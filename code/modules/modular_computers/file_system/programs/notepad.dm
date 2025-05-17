#define PRINTER_TIMEOUT 10

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
	usage_flags = PROGRAM_PDA
	/// Cooldown var for printing paper sheets.
	COOLDOWN_DECLARE(printer_ready)

/datum/computer_file/program/notepad/on_ui_create(mob/user, datum/tgui/ui)
	COOLDOWN_START(src, printer_ready, PRINTER_TIMEOUT)

/datum/computer_file/program/notepad/proc/set_note(note)
	var/obj/item/modular_computer/tablet/tablet = computer
	if(!istype(tablet))
		return
	tablet.note = note

/datum/computer_file/program/notepad/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("UpdateNote")
			src.set_note(params["newnote"])
			return TRUE

		if("ShowPaper")
			var/obj/item/modular_computer/tablet/tablet = computer
			if(!istype(tablet) || QDELETED(tablet.stored_paper))
				return
			tablet.stored_paper.ui_interact(usr)
			return TRUE

		if("PRG_savelog")
			var/obj/item/modular_computer/tablet/tablet = computer
			if(!istype(tablet))
				return

			var/logname = check_filename(params["log_name"])
			if(!logname)
				return
			// Now we will generate HTML-compliant file that can actually be viewed/printed.
			var/datum/computer_file/data/log_file/logfile = new()
			logfile.filename = "[logname].txt" // Custom extension, different from .log

			var/log_data = tablet.note ? tablet.note : ""
			logfile.set_stored_data(log_data)

			var/obj/item/computer_hardware/hard_drive/hard_drive = computer.all_components[MC_HDD]
			if(!hard_drive)
				computer.visible_message(span_warning("\The [computer] shows an \"I/O Error - Hard drive connection error\" warning."))
			else if(!hard_drive.store_file(logfile))
				computer.visible_message(span_warning("\The [computer] shows an \"I/O Error - Hard drive may be full or the file may have the same name as another. Please free some space and try again. Required space: [logfile.size]GQ\" warning."))

			computer.send_sound()
			return TRUE

		if("PrintNote")
			if(!COOLDOWN_FINISHED(src, printer_ready))
				to_chat(usr, span_warning("The printer is not ready to print yet!"))
				return
			var/obj/item/modular_computer/tablet/tablet = computer
			if(!istype(tablet))
				return
			var/obj/item/computer_hardware/printer/printer
			if(computer)
				printer = computer.all_components[MC_PRINT]
			if(printer)
				var/printable_text = copytext(tablet.note, 1, MAX_PAPER_LENGTH + 1) // Includes up to 5000 chars
				if(!printer.print_text(printable_text))
					to_chat(usr, span_notice("Hardware error: Printer was unable to print the file. It may be out of paper."))
					return
				else
					COOLDOWN_START(src, printer_ready, PRINTER_TIMEOUT)
					computer.visible_message(span_notice("\The [computer] prints out a paper."))

/datum/computer_file/program/notepad/ui_data(mob/user)
	var/list/data = list()
	var/obj/item/modular_computer/tablet/tablet = computer
	var/obj/item/computer_hardware/printer/printer
	if(computer)
		printer = computer.all_components[MC_PRINT]
	if(!istype(tablet))
		return data
	data["note"] = tablet.note
	data["has_paper"] = !QDELETED(tablet.stored_paper)
	data["has_printer"] =  printer ? TRUE : FALSE

	return data

#undef PRINTER_TIMEOUT
