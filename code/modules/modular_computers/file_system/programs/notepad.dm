/datum/computer_file/program/notepad
	filename = "notepad"
	filedesc = "Notepad"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "Jot down your work-safe thoughts and what not."
	size = 0
	undeletable = TRUE // It comes by default in PDAs, can't be downloaded, takes no space and should obviously not be able to be deleted.
	available_on_ntnet = FALSE
	tgui_id = "NtosNotepad"
	program_icon = "book"
	usage_flags = PROGRAM_TABLET

/datum/computer_file/program/notepad/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("UpdateNote")
			var/obj/item/modular_computer/tablet/tablet = computer
			if(!istype(tablet))
				return
			tablet.note = params["newnote"]
			return TRUE
		if("ShowPaper")
			var/obj/item/modular_computer/tablet/tablet = computer
			if(!istype(tablet) || QDELETED(tablet.stored_paper))
				return
			tablet.stored_paper.ui_interact(usr)
			return TRUE


/datum/computer_file/program/notepad/ui_data(mob/user)
	var/list/data = list()
	var/obj/item/modular_computer/tablet/tablet = computer
	if(!istype(tablet))
		return data
	data["note"] = tablet.note
	data["has_paper"] = !QDELETED(tablet.stored_paper)

	return data
