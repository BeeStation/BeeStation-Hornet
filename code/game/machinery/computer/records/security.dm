#define COMP_SECURITY_ARREST_AMOUNT_TO_FLAG 10
#define PRINTOUT_MISSING "Missing"
#define PRINTOUT_RAPSHEET "Rapsheet"
#define PRINTOUT_WANTED "Wanted"
/// Editing this will cause UI issues.
#define MAX_CRIME_NAME_LEN 24

/obj/machinery/computer/records/security
	name = "security records console"
	desc = "Used to view and edit personnel's security records."
	icon_screen = "security"
	icon_keyboard = "security_key"
	req_one_access = list(ACCESS_SEC_RECORDS)
	circuit = /obj/item/circuitboard/computer/records/security
	light_color = LIGHT_COLOR_RED

	/// The current state of the printer
	var/printing = FALSE

CREATION_TEST_IGNORE_SUBTYPES(/obj/machinery/computer/records/security)

/obj/machinery/computer/records/security/syndie
	icon_keyboard = "syndie_key"
	req_one_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/records/security/laptop
	name = "security laptop"
	desc = "A cheap Nanotrasen security laptop, it functions as a security records console. It's bolted to the table."
	icon_state = "laptop"
	icon_screen = "seclaptop"
	icon_keyboard = "laptop_key"

/obj/machinery/computer/records/security/laptop/syndie
	desc = "A cheap, jailbroken security laptop. It functions as a security records console. It's bolted to the table."
	req_one_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/records/security/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/arrest_console_data,
		/obj/item/circuit_component/arrest_console_arrest,
	))

/obj/machinery/computer/records/security/emp_act(severity)
	. = ..()

	if(machine_stat & (BROKEN|NOPOWER) || . & EMP_PROTECT_SELF)
		return

	for(var/datum/record/crew/target in GLOB.manifest.general)
		if(prob(10/severity))
			switch(rand(1,5))
				if(1)
					if(prob(10))
						target.name = "[pick(random_lizard_name(MALE),random_lizard_name(FEMALE))]"
					else
						target.name = "[pick(pick(GLOB.first_names_male), pick(GLOB.first_names_female))] [pick(GLOB.last_names)]"
				if(2)
					target.gender = pick("Male", "Female", "Other")
				if(3)
					target.age = rand(5, 85)
				if(4)
					target.wanted_status = pick(WANTED_STATUSES)
				if(5)
					target.species = pick(get_selectable_species())
			continue

		else if(prob(1))
			qdel(target)
			continue

/obj/machinery/computer/records/security/attacked_by(obj/item/attacking_item, mob/living/user)
	. = ..()
	if(!istype(attacking_item, /obj/item/photo))
		return
	insert_new_record(user, attacking_item)

/obj/machinery/computer/records/security/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(.)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		character_preview_view = create_character_preview_view(user)
		ui = new(user, src, "SecurityRecords")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/computer/records/security/ui_data(mob/user)
	var/list/data = ..()

	data["available_statuses"] = WANTED_STATUSES
	data["current_user"] = user.name
	data["higher_access"] = has_armory_access(user)

	var/list/records = list()
	for(var/datum/record/crew/target in GLOB.manifest.general)
		var/list/citations = list()
		for(var/datum/crime/citation/warrant in target.citations)
			citations += list(list(
				author = warrant.author,
				crime_ref = REF(warrant),
				details = warrant.details,
				fine = warrant.fine,
				name = warrant.name,
				paid = warrant.paid,
				time = warrant.time,
				valid = warrant.valid,
				voider = warrant.voider,
			))

		var/list/crimes = list()
		for(var/datum/crime/crime in target.crimes)
			crimes += list(list(
				author = crime.author,
				crime_ref = REF(crime),
				details = crime.details,
				name = crime.name,
				time = crime.time,
				valid = crime.valid,
				voider = crime.voider,
			))

		records += list(list(
			age = target.age,
			citations = citations,
			crew_ref = REF(target),
			crimes = crimes,
			fingerprint = target.fingerprint,
			gender = target.gender,
			name = target.name,
			security_note = target.security_note,
			rank = target.rank,
			species = target.species,
			wanted_status = target.wanted_status,
		))

	data["records"] = records

	return data


/obj/machinery/computer/records/security/ui_static_data(mob/user)
	var/list/data = list()
	data["min_age"] = AGE_MIN
	data["max_age"] = AGE_MAX
	data["character_preview_view"] = character_preview_view.assigned_map
	return data

/obj/machinery/computer/records/security/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	var/datum/record/crew/target
	if(params["crew_ref"])
		target = locate(params["crew_ref"]) in GLOB.manifest.general
	if(!target)
		return FALSE

	switch(action)
		if("add_crime")
			add_crime(user, target, params)
			return TRUE

		if("delete_record")
			qdel(target)
			return TRUE

		if("edit_crime")
			edit_crime(user, target, params)
			return TRUE

		if("invalidate_crime")
			invalidate_crime(user, target, params)
			return TRUE

		if("print_record")
			print_record(user, target, params)
			return TRUE

		if("set_note")
			var/security_note = params["security_note"]
			target.security_note = trim(security_note, MAX_MESSAGE_LEN)
			return TRUE

		if("set_wanted")
			var/wanted_status = params["status"]
			if(!wanted_status || !(wanted_status in WANTED_STATUSES))
				return FALSE
			if(wanted_status == WANTED_ARREST && !length(target.crimes))
				return FALSE
			target.wanted_status = wanted_status

			update_matching_security_huds(target.name)

			return TRUE

	return FALSE

/// Handles adding a crime to a particular record.
/obj/machinery/computer/records/security/proc/add_crime(mob/user, datum/record/crew/target, list/params)
	var/input_name = trim(params["name"], MAX_CRIME_NAME_LEN)
	if(!input_name)
		to_chat(user, "<span class='warning'>You must enter a name for the crime.</span>")
		playsound(src, 'sound/machines/terminal_error.ogg', 75, TRUE)
		return FALSE

	var/max = CONFIG_GET(number/maxfine)
	if(params["fine"] > max)
		to_chat(user, "<span class='warning'>The maximum fine is [max] credits.</span>")
		playsound(src, 'sound/machines/terminal_error.ogg', 75, TRUE)
		return FALSE

	var/input_details
	if(params["details"])
		input_details = trim(params["details"], MAX_MESSAGE_LEN)

	if(params["fine"] == 0)
		var/datum/crime/new_crime = new(name = input_name, details = input_details, author = user)
		target.crimes += new_crime
		target.wanted_status = WANTED_ARREST
		investigate_log("New Crime: <strong>[input_name]</strong> | Added to [target.name] by [key_name(user)]", INVESTIGATE_RECORDS)

		update_matching_security_huds(target.name)
		return TRUE

	var/datum/crime/citation/new_citation = new(name = input_name, details = input_details, author = user, fine = params["fine"])

	target.citations += new_citation
	new_citation.alert_owner(user, src, target.name, "You have been issued a [params["fine"]]cr citation for [input_name]. Fines are payable at Security.")
	investigate_log("New Citation: <strong>[input_name]</strong> Fine: [params["fine"]] | Added to [target.name] by [key_name(user)]", INVESTIGATE_RECORDS)

	return TRUE

/// Handles editing a crime on a particular record.
/obj/machinery/computer/records/security/proc/edit_crime(mob/user, datum/record/crew/target, list/params)
	var/datum/crime/editing_crime = locate(params["crime_ref"]) in target.crimes
	if(!editing_crime?.valid)
		editing_crime = locate(params["crime_ref"]) in target.citations //One last hail mary.
		if(!editing_crime?.valid)
			return FALSE

	if(user != editing_crime.author && !has_armory_access(user)) // only warden/hos/command can edit crimes they didn't author
		return FALSE

	if(params["name"] && length(params["name"]) > 2 && params["name"] != editing_crime.name)
		editing_crime.name = trim(params["name"], MAX_CRIME_NAME_LEN)
		return TRUE

	if(params["description"] && length(params["description"]) > 2 && params["description"] != editing_crime.details)
		var/new_details = STRIP_HTML_FULL(params["description"], MAX_MESSAGE_LEN)
		editing_crime.details = new_details
		return TRUE

	return FALSE

/// Deletes security information from a record.
/obj/machinery/computer/records/security/expunge_record_info(datum/record/crew/target)
	target.citations.Cut()
	target.crimes.Cut()
	target.security_note = "None."
	target.wanted_status = WANTED_NONE
	return TRUE

/// Only qualified personnel can edit records.
/obj/machinery/computer/records/security/proc/has_armory_access(mob/user)
	if(issiliconoradminghost(user))
		return TRUE
	if(!isliving(user))
		return FALSE
	var/mob/living/player = user

	var/obj/item/card/id/auth = player.get_idcard(TRUE)
	if(!auth)
		return FALSE

	if(!(ACCESS_ARMORY in auth.GetAccess()))
		return FALSE

	return TRUE

/// Voids crimes, or sets someone to discharged if they have none left.
/obj/machinery/computer/records/security/proc/invalidate_crime(mob/user, datum/record/crew/target, list/params)
	var/acquitted = TRUE
	var/datum/crime/to_void = locate(params["crime_ref"]) in target.crimes
	if(!to_void)
		to_void = locate(params["crime_ref"]) in target.citations
		// No need to change status after invalidatation of citation
		acquitted = FALSE
		if(!to_void)
			return FALSE

	if(user != to_void.author && !has_armory_access(user))
		return FALSE

	to_void.valid = FALSE
	to_void.voider = user
	investigate_log("[key_name(user)] has invalidated [target.name]'s crime: [to_void.name]", INVESTIGATE_RECORDS)

	for(var/datum/crime/incident in target.crimes)
		if(!incident.valid)
			continue
		acquitted = FALSE
		break

	if(acquitted)
		target.wanted_status = WANTED_DISCHARGED
		investigate_log("[key_name(user)] has invalidated [target.name]'s last valid crime. Their status is now [WANTED_DISCHARGED].", INVESTIGATE_RECORDS)

	update_matching_security_huds(target.name)

	return TRUE

/// Finishes printing, resets the printer.
/obj/machinery/computer/records/security/proc/print_finish(obj/item/printable)
	printing = FALSE
	playsound(src, 'sound/machines/terminal_eject.ogg', 100, TRUE)
	printable.forceMove(loc)

	return TRUE

/// Handles printing records via UI. Takes the params from UI_act.
/obj/machinery/computer/records/security/proc/print_record(mob/user, datum/record/crew/target, list/params)
	if(printing)
		balloon_alert(user, "printer busy")
		playsound(src, 'sound/machines/terminal_error.ogg', 100, TRUE)
		return FALSE

	printing = TRUE
	balloon_alert(user, "printing")
	playsound(src, 'sound/items/taperecorder/taperecorder_print.ogg', 100, TRUE)

	var/obj/item/printable
	var/input_alias = trim(params["alias"], MAX_NAME_LEN) || target.name
	var/input_description = trim(params["desc"], MAX_BROADCAST_LEN) || "No further details."
	var/input_header = trim(params["head"], 8) || capitalize(params["type"])

	switch(params["type"])
		if("missing")
			var/obj/item/photo/mugshot = target.get_front_photo()
			var/obj/item/poster/wanted/missing/missing_poster = new(null, mugshot.picture.picture_image, input_alias, input_description, input_header)

			printable = missing_poster

		if("wanted")
			var/list/crimes = target.crimes
			if(!length(crimes))
				balloon_alert(user, "no crimes")
				return FALSE

			input_description += "\n\n<b>WANTED FOR:</b>"
			for(var/datum/crime/incident in crimes)
				if(!incident.valid)
					input_description += "<b>--REDACTED--</b>"
					continue
				input_description += "\n<bCrime:</b> [incident.name]\n"
				input_description += "<b>Details:</b> [incident.details]\n"

			var/obj/item/photo/mugshot = target.get_front_photo()
			var/obj/item/poster/wanted/wanted_poster = new(null, mugshot.picture.picture_image, input_alias, input_description, input_header)

			printable = wanted_poster

		if("rapsheet")
			var/list/crimes = target.crimes
			if(!length(crimes))
				balloon_alert(user, "no crimes")
				return FALSE

			var/obj/item/paper/rapsheet = target.get_rapsheet(input_alias, input_header, input_description)
			printable = rapsheet

	addtimer(CALLBACK(src, PROC_REF(print_finish), printable), 2 SECONDS, TIMER_UNIQUE | TIMER_STOPPABLE)

	return TRUE


/**
 * Security circuit component
 */

/obj/item/circuit_component/arrest_console_data
	display_name = "Security Records Data"
	desc = "Outputs the security records data, where it can then be filtered with a Select Query component"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The records retrieved
	var/datum/port/output/records

	/// Sends a signal on failure
	var/datum/port/output/on_fail

	var/obj/machinery/computer/records/security/attached_console

/obj/item/circuit_component/arrest_console_data/populate_ports()
	records = add_output_port("Security Records", PORT_TYPE_TABLE)
	on_fail = add_output_port("Failed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/arrest_console_data/register_usb_parent(atom/movable/parent)
	. = ..()
	if(istype(parent, /obj/machinery/computer/records/security))
		attached_console = parent

/obj/item/circuit_component/arrest_console_data/unregister_usb_parent(atom/movable/parent)
	attached_console = null
	return ..()

/obj/item/circuit_component/arrest_console_data/get_ui_notices()
	. = ..()
	. += create_table_notices(list(
		"name",
		"id",
		"rank",
		"arrest_status",
		"gender",
		"age",
		"species",
		"fingerprint",
	))


/obj/item/circuit_component/arrest_console_data/input_received(datum/port/input/port)

	if(!attached_console || !attached_console.authenticated)
		on_fail.set_output(COMPONENT_SIGNAL)
		return

	if(isnull(GLOB.manifest.general))
		on_fail.set_output(COMPONENT_SIGNAL)
		return

	var/list/new_table = list()
	for(var/datum/record/crew/player_record as anything in GLOB.manifest.general)
		var/list/entry = list()
		entry["age"] = player_record.age
		entry["arrest_status"] = player_record.wanted_status
		entry["fingerprint"] = player_record.fingerprint
		entry["gender"] = player_record.gender
		entry["name"] = player_record.name
		entry["rank"] = player_record.rank
		entry["record"] = REF(player_record)
		entry["species"] = player_record.species

		new_table += list(entry)

	records.set_output(new_table)

/obj/item/circuit_component/arrest_console_arrest
	display_name = "Security Records Set Status"
	desc = "Receives a table to use to set people's arrest status. Table should be from the security records data component. If New Status port isn't set, the status will be decided by the options."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The targets to set the status of.
	var/datum/port/input/targets

	/// Sets the new status of the targets.
	var/datum/port/input/option/new_status

	/// Returns the new status set once the setting is complete. Good for locating errors.
	var/datum/port/output/new_status_set

	/// Sends a signal on failure
	var/datum/port/output/on_fail

	var/obj/machinery/computer/records/security/attached_console

/obj/item/circuit_component/arrest_console_arrest/register_usb_parent(atom/movable/parent)
	. = ..()
	if(istype(parent, /obj/machinery/computer/records/security))
		attached_console = parent

/obj/item/circuit_component/arrest_console_arrest/unregister_usb_parent(atom/movable/parent)
	attached_console = null
	return ..()

/obj/item/circuit_component/arrest_console_arrest/populate_options()
	if(!attached_console)
		return
	var/list/available_statuses = WANTED_STATUSES
	new_status = add_option_port("Arrest Options", available_statuses)

/obj/item/circuit_component/arrest_console_arrest/populate_ports()
	targets = add_input_port("Targets", PORT_TYPE_TABLE)
	new_status_set = add_output_port("Set Status", PORT_TYPE_STRING)
	on_fail = add_output_port("Failed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/arrest_console_arrest/input_received(datum/port/input/port)

	if(!attached_console || !attached_console.authenticated)
		on_fail.set_output(COMPONENT_SIGNAL)
		return

	var/status_to_set = new_status.value

	new_status_set.set_output(status_to_set)
	var/list/target_table = targets.value
	if(!target_table)
		on_fail.set_output(COMPONENT_SIGNAL)
		return

	var/successful_set = 0
	var/list/names_of_entries = list()
	for(var/list/target in target_table)
		var/datum/record/crew/sec_record = target["security_record"]
		if(!sec_record)
			continue

		if(sec_record.wanted_status != status_to_set)
			successful_set++
			names_of_entries += target["name"]
		sec_record.wanted_status = status_to_set

	if(successful_set > 0)
		investigate_log("[parent.get_creator()] has set security records for '[names_of_entries.Join(", ")]' to [status_to_set] via circuits.", INVESTIGATE_RECORDS)
		if(successful_set > COMP_SECURITY_ARREST_AMOUNT_TO_FLAG)
			message_admins("[successful_set] security entries have been set to [status_to_set] by [parent.get_creator_admin()]. [ADMIN_COORDJMP(src)]")
		update_all_security_huds()

#undef COMP_SECURITY_ARREST_AMOUNT_TO_FLAG
#undef PRINTOUT_MISSING
#undef PRINTOUT_RAPSHEET
#undef PRINTOUT_WANTED
#undef MAX_CRIME_NAME_LEN
