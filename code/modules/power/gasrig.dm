/// Advanced Gas Rig defines

#define GASRIG_MAX_SHIELD_STRENGTH 10000
#define GASRIG_NATURAL_SHIELD_RECOVERY 1000

#define GASRIG_RETRACTOR_SPEED 10

#define GASRIG_MAX_DEPTH 1000
#define GASRIG_DEPTH_CHANGE_SPEED 10
#define GASRIG_DEPTH_SHIELD_DAMAGE_MULTIPLIER 3
#define GASRIG_SHIELD_MOL_LOG_MULTIPLER 1

#define GASRIG_MODE_NORMAL 1
#define GASRIG_MODE_REPAIR 2
#define GASRIG_MODE_OVERPRESSURE 3

#define GASRIG_DEPTH_TEMP_MULTIPLER 1
#define GASRIG_FRACKING_PRESSURE_MULTIPLER 1
#define GASRIG_DEFAULT_OUTPUT_PRESSURE 4500

#define GASRIG_MAX_HEALTH 100



/// Gas depths
/// Defines are ordered as (gas starting depth, gas ending depth, maximium production multipler)
#define GASRIG_O2 list(10, 250, 50)
#define GASRIG_N2 list(115, 400, 25)
#define GASRIG_PLAS list(300, 1000, 100)
#define GASRIG_CO2 list(330, 500, 15)
#define GASRIG_N2O list(700, 1000, 5)
#define GASRIG_NOB list(925, 1000, 100)

/obj/machinery/atmospherics/gasrig/core
	name = "\improper Advanced Gas Rig"
	desc = "This state-of-the-art gas mining rig will extend a collector down to the depths of atmosphere below to extract all the gases a station could need."
	icon = 'icons/obj/machines/gasrig.dmi'
	icon_state = "gasrig_1"
	use_power = IDLE_POWER_USE
	idle_power_usage = IDLE_POWER_USE
	layer = NUCLEAR_REACTOR_LAYER

	var/depth = 0

	var/set_depth = 0

	var/shield_strength = GASRIG_MAX_SHIELD_STRENGTH
	var/shield_strength_change = 0

	var/mode = GASRIG_MODE_NORMAL
	var/active = TRUE

	var/health = GASRIG_MAX_HEALTH
	var/needs_repairs = FALSE

	var/functional = TRUE

	var/display_efficiency = 1
	var/display_shield_efficiency = 0

	var/display_gas_power = 0
	var/display_gas_specific_heat = 0

	init_processing = TRUE

	var/obj/machinery/atmospherics/components/unary/gasrig/shielding_input/shielding_input

	var/obj/machinery/atmospherics/components/unary/gasrig/fracking_input/fracking_input

	var/obj/machinery/atmospherics/components/unary/gasrig/gas_output/gas_output

/obj/machinery/atmospherics/gasrig/core/proc/init_inputs()
	var/offset_loc = locate(x - 1, y, z)
	shielding_input = new/obj/machinery/atmospherics/components/unary/gasrig/shielding_input(offset_loc, TRUE)
	shielding_input.dir = WEST
	shielding_input.set_init_directions()
	offset_loc = locate(x + 1, y, z)
	fracking_input = new/obj/machinery/atmospherics/components/unary/gasrig/fracking_input(offset_loc, TRUE)
	fracking_input.dir = EAST
	fracking_input.set_init_directions()
	offset_loc = locate(x, y - 1, z)
	gas_output = new/obj/machinery/atmospherics/components/unary/gasrig/gas_output(offset_loc, TRUE)
	gas_output.dir = SOUTH
	gas_output.set_init_directions()

/obj/machinery/atmospherics/gasrig/core/Initialize(mapload)
	. = ..()
	init_inputs()
	update_pipenets()

/obj/machinery/atmospherics/gasrig/core/Destroy()
	shielding_input.Destroy()
	fracking_input.Destroy()
	gas_output.Destroy()
	STOP_PROCESSING(SSmachines, src)
	return ..()

/obj/machinery/atmospherics/gasrig/core/process(delta_time)
	if(!needs_repairs && active)
		produce_gases(gas_output.airs[1])
	get_shield_damage(shielding_input.airs[1])
	get_damage()
	approach_set_depth()
	update_pipenets()


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
	shield_strength_change = (depth * GASRIG_DEPTH_SHIELD_DAMAGE_MULTIPLIER) + temp_shield
	shield_strength = max(min(shield_strength + shield_strength_change, GASRIG_MAX_SHIELD_STRENGTH), 0)

/obj/machinery/atmospherics/gasrig/core/proc/produce_gases(datum/gas_mixture/air)
	var/efficiency = get_fracking_efficiency(fracking_input.airs[1])

	if (air.return_pressure() > get_output_pressure(efficiency))
		update_mode(GASRIG_MODE_OVERPRESSURE)
		return

	//produce_gases will never be called if repairs are needed
	update_mode(GASRIG_MODE_NORMAL)

	if(!functional)
		return
	if((depth >= GASRIG_O2[1]) && (depth <= GASRIG_O2[2]))
		calculate_gas_to_output(GASRIG_O2, /datum/gas/oxygen, air, efficiency)

	if((depth >= GASRIG_N2[1]) && (depth <= GASRIG_N2[2]))
		calculate_gas_to_output(GASRIG_N2, /datum/gas/nitrogen, air, efficiency)

	if((depth >= GASRIG_PLAS[1]) && (depth <= GASRIG_PLAS[2]))
		calculate_gas_to_output(GASRIG_PLAS, /datum/gas/plasma, air, efficiency)

	if((depth >= GASRIG_CO2[1]) && (depth <= GASRIG_CO2[2]))
		calculate_gas_to_output(GASRIG_CO2, /datum/gas/carbon_dioxide, air, efficiency)

	if((depth >= GASRIG_N2O[1]) && (depth <= GASRIG_N2O[2]))
		calculate_gas_to_output(GASRIG_N2O, /datum/gas/nitrous_oxide, air, efficiency)

	if((depth >= GASRIG_NOB[1]) && (depth <= GASRIG_NOB[2]))
		calculate_gas_to_output(GASRIG_NOB, /datum/gas/hypernoblium, air, efficiency)

/obj/machinery/atmospherics/gasrig/core/proc/get_fracking_efficiency(datum/gas_mixture/air)
	var/datum/gas_mixture/temp_air = new
	air.release_gas_to(temp_air, air.return_pressure() / 2, 1)
	var/temp_eff = log(10, (temp_air.return_pressure() * temp_air.total_moles()) + 10/* to prevent efficiency ever being below 1 */)
	display_efficiency = temp_eff
	return temp_eff

/obj/machinery/atmospherics/gasrig/core/proc/change_health(amount)
	health = max(min(health + amount, GASRIG_MAX_HEALTH), 0)


/obj/machinery/atmospherics/gasrig/core/proc/get_damage()
	if(shield_strength > 0)
		return

	change_health(-5)
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

/obj/machinery/atmospherics/gasrig/core/proc/update_mode(new_mode)
	if (mode == new_mode)
		return

	mode = new_mode
	switch(new_mode)
		if(GASRIG_MODE_NORMAL)
			functional = TRUE
			active = TRUE
		if(GASRIG_MODE_OVERPRESSURE)
			functional = FALSE
		if(GASRIG_MODE_REPAIR)
			needs_repairs = TRUE
			functional = FALSE
			active = FALSE

/obj/machinery/atmospherics/gasrig/core/welder_act(mob/living/user, obj/item/tool)
	if(health >= GASRIG_MAX_HEALTH)
		to_chat(user, span_notice("No repairs needed!"))
		return
	if(tool.use_tool(src, user, 0, volume=50, amount=2))
		change_health(10)

/obj/machinery/atmospherics/gasrig/core/attackby(obj/item/I, mob/user, params)
	if(!needs_repairs)
		to_chat(user, span_notice("No repairs needed!"))
		return
	if(istype(I, /obj/item/stack/sheet/plasteel))
		var/obj/item/stack/sheet/plasteel/PS = I
		if(PS.get_amount() >= 10)
			PS.use(10)
			to_chat(user, span_notice("You replace damaged plating."))
			playsound(src.loc, 'sound/machines/click.ogg', 75, 1)
			needs_repairs = FALSE
			update_mode(GASRIG_MODE_NORMAL)
			change_health(10)
			update_appearance()
		else
			to_chat(user, span_warning("You need 10 sheets of plasteel!"))
		return

/obj/machinery/atmospherics/gasrig/core/ui_state(mob/user)
	return GLOB.default_state

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
	data["needs_repairs"] = needs_repairs
	data["o2_constants"] = GASRIG_O2
	data["n2_constants"] = GASRIG_N2
	data["plas_constants"] = GASRIG_PLAS
	data["co2_constants"] = GASRIG_CO2
	data["n2o_constants"] = GASRIG_N2O
	data["nob_constants"] = GASRIG_NOB
	. =  data

/obj/machinery/atmospherics/gasrig/core/ui_act(action, params)
	if(..())
		return
	say(action)
	switch(action)
		if("set_depth")
			set_depth = text2num(params["set_depth"])
			. = TRUE
	update_icon()
		//log_gasrig(usr)

/obj/machinery/atmospherics/gasrig/core/proc/add_gas_to_output(var/datum/gas/to_add, var/datum/gas_mixture/air, amount, temp)
	var/datum/gas_mixture/merger = new
	merger.assert_gas(to_add)
	merger.gases[to_add][MOLES] = amount
	merger.temperature = temp
	air.merge(merger)

/obj/machinery/atmospherics/gasrig/core/proc/calculate_gas_to_output(gas_constant, gas_type, var/datum/gas_mixture/air, efficiency)
	var/difference = gas_constant[2] - gas_constant[1]
	var/percent_rising = ((depth - gas_constant[1]) / (difference/2))
	var/percent_falling = ((gas_constant[2] - depth) / (difference/2))

	add_gas_to_output(gas_type, air, gas_constant[3] * min(percent_falling, percent_rising) * efficiency, depth * GASRIG_DEPTH_TEMP_MULTIPLER)

/obj/machinery/atmospherics/gasrig/core/proc/update_pipenets()
	shielding_input.update_parents()
	fracking_input.update_parents()
	gas_output.update_parents()

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
