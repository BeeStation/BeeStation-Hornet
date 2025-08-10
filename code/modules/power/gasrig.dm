

/obj/machinery/atmospherics/gasrig/core
	name = "\improper Advanced Gas Rig"
	desc = "This state-of-the-art gas mining rig will extend a collector down to the depths of the atmosphere below to extract all the gases a station could need."
	icon = 'icons/obj/machines/gasrig.dmi'
	icon_state = "gasrig_1"
	/// Machine starts idle unless you want it to always start active
	use_power = IDLE_POWER_USE
	/// What we expend when NOT harvesting gasses
	idle_power_usage = 2 KILOWATT
	/// Power draw when harvesting gas (increases according to depth at Y x Depth / 200) (This will always be power usage at 200 depth)
	active_power_usage = 25 KILOWATT
	layer = NUCLEAR_REACTOR_LAYER
	resistance_flags = INDESTRUCTIBLE|ACID_PROOF|FIRE_PROOF
	density = TRUE

	var/depth = 0

	var/set_depth = 0	// wtf is this? what should we be checking depth or set_depth?
	var/shield_strength = GASRIG_MAX_SHIELD_STRENGTH
	var/shield_strength_change = 0

	var/mode = GASRIG_MODE_NORMAL
	var/active = TRUE
	var/overpressure = FALSE

	var/health = GASRIG_MAX_HEALTH
	var/needs_repairs = FALSE

	var/display_efficiency = 1
	var/display_shield_efficiency = 0

	var/display_gas_power = 0
	var/display_gas_specific_heat = 0

	init_processing = TRUE

	var/obj/machinery/atmospherics/components/unary/gasrig/shielding_input/shielding_input

	var/obj/machinery/atmospherics/components/unary/gasrig/fracking_input/fracking_input

	var/obj/machinery/atmospherics/components/unary/gasrig/gas_output/gas_output

	var/list/dummies = list()

/obj/machinery/atmospherics/gasrig/core/proc/init_inputs()
	var/offset_loc = locate(x - 1, y, z)
	shielding_input = new/obj/machinery/atmospherics/components/unary/gasrig/shielding_input(offset_loc, TRUE, src)
	shielding_input.dir = WEST
	shielding_input.set_init_directions()
	RegisterSignal(shielding_input, COMSIG_QDELETING, PROC_REF(kill_children))
	offset_loc = locate(x + 1, y, z)
	fracking_input = new/obj/machinery/atmospherics/components/unary/gasrig/fracking_input(offset_loc, TRUE, src)
	fracking_input.dir = EAST
	fracking_input.set_init_directions()
	RegisterSignal(fracking_input, COMSIG_QDELETING, PROC_REF(kill_children))
	offset_loc = locate(x, y - 1, z)
	gas_output = new/obj/machinery/atmospherics/components/unary/gasrig/gas_output(offset_loc, TRUE, src)
	gas_output.dir = SOUTH
	gas_output.set_init_directions()
	RegisterSignal(gas_output, COMSIG_QDELETING, PROC_REF(kill_children))

/obj/machinery/atmospherics/gasrig/core/proc/init_dummies()
	var/offset_loc = locate(x - 1, y + 1, z)
	dummies += new/obj/machinery/atmospherics/gasrig/dummy(offset_loc, src, "gasrig_d1")
	offset_loc = locate(x, y + 1, z)
	dummies += new/obj/machinery/atmospherics/gasrig/dummy(offset_loc, src, "gasrig_d2")
	offset_loc = locate(x + 1, y + 1, z)
	dummies += new/obj/machinery/atmospherics/gasrig/dummy(offset_loc, src, "gasrig_d3")
	offset_loc = locate(x - 1, y - 1, z)

	for(var/obj/machinery/atmospherics/gasrig/dummy/dummy in dummies)
		dummy.layer = ABOVE_MOB_LAYER

	dummies += new/obj/machinery/atmospherics/gasrig/dummy(offset_loc, src, "gasrig_d4")
	offset_loc = locate(x + 1, y - 1, z)
	dummies += new/obj/machinery/atmospherics/gasrig/dummy(offset_loc, src, "gasrig_d5")

	for(var/obj/machinery/atmospherics/gasrig/dummy/dummy in dummies)
		RegisterSignal(dummy, COMSIG_QDELETING, PROC_REF(kill_children))


/obj/machinery/atmospherics/gasrig/core/Initialize(mapload)
	. = ..()
	init_inputs()
	init_dummies()
	update_pipenets()

/obj/machinery/atmospherics/gasrig/core/proc/kill_children()
	Destroy()

/obj/machinery/atmospherics/gasrig/core/Destroy()
	shielding_input.Destroy()
	fracking_input.Destroy()
	gas_output.Destroy()
	for(var/obj/machinery/atmospherics/gasrig/dummy/dummy in dummies)
		dummy.Destroy()
	STOP_PROCESSING(SSmachines, src)
	return ..()

/obj/machinery/atmospherics/gasrig/core/process(delta_time)	// Machine operation is here
	get_shield_damage(shielding_input.airs[1])
	get_damage(delta_time)
	if(machine_stat & NOPOWER)
		update_pipenets()
		return
	if(!active)
		update_use_power(IDLE_POWER_USE) // We're not fraking yet so power consumption is IDLE
	if(!needs_repairs && active)
		update_use_power(ACTIVE_POWER_USE)
		produce_gases(gas_output.airs[1])
	if(needs_repairs && active)	// I assume this is air leak you should comment this and explain it
		produce_gases(src.loc.return_air())
		src.air_update_turf(FALSE, FALSE)
	approach_set_depth()
	update_pipenets()

/obj/machinery/atmospherics/gasrig/core/examine(mob/user)
	. = ..()
	if(needs_repairs)
		. += span_warning("Some components have been damaged beyond repair. Use plasteel sheets to replace them.")
	if(health < GASRIG_MAX_HEALTH)
		. += "It is damaged. Use a welder to repair it."
	if(overpressure)
		. += "Maximum output pressure exceeded."

/obj/machinery/atmospherics/gasrig/core/proc/get_shield_damage(datum/gas_mixture/air)
	var/datum/gas_mixture/temp_air = new
	air.pump_gas_to(temp_air, 4500)
	var/gas_power = 0 //Gases with no gas power dont provide much for shielding
	var/specific_heat = 0 //To encourage balancing a mix rather then just getting the gas with the most gas power
	var/total_moles = 1 //so the log doesnt start negative
	for (var/datum/gas/gas_id as anything in temp_air.gases)
		gas_power += initial(gas_id.fusion_power)*temp_air.gases[gas_id][MOLES]
		specific_heat += initial(gas_id.specific_heat)*temp_air.gases[gas_id][MOLES]
		total_moles += temp_air.gases[gas_id][MOLES]

	var/aver_gas_power = 0
	var/aver_specific_heat = 0

	if (total_moles > 0)
		aver_gas_power = gas_power / total_moles
		aver_specific_heat = specific_heat / total_moles

	display_gas_power = aver_gas_power
	display_gas_specific_heat = aver_specific_heat

	var/temp_shield = (((aver_gas_power + 1) * aver_specific_heat) * log(10, total_moles * GASRIG_SHIELD_MOL_LOG_MULTIPLER)) + GASRIG_NATURAL_SHIELD_RECOVERY
	display_shield_efficiency = temp_shield
	shield_strength_change = temp_shield - (get_depth() * GASRIG_DEPTH_SHIELD_DAMAGE_MULTIPLIER)
	shield_strength = max(min(shield_strength + shield_strength_change, GASRIG_MAX_SHIELD_STRENGTH), 0)

/obj/machinery/atmospherics/gasrig/core/proc/produce_gases(datum/gas_mixture/air)
	var/efficiency = get_fracking_efficiency(fracking_input.airs[1])
	var/temp_depth = get_depth()

	if (air.return_pressure() > get_output_pressure(efficiency))
		overpressure = TRUE
		return
	overpressure = FALSE
	calculate_power_use()
	if((temp_depth >= GASRIG_O2[1]) && (temp_depth <= GASRIG_O2[2]))
		calculate_gas_to_output(GASRIG_O2, /datum/gas/oxygen, air, efficiency)

	if((temp_depth >= GASRIG_N2[1]) && (temp_depth <= GASRIG_N2[2]))
		calculate_gas_to_output(GASRIG_N2, /datum/gas/nitrogen, air, efficiency)

	if((temp_depth >= GASRIG_PLAS[1]) && (temp_depth <= GASRIG_PLAS[2]))
		calculate_gas_to_output(GASRIG_PLAS, /datum/gas/plasma, air, efficiency)

	if((temp_depth >= GASRIG_CO2[1]) && (temp_depth <= GASRIG_CO2[2]))
		calculate_gas_to_output(GASRIG_CO2, /datum/gas/carbon_dioxide, air, efficiency)

	if((temp_depth >= GASRIG_N2O[1]) && (temp_depth <= GASRIG_N2O[2]))
		calculate_gas_to_output(GASRIG_N2O, /datum/gas/nitrous_oxide, air, efficiency)

	if((temp_depth >= GASRIG_NOB[1]) && (temp_depth <= GASRIG_NOB[2]))
		calculate_gas_to_output(GASRIG_NOB, /datum/gas/hypernoblium, air, efficiency)

/obj/machinery/atmospherics/gasrig/core/proc/calculate_power_use()
	var/depth = get_depth()
	active_power_usage = initial(active_power_usage) * (depth / 200) // 100 depth is 12.5 kW/s 200 depth is 25 300 is 37.5, 1000 is 125 kW.

/obj/machinery/atmospherics/gasrig/core/proc/get_fracking_efficiency(datum/gas_mixture/air)
	var/datum/gas_mixture/temp_air = new
	air.release_gas_to(temp_air, air.return_pressure() / 2, 1)
	var/temp_eff = log(10, (temp_air.return_pressure() * temp_air.total_moles()) + 10/* to prevent efficiency ever being below 1 */)
	display_efficiency = temp_eff
	return temp_eff

/obj/machinery/atmospherics/gasrig/core/proc/change_health(amount)
	health = max(min(health + amount, GASRIG_MAX_HEALTH), 0)


/obj/machinery/atmospherics/gasrig/core/proc/get_damage(delta_time)
	if(shield_strength > 0)
		return

	change_health(-5)

	if(!needs_repairs)
		if(DT_PROB(50, delta_time))
			playsound(src.loc, 'sound/machines/apc/PowerSwitch_Cover.ogg', 75, 1)
	if (health <= 0)
		update_mode(GASRIG_MODE_REPAIR)


/obj/machinery/atmospherics/gasrig/core/proc/get_output_pressure(fracking_efficiency)
	return max(GASRIG_DEFAULT_OUTPUT_PRESSURE, fracking_efficiency * GASRIG_FRACKING_PRESSURE_MULTIPLER)

/obj/machinery/atmospherics/gasrig/core/proc/approach_set_depth()
	var/temp_depth = get_depth()
	if (temp_depth != set_depth)
		if ((temp_depth < set_depth) && !needs_repairs)
			depth += min(GASRIG_DEPTH_CHANGE_SPEED, set_depth - temp_depth)
		if (temp_depth > set_depth)
			depth += max(-GASRIG_DEPTH_CHANGE_SPEED, set_depth - temp_depth)


//for potential station altitude updates.
/obj/machinery/atmospherics/gasrig/core/proc/get_depth()
	return depth

// We have a proc for this called update_icon, update_appearance() calls that and update_overlays() no need for this
// Do it on update_icon, then when you would call this call update_appearance instead
/obj/machinery/atmospherics/gasrig/core/proc/get_new_icon()
	switch(mode)
		if(GASRIG_MODE_NORMAL)
			if(active)
				icon_state = "gasrig_1"
				gas_output.icon_state = "gasrig_port_3"
				return
		if(GASRIG_MODE_REPAIR)
			if(active)
				icon_state = "gasrig_1_broken"
				gas_output.icon_state = "gasrig_port_3_broken"
				return
	icon_state = "gasrig_1_off"
	gas_output.icon_state = "gasrig_port_3_off"
	update_appearance()
	gas_output.update_appearance()


/obj/machinery/atmospherics/gasrig/core/proc/update_mode(new_mode)
	if (mode == new_mode)
		return

	mode = new_mode
	switch(new_mode)
		if(GASRIG_MODE_NORMAL)
			get_new_icon()
		if(GASRIG_MODE_REPAIR)
			//here so it only plays once
			playsound(src.loc, 'sound/weapons/blastcannon.ogg', 100)
			playsound(src.loc, 'sound/machines/hiss.ogg', 50)
			get_new_icon()
			needs_repairs = TRUE

/obj/machinery/atmospherics/gasrig/core/welder_act(mob/living/user, obj/item/tool)
	if(health >= GASRIG_MAX_HEALTH)
		balloon_alert(user, "No repairs needed!")
		return
	if(get_depth() > 0)
		balloon_alert(user, "The rig needs to be raised to repair it!")
		return
	if(needs_repairs)
		balloon_alert(user, "Repair with plasteel first!")
		return
	if(tool.use_tool(src, user, 0, volume=50, amount=2))
		change_health(10)
		balloon_alert(user, "You repair the rig's damage!")

/obj/machinery/atmospherics/gasrig/core/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/sheet/plasteel))
		var/obj/item/stack/sheet/plasteel/PS = I
		if(!needs_repairs)
			balloon_alert(user, "No repairs needed!")
			return
		if(get_depth() > 0)
			balloon_alert(user, "The rig needs to be raised to repair it!")
			return
		if(PS.get_amount() >= 10)
			PS.use(10)
			balloon_alert(user, "You replace damaged plating.")
			playsound(src.loc, 'sound/machines/click.ogg', 75, 1)
			needs_repairs = FALSE
			update_mode(GASRIG_MODE_NORMAL)
			change_health(10)
			update_appearance()
		else
			balloon_alert(user, "You need 10 sheets of plasteel!")

/obj/machinery/atmospherics/gasrig/core/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosGasRig")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/atmospherics/gasrig/core/ui_data()
	var/data = list()
	data["depth"] = depth
	data["set_depth"] = set_depth
	data["max_depth"] = GASRIG_MAX_DEPTH
	data["shield_strength"] = shield_strength
	data["shield_strength_change"] = shield_strength_change
	data["max_shield"] = GASRIG_MAX_SHIELD_STRENGTH
	data["fracking_eff"] = display_efficiency
	data["shield_eff"] = display_shield_efficiency
	data["gas_power"] = display_gas_power
	data["specific_heat"] = display_gas_specific_heat
	data["max_health"] = GASRIG_MAX_HEALTH
	data["health"] = health
	data["active"] = active
	data["needs_repairs"] = needs_repairs
	data["over_pressure"] = overpressure
	data["o2_constants"] = GASRIG_O2
	data["n2_constants"] = GASRIG_N2
	data["plas_constants"] = GASRIG_PLAS
	data["co2_constants"] = GASRIG_CO2
	data["n2o_constants"] = GASRIG_N2O
	data["nob_constants"] = GASRIG_NOB
	return data

/obj/machinery/atmospherics/gasrig/core/ui_act(action, params)
	if(..())
		return
	ui_act_base(action, params)


/obj/machinery/atmospherics/gasrig/core/proc/ui_act_base(action, params)
	switch(action)
		if("set_depth")
			set_depth = text2num(params["set_depth"])
			. = TRUE
		if("active")
			active = !active
			. = TRUE
	get_new_icon()
		//log_gasrig(usr)

/obj/machinery/atmospherics/gasrig/core/proc/add_gas_to_output(var/datum/gas/to_add, var/datum/gas_mixture/air, amount, temp)
	var/datum/gas_mixture/merger = new
	merger.assert_gas(to_add)
	merger.gases[to_add][MOLES] = amount
	merger.temperature = temp
	air.merge(merger)

/obj/machinery/atmospherics/gasrig/core/proc/calculate_gas_to_output(gas_constant, gas_type, var/datum/gas_mixture/air, efficiency)
	var/difference = gas_constant[2] - gas_constant[1]
	var/percent_rising = ((get_depth() - gas_constant[1]) / (difference/2))
	var/percent_falling = ((gas_constant[2] - get_depth()) / (difference/2))

	add_gas_to_output(gas_type, air, gas_constant[3] * min(percent_falling, percent_rising) * efficiency, depth * GASRIG_DEPTH_TEMP_MULTIPLER)

/obj/machinery/atmospherics/gasrig/core/proc/update_pipenets()
	shielding_input.update_parents()
	fracking_input.update_parents()
	gas_output.update_parents()

/obj/machinery/atmospherics/components/unary/gasrig/
	resistance_flags = INDESTRUCTIBLE|ACID_PROOF|FIRE_PROOF
	density = TRUE
	var/obj/machinery/atmospherics/gasrig/core/parent

/obj/machinery/atmospherics/components/unary/gasrig/New(loc, booled, var/obj/machinery/atmospherics/gasrig/core/C)
	..(loc, booled)
	parent = C

/obj/machinery/atmospherics/components/unary/gasrig/welder_act(mob/living/user, obj/item/tool)
	parent.welder_act(user, tool)

/obj/machinery/atmospherics/components/unary/gasrig/attackby(obj/item/I, mob/user, params)
	parent.attackby(I, user, params)

/obj/machinery/atmospherics/components/unary/gasrig/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosGasRig")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/atmospherics/components/unary/gasrig/ui_act(action, params)
	if(..())
		return
	parent.ui_act_base(action, params)

/obj/machinery/atmospherics/components/unary/gasrig/ui_data()
	return parent.ui_data()

/obj/machinery/atmospherics/components/unary/gasrig/shielding_input
	name = "AGR shield gas input port"
	desc = "Input port for the AGR to intake shielding gas."
	icon = 'icons/obj/machines/gasrig.dmi'
	icon_state = "gasrig_port_1"
	layer = LOW_OBJ_LAYER

/obj/machinery/atmospherics/components/unary/gasrig/fracking_input
	name = "AGR fracking gas input port"
	desc = "Input port for the AGR to intake fracking gas."
	icon = 'icons/obj/machines/gasrig.dmi'
	icon_state = "gasrig_port_2"
	layer = LOW_OBJ_LAYER

/obj/machinery/atmospherics/components/unary/gasrig/gas_output
	name = "AGR gas output port"
	desc = "Main output for the AGR"
	icon = 'icons/obj/machines/gasrig.dmi'
	icon_state = "gasrig_port_3"
	layer = LOW_OBJ_LAYER

/obj/machinery/atmospherics/gasrig/dummy
	name = "\improper Advanced Gas Rig"
	desc = "This state-of-the-art gas mining rig will extend a collector down to the depths of the atmosphere below to extract all the gases a station could need."
	icon = 'icons/obj/machines/gasrig.dmi'
	layer = LOW_OBJ_LAYER
	var/obj/machinery/atmospherics/gasrig/core/parent

/obj/machinery/atmospherics/gasrig/dummy/New(loc, var/obj/machinery/atmospherics/gasrig/core/gasrig, iconstate)
	..(loc)
	parent = gasrig
	icon_state = iconstate

/obj/machinery/atmospherics/gasrig/dummy/welder_act(mob/living/user, obj/item/tool)
	parent.welder_act(user, tool)

/obj/machinery/atmospherics/gasrig/dummy/attackby(obj/item/I, mob/user, params)
	parent.attackby(I, user, params)

/obj/machinery/atmospherics/gasrig/dummy/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosGasRig")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/atmospherics/gasrig/dummy/ui_data()
	return parent.ui_data()

/obj/machinery/atmospherics/gasrig/dummy/ui_act(action, params)
	if(..())
		return
	parent.ui_act_base(action, params)

