/datum/computer_file/program/emag_console
	filename = "emag_console"
	filedesc = "Crypto-breaker"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "hostile"
	extended_desc = "The console output from an emag. You shouldn't be seeing this."
	size = 0
	available_on_ntnet = FALSE
	tgui_id = "NtosEmagConsole"

/datum/computer_file/program/emag_console/ui_act(action,params,datum/tgui/ui)
	if(!ui || ui.status != UI_INTERACTIVE)
		return TRUE
	kill_program(forced = TRUE)
	return TRUE

/datum/computer_file/program/emag_console/kill_program(forced)
	. = ..()
	if(computer)
		computer.device_theme = THEME_SYNDICATE
		computer.allowed_themes = GLOB.ntos_device_themes_emagged
