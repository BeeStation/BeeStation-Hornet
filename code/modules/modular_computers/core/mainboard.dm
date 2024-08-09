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
	// var/screen_on = FALSE
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
	// Nothing for now

/obj/item/mainboard/Destroy()
	turn_off(loud = FALSE)
	for(var/port in all_components)
		var/obj/item/computer_hardware/component = all_components[port]
		qdel(component)
	all_components?.Cut()
	// remove_messenger() // This should be handled in the messenger app
	return ..()

// All the interaction procs
// click procs

/obj/item/mainboard/proc/GetAccess_parent()
	var/obj/item/computer_hardware/id_slot/id_slot = all_components[MC_ID_AUTH]
	if(!istype(id_slot))
		return
	. = id_slot.GetAccess_parent()

/obj/item/mainboard/proc/GetID_parent()
	var/obj/item/computer_hardware/id_slot/id_slot = all_components[MC_ID_AUTH]
	if(!istype(id_slot))
		return
	. = id_slot.GetID_parent()

// attack procs
/// When the mainboard's physical parent was used to attack
/obj/item/mainboard/proc/attack_obj_parent(obj/O, mob/living/user)
	// Send to programs for processing - this should go LAST
	// Used to implement the physical scanner.
	for(var/datum/computer_file/program/thread in (idle_threads + active_program))
		if(thread.use_attack_obj && thread.attack_obj(O, user))
			return

/// When the mainboard itself is attacked
/obj/item/mainboard/attackby(obj/item/I, mob/living/user, params)
	// Insert new hardware
	var/obj/item/computer_hardware/inserted_hardware = I
	if(istype(inserted_hardware)) //&& upgradable)
		if(install_component(inserted_hardware, user))
			inserted_hardware.on_inserted(user)
			ui_update()
			return

	return ..()

/obj/item/mainboard/screwdriver_act(mob/user, obj/item/tool)
	if(!length(all_components))
		balloon_alert(user, "no components installed!")
		return
	var/list/component_names = list()
	for(var/h in all_components)
		var/obj/item/computer_hardware/H = all_components[h]
		component_names.Add(H.name)

	INVOKE_ASYNC(
		src,
		GLOBAL_PROC_REF(tgui_input_list_async),
		user,
		"Which component do you want to uinstall?",
		"Computer maintenance",
		component_names,
		null,
		PROC_REF(after_screwdriver_act),
		30 SECONDS
	)

	// var/choice1 = tgui_input_list_async()

	// var/choice = input(user, "Which component do you want to uninstall?", "Computer maintenance", null) as null|anything in sort_list(component_names)

/obj/item/mainboard/proc/after_screwdriver_act(choice)
	var/mob/user = src

	if(!istype(user) || !choice || !physical_holder.Adjacent(user))
		return

	var/obj/item/computer_hardware/H = find_hardware_by_name(choice)
	if(!istype(H))
		return

	var/obj/item/screwdriver/thing = user.get_active_held_item()
	if(istype(thing))
		thing.play_tool_sound(user, volume=20)
	uninstall_component(H, user, TRUE)
	ui_update()
	return

/obj/item/mainboard/process(delta_time)
	if(!enabled)
		last_power_usage = 0
		return 0

	if(istype(active_program) && active_program.requires_ntnet && !get_ntnet_status(active_program.requires_ntnet_feature))
		active_program.event_networkfailure(0) // Active program requires NTNet to run but we've just lost connection. Crash.

	for(var/datum/computer_file/program/P in idle_threads)
		if(P.requires_ntnet && !get_ntnet_status(P.requires_ntnet_feature))
			P.event_networkfailure(1)

	if(istype(active_program))
		if(active_program.program_state != PROGRAM_STATE_KILLED)
			active_program.process_tick(delta_time)
			active_program.ntnet_status = get_ntnet_status()
		else
			active_program = null

	for(var/datum/computer_file/program/P in idle_threads)
		if(P.program_state != PROGRAM_STATE_KILLED)
			P.process_tick(delta_time)
			P.ntnet_status = get_ntnet_status()
		else
			idle_threads.Remove(P)

	handle_power(delta_time) // Handles all computer power interaction
	//check_update_ui_need()
