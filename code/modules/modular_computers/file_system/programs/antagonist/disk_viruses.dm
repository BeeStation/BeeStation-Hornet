/datum/computer_file/program/virus_basic
	filename = "virus payload"
	filedesc = "basic-breaker"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "hostile"
	extended_desc = "The console output from a virus. You shouldn't be seeing this."
	size = 0
	available_on_ntnet = FALSE
	tgui_id = "NtosVirus"

/datum/computer_file/program/virus_basic/ui_act(action,params,datum/tgui/ui)
	if(!ui || ui.status != UI_INTERACTIVE)
		return TRUE
	if(computer)
		computer.device_theme = THEME_SYNDICATE
		computer.allowed_themes = GLOB.ntos_device_themes_emagged
	kill_program(forced = TRUE)
	return TRUE

/datum/computer_file/program/virus_basic/kill_program(forced)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/portable/portable_drive = computer.all_components[MC_SDD]
	new /obj/effect/particle_effect/sparks/red(get_turf(computer))
	playsound(computer, "sparks", 50, 1)
	playsound(computer, 'sound/machines/defib_failed.ogg', 50, TRUE)
	if(portable_drive)
		computer.uninstall_component(portable_drive)
		qdel(portable_drive)


/datum/computer_file/program/virus_basic/basic
	filename = "advanced virus payload"

/datum/computer_file/program/virus_basic/basic/kill_program(forced)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/hard_drive = computer.all_components[MC_HDD]
	if(hard_drive)
		computer.uninstall_component(hard_drive) // Hacked basic disk will brick the computer by destroying the hard drive
		qdel(hard_drive)

/datum/computer_file/program/virus_basic/advanced
	filename = "advanced virus payload"

/datum/computer_file/program/virus_basic/advanced/kill_program(forced)
	. = ..()
	if(computer)
		empulse(get_turf(computer), 3, 5) // Hacked advanced disk will cause an aoe emp

/datum/computer_file/program/virus_basic/super
	filename = "super advanced virus payload"

/datum/computer_file/program/virus_basic/super/kill_program(forced)
	. = ..()
	var/obj/item/computer_hardware/battery/controler = computer.all_components[MC_CELL]
	if(controler)	// Hacked super disk will cause an explosion by hacking the battery controler
		controler.hacked = TRUE
		controler.battery.charge = 1

/datum/computer_file/program/antivirus_readme
	filename = "Crack-README.txt"
	filedesc = "Crack-README.txt"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "notepad"
	extended_desc = "This file explains how to use this cracked subscription package."
	size = 0
	available_on_ntnet = FALSE
	tgui_id = "antivirus_readme"
	program_icon = "file-lines"
