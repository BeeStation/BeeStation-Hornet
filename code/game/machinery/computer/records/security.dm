#define COMP_SECURITY_ARREST_AMOUNT_TO_FLAG 10
#define PRINTOUT_MISSING "Missing"
#define PRINTOUT_RAPSHEET "Rapsheet"
#define PRINTOUT_WANTED "Wanted"


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
	//How many posters to print for this record. Yes i am doing this for you, Ragantis.
	var/amount = 1

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
		ui = new(user, src, "SecurityRecords")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/computer/records/security/ui_data(mob/user)
	var/list/data = ..()

	data["available_statuses"] = WANTED_STATUSES()
	data["current_user"] = user.name
	data["higher_access"] = has_armory_access(user)
	data["amount"] = amount

	var/list/records = list()
	for(var/datum/record/crew/target in GLOB.manifest.general)
		var/list/citations = list()
		for(var/datum/crime_record/citation/warrant in target.citations)
			citations += list(list(
				author = warrant.author,
				crime_ref = FAST_REF(warrant),
				details = warrant.details,
				fine = warrant.fine,
				name = warrant.name,
				paid = warrant.paid,
				time = warrant.time,
				valid = warrant.valid,
				voider = warrant.voider,
			))

		var/list/crimes = list()
		for(var/datum/crime_record/crime in target.crimes)
			crimes += list(list(
				author = crime.author,
				crime_ref = FAST_REF(crime),
				details = crime.details,
				name = crime.name,
				time = crime.time,
				valid = crime.valid,
				voider = crime.voider,
			))

		records += list(list(
			age = target.age,
			citations = citations,
			record_ref = REF(target),
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
	var/datum/record/crew/target_record

	if (!authenticated || issilicon(user)) // Silicons are forbidden from editing records.
		return FALSE

	if (action == "set_amount")
		set_print_amount(sanitize_integer(params["new_amount"]))
		return TRUE

	if(params["record_ref"])
		target_record = locate(params["record_ref"]) in GLOB.manifest.general
	if(!target_record)
		return FALSE

	switch(action)
		if("add_crime")
			target_record.add_crime(user, sanitize_ic(params["name"]), sanitize_integer(params["fine"]), sanitize_ic(params["details"]), src)
			return TRUE

		if("delete_record")
			qdel(target_record)
			return TRUE

		if("edit_crime")
			target_record.edit_crime(user, sanitize_ic(params["name"]), sanitize_ic(params["description"]), params["crime_ref"])
			return TRUE

		if("invalidate_crime")
			target_record.invalidate_crime(user, params["crime_ref"], target_record.crimes, target_record.citations)
			return TRUE

		if("delete_crime")
			target_record.delete_crime(user, params["crime_ref"], target_record.crimes, target_record.citations)
			return TRUE

		if("print_record")
			print_record(user, target_record, sanitize_ic(params["alias"]), sanitize_ic(params["desc"]), sanitize_ic(params["head"]), sanitize_ic(params["type"]))
			return TRUE

		if("set_note")
			target_record.set_security_note(sanitize_ic(params["security_note"]))
			return TRUE

		if("set_wanted")
			target_record.set_wanted_status(sanitize_ic(params["status"]))
			return TRUE

	return FALSE

/obj/machinery/computer/records/security/can_edit_field(field)
	switch (field)
		if ("name")
			return TRUE
		if ("rank")
			return TRUE
		if ("age")
			return TRUE
		if ("species")
			return TRUE
		if ("gender")
			return TRUE
		if ("fingerprint")
			return TRUE
		if ("security_note")
			return TRUE
	return FALSE

// Changing how many posters to print.
/obj/machinery/computer/records/security/proc/set_print_amount(new_amount)
	var/target = text2num(new_amount)
	amount = target
	return TRUE

/// Finishes printing, resets the printer.
/obj/machinery/computer/records/security/proc/print_finish(list/to_print)
	printing = FALSE
	playsound(src, 'sound/machines/terminal_eject.ogg', 100, TRUE)

	for(var/obj/item/printable as anything in to_print)
		printable.forceMove(loc)

	return TRUE

/// Handles printing records via UI. Takes the params from UI_act.
/obj/machinery/computer/records/security/proc/print_record(mob/user, datum/record/crew/target, alias, description, header, type)
	if(printing)
		balloon_alert(user, "printer busy")
		playsound(src, 'sound/machines/terminal_error.ogg', 100, TRUE)
		return FALSE

	printing = TRUE
	balloon_alert(user, "printing")
	playsound(src, 'sound/items/taperecorder/taperecorder_print.ogg', 100, TRUE)

	var/list/to_print = new()
	var/input_alias = trim(alias, MAX_NAME_LEN) || target.name
	var/input_description = trim(description, MAX_BROADCAST_LEN) || "No further details."
	var/input_header = trim(header, 8) || capitalize(type)
	for(var/amount_to_print in 1 to amount)
		switch(type)
			if("missing")
				var/obj/item/photo/mugshot = target.get_front_photo()
				var/obj/item/poster/wanted/missing/missing_poster = new(null, mugshot.picture.picture_image, input_alias, input_description, input_header)

				to_print.Add(missing_poster)

			if("wanted")
				var/list/crimes = target.crimes
				if(!length(crimes))
					balloon_alert(user, "no crimes")
					return FALSE

				input_description += "\n\n<b>WANTED FOR:</b>"
				for(var/datum/crime_record/incident in crimes)
					if(!incident.valid)
						input_description += "<b>--REDACTED--</b>"
						continue
					input_description += "\n<bCrime:</b> [incident.name]\n"
					input_description += "<b>Details:</b> [incident.details]\n"

				var/obj/item/photo/mugshot = target.get_front_photo()
				var/obj/item/poster/wanted/wanted_poster = new(null, mugshot.picture.picture_image, input_alias, input_description, input_header)

				to_print.Add(wanted_poster)

			if("rapsheet")
				var/list/crimes = target.crimes
				if(!length(crimes))
					balloon_alert(user, "no crimes")
					return FALSE

				var/obj/item/paper/rapsheet = target.get_rapsheet(input_alias, input_header, input_description)
				to_print.Add(rapsheet)

	addtimer(CALLBACK(src, PROC_REF(print_finish), to_print), 2 SECONDS, TIMER_UNIQUE | TIMER_STOPPABLE)

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
	var/list/available_statuses = WANTED_STATUSES()
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
