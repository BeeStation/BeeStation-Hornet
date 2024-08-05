// This file is dedicated to defining the mainboard itself and overriding /obj/item functions.

/// The primary logical component encapsulating all of the ModPC functionality.
///
/// This item is contained within a case or shell, and this object then contains all the possible components of a ModPC.
/obj/item/mainboard
	name = "mainboard"
	desc = "An intricate collection of circuits on a printed silicon wafer, used for connecting components together."

	icon = 'icons/obj/module.dmi'
	icon_state = "mainboard" // temporary

	/// Whether the computer is turned on.
	var/enabled = 0
	/// If this is inside of something
	var/atom/movable/physical_holder = null
	/// If we can imprint IDs on this device
	var/can_save_id = FALSE

	// theme-related
	/// Sets the theme for the main menu, hardware config, and file browser apps.
	var/device_theme = THEME_NTOS
	/// Color used for the Thinktronic Classic theme.
	var/classic_color = COLOR_OLIVE
	/// Whether this device is allowed to change themes or not.
	var/theme_locked = FALSE
	/// If the theme should not be initialized from theme prefs (for custom job themes)
	var/ignore_theme_pref = FALSE
	/// List of themes for this device to allow.
	var/list/allowed_themes

	// program-related
	/// The current foreground program that is running on the computer.
	var/datum/computer_file/program/active_program = null
	/// List of background programs that are still being processed
	var/list/datum/computer_file/program/idle_threads = null
	/// Used with the clown virus
	var/honks_left = 0

	// component-related
	/// A ref list of all components installed on this computer
	var/list/all_components = list()
	/// Lazy List of extra hardware slots that can be used modularly.
	var/list/expansion_bays
	/// Number of total expansion bays this computer has available.
	var/max_bays = 0
	/// The largest weight-class of components for this
	var/max_hardware_w_class = WEIGHT_CLASS_SMALL

	// power-related
	/// Is an integrated screen on? TODO: Make this into a screen component
	var/screen_on = FALSE
	/// The total power usage when the screen is on
	var/total_active_power_usage = 50
	/// The total power usage when the screen is off
	var/total_idle_power_usage = 5
	/// The previous tick's power usage
	var/last_power_usage = 0

	// misc variables

/obj/item/mainboard/Initialize(mapload)
	. = ..()
	allowed_themes = GLOB.ntos_device_themes_default
	idle_threads = list()
	START_PROCESSING(SSobj, src)
	// Nothing for now

/obj/item/mainboard/Destroy()
	kill_program(forced = TRUE)
	STOP_PROCESSING(SSobj, src)
	for(var/port in all_components)
		var/obj/item/computer_hardware/component = all_components[port]
		qdel(component)
	all_components?.Cut()
	// if(istype(stored_pai_card)) // This should be handled in the pai card component
	// 	qdel(stored_pai_card)
	// 	remove_pai()
	// if(istype(light_action))
	// 	QDEL_NULL(light_action)
	physical_holder = null
	// remove_messenger() // This should be handled in the messenger app
	return ..()

/obj/item/mainboard/examine(mob/user)
	. = ..()
	. += internal_parts_examine(user)

// All the various update procs
/obj/item/mainboard/update_icon_state()
	..()
	CRASH("TODO")
	// return ..()

/obj/item/mainboard/update_overlays()
	. = ..()
	CRASH("TODO")

// All the interaction procs
// click procs
/obj/item/mainboard/AltClick(mob/user)
	if(isnull(physical_holder))
		return FALSE
	if(issilicon(user) || !user.canUseTopic(physical_holder, BE_CLOSE))
		return FALSE
	var/obj/item/computer_hardware/id_slot/slot1 = all_components[MC_ID_AUTH]
	var/obj/item/computer_hardware/id_slot/slot2 = all_components[MC_ID_MODIFY]
	if(slot2?.try_eject(user))
		return slot1?.try_eject(user)
	return TRUE

// attack procs
/// When the mainboard's physical parent was used to attack
/obj/item/mainboard/proc/attack_obj_parent(obj/O, mob/living/user)
	// Send to programs for processing - this should go LAST
	// Used to implement the physical scanner.
	for(var/datum/computer_file/program/thread in (idle_threads + active_program))
		if(thread.use_attack && !thread.attack(O, user))
			return

/// When the mainboard itself is attacked
/obj/item/mainboard/attackby(obj/item/I, mob/living/user, params)
	// Try to insert items into any of the components
	for(var/component_name in all_components)
		var/obj/item/computer_hardware/comp = all_components[component_name]
		if(comp.try_insert(I, user))
			ui_update()
			return

	// Insert new hardware
	var/obj/item/computer_hardware/inserted_hardware = I
	if(istype(inserted_hardware)) //&& upgradable)
		if(install_component(inserted_hardware, user))
			inserted_hardware.on_inserted(user)
			ui_update()
			return

	return ..()

/// When the mainboard's physical parent was attacked and passed it to us
/obj/item/mainboard/proc/attackby_parent(obj/item/I, mob/user, params)
	// Check for ID first
	if(istype(I, /obj/item/card/id) && InsertID(I))
		return

	// Scan a photo.
	if(istype(I, /obj/item/photo))
		var/obj/item/computer_hardware/hard_drive/hdd = all_components[MC_HDD]
		var/obj/item/photo/pic = I
		if(hdd)
			for(var/datum/computer_file/program/messenger/messenger in hdd.stored_files)
				hdd.saved_image = pic.picture
				messenger.ProcessPhoto()
				to_chat(user, "<span class='notice'>You scan \the [pic] into \the [src]'s messenger.</span>")
				physical_holder.ui_update()
			return

	// Insert a pAI card
	if(istype(I, /obj/item/paicard))
		var/obj/item/computer_hardware/goober/pai/pai_slot = all_components[MC_PAI]
		if(isnull(pai_slot) || istype(pai_slot.stored_card))
			to_chat(user, "<span class='notice'>[I] doesnt' fit!</span>")
			return

		pai_slot.insert_pai(I)
		physical_holder.update_icon()

	if(iscash(I))
		var/obj/item/computer_hardware/id_slot/id_slot = all_components[MC_ID_AUTH]
		// Check to see if we have an ID inside, and a valid input for money
		if(id_slot?.GetID())
			var/obj/item/card/id/id = id_slot.GetID()
			id.attackby(I, user) // If we do, try and put that attacking object in
			return

	return attackby(I, user, params)

/obj/item/mainboard/proc/attack_ai_parent(mob/user)
	if(isnull(physical_holder))
		return FALSE
	return attack_self(user)

/obj/item/mainboard/proc/attack_ghost_parent(mob/user)
	if(. || isnull(physical_holder))
		return FALSE
	if(enabled)
		ui_interact(user)
	else if(IsAdminGhost(user))
		var/response = alert(user, "This computer is turned off. Would you like to turn it on?", "Admin Override", "Yes", "No")
		if(response == "Yes")
			turn_on(user)

/obj/item/mainboard/screwdriver_act(mob/user, obj/item/tool)
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

// Process currently calls handle_power(), may be expanded in future if more things are added.
/// Handle all the nessacary functions every tick
/obj/item/mainboard/process(delta_time)
	if(!enabled) // The computer is turned off
		last_power_usage = 0
		return 0

	if(obj_integrity <= integrity_failure * max_integrity)
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
