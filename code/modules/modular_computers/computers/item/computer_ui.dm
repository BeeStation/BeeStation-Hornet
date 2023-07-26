/obj/item/modular_computer/interact(mob/user)
	if(enabled)
		ui_interact(user)
	else
		turn_on(user)

// Operates TGUI

/obj/item/modular_computer/ui_state(mob/user)
	return GLOB.default_state

/obj/item/modular_computer/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/headers),
		get_asset_datum(/datum/asset/simple/arcade),
	)

/obj/item/modular_computer/ui_interact(mob/user, datum/tgui/ui)
	if(!enabled || !user.is_literate() || !use_power())
		if(ui)
			ui.close()
		return

	// Robots don't really need to see the screen, their wireless connection works as long as computer is on.
	if(!screen_on && !issilicon(user))
		if(ui)
			ui.close()
		return FALSE

	// We are still here, that means there is no program loaded. Load the BIOS/ROM/OS/whatever you want to call it.
	// This screen simply lists available programs and user may select them.
	var/obj/item/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
	if(!hard_drive || !hard_drive.stored_files || !hard_drive.stored_files.len)
		to_chat(user, "<span class='danger'>\The [src] beeps three times, it's screen displaying a \"DISK ERROR\" warning.</span>")
		return FALSE // No HDD, No HDD files list or no stored files. Something is very broken.

	if(honk_amount > 0) // EXTRA annoying, huh!
		honk_amount--
		playsound(src, 'sound/items/bikehorn.ogg', 30, TRUE)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		if(active_program)
			ui = new(user, src, active_program.tgui_id, active_program.filedesc)
			ui.set_autoupdate(TRUE)
		else
			ui = new(user, src, "NtosMain")
			ui.set_autoupdate(TRUE)
		ui.open()
		return

	var/old_open_ui = ui.interface
	if(active_program)
		ui.interface = active_program.tgui_id
		ui.title = active_program.filedesc
	else
		ui.interface = "NtosMain"
	//opened a new UI
	if(old_open_ui != ui.interface)
		update_static_data(user, ui) // forces a static UI update for the new UI
		ui.send_assets() // sends any new asset datums from the new UI
		if(active_program)
			active_program.on_ui_create(user, ui)


/obj/item/modular_computer/ui_close(mob/user, datum/tgui/tgui)
	if(active_program)
		active_program.on_ui_close(user, tgui)

/obj/item/modular_computer/ui_assets(mob/user)
	var/list/data = list()
	data += get_asset_datum(/datum/asset/simple/headers)
	if(active_program)
		data += active_program.ui_assets(user)
	return data

/obj/item/modular_computer/ui_static_data(mob/user)
	. = ..()
	var/list/data = list()
	if(active_program)
		data += active_program.ui_static_data(user)
		return data
	return data

/obj/item/modular_computer/ui_data(mob/user)
	var/list/data = get_header_data()
	if(active_program)
		data += active_program.ui_data(user)
		return data
	data["login"] = list()

	data["disk"] = null

	data["stored_pai"] = istype(stored_pai_card)
	data["stored_pai_name"] = stored_pai_card?.pai?.name

	var/obj/item/computer_hardware/card_slot/cardholder = all_components[MC_CARD]
	var/obj/item/computer_hardware/hard_drive/role/ssd = all_components[MC_HDD_JOB]
	data["cardholder"] = FALSE

	if(cardholder)
		data["cardholder"] = TRUE
		data["auto_imprint"] = saved_auto_imprint

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
			var/background_running = FALSE
			if(prog in idle_threads)
				background_running = TRUE

			data["disk_programs"] += list(list("name" = prog.filename, "desc" = prog.filedesc, "running" = background_running, "icon" = prog.program_icon, "alert" = prog.alert_pending))

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
		var/background_running = FALSE
		if(P in idle_threads)
			background_running = TRUE

		data["programs"] += list(list("name" = P.filename, "desc" = P.filedesc, "running" = background_running, "icon" = P.program_icon, "alert" = P.alert_pending))

	data["has_light"] = has_light
	data["light_on"] = light_on
	data["comp_light_color"] = comp_light_color
	return data

// Handles user's GUI input
/obj/item/modular_computer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(device_theme == THEME_THINKTRONIC)
		send_select_sound()
	var/obj/item/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
	switch(action)
		if("PC_exit")
			kill_program()
			return TRUE
		if("PC_shutdown")
			shutdown_computer()
			return TRUE
		if("PC_minimize")
			if(!active_program || !all_components[MC_CPU])
				return

			idle_threads.Add(active_program)
			active_program.program_state = PROGRAM_STATE_BACKGROUND // Should close any existing UIs
			active_program = null
			if(ismob(usr))
				ui_interact(usr) // Re-open the UI on this computer. It should show the main screen now.
			update_icon()
			return TRUE
		if("PC_killprogram")
			var/prog = params["name"]
			var/datum/computer_file/program/killed_program  = null
			if(hard_drive)
				killed_program  = hard_drive.find_file_by_name(prog)

			if(!istype(killed_program) || killed_program.program_state == PROGRAM_STATE_KILLED)
				return
			if(killed_program in idle_threads)
				idle_threads.Remove(killed_program)
			killed_program.kill_program(forced = TRUE)
			to_chat(usr, "<span class='notice'>Program [killed_program.filename].[killed_program.filetype] with PID [rand(100,999)] has been killed.</span>")
			return TRUE
		if("PC_runprogram")
			var/is_disk = params["is_disk"]
			var/datum/computer_file/program/program
			var/obj/item/computer_hardware/hard_drive/role/ssd = all_components[MC_HDD_JOB]

			if(hard_drive && !is_disk)
				program = hard_drive.find_file_by_name(params["name"])
			if(ssd && is_disk)
				program = ssd.find_file_by_name(params["name"])

			if(!program || !istype(program)) // Program not found or it's not executable program.
				to_chat(usr, "<span class='danger'>\The [src]'s screen shows \"I/O ERROR - Unable to run program\" warning.</span>")
				return
			program.computer = src
			open_program(usr, program)

		if("PC_toggle_light")
			return toggle_flashlight()

		if("PC_light_color")
			var/mob/user = usr
			var/new_color
			while(!new_color)
				new_color = tgui_color_picker(user, "Choose a new color for [src]'s flashlight.", "Light Color",light_color)
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
					if(uninstall_component(portable_drive, usr, TRUE))
						playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50)
					return TRUE
				if("job disk")
					var/obj/item/computer_hardware/hard_drive/role/ssd = all_components[MC_HDD_JOB]
					if(!ssd)
						return
					if(uninstall_component(ssd, usr, TRUE))
						playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50)
					return TRUE
				if("intelliCard")
					var/obj/item/computer_hardware/ai_slot/intelliholder = all_components[MC_AI]
					if(!intelliholder)
						return
					if(intelliholder.try_eject(user))
						playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50)
					return TRUE
				if("ID")
					var/obj/item/computer_hardware/card_slot/cardholder = all_components[MC_CARD]
					if(!cardholder)
						return
					if(cardholder.try_eject(user))
						playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50)
					return TRUE
				if("secondary RFID card")
					var/obj/item/computer_hardware/card_slot/cardholder = all_components[MC_CARD2]
					if(!cardholder)
						return
					if(cardholder.try_eject(user))
						playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50)
					return TRUE
		if("PC_Imprint_ID")
			var/obj/item/computer_hardware/card_slot/cardholder = all_components[MC_CARD]
			if(!cardholder || !can_save_id)
				return TRUE

			saved_identification = cardholder.current_identification
			saved_job = cardholder.current_job

			update_id_display()

			playsound(src, 'sound/machines/terminal_processing.ogg', 15, TRUE)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), src, 'sound/machines/terminal_success.ogg', 15, TRUE), 1.3 SECONDS)
			return TRUE
		if("PC_Toggle_Auto_Imprint")
			saved_auto_imprint = !saved_auto_imprint
			if(saved_auto_imprint)
				on_id_insert()
			return TRUE
		if("PC_Pai_Interact")
			if(!can_store_pai || !istype(stored_pai_card))
				return
			if(params["option"] == "interact")
				stored_pai_card.attack_self(usr)
			else if(params["option"] == "eject")
				usr.put_in_hands(stored_pai_card)
				remove_pai()
				to_chat(usr, "<span class='notice'>You remove the pAI from [src].</span>")
				playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50)
			return TRUE
	if(active_program)
		return active_program.ui_act(action, params, ui, state)

/obj/item/modular_computer/ui_host()
	if(physical)
		return physical
	return src
