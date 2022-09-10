/datum/computer_file/program/notepad
	filename = "notepad"
	filedesc = "Notepad"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Jot down your work-safe thoughts and what not."
	size = 2
	tgui_id = "NtosNotepad"
	program_icon = "book"
	usage_flags = PROGRAM_TABLET

/datum/computer_file/program/notepad/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("UpdateNote")
			var/obj/item/modular_computer/tablet/comp = computer
			comp.note = params["newnote"]
			return UI_UPDATE

/datum/computer_file/program/notepad/ui_data(mob/user)
	var/list/data = get_header_data()
	var/obj/item/modular_computer/tablet/comp = computer

	data["note"] = comp.note

	return data
