//All defines used in reactions are located in ..\__DEFINES\reactions.dm

/proc/init_gas_reactions()
	. = list()

	for(var/r in subtypesof(/datum/gas_reaction))
		var/datum/gas_reaction/reaction = r
		if(initial(reaction.exclude))
			continue
		reaction = new r
		. += reaction
	sortTim(., /proc/cmp_gas_reaction)

/proc/cmp_gas_reaction(datum/gas_reaction/a, datum/gas_reaction/b) // compares lists of reactions by the maximum priority contained within the list
	return b.priority - a.priority

/datum/gas_reaction
	//regarding the requirements lists: the minimum or maximum requirements must be non-zero.
	//when in doubt, use MINIMUM_MOLE_COUNT.
	var/list/min_requirements
	var/list/max_requirements
	var/exclude = FALSE //do it this way to allow for addition/removal of reactions midmatch in the future
	var/priority = 100 //lower numbers are checked/react later than higher numbers. if two reactions have the same priority they may happen in either order
	var/name = "reaction"
	var/id = "r"

/datum/gas_reaction/New()
	init_reqs()

/datum/gas_reaction/proc/init_reqs()

/datum/gas_reaction/proc/react(datum/gas_mixture/air, atom/location)
	return NO_REACTION

/datum/gas_reaction/proc/test()
	return list("success" = TRUE)

/datum/gas_reaction/nobliumsupression
	priority = INFINITY
	name = "Hyper-Noblium Reaction Suppression"
	id = "nobstop"

/datum/gas_reaction/nobliumsupression/init_reqs()
	min_requirements = list(GAS_HYPERNOB = REACTION_OPPRESSION_THRESHOLD)

/datum/gas_reaction/nobliumsupression/react()
	return STOP_REACTIONS

//water vapor: puts out fires?
/datum/gas_reaction/water_vapor
	priority = 1
	name = "Water Vapor"
	id = "vapor"

/datum/gas_reaction/water_vapor/init_reqs()
	min_requirements = list(GAS_H2O = MOLES_GAS_VISIBLE)

/datum/gas_reaction/water_vapor/react(datum/gas_mixture/air, datum/holder)
	var/turf/open/location = isturf(holder) ? holder : null
	. = NO_REACTION
	if (air.return_temperature() <= WATER_VAPOR_FREEZE)
		if(location && location.freon_gas_act())
			. = REACTING
	else if(location && location.water_vapor_gas_act())
		air.adjust_moles(GAS_H2O, -MOLES_GAS_VISIBLE)
		. = REACTING

// no test cause it's entirely based on location

//tritium combustion: combustion of oxygen and tritium (treated as hydrocarbons). creates hotspots. exothermic
/datum/gas_reaction/tritfire
	priority = -1 //fire should ALWAYS be last, but tritium fires happen before plasma fires
	name = "Tritium Combustion"
	id = "tritfire"

/datum/gas_reaction/tritfire/init_reqs()
	min_requirements = list(
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST,
		GAS_TRITIUM = MINIMUM_MOLE_COUNT,
		GAS_O2 = MINIMUM_MOLE_COUNT
	)

/proc/fire_expose(turf/open/location, datum/gas_mixture/air, temperature)
	if(istype(location) && temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		location.hotspot_expose(temperature, CELL_VOLUME)
		for(var/I in location)
			var/atom/movable/item = I
			item.temperature_expose(air, temperature, CELL_VOLUME)
		location.temperature_expose(air, temperature, CELL_VOLUME)

/proc/radiation_burn(turf/open/location, energy_released)
	if(istype(location) && prob(10))
		radiation_pulse(location, energy_released/TRITIUM_BURN_RADIOACTIVITY_FACTOR)

/datum/gas_reaction/tritfire/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/temperature = air.return_temperature()
	var/list/cached_results = air.reaction_results
	cached_results["fire"] = 0
	var/turf/open/location = isturf(holder) ? holder : null
	var/burned_fuel = 0

	if(air.get_moles(GAS_O2) < air.get_moles(GAS_TRITIUM))
		burned_fuel = air.get_moles(GAS_O2)/TRITIUM_BURN_OXY_FACTOR
		air.adjust_moles(GAS_TRITIUM, -burned_fuel)
	else
		burned_fuel = air.get_moles(GAS_TRITIUM)*TRITIUM_BURN_TRIT_FACTOR
		air.adjust_moles(GAS_TRITIUM, -air.get_moles(GAS_TRITIUM)/TRITIUM_BURN_TRIT_FACTOR)
		air.adjust_moles(GAS_O2,-air.get_moles(GAS_TRITIUM))

	if(burned_fuel)
		energy_released += (FIRE_HYDROGEN_ENERGY_RELEASED * burned_fuel)
		if(location && prob(10) && burned_fuel > TRITIUM_MINIMUM_RADIATION_ENERGY) //woah there let's not crash the server
			radiation_pulse(location, energy_released/TRITIUM_BURN_RADIOACTIVITY_FACTOR)

		air.adjust_moles(GAS_H2O, burned_fuel/TRITIUM_BURN_OXY_FACTOR)

		cached_results["fire"] += burned_fuel

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature((temperature*old_heat_capacity + energy_released)/new_heat_capacity)

	//let the floor know a fire is happening
	if(istype(location))
		temperature = air.return_temperature()
		if(temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			location.hotspot_expose(temperature, CELL_VOLUME)
			for(var/I in location)
				var/atom/movable/item = I
				item.temperature_expose(air, temperature, CELL_VOLUME)
			location.temperature_expose(air, temperature, CELL_VOLUME)

	return cached_results["fire"] ? REACTING : NO_REACTION

/datum/gas_reaction/tritfire/test()
	var/datum/gas_mixture/G = new
	G.set_moles(GAS_TRITIUM,50)
	G.set_moles(GAS_O2,50)
	G.set_temperature(500)
	var/result = G.react()
	if(result != REACTING)
		return list("success" = FALSE, "message" = "Reaction didn't go at all!")
	if(!G.reaction_results["fire"])
		return list("success" = FALSE, "message" = "Trit fires aren't setting fire results correctly!")
	return ..()

//plasma combustion: combustion of oxygen and plasma (treated as hydrocarbons). creates hotspots. exothermic
/datum/gas_reaction/plasmafire
	priority = -2 //fire should ALWAYS be last, but plasma fires happen after tritium fires
	name = "Plasma Combustion"
	id = "plasmafire"

/datum/gas_reaction/plasmafire/init_reqs()
	min_requirements = list(
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST,
		GAS_PLASMA = MINIMUM_MOLE_COUNT,
		GAS_O2 = MINIMUM_MOLE_COUNT
	)

/datum/gas_reaction/plasmafire/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/temperature = air.return_temperature()
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
		temperature_scale = (temperature-PLASMA_MINIMUM_BURN_TEMPERATURE)/(PLASMA_UPPER_TEMPERATURE-PLASMA_MINIMUM_BURN_TEMPERATURE)
	if(temperature_scale > 0)
		oxygen_burn_rate = OXYGEN_BURN_RATE_BASE - temperature_scale
		if(air.get_moles(GAS_O2) / air.get_moles(GAS_PLASMA) > SUPER_SATURATION_THRESHOLD) //supersaturation. Form Tritium.
			super_saturation = TRUE
		if(air.get_moles(GAS_O2) > air.get_moles(GAS_PLASMA)*PLASMA_OXYGEN_FULLBURN)
			plasma_burn_rate = (air.get_moles(GAS_PLASMA)*temperature_scale)/PLASMA_BURN_RATE_DELTA
		else
			plasma_burn_rate = (temperature_scale*(air.get_moles(GAS_O2)/PLASMA_OXYGEN_FULLBURN))/PLASMA_BURN_RATE_DELTA

		if(plasma_burn_rate > MINIMUM_HEAT_CAPACITY)
			plasma_burn_rate = min(plasma_burn_rate,air.get_moles(GAS_PLASMA),air.get_moles(GAS_O2)/oxygen_burn_rate) //Ensures matter is conserved properly
			air.set_moles(GAS_PLASMA, QUANTIZE(air.get_moles(GAS_PLASMA) - plasma_burn_rate))
			air.set_moles(GAS_O2, QUANTIZE(air.get_moles(GAS_O2) - (plasma_burn_rate * oxygen_burn_rate)))
			if (super_saturation)
				air.adjust_moles(GAS_TRITIUM, plasma_burn_rate)
			else
				air.adjust_moles(GAS_CO2, plasma_burn_rate)

			energy_released += FIRE_PLASMA_ENERGY_RELEASED * (plasma_burn_rate)

			cached_results["fire"] += (plasma_burn_rate)*(1+oxygen_burn_rate)

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature((temperature*old_heat_capacity + energy_released)/new_heat_capacity)

	//let the floor know a fire is happening
	if(istype(location))
		temperature = air.return_temperature()
		if(temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			location.hotspot_expose(temperature, CELL_VOLUME)
			for(var/I in location)
				var/atom/movable/item = I
				item.temperature_expose(air, temperature, CELL_VOLUME)
			location.temperature_expose(air, temperature, CELL_VOLUME)

	return cached_results["fire"] ? REACTING : NO_REACTION

/datum/gas_reaction/plasmafire/test()
	var/datum/gas_mixture/G = new
	G.set_moles(GAS_PLASMA,50)
	G.set_moles(GAS_O2,50)
	G.set_volume(1000)
	G.set_temperature(500)
	var/result = G.react()
	if(result != REACTING)
		return list("success" = FALSE, "message" = "Reaction didn't go at all!")
	if(!G.reaction_results["fire"])
		return list("success" = FALSE, "message" = "Plasma fires aren't setting fire results correctly!")
	if(!G.get_moles(GAS_CO2))
		return list("success" = FALSE, "message" = "Plasma fires aren't making CO2!")
	G.clear()
	G.set_moles(GAS_PLASMA,10)
	G.set_moles(GAS_O2,1000)
	G.set_temperature(500)
	result = G.react()
	if(!G.get_moles(GAS_TRITIUM))
		return list("success" = FALSE, "message" = "Plasma fires aren't making trit!")
	return ..()

/datum/gas_reaction/genericfire
	priority = -3 // very last reaction
	name = "Combustion"
	id = "genericfire"

/datum/gas_reaction/genericfire/init_reqs()
	var/lowest_fire_temp = INFINITY
	var/list/fire_temperatures = GLOB.gas_data.fire_temperatures
	for(var/gas in fire_temperatures)
		lowest_fire_temp = min(lowest_fire_temp, fire_temperatures[gas])
	var/lowest_oxi_temp = INFINITY
	var/list/oxidation_temperatures = GLOB.gas_data.oxidation_temperatures
	for(var/gas in oxidation_temperatures)
		lowest_oxi_temp = min(lowest_oxi_temp, oxidation_temperatures[gas])
	min_requirements = list(
		"TEMP" = max(lowest_oxi_temp, lowest_fire_temp),
		"FIRE_REAGENTS" = MINIMUM_MOLE_COUNT
	)

// no requirements, always runs
// bad idea? maybe
// this is overridden by auxmos but, hey, good idea to have it readable

/datum/gas_reaction/genericfire/react(datum/gas_mixture/air, datum/holder)
	var/temperature = air.return_temperature()
	var/list/oxidation_temps = GLOB.gas_data.oxidation_temperatures
	var/list/oxidation_rates = GLOB.gas_data.oxidation_rates
	var/oxidation_power = 0
	var/list/burn_results = list()
	var/list/fuels = list()
	var/list/oxidizers = list()
	var/list/fuel_rates = GLOB.gas_data.fire_burn_rates
	var/list/fuel_temps = GLOB.gas_data.fire_temperatures
	var/total_fuel = 0
	var/energy_released = 0
	for(var/G in air.get_gases())
		var/oxidation_temp = oxidation_temps[G]
		if(oxidation_temp && oxidation_temp > temperature)
			var/temperature_scale = max(0, 1-(temperature / oxidation_temp))
			var/amt = air.get_moles(G) * temperature_scale
			oxidizers[G] = amt
			oxidation_power += amt * oxidation_rates[G]
		else
			var/fuel_temp = fuel_temps[G]
			if(fuel_temp && fuel_temp > temperature)
				var/amt = (air.get_moles(G) / fuel_rates[G]) * max(0, 1-(temperature / fuel_temp))
				fuels[G] = amt // we have to calculate the actual amount we're using after we get all oxidation together
				total_fuel += amt
	if(oxidation_power <= 0 || total_fuel <= 0)
		return NO_REACTION
	var/oxidation_ratio = oxidation_power / total_fuel
	if(oxidation_ratio > 1)
		for(var/oxidizer in oxidizers)
			oxidizers[oxidizer] /= oxidation_ratio
	else if(oxidation_ratio < 1)
		for(var/fuel in fuels)
			fuels[fuel] *= oxidation_ratio
	fuels += oxidizers
	var/list/fire_products = GLOB.gas_data.fire_products
	var/list/fire_enthalpies = GLOB.gas_data.fire_enthalpies
	for(var/fuel in fuels + oxidizers)
		var/amt = fuels[fuel]
		if(!burn_results[fuel])
			burn_results[fuel] = 0
		burn_results[fuel] -= amt
		energy_released += amt * fire_enthalpies[fuel]
		for(var/product in fire_products[fuel])
			if(!burn_results[product])
				burn_results[product] = 0
			burn_results[product] += amt
	var/final_energy = air.thermal_energy() + energy_released
	for(var/result in burn_results)
		air.adjust_moles(result, burn_results[result])
	air.set_temperature(final_energy / air.heat_capacity())
	var/list/cached_results = air.reaction_results
	cached_results["fire"] = min(total_fuel, oxidation_power) * 2
	return cached_results["fire"] ? REACTING : NO_REACTION

//fusion: a terrible idea that was fun but broken. Now reworked to be less broken and more interesting. Again (and again, and again). Again!
//Fusion Rework Counter: Please increment this if you make a major overhaul to this system again.
//6 reworks

/proc/fusion_ball(datum/holder, reaction_energy, instability)
	var/turf/open/location
	if (istype(holder,/datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/fusion_pipenet = holder
		location = get_turf(pick(fusion_pipenet.members))
	else
		location = get_turf(holder)
	if(location)
		var/particle_chance = ((PARTICLE_CHANCE_CONSTANT)/(reaction_energy-PARTICLE_CHANCE_CONSTANT)) + 1//Asymptopically approaches 100% as the energy of the reaction goes up.
		if(prob(PERCENT(particle_chance)))
			location.fire_nuclear_particle()
		var/rad_power = max((FUSION_RAD_COEFFICIENT/instability) + FUSION_RAD_MAX,0)
		radiation_pulse(location,rad_power)

/datum/gas_reaction/fusion
	exclude = FALSE
	priority = 2
	name = "Plasmic Fusion"
	id = "fusion"

/datum/gas_reaction/fusion/init_reqs()
	min_requirements = list(
		"TEMP" = FUSION_TEMPERATURE_THRESHOLD,
		GAS_TRITIUM = FUSION_TRITIUM_MOLES_USED,
		GAS_PLASMA = FUSION_MOLE_THRESHOLD,
		GAS_CO2 = FUSION_MOLE_THRESHOLD)

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
	var/old_heat_capacity = air.heat_capacity()
	var/reaction_energy = 0 //Reaction energy can be negative or positive, for both exothermic and endothermic reactions.
	var/initial_plasma = air.get_moles(GAS_PLASMA)
	var/initial_carbon = air.get_moles(GAS_CO2)
	var/scale_factor = (air.return_volume())/(PI) //We scale it down by volume/Pi because for fusion conditions, moles roughly = 2*volume, but we want it to be based off something constant between reactions.
	var/toroidal_size = (2*PI)+TORADIANS(arctan((air.return_volume()-TOROID_VOLUME_BREAKEVEN)/TOROID_VOLUME_BREAKEVEN)) //The size of the phase space hypertorus
	var/gas_power = 0
	var/list/gas_fusion_powers = GLOB.gas_data.fusion_powers
	for (var/gas_id in air.get_gases())
		gas_power += (gas_fusion_powers[gas_id]*air.get_moles(gas_id))
	var/instability = MODULUS((gas_power*INSTABILITY_GAS_POWER_FACTOR)**2,toroidal_size) //Instability effects how chaotic the behavior of the reaction is
	cached_scan_results["fusion"] = instability//used for analyzer feedback

	var/plasma = (initial_plasma-FUSION_MOLE_THRESHOLD)/(scale_factor) //We have to scale the amounts of carbon and plasma down a significant amount in order to show the chaotic dynamics we want
	var/carbon = (initial_carbon-FUSION_MOLE_THRESHOLD)/(scale_factor) //We also subtract out the threshold amount to make it harder for fusion to burn itself out.

	//The reaction is a specific form of the Kicked Rotator system, which displays chaotic behavior and can be used to model particle interactions.
	plasma = MODULUS(plasma - (instability*sin(TODEGREES(carbon))), toroidal_size)
	carbon = MODULUS(carbon - plasma, toroidal_size)


	air.set_moles(GAS_PLASMA, plasma*scale_factor + FUSION_MOLE_THRESHOLD) //Scales the gases back up
	air.set_moles(GAS_CO2 , carbon*scale_factor + FUSION_MOLE_THRESHOLD)
	var/delta_plasma = initial_plasma - air.get_moles(GAS_PLASMA)

	reaction_energy += delta_plasma*PLASMA_BINDING_ENERGY //Energy is gained or lost corresponding to the creation or destruction of mass.
	if(instability < FUSION_INSTABILITY_ENDOTHERMALITY)
		reaction_energy = max(reaction_energy,0) //Stable reactions don't end up endothermic.
	else if (reaction_energy < 0)
		reaction_energy *= (instability-FUSION_INSTABILITY_ENDOTHERMALITY)**0.5

	if(air.thermal_energy() + reaction_energy < 0) //No using energy that doesn't exist.
		air.set_moles(GAS_PLASMA,initial_plasma)
		air.set_moles(GAS_CO2, initial_carbon)
		return NO_REACTION
	air.adjust_moles(GAS_TRITIUM, -FUSION_TRITIUM_MOLES_USED)
	//The decay of the tritium and the reaction's energy produces waste gases, different ones depending on whether the reaction is endo or exothermic
	if(reaction_energy > 0)
		air.adjust_moles(GAS_O2, FUSION_TRITIUM_MOLES_USED*(reaction_energy*FUSION_TRITIUM_CONVERSION_COEFFICIENT))
		air.adjust_moles(GAS_NITROUS, FUSION_TRITIUM_MOLES_USED*(reaction_energy*FUSION_TRITIUM_CONVERSION_COEFFICIENT))
	else
		air.adjust_moles(GAS_BZ, FUSION_TRITIUM_MOLES_USED*(reaction_energy*-FUSION_TRITIUM_CONVERSION_COEFFICIENT))
		air.adjust_moles(GAS_NITRYL, FUSION_TRITIUM_MOLES_USED*(reaction_energy*-FUSION_TRITIUM_CONVERSION_COEFFICIENT))

	if(reaction_energy)
		if(location)
			var/particle_chance = ((PARTICLE_CHANCE_CONSTANT)/(reaction_energy-PARTICLE_CHANCE_CONSTANT)) + 1//Asymptopically approaches 100% as the energy of the reaction goes up.
			if(prob(PERCENT(particle_chance)))
				location.fire_nuclear_particle()
			var/rad_power = max((FUSION_RAD_COEFFICIENT/instability) + FUSION_RAD_MAX,0)
			radiation_pulse(location,rad_power)

		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(clamp(((air.return_temperature()*old_heat_capacity + reaction_energy)/new_heat_capacity),TCMB,INFINITY))
		return REACTING

/datum/gas_reaction/fusion/test()
	var/datum/gas_mixture/G = new
	G.set_moles(GAS_CO2,300)
	G.set_moles(GAS_PLASMA,1000)
	G.set_moles(GAS_TRITIUM,100.61)
	G.set_moles(GAS_NITRYL,1)
	G.set_temperature(15000)
	G.set_volume(1000)
	var/result = G.react()
	if(result != REACTING)
		return list("success" = FALSE, "message" = "Reaction didn't go at all!")
	if(abs(G.analyzer_results["fusion"] - 3) > 0.0000001)
		var/instability = G.analyzer_results["fusion"]
		return list("success" = FALSE, "message" = "Fusion is not calculating analyzer results correctly, should be 3.000000045, is instead [instability]")
	if(abs(G.get_moles(GAS_PLASMA) - 850.616) > 0.5)
		var/plas = G.get_moles(GAS_PLASMA)
		return list("success" = FALSE, "message" = "Fusion is not calculating plasma correctly, should be 850.616, is instead [plas]")
	if(abs(G.get_moles(GAS_CO2) - 1699.384) > 0.5)
		var/co2 = G.get_moles(GAS_CO2)
		return list("success" = FALSE, "message" = "Fusion is not calculating co2 correctly, should be 1699.384, is instead [co2]")
	if(abs(G.return_temperature() - 27600) > 200) // calculating this manually sucks dude
		var/temp = G.return_temperature()
		return list("success" = FALSE, "message" = "Fusion is not calculating temperature correctly, should be around 27600, is instead [temp]")
	return ..()

/datum/gas_reaction/nitrylformation //The formation of nitryl. Endothermic. Requires N2O as a catalyst.
	priority = 3
	name = "Nitryl formation"
	id = "nitrylformation"

/datum/gas_reaction/nitrylformation/init_reqs()
	min_requirements = list(
		GAS_O2 = 20,
		GAS_N2 = 20,
		GAS_NITROUS = 5,
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST*25
	)

/datum/gas_reaction/nitrylformation/react(datum/gas_mixture/air)
	var/temperature = air.return_temperature()

	var/old_heat_capacity = air.heat_capacity()
	var/heat_efficency = min(temperature/(FIRE_MINIMUM_TEMPERATURE_TO_EXIST*100),air.get_moles(GAS_O2),air.get_moles(GAS_N2))
	var/energy_used = heat_efficency*NITRYL_FORMATION_ENERGY
	if ((air.get_moles(GAS_O2) - heat_efficency < 0 )|| (air.get_moles(GAS_N2) - heat_efficency < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(GAS_O2, -heat_efficency)
	air.adjust_moles(GAS_N2, -heat_efficency)
	air.adjust_moles(GAS_NITRYL, heat_efficency*2)

	if(energy_used > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((temperature*old_heat_capacity - energy_used)/new_heat_capacity),TCMB))
		return REACTING

/datum/gas_reaction/nitrylformation/test()
	var/datum/gas_mixture/G = new
	G.set_moles(GAS_O2,30)
	G.set_moles(GAS_N2,30)
	G.set_moles(GAS_NITROUS,10)
	G.set_volume(1000)
	G.set_temperature(150000)
	var/result = G.react()
	if(result != REACTING)
		return list("success" = FALSE, "message" = "Reaction didn't go at all!")
	if(!G.get_moles(GAS_NITRYL) < 0.8)
		return list("success" = FALSE, "message" = "Nitryl isn't being generated correctly!")
	return ..()

/datum/gas_reaction/bzformation //Formation of BZ by combining plasma and tritium at low pressures. Exothermic.
	priority = 4
	name = "BZ Gas formation"
	id = "bzformation"

/datum/gas_reaction/bzformation/init_reqs()
	min_requirements = list(
		GAS_NITROUS = 10,
		GAS_PLASMA = 10
	)


/datum/gas_reaction/bzformation/react(datum/gas_mixture/air)
	var/temperature = air.return_temperature()
	var/pressure = air.return_pressure()
	var/old_heat_capacity = air.heat_capacity()
	var/reaction_efficency = min(1/((pressure/(0.1*ONE_ATMOSPHERE))*(max(air.get_moles(GAS_PLASMA)/air.get_moles(GAS_NITROUS),1))),air.get_moles(GAS_NITROUS),air.get_moles(GAS_PLASMA)/2)
	var/energy_released = 2*reaction_efficency*FIRE_CARBON_ENERGY_RELEASED
	if ((air.get_moles(GAS_NITROUS) - reaction_efficency < 0 )|| (air.get_moles(GAS_PLASMA) - (2*reaction_efficency) < 0) || energy_released <= 0) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(GAS_BZ, reaction_efficency)
	if(reaction_efficency == air.get_moles(GAS_NITROUS))
		air.adjust_moles(GAS_BZ, -min(pressure,1))
		air.adjust_moles(GAS_O2, min(pressure,1))
	air.adjust_moles(GAS_NITROUS, -reaction_efficency)
	air.adjust_moles(GAS_PLASMA, -2*reaction_efficency)

	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, min((reaction_efficency**2)*BZ_RESEARCH_SCALE),BZ_RESEARCH_MAX_AMOUNT)

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((temperature*old_heat_capacity + energy_released)/new_heat_capacity),TCMB))
		return REACTING

/datum/gas_reaction/bzformation/test()
	var/datum/gas_mixture/G = new
	G.set_moles(GAS_PLASMA,15)
	G.set_moles(GAS_NITROUS,15)
	G.set_volume(1000)
	G.set_temperature(10)
	var/result = G.react()
	if(result != REACTING)
		return list("success" = FALSE, "message" = "Reaction didn't go at all!")
	if(!G.get_moles(GAS_BZ) < 4) // efficiency is 4.0643 and bz generation == efficiency
		return list("success" = FALSE, "message" = "Nitryl isn't being generated correctly!")
	return ..()

/datum/gas_reaction/stimformation //Stimulum formation follows a strange pattern of how effective it will be at a given temperature, having some multiple peaks and some large dropoffs. Exo and endo thermic.
	priority = 5
	name = "Stimulum formation"
	id = "stimformation"

/datum/gas_reaction/stimformation/init_reqs()
	min_requirements = list(
		GAS_TRITIUM = 30,
		GAS_PLASMA = 10,
		GAS_BZ = 20,
		GAS_NITRYL = 30,
		"TEMP" = STIMULUM_HEAT_SCALE/2)

/datum/gas_reaction/stimformation/react(datum/gas_mixture/air)
	var/old_heat_capacity = air.heat_capacity()
	var/heat_scale = min(air.return_temperature()/STIMULUM_HEAT_SCALE,air.get_moles(GAS_TRITIUM),air.get_moles(GAS_PLASMA),air.get_moles(GAS_NITRYL))
	var/stim_energy_change = heat_scale + STIMULUM_FIRST_RISE*(heat_scale**2) - STIMULUM_FIRST_DROP*(heat_scale**3) + STIMULUM_SECOND_RISE*(heat_scale**4) - STIMULUM_ABSOLUTE_DROP*(heat_scale**5)

	if ((air.get_moles(GAS_TRITIUM) - heat_scale < 0 )|| (air.get_moles(GAS_PLASMA) - heat_scale < 0) || (air.get_moles(GAS_NITRYL) - heat_scale < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(GAS_STIMULUM, heat_scale/10)
	air.adjust_moles(GAS_TRITIUM, -heat_scale)
	air.adjust_moles(GAS_PLASMA, -heat_scale)
	air.adjust_moles(GAS_NITRYL, -heat_scale)

	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, STIMULUM_RESEARCH_AMOUNT*max(stim_energy_change,0))
	if(stim_energy_change)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((air.return_temperature()*old_heat_capacity + stim_energy_change)/new_heat_capacity),TCMB))
		return REACTING

/datum/gas_reaction/stimformation/test()
	//above mentioned "strange pattern" is a basic quintic polynomial, it's fine, can calculate it manually
	var/datum/gas_mixture/G = new
	G.set_moles(GAS_BZ,30)
	G.set_moles(GAS_PLASMA,1000)
	G.set_moles(GAS_TRITIUM,1000)
	G.set_moles(GAS_NITRYL,1000)
	G.set_volume(1000)
	G.set_temperature(12998000) // yeah, really

	var/result = G.react()
	if(result != REACTING)
		return list("success" = FALSE, "message" = "Reaction didn't go at all!")
	if(!G.get_moles(GAS_STIMULUM) < 900)
		return list("success" = FALSE, "message" = "Stimulum isn't being generated correctly!")
	return ..()

/datum/gas_reaction/nobliumformation //Hyper-Noblium formation is extrememly endothermic, but requires high temperatures to start. Due to its high mass, hyper-nobelium uses large amounts of nitrogen and tritium. BZ can be used as a catalyst to make it less endothermic.
	priority = 6
	name = "Hyper-Noblium condensation"
	id = "nobformation"

/datum/gas_reaction/nobliumformation/init_reqs()
	min_requirements = list(
		GAS_N2 = 10,
		GAS_TRITIUM = 5,
		"ENER" = NOBLIUM_FORMATION_ENERGY)

/datum/gas_reaction/nobliumformation/react(datum/gas_mixture/air)
	var/old_heat_capacity = air.heat_capacity()
	var/nob_formed = min((air.get_moles(GAS_N2)+air.get_moles(GAS_TRITIUM))/100,air.get_moles(GAS_TRITIUM)/10,air.get_moles(GAS_N2)/20)
	var/energy_taken = nob_formed*(NOBLIUM_FORMATION_ENERGY/(max(air.get_moles(GAS_BZ),1)))
	if ((air.get_moles(GAS_TRITIUM) - 10*nob_formed < 0) || (air.get_moles(GAS_N2) - 20*nob_formed < 0))
		return NO_REACTION
	air.adjust_moles(GAS_TRITIUM, -10*nob_formed)
	air.adjust_moles(GAS_N2, -20*nob_formed)
	air.adjust_moles(GAS_HYPERNOB,nob_formed)

	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, nob_formed*NOBLIUM_RESEARCH_AMOUNT)

	if (nob_formed)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((air.return_temperature()*old_heat_capacity - energy_taken)/new_heat_capacity),TCMB))

/datum/gas_reaction/nobliumformation/test()
	var/datum/gas_mixture/G = new
	G.set_moles(GAS_N2,100)
	G.set_moles(GAS_TRITIUM,500)
	G.set_volume(1000)
	G.set_temperature(5000000) // yeah, really
	var/result = G.react()
	if(result != REACTING)
		return list("success" = FALSE, "message" = "Reaction didn't go at all!")
	if(abs(G.thermal_energy() - 23000000000) > 1000000) // god i hate floating points
		return list("success" = FALSE, "message" = "Hyper-nob formation isn't removing the right amount of heat! Should be 23,000,000,000, is instead [G.thermal_energy()]")
	return ..()


/datum/gas_reaction/miaster	//dry heat sterilization: clears out pathogens in the air
	priority = -10 //after all the heating from fires etc. is done
	name = "Dry Heat Sterilization"
	id = "sterilization"

/datum/gas_reaction/miaster/init_reqs()
	min_requirements = list(
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST+70,
		GAS_MIASMA = MINIMUM_MOLE_COUNT
	)

/datum/gas_reaction/miaster/react(datum/gas_mixture/air, datum/holder)
	// As the name says it, it needs to be dry
	if(air.get_moles(GAS_H2O) && air.get_moles(GAS_H2O)/air.total_moles() > 0.1)
		return

	//Replace miasma with oxygen
	var/cleaned_air = min(air.get_moles(GAS_MIASMA), 20 + (air.return_temperature() - FIRE_MINIMUM_TEMPERATURE_TO_EXIST - 70) / 20)
	air.adjust_moles(GAS_MIASMA, -cleaned_air)
	air.adjust_moles(GAS_O2, cleaned_air)

	//Possibly burning a bit of organic matter through maillard reaction, so a *tiny* bit more heat would be understandable
	air.set_temperature(air.return_temperature() + cleaned_air * 0.002)
	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, cleaned_air*MIASMA_RESEARCH_AMOUNT)//Turns out the burning of miasma is kinda interesting to scientists

/datum/gas_reaction/miaster/test()
	var/datum/gas_mixture/G = new
	G.set_moles(GAS_MIASMA,1)
	G.set_volume(1000)
	G.set_temperature(450)
	var/result = G.react()
	if(result != REACTING)
		return list("success" = FALSE, "message" = "Reaction didn't go at all!")
	G.clear()
	G.set_moles(GAS_MIASMA,1)
	G.set_temperature(450)
	G.set_moles(GAS_H2O,0.5)
	result = G.react()
	if(result != NO_REACTION)
		return list("success" = FALSE, "message" = "Miasma sterilization not stopping due to water vapor correctly!")
	return ..()
