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
/obj/item/mainboard/ui_interact(mob/user, datum/tgui/ui)
	if(!enabled || !user.is_literate())


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
