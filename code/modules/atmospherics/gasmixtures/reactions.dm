//All defines used in reactions are located in ..\__DEFINES\reactions.dm
#define SET_REACTION_RESULTS(amount) air.reaction_results[type] = amount

/proc/init_gas_reactions()
	var/list/priority_reactions = list()

	//Builds a list of gas id to reaction group
	for(var/gas_id in GLOB.meta_gas_info)
		priority_reactions[gas_id] = list(
			PRIORITY_PRE_FORMATION = list(),
			PRIORITY_FORMATION = list(),
			PRIORITY_POST_FORMATION = list(),
			PRIORITY_FIRE = list()
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
	for(var/gas_id in GLOB.meta_gas_info)
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
	//regarding the requirements list: the minimum or maximum requirements must be non-zero.
	//when in doubt, use MINIMUM_MOLE_COUNT.
	var/list/requirements
	var/major_gas //the highest rarity gas used in the reaction.
	var/exclude = FALSE //do it this way to allow for addition/removal of reactions midmatch in the future
	///The priority group this reaction is a part of. You can think of these as processing in batches, put your reaction into the one that's most fitting
	var/priority_group
	var/name = "reaction"
	var/id = "r"

/datum/gas_reaction/New()
	init_reqs()

/datum/gas_reaction/proc/init_reqs()

/datum/gas_reaction/proc/react(datum/gas_mixture/air, atom/location)
	return NO_REACTION

/datum/gas_reaction/nobliumsupression
	priority = INFINITY
	name = "Hyper-Noblium Reaction Suppression"
	id = "nobstop"

/datum/gas_reaction/nobliumsupression/init_reqs()
	requirements = list(/datum/gas/hypernoblium = REACTION_OPPRESSION_THRESHOLD)

/datum/gas_reaction/nobliumsupression/react()
	return STOP_REACTIONS

//water vapor: puts out fires?
/datum/gas_reaction/water_vapor
	priority = PRIORITY_POST_FORMATION
	name = "Water Vapor"
	id = "vapor"

/datum/gas_reaction/water_vapor/init_reqs()
	requirements = list(/datum/gas/water_vapor = MOLES_GAS_VISIBLE)

/datum/gas_reaction/water_vapor/react(datum/gas_mixture/air, datum/holder)
	var/turf/open/location = isturf(holder) ? holder : null
	. = NO_REACTION
	if (air.temperature <= WATER_VAPOR_FREEZE)
		if(location?.freon_gas_act())
			. = REACTING
	else if(air.temperature <= T20C + 10)
		if(location?.water_vapor_gas_act())
			air.gases[/datum/gas/water_vapor][MOLES] -= MOLES_GAS_VISIBLE
			. = REACTING

//tritium combustion: combustion of oxygen and tritium (treated as hydrocarbons). creates hotspots. exothermic
/datum/gas_reaction/nitrous_decomp
	priority_group = PRIORITY_POST_FORMATION
	name = "Nitrous Oxide Decomposition"
	id = "nitrous_decomp"

/datum/gas_reaction/nitrous_decomp/init_reqs()
	requirements = list(
		/datum/gas/nitrous_oxide = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = N2O_DECOMPOSITION_MIN_ENERGY
	)

/datum/gas_reaction/nitrous_decomp/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/temperature = air.temperature
	var/burned_fuel = 0


	burned_fuel = max(0,0.00002 * (temperature - (0.00001 * (temperature**2)))) * cached_gases[/datum/gas/nitrous_oxide][MOLES]
	if(cached_gases[/datum/gas/nitrous_oxide][MOLES] - burned_fuel < 0)
		return NO_REACTION
	cached_gases[/datum/gas/nitrous_oxide][MOLES] -= burned_fuel

	if(burned_fuel)
		energy_released += (N2O_DECOMPOSITION_ENERGY_RELEASED * burned_fuel)

		ASSERT_GAS(/datum/gas/oxygen, air)
		cached_gases[/datum/gas/oxygen][MOLES] += burned_fuel * 0.5
		ASSERT_GAS(/datum/gas/nitrogen, air)
		cached_gases[/datum/gas/nitrogen][MOLES] += burned_fuel

		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = (temperature * old_heat_capacity + energy_released) / new_heat_capacity
		return REACTING
	return NO_REACTION


//tritium combustion: combustion of oxygen and tritium (treated as hydrocarbons). creates hotspots. exothermic
/datum/gas_reaction/tritfire
	priority_group = PRIORITY_FIRE
	name = "Tritium Combustion"
	id = "tritfire"

/datum/gas_reaction/tritfire/init_reqs()
	requirements = list(
		/datum/gas/tritium = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	)

/datum/gas_reaction/tritfire/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/temperature = air.temperature
	var/list/cached_results = air.reaction_results
	cached_results["fire"] = 0
	var/turf/open/location = isturf(holder) ? holder : null
	var/burned_fuel = 0

	if(cached_gases[/datum/gas/oxygen][MOLES] < cached_gases[/datum/gas/tritium][MOLES] || MINIMUM_TRIT_OXYBURN_ENERGY > air.thermal_energy())
		burned_fuel = cached_gases[/datum/gas/oxygen][MOLES] / TRITIUM_BURN_OXY_FACTOR
		cached_gases[/datum/gas/tritium][MOLES] -= burned_fuel

		ASSERT_GAS(/datum/gas/water_vapor, air) //oxygen+more-or-less hydrogen=H2O
		cached_gases[/datum/gas/water_vapor][MOLES] += burned_fuel / TRITIUM_BURN_OXY_FACTOR

		energy_released += (FIRE_HYDROGEN_ENERGY_WEAK * burned_fuel)
		cached_results["fire"] += burned_fuel

	else
		burned_fuel = cached_gases[/datum/gas/tritium][MOLES]

		cached_gases[/datum/gas/tritium][MOLES] -= burned_fuel / TRITIUM_BURN_TRIT_FACTOR
		cached_gases[/datum/gas/oxygen][MOLES] -= burned_fuel

		ASSERT_GAS(/datum/gas/water_vapor, air) //oxygen+more-or-less hydrogen=H2O
		cached_gases[/datum/gas/water_vapor][MOLES] += burned_fuel / TRITIUM_BURN_TRIT_FACTOR

		energy_released += (FIRE_HYDROGEN_ENERGY_RELEASED * burned_fuel)
		cached_results["fire"] += burned_fuel * 10

	if(burned_fuel)
		if(location && prob(10) && burned_fuel > TRITIUM_MINIMUM_RADIATION_ENERGY) //woah there let's not crash the server
			radiation_pulse(location, energy_released / TRITIUM_BURN_RADIOACTIVITY_FACTOR)

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = (temperature * old_heat_capacity + energy_released) / new_heat_capacity

	//let the floor know a fire is happening
	if(istype(location))
		temperature = air.temperature
		if(temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			location.hotspot_expose(temperature, CELL_VOLUME)

	return cached_results["fire"] ? REACTING : NO_REACTION

/proc/fire_expose(turf/open/location, datum/gas_mixture/air, temperature)
	if(istype(location) && temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		location.hotspot_expose(temperature, CELL_VOLUME)

/proc/radiation_burn(turf/open/location, energy_released)
	if(istype(location) && prob(10))
		radiation_pulse(location, energy_released/TRITIUM_BURN_RADIOACTIVITY_FACTOR)



//plasma combustion: combustion of oxygen and plasma (treated as hydrocarbons). creates hotspots. exothermic
/datum/gas_reaction/plasmafire
	priority_group = PRIORITY_FIRE
	name = "Plasma Combustion"
	id = "plasmafire"

/datum/gas_reaction/plasmafire/init_reqs()
	requirements = list(
		/datum/gas/plasma = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	)

/datum/gas_reaction/plasmafire/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/temperature = air.temperature
	var/list/cached_results = air.reaction_results
	cached_results["fire"] = 0
	var/turf/open/location = isturf(holder) ? holder : null

	//Handle plasma burning
	var/plasma_burn_rate = 0
	var/oxygen_burn_rate = 0
	//more plasma released at higher temperatures
	var/temperature_scale = 0
	//to make tritium
	var/super_saturation = FALSE

	if(temperature > PLASMA_UPPER_TEMPERATURE)
		temperature_scale = 1
	else
		temperature_scale = (temperature - PLASMA_MINIMUM_BURN_TEMPERATURE) / (PLASMA_UPPER_TEMPERATURE-PLASMA_MINIMUM_BURN_TEMPERATURE)
	if(temperature_scale > 0)
		oxygen_burn_rate = OXYGEN_BURN_RATE_BASE - temperature_scale
		if(cached_gases[/datum/gas/oxygen][MOLES] / cached_gases[/datum/gas/plasma][MOLES] > SUPER_SATURATION_THRESHOLD) //supersaturation. Form Tritium.
			super_saturation = TRUE
		if(cached_gases[/datum/gas/oxygen][MOLES] > cached_gases[/datum/gas/plasma][MOLES] * PLASMA_OXYGEN_FULLBURN)
			plasma_burn_rate = (cached_gases[/datum/gas/plasma][MOLES] * temperature_scale) / PLASMA_BURN_RATE_DELTA
		else
			plasma_burn_rate = (temperature_scale * (cached_gases[/datum/gas/oxygen][MOLES] / PLASMA_OXYGEN_FULLBURN)) / PLASMA_BURN_RATE_DELTA

		if(plasma_burn_rate > MINIMUM_HEAT_CAPACITY)
			plasma_burn_rate = min(plasma_burn_rate, cached_gases[/datum/gas/plasma][MOLES], cached_gases[/datum/gas/oxygen][MOLES]/oxygen_burn_rate) //Ensures matter is conserved properly
			cached_gases[/datum/gas/plasma][MOLES] = QUANTIZE(cached_gases[/datum/gas/plasma][MOLES] - plasma_burn_rate)
			cached_gases[/datum/gas/oxygen][MOLES] = QUANTIZE(cached_gases[/datum/gas/oxygen][MOLES] - (plasma_burn_rate * oxygen_burn_rate))
			if (super_saturation)
				ASSERT_GAS(/datum/gas/tritium, air)
				cached_gases[/datum/gas/tritium][MOLES] += plasma_burn_rate
			else
				ASSERT_GAS(/datum/gas/carbon_dioxide,air)
				ASSERT_GAS(/datum/gas/water_vapor,air)
				cached_gases[/datum/gas/carbon_dioxide][MOLES] += plasma_burn_rate * 0.75
				cached_gases[/datum/gas/water_vapor][MOLES] += plasma_burn_rate * 0.25

			energy_released += FIRE_PLASMA_ENERGY_RELEASED * (plasma_burn_rate)

			cached_results["fire"] += (plasma_burn_rate) * (1 + oxygen_burn_rate)

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = (temperature*old_heat_capacity + energy_released)/new_heat_capacity

	//let the floor know a fire is happening
	if(istype(location))
		temperature = air.temperature
		if(temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			location.hotspot_expose(temperature, CELL_VOLUME)

	return cached_results["fire"] ? REACTING : NO_REACTION

//fusion: a terrible idea that was fun but broken. Now reworked to be less broken and more interesting. Again (and again, and again). Again!
//Fusion Rework Counter: Please increment this if you make a major overhaul to this system again.
//6 reworks

/datum/gas_reaction/fusion
	exclude = FALSE
	priority = 2
	name = "Plasmic Fusion"
	id = "fusion"

/datum/gas_reaction/fusion/init_reqs()
	requirements = list(
		"MIN_TEMP" = FUSION_TEMPERATURE_THRESHOLD,
		/datum/gas/tritium = FUSION_TRITIUM_MOLES_USED,
		/datum/gas/plasma = FUSION_MOLE_THRESHOLD,
		/datum/gas/carbon_dioxide = FUSION_MOLE_THRESHOLD)

/datum/gas_reaction/fusion/react(datum/gas_mixture/air, datum/holder)
	var/turf/open/location
	if (istype(holder,/datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/fusion_pipenet = holder
		location = get_turf(pick(fusion_pipenet.members))
	else
		location = get_turf(holder)
	if(!air.analyzer_results)
		air.analyzer_results = new
	var/list/cached_scan_results = air.analyzer_results
	var/thermal_energy = air.thermal_energy()
	var/reaction_energy = 0 //Reaction energy can be negative or positive, for both exothermic and endothermic reactions.
	var/initial_plasma = air.gases[/datum/gas/plasma][MOLES]
	var/initial_carbon = air.gases[/datum/gas/carbon_dioxide][MOLES]
	var/scale_factor = max(air.return_volume() / FUSION_SCALE_DIVISOR, FUSION_MINIMAL_SCALE)
	var/temperature_scale = log(10, air.return_temperature())
	//The size of the phase space hypertorus
	var/toroidal_size = 	TOROID_CALCULATED_THRESHOLD \
							+ (temperature_scale <= FUSION_BASE_TEMPSCALE ? \
							(temperature_scale-FUSION_BASE_TEMPSCALE) / FUSION_BUFFER_DIVISOR \
							: 4 ** (temperature_scale-FUSION_BASE_TEMPSCALE) / FUSION_SLOPE_DIVISOR)
	var/gas_power = 0
	for (var/gas_id in air.gases)
		gas_power += (GLOB.gas_data.fusion_powers[gas_id]*air.gases[gas_id][MOLES])
	var/instability = MODULUS((gas_power*INSTABILITY_GAS_POWER_FACTOR),toroidal_size) //Instability effects how chaotic the behavior of the reaction is
	cached_scan_results[id] = instability//used for analyzer feedback

	var/plasma = (initial_plasma-FUSION_MOLE_THRESHOLD)/(scale_factor) //We have to scale the amounts of carbon and plasma down a significant amount in order to show the chaotic dynamics we want
	var/carbon = (initial_carbon-FUSION_MOLE_THRESHOLD)/(scale_factor) //We also subtract out the threshold amount to make it harder for fusion to burn itself out.

	//The reaction is a specific form of the Kicked Rotator system, which displays chaotic behavior and can be used to model particle interactions.
	plasma = MODULUS(plasma - (instability*sin(TODEGREES(carbon))), toroidal_size)
	carbon = MODULUS(carbon - plasma, toroidal_size)

	air.gases[/datum/gas/plasma][MOLES] = plasma*scale_factor + FUSION_MOLE_THRESHOLD
//Scales the gases back up
	air.gases[/datum/gas/carbon_dioxide][MOLES] = carbon*scale_factor + FUSION_MOLE_THRESHOLD

	var/delta_plasma = min(initial_plasma - air.gases[/datum/gas/plasma][MOLES], toroidal_size * scale_factor * 1.5)

	//Energy is gained or lost corresponding to the creation or destruction of mass.
	//Low instability prevents endothermality while higher instability acutally encourages it.
	reaction_energy = 	instability <= FUSION_INSTABILITY_ENDOTHERMALITY || delta_plasma > 0 ? \
						max(delta_plasma*PLASMA_BINDING_ENERGY, 0) \
						: delta_plasma*PLASMA_BINDING_ENERGY * (instability-FUSION_INSTABILITY_ENDOTHERMALITY)**0.5

	//To achieve faster equilibrium. Too bad it is not that good at cooling down.
	if (reaction_energy)
		var/middle_energy = (((TOROID_CALCULATED_THRESHOLD / 2) * scale_factor) + FUSION_MOLE_THRESHOLD) * (200 * FUSION_MIDDLE_ENERGY_REFERENCE)
		thermal_energy = middle_energy * FUSION_ENERGY_TRANSLATION_EXPONENT ** log(10, thermal_energy / middle_energy)

		//This bowdlerization is a double-edged sword. Tread with care!
		var/bowdlerized_reaction_energy = 	clamp(reaction_energy, \
											thermal_energy * ((1 / FUSION_ENERGY_TRANSLATION_EXPONENT ** 2) - 1), \
											thermal_energy * (FUSION_ENERGY_TRANSLATION_EXPONENT ** 2 - 1))
		thermal_energy = middle_energy * 10 ** log(FUSION_ENERGY_TRANSLATION_EXPONENT, (thermal_energy + bowdlerized_reaction_energy) / middle_energy)

	//The reason why you should set up a tritium production line.
	air.gases[/datum/gas/tritium][MOLES] += -FUSION_TRITIUM_MOLES_USED

	//The decay of the tritium and the reaction's energy produces waste gases, different ones depending on whether the reaction is endo or exothermic
	var/standard_waste_gas_output = scale_factor * (FUSION_TRITIUM_CONVERSION_COEFFICIENT*FUSION_TRITIUM_MOLES_USED)
	if(delta_plasma > 0)
		air.gases[/datum/gas/water_vapor][MOLES] += standard_waste_gas_output
	else
		air.gases[/datum/gas/bz][MOLES] += standard_waste_gas_output
	air.gases[/datum/gas/oxygen][MOLES] += standard_waste_gas_output //Oxygen is a bit touchy subject

	if(reaction_energy)
		if(location)
			var/standard_energy = 400 * air.gases[/datum/gas/plasma][MOLES] * air.return_temperature() //Prevents putting meaningless waste gases to achieve high rads.
			if(prob(PERCENT(((PARTICLE_CHANCE_CONSTANT)/(reaction_energy-PARTICLE_CHANCE_CONSTANT)) + 1))) //Asymptopically approaches 100% as the energy of the reaction goes up.
				location.fire_nuclear_particle(customize = TRUE, custompower = standard_energy)
			radiation_pulse(location, max(2000 * 3 ** (log(10,standard_energy) - FUSION_RAD_MIDPOINT), 0))
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = (clamp(thermal_energy/new_heat_capacity, TCMB, INFINITY))
		return REACTING
	else if(reaction_energy == 0 && instability <= FUSION_INSTABILITY_ENDOTHERMALITY)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = (clamp(thermal_energy/new_heat_capacity, TCMB, INFINITY)) //THIS SHOULD STAY OR FUSION WILL EAT YOUR FACE
		return REACTING


/datum/gas_reaction/nitrylformation //The formation of nitryl. Endothermic. Requires bz.
	priority_group = PRIORITY_FORMATION
	name = "Nitryl formation"
	id = "nitrylformation"

/datum/gas_reaction/nitrylformation/init_reqs()
	requirements = list(
		/datum/gas/oxygen = 10,
		/datum/gas/nitrogen = 10,
		/datum/gas/bz = 5,
		"MIN_TEMP" = 1500,
		"MAX_TEMP" = 10000
	)

/datum/gas_reaction/nitrylformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature

	var/old_heat_capacity = air.heat_capacity()
	var/heat_efficency = min(temperature / (FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 8), cached_gases[/datum/gas/oxygen][MOLES], cached_gases[/datum/gas/nitrogen][MOLES])
	var/energy_used = heat_efficency * NITRYL_FORMATION_ENERGY
	ASSERT_GAS(/datum/gas/nitryl, air)
	if ((cached_gases[/datum/gas/oxygen][MOLES] - heat_efficency < 0 ) || (cached_gases[/datum/gas/nitrogen][MOLES] - heat_efficency < 0) || (cached_gases[/datum/gas/bz][MOLES] - heat_efficency * 0.05 < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION

	ASSERT_GAS(/datum/gas/nitryl, air)
	cached_gases[/datum/gas/oxygen][MOLES] -= heat_efficency
	cached_gases[/datum/gas/nitrogen][MOLES] -= heat_efficency
	cached_gases[/datum/gas/bz][MOLES] -= heat_efficency * 0.05 //bz gets consumed to balance the nitryl production and not make it too common and/or easy
	cached_gases[/datum/gas/nitryl][MOLES] += heat_efficency

	if(energy_used > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((temperature * old_heat_capacity - energy_used) / new_heat_capacity), TCMB) //the air cools down when reacting
		return REACTING

/datum/gas_reaction/bzformation //Formation of BZ by combining plasma and tritium at low pressures. Exothermic.
	priority_group = PRIORITY_FORMATION
	name = "BZ Gas formation"
	id = "bzformation"

/datum/gas_reaction/bzformation/init_reqs()
	requirements = list(
		/datum/gas/nitrous_oxide = 10,
		/datum/gas/plasma = 10
	)

/datum/gas_reaction/bzformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/pressure = air.return_pressure()
	var/old_heat_capacity = air.heat_capacity()
	var/reaction_efficency = min(1 / ((pressure / (0.1 * ONE_ATMOSPHERE)) * (max(cached_gases[/datum/gas/plasma][MOLES] / cached_gases[/datum/gas/nitrous_oxide][MOLES], 1))), cached_gases[/datum/gas/nitrous_oxide][MOLES], cached_gases[/datum/gas/plasma][MOLES] * 0.5)
	var/energy_released = 2 * reaction_efficency * FIRE_CARBON_ENERGY_RELEASED
	if ((cached_gases[/datum/gas/nitrous_oxide][MOLES] - reaction_efficency < 0 )|| (cached_gases[/datum/gas/plasma][MOLES] - (2 * reaction_efficency) < 0) || energy_released <= 0) //Shouldn't produce gas from nothing.
		return NO_REACTION

	ASSERT_GAS(/datum/gas/bz, air)
	cached_gases[/datum/gas/bz][MOLES] += reaction_efficency * 2.5
	if(reaction_efficency == cached_gases[/datum/gas/nitrous_oxide][MOLES])
		ASSERT_GAS(/datum/gas/oxygen, air)
		cached_gases[/datum/gas/bz][MOLES] -= min(pressure,0.5)
		cached_gases[/datum/gas/oxygen][MOLES] += min(pressure,0.5)
	cached_gases[/datum/gas/nitrous_oxide][MOLES] -= reaction_efficency
	cached_gases[/datum/gas/plasma][MOLES]  -= 2 * reaction_efficency

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((temperature * old_heat_capacity + energy_released) / new_heat_capacity), TCMB)
		return REACTING

/datum/gas_reaction/stimformation //Stimulum formation follows a strange pattern of how effective it will be at a given temperature, having some multiple peaks and some large dropoffs. Exo and endo thermic.
	priority_group = PRIORITY_FORMATION
	name = "Stimulum formation"
	id = "stimformation"

/datum/gas_reaction/stimformation/init_reqs()
	requirements = list(
		/datum/gas/tritium = 30,
		/datum/gas/bz = 20,
		/datum/gas/nitryl = 30,
		"MIN_TEMP" = 1500)

/datum/gas_reaction/stimformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases

	var/old_heat_capacity = air.heat_capacity()
	var/heat_scale = min(air.temperature/STIMULUM_HEAT_SCALE,cached_gases[/datum/gas/tritium][MOLES],cached_gases[/datum/gas/plasma][MOLES],cached_gases[/datum/gas/nitryl][MOLES])
	var/stim_energy_change = heat_scale + STIMULUM_FIRST_RISE*(heat_scale**2) - STIMULUM_FIRST_DROP*(heat_scale**3) + STIMULUM_SECOND_RISE*(heat_scale**4) - STIMULUM_ABSOLUTE_DROP*(heat_scale**5)
	ASSERT_GAS(/datum/gas/stimulum, air)
	if ((cached_gases[/datum/gas/tritium][MOLES] - heat_scale < 0 ) || (cached_gases[/datum/gas/nitryl][MOLES] - heat_scale < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	cached_gases[/datum/gas/stimulum][MOLES] += heat_scale * 0.75
	cached_gases[/datum/gas/tritium][MOLES] -= heat_scale
	cached_gases[/datum/gas/nitryl][MOLES] -= heat_scale

	if(stim_energy_change)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((air.temperature * old_heat_capacity + stim_energy_change) / new_heat_capacity), TCMB)
		return REACTING

/datum/gas_reaction/nobliumformation //Hyper-Noblium formation is extrememly endothermic, but requires high temperatures to start. Due to its high mass, hyper-nobelium uses large amounts of nitrogen and tritium. BZ can be used as a catalyst to make it less endothermic.
	priority_group = PRIORITY_FORMATION
	name = "Hyper-Noblium condensation"
	id = "nobformation"

/datum/gas_reaction/nobliumformation/init_reqs()
	requirements = list(
		/datum/gas/nitrogen = 10,
		/datum/gas/tritium = 5,
		"MIN_TEMP" = TCMB,
		"MAX_TEMP" = 15
		)

/datum/gas_reaction/nobliumformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	air.assert_gases(/datum/gas/hypernoblium, /datum/gas/bz)
	var/old_heat_capacity = air.heat_capacity()
	var/nob_formed = min((cached_gases[/datum/gas/nitrogen][MOLES] + cached_gases[/datum/gas/tritium][MOLES]) * 0.01, cached_gases[/datum/gas/tritium][MOLES] * 0.1, cached_gases[/datum/gas/nitrogen][MOLES] * 0.2)
	var/energy_produced = nob_formed * (NOBLIUM_FORMATION_ENERGY / (max(cached_gases[/datum/gas/bz][MOLES], 1)))
	if ((cached_gases[/datum/gas/tritium][MOLES] - 5 * nob_formed < 0) || (cached_gases[/datum/gas/nitrogen][MOLES] - 10 * nob_formed < 0))
		return NO_REACTION

	cached_gases[/datum/gas/tritium][MOLES] -= 5 * nob_formed
	cached_gases[/datum/gas/nitrogen][MOLES] -= 10 * nob_formed
	cached_gases[/datum/gas/hypernoblium][MOLES] += nob_formed

	if (nob_formed)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((air.temperature * old_heat_capacity + energy_produced) / new_heat_capacity), TCMB)
		return REACTING

/datum/gas_reaction/stim_ball
	priority = 7
	name ="Stimulum Energy Ball"
	id = "stimball"

/datum/gas_reaction/stim_ball/init_reqs()
	requirements = list(
		/datum/gas/pluoxium = STIM_BALL_GAS_AMOUNT,
		/datum/gas/stimulum = STIM_BALL_GAS_AMOUNT,
		/datum/gas/nitryl = MINIMUM_MOLE_COUNT,
		/datum/gas/plasma = MINIMUM_MOLE_COUNT,
		"MIN_TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	)

/datum/gas_reaction/stim_ball/react(datum/gas_mixture/air, datum/holder)
	var/turf/open/location
	var/old_heat_capacity = air.heat_capacity()
	if(istype(holder,/datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/pipenet = holder
		location = get_turf(pick(pipenet.members))
	else
		location = get_turf(holder)
	var/ball_shot_angle = 180*cos(air.gases[/datum/gas/water_vapor][MOLES]/air.gases[/datum/gas/nitryl][MOLES])+180
	var/stim_used = min(STIM_BALL_GAS_AMOUNT/air.gases[/datum/gas/plasma][MOLES],air.gases[/datum/gas/stimulum][MOLES])
	var/pluox_used = min(STIM_BALL_GAS_AMOUNT/air.gases[/datum/gas/plasma][MOLES],air.gases[/datum/gas/pluoxium][MOLES])
	var/energy_released = stim_used*STIMULUM_HEAT_SCALE//Stimulum has a lot of stored energy, and breaking it up releases some of it
	location.fire_nuclear_particle(ball_shot_angle)
	air.gases[/datum/gas/carbon_dioxide][MOLES] += 4*pluox_used
	air.gases[/datum/gas/nitrogen][MOLES] += 8*stim_used
	air.gases[/datum/gas/pluoxium][MOLES] += -pluox_used
	air.gases[/datum/gas/stimulum][MOLES] += -stim_used
	air.gases[/datum/gas/plasma][MOLES] += max(-air.gases[/datum/gas/plasma][MOLES]/2,-30)
	if(energy_released)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = (clamp((air.return_temperature()*old_heat_capacity + energy_released)/new_heat_capacity,TCMB,INFINITY))
		return REACTING
