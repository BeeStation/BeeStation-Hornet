/datum/computer_file/program/readme
	filename = "README.txt"
	filedesc = "README.txt"
	program_icon_state = "notepad"
	extended_desc = "This is a nothign burger."
	size = 0
	available_on_ntnet = FALSE
	tgui_id = "antivirus_readme"
	program_icon = "file-lines"
	power_consumption = 80 WATT

/datum/computer_file/program/readme/coil_readme
	filename = "Coilvrs-README.txt"
	filedesc = "Coilvrs-README.txt"
	extended_desc = "This file explains how to use the Coilvrs Executable."
	tgui_id = "VirusReadme_Coil"

/datum/computer_file/program/readme/breacher_readme
	filename = "BrexerTrojn-README.txt"
	filedesc = "BrexerTrojn-README.txt"
	extended_desc = "This file explains how to use the BrexerTrojn Executable."
	tgui_id = "VirusReadme_Breacher"

/datum/computer_file/program/readme/sledge_readme
	filename = "Sleghamr-README.txt"
	filedesc = "Sleghamr-README.txt"
	extended_desc = "This file explains how to use the Sleghamr Executable."
	tgui_id = "VirusReadme_Sledge"

/datum/computer_file/program/readme/antivirus_readme
	filename = "Crack-README.txt"
	filedesc = "Crack-README.txt"
	extended_desc = "This file explains how to use this cracked subscription package of NTOS Virus Buster."
	tgui_id = "antivirus_readme"

/datum/computer_file/program/coil_virus
	filename = "Coilvrs.exe"
	filedesc = "Coilvrs.exe"
	program_icon_state = "single_contract"
	extended_desc = "Virus that causes an EMP type event."
	size = 0
	available_on_ntnet = FALSE
	tgui_id = "virus_coil"
	program_icon = "charging-station"
	var/triggered = FALSE

/datum/computer_file/program/coil_virus/on_start(mob/living/user)
	. = ..()
	get_user()
	if(player)
		sound_channel = rand(200, 800)
		player.playsound_local(computer, 'sound/soundtrack/PinkSuzuki_HappyPlace.ogg', 50, channel = sound_channel)
		sound = TRUE

/datum/computer_file/program/coil_virus/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return

	switch(action)
		if("Detonate")
			triggered = TRUE
			kill_program()
			return TRUE

/datum/computer_file/program/coil_virus/kill_program(forced)
	. = ..()
	if(player)
		player.stop_sound_channel(sound_channel)
		sound = FALSE
		player = null
	if(triggered)
		empulse(get_turf(computer), 2, 2, 1)
		new /obj/effect/particle_effect/sparks/blue(get_turf(computer))
		playsound(computer, "sparks", 50)
		playsound(computer, 'sound/machines/defib_zap.ogg', 25, TRUE)
	else
		weaker_emp()
		return
	var/obj/item/computer_hardware/network_card/card = computer.all_components[MC_NET]
	var/obj/item/computer_hardware/hard_drive/drive = computer.all_components[MC_HDD]
	if(card)
		if(drive.virus_lethality)
			computer.add_log("SYSnotice :: Executable anomaly detected... Manual execution of *UNKNOWN* at: [card.identification_string] (NID ?%&!).", log_id = FALSE)
		else
			computer.add_log("SYSnotice :: Executable anomaly detected... Manual execution of *UNKNOWN* at: [card.get_network_tag()].", log_id = FALSE)
	var/obj/item/computer_hardware/hard_drive/role/virus/disk = computer.all_components[MC_HDD_JOB]
	disk.component_qdel()

/datum/computer_file/program/coil_virus/on_ui_close(mob/user, datum/tgui/tgui)
	. = ..()
	if(player)
		player.stop_sound_channel(sound_channel)
		sound = FALSE
		player = null
	kill_program()

/datum/computer_file/program/coil_virus/proc/weaker_emp()
	empulse(get_turf(computer), 1, 1, 1)
	new /obj/effect/particle_effect/sparks/blue(get_turf(computer))
	playsound(computer, "sparks", 50)
	playsound(computer, 'sound/machines/defib_zap.ogg', 25, TRUE)
	var/obj/item/computer_hardware/network_card/card = computer.all_components[MC_NET]
	var/obj/item/computer_hardware/hard_drive/role/virus/disk = computer.all_components[MC_HDD_JOB]
	if(card)
		computer.add_log("ALERT: Execution of unsafe class [filename] file detected in [card.get_network_tag()]!", log_id = FALSE)
	disk.component_qdel()

/datum/computer_file/program/breacher_virus
	filename = "BrexerTrojn.exe"
	filedesc = "BrexerTrojn.exe"
	program_icon_state = "single_contract"
	extended_desc = "Detonates the Computer's battery after an arming period."
	size = 0
	available_on_ntnet = FALSE
	tgui_id = "virus_breacher"
	program_icon = "user-secret"
	var/triggered = FALSE

/datum/computer_file/program/breacher_virus/on_start(mob/living/user)
	. = ..()
	get_user()
	if(player)
		sound_channel = rand(200, 800)
		player.playsound_local(computer, 'sound/soundtrack/PinkSuzuki_DaxtersPlaceOutro.ogg', 50, channel = sound_channel)
		sound = TRUE
	var/obj/item/computer_hardware/network_card/card = computer.all_components[MC_NET]
	if(card)
		computer.add_log("ALERT: Execution of unsafe class [filename] file detected in [card.get_network_tag()]!", log_id = FALSE)

/datum/computer_file/program/breacher_virus/kill_program(mob/user, forced)
	. = ..()
	if(player)
		player.stop_sound_channel(sound_channel)
		sound = FALSE
		player = null
	if(!triggered)
		dud()
		return
	var/obj/item/computer_hardware/battery/controler = computer.all_components[MC_CELL]
	var/obj/item/computer_hardware/hard_drive/role/virus/disk = computer.all_components[MC_HDD_JOB]
	playsound(computer, 'sound/machines/pda_button1.ogg', 50, TRUE)
	if(controler)
		new /obj/effect/particle_effect/sparks/red(get_turf(computer))
		playsound(computer, "sparks", 50)
		computer.battery_explosion()	// Instant explosion
	if(disk)
		disk.component_qdel()

/datum/computer_file/program/breacher_virus/on_ui_close(mob/user, datum/tgui/tgui)
	. = ..()
	if(player)
		player.stop_sound_channel(sound_channel)
		sound = FALSE
		player = null
	if(!triggered)
		dud()
		return

/datum/computer_file/program/breacher_virus/proc/dud()
	var/obj/item/computer_hardware/network_card/card = computer.all_components[MC_NET]
	var/obj/item/computer_hardware/hard_drive/drive = computer.all_components[MC_HDD]
	var/obj/item/computer_hardware/hard_drive/role/virus/disk = computer.all_components[MC_HDD_JOB]
	computer.update_appearance()
	if(card)
		card.component_qdel()
	if(drive)
		drive.component_qdel()
	new /obj/effect/particle_effect/sparks/red(get_turf(computer))
	playsound(computer, "sparks", 50)
	playsound(computer, 'sound/machines/pda_button1.ogg', 50, TRUE)
	disk.component_qdel()

/datum/computer_file/program/breacher_virus/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return

	switch(action)
		if("Detonate")
			triggered = TRUE
			kill_program()
			return TRUE

/datum/computer_file/program/sledge_virus
	filename = "Sleghamr.exe"
	filedesc = "Sleghamr.exe"
	program_icon_state = "single_contract"
	extended_desc = "Destroys any traces of NTOS Virus Buster from your system."
	size = 0
	available_on_ntnet = FALSE
	tgui_id = "virus_sledge"
	program_icon = "book-skull"
	var/triggered = FALSE

/datum/computer_file/program/sledge_virus/on_start(mob/living/user)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/drive = computer.all_components[MC_HDD]
	if(!drive.virus_defense)
		computer.balloon_alert(user, "<font color='#ff0000'>ERROR:</font> No traces of NTOS Virus Buster found.")
		to_chat(user, "<span class='cfc_red'>ERROR:</span> No traces of NTOS Virus Buster found.")
		triggered = TRUE
		kill_program()
		return
	get_user()
	if(player)
		sound_channel = rand(200, 800)
		player.playsound_local(computer, 'sound/soundtrack/PinkSuzuki_HellraiserAnthem.ogg', 50, channel = sound_channel)
		sound = TRUE

/datum/computer_file/program/sledge_virus/on_ui_close(mob/user, datum/tgui/tgui)
	. = ..()
	if(player)
		player.stop_sound_channel(sound_channel)
		sound = FALSE
		player = null
	triggered = TRUE
	kill_program()

/datum/computer_file/program/sledge_virus/kill_program(mob/user, forced)
	. = ..()
	if(player)
		player.stop_sound_channel(sound_channel)
		sound = FALSE
		player = null
	if(triggered)
		var/obj/item/computer_hardware/network_card/card = computer.all_components[MC_NET]
		if(card)
			computer.add_log("ALERT: Execution of unsafe class [filename] file detected in [card.get_network_tag()]!", log_id = FALSE)
		return
	var/obj/item/computer_hardware/hard_drive/drive = computer.all_components[MC_HDD]
	drive.virus_defense = ANTIVIRUS_NONE
	new /obj/effect/particle_effect/sparks/red(get_turf(computer))
	playsound(computer, "sparks", 50)
	playsound(computer, 'sound/machines/pda_button1.ogg', 50, TRUE)
	var/obj/item/computer_hardware/network_card/card = computer.all_components[MC_NET]
	if(card)
		if(drive.virus_lethality)
			computer.add_log("SYSnotice :: Executable anomaly detected... Manual execution of *UNKNOWN* at: [card.identification_string] (NID ?%&!).", log_id = FALSE)
		else
			computer.add_log("SYSnotice :: Executable anomaly detected... Manual execution of *UNKNOWN* at: [card.get_network_tag()].", log_id = FALSE)
	var/obj/item/computer_hardware/hard_drive/role/virus/disk = computer.all_components[MC_HDD_JOB]
	disk.component_qdel()

/datum/computer_file/program/sledge_virus/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return

	switch(action)
		if("Detonate")
			triggered = FALSE
			kill_program()
			return TRUE
