/// This is a console!
/// Finally consoles are a modular computer! Lets see how they behave!
/obj/item/modular_computer/console
	name = "modular console"
	desc = "A stationary computer."
	icon = 'icons/obj/modular_console.dmi'
	icon_state = "console-0"
	base_icon_state = "console"
	icon_state_menu = "menu"
	verb_say = "beeps"
	verb_yell = "blares"
	max_bays = 5
	w_class = WEIGHT_CLASS_GIGANTIC
	pressure_resistance = 15
	pass_flags_self = PASSMACHINE | LETPASSCLICKS
	layer = BELOW_OBJ_LAYER //keeps shit coming out of the machine from ending up underneath it.
	flags_ricochet = RICOCHET_HARD
	ricochet_chance_mod = 0.3
	anchored = TRUE
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT

	smoothing_flags = SMOOTH_BITMASK | SMOOTH_DIRECTIONAL | SMOOTH_BITMASK_SKIP_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_COMPUTERS)
	canSmoothWith = list(SMOOTH_GROUP_COMPUTERS)
	density = TRUE
	base_idle_power_usage = 100
	base_active_power_usage = 500
	max_hardware_size = WEIGHT_CLASS_LARGE
	steel_sheet_cost = 10
	max_integrity = 300
	var/console_department // Used in initialize to set network tag according to our area.
	var/screen_icon_screensaver = "standby"	// Icon state overlay when the computer is powered, but not 'switched on'.

/obj/item/modular_computer/console/Initialize(mapload)
	. = ..()
	QUEUE_SMOOTH(src)
	QUEUE_SMOOTH_NEIGHBORS(src)

/obj/item/modular_computer/console/update_overlays()
	. = ..()
	var/init_icon = initial(icon)
	if(!init_icon)
		return
	if(enabled)
		. += mutable_appearance(init_icon, "keyboard")
		if(!active_program)
			. += mutable_appearance(init_icon, icon_state_menu)
	if(!enabled && use_power())	// If not enabled but has power
		. += mutable_appearance(init_icon, screen_icon_screensaver)
		. += mutable_appearance(init_icon, "keyboard_off")
	if(atom_integrity <= integrity_failure * max_integrity)
		. += mutable_appearance(init_icon, "broken-[smoothing_junction]")

/obj/item/modular_computer/console/Destroy()
	QUEUE_SMOOTH_NEIGHBORS(src)
	. = ..()
