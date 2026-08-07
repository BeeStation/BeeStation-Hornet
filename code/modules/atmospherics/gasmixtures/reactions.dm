//Most other defines used in reactions are located in ..\__DEFINES\reactions.dm
#define SET_REACTION_RESULTS(amount) air.reaction_results[type] = amount

/proc/init_gas_reactions()
	var/list/priority_reactions = list()

	//Builds a list of gas id to reaction group
	for(var/gas_id in GLOB.meta_gas_info[META_GAS_ID])
		priority_reactions[gas_id] = list(
			/* PRIORITY_PRE_FORMATION = */ list(),
			/* PRIORITY_FORMATION = */ list(),
			/* PRIORITY_POST_FORMATION = */ list(),
			/* PRIORITY_FIRE = */ list()
		)

	for(var/datum/gas_reaction/reaction as anything in subtypesof(/datum/gas_reaction))
		if(initial(reaction.exclude))
			continue
		reaction = new reaction
		var/datum/gas/reaction_key
		for (var/req in reaction.requirements)
			if (ispath(req))
				var/datum/gas/req_gas = req
				if (!reaction_key || initial(reaction_key.rarity) > initial(req_gas.rarity))
					reaction_key = req_gas
		reaction.major_gas = reaction_key
		priority_reactions[reaction_key][reaction.priority_group] += reaction

	//Culls empty gases
	for(var/gas_id in GLOB.meta_gas_info[META_GAS_ID])
		var/passed = FALSE
		for(var/list/priority_grouping in priority_reactions[gas_id])
			if(length(priority_grouping))
				passed = TRUE
				break
		if(passed)
			continue
		priority_reactions[gas_id] = null

	return priority_reactions

/datum/gas_reaction
	/**
	 * Regarding the requirements list: the minimum or maximum requirements must be non-zero.
	 * When in doubt, use MINIMUM_MOLE_COUNT.
	 * Another thing to note is that reactions will not fire if we have any requirements outside of gas id path or MIN_TEMP or MAX_TEMP.
	 * More complex implementations will require modifications to gas_mixture.react()
	 */
	var/list/requirements
	var/major_gas //the highest rarity gas used in the reaction.
	var/exclude = FALSE //do it this way to allow for addition/removal of reactions midmatch in the future
	///The priority group this reaction is a part of. You can think of these as processing in batches, put your reaction into the one that's most fitting
	var/priority_group
	var/name = "reaction"
	var/id = "r"
	/// Whether the presence of our reaction should make fires bigger or not.
	var/expands_hotspot = FALSE
	/// A short string describing this reaction.
	var/desc
	/** REACTION FACTORS
	 *
	 * Describe (to a human) factors influencing this reaction in an assoc list format.
	 * Also include gases formed by the reaction
	 * Implement various interaction for different keys under subsystem/air/proc/atmos_handbook_init()
	 *
	 * E.G.
	 * factor["Temperature"] = "Minimum temperature of 20 kelvins, maximum temperature of 100 kelvins"
	 * factor[GAS_O2] = "Minimum oxygen amount of 20 moles, more oxygen increases reaction rate up to 150 moles"
	 */
	var/list/factor

/datum/gas_reaction/New()
	init_reqs()
	init_factors()

/datum/gas_reaction/proc/init_reqs() // Override this
	CRASH("Reaction [type] made without specifying requirements.")

/datum/gas_reaction/proc/init_factors()

/datum/gas_reaction/proc/react(datum/gas_mixture/air, atom/location)
	return NO_REACTION


/**
 * Steam Condensation/Deposition:
 *
 * Makes turfs slippery.
 * Can frost things if the gas is cold enough.
 */
/datum/gas_reaction/water_vapor
	priority_group = PRIORITY_POST_FORMATION
	name = "Water Vapor Condensation"
	id = "vapor"
	desc = "Water vapor condensation that can make things slippery."

/datum/gas_reaction/water_vapor/init_reqs()
	requirements = list(
		/datum/gas/water_vapor = MOLES_GAS_VISIBLE,
		"MAX_TEMP" = WATER_VAPOR_CONDENSATION_POINT,
	)

/datum/gas_reaction/water_vapor/react(datum/gas_mixture/air, datum/holder)
	. = NO_REACTION
	if(!isturf(holder))
		return

	var/turf/open/location = holder
	var/consumed = 0
	switch(air.temperature)
		if(-INFINITY to WATER_VAPOR_DEPOSITION_POINT)
			if(location?.freeze_turf())
				consumed = MOLES_GAS_VISIBLE
			var/datum/component/wet_floor/wet_floor = location?.GetComponent(/datum/component/wet_floor)
			if(wet_floor && wet_floor.highest_strength == TURF_WET_PERMAFROST)
				. |= VOLATILE_REACTION
		if(WATER_VAPOR_DEPOSITION_POINT to WATER_VAPOR_CONDENSATION_POINT)
			if(!isgroundlessturf(location))
				location.water_vapor_gas_act()
			consumed = MOLES_GAS_VISIBLE

	if(consumed)
		air.moles[/datum/gas/water_vapor] -= consumed
		SET_REACTION_RESULTS(consumed)
		. |= REACTING

// Fire:

/**
 * Plasma combustion:
 *
 * Combustion of oxygen and plasma (mostly treated as hydrocarbons).
 * The reaction rate is dependent on the temperature of the gasmix.
 * May produce either tritium or carbon dioxide and water vapor depending on the fuel/oxydizer ratio of the gasmix.
 */
/datum/gas_reaction/plasmafire
	priority_group = PRIORITY_FIRE
	name = "Plasma Combustion"
	id = "plasmafire"
	expands_hotspot = TRUE
	desc = "Combustion of oxygen and plasma. Able to produce tritium or carbon dioxade and water vapor."

/datum/gas_reaction/plasmafire/init_reqs()
	requirements = list(
		/datum/gas/plasma = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = PLASMA_MINIMUM_BURN_TEMPERATURE,
	)

/datum/gas_reaction/plasmafire/react(datum/gas_mixture/air, datum/holder)
	. = NO_REACTION
	// This reaction should proceed faster at higher temperatures.
	var/temperature = air.temperature
	var/temperature_scale = 0
	if(temperature > PLASMA_UPPER_TEMPERATURE)
		temperature_scale = 1
	else
		temperature_scale = (temperature - PLASMA_MINIMUM_BURN_TEMPERATURE) / (PLASMA_UPPER_TEMPERATURE-PLASMA_MINIMUM_BURN_TEMPERATURE)
		if(temperature_scale <= 0)
			return

	var/oxygen_burn_ratio = OXYGEN_BURN_RATIO_BASE - temperature_scale
	var/plasma_burn_rate = 0
	var/super_saturation = FALSE // Whether we should make tritium.
	var/list/cached_moles = air.moles //this speeds things up because accessing datum vars is slow
	var/oxygen_moles = cached_moles[/datum/gas/oxygen]
	var/plasma_moles = cached_moles[/datum/gas/plasma]
	switch(oxygen_moles / plasma_moles)
		if(SUPER_SATURATION_THRESHOLD to INFINITY)
			plasma_burn_rate = (plasma_moles / PLASMA_BURN_RATE_DELTA) * temperature_scale
			super_saturation = TRUE // Begin to form tritium
		if(PLASMA_OXYGEN_FULLBURN to SUPER_SATURATION_THRESHOLD)
			plasma_burn_rate = (plasma_moles / PLASMA_BURN_RATE_DELTA) * temperature_scale
		else
			plasma_burn_rate = ((oxygen_moles / PLASMA_OXYGEN_FULLBURN) / PLASMA_BURN_RATE_DELTA) * temperature_scale

	if(plasma_burn_rate < MINIMUM_HEAT_CAPACITY)
		return

	var/old_heat_capacity = air.heat_capacity()
	plasma_burn_rate = min(plasma_burn_rate, plasma_moles, oxygen_moles * INVERSE(oxygen_burn_ratio)) //Ensures matter is conserved properly
	cached_moles[/datum/gas/plasma] = QUANTIZE(plasma_moles - plasma_burn_rate)
	cached_moles[/datum/gas/oxygen] = QUANTIZE(oxygen_moles - (plasma_burn_rate * oxygen_burn_ratio))
	if(super_saturation)
		cached_moles[/datum/gas/tritium] += plasma_burn_rate
	else
		cached_moles[/datum/gas/carbon_dioxide] += plasma_burn_rate * 0.75
		cached_moles[/datum/gas/water_vapor] += plasma_burn_rate * 0.25


	SET_REACTION_RESULTS((plasma_burn_rate) * (1 + oxygen_burn_ratio))
	var/energy_released = FIRE_PLASMA_ENERGY_RELEASED * plasma_burn_rate
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = (temperature * old_heat_capacity + energy_released) / new_heat_capacity

	// Let the floor know a fire is happening
	var/turf/open/location = holder
	if(istype(location))
		temperature = air.temperature
		if(temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			location.hotspot_expose(temperature, CELL_VOLUME)

	. |= REACTING | VOLATILE_REACTION

/**
 * Tritium combustion:
 *
 * Combustion of oxygen and tritium (treated as hydrogen).
 * Highly exothermic.
 * Creates hotspots.
 * Creates radiation.
 */
/datum/gas_reaction/tritfire
	priority_group = PRIORITY_FIRE
	name = "Tritium Combustion"
	id = "tritfire"
	expands_hotspot = TRUE
	desc = "Combustion of tritium with oxygen. Can be extremely fast and energetic if a few conditions are fulfilled."

/datum/gas_reaction/tritfire/init_reqs()
	requirements = list(
		/datum/gas/tritium = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = TRITIUM_MINIMUM_BURN_TEMPERATURE,
	)

/datum/gas_reaction/tritfire/react(datum/gas_mixture/air, datum/holder)
	. = NO_REACTION
	var/list/cached_moles = air.moles //this speeds things up because accessing datum vars is slow
	var/tritium_moles = cached_moles[/datum/gas/tritium]
	var/oxygen_moles = cached_moles[/datum/gas/oxygen]
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/temperature = air.temperature
	var/burned_fuel = 0

	if(oxygen_moles < tritium_moles || MINIMUM_TRIT_OXYBURN_ENERGY > (temperature * old_heat_capacity))// Yogs -- Maybe a tiny performance boost? I'unno
		burned_fuel = oxygen_moles / TRITIUM_BURN_OXY_FACTOR
		if(burned_fuel > tritium_moles)
			burned_fuel = tritium_moles //Yogs -- prevents negative moles of Tritium
		cached_moles[/datum/gas/tritium] -= burned_fuel
	else
		burned_fuel = tritium_moles // Yogs -- Conservation of Mass fix
		cached_moles[/datum/gas/tritium] *= (1 - 1 / TRITIUM_OXYGEN_FULLBURN) // Yogs -- Maybe a tiny performance boost? I'unno
		cached_moles[/datum/gas/oxygen] -= cached_moles[/datum/gas/tritium]
		energy_released += (FIRE_TRITIUM_ENERGY_RELEASED * burned_fuel * (TRITIUM_OXYGEN_FULLBURN - 1)) // Yogs -- Fixes low-energy tritium fires

	cached_moles[/datum/gas/water_vapor] += burned_fuel

	SET_REACTION_RESULTS(burned_fuel)

	var/turf/open/location
	if(istype(holder, /datum/pipenet)) //Find the tile the reaction is occurring on, or a random part of the network if it's a pipenet.
		var/datum/pipenet/pipenet = holder
		location = pick(pipenet.members)
	else if(isatom(holder))
		location = holder

	energy_released += FIRE_TRITIUM_ENERGY_RELEASED * burned_fuel
	if(location && burned_fuel > TRITIUM_RADIATION_MINIMUM_MOLES && energy_released > TRITIUM_RADIATION_RELEASE_THRESHOLD * (air.volume / CELL_VOLUME) ** ATMOS_RADIATION_VOLUME_EXP && prob(10))
		radiation_pulse(location, max_range = min(sqrt(burned_fuel) / TRITIUM_RADIATION_RANGE_DIVISOR, GAS_REACTION_MAXIMUM_RADIATION_PULSE_RANGE), threshold = TRITIUM_RADIATION_THRESHOLD, intensity = 1)

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = (temperature * old_heat_capacity + energy_released) / new_heat_capacity

	//let the floor know a fire is happening
	if(istype(location))
		temperature = air.temperature
		if(temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			location.hotspot_expose(temperature, CELL_VOLUME)

	if(burned_fuel)
		. |= REACTING | VOLATILE_REACTION

// N2O

/**
 * Nitrous oxide Formation:
 *
 * Formation of N2O.
 * Endothermic.
 * Requires BZ as a catalyst.
 */
/datum/gas_reaction/nitrousformation //formation of n2o, exothermic, requires bz as catalyst
	priority_group = PRIORITY_FORMATION
	name = "Nitrous Oxide Formation"
	id = "nitrousformation"
	desc = "Production of nitrous oxide with BZ as a catalyst."

/datum/gas_reaction/nitrousformation/init_reqs()
	requirements = list(
		/datum/gas/oxygen = 10,
		/datum/gas/nitrogen = 20,
		/datum/gas/bz = 5,
		"MIN_TEMP" = N2O_FORMATION_MIN_TEMPERATURE,
		"MAX_TEMP" = N2O_FORMATION_MAX_TEMPERATURE,
	)

/datum/gas_reaction/nitrousformation/react(datum/gas_mixture/air)
	var/list/cached_moles = air.moles
	var/oxygen_moles = cached_moles[/datum/gas/oxygen]
	var/nitrogen_moles = cached_moles[/datum/gas/nitrogen]
	var/heat_efficiency = min(oxygen_moles * INVERSE(0.5), nitrogen_moles)
	if ((oxygen_moles - heat_efficiency * 0.5 < 0 ) || (nitrogen_moles - heat_efficiency < 0))
		return NO_REACTION // Shouldn't produce gas from nothing.

	var/old_heat_capacity = air.heat_capacity()
	cached_moles[/datum/gas/oxygen] -= heat_efficiency * 0.5
	cached_moles[/datum/gas/nitrogen] -= heat_efficiency
	cached_moles[/datum/gas/nitrous_oxide] += heat_efficiency

	SET_REACTION_RESULTS(heat_efficiency)
	var/energy_released = heat_efficiency * N2O_FORMATION_ENERGY
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((air.temperature * old_heat_capacity + energy_released) / new_heat_capacity), TCMB) // The air cools down when reacting.
	return REACTING


/**
 * Nitrous Oxide Decomposition
 *
 * Decomposition of N2O.
 * Exothermic.
 */
/datum/gas_reaction/nitrous_decomp
	priority_group = PRIORITY_POST_FORMATION
	name = "Nitrous Oxide Decomposition"
	id = "nitrous_decomp"
	desc = "Decomposition of nitrous oxide under high temperature."

/datum/gas_reaction/nitrous_decomp/init_reqs()
	requirements = list(
		/datum/gas/nitrous_oxide = MINIMUM_MOLE_COUNT * 2,
		"MIN_TEMP" = N2O_DECOMPOSITION_MIN_TEMPERATURE,
		"MAX_TEMP" = N2O_DECOMPOSITION_MAX_TEMPERATURE,
	)

/datum/gas_reaction/nitrous_decomp/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_moles = air.moles //this speeds things up because accessing datum vars is slow
	var/nitrous_oxide_moles = cached_moles[/datum/gas/nitrous_oxide]
	var/temperature = air.temperature
	var/burned_fuel = (nitrous_oxide_moles / N2O_DECOMPOSITION_RATE_DIVISOR) * ((temperature - N2O_DECOMPOSITION_MIN_SCALE_TEMP) * (temperature - N2O_DECOMPOSITION_MAX_SCALE_TEMP) / (N2O_DECOMPOSITION_SCALE_DIVISOR))
	if(burned_fuel <= 0 || nitrous_oxide_moles - burned_fuel < 0)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	cached_moles[/datum/gas/nitrous_oxide] -= burned_fuel
	cached_moles[/datum/gas/nitrogen] += burned_fuel
	cached_moles[/datum/gas/oxygen] += burned_fuel / 2

	SET_REACTION_RESULTS(burned_fuel)
	var/energy_released = N2O_DECOMPOSITION_ENERGY * burned_fuel
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = (temperature * old_heat_capacity + energy_released) / new_heat_capacity
	. |= REACTING


// BZ

/**
 * BZ Formation
 *
 * Formation of BZ by combining plasma and nitrous oxide at low pressures.
 * Exothermic.
 */
/datum/gas_reaction/bzformation
	priority_group = PRIORITY_FORMATION
	name = "BZ Gas Formation"
	id = "bzformation"
	desc = "Production of BZ using plasma and nitrous oxide."

/datum/gas_reaction/bzformation/init_reqs()
	requirements = list(
		/datum/gas/nitrous_oxide = 10,
		/datum/gas/plasma = 10,
		"MAX_TEMP" = BZ_FORMATION_MAX_TEMPERATURE,
	)

/datum/gas_reaction/bzformation/react(datum/gas_mixture/air)
	var/list/cached_moles = air.moles
	var/nitrous_oxide_moles = cached_moles[/datum/gas/nitrous_oxide]
	var/plasma_moles = cached_moles[/datum/gas/plasma]
	var/pressure = air.return_pressure()
	var/volume = air.return_volume()
	var/environment_effciency = volume/pressure		//More volume and less pressure gives better rates
	var/ratio_efficency = min(nitrous_oxide_moles/plasma_moles, 1)  //Less n2o than plasma give lower rates
	var/nitrous_oxide_decomposed_factor = max(4 * (plasma_moles / (nitrous_oxide_moles + plasma_moles) - 0.75), 0) // Nitrous oxide decomposes when there are more than 3 parts plasma per n2o.
	var/bz_formed = min(0.01 * ratio_efficency * environment_effciency, nitrous_oxide_moles * INVERSE(0.4), plasma_moles * INVERSE(0.8 * (1 - nitrous_oxide_decomposed_factor)))

	if (nitrous_oxide_moles - bz_formed * 0.4 < 0  || plasma_moles - 0.8 * bz_formed * (1 - nitrous_oxide_decomposed_factor) < 0 || bz_formed <= 0)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()

	/**
	*If n2o-plasma ratio is less than 1:3 start decomposing n2o.
	*Rate of decomposition vs BZ production increases as n2o concentration gets lower
	*Plasma acts as a catalyst on decomposition, so it doesn't get consumed in the process.
	*N2O decomposes with its normal decomposition energy
	*/
	if (nitrous_oxide_decomposed_factor>0)
		var/amount_decomposed = 0.4 * bz_formed * nitrous_oxide_decomposed_factor
		cached_moles[/datum/gas/nitrogen] += amount_decomposed
		cached_moles[/datum/gas/oxygen] += 0.5 * amount_decomposed

	cached_moles[/datum/gas/bz] += bz_formed * (1-nitrous_oxide_decomposed_factor)
	cached_moles[/datum/gas/nitrous_oxide] -= 0.4 * bz_formed
	cached_moles[/datum/gas/plasma] -= 0.8 * bz_formed * (1-nitrous_oxide_decomposed_factor)

	SET_REACTION_RESULTS(bz_formed)
	var/energy_released = bz_formed * (BZ_FORMATION_ENERGY + nitrous_oxide_decomposed_factor * (N2O_DECOMPOSITION_ENERGY - BZ_FORMATION_ENERGY))
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((air.temperature * old_heat_capacity + energy_released) / new_heat_capacity), TCMB)
	return REACTING


// Pluoxium

/**
 * Pluoxium Formation:
 *
 * Consumes a tiny amount of tritium to convert CO2 and oxygen to pluoxium.
 * Exothermic.
 */
/datum/gas_reaction/pluox_formation
	priority_group = PRIORITY_FORMATION
	name = "Pluoxium Formation"
	id = "pluox_formation"
	desc = "Alternate production for pluoxium which uses tritium."

/datum/gas_reaction/pluox_formation/init_reqs()
	requirements = list(
		/datum/gas/carbon_dioxide = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		/datum/gas/tritium = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = PLUOXIUM_FORMATION_MIN_TEMP,
		"MAX_TEMP" = PLUOXIUM_FORMATION_MAX_TEMP,
	)

/datum/gas_reaction/pluox_formation/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_moles = air.moles
	var/carbon_dioxide_moles = cached_moles[/datum/gas/carbon_dioxide]
	var/oxygen_moles = cached_moles[/datum/gas/oxygen]
	var/tritium_moles = cached_moles[/datum/gas/tritium]
	var/produced_amount = min(PLUOXIUM_FORMATION_MAX_RATE, carbon_dioxide_moles, oxygen_moles * INVERSE(0.5), tritium_moles * INVERSE(0.01))
	if (produced_amount <= 0 || carbon_dioxide_moles - produced_amount < 0 || oxygen_moles - produced_amount * 0.5 < 0 || tritium_moles - produced_amount * 0.01 < 0)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	cached_moles[/datum/gas/carbon_dioxide] -= produced_amount
	cached_moles[/datum/gas/oxygen] -= produced_amount * 0.5
	cached_moles[/datum/gas/tritium] -= produced_amount * 0.01
	cached_moles[/datum/gas/pluoxium] += produced_amount

	SET_REACTION_RESULTS(produced_amount)
	var/energy_released = produced_amount * PLUOXIUM_FORMATION_ENERGY
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max((air.temperature * old_heat_capacity + energy_released) / new_heat_capacity, TCMB)
	return REACTING


// Nitrium

/**
 * Nitrium Formation:
 *
 * The formation of nitrium.
 * Endothermic.
 * Requires BZ.
 */
/datum/gas_reaction/nitrium_formation
	priority_group = PRIORITY_FORMATION
	name = "Nitrium Formation"
	id = "nitrium_formation"
	desc = "Production of nitrium from BZ, tritium, and nitrogen."

/datum/gas_reaction/nitrium_formation/init_reqs()
	requirements = list(
		/datum/gas/tritium = 20,
		/datum/gas/nitrogen = 10,
		/datum/gas/bz = 5,
		"MIN_TEMP" = NITRIUM_FORMATION_MIN_TEMP,
	)

/datum/gas_reaction/nitrium_formation/react(datum/gas_mixture/air)
	var/list/cached_moles = air.moles
	var/tritium_moles = cached_moles[/datum/gas/tritium]
	var/nitrogen_moles = cached_moles[/datum/gas/nitrogen]
	var/bz_moles = cached_moles[/datum/gas/bz]
	var/temperature = air.temperature
	var/heat_efficiency = min(temperature / NITRIUM_FORMATION_TEMP_DIVISOR, tritium_moles, nitrogen_moles, bz_moles * INVERSE(0.05))

	if(heat_efficiency <= 0 || (tritium_moles - heat_efficiency < 0 ) || (nitrogen_moles - heat_efficiency < 0) || (bz_moles - heat_efficiency * 0.05 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	cached_moles[/datum/gas/tritium] -= heat_efficiency
	cached_moles[/datum/gas/nitrogen] -= heat_efficiency
	cached_moles[/datum/gas/bz] -= heat_efficiency * 0.05 //bz gets consumed to balance the nitrium production and not make it too common and/or easy
	cached_moles[/datum/gas/nitrium] += heat_efficiency


	SET_REACTION_RESULTS(heat_efficiency)
	var/energy_used = heat_efficiency * NITRIUM_FORMATION_ENERGY
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((temperature * old_heat_capacity - energy_used) / new_heat_capacity), TCMB) //the air cools down when reacting
	return REACTING


/**
 * Nitrium Decomposition:
 *
 * The decomposition of nitrium.
 * Exothermic.
 * Requires oxygen as catalyst.
 */
/datum/gas_reaction/nitrium_decomposition
	priority_group = PRIORITY_PRE_FORMATION
	name = "Nitrium Decomposition"
	id = "nitrium_decomp"
	desc = "Decomposition of nitrium when exposed to oxygen under normal temperatures."

/datum/gas_reaction/nitrium_decomposition/init_reqs()
	requirements = list(
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		/datum/gas/nitrium = MINIMUM_MOLE_COUNT,
		"MAX_TEMP" = NITRIUM_DECOMPOSITION_MAX_TEMP,
	)

/datum/gas_reaction/nitrium_decomposition/react(datum/gas_mixture/air)
	var/list/cached_moles = air.moles
	var/nitrium_moles = cached_moles[/datum/gas/nitrium]
	var/temperature = air.temperature

	//This reaction is aggressively slow. like, a tenth of a mole per fire slow. Keep that in mind
	var/heat_efficiency = min(temperature / NITRIUM_DECOMPOSITION_TEMP_DIVISOR, nitrium_moles)

	if (heat_efficiency <= 0 || (nitrium_moles - heat_efficiency < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	air.assert_gas(/datum/gas/nitrogen)
	cached_moles[/datum/gas/nitrium] -= heat_efficiency
	cached_moles[/datum/gas/nitrogen] += heat_efficiency

	SET_REACTION_RESULTS(heat_efficiency)
	var/energy_released = heat_efficiency * NITRIUM_DECOMPOSITION_ENERGY
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((temperature * old_heat_capacity + energy_released) / new_heat_capacity), TCMB) //the air heats up when reacting
	return REACTING

/**
 * Hyper-Noblium Formation:
 *
 * Extremely exothermic.
 * Requires very low temperatures.
 * Due to its high mass, hyper-noblium uses large amounts of nitrogen and tritium.
 * BZ can be used as a catalyst to make it less exothermic.
 */
/datum/gas_reaction/nobliumformation
	priority_group = PRIORITY_FORMATION
	name = "Hyper-Noblium Condensation"
	id = "nobformation"
	desc = "Production of hyper-noblium from nitrogen and tritium under very low temperatures. Extremely energetic."

/datum/gas_reaction/nobliumformation/init_reqs()
	requirements = list(
		/datum/gas/nitrogen = 10,
		/datum/gas/tritium = 5,
		"MIN_TEMP" = NOBLIUM_FORMATION_MIN_TEMP,
		"MAX_TEMP" = NOBLIUM_FORMATION_MAX_TEMP,
	)

/datum/gas_reaction/nobliumformation/react(datum/gas_mixture/air)
	. = NO_REACTION
	var/list/cached_moles = air.moles
	var/nitrogen_moles = cached_moles[/datum/gas/nitrogen]
	var/tritium_moles = cached_moles[/datum/gas/tritium]
	/// List of gases we will assert, and possibly garbage collect.
	var/list/asserted_gases = list(/datum/gas/hypernoblium, /datum/gas/bz)
	air.assert_gases(arglist(asserted_gases))
	var/bz_moles = cached_moles[/datum/gas/bz]
	var/reduction_factor = clamp(tritium_moles / (tritium_moles + bz_moles), 0.001 , 1) //reduces trit consumption in presence of bz upward to 0.1% reduction
	var/nob_formed = min((nitrogen_moles + tritium_moles) * 0.01, tritium_moles * INVERSE(5 * reduction_factor), nitrogen_moles * INVERSE(10))

	//calling QUANTIZE on results to round very small floating point values.
	if (QUANTIZE(nob_formed) <= 0 || (QUANTIZE(tritium_moles - 5 * nob_formed * reduction_factor) < 0) || (QUANTIZE(nitrogen_moles - 10 * nob_formed) < 0))
		air.garbage_collect()
		return

	var/old_heat_capacity = air.heat_capacity()
	cached_moles[/datum/gas/tritium] -= 5 * nob_formed * reduction_factor
	cached_moles[/datum/gas/nitrogen] -= 10 * nob_formed
	cached_moles[/datum/gas/hypernoblium] += nob_formed // I'm not going to nitpick, but N20H10 feels like it should be an explosive more than anything.

	SET_REACTION_RESULTS(nob_formed)
	var/energy_released = nob_formed * NOBLIUM_FORMATION_ENERGY / max(bz_moles, 1)
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.temperature = max(((air.temperature * old_heat_capacity + energy_released) / new_heat_capacity), TCMB)
	. |= REACTING | VOLATILE_REACTION

//fusion: a terrible idea that was fun but broken. Now reworked to be less broken and more interesting. Again (and again, and again). Again!
//Fusion Rework Counter: Please increment this if you make a major overhaul to this system again.
//7 reworks

/datum/gas_reaction/fusion
	exclude = FALSE
	priority_group = PRIORITY_FORMATION
	name = "Plasmic Fusion"
	id = "fusion"

/datum/gas_reaction/fusion/init_reqs()
	requirements = list(
		/datum/gas/tritium = PLASMIC_FUSION_TRITIUM_MOLES_USED,
		/datum/gas/plasma = PLASMIC_FUSION_MOLE_THRESHOLD,
		/datum/gas/carbon_dioxide = PLASMIC_FUSION_MOLE_THRESHOLD,
		"MIN_TEMP" = PLASMIC_FUSION_TEMPERATURE_THRESHOLD,
	)

/datum/gas_reaction/fusion/react(datum/gas_mixture/air, datum/holder)
	var/turf/open/location
	if (istype(holder, /datum/pipenet)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipenet/fusion_pipenet = holder
		location = get_turf(pick(fusion_pipenet.members))
	else
		location = get_turf(holder)

	air.analyzer_results ||= new()
	var/list/cached_scan_results = air.analyzer_results

	var/list/cached_moles = air.moles //this speeds things up because accessing datum vars is slow
	var/initial_plasma = cached_moles[/datum/gas/plasma]
	var/initial_carbon = cached_moles[/datum/gas/carbon_dioxide]
	var/thermal_energy = air.thermal_energy()
	var/reaction_energy = 0 //Reaction energy can be negative or positive, for both exothermic and endothermic reactions.
	var/scale_factor = max(air.return_volume() / PLASMIC_FUSION_SCALE_DIVISOR, PLASMIC_FUSION_MINIMAL_SCALE)
	var/temperature_scale = log(10, air.return_temperature())
	//The size of the phase space hypertorus
	var/toroidal_size = PLASMIC_FUSION_TOROID_CALCULATED_THRESHOLD \
						+ (temperature_scale <= PLASMIC_FUSION_BASE_TEMPSCALE ? \
						(temperature_scale-PLASMIC_FUSION_BASE_TEMPSCALE) / PLASMIC_FUSION_BUFFER_DIVISOR \
						: 4 ** (temperature_scale-PLASMIC_FUSION_BASE_TEMPSCALE) / PLASMIC_FUSION_SLOPE_DIVISOR)

	var/instability = MODULUS((air.fusion_power() * PLASMIC_FUSION_INSTABILITY_GAS_POWER_FACTOR), toroidal_size) //Instability effects how chaotic the behavior of the reaction is
	cached_scan_results[id] = instability //used for analyzer feedback

	var/plasma = (initial_plasma-PLASMIC_FUSION_MOLE_THRESHOLD)/(scale_factor) //We have to scale the amounts of carbon and plasma down a significant amount in order to show the chaotic dynamics we want
	var/carbon = (initial_carbon-PLASMIC_FUSION_MOLE_THRESHOLD)/(scale_factor) //We also subtract out the threshold amount to make it harder for fusion to burn itself out.

	//The reaction is a specific form of the Kicked Rotator system, which displays chaotic behavior and can be used to model particle interactions.
	plasma = MODULUS(plasma - (instability*sin(TODEGREES(carbon))), toroidal_size)
	carbon = MODULUS(carbon - plasma, toroidal_size)

	cached_moles[/datum/gas/plasma] = plasma * scale_factor + PLASMIC_FUSION_MOLE_THRESHOLD //Scales the gases back up
	cached_moles[/datum/gas/carbon_dioxide] = carbon * scale_factor + PLASMIC_FUSION_MOLE_THRESHOLD //Scales the gases back up

	var/delta_plasma = min(initial_plasma - cached_moles[/datum/gas/plasma], toroidal_size * scale_factor * 1.5)

	//Energy is gained or lost corresponding to the creation or destruction of mass.
	//Low instability prevents endothermality while higher instability acutally encourages it.
	reaction_energy = 	instability <= PLASMIC_FUSION_INSTABILITY_ENDOTHERMALITY || delta_plasma > 0 ? \
						max(delta_plasma*PLASMIC_FUSION_PLASMA_BINDING_ENERGY, 0) \
						: delta_plasma*PLASMIC_FUSION_PLASMA_BINDING_ENERGY * (instability-PLASMIC_FUSION_INSTABILITY_ENDOTHERMALITY)**0.5

	//To achieve faster equilibrium. Too bad it is not that good at cooling down.
	if (reaction_energy)
		var/middle_energy = (((PLASMIC_FUSION_TOROID_CALCULATED_THRESHOLD / 2) * scale_factor) + PLASMIC_FUSION_MOLE_THRESHOLD) * (200 * PLASMIC_FUSION_MIDDLE_ENERGY_REFERENCE)
		thermal_energy = middle_energy * PLASMIC_FUSION_ENERGY_TRANSLATION_EXPONENT ** log(10, thermal_energy / middle_energy)

		//This bowdlerization is a double-edged sword. Tread with care!
		var/bowdlerized_reaction_energy = 	clamp(reaction_energy, \
											thermal_energy * ((1 / PLASMIC_FUSION_ENERGY_TRANSLATION_EXPONENT ** 2) - 1), \
											thermal_energy * (PLASMIC_FUSION_ENERGY_TRANSLATION_EXPONENT ** 2 - 1))
		thermal_energy = middle_energy * 10 ** log(PLASMIC_FUSION_ENERGY_TRANSLATION_EXPONENT, (thermal_energy + bowdlerized_reaction_energy) / middle_energy)

	//The reason why you should set up a tritium production line.
	cached_moles[/datum/gas/tritium] -= PLASMIC_FUSION_TRITIUM_MOLES_USED

	//The decay of the tritium and the reaction's energy produces waste gases, different ones depending on whether the reaction is endo or exothermic
	var/standard_waste_gas_output = scale_factor * (PLASMIC_FUSION_TRITIUM_CONVERSION_COEFFICIENT*PLASMIC_FUSION_TRITIUM_MOLES_USED)
	if (delta_plasma > 0)
		cached_moles[/datum/gas/water_vapor] += standard_waste_gas_output
	else
		cached_moles[/datum/gas/bz] += standard_waste_gas_output
	//Oxygen is a bit touchy subject
	cached_moles[/datum/gas/oxygen] += standard_waste_gas_output

	if(reaction_energy)
		if(location)
			var/particle_chance = ((PLASMIC_FUSION_PARTICLE_CHANCE_CONSTANT)/(reaction_energy-PLASMIC_FUSION_PARTICLE_CHANCE_CONSTANT)) + 1//Asymptopically approaches 100% as the energy of the reaction goes up.
			if(prob(PERCENT(particle_chance)))
				location.fire_nuclear_particle()
			radiation_pulse(
				location,
				max_range = rand(6,30),
				threshold = RAD_EXTREME_INSULATION,
				intensity = 20,
			)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = clamp(thermal_energy/new_heat_capacity, TCMB, INFINITY)
	else if(reaction_energy == 0 && instability <= PLASMIC_FUSION_INSTABILITY_ENDOTHERMALITY)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = clamp(thermal_energy/new_heat_capacity, TCMB, INFINITY) //THIS SHOULD STAY OR FUSION WILL EAT YOUR FACE

	return REACTING | VOLATILE_REACTION

#undef SET_REACTION_RESULTS
