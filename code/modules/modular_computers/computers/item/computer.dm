GLOBAL_LIST_EMPTY(TabletMessengers) // a list of all active messengers, similar to GLOB.PDAs (used primarily with ntmessenger.dm)

// This is the base type that does all the hardware stuff.
// Other types expand it - tablets use a direct subtypes, and
// consoles and laptops use "procssor" item that is held inside machinery piece
/obj/item/modular_computer
	name = "modular microcomputer"
	desc = "A small portable microcomputer."
	icon = 'icons/obj/computer.dmi'
	icon_state = "laptop"
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 3
	light_power = 0.6
	light_color = "#FFFFFF"
	light_on = FALSE

	// Whether the computer is turned on.
	var/enabled = 0
	// Whether the computer is active/opened/it's screen is on.
	var/screen_on = 1
	/// If it's bypassing the set icon state
	var/bypass_state = FALSE
	/// Whether or not the computer can be upgraded
	var/upgradable = TRUE
	/// Whether or not the computer can be deconstructed
	var/deconstructable = TRUE
	/// Sets the theme for the main menu, hardware config, and file browser apps.
	var/device_theme = THEME_NTOS
	/// Whether this device is allowed to change themes or not.
	var/theme_locked = FALSE
	/// If the theme should not be initialized from theme prefs (for custom job themes)
	var/ignore_theme_pref = FALSE
	/// List of themes for this device to allow.
	var/list/allowed_themes
	/// Color used for the Thinktronic Classic theme.
	var/classic_color = COLOR_OLIVE
	var/datum/computer_file/program/active_program = null	// A currently active program running on the computer.
	var/hardware_flag = 0									// A flag that describes this device type
	var/last_power_usage = 0
	var/last_battery_percent = 0							// Used for deciding if battery percentage has chandged
	var/last_world_time = "00:00"
	var/list/last_header_icons

	var/base_active_power_usage = 50						// Power usage when the computer is open (screen is active) and can be interacted with. Remember hardware can use power too.
	var/base_idle_power_usage = 5							// Power usage when the computer is idle and screen is off (currently only applies to laptops)

	// Modular computers can run on various devices. Each DEVICE (Laptop, Console, Tablet,..)
	// must have it's own DMI file. Icon states must be called exactly the same in all files, but may look differently
	// If you create a program which is limited to Laptops and Consoles you don't have to add it's icon_state overlay for Tablets too, for example.

	var/icon_state_unpowered = null							// Icon state when the computer is turned off.
	var/icon_state_powered = null							// Icon state when the computer is turned on.
	var/icon_state_menu = "menu"							// Icon state overlay when the computer is turned on, but no program is loaded that would override the screen.
	var/max_hardware_size = 0								// Maximal hardware w_class. Tablets/PDAs have 1, laptops 2, consoles 4.
	var/steel_sheet_cost = 5								// Amount of steel sheets refunded when disassembling an empty frame of this computer.

	integrity_failure = 0.5
	max_integrity = 100
	armor_type = /datum/armor/item_modular_computer

	/// List of "connection ports" in this computer and the components with which they are plugged
	var/list/all_components = list()
	/// Lazy List of extra hardware slots that can be used modularly.
	var/list/expansion_bays
	/// Number of total expansion bays this computer has available.
	var/max_bays = 0

	/// If we can imprint IDs on this device
	var/can_save_id = FALSE
	/// The currently imprinted ID.
	var/saved_identification = null
	/// The currently imprinted job.
	var/saved_job = null
	/// If the saved info should auto-update
	var/saved_auto_imprint = FALSE
	/// The amount of honks. honk honk honk honk honk honkh onk honkhnoohnk
	var/honk_amount = 0
	/// Idle programs on background. They still receive process calls but can't be interacted with.
	var/list/idle_threads
	/// Object that represents our computer. It's used for Adjacent() and UI visibility checks.
	var/obj/physical = null
	/// If the computer has a flashlight/LED light/what-have-you installed
	var/has_light = FALSE
	/// How far the computer's light can reach, is not editable by players.
	var/comp_light_luminosity = 3
	/// The built-in light's color, editable by players.
	var/comp_light_color = "#FFFFFF"
	/// Whether or not the tablet is invisible in messenger and other apps
	var/messenger_invisible = FALSE
	/// The saved image used for messaging purposes
	var/datum/picture/saved_image
	/// The ringtone that will be set on initialize
	var/init_ringtone = "beep"
	/// If the device starts with its ringer on
	var/init_ringer_on = TRUE
	/// Stored pAI card
	var/obj/item/paicard/stored_pai_card
	/// If the device is capable of storing a pAI
	var/can_store_pai = FALSE


/datum/armor/item_modular_computer
	bullet = 20
	laser = 20
	energy = 100
	rad = 100

/obj/item/modular_computer/Initialize(mapload)
	allowed_themes = GLOB.ntos_device_themes_default
	. = ..()
	START_PROCESSING(SSobj, src)
	if(!physical)
		physical = src
	set_light_color(comp_light_color)
	set_light_range(comp_light_luminosity)
	idle_threads = list()
	update_id_display()
	if(has_light)
		add_item_action(/datum/action/item_action/toggle_computer_light)
	update_icon()
	add_messenger()

/obj/item/modular_computer/proc/update_id_display()
	var/obj/item/computer_hardware/identifier/id = all_components[MC_IDENTIFY]
	if(id)
		id.UpdateDisplay()

/obj/item/modular_computer/proc/on_id_insert()
	ui_update()
	var/obj/item/computer_hardware/card_slot/cardholder = all_components[MC_CARD]
	// We shouldn't auto-imprint if ID modification is open.
	if(!can_save_id || !saved_auto_imprint || !cardholder || istype(active_program, /datum/computer_file/program/card_mod))
		return
	if(cardholder.current_identification == saved_identification && cardholder.current_job == saved_job)
		return
	if(!cardholder.current_identification || !cardholder.current_job)
		return
	saved_identification = cardholder.current_identification
	saved_job = cardholder.current_job
	update_id_display()
	playsound(src, 'sound/machines/terminal_processing.ogg', 15, TRUE)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), src, 'sound/machines/terminal_success.ogg', 15, TRUE), 1.3 SECONDS)

/obj/item/modular_computer/Destroy()
	kill_program(forced = TRUE)
	STOP_PROCESSING(SSobj, src)
	for(var/port in all_components)
		var/obj/item/computer_hardware/component = all_components[port]
		qdel(component)
	all_components?.Cut()
	if(istype(stored_pai_card))
		qdel(stored_pai_card)
		remove_pai()
	physical = null
	remove_messenger()
	return ..()

/obj/item/modular_computer/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, /datum/action/item_action/toggle_computer_light))
		toggle_flashlight()
		return

	return ..()

/// From [/datum/newscaster/feed_network/proc/save_photo]
/obj/item/modular_computer/proc/save_photo(icon/photo)
	var/photo_file = copytext_char(md5("/icon[photo]"), 1, 6)
	if(!fexists("[GLOB.log_directory]/photos/[photo_file].png"))
		//Clean up repeated frames
		var/icon/clean = new /icon()
		clean.Insert(photo, "", SOUTH, 1, 0)
		fcopy(clean, "[GLOB.log_directory]/photos/[photo_file].png")
	return photo_file

/obj/item/modular_computer/pre_attack_secondary(atom/A, mob/living/user, params)
	if(active_program?.tap(A, user, params))
		user.do_attack_animation(A) //Emulate this animation since we kill the attack in three lines
		playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), TRUE, -1) //Likewise for the tap sound
		addtimer(CALLBACK(src, PROC_REF(play_ping)), 0.5 SECONDS, TIMER_UNIQUE) //Slightly delayed ping to indicate success
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/**
 * Plays a ping sound.
 *
 * Timers runtime if you try to make them call playsound. Yep.
 */
/obj/item/modular_computer/proc/play_ping()
	playsound(loc, 'sound/machines/ping.ogg', get_clamped_volume(), FALSE, -1)

/obj/item/modular_computer/AltClick(mob/user)
	if(issilicon(user) || !user.canUseTopic(src, BE_CLOSE))
		return FALSE
	var/obj/item/computer_hardware/card_slot/card_slot2 = all_components[MC_CARD2]
	var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	if(!card_slot2?.try_eject(user))
		return card_slot?.try_eject(user)
	return TRUE

// Gets IDs/access levels from card slot. Would be useful when/if PDAs would become modular PCs. (They are now!! you are welcome - itsmeow)
/obj/item/modular_computer/GetAccess()
	var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	if(card_slot)
		return card_slot.GetAccess()
	return ..()

/obj/item/modular_computer/GetID()
	var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	if(card_slot)
		return card_slot.GetID()
	return ..()

/obj/item/modular_computer/RemoveID()
	var/obj/item/computer_hardware/card_slot/card_slot2 = all_components[MC_CARD2]
	var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	var/removed_id = (card_slot2?.try_eject() || card_slot?.try_eject())
	if(removed_id)
		if(ishuman(loc))
			var/mob/living/carbon/human/human_wearer = loc
			if(human_wearer.wear_id == src)
				human_wearer.sec_hud_set_ID()
		return removed_id
	return ..()

/obj/item/modular_computer/InsertID(obj/item/inserting_item)
	var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	var/obj/item/computer_hardware/card_slot/card_slot2 = all_components[MC_CARD2]

	if(!(card_slot || card_slot2))
		return FALSE

	var/obj/item/card/inserting_id = inserting_item.GetID()
	if(!inserting_id)
		return FALSE

	if((card_slot?.try_insert(inserting_id)) || (card_slot2?.try_insert(inserting_id)))
		if(ishuman(loc))
			var/mob/living/carbon/human/human_wearer = loc
			if(human_wearer.wear_id == src)
				human_wearer.sec_hud_set_ID()
		return TRUE
	return FALSE

/obj/item/modular_computer/MouseDrop(obj/over_object, src_location, over_location)
	var/mob/M = usr
	if((!istype(over_object, /atom/movable/screen)) && usr.canUseTopic(src, BE_CLOSE))
		return attack_self(M)
	return ..()

/obj/item/modular_computer/attack_silicon(mob/user)
	return attack_self(user)

/obj/item/modular_computer/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(.)
		return
	if(enabled)
		ui_interact(user)
	else if(IsAdminGhost(user))
		var/response = alert(user, "This computer is turned off. Would you like to turn it on?", "Admin Override", "Yes", "No")
		if(response == "Yes")
			turn_on(user)

/obj/item/modular_computer/should_emag(mob/user)
	if(!enabled)
		to_chat(user, span_warning("You'd need to turn the [src] on first."))
		return FALSE
	return TRUE

/obj/item/modular_computer/on_emag(mob/user)
	..()
	var/newemag = FALSE
	var/obj/item/computer_hardware/hard_drive/drive = all_components[MC_HDD]
	for(var/datum/computer_file/program/app in drive.stored_files)
		if(!istype(app))
			continue
		if(app.run_emag())
			newemag = TRUE
	if(newemag)
		to_chat(user, span_notice("You swipe \the [src]. A console window momentarily fills the screen, with white text rapidly scrolling past."))
		kill_program(forced = TRUE, update = FALSE)

		var/datum/computer_file/program/emag_console/emag_console = new(src)
		emag_console.computer = src
		emag_console.program_state = PROGRAM_STATE_ACTIVE
		active_program = emag_console
		ui_interact(user)
		update_icon()
		return TRUE
	to_chat(user, span_notice("You swipe \the [src]. A console window fills the screen, but it quickly closes itself after only a few lines are written to it."))
	return FALSE

/obj/item/modular_computer/examine(mob/user)
	. = ..()
	if(atom_integrity <= integrity_failure * max_integrity)
		. += span_danger("It is heavily damaged!")
	else if(atom_integrity < max_integrity)
		. += span_warning("It is damaged.")

	. += get_modular_computer_parts_examine(user)

/obj/item/modular_computer/update_icon()
	cut_overlays()
	if(!bypass_state)
		icon_state = enabled ? icon_state_powered : icon_state_unpowered

	var/init_icon = initial(icon)
	if(!init_icon)
		return

	if(enabled)
		add_overlay(active_program ? mutable_appearance(init_icon, active_program.program_icon_state) : mutable_appearance(init_icon, icon_state_menu))

	if(can_store_pai && stored_pai_card)
		add_overlay(stored_pai_card.pai ? mutable_appearance(init_icon, "pai-overlay") : mutable_appearance(init_icon, "pai-off-overlay"))

	if(atom_integrity <= integrity_failure * max_integrity)
		add_overlay(mutable_appearance(init_icon, "bsod"))
		add_overlay(mutable_appearance(init_icon, "broken"))

/obj/item/modular_computer/proc/turn_on(mob/user, open_ui = TRUE)
	if(enabled)
		if(open_ui)
			ui_interact(user)
		return TRUE
	var/issynth = issilicon(user) // Robots and AIs get different activation messages.
	if(atom_integrity <= integrity_failure * max_integrity)
		if(issynth)
			to_chat(user, span_warning("You send an activation signal to \the [src], but it responds with an error code. It must be damaged."))
		else
			to_chat(user, span_warning("You press the power button, but the computer fails to boot up, displaying variety of errors before shutting down again."))
		return FALSE

	// If we have a recharger, enable it automatically. Lets computer without a battery work.
	var/obj/item/computer_hardware/recharger/recharger = all_components[MC_CHARGE]
	if(recharger)
		recharger.enabled = 1

	if(all_components[MC_CPU] && use_power()) // use_power() checks if the PC is powered
		if(issynth)
			to_chat(user, span_notice("You send an activation signal to \the [src], turning it on."))
		else
			to_chat(user, span_notice("You press the power button and start up \the [src]."))
		enabled = 1
		update_icon()
		if(open_ui)
			ui_interact(user)
		return TRUE
	else // Unpowered
		if(issynth)
			to_chat(user, span_warning("You send an activation signal to \the [src] but it does not respond."))
		else
			to_chat(user, span_warning("You press the power button but \the [src] does not respond."))
	return FALSE

// Process currently calls handle_power(), may be expanded in future if more things are added.
/obj/item/modular_computer/process(delta_time)
	if(!enabled) // The computer is turned off
		last_power_usage = 0
		return 0

	if(atom_integrity <= integrity_failure * max_integrity)
		shutdown_computer()
		return 0

	if(active_program && active_program.requires_ntnet && !get_ntnet_status(active_program.requires_ntnet_feature))
		active_program.event_networkfailure(0) // Active program requires NTNet to run but we've just lost connection. Crash.

	for(var/I in idle_threads)
		var/datum/computer_file/program/P = I
		if(P.requires_ntnet && !get_ntnet_status(P.requires_ntnet_feature))
			P.event_networkfailure(1)

	if(active_program)
		if(active_program.program_state != PROGRAM_STATE_KILLED)
			active_program.process_tick(delta_time)
			active_program.ntnet_status = get_ntnet_status()
		else
			active_program = null

	for(var/I in idle_threads)
		var/datum/computer_file/program/P = I
		if(P.program_state != PROGRAM_STATE_KILLED)
			P.process_tick(delta_time)
			P.ntnet_status = get_ntnet_status()
		else
			idle_threads.Remove(P)

	handle_power(delta_time) // Handles all computer power interaction
	//check_update_ui_need()

/**
  * Displays notification text alongside a soundbeep when requested to by a program.
  *
  * After checking that the requesting program is allowed to send an alert, creates
  * a visible message of the requested text alongside a soundbeep. This proc adds
  * text to indicate that the message is coming from this device and the program
  * on it, so the supplied text should be the exact message and ending punctuation.
  *
  * Arguments:
  * The program calling this proc.
  * The message that the program wishes to display.
 */

/obj/item/modular_computer/proc/alert_call(datum/computer_file/program/alerting_program, alerttext, sound = 'sound/machines/twobeep_high.ogg')
	if(!alerting_program || !alerting_program.alert_able || alerting_program.alert_silenced || !alerttext) //Yeah, we're checking alert_able. No, you don't get to make alerts that the user can't silence.
		return
	playsound(src, sound, 50, TRUE)
	visible_message(span_notice("The [src] displays a [alerting_program.filedesc] notification: [alerttext]"))
	var/mob/living/holder = loc
	if(istype(holder))
		to_chat(holder, "[icon2html(src)] [span_notice("The [src] displays a [alerting_program.filedesc] notification: [alerttext]")]")

/obj/item/modular_computer/proc/ring(ringtone) // bring bring
	if(HAS_TRAIT(SSstation, STATION_TRAIT_PDA_GLITCHED))
		playsound(src, pick('sound/machines/twobeep_voice1.ogg', 'sound/machines/twobeep_voice2.ogg'), 50, TRUE)
	else
		playsound(src, 'sound/machines/twobeep_high.ogg', 50, TRUE)
	visible_message("*[ringtone]*")

/obj/item/modular_computer/proc/send_sound()
	playsound(src, 'sound/machines/terminal_success.ogg', 15, TRUE)

/obj/item/modular_computer/proc/send_select_sound()
	playsound(src, 'sound/machines/terminal_select.ogg', 15, TRUE)

// Function used by NanoUI's to obtain data for header. All relevant entries begin with "PC_"
/obj/item/modular_computer/proc/get_header_data()
	var/list/data = list()

	data["PC_device_theme"] = device_theme
	data["PC_classic_color"] = classic_color
	data["PC_theme_locked"] = theme_locked

	var/obj/item/computer_hardware/battery/battery_module = all_components[MC_CELL]
	var/obj/item/computer_hardware/recharger/recharger = all_components[MC_CHARGE]

	if(battery_module?.battery)
		switch(battery_module.battery.percent())
			if(80 to 200) // 100 should be maximal but just in case..
				data["PC_batteryicon"] = "batt_100.gif"
			if(60 to 80)
				data["PC_batteryicon"] = "batt_80.gif"
			if(40 to 60)
				data["PC_batteryicon"] = "batt_60.gif"
			if(20 to 40)
				data["PC_batteryicon"] = "batt_40.gif"
			if(5 to 20)
				data["PC_batteryicon"] = "batt_20.gif"
			else
				data["PC_batteryicon"] = "batt_5.gif"
		data["PC_batterypercent"] = "[round(battery_module.battery.percent())]%"
		data["PC_showbatteryicon"] = 1
	else
		data["PC_batteryicon"] = "batt_5.gif"
		data["PC_batterypercent"] = "N/C"
		data["PC_showbatteryicon"] = battery_module ? 1 : 0

	if(recharger && recharger.enabled && recharger.check_functionality() && recharger.use_power(0))
		data["PC_apclinkicon"] = "charging.gif"

	switch(get_ntnet_status())
		if(0)
			data["PC_ntneticon"] = "sig_none.gif"
		if(1)
			data["PC_ntneticon"] = "sig_low.gif"
		if(2)
			data["PC_ntneticon"] = "sig_high.gif"
		if(3)
			data["PC_ntneticon"] = "sig_lan.gif"

	var/list/program_headers = list()
	for(var/datum/computer_file/program/P as anything in idle_threads)
		if(!P?.ui_header)
			continue
		program_headers.Add(list(list(
			"icon" = P.ui_header
		)))

	data["PC_programheaders"] = program_headers

	data["PC_stationtime"] = station_time_timestamp()
	data["PC_stationdate"] = "[time2text(world.realtime, "DDD, Month DD")], [GLOB.year_integer+YEAR_OFFSET]"
	data["PC_hasheader"] = 1
	data["PC_showexitprogram"] = active_program ? 1 : 0 // Hides "Exit Program" button on mainscreen
	return data

// Relays kill program request to currently active program. Use this to quit current program.
/obj/item/modular_computer/proc/kill_program(forced = FALSE, update = TRUE)
	if(active_program)
		if(active_program in idle_threads)
			idle_threads.Remove(active_program)
		active_program.kill_program(forced)
		active_program = null
	if(update)
		var/mob/user = usr
		if(user && istype(user))
			ui_interact(user) // Re-open the UI on this computer. It should show the main screen now.
		update_icon()

/obj/item/modular_computer/proc/open_program(mob/user, datum/computer_file/program/program, in_background = FALSE)
	if(program.computer != src)
		CRASH("tried to open program that does not belong to this computer")

	if(!program || !istype(program)) // Program not found or it's not executable program.
		to_chat(user, span_danger("\The [src]'s screen shows \"I/O ERROR - Unable to run program\" warning."))
		return FALSE

	if(!program.is_supported_by_hardware(hardware_flag, 1, user))
		return FALSE

	// The program is already running. Resume it.
	if(!in_background)
		if(program in idle_threads)
			program.program_state = PROGRAM_STATE_ACTIVE
			active_program = program
			program.alert_pending = FALSE
			idle_threads.Remove(program)
			update_icon()
			return TRUE
	else if(program in idle_threads)
		return TRUE
	var/obj/item/computer_hardware/processor_unit/PU = all_components[MC_CPU]
	if(idle_threads.len > PU.max_idle_programs)
		to_chat(user, span_danger("\The [src] displays a \"Maximal CPU load reached. Unable to run another program.\" error."))
		return FALSE

	if(program.requires_ntnet && !get_ntnet_status(program.requires_ntnet_feature)) // The program requires NTNet connection, but we are not connected to NTNet.
		to_chat(user, span_danger("\The [src]'s screen shows \"Unable to connect to NTNet. Please retry. If problem persists contact your system administrator.\" warning."))
		return FALSE

	if(!program.on_start(user))
		return FALSE

	if(!in_background)
		active_program = program
		program.alert_pending = FALSE
		ui_interact(user)
	else
		program.program_state = PROGRAM_STATE_BACKGROUND
		idle_threads.Add(program)
	update_icon()
	return TRUE



// Returns 0 for No Signal, 1 for Low Signal and 2 for Good Signal. 3 is for wired connection (always-on)
/obj/item/modular_computer/proc/get_ntnet_status(specific_action = 0)
	var/obj/item/computer_hardware/network_card/network_card = all_components[MC_NET]
	if(network_card)
		return network_card.get_signal(specific_action)
	else
		return 0

/obj/item/modular_computer/proc/add_log(text)
	if(!get_ntnet_status())
		return FALSE
	var/obj/item/computer_hardware/network_card/network_card = all_components[MC_NET]
	return SSnetworks.add_log(text, network_card.GetComponent(/datum/component/ntnet_interface).network, network_card.hardware_id)

/obj/item/modular_computer/proc/shutdown_computer(loud = 1)
	kill_program(forced = TRUE)
	for(var/datum/computer_file/program/P in idle_threads)
		P.kill_program(forced = TRUE)
		idle_threads.Remove(P)
	if(loud)
		physical.visible_message(span_notice("\The [src] shuts down."))
	enabled = 0
	update_icon()

/**
  * Toggles the computer's flashlight, if it has one.
  *
  * Called from ui_act(), does as the name implies.
  * It is separated from ui_act() to be overwritten as needed.
*/
/obj/item/modular_computer/proc/toggle_flashlight()
	if(!has_light)
		return FALSE
	set_light_on(!light_on)
	update_icon()
	// Show the light_on overlay on top of the action button icon
	update_action_buttons(force = TRUE) //force it because we added an overlay, not changed its icon
	return TRUE

/**
  * Sets the computer's light color, if it has a light.
  *
  * Called from ui_act(), this proc takes a color string and applies it.
  * It is separated from ui_act() to be overwritten as needed.
  * Arguments:
  ** color is the string that holds the color value that we should use. Proc auto-fails if this is null.
*/
/obj/item/modular_computer/proc/set_flashlight_color(color)
	if(!has_light || !color)
		return FALSE
	comp_light_color = color
	set_light_color(color)
	return TRUE

/obj/item/modular_computer/screwdriver_act(mob/user, obj/item/tool)
	if(!deconstructable)
		return
	if(!length(all_components))
		balloon_alert(user, "no components installed!")
		return
	var/list/component_names = list()
	for(var/h in all_components)
		var/obj/item/computer_hardware/H = all_components[h]
		component_names.Add(H.name)

	var/choice = input(user, "Which component do you want to uninstall?", "Computer maintenance", null) as null|anything in sort_list(component_names)

	if(!choice)
		return

	if(!Adjacent(user))
		return

	var/obj/item/computer_hardware/H = find_hardware_by_name(choice)

	if(!H)
		return

	tool.play_tool_sound(user, volume=20)
	uninstall_component(H, user, TRUE)
	ui_update()
	return

/obj/item/modular_computer/attackby(obj/item/attacking_item, mob/user, params)
	// Check for ID first
	if(istype(attacking_item, /obj/item/card/id) && InsertID(attacking_item))
		return

	// Scan a photo.
	if(istype(attacking_item, /obj/item/photo))
		var/obj/item/computer_hardware/hard_drive/hdd = all_components[MC_HDD]
		var/obj/item/photo/pic = attacking_item
		if(hdd)
			for(var/datum/computer_file/program/messenger/messenger in hdd.stored_files)
				saved_image = pic.picture
				messenger.ProcessPhoto()
				to_chat(user, span_notice("You scan \the [pic] into \the [src]'s messenger."))
				ui_update()
			return

	// Insert items into the components
	for(var/h in all_components)
		var/obj/item/computer_hardware/H = all_components[h]
		if(H.try_insert(attacking_item, user))
			ui_update()
			return

	// Insert a pAI card
	if(can_store_pai && !stored_pai_card && istype(attacking_item, /obj/item/paicard))
		if(!user.transferItemToLoc(attacking_item, src))
			return
		stored_pai_card = attacking_item
		// If the pAI moves out of the PDA, remove the reference.
		RegisterSignal(stored_pai_card, COMSIG_MOVABLE_MOVED, PROC_REF(stored_pai_moved))
		RegisterSignal(stored_pai_card, COMSIG_PARENT_QDELETING, PROC_REF(remove_pai))
		to_chat(user, span_notice("You slot \the [attacking_item] into [src]."))
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50)
		update_icon()

	// Insert new hardware
	var/obj/item/computer_hardware/inserted_hardware = attacking_item
	if(istype(inserted_hardware) && upgradable)
		if(install_component(inserted_hardware, user))
			inserted_hardware.on_inserted(user)
			ui_update()
			return

	if(attacking_item.tool_behaviour == TOOL_WRENCH)
		if(length(all_components))
			balloon_alert(user, "remove the other components!")
			return
		attacking_item.play_tool_sound(src, user, 20, volume=20)
		new /obj/item/stack/sheet/iron( get_turf(src.loc), steel_sheet_cost )
		user.balloon_alert(user, "disassembled")
		relay_qdel()
		qdel(src)
		return

	if(attacking_item.tool_behaviour == TOOL_WELDER)
		if(atom_integrity == max_integrity)
			to_chat(user, span_warning("\The [src] does not require repairs."))
			return

		if(!attacking_item.tool_start_check(user, amount=1))
			return

		to_chat(user, span_notice("You begin repairing damage to \the [src]..."))
		if(attacking_item.use_tool(src, user, 20, volume=50, amount=1))
			atom_integrity = max_integrity
			to_chat(user, span_notice("You repair \the [src]."))
			update_icon()
		return

	var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	// Check to see if we have an ID inside, and a valid input for money
	if(card_slot?.GetID() && iscash(attacking_item))
		var/obj/item/card/id/id = card_slot.GetID()
		id.attackby(attacking_item, user) // If we do, try and put that attacking object in
		return
	..()

/// Handle when the pAI moves to exit the PDA
/obj/item/modular_computer/proc/stored_pai_moved()
	if(istype(stored_pai_card) && stored_pai_card.loc != src)
		visible_message(span_notice("[stored_pai_card] ejects itself from [src]!"))
		remove_pai()

/// Set the internal pAI card to null - this is NOT "Ejecting" it.
/obj/item/modular_computer/proc/remove_pai()
	if(!istype(stored_pai_card))
		return
	UnregisterSignal(stored_pai_card, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(stored_pai_card, COMSIG_PARENT_QDELETING)
	stored_pai_card = null
	update_icon()

// Used by processor to relay qdel() to machinery type.
/obj/item/modular_computer/proc/relay_qdel()
	return

// Perform adjacency checks on our physical counterpart, if any.
/obj/item/modular_computer/Adjacent(atom/neighbor)
	if(physical && physical != src)
		return physical.Adjacent(neighbor)
	return ..()

/obj/item/modular_computer/proc/add_messenger()
	GLOB.TabletMessengers += src

/obj/item/modular_computer/proc/remove_messenger()
	GLOB.TabletMessengers -= src

// Make messages visible via allow_inside_usr
/obj/item/modular_computer/visible_message(message, self_message, blind_message, vision_distance, list/ignored_mobs, list/visible_message_flags, allow_inside_usr = TRUE)
	return ..()
