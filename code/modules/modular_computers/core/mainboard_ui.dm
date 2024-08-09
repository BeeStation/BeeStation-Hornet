/obj/item/mainboard/interact(mob/user)
	if(isnull(physical_holder))
		return FALSE

	if(enabled)
		return ui_interact(user)
	else
		return turn_on(user)

// Operates TGUI

/obj/item/mainboard/ui_state(mob/user)
	return GLOB.default_state

/obj/item/mainboard/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/headers),
		get_asset_datum(/datum/asset/simple/arcade),
	)

/obj/item/mainboard/ui_interact(mob/user, datum/tgui/ui)
	if(!enabled || !user.is_literate() || !use_power())
		if(ui)
			ui.close()
		return FALSE

	// Robots don't really need to see the screen, their wireless connection works as long as computer is on.
	if(!enabled && !issilicon(user))
		if(ui)
			ui.close()
		return FALSE

	// We are still here, that means there is no program loaded. Load the BIOS/ROM/OS/whatever you want to call it.
	// This screen simply lists available programs and user may select them.
	var/obj/item/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
	if(!hard_drive || !hard_drive.stored_files || !hard_drive.stored_files.len)
		to_chat(user, "<span class='danger'>\The [src] beeps three times, it's screen displaying a \"DISK ERROR\" warning.</span>")
		return FALSE // No HDD, No HDD files list or no stored files. Something is very broken.

	if(honks_left > 0) // EXTRA annoying, huh!
		honks_left--
		playsound(src, 'sound/items/bikehorn.ogg', 30, TRUE)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		if(active_program)
			ui = new(user, src, active_program.tgui_id, active_program.filedesc)
			ui.set_autoupdate(TRUE)
		else
			ui = new(user, src, "NtosMain", physical_holder.name)
			ui.set_autoupdate(TRUE)
		ui.open()
		return TRUE

	var/old_open_ui = ui.interface
	if(active_program)
		ui.interface = active_program.tgui_id
		ui.title = active_program.filedesc
	else
		ui.interface = "NtosMain"
		ui.title = physical_holder.name

	//opened a new UI
	if(old_open_ui != ui.interface)
		update_static_data(user, ui) // forces a static UI update for the new UI
		ui.send_assets() // sends any new asset datums from the new UI
		if(active_program)
			active_program.on_ui_create(user, ui)
		return TRUE


/obj/item/mainboard/ui_close(mob/user, datum/tgui/tgui)
	if(active_program)
		active_program.on_ui_close(user, tgui)

/obj/item/mainboard/ui_assets(mob/user)
	var/list/data = list()
	data += get_asset_datum(/datum/asset/simple/headers)
	if(active_program)
		data += active_program.ui_assets(user)
	return data

/obj/item/mainboard/ui_static_data(mob/user)
	. = ..()
	var/list/data = list()
	if(active_program)
		data += active_program.ui_static_data(user)
		return data
	return data

/obj/item/mainboard/proc/get_ui_headers()
	. = list()

	.["PC_device_theme"] = device_theme
	.["PC_classic_color"] = classic_color
	.["PC_theme_locked"] = theme_locked

	var/obj/item/computer_hardware/battery/battery_module = all_components[MC_CELL]
	if(battery_module?.battery)
		switch(battery_module.battery.percent())
			if(80 to 200) // 100 should be maximal but just in case..
				.["PC_batteryicon"] = "batt_100.gif"
			if(60 to 80)
				.["PC_batteryicon"] = "batt_80.gif"
			if(40 to 60)
				.["PC_batteryicon"] = "batt_60.gif"
			if(20 to 40)
				.["PC_batteryicon"] = "batt_40.gif"
			if(5 to 20)
				.["PC_batteryicon"] = "batt_20.gif"
			else
				.["PC_batteryicon"] = "batt_5.gif"
		.["PC_batterypercent"] = "[round(battery_module.battery.percent())]%"
		.["PC_showbatteryicon"] = 1
	else
		.["PC_batteryicon"] = "batt_5.gif"
		.["PC_batterypercent"] = "N/C"
		.["PC_showbatteryicon"] = battery_module ? 1 : 0

	var/obj/item/computer_hardware/recharger/recharger = all_components[MC_CHARGE]
	if(recharger && recharger.enabled && recharger.check_functionality() && recharger.use_power(0))
		.["PC_apclinkicon"] = "charging.gif"

	switch(get_ntnet_status())
		if(0)
			.["PC_ntneticon"] = "sig_none.gif"
		if(1)
			.["PC_ntneticon"] = "sig_low.gif"
		if(2)
			.["PC_ntneticon"] = "sig_high.gif"
		if(3)
			.["PC_ntneticon"] = "sig_lan.gif"

	var/list/program_headers = list()
	for(var/datum/computer_file/program/P as anything in idle_threads)
		if(!P?.ui_header)
			continue
		program_headers.Add(list(list(
			"icon" = P.ui_header
		)))

	.["PC_programheaders"] = program_headers

	.["PC_stationtime"] = station_time_timestamp()
	.["PC_stationdate"] = "[time2text(world.realtime, "DDD, Month DD")], [GLOB.year_integer+YEAR_OFFSET]"
	.["PC_hasheader"] = 1
	.["PC_showexitprogram"] = active_program ? 1 : 0 // Hides "Exit Program" button on mainscreen



/obj/item/mainboard/ui_data(mob/user)
	var/list/data = get_ui_headers()
	if(active_program)
		data += active_program.ui_data(user)
		return data

	var/obj/item/computer_hardware/goober/pai/pai_slot = all_components[MC_PAI]
	if(istype(pai_slot))
		var/obj/item/paicard/stored_card = pai_slot.stored_card
		data["stored_pai"] = !istype(stored_card)
		data["stored_pai_name"] = stored_card?.pai?.name

	var/obj/item/computer_hardware/id_slot/cardholder = all_components[MC_ID_AUTH]

	data["cardholder"] = FALSE
	data["login"] = list()
	if(istype(cardholder))
		data["cardholder"] = TRUE
		data["auto_imprint"] = cardholder.auto_imprint

		var/stored_name = saved_identification()
		var/stored_title = saved_job()
		if(isnull(stored_name))
			stored_name = "Unknown"
		if(isnull(stored_title))
			stored_title = "Unknown"
		data["login"] = list(
			IDName = stored_name,
			IDJob = stored_title,
		)
		data["proposed_login"] = list(
			IDName = cardholder.current_identification,
			IDJob = cardholder.current_job,
		)

	var/obj/item/computer_hardware/hard_drive/role/ssd = all_components[MC_HDD_JOB]
	data["disk"] = null
	if(ssd)
		data["disk"] = ssd
		data["disk_name"] = ssd.name

		for(var/datum/computer_file/program/prog in ssd.stored_files)
			var/background_running = FALSE
			if(prog in idle_threads)
				background_running = TRUE

			data["disk_programs"] += list(list("name" = prog.filename, "desc" = prog.filedesc, "running" = background_running, "icon" = prog.program_icon, "alert" = prog.alert_pending))

	data["removable_media"] = list()
	if(all_components[MC_R_HDD])
		data["removable_media"] += "removable storage disk"
	var/obj/item/computer_hardware/goober/ai/intelliholder = all_components[MC_AI]
	if(intelliholder?.stored_card)
		data["removable_media"] += "intelliCard"
	var/obj/item/computer_hardware/id_slot/secondarycardholder = all_components[MC_ID_MODIFY]
	if(secondarycardholder?.stored_card)
		data["removable_media"] += "secondary RFID card"

	data["programs"] = list()
	var/obj/item/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
	for(var/datum/computer_file/program/P in hard_drive.stored_files)
		var/background_running = FALSE
		if(P in idle_threads)
			background_running = TRUE

		data["programs"] += list(list("name" = P.filename, "desc" = P.filedesc, "running" = background_running, "icon" = P.program_icon, "alert" = P.alert_pending))

	data["has_light"] = FALSE // has_light
	data["light_on"] = FALSE // light_on
	data["comp_light_color"] = "#FFFFFF" // comp_light_color

	return data

// Handles user's GUI input
/obj/item/mainboard/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(device_theme == THEME_THINKTRONIC)
		play_select_sound()
	var/obj/item/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
	switch(action)
		if("PC_exit")
			kill_program()
			return TRUE

		if("PC_shutdown")
			turn_off()
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
			var/obj/item/modular_computer/modpc_item = physical_holder
			if(!istype(modpc_item))
				return FALSE
			return modpc_item.toggle_flashlight()

		if("PC_light_color")
			var/obj/item/modular_computer/modpc_item = physical_holder
			if(!istype(modpc_item))
				return FALSE
			var/mob/user = usr
			var/new_color
			while(!new_color)
				new_color = tgui_color_picker(user, "Choose a new color for [src]'s flashlight.", "Light Color",light_color)
				if(!new_color)
					return
				if(is_color_dark_with_saturation(new_color, 50) ) //Colors too dark are rejected
					to_chat(user, "<span class='warning'>That color is too dark! Choose a lighter one.</span>")
					new_color = null
			return modpc_item.set_flashlight_color(new_color)

		if("PC_Eject_Disk")
			var/param = params["name"]
			var/mob/user = usr
			switch(param)
				if("removable storage disk")
					var/obj/item/computer_hardware/hard_drive/portable/portable_drive = all_components[MC_R_HDD]
					if(!portable_drive)
						return
					if(uninstall_component(portable_drive, usr, TRUE))
						play_disk_sound()
					return TRUE

				if("job disk")
					var/obj/item/computer_hardware/hard_drive/role/ssd = all_components[MC_HDD_JOB]
					if(!ssd)
						return
					if(uninstall_component(ssd, usr, TRUE))
						play_disk_sound()
					return TRUE

				if("intelliCard")
					var/obj/item/computer_hardware/goober/ai/intelliholder = all_components[MC_AI]
					if(!intelliholder)
						return
					if(intelliholder.try_eject(user))
						play_disk_sound()
					else
						to_chat(user, "<span class='warning'>There are no cards in \the [intelliholder].</span>")
					return TRUE

				if("ID")
					var/obj/item/computer_hardware/id_slot/cardholder = all_components[MC_ID_AUTH]
					if(!istype(cardholder))
						return FALSE
					if(cardholder.try_eject(user))
						play_disk_sound()
						return TRUE
					to_chat(user, "<span class='warning'>There are no cards in \the [cardholder].</span>")
					return TRUE

				if("secondary RFID card")
					var/obj/item/computer_hardware/id_slot/cardholder = all_components[MC_ID_MODIFY]
					if(!istype(cardholder))
						return FALSE
					if(cardholder.try_eject(user))
						play_disk_sound()
						return TRUE
					to_chat(user, "<span class='warning'>There are no cards in \the [cardholder].</span>")
					return FALSE

		if("PC_Imprint_ID")
			var/obj/item/computer_hardware/id_slot/cardholder = all_components[MC_ID_AUTH]
			if(!istype(cardholder) || can_save_id)
				return TRUE

			update_id_display(cardholder.current_identification, cardholder.current_job)

			play_processing_sound()

			addtimer(CALLBACK(src, PROC_REF(play_success_sound)), 1.3 SECONDS)
			return TRUE

		if("PC_Toggle_Auto_Imprint")
			var/obj/item/computer_hardware/id_slot/cardholder = all_components[MC_ID_AUTH]
			if(!istype(cardholder))
				return TRUE

			cardholder.auto_imprint = !cardholder.auto_imprint
			if(cardholder.auto_imprint)
				on_id_insert()

			return TRUE

		if("PC_Pai_Interact")
			var/obj/item/computer_hardware/goober/pai/pai_slot = all_components[MC_PAI]
			if(!istype(pai_slot))
				return

			var/obj/item/paicard/stored_pai_card = pai_slot.stored_card
			if(!istype(stored_pai_card))
				return

			if(params["option"] == "interact")
				stored_pai_card.attack_self(usr)
			else if(params["option"] == "eject")
				usr.put_in_hands(stored_pai_card)
				pai_slot.remove_pai()
				to_chat(usr, "<span class='notice'>You remove the pAI from [src].</span>")
				playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50)
			return TRUE

	if(active_program)
		return active_program.ui_act(action, params, ui, state)

/obj/item/mainboard/ui_host()
	if(physical_holder)
		return physical_holder
	return src
