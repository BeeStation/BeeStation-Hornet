/obj/machinery/atmospherics/gasrig
	name = "\improper Advanced Gas Rig"
	desc = "This state-of-the-art gas mining rig will extend a collector down to the depths of the atmosphere below to extract all the gases a station could need."
	icon = 'icons/obj/machines/gasrig.dmi'
	icon_state = "gasrig_1"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	move_resist = INFINITY
	layer = HIGH_OBJ_LAYER

/obj/machinery/atmospherics/gasrig/core
	/// Machine starts idle unless you want it to always start active
	use_power = IDLE_POWER_USE
	/// What we expend when NOT harvesting gasses
	idle_power_usage = 2 KILOWATT
	/// Power draw when harvesting gas (increases according to depth at Y x Depth / 200) (This will always be power usage at 200 depth)
	active_power_usage = 25 KILOWATT
	density = TRUE

	var/depth = 0

	/// the desired depth to approach
	var/set_depth = 0
	var/shield_strength = GASRIG_MAX_SHIELD_STRENGTH
	/// used for displaying the shield strength delta
	var/shield_strength_change = 0

	var/mode = GASRIG_MODE_NORMAL
	var/active = TRUE
	var/overpressure = FALSE

	var/health = GASRIG_MAX_HEALTH
	var/needs_repairs = FALSE

	var/display_efficiency = 1
	var/list/display_mols_produced = list()
	var/display_shield_efficiency = 0

	var/display_gas_power = 0
	var/display_gasrig_gas_modifier = 0

	var/list/gas_references = list( //I think it might be better to stack this in with the gas defines themselves, but it would get kinda messy with how I made the tgui
		/datum/gas/oxygen = GASRIG_O2,
		/datum/gas/nitrogen = GASRIG_N2,
		/datum/gas/plasma = GASRIG_PLAS,
		/datum/gas/carbon_dioxide = GASRIG_CO2,
		/datum/gas/nitrous_oxide = GASRIG_N2O,
		/datum/gas/bz = GASRIG_BZ,
		/datum/gas/pluoxium = GASRIG_PLOX,
		/datum/gas/hypernoblium = GASRIG_NOB,
		/datum/gas/tritium = GASRIG_TRIT
	)

	init_processing = TRUE

	var/datum/looping_sound/gravgen/soundloop

	var/obj/machinery/atmospherics/components/unary/gasrig/shielding_input/shielding_input

	var/obj/machinery/atmospherics/components/unary/gasrig/fracking_input/fracking_input

	var/obj/machinery/atmospherics/components/unary/gasrig/gas_output/gas_output

	var/list/dummies = list()

/obj/machinery/atmospherics/gasrig/core/proc/init_inputs()
	var/turf/offset_loc = locate(x - 1, y, z)
	shielding_input = new /obj/machinery/atmospherics/components/unary/gasrig/shielding_input(offset_loc, src)
	shielding_input.dir = WEST
	shielding_input.set_init_directions()
	offset_loc = locate(x + 1, y, z)
	fracking_input = new /obj/machinery/atmospherics/components/unary/gasrig/fracking_input(offset_loc, src)
	fracking_input.dir = EAST
	fracking_input.set_init_directions()
	offset_loc = locate(x, y - 1, z)
	gas_output = new /obj/machinery/atmospherics/components/unary/gasrig/gas_output(offset_loc, src)
	gas_output.dir = SOUTH
	gas_output.set_init_directions()

/obj/machinery/atmospherics/gasrig/core/proc/init_dummies()
	var/turf/offset_loc = locate(x - 1, y + 1, z)
	dummies += new /obj/machinery/atmospherics/gasrig/dummy(offset_loc, src, "gasrig_d1")
	offset_loc = locate(x, y + 1, z)
	dummies += new /obj/machinery/atmospherics/gasrig/dummy(offset_loc, src, "gasrig_d2")
	offset_loc = locate(x + 1, y + 1, z)
	dummies += new /obj/machinery/atmospherics/gasrig/dummy(offset_loc, src, "gasrig_d3")
	offset_loc = locate(x - 1, y - 1, z)

	for(var/obj/machinery/atmospherics/gasrig/dummy/dummy in dummies)
		dummy.layer = ABOVE_MOB_LAYER

	dummies += new /obj/machinery/atmospherics/gasrig/dummy(offset_loc, src, "gasrig_d4")
	offset_loc = locate(x + 1, y - 1, z)
	dummies += new /obj/machinery/atmospherics/gasrig/dummy(offset_loc, src, "gasrig_d5")



/obj/machinery/atmospherics/gasrig/core/Initialize(mapload)
	. = ..()
	soundloop = new(src)
	soundloop.volume = 10 //depth starts at zero so init at minimum volume
	soundloop.start() //start immediately as it starts on
	init_inputs()
	init_dummies()
	update_pipenets()

/obj/machinery/atmospherics/gasrig/core/Destroy()
	if (shielding_input)
		QDEL_NULL(shielding_input)
	if (fracking_input)
		QDEL_NULL(fracking_input)
	if (gas_output)
		QDEL_NULL(gas_output)
	QDEL_LIST(dummies)
	QDEL_NULL(soundloop)
	STOP_PROCESSING(SSmachines, src)
	return ..()

/obj/machinery/atmospherics/gasrig/core/process(delta_time)	// Machine operation is here
	display_mols_produced = list() // this is here to ensure the list is empty if mols arnt being produced
	get_shield_damage(shielding_input.airs[1])
	get_damage(delta_time)
	if(machine_stat & NOPOWER)
		update_pipenets()
		return
	if(!active)
		update_use_power(IDLE_POWER_USE) // We're not fracking yet so power consumption is IDLE
	if(!needs_repairs && active)
		update_use_power(ACTIVE_POWER_USE)
		produce_gases(gas_output.airs[1], delta_time)
	if(needs_repairs && active)	//when repairs are needed leak gases into the turf instead of gas_output
		produce_gases(src.loc.return_air(), delta_time)
		src.air_update_turf(FALSE, FALSE)
	calculate_power_use()
	approach_set_depth(delta_time)
	update_pipenets()

/obj/machinery/atmospherics/gasrig/core/examine(mob/user)
	. = ..()
	if(needs_repairs)
		. += span_warning("Some components have been damaged beyond repair. Use plasteel sheets to replace them.")
	if(health < GASRIG_MAX_HEALTH)
		. += "It is damaged. Use a welder to repair it."
	if(overpressure)
		. += "Maximum output pressure exceeded."

/obj/machinery/atmospherics/gasrig/core/power_change()
	. = ..()
	if(!.)
		return
	if(machine_stat & NOPOWER)
		if(soundloop.is_active())
			soundloop.stop()
	else if (active && !soundloop.is_active())
		soundloop.start()
	update_appearance()

/obj/machinery/atmospherics/gasrig/core/proc/get_shield_damage(datum/gas_mixture/air)
	var/datum/gas_mixture/temp_air = new
	air.pump_gas_to(temp_air, 4500)
	var/gas_power = 0 //Gases with no gas power dont provide much for shielding
	var/gas_modifier = 0 //To encourage balancing a mix rather then just getting the gas with the most gas power
	var/total_moles = 1 //so the log doesnt start negative
	for (var/datum/gas/gas_id as anything in temp_air.gases)
		gas_power += initial(gas_id.gasrig_shielding_power)*temp_air.gases[gas_id][MOLES]
		gas_modifier += initial(gas_id.gasrig_shielding_modifier)*temp_air.gases[gas_id][MOLES]
		total_moles += temp_air.gases[gas_id][MOLES]

	var/aver_gas_modifier = 0

	if (total_moles > 0)
		aver_gas_modifier = gas_modifier / total_moles

	display_gas_power = gas_power
	display_gasrig_gas_modifier = aver_gas_modifier

	aver_gas_modifier = clamp(aver_gas_modifier, 0.1, 1) //clamp the gas modifier so shielding power of a gas is never zero

	var/temp_shield = (((gas_power) * log(10, total_moles * GASRIG_SHIELD_MOL_LOG_MULTIPLER)) * aver_gas_modifier) + GASRIG_NATURAL_SHIELD_RECOVERY
	display_shield_efficiency = temp_shield
	shield_strength_change = temp_shield - (get_depth() * GASRIG_DEPTH_SHIELD_DAMAGE_MULTIPLIER)
	shield_strength = clamp(shield_strength + shield_strength_change, 0, GASRIG_MAX_SHIELD_STRENGTH)


/obj/machinery/atmospherics/gasrig/core/proc/produce_gases(datum/gas_mixture/air, delta_time)
	var/efficiency = get_fracking_efficiency(fracking_input.airs[1])
	if (air.return_pressure() > get_output_pressure(efficiency))
		overpressure = TRUE
		return

	overpressure = FALSE

	for(var/gas_datum in gas_references)
		calculate_gas_to_output(gas_references[gas_datum], gas_datum, air, efficiency, delta_time)

/obj/machinery/atmospherics/gasrig/core/proc/calculate_power_use()
	var/depth = get_depth()
	var/temp_power_usage = max(initial(active_power_usage) * (depth / 200), 2 KILOWATT)
	if (active_power_usage != temp_power_usage)
		active_power_usage = temp_power_usage // 100 depth is 12.5 kW/s 200 depth is 25 300 is 37.5, 1000 is 125 kW.
		update_current_power_usage()

/obj/machinery/atmospherics/gasrig/core/proc/get_fracking_efficiency(datum/gas_mixture/air)
	var/datum/gas_mixture/temp_air = new
	air.release_gas_to(temp_air, air.return_pressure() / 2, 1)
	// to prevent efficiency ever being below 1
	var/temp_eff = log(10, (temp_air.return_pressure() * temp_air.total_moles()) + 10)
	display_efficiency = temp_eff
	return temp_eff

/obj/machinery/atmospherics/gasrig/core/proc/change_health(amount)
	health = clamp(health + amount, 0, GASRIG_MAX_HEALTH)


/obj/machinery/atmospherics/gasrig/core/proc/get_damage(delta_time)
	if(shield_strength > 0)
		return

	change_health(-5)

	if(!needs_repairs && DT_PROB(50, delta_time))
		playsound(src.loc, 'sound/machines/apc/PowerSwitch_Cover.ogg', 75, 1)

	if (health <= 0)
		update_mode(GASRIG_MODE_REPAIR)


/obj/machinery/atmospherics/gasrig/core/proc/get_output_pressure(fracking_efficiency)
	return max(GASRIG_DEFAULT_OUTPUT_PRESSURE, fracking_efficiency * GASRIG_FRACKING_PRESSURE_MULTIPLER)

/obj/machinery/atmospherics/gasrig/core/proc/approach_set_depth(delta_time)
	var/temp_depth = get_depth()
	if (temp_depth != set_depth)
		if (temp_depth < set_depth && !needs_repairs)
			depth += min(GASRIG_DEPTH_CHANGE_SPEED * delta_time, set_depth - temp_depth)
		if (temp_depth > set_depth)
			depth += max(-GASRIG_DEPTH_CHANGE_SPEED * delta_time, set_depth - temp_depth)
		soundloop.volume = max(10, floor((temp_depth / GASRIG_MAX_DEPTH) * 75))

//for potential station altitude updates.
/obj/machinery/atmospherics/gasrig/core/proc/get_depth()
	return depth

/obj/machinery/atmospherics/gasrig/core/update_icon_state()
	. = ..()
	if(mode == GASRIG_MODE_NORMAL && !needs_repairs)
		if(active && !(machine_stat & NOPOWER))
			icon_state = "gasrig_1"
			return
	icon_state = "gasrig_1_off"

/obj/machinery/atmospherics/gasrig/core/update_overlays()
	. = ..()
	. += mutable_appearance(initial(icon), "glass_overlay_1")	// Layers may not be working as I expect it, if not, delete layer arg and move this after last mutable
	if(!active || (machine_stat & NOPOWER))
		return
	if(!needs_repairs)
		. += mutable_appearance(initial(icon), "overlay_1")
		. += emissive_appearance(initial(icon), "overlay_1", layer)
	if(mode == GASRIG_MODE_REPAIR)	// Whatever "broken" is
		. += mutable_appearance(initial(icon), "overlay_1_broken")
		. += emissive_appearance(initial(icon), "overlay_1_broken", layer)

/obj/machinery/atmospherics/gasrig/core/update_appearance(updates)
	. = ..()
	gas_output.update_appearance()

/obj/machinery/atmospherics/gasrig/core/proc/update_mode(new_mode)
	if (mode == new_mode)
		return

	mode = new_mode
	switch(new_mode)
		if(GASRIG_MODE_NORMAL)
			update_appearance()
			if(active)
				soundloop.start()
		if(GASRIG_MODE_REPAIR)
			//here so it only plays once
			playsound(src, 'sound/weapons/blastcannon.ogg', 100)
			playsound(src, 'sound/machines/hiss.ogg', 50)
			needs_repairs = TRUE
			update_appearance()

/obj/machinery/atmospherics/gasrig/core/proc/set_active(to_set)
	active = to_set
	if(!active)
		soundloop.stop()
		return
	soundloop.start()

/obj/machinery/atmospherics/gasrig/core/welder_act(mob/living/user, obj/item/tool)
	if(health >= GASRIG_MAX_HEALTH)
		balloon_alert(user, "No repairs needed!")
		return TRUE
	if(get_depth() > 0)
		balloon_alert(user, "The rig needs to be raised to repair it!")
		return TRUE
	if(needs_repairs)
		balloon_alert(user, "Repair with plasteel first!")
		return TRUE
	if(tool.use_tool(src, user, 0, volume=50, amount=2))
		change_health(10)
		balloon_alert(user, "You repair the rig's damage!")
		return TRUE

/obj/machinery/atmospherics/gasrig/core/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/stack/sheet/plasteel))
		var/obj/item/stack/sheet/plasteel/plasteel_sheets = attacking_item
		if(!needs_repairs)
			balloon_alert(user, "No repairs needed!")
			return
		if(get_depth() > 0)
			balloon_alert(user, "The rig needs to be raised to repair it!")
			return
		if(plasteel_sheets.get_amount() >= 10)
			plasteel_sheets.use(10)
			balloon_alert(user, "You replace damaged plating.")
			playsound(src, 'sound/machines/click.ogg', 75, 1)
			needs_repairs = FALSE
			update_mode(GASRIG_MODE_NORMAL)
			change_health(10)
			update_appearance()
			return
		else
			balloon_alert(user, "You need 10 sheets of plasteel!")
			return
	return ..()

/obj/machinery/atmospherics/gasrig/core/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosGasRig")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/atmospherics/gasrig/core/ui_static_data(mob/user)
	var/list/data = list()
	data["o2_constants"] = GASRIG_O2
	data["n2_constants"] = GASRIG_N2
	data["plas_constants"] = GASRIG_PLAS
	data["co2_constants"] = GASRIG_CO2
	data["n2o_constants"] = GASRIG_N2O
	data["nob_constants"] = GASRIG_NOB
	data["bz_constants"] =  GASRIG_BZ
	data["plox_constants"] = GASRIG_PLOX
	data["trit_constants"] = GASRIG_TRIT
	data["max_health"] = GASRIG_MAX_HEALTH
	data["max_shield"] = GASRIG_MAX_SHIELD_STRENGTH
	data["max_depth"] = GASRIG_MAX_DEPTH
	return data


/obj/machinery/atmospherics/gasrig/core/ui_data(mob/user)
	var/list/data = list()
	data["depth"] = depth
	data["set_depth"] = set_depth
	data["shield_strength"] = shield_strength
	data["shield_strength_change"] = shield_strength_change
	data["fracking_eff"] = display_efficiency
	data["shield_eff"] = display_shield_efficiency
	data["gas_power"] = display_gas_power
	data["gas_modifier"] = display_gasrig_gas_modifier
	data["health"] = health
	data["active"] = active
	data["mols_produced"] = display_mols_produced
	data["warning_message"] = get_warning()
	return data

/obj/machinery/atmospherics/gasrig/core/proc/get_warning()
	if(needs_repairs)
		return "Repairs needed! Use plasteel to replace damaged components."
	if(overpressure)
		return "Output pressure has exceeded maximum."
	return null

/obj/machinery/atmospherics/gasrig/core/ui_act(action, params)
	. = ..()
	if(.)
		return
	ui_act_base(action, params)


/obj/machinery/atmospherics/gasrig/core/proc/ui_act_base(action, params)
	if(machine_stat & NOPOWER)
		return
	switch(action)
		if("set_depth")
			set_depth = text2num(params["set_depth"])
			. = TRUE
		if("active")
			set_active(!active)
			. = TRUE
	update_appearance()

/obj/machinery/atmospherics/gasrig/core/proc/add_gas_to_output(datum/gas/to_add, datum/gas_mixture/air, amount, temp)
	var/datum/gas_mixture/merger = new
	merger.assert_gas(to_add)
	merger.gases[to_add][MOLES] = amount
	merger.temperature = temp
	air.merge(merger)

/obj/machinery/atmospherics/gasrig/core/proc/calculate_gas_to_output(gas_constant, datum/gas/gas_type, datum/gas_mixture/air, efficiency, delta_time)
	if(get_depth() < gas_constant[1] || get_depth() > gas_constant[2])
		return
	var/difference = gas_constant[2] - gas_constant[1]
	var/percent_rising = ((get_depth() - gas_constant[1]) / (difference/2))
	var/percent_falling = ((gas_constant[2] - get_depth()) / (difference/2))
	var/gas_produced = gas_constant[3] * min(percent_falling, percent_rising) * efficiency
	display_mols_produced += list(gas_type.name, gas_produced / delta_time)
	add_gas_to_output(gas_type, air, gas_produced, depth * GASRIG_DEPTH_TEMP_MULTIPLER)

/obj/machinery/atmospherics/gasrig/core/proc/update_pipenets()
	shielding_input.update_parents()
	fracking_input.update_parents()
	gas_output.update_parents()

/obj/machinery/atmospherics/components/unary/gasrig/
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	move_resist = INFINITY
	var/obj/machinery/atmospherics/gasrig/core/parent

/obj/machinery/atmospherics/components/unary/gasrig/Initialize(mapload, obj/machinery/atmospherics/gasrig/core/gas_rig)
	parent = gas_rig //ordered this way to prevent update_overlays from getting a null value
	. = ..()

/obj/machinery/atmospherics/components/unary/gasrig/Destroy()
	if (parent)
		QDEL_NULL(parent)
	return ..()

/obj/machinery/atmospherics/components/unary/gasrig/welder_act(mob/living/user, obj/item/tool)
	if(parent.welder_act(user, tool))
		return TRUE

/obj/machinery/atmospherics/components/unary/gasrig/attackby(obj/item/I, mob/user, params)
	return parent.attackby(I, user, params)

/obj/machinery/atmospherics/components/unary/gasrig/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosGasRig")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/atmospherics/components/unary/gasrig/ui_act(action, params)
	. = ..()
	if(.)
		return
	parent.ui_act_base(action, params)

/obj/machinery/atmospherics/components/unary/gasrig/ui_data(mob/user)
	return parent.ui_data(user)

/obj/machinery/atmospherics/components/unary/gasrig/ui_static_data(mob/user)
	return parent.ui_static_data(user)

/obj/machinery/atmospherics/components/unary/gasrig/shielding_input
	name = "AGR shield gas input port"
	desc = "Input port for the AGR to intake shielding gas."
	icon = 'icons/obj/machines/gasrig.dmi'
	icon_state = "gasrig_port_1"
	layer = HIGH_OBJ_LAYER

/obj/machinery/atmospherics/components/unary/gasrig/fracking_input
	name = "AGR fracking gas input port"
	desc = "Input port for the AGR to intake fracking gas."
	icon = 'icons/obj/machines/gasrig.dmi'
	icon_state = "gasrig_port_2"
	layer = HIGH_OBJ_LAYER

/obj/machinery/atmospherics/components/unary/gasrig/gas_output
	name = "AGR gas output port"
	desc = "Main output for the AGR"
	icon = 'icons/obj/machines/gasrig.dmi'
	icon_state = "gasrig_port_3"
	layer = HIGH_OBJ_LAYER

/obj/machinery/atmospherics/components/unary/gasrig/gas_output/update_overlays()
	. = ..()
	if(!parent.active || (machine_stat & NOPOWER))
		return
	if(!parent.needs_repairs)
		. += mutable_appearance(initial(icon), "overlay_3")
		. += emissive_appearance(initial(icon), "overlay_3", layer)
	if(parent.mode == GASRIG_MODE_REPAIR)
		. += mutable_appearance(initial(icon), "overlay_3_broken")
		. += emissive_appearance(initial(icon), "overlay_3_broken", layer)

/obj/machinery/atmospherics/gasrig/dummy
	var/obj/machinery/atmospherics/gasrig/core/parent

/obj/machinery/atmospherics/gasrig/dummy/Initialize(mapload, obj/machinery/atmospherics/gasrig/core/gasrig, iconstate)
	. = ..()
	parent = gasrig
	icon_state = iconstate

/obj/machinery/atmospherics/gasrig/dummy/Destroy()
	if (parent)
		QDEL_NULL(parent)
	return ..()

/obj/machinery/atmospherics/gasrig/dummy/welder_act(mob/living/user, obj/item/tool)
	if(parent.welder_act(user, tool))
		return TRUE

/obj/machinery/atmospherics/gasrig/dummy/attackby(obj/item/I, mob/user, params)
	return parent.attackby(I, user, params)

/obj/machinery/atmospherics/gasrig/dummy/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosGasRig")
		ui.set_autoupdate(TRUE)
		ui.open()


/obj/machinery/atmospherics/gasrig/dummy/ui_data(mob/user)
	return parent.ui_data()

/obj/machinery/atmospherics/gasrig/dummy/ui_static_data(mob/user)
	return parent.ui_static_data(user)


/obj/machinery/atmospherics/gasrig/dummy/ui_act(action, params)
	. = ..()
	if(.)
		return
	parent.ui_act_base(action, params)

