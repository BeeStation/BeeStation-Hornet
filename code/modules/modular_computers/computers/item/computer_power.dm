/obj/item/modular_computer/proc/get_power()
	if(check_power_override())
		return INFINITY
	var/obj/item/computer_hardware/recharger/recharger = all_components[MC_CHARGER]

	if(recharger && recharger.check_functionality())
		if(recharger.use_power())
			return INFINITY

	var/obj/item/computer_hardware/battery/battery_module = all_components[MC_CELL]

	if(battery_module && battery_module.battery && battery_module.battery.charge)
		var/obj/item/stock_parts/cell/cell = battery_module.battery
		return cell.charge
	return 0

// Tries to draw power from charger or, if no operational charger is present, from power cell.
/obj/item/modular_computer/proc/use_power(amount = 0)
	if(check_power_override())
		return TRUE

	var/obj/item/computer_hardware/recharger/recharger = all_components[MC_CHARGER]

	if(recharger && recharger.check_functionality())
		if(recharger.use_power(amount))
			return TRUE

	var/obj/item/computer_hardware/battery/battery_module = all_components[MC_CELL]

	if(battery_module && battery_module.battery && battery_module.battery.charge)
		var/obj/item/stock_parts/cell/cell = battery_module.battery
		if(cell.use(amount))
			return TRUE
		else // Discharge the cell anyway.
			cell.use(min(amount, cell.charge))
			return FALSE
	return FALSE

/obj/item/modular_computer/proc/give_power(amount)
	var/obj/item/computer_hardware/battery/battery_module = all_components[MC_CELL]
	if(battery_module && battery_module.battery)
		return battery_module.battery.give(amount)
	return 0

/obj/item/modular_computer/get_cell()
	var/obj/item/computer_hardware/battery/battery_module = all_components[MC_CELL]
	return battery_module?.get_cell()

// Used in following function to reduce copypaste
/obj/item/modular_computer/proc/power_failure()
	var/obj/item/computer_hardware/battery/controler = all_components[MC_CELL]
	if(controler)
		if(controler.hacked)
			battery_explosion()
			return
	if(enabled) // Shut down the computer
		if(active_program)
			active_program.event_powerfailure(0)
		for(var/I in idle_threads)
			var/datum/computer_file/program/PRG = I
			PRG.event_powerfailure(1)
		shutdown_computer(0)
	// Disable the flashlight
	if (light_on)
		set_light_on(FALSE)
		update_appearance()
		update_action_buttons(force = TRUE)

/obj/item/modular_computer/proc/battery_explosion()
	var/obj/item/computer_hardware/battery/controler = all_components[MC_CELL]
	if(controler.battery)	// If the battery controler is hacked it just fucking explodes
		var/turf/current_turf = get_turf(src)
		if(ismob(loc))
			var/mob/victim = loc
			victim.show_message(span_userdanger("Your [src] explodes!"), MSG_VISUAL, span_warning("You hear a loud *pop*!"), MSG_AUDIBLE)
		else
			visible_message(span_danger("[src] explodes!"), span_warning("You hear a loud *pop*!"))
		new /obj/effect/particle_effect/sparks/red(get_turf(src))
		playsound(src, "sparks", 50, 1)
		if(current_turf)
			current_turf.hotspot_expose(700, 125)
		switch(controler.rating)
			if(PART_TIER_1)
				explosion(src, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 2, flash_range = 1)
			if(PART_TIER_2)
				explosion(src, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 2, flash_range = 3)
			if(PART_TIER_3)
				explosion(src, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 1, flash_range = 3, flame_range = 1)
			if(PART_TIER_4)
				explosion(src, devastation_range = -1, heavy_impact_range = 1, light_impact_range = 2, flash_range = 3, flame_range = 2)
			if(PART_TIER_5)
				explosion(src, devastation_range = -1, heavy_impact_range = 2, light_impact_range = 3, flash_range = 4, flame_range = 3)
		controler.component_qdel()
		update_appearance()

// Handles power-related things, such as battery interaction, recharging, shutdown when it's discharged
/obj/item/modular_computer/proc/handle_power(delta_time)
	var/obj/item/computer_hardware/recharger/recharger = all_components[MC_CHARGER]
	if(recharger)
		recharger.process(delta_time)

	var/power_usage = calculate_power() * delta_time
	if(use_power(power_usage))
		last_power_usage = power_usage
		return TRUE
	else
		power_failure()
		return FALSE

/**
*Calculates current power usage based on if the computer is on of not.
*
*Takes into account component power usage, active or idle power usage.
*
*When te computer is idle doesn't return component power usage.
*
*/
/obj/item/modular_computer/proc/calculate_power()
	// No power usage while disabled
	if (!enabled)
		return 0

	var/power_usage = using_flashlight ? flashlight_power_usage : base_power_usage

	for(var/h in all_components)
		var/obj/item/computer_hardware/H = all_components[h]
		if(H.enabled)
			power_usage += H.power_usage

	if (active_program)
		power_usage += active_program.power_consumption

	return power_usage * power_usage_multiplier

// Used by child types if they have other power source than battery or recharger
/obj/item/modular_computer/proc/check_power_override()
	return FALSE
