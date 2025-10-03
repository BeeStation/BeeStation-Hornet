/obj/machinery/cell_charger
	name = "cell charger"
	desc = "It charges power cells."
	icon = 'icons/obj/power.dmi'
	icon_state = "ccharger"
	use_power = IDLE_POWER_USE
	idle_power_usage = 100 WATT
	power_channel = AREA_USAGE_EQUIP
	circuit = /obj/item/circuitboard/machine/cell_charger
	pass_flags = PASSTABLE
	var/obj/item/charging = null
	var/chargelevel = -1
	var/recharge_coeff = 1
	var/static/list/allowed_items = list(
		/obj/item/stock_parts/cell,
		/obj/item/modular_computer)

/obj/machinery/cell_charger/RefreshParts()
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		recharge_coeff = C.rating

/obj/machinery/cell_charger/update_overlays()
	. = ..()
	var/init_icon = initial(icon)
	if(!init_icon)
		return
	if(charging)
		var/obj/item/stock_parts/cell/cell_charging = charging.get_cell()
		. += mutable_appearance(init_icon, "ccharger-on")
		if(!(machine_stat & (BROKEN|NOPOWER)))
			var/newlevel = 	round(cell_charging.percent() * 4 / 100)
			chargelevel = newlevel
			. += mutable_appearance(init_icon, "ccharger-o[newlevel]")
	if(istype(charging, /obj/item/modular_computer))	//The overlay is for PDA but lets do this for other computers also
		. += mutable_appearance(init_icon, "pda")

/obj/machinery/cell_charger/examine(mob/user)
	. = ..()
	. += "There's [charging ? "a" : "no"] [charging ? charging : "cell"] in the charger."
	if(charging)
		var/obj/item/stock_parts/cell/cell_charging = charging.get_cell()
		. += "Current charge: [round(cell_charging.percent(), 1)]%."
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads:")
		. += span_notice("- Current recharge coefficient: <b>[recharge_coeff]</b>.")

/obj/machinery/cell_charger/attackby(obj/item/W, mob/user, params)
	if(W.get_cell() && is_allowed(W) && !panel_open)
		if(machine_stat & BROKEN)
			to_chat(user, span_warning("[src] is broken!"))
			return
		if(!anchored)
			to_chat(user, span_warning("[src] isn't attached to the ground!"))
			return
		if(charging)
			to_chat(user, span_warning("There is already something in the charger!"))
			return
		else
			var/area/a = get_area(src) // Gets our locations location, like a dream within a dream
			if(!isarea(a))
				return
			if(a.power_equip == 0) // There's no APC in this area, don't try to cheat power!
				to_chat(user, span_warning("[src] blinks red as you try to insert the [W]!"))
				return
			if(!user.transferItemToLoc(W,src))
				return

			charging = W
			user.visible_message("[user] inserts a [W] into [src].", span_notice("You insert a [W] into [src]."))
			chargelevel = -1
			update_appearance()
	else
		if(!charging && default_deconstruction_screwdriver(user, icon_state, icon_state, W))
			return
		if(default_deconstruction_crowbar(W))
			return
		if(!charging && default_unfasten_wrench(user, W))
			return
		return ..()

/obj/machinery/cell_charger/proc/is_allowed(obj/item/I)
	for(var/path in allowed_items)
		if(istype(I, path))
			return TRUE
	return FALSE

/obj/machinery/cell_charger/deconstruct()
	if(charging)
		charging.forceMove(drop_location())
	return ..()

/obj/machinery/cell_charger/Destroy()
	QDEL_NULL(charging)
	return ..()

/obj/machinery/cell_charger/proc/removecell()
	charging.update_appearance()
	charging = null
	chargelevel = -1
	update_appearance()

/obj/machinery/cell_charger/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!charging)
		return

	user.put_in_hands(charging)
	charging.add_fingerprint(user)

	user.visible_message("[user] removes [charging] from [src].", span_notice("You remove [charging] from [src]."))

	removecell()

/obj/machinery/cell_charger/attack_tk(mob/user)
	if(!charging)
		return
	charging.forceMove(loc)
	to_chat(user, span_notice("You telekinetically remove [charging] from [src]."))
	removecell()
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/machinery/cell_charger/attack_silicon(mob/user)
	return TRUE

/obj/machinery/cell_charger/emp_act(severity)
	. = ..()

	if(machine_stat & (BROKEN|NOPOWER) || . & EMP_PROTECT_CONTENTS)
		return

	if(charging)
		charging.emp_act(severity)

/obj/machinery/cell_charger/process(delta_time)
	if(!charging || !anchored || (machine_stat & (BROKEN|NOPOWER)))
		return

	var/obj/item/stock_parts/cell/cell = charging.get_cell()

	if(!cell)
		update_use_power(IDLE_POWER_USE)
		return
	if(cell.percent() >= 100)
		update_use_power(IDLE_POWER_USE)
		return

	var/power_needed = cell.chargerate * recharge_coeff

	// Power transfer loss happens here so it doesn't affect user experience too much (making cell take more time to charge than it should)
	active_power_usage = power_needed / POWER_TRANSFER_LOSS
	update_use_power(ACTIVE_POWER_USE)

	cell.give(active_power_usage)

	update_appearance()

/obj/machinery/cell_charger/add_context_self(datum/screentip_context/context, mob/user)
	if (charging)
		context.add_attack_hand_action("Take Item")
	if (!panel_open)
		context.add_left_click_item_action("Charge Item", get_cell())
	if (!charging)
		context.add_generic_deconstruction_actions(src)
		context.add_generic_unfasten_actions(src, TRUE)
