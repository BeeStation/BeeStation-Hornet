/obj/machinery/computer/records/medical
	name = "medical records console"
	desc = "This can be used to check medical records."
	icon_screen = "medcomp"
	icon_keyboard = "med_key"
	req_one_access = list(ACCESS_BRIGPHYS, ACCESS_MEDICAL, ACCESS_FORENSICS_LOCKERS)
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

/obj/machinery/computer/records/medical/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(.)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "MedicalRecords")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/computer/records/medical/ui_data(mob/user)
	var/list/data = ..()

	var/list/records = list()
	for(var/datum/record/crew/each_record in GLOB.manifest.general)
		records += list(each_record.get_info_list())

	data["records"] = records

	return data

/obj/machinery/computer/records/medical/ui_static_data(mob/user)
	var/list/data = list()
	data["min_age"] = AGE_MIN
	data["max_age"] = AGE_MAX
	data["physical_statuses"] = PHYSICAL_STATUSES()
	data["mental_statuses"] = MENTAL_STATUSES()
	data["character_preview_view"] = character_preview_view.assigned_map
	return data

/obj/machinery/computer/records/medical/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	if (!authenticated || issilicon(usr)) // Silicons are forbidden from editing records.
		return FALSE

	var/datum/record/crew/target_record
	if(params["record_ref"])
		target_record = locate(params["record_ref"]) in GLOB.manifest.general
	if(isnull(target_record))
		return FALSE

	switch(action)
		if("add_note")
			target_record.add_medical_note(sanitize_ic(params["content"]), usr.name)
			return TRUE

		if("delete_note")
			target_record.delete_medical_note(params["note_ref"])
			return TRUE

		if("set_physical_status")
			target_record.set_physical_status(sanitize_ic(params["physical_status"]))
			return TRUE

		if("set_mental_status")
			target_record.set_mental_status(sanitize_ic(params["mental_status"]))
			return TRUE

	return FALSE

/obj/machinery/computer/records/medical/can_edit_field(field)
	switch (field)
		if ("age")
			return TRUE
		if ("species")
			return TRUE
		if ("gender")
			return TRUE
		if ("dna_string")
			return TRUE
		if ("blood_type")
			return TRUE
	return FALSE
