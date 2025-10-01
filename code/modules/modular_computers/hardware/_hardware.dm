/obj/item/computer_hardware
	name = "hardware"
	desc = "Unknown Hardware."
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	pickup_sound = 'sound/items/handling/tape_pickup.ogg'
	drop_sound = 'sound/items/handling/tape_drop.ogg'
	//Two small paychecks as default, with higher level components going up.
	custom_price = PAYCHECK_EASY * 2

	/// w_class limits which devices can contain this component. 1: PDAs/Tablets, 2: Laptops, 3-4: Consoles only
	w_class = WEIGHT_CLASS_TINY
	/// Computer that holds this hardware, if any.
	var/obj/item/modular_computer/holder = null

	/// If the hardware uses extra power, change this.
	var/power_usage = 0
	/// If the hardware is turned off set this to 0.
	var/enabled = TRUE
	/// Prevent disabling for important component, like the CPU.
	var/critical = FALSE
	/// Prevents direct installation of removable media.
	var/can_install = TRUE
	/// Hardware that fits into expansion bays.
	var/expansion_hw = FALSE
	/// Whether the hardware is removable or not.
	var/removable = TRUE
	/// Current damage level
	var/damage = 0
	/// Maximal damage level.
	var/max_damage = 100
	/// "Malfunction" threshold. When damage exceeds this value the hardware piece will semi-randomly fail and do !!FUN!! things
	var/damage_malfunction = 20
	/// "Failure" threshold. When damage exceeds this value the hardware piece will not work at all.
	var/damage_failure = 50
	/// Chance of malfunction when the component is damaged
	var/malfunction_probability = 10
	/// What define is used to qualify this piece of hardware? Important for upgraded versions of the same hardware.
	var/device_type
	/// If the hardware can be "hotswapped" (ejected when another is installed)
	var/hotswap = TRUE
	/// If this has been opened by a screwdriver
	var/open = FALSE
	/// If this has been opened by a screwdriver
	var/open_overlay = "comp_open"
	/// If this can be hacked (This is a temporary flag for PArts that already have an overclocking effect to them)
	var/can_hack = TRUE
	/// If this is currently Hacked (Also reffered to as "Overclocking")
	var/hacked = FALSE
	/// A Serial Number used in hacking and other niffty things
	var/serial_code
	/// Hardware tier, basicly how advanced it is
	var/rating

/obj/item/computer_hardware/New(obj/L)
	..()
	pixel_x = base_pixel_x + rand(-8, 8)
	pixel_y = base_pixel_y + rand(-8, 8)

/obj/item/computer_hardware/Initialize(mapload)
	. = ..()
	serial_code = generate_series_code()

/obj/item/computer_hardware/proc/generate_series_code()	//Generates a code unique to each individual hardware piece. For now used in hardware_id of network cards
	var/list/charset = GLOB.alphabet | list("0","1","2","3","4","5","6","7","8","9")
	var/code = ""
	for(var/i = 1 to 4)
		code += pick(uppertext(charset))
	return code

/obj/item/computer_hardware/Destroy()
	if(holder)
		holder.forget_component(src)
	return ..()

/// Called when the hardware is inserted BY HAND. Use on_install for cases where it's installed by code.
/obj/item/computer_hardware/proc/on_inserted()
	playsound(src, 'sound/items/flashlight_on.ogg', 50, TRUE)
	return

/obj/item/computer_hardware/attackby(obj/item/I, mob/living/user)
	if(try_insert(I, user))
		return TRUE

	return ..()

/obj/item/computer_hardware/welder_act(mob/living/user, obj/item/I)
	if(atom_integrity == max_integrity)
		to_chat(user, span_warning("\The [src] doesn't seem to require repairs."))
		return TRUE
	if(!I.tool_start_check(user, amount=0))
		return TRUE
	user.visible_message(span_notice("[user.name] starts to repair [name]."), \
	span_notice("You start to repair [src]."), \
	span_hear("You hear welding."))
	if(!I.use_tool(src, user, 10, amount=2, volume=20))
		return
	atom_integrity = max_integrity
	to_chat(user, span_notice("The [src] is now fixed."))
	return TRUE

/obj/item/computer_hardware/update_overlays()
	. = ..()
	if(open)
		. += mutable_appearance(icon, open_overlay)

/obj/item/computer_hardware/screwdriver_act(mob/living/user, obj/item/I)
	if(!open)
		to_chat(user, "You unscrew the [name]'s service panel, exposing its internal ports and configuration nodes")
		playsound(src, 'sound/machines/pda_button1.ogg', 50, TRUE)
		open = TRUE
	else
		to_chat(user, "You screw the service panel back into place, sealing the [name]'s internals")
		playsound(src, 'sound/machines/pda_button2.ogg', 50, TRUE)
		open = FALSE
	update_appearance()
	return TRUE

/obj/item/computer_hardware/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	if(!open)
		to_chat(user, "You must unscrew the service panel in order to fiddle with the [src]'s internals.")
		return TRUE
	if(hacked)
		balloon_alert(user, "<font color='#d10282'>WARNING :: OPERATING BEYOND RATED PARAMETERS :: CONSUMPTION INALTERABLE</font>")
		to_chat(user, "<span class='cfc_magenta'>WARNING :: OPERATING BEYOND RATED PARAMETERS :: CONSUMPTION INALTERABLE</span>")
		new /obj/effect/particle_effect/sparks(get_turf(src))
		playsound(src, "sparks", 20)
		return TRUE
	var/min_power =	initial(power_usage) / 2
	var/max_power =	initial(power_usage) * 5
	var/input = tgui_input_number(usr, "Current Power Consumption Overide // Insert Value.", "Power Consumption", 0, max_power, min_power, 0, TRUE)
	if(input == null || input == "")
		return TRUE
	if(input <= ((initial(power_usage) / 2) - 1)) // If SOMEHOW this happens, lets not let it happen.
		balloon_alert(user, "Input value too low for current hardware")
		to_chat(user, "Input value too low for current hardware")
		new /obj/effect/particle_effect/sparks(get_turf(src))
		playsound(src, "sparks", 20)
		return TRUE
	power_usage = input
	new /obj/effect/particle_effect/sparks(get_turf(src))
	playsound(src, 'sound/items/handling/tape_drop.ogg', 50, TRUE)
	return TRUE

/obj/item/computer_hardware/multitool_act(mob/living/user, obj/item/I)
	balloon_alert_to_viewers("Diagnostics Retrieved.")
	var/list/result = diagnostics()
	to_chat(user, examine_block("<span class='infoplain'>[result.Join("<br>")]</span>"))
	playsound(src, 'sound/effects/fastbeep.ogg', 20)
	return TRUE

/obj/item/computer_hardware/multitool_act_secondary(mob/living/user, obj/item/tool)
	var/time_to_hack = 3 SECONDS
	var/fail_chance = 15
	if(user.mind?.assigned_role == (JOB_NAME_SCIENTIST || JOB_NAME_RESEARCHDIRECTOR))	// Scientist buff
		time_to_hack = 2 SECONDS
		fail_chance = 5
	if(HAS_TRAIT(user, TRAIT_COMPUTER_WHIZ))	// Trait buff
		time_to_hack = 1 SECONDS
		fail_chance = 0
	if(!open)
		to_chat(user, "You must unscrew the service panel in order to fiddle with the [src]'s internals.")
		return TRUE
	if(!can_hack)
		to_chat(user, "\The [src] cannot be overclocked.")
		return TRUE
	balloon_alert(user, "<font color='#12e21d'>Authorization Required. Keygen in progress...</font>")
	to_chat(user, "<span class='cfc_lime'>Authorization Required. Keygen in progress...</span>")
	playsound(src, 'sound/machines/defib_saftyOff.ogg', 50, TRUE)

	if(!do_after(user, time_to_hack, src))
		balloon_alert(user, "<font color='#d80000'>ERROR:</font> Unauthorized access detected!")
		to_chat(user, "<span class='cfc_red'>ERROR:</span> Unauthorized access detected!")
		new /obj/effect/particle_effect/sparks(get_turf(src))
		playsound(src, "sparks", 40)
		user.electrocute_act(25, src, 1)
		return TRUE
	if(prob(fail_chance))
		balloon_alert(user, "<font color='#d80000'>Error:</font> Serial Key provided is invalid.")
		to_chat(user, "<span class='cfc_red'>Error:</span> Serial Key provided is invalid.")
		new /obj/effect/particle_effect/sparks(get_turf(src))
		playsound(src, "sparks", 40)
		user.electrocute_act(25, src, 1)
	else
		overclock(user, tool)
		playsound(src, 'sound/effects/fastbeep.ogg', 10)
	return TRUE

/obj/item/computer_hardware/add_context_self(datum/screentip_context/context, mob/user)
	context.add_left_click_tool_action("Diagnose", TOOL_MULTITOOL)
	context.add_right_click_tool_action("Overclock", TOOL_MULTITOOL)
	context.add_left_click_tool_action("[open ? "Close" : "Open"]", TOOL_SCREWDRIVER)
	context.add_right_click_tool_action("Alter Power Consumption", TOOL_SCREWDRIVER)
	context.add_left_click_tool_action("Repair", TOOL_WELDER)
	context.add_left_click_tool_action("[enabled ? "Disable" : "Enable"]", TOOL_WIRECUTTER)

/obj/item/computer_hardware/proc/overclock(mob/living/user, obj/item/tool)
	if(hacked)
		hacked = FALSE
		power_usage = initial(power_usage)
		to_chat(user, "You returned [src] to safe working parameters.")
	else
		hacked = TRUE
		power_usage = (power_usage * 5)
		balloon_alert(user, "<font color='#00bb10'>Access Authorized.</font> System overclocking initiated.")
		to_chat(user, "<span class='cfc_green'>Access Authorized.</span> System overclocking initiated.")
	new /obj/effect/particle_effect/sparks/blue(get_turf(src))
	playsound(src, "sparks", 50)
	update_appearance()
	update_overclocking(user, tool)

/obj/item/computer_hardware/wirecutter_act(mob/living/user, obj/item/tool)
	if(enabled)
		enabled = FALSE
		to_chat(user, "The [src] has been disabled.")
		playsound(src, 'sound/items/handling/wirecutter_pickup.ogg', 50, TRUE)
		return TRUE
	else
		enabled = TRUE
		to_chat(user, "The [src] has been enabled.")
		playsound(src, 'sound/items/handling/wirecutter_pickup.ogg', 50, TRUE)
		return TRUE

/obj/item/computer_hardware/proc/update_overclocking(mob/living/user, obj/item/tool)
	return // Nothing happens here yet

/// Called on multitool click, returns a string of diagnostic information.
/obj/item/computer_hardware/proc/diagnostics()
	. = list()
	. += "***** DIAGNOSTICS REPORT *****"
	. += "Hardware Integrity Test... (Corruption: [damage]/[max_damage]) [damage > damage_failure ? "FAIL" : damage > damage_malfunction ? "WARN" : "PASS"]"
	if(!enabled)
		. += "<span class='cfc_soul_glimmer_humour'>Warning</span> // Hardware Disabled"
	if(power_usage)
		. += "Current power consumption :: [display_power_persec(power_usage)]"
	if(expansion_hw)
		. += "INFO :: Component requires Expansion Bay slot."
	if(hacked)
		. += "<span class='cfc_magenta'>WARNING :: OPERATING BEYOND RATED PARAMETERS</span>"
	return

/obj/item/computer_hardware/proc/component_qdel()	// Handles deleting a component professionally
	if(holder)
		holder.uninstall_component(src)
	qdel(src)

/// Handles damage checks
/obj/item/computer_hardware/proc/check_functionality()
	if(!enabled) // Disabled.
		return FALSE

	if(damage > damage_failure) // Too damaged to work at all.
		return FALSE

	if(damage > damage_malfunction) // Still working. Well, sometimes...
		if(prob(malfunction_probability))
			return FALSE

	return TRUE // Good to go.

/obj/item/computer_hardware/examine(mob/user)
	. = ..()
	if(damage > damage_failure)
		. += span_danger("It seems to be severely damaged!")
	else if(damage > damage_malfunction)
		. += span_warning("It seems to be damaged!")
	else if(damage)
		. += span_notice("It seems to be slightly damaged.")

/// Component-side compatibility check.
/obj/item/computer_hardware/proc/can_install(obj/item/modular_computer/install_into, mob/living/user = null)
	if(open)
		to_chat(user, span_notice("The component doesn't fit! Try closing the maintenance panel with a screwdriver!"))
		playsound(src, 'sound/items/handling/tape_drop.ogg', 50, TRUE)
		return FALSE
	return can_install

/// Called when component is installed into PC.
/obj/item/computer_hardware/proc/on_install(obj/item/modular_computer/install_into, mob/living/user = null)
	install_into.ui_update(user)
	return

/// Called when component is removed from PC.
/obj/item/computer_hardware/proc/on_remove(obj/item/modular_computer/remove_from, mob/living/user)
	if(remove_from.physical && !QDELETED(remove_from) && !QDELETED(src))
		try_eject(forced = TRUE)
	remove_from.ui_update(user)

/// Called when someone tries to insert something in it - paper in printer, card in card reader, etc.
/obj/item/computer_hardware/proc/try_insert(obj/item/I, mob/living/user = null)
	return FALSE

/**
  * Implement this when your hardware contains an object that the user can eject.
  *
  * Examples include ejecting cells from battery modules, ejecting an ID card from a card reader
  * or ejecting an Intellicard from an AI card slot.
  * Arguments:
  * * user - The mob requesting the eject.
  * * forced - Whether this action should be forced in some way.
  */
/obj/item/computer_hardware/proc/try_eject(mob/living/user = null, forced = FALSE)
	return FALSE
