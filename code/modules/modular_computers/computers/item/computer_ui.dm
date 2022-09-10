/obj/item/modular_computer/attack_self(mob/user)
	. = ..()
	ui_interact(user)

// Operates TGUI

/obj/item/modular_computer/ui_state(mob/user)
	return GLOB.default_state

/obj/item/modular_computer/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/headers),
		get_asset_datum(/datum/asset/simple/arcade),
	)

/obj/item/modular_computer/ui_interact(mob/user, datum/tgui/ui)
	if(issilicon(user)) // silicons have some issues regarding real_name
		saved_identification = user.real_name
	if(!enabled)
		if(ui)
			ui.close()
		return 0
	if(!use_power())
		if(ui)
			ui.close()
		return 0

	// Robots don't really need to see the screen, their wireless connection works as long as computer is on.
	if(!screen_on && !issilicon(user))
		if(ui)
			ui.close()
		return 0

	// If we have an active program switch to it now.
	if(active_program)
		if(ui) // This is the main laptop screen. Since we are switching to program's UI close it for now.
			ui.close()
		active_program.ui_interact(user)
		return

	// We are still here, that means there is no program loaded. Load the BIOS/ROM/OS/whatever you want to call it.
	// This screen simply lists available programs and user may select them.
	var/obj/item/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
	if(!hard_drive || !hard_drive.stored_files || !hard_drive.stored_files.len)
		to_chat(user, "<span class='danger'>\The [src] beeps three times, it's screen displaying a \"DISK ERROR\" warning.</span>")
		return // No HDD, No HDD files list or no stored files. Something is very broken.

	if(honk_amount > 0) // EXTRA annoying, huh!
		honk_amount--
		playsound(src, 'sound/items/bikehorn.ogg', 30, TRUE)

	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "NtosMain")
		ui.set_autoupdate(TRUE)
		if(ui.open())
			ui.send_asset(get_asset_datum(/datum/asset/simple/headers))

/obj/item/modular_computer/ui_data(mob/user)
	var/list/data = get_header_data()
	data["device_theme"] = device_theme
	data["login"] = list()

	data["disk"] = null

	var/obj/item/computer_hardware/card_slot/cardholder = all_components[MC_CARD]
	var/obj/item/computer_hardware/hard_drive/role/ssd = all_components[MC_HDD_JOB]
	data["cardholder"] = FALSE

	if(cardholder)
		data["cardholder"] = TRUE

		var/stored_name = saved_identification
		var/stored_title = saved_job
		if(!stored_name)
			stored_name = "Unknown"
		if(!stored_title)
			stored_title = "Unknown"
		data["login"] = list(
			IDName = saved_identification,
			IDJob = saved_job,
		)
		data["proposed_login"] = list(
			IDName = cardholder.current_identification,
			IDJob = cardholder.current_job,
		)

	if(ssd)
		data["disk"] = ssd
		data["disk_name"] = ssd.name

		for(var/datum/computer_file/program/prog in ssd.stored_files)
			var/running = FALSE
			if(prog in idle_threads)
				running = TRUE

			data["disk_programs"] += list(list("name" = prog.filename, "desc" = prog.filedesc, "running" = running, "icon" = prog.program_icon, "alert" = prog.alert_pending))

	data["removable_media"] = list()
	if(all_components[MC_SDD])
		data["removable_media"] += "removable storage disk"
	var/obj/item/computer_hardware/ai_slot/intelliholder = all_components[MC_AI]
	if(intelliholder?.stored_card)
		data["removable_media"] += "intelliCard"
	var/obj/item/computer_hardware/card_slot/secondarycardholder = all_components[MC_CARD2]
	if(secondarycardholder?.stored_card)
		data["removable_media"] += "secondary RFID card"

	data["programs"] = list()
	var/obj/item/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
	for(var/datum/computer_file/program/P in hard_drive.stored_files)
		var/running = 0
		if(P in idle_threads)
			running = 1

		data["programs"] += list(list("name" = P.filename, "desc" = P.filedesc, "running" = running, "icon" = P.program_icon, "alert" = P.alert_pending))

	data["has_light"] = has_light
	data["light_on"] = light_on
	data["comp_light_color"] = comp_light_color
	return data


// Handles user's GUI input
/obj/item/modular_computer/ui_act(action, params)
	if(..())
		return
	var/obj/item/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
	switch(action)
		if("PC_exit")
			kill_program()
			return TRUE
		if("PC_shutdown")
			shutdown_computer()
			return TRUE
		if("PC_minimize")
			var/mob/user = usr
			if(!active_program || !all_components[MC_CPU])
				return

			idle_threads.Add(active_program)
			active_program.program_state = PROGRAM_STATE_BACKGROUND // Should close any existing UIs

			active_program = null
			update_icon()
			if(user && istype(user))
				ui_interact(user) // Re-open the UI on this computer. It should show the main screen now.

		if("PC_killprogram")
			var/prog = params["name"]
			var/datum/computer_file/program/P = null
			var/mob/user = usr
			if(hard_drive)
				P = hard_drive.find_file_by_name(prog)

			if(!istype(P) || P.program_state == PROGRAM_STATE_KILLED)
				return

			P.kill_program(forced = TRUE)
			to_chat(user, "<span class='notice'>Program [P.filename].[P.filetype] with PID [rand(100,999)] has been killed.</span>")
			return TRUE

		if("PC_runprogram")
			var/prog = params["name"]
			var/is_disk = params["is_disk"]
			var/datum/computer_file/program/P = null
			var/obj/item/computer_hardware/hard_drive/role/ssd = all_components[MC_HDD_JOB]
			var/mob/user = usr

			if(hard_drive && !is_disk)
				P = hard_drive.find_file_by_name(prog)
			if(ssd && is_disk)
				P = ssd.find_file_by_name(prog)

			if(!P || !istype(P)) // Program not found or it's not executable program.
				to_chat(user, "<span class='danger'>\The [src]'s screen shows \"I/O ERROR - Unable to run program\" warning.</span>")
				return

			P.computer = src

			if(!P.is_supported_by_hardware(hardware_flag, 1, user))
				return

			// The program is already running. Resume it.
			if(P in idle_threads)
				P.program_state = PROGRAM_STATE_ACTIVE
				active_program = P
				P.alert_pending = FALSE
				idle_threads.Remove(P)
				update_icon()
				return

			var/obj/item/computer_hardware/processor_unit/PU = all_components[MC_CPU]

			if(idle_threads.len > PU.max_idle_programs)
				to_chat(user, "<span class='danger'>\The [src] displays a \"Maximal CPU load reached. Unable to run another program.\" error.</span>")
				return

			if(P.requires_ntnet && !get_ntnet_status(P.requires_ntnet_feature)) // The program requires NTNet connection, but we are not connected to NTNet.
				to_chat(user, "<span class='danger'>\The [src]'s screen shows \"Unable to connect to NTNet. Please retry. If problem persists contact your system administrator.\" warning.</span>")
				return
			if(P.run_program(user))
				active_program = P
				P.alert_pending = FALSE
				update_icon()
			return TRUE

		if("PC_toggle_light")
			return toggle_flashlight()

		if("PC_light_color")
			var/mob/user = usr
			var/new_color
			while(!new_color)
				new_color = input(user, "Choose a new color for [src]'s flashlight.", "Light Color",light_color) as color|null
				if(!new_color)
					return
				if(color_hex2num(new_color) < 200) //Colors too dark are rejected
					to_chat(user, "<span class='warning'>That color is too dark! Choose a lighter one.</span>")
					new_color = null
			return set_flashlight_color(new_color)

		if("PC_Eject_Disk")
			var/param = params["name"]
			var/mob/user = usr
			switch(param)
				if("removable storage disk")
					var/obj/item/computer_hardware/hard_drive/portable/portable_drive = all_components[MC_SDD]
					if(!portable_drive)
						return
					if(uninstall_component(portable_drive, usr))
						user.put_in_hands(portable_drive)
						playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50)
				if("job disk")
					var/obj/item/computer_hardware/hard_drive/role/ssd = all_components[MC_HDD_JOB]
					if(!ssd)
						return
					if(uninstall_component(ssd, usr))
						user.put_in_hands(ssd)
						playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50)
				if("intelliCard")
					var/obj/item/computer_hardware/ai_slot/intelliholder = all_components[MC_AI]
					if(!intelliholder)
						return
					if(intelliholder.try_eject(user))
						playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50)
				if("ID")
					var/obj/item/computer_hardware/card_slot/cardholder = all_components[MC_CARD]
					if(!cardholder)
						return
					if(cardholder.try_eject(user))
						playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50)
				if("secondary RFID card")
					var/obj/item/computer_hardware/card_slot/cardholder = all_components[MC_CARD2]
					if(!cardholder)
						return
					if(cardholder.try_eject(user))
						playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50)
		if("PC_Imprint_ID")
			var/obj/item/computer_hardware/card_slot/cardholder = all_components[MC_CARD]
			var/obj/item/computer_hardware/identifier/id_hardware = all_components[MC_IDENTIFY]
			if(!cardholder)
				return

			saved_identification = cardholder.current_identification
			saved_job = cardholder.current_job

			if(id_hardware)
				id_hardware.UpdateDisplay()

			playsound(src, 'sound/machines/terminal_processing.ogg', 15, TRUE)
		else
			return

/obj/item/modular_computer/ui_host()
	if(physical)
		return physical
	return src
