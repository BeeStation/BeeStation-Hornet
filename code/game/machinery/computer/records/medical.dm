/obj/machinery/computer/records/medical
	name = "medical records console"
	desc = "This can be used to check medical records."
	icon_screen = "medcomp"
	icon_keyboard = "med_key"
	req_one_access = list(ACCESS_MEDICAL, ACCESS_FORENSICS_LOCKERS)
	circuit = /obj/item/circuitboard/computer/records/medical
	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/records/medical/syndie
	icon_keyboard = "syndie_key"

/obj/machinery/computer/records/medical/laptop
	name = "medical laptop"
	desc = "A cheap Nanotrasen medical laptop, it functions as a medical records computer. It's bolted to the table."
	icon_state = "laptop"
	icon_screen = "medlaptop"
	icon_keyboard = "laptop_key"

	pass_flags = PASSTABLE
	//these muthafuckas arent supposed to smooth
	base_icon_state = null
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null

/obj/machinery/computer/records/medical/attacked_by(obj/item/attacking_item, mob/living/user)
	. = ..()
	if(!istype(attacking_item, /obj/item/photo))
		return
	insert_new_record(user, attacking_item)

/obj/machinery/computer/records/medical/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(.)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		character_preview_view = create_character_preview_view(user)
		ui = new(user, src, "MedicalRecords")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/computer/records/medical/ui_data(mob/user)
	var/list/data = ..()

	var/list/records = list()
	for(var/datum/record/crew/target in GLOB.manifest.general)
		var/list/notes = list()
		for(var/datum/medical_note/note in target.medical_notes)
			notes += list(list(
				author = note.author,
				content = note.content,
				note_ref = REF(note),
				time = note.time,
			))

		records += list(list(
			age = target.age,
			blood_type = target.blood_type,
			crew_ref = REF(target),
			dna = target.dna_string,
			gender = target.gender,
			major_disabilities = target.major_disabilities_desc,
			minor_disabilities = target.minor_disabilities_desc,
			physical_status = target.physical_status,
			mental_status = target.mental_status,
			name = target.name,
			notes = notes,
			quirk_notes = target.quirk_notes,
			rank = target.rank,
			species = target.species,
		))

	data["records"] = records

	return data

/obj/machinery/computer/records/medical/ui_static_data(mob/user)
	var/list/data = list()
	data["min_age"] = AGE_MIN
	data["max_age"] = AGE_MAX
	data["physical_statuses"] = PHYSICAL_STATUSES
	data["mental_statuses"] = MENTAL_STATUSES
	return data

/obj/machinery/computer/records/medical/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/datum/record/crew/target
	if(params["crew_ref"])
		target = locate(params["crew_ref"]) in GLOB.manifest.general
	if(!target)
		return FALSE

	switch(action)
		if("add_note")
			if(!params["content"])
				return FALSE
			var/content = trim(params["content"], MAX_MESSAGE_LEN)

			var/datum/medical_note/new_note = new(usr.name, content)
			while(length(target.medical_notes) > 2)
				target.medical_notes.Cut(1, 2)

			target.medical_notes += new_note

			return TRUE

		if("delete_note")
			var/datum/medical_note/old_note = locate(params["note_ref"]) in target.medical_notes
			if(!old_note)
				return FALSE

			target.medical_notes -= old_note
			qdel(old_note)

			return TRUE

		if("set_physical_status")
			var/physical_status = params["physical_status"]
			if(!physical_status || !(physical_status in PHYSICAL_STATUSES))
				return FALSE

			target.physical_status = physical_status

			return TRUE

		if("set_mental_status")
			var/mental_status = params["mental_status"]
			if(!mental_status || !(mental_status in MENTAL_STATUSES))
				return FALSE

			target.mental_status = mental_status

			return TRUE

		if("set_physical_status")
			var/physical_status = params["physical_status"]
			if(!physical_status || !(physical_status in PHYSICAL_STATUSES))
				return FALSE

			target.physical_status = physical_status

			return TRUE

		if("set_mental_status")
			var/mental_status = params["mental_status"]
			if(!mental_status || !(mental_status in MENTAL_STATUSES))
				return FALSE

			target.mental_status = mental_status

			return TRUE

	return FALSE

/// Deletes medical information from a record.
/obj/machinery/computer/records/medical/expunge_record_info(datum/record/crew/target)
	if(!target)
		return FALSE

	target.age = 18
	target.blood_type = pick(list("A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"))
	target.dna_string = "Unknown"
	target.gender = "Unknown"
	target.major_disabilities = ""
	target.major_disabilities_desc = ""
	target.medical_notes.Cut()
	target.minor_disabilities = ""
	target.minor_disabilities_desc = ""
	target.physical_status = ""
	target.mental_status = ""
	target.name = "Unknown"
	target.quirk_notes = ""
	target.rank = "Unknown"
	target.species = "Unknown"

	return TRUE
