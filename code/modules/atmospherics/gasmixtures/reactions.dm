//All defines used in reactions are located in ..\__DEFINES\reactions.dm

/proc/init_gas_reactions()
	. = list()
	for(var/type in subtypesof(/datum/gas))
		.[type] = list()

	for(var/r in subtypesof(/datum/gas_reaction))
		var/datum/gas_reaction/reaction = r
		if(initial(reaction.exclude))
			continue
		reaction = new r
		var/datum/gas/reaction_key
		for (var/req in reaction.min_requirements)
			if (ispath(req))
				var/datum/gas/req_gas = req
				if (!reaction_key || initial(reaction_key.rarity) > initial(req_gas.rarity))
					reaction_key = req_gas
		.[reaction_key] += list(reaction)
		sortTim(., /proc/cmp_gas_reactions, TRUE)

/proc/cmp_gas_reactions(list/datum/gas_reaction/a, list/datum/gas_reaction/b) // compares lists of reactions by the maximum priority contained within the list
	if (!length(a) || !length(b))
		return length(b) - length(a)
	var/maxa
	var/maxb
	for (var/datum/gas_reaction/R in a)
		if (R.priority > maxa)
			maxa = R.priority
	for (var/datum/gas_reaction/R in b)
		if (R.priority > maxb)
			maxb = R.priority
	return maxb - maxa

/datum/gas_reaction
	//regarding the requirements lists: the minimum or maximum requirements must be non-zero.
	//when in doubt, use MINIMUM_MOLE_COUNT.
	var/list/min_requirements
	var/major_gas //the highest rarity gas used in the reaction.
	var/exclude = FALSE //do it this way to allow for addition/removal of reactions midmatch in the future
	var/priority = 100 //lower numbers are checked/react later than higher numbers. if two reactions have the same priority they may happen in either order
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
	min_requirements = list(/datum/gas/hypernoblium = REACTION_OPPRESSION_THRESHOLD)

/datum/gas_reaction/nobliumsupression/react()
	return STOP_REACTIONS

//water vapor: puts out fires?
/datum/gas_reaction/water_vapor
	priority = 1
	name = "Water Vapor"
	id = "vapor"

/datum/gas_reaction/water_vapor/init_reqs()
	min_requirements = list(/datum/gas/water_vapor = MOLES_GAS_VISIBLE)

/datum/gas_reaction/water_vapor/react(datum/gas_mixture/air, datum/holder)
	var/turf/open/location = isturf(holder) ? holder : null
	. = NO_REACTION
	if (air.return_temperature() <= WATER_VAPOR_FREEZE)
		if(location && location.freon_gas_act())
			. = REACTING
	else if(location && location.water_vapor_gas_act())
		air.adjust_moles(/datum/gas/water_vapor, -MOLES_GAS_VISIBLE)
		. = REACTING

//tritium combustion: combustion of oxygen and tritium (treated as hydrocarbons). creates hotspots. exothermic
/datum/gas_reaction/nitrous_decomp
	priority = 0
	name = "Nitrous Oxide Decomposition"
	id = "nitrous_decomp"

/datum/gas_reaction/nitrous_decomp/init_reqs()
	min_requirements = list(
		"TEMP" = N2O_DECOMPOSITION_MIN_ENERGY,
		/datum/gas/nitrous_oxide = MINIMUM_MOLE_COUNT
	)

/datum/gas_reaction/nitrous_decomp/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity() //this speeds things up because accessing datum vars is slow
	var/temperature = air.return_temperature()
	var/burned_fuel = 0


	burned_fuel = max(0,0.00002*(temperature-(0.00001*(temperature**2))))*air.get_moles(/datum/gas/nitrous_oxide)
	air.set_moles(/datum/gas/nitrous_oxide, air.get_moles(/datum/gas/nitrous_oxide) - burned_fuel)

	if(burned_fuel)
		energy_released += (N2O_DECOMPOSITION_ENERGY_RELEASED * burned_fuel)

		air.set_moles(/datum/gas/oxygen, air.get_moles(/datum/gas/oxygen) + burned_fuel/2)
		air.set_moles(/datum/gas/nitrogen, air.get_moles(/datum/gas/nitrogen) + burned_fuel)

		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature((temperature*old_heat_capacity + energy_released)/new_heat_capacity)
		return REACTING
	return NO_REACTION

//tritium combustion: combustion of oxygen and tritium (treated as hydrocarbons). creates hotspots. exothermic
/datum/gas_reaction/tritfire
	priority = -1 //fire should ALWAYS be last, but tritium fires happen before plasma fires
	name = "Tritium Combustion"
	id = "tritfire"

/datum/gas_reaction/tritfire/init_reqs()
	min_requirements = list(
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST,
		/datum/gas/tritium = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT
	)

/datum/gas_reaction/tritfire/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/temperature = air.return_temperature()
	var/list/cached_results = air.reaction_results
	cached_results["fire"] = 0
	var/turf/open/location = isturf(holder) ? holder : null
	var/burned_fuel = 0
	var/initial_trit = air.get_moles(/datum/gas/tritium)// Yogs
	if(air.get_moles(/datum/gas/oxygen) < initial_trit || MINIMUM_TRIT_OXYBURN_ENERGY > (temperature * old_heat_capacity))// Yogs -- Maybe a tiny performance boost? I'unno
		burned_fuel = air.get_moles(/datum/gas/oxygen)/TRITIUM_BURN_OXY_FACTOR
		if(burned_fuel > initial_trit) burned_fuel = initial_trit //Yogs -- prevents negative moles of Tritium
		air.adjust_moles(/datum/gas/tritium, -burned_fuel)
	else
		burned_fuel = initial_trit // Yogs -- Conservation of Mass fix
		air.set_moles(/datum/gas/tritium, air.get_moles(/datum/gas/tritium) * (1 - 1/TRITIUM_BURN_TRIT_FACTOR)) // Yogs -- Maybe a tiny performance boost? I'unno
		air.adjust_moles(/datum/gas/oxygen, -air.get_moles(/datum/gas/tritium))
		energy_released += (FIRE_HYDROGEN_ENERGY_RELEASED * burned_fuel * (TRITIUM_BURN_TRIT_FACTOR - 1)) // Yogs -- Fixes low-energy tritium fires

	if(burned_fuel)
		energy_released += (FIRE_HYDROGEN_ENERGY_RELEASED * burned_fuel)
		if(location && prob(10) && burned_fuel > TRITIUM_MINIMUM_RADIATION_ENERGY) //woah there let's not crash the server
			radiation_pulse(location, energy_released/TRITIUM_BURN_RADIOACTIVITY_FACTOR)

		//oxygen+more-or-less hydrogen=H2O
		air.adjust_moles(/datum/gas/water_vapor, burned_fuel )// Yogs -- Conservation of Mass

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

//plasma combustion: combustion of oxygen and plasma (treated as hydrocarbons). creates hotspots. exothermic
/datum/gas_reaction/plasmafire
	priority = -2 //fire should ALWAYS be last, but plasma fires happen after tritium fires
	name = "Plasma Combustion"
	id = "plasmafire"

/datum/gas_reaction/plasmafire/init_reqs()
	min_requirements = list(
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST,
		/datum/gas/plasma = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT
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
		if(air.get_moles(/datum/gas/oxygen) / air.get_moles(/datum/gas/plasma) > SUPER_SATURATION_THRESHOLD) //supersaturation. Form Tritium.
			super_saturation = TRUE
		if(air.get_moles(/datum/gas/oxygen) > air.get_moles(/datum/gas/plasma)*PLASMA_OXYGEN_FULLBURN)
			plasma_burn_rate = (air.get_moles(/datum/gas/plasma)*temperature_scale)/PLASMA_BURN_RATE_DELTA
		else
			plasma_burn_rate = (temperature_scale*(air.get_moles(/datum/gas/oxygen)/PLASMA_OXYGEN_FULLBURN))/PLASMA_BURN_RATE_DELTA

		if(plasma_burn_rate > MINIMUM_HEAT_CAPACITY)
			plasma_burn_rate = min(plasma_burn_rate,air.get_moles(/datum/gas/plasma),air.get_moles(/datum/gas/oxygen)/oxygen_burn_rate) //Ensures matter is conserved properly
			air.set_moles(/datum/gas/plasma, QUANTIZE(air.get_moles(/datum/gas/plasma) - plasma_burn_rate))
			air.set_moles(/datum/gas/oxygen, QUANTIZE(air.get_moles(/datum/gas/oxygen) - (plasma_burn_rate * oxygen_burn_rate)))
			if (super_saturation)
				air.adjust_moles(/datum/gas/tritium, plasma_burn_rate)
			else
				air.adjust_moles(/datum/gas/carbon_dioxide, plasma_burn_rate)

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

//fusion: a terrible idea that was fun but broken. Now reworked to be less broken and more interesting. Again (and again, and again). Again!
//Fusion Rework Counter: Please increment this if you make a major overhaul to this system again.
//6 reworks

/datum/gas_reaction/fusion
	exclude = FALSE
	priority = 2
	name = "Plasmic Fusion"
	id = "fusion"

/datum/gas_reaction/fusion/init_reqs()
	min_requirements = list(
		"TEMP" = FUSION_TEMPERATURE_THRESHOLD,
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
	var/old_heat_capacity = air.heat_capacity()
	var/reaction_energy = 0 //Reaction energy can be negative or positive, for both exothermic and endothermic reactions.
	var/initial_plasma = air.get_moles(/datum/gas/plasma)
	var/initial_carbon = air.get_moles(/datum/gas/carbon_dioxide)
	var/scale_factor = (air.return_volume())/(PI) //We scale it down by volume/Pi because for fusion conditions, moles roughly = 2*volume, but we want it to be based off something constant between reactions.
	var/toroidal_size = (2*PI)+TORADIANS(arctan((air.return_volume()-TOROID_VOLUME_BREAKEVEN)/TOROID_VOLUME_BREAKEVEN)) //The size of the phase space hypertorus
	var/gas_power = 0
	for (var/gas_id in air.get_gases())
		gas_power += (GLOB.meta_gas_info[gas_id][META_GAS_FUSION_POWER]*air.get_moles(gas_id))
	var/instability = MODULUS((gas_power*INSTABILITY_GAS_POWER_FACTOR)**2,toroidal_size) //Instability effects how chaotic the behavior of the reaction is
	cached_scan_results[id] = instability//used for analyzer feedback

	var/plasma = (initial_plasma-FUSION_MOLE_THRESHOLD)/(scale_factor) //We have to scale the amounts of carbon and plasma down a significant amount in order to show the chaotic dynamics we want
	var/carbon = (initial_carbon-FUSION_MOLE_THRESHOLD)/(scale_factor) //We also subtract out the threshold amount to make it harder for fusion to burn itself out.

	//The reaction is a specific form of the Kicked Rotator system, which displays chaotic behavior and can be used to model particle interactions.
	plasma = MODULUS(plasma - (instability*sin(TODEGREES(carbon))), toroidal_size)
	carbon = MODULUS(carbon - plasma, toroidal_size)


	air.set_moles(/datum/gas/plasma, plasma*scale_factor + FUSION_MOLE_THRESHOLD )//Scales the gases back up
	air.set_moles(/datum/gas/carbon_dioxide, carbon*scale_factor + FUSION_MOLE_THRESHOLD)
	var/delta_plasma = initial_plasma - air.get_moles(/datum/gas/plasma)

	reaction_energy += delta_plasma*PLASMA_BINDING_ENERGY //Energy is gained or lost corresponding to the creation or destruction of mass.
	if(instability < FUSION_INSTABILITY_ENDOTHERMALITY)
		reaction_energy = max(reaction_energy,0) //Stable reactions don't end up endothermic.
	else if (reaction_energy < 0)
		reaction_energy *= (instability-FUSION_INSTABILITY_ENDOTHERMALITY)**0.5

	if(air.thermal_energy() + reaction_energy < 0) //No using energy that doesn't exist.
		air.set_moles(/datum/gas/plasma, initial_plasma)
		air.set_moles(/datum/gas/carbon_dioxide, initial_carbon)
		return NO_REACTION
	air.adjust_moles(/datum/gas/tritium, -FUSION_TRITIUM_MOLES_USED)
	//The decay of the tritium and the reaction's energy produces waste gases, different ones depending on whether the reaction is endo or exothermic
	if(reaction_energy > 0)
		air.adjust_moles(/datum/gas/oxygen, FUSION_TRITIUM_MOLES_USED*(reaction_energy*FUSION_TRITIUM_CONVERSION_COEFFICIENT))
		air.adjust_moles(/datum/gas/nitrous_oxide, FUSION_TRITIUM_MOLES_USED*(reaction_energy*FUSION_TRITIUM_CONVERSION_COEFFICIENT))
	else
		air.adjust_moles(/datum/gas/bz, FUSION_TRITIUM_MOLES_USED*(reaction_energy*-FUSION_TRITIUM_CONVERSION_COEFFICIENT))
		air.adjust_moles(/datum/gas/nitryl, FUSION_TRITIUM_MOLES_USED*(reaction_energy*-FUSION_TRITIUM_CONVERSION_COEFFICIENT))

	if(reaction_energy)
		if(location)
			var/particle_chance = ((PARTICLE_CHANCE_CONSTANT)/(reaction_energy-PARTICLE_CHANCE_CONSTANT)) + 1//Asymptopically approaches 100% as the energy of the reaction goes up.
			if(prob(PERCENT(particle_chance)))
				location.fire_nuclear_particle()
			var/rad_power = max((FUSION_RAD_COEFFICIENT/instability) + FUSION_RAD_MAX,0)
			radiation_pulse(location,rad_power)

		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(CLAMP(((air.return_temperature()*old_heat_capacity + reaction_energy)/new_heat_capacity),TCMB,INFINITY))
		return REACTING

/datum/gas_reaction/nitrylformation //The formation of nitryl. Endothermic. Requires N2O as a catalyst.
	priority = 3
	name = "Nitryl formation"
	id = "nitrylformation"

/datum/gas_reaction/nitrylformation/init_reqs()
	min_requirements = list(
		/datum/gas/oxygen = 20,
		/datum/gas/nitrogen = 20,
		/datum/gas/pluoxium = 5, //Gates Nitryl behind pluoxium to offset N2O burning up during formation
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST*60
	)

/datum/gas_reaction/nitrylformation/react(datum/gas_mixture/air)
	var/temperature = air.return_temperature()

	var/old_heat_capacity = air.heat_capacity()
	var/heat_efficency = min(temperature/(FIRE_MINIMUM_TEMPERATURE_TO_EXIST*60),air.get_moles(/datum/gas/oxygen),air.get_moles(/datum/gas/nitrogen))
	var/energy_used = heat_efficency*NITRYL_FORMATION_ENERGY
	if ((air.get_moles(/datum/gas/oxygen) - heat_efficency < 0 )|| (air.get_moles(/datum/gas/nitrogen) - heat_efficency < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(/datum/gas/oxygen, -heat_efficency)
	air.adjust_moles(/datum/gas/nitrogen, -heat_efficency)
	air.adjust_moles(/datum/gas/nitryl, heat_efficency*2)

	if(energy_used > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((temperature*old_heat_capacity - energy_used)/new_heat_capacity),TCMB))
		return REACTING

/datum/gas_reaction/bzformation //Formation of BZ by combining plasma and tritium at low pressures. Exothermic.
	priority = 4
	name = "BZ Gas formation"
	id = "bzformation"

/datum/gas_reaction/bzformation/init_reqs()
	min_requirements = list(
		/datum/gas/nitrous_oxide = 10,
		/datum/gas/plasma = 10
	)


/datum/gas_reaction/bzformation/react(datum/gas_mixture/air)
	var/temperature = air.return_temperature()
	var/pressure = air.return_pressure()
	var/old_heat_capacity = air.heat_capacity()
	var/reaction_efficency = min(1/((pressure/(0.5*ONE_ATMOSPHERE))*(max(air.get_moles(/datum/gas/plasma)/air.get_moles(/datum/gas/nitrous_oxide),1))),air.get_moles(/datum/gas/nitrous_oxide),air.get_moles(/datum/gas/plasma)/2)
	var/energy_released = 2*reaction_efficency*FIRE_CARBON_ENERGY_RELEASED
	if ((air.get_moles(/datum/gas/nitrous_oxide) - reaction_efficency < 0 )|| (air.get_moles(/datum/gas/plasma) - (2*reaction_efficency) < 0) || energy_released <= 0) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(/datum/gas/bz, reaction_efficency)
	if(reaction_efficency == air.get_moles(/datum/gas/nitrous_oxide))
		air.adjust_moles(/datum/gas/bz, -min(pressure,1))
		air.adjust_moles(/datum/gas/oxygen, min(pressure,1))
	air.adjust_moles(/datum/gas/nitrous_oxide, -reaction_efficency)
	air.adjust_moles(/datum/gas/plasma, -2*reaction_efficency)

	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, min((reaction_efficency**2)*BZ_RESEARCH_SCALE),BZ_RESEARCH_MAX_AMOUNT)

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((temperature*old_heat_capacity + energy_released)/new_heat_capacity),TCMB))
		return REACTING

/datum/gas_reaction/stimformation //Stimulum formation follows a strange pattern of how effective it will be at a given temperature, having some multiple peaks and some large dropoffs. Exo and endo thermic.
	priority = 5
	name = "Stimulum formation"
	id = "stimformation"

/datum/gas_reaction/stimformation/init_reqs()
	min_requirements = list(
		/datum/gas/tritium = 30,
		/datum/gas/plasma = 10,
		/datum/gas/bz = 20,
		/datum/gas/nitryl = 30,
		"TEMP" = STIMULUM_HEAT_SCALE/2)

/datum/gas_reaction/stimformation/react(datum/gas_mixture/air)

	var/old_heat_capacity = air.heat_capacity()
	var/heat_scale = min(air.return_temperature()/STIMULUM_HEAT_SCALE,air.get_moles(/datum/gas/plasma),air.get_moles(/datum/gas/nitryl))
	var/stim_energy_change = heat_scale + STIMULUM_FIRST_RISE*(heat_scale**2) - STIMULUM_FIRST_DROP*(heat_scale**3) + STIMULUM_SECOND_RISE*(heat_scale**4) - STIMULUM_ABSOLUTE_DROP*(heat_scale**5)

	if ((air.get_moles(/datum/gas/plasma) - heat_scale < 0) || (air.get_moles(/datum/gas/nitryl) - heat_scale < 0) || (air.get_moles(/datum/gas/tritium) - heat_scale < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	air.adjust_moles(/datum/gas/stimulum, heat_scale/10)
	air.adjust_moles(/datum/gas/plasma, -heat_scale)
	air.adjust_moles(/datum/gas/nitryl, -heat_scale)
	air.adjust_moles(/datum/gas/tritium, -heat_scale)
	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, STIMULUM_RESEARCH_AMOUNT*max(stim_energy_change,0))
	if(stim_energy_change)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((air.return_temperature()*old_heat_capacity + stim_energy_change)/new_heat_capacity),TCMB))
		return REACTING

/datum/gas_reaction/nobliumformation //Hyper-Noblium formation is extrememly endothermic, but requires high temperatures to start. Due to its high mass, hyper-nobelium uses large amounts of nitrogen and tritium. BZ can be used as a catalyst to make it less endothermic.
	priority = 6
	name = "Hyper-Noblium condensation"
	id = "nobformation"

/datum/gas_reaction/nobliumformation/init_reqs()
	min_requirements = list(
		/datum/gas/nitrogen = 10,
		/datum/gas/tritium = 5,
		"TEMP" = 5000000)

/datum/gas_reaction/nobliumformation/react(datum/gas_mixture/air)
	var/old_heat_capacity = air.heat_capacity()
	var/nob_formed = min((air.get_moles(/datum/gas/nitrogen)+air.get_moles(/datum/gas/tritium))/100,air.get_moles(/datum/gas/tritium)/10,air.get_moles(/datum/gas/nitrogen)/20)
	var/energy_taken = nob_formed*(NOBLIUM_FORMATION_ENERGY/(max(air.get_moles(/datum/gas/bz),1)))
	if ((air.get_moles(/datum/gas/tritium) - 10*nob_formed < 0) || (air.get_moles(/datum/gas/nitrogen) - 20*nob_formed < 0))
		return NO_REACTION
	air.adjust_moles(/datum/gas/tritium, -10*nob_formed)
	air.adjust_moles(/datum/gas/nitrogen, -20*nob_formed)
	air.adjust_moles(/datum/gas/hypernoblium, nob_formed)
	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, nob_formed*NOBLIUM_RESEARCH_AMOUNT)

	if (nob_formed)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(max(((air.return_temperature()*old_heat_capacity - energy_taken)/new_heat_capacity),TCMB))


/datum/gas_reaction/miaster	//dry heat sterilization: clears out pathogens in the air
	priority = -10 //after all the heating from fires etc. is done
	name = "Dry Heat Sterilization"
	id = "sterilization"

/datum/gas_reaction/miaster/init_reqs()
	min_requirements = list(
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST+70,
		/datum/gas/miasma = MINIMUM_MOLE_COUNT
	)

/datum/gas_reaction/miaster/react(datum/gas_mixture/air, datum/holder)
	// As the name says it, it needs to be dry
	if(air.get_moles(/datum/gas/water_vapor)/air.total_moles() > 0.1)
		return

	//Replace miasma with oxygen
	var/cleaned_air = min(air.get_moles(/datum/gas/miasma), 20 + (air.return_temperature() - FIRE_MINIMUM_TEMPERATURE_TO_EXIST - 70) / 20)
	air.adjust_moles(/datum/gas/miasma, -cleaned_air)
	air.adjust_moles(/datum/gas/oxygen, cleaned_air)

	//Possibly burning a bit of organic matter through maillard reaction, so a *tiny* bit more heat would be understandable
	air.set_temperature(air.return_temperature() + cleaned_air * 0.002)
	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, cleaned_air*MIASMA_RESEARCH_AMOUNT)//Turns out the burning of miasma is kinda interesting to scientists
// BEGIN
/datum/gas_reaction/space_drugs
    priority = 1
    name = "space_drugs"
    id = "space_drugs"


/datum/gas_reaction/space_drugs/init_reqs()
	min_requirements = list(
		/datum/gas/mercury = 1,
		/datum/gas/sugar = 1,
		/datum/gas/lithium = 1
	)


/datum/gas_reaction/space_drugs/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/mercury) + air.get_moles(/datum/gas/sugar) + air.get_moles(/datum/gas/lithium)
	remove_air = air.get_moles(/datum/gas/mercury)
	air.adjust_moles(/datum/gas/mercury, -remove_air)
	remove_air = air.get_moles(/datum/gas/sugar)
	air.adjust_moles(/datum/gas/sugar, -remove_air)
	remove_air = air.get_moles(/datum/gas/lithium)
	air.adjust_moles(/datum/gas/lithium, -remove_air)
	air.adjust_moles(/datum/gas/space_drugs, cleaned_air)

/datum/gas_reaction/crank
    priority = 1
    name = "crank"
    id = "crank"


/datum/gas_reaction/crank/init_reqs()
	min_requirements = list(
		/datum/gas/diphenhydramine = 1,
		/datum/gas/ammonia = 1,
		/datum/gas/lithium = 1,
		/datum/gas/acid = 1,
		/datum/gas/fuel = 1,
		"TEMP" = 390)

/datum/gas_reaction/crank/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/diphenhydramine) + air.get_moles(/datum/gas/ammonia) + air.get_moles(/datum/gas/lithium) + air.get_moles(/datum/gas/acid) + air.get_moles(/datum/gas/fuel)
	remove_air = air.get_moles(/datum/gas/diphenhydramine)
	air.adjust_moles(/datum/gas/diphenhydramine, -remove_air)
	remove_air = air.get_moles(/datum/gas/ammonia)
	air.adjust_moles(/datum/gas/ammonia, -remove_air)
	remove_air = air.get_moles(/datum/gas/lithium)
	air.adjust_moles(/datum/gas/lithium, -remove_air)
	remove_air = air.get_moles(/datum/gas/acid)
	air.adjust_moles(/datum/gas/acid, -remove_air)
	remove_air = air.get_moles(/datum/gas/fuel)
	air.adjust_moles(/datum/gas/fuel, -remove_air)
	air.adjust_moles(/datum/gas/crank, cleaned_air)

/datum/gas_reaction/krokodil
    priority = 1
    name = "krokodil"
    id = "krokodil"


/datum/gas_reaction/krokodil/init_reqs()
	min_requirements = list(
		/datum/gas/diphenhydramine = 1,
		/datum/gas/morphine = 1,
		/datum/gas/space_cleaner = 1,
		/datum/gas/potassium = 1,
		/datum/gas/phosphorus = 1,
		/datum/gas/fuel = 1,
		"TEMP" = 380)

/datum/gas_reaction/krokodil/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/diphenhydramine) + air.get_moles(/datum/gas/morphine) + air.get_moles(/datum/gas/space_cleaner) + air.get_moles(/datum/gas/potassium) + air.get_moles(/datum/gas/phosphorus) + air.get_moles(/datum/gas/fuel)
	remove_air = air.get_moles(/datum/gas/diphenhydramine)
	air.adjust_moles(/datum/gas/diphenhydramine, -remove_air)
	remove_air = air.get_moles(/datum/gas/morphine)
	air.adjust_moles(/datum/gas/morphine, -remove_air)
	remove_air = air.get_moles(/datum/gas/space_cleaner)
	air.adjust_moles(/datum/gas/space_cleaner, -remove_air)
	remove_air = air.get_moles(/datum/gas/potassium)
	air.adjust_moles(/datum/gas/potassium, -remove_air)
	remove_air = air.get_moles(/datum/gas/phosphorus)
	air.adjust_moles(/datum/gas/phosphorus, -remove_air)
	remove_air = air.get_moles(/datum/gas/fuel)
	air.adjust_moles(/datum/gas/fuel, -remove_air)
	air.adjust_moles(/datum/gas/krokodil, cleaned_air)

/datum/gas_reaction/methamphetamine
    priority = 1
    name = "methamphetamine"
    id = "methamphetamine"


/datum/gas_reaction/methamphetamine/init_reqs()
	min_requirements = list(
		/datum/gas/ephedrine = 1,
		/datum/gas/iodine = 1,
		/datum/gas/phosphorus = 1,
		/datum/gas/hydrogen = 1,
		"TEMP" = 374)

/datum/gas_reaction/methamphetamine/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/ephedrine) + air.get_moles(/datum/gas/iodine) + air.get_moles(/datum/gas/phosphorus) + air.get_moles(/datum/gas/hydrogen)
	remove_air = air.get_moles(/datum/gas/ephedrine)
	air.adjust_moles(/datum/gas/ephedrine, -remove_air)
	remove_air = air.get_moles(/datum/gas/iodine)
	air.adjust_moles(/datum/gas/iodine, -remove_air)
	remove_air = air.get_moles(/datum/gas/phosphorus)
	air.adjust_moles(/datum/gas/phosphorus, -remove_air)
	remove_air = air.get_moles(/datum/gas/hydrogen)
	air.adjust_moles(/datum/gas/hydrogen, -remove_air)
	air.adjust_moles(/datum/gas/methamphetamine, cleaned_air)

/datum/gas_reaction/bath_salts
    priority = 1
    name = "bath_salts"
    id = "bath_salts"


/datum/gas_reaction/bath_salts/init_reqs()
	min_requirements = list(
		/datum/gas/bad_food = 1,
		/datum/gas/saltpetre = 1,
		/datum/gas/nutriment = 1,
		/datum/gas/space_cleaner = 1,
		/datum/gas/enzyme = 1,
		/datum/gas/tea = 1,
		/datum/gas/mercury = 1,
		"TEMP" = 374)

/datum/gas_reaction/bath_salts/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/bad_food) + air.get_moles(/datum/gas/saltpetre) + air.get_moles(/datum/gas/nutriment) + air.get_moles(/datum/gas/space_cleaner) + air.get_moles(/datum/gas/enzyme) + air.get_moles(/datum/gas/tea) + air.get_moles(/datum/gas/mercury)
	remove_air = air.get_moles(/datum/gas/bad_food)
	air.adjust_moles(/datum/gas/bad_food, -remove_air)
	remove_air = air.get_moles(/datum/gas/saltpetre)
	air.adjust_moles(/datum/gas/saltpetre, -remove_air)
	remove_air = air.get_moles(/datum/gas/nutriment)
	air.adjust_moles(/datum/gas/nutriment, -remove_air)
	remove_air = air.get_moles(/datum/gas/space_cleaner)
	air.adjust_moles(/datum/gas/space_cleaner, -remove_air)
	remove_air = air.get_moles(/datum/gas/enzyme)
	air.adjust_moles(/datum/gas/enzyme, -remove_air)
	remove_air = air.get_moles(/datum/gas/tea)
	air.adjust_moles(/datum/gas/tea, -remove_air)
	remove_air = air.get_moles(/datum/gas/mercury)
	air.adjust_moles(/datum/gas/mercury, -remove_air)
	air.adjust_moles(/datum/gas/bath_salts, cleaned_air)

/datum/gas_reaction/aranesp
    priority = 1
    name = "aranesp"
    id = "aranesp"


/datum/gas_reaction/aranesp/init_reqs()
	min_requirements = list(
		/datum/gas/epinephrine = 1,
		/datum/gas/atropine = 1,
		/datum/gas/morphine = 1
	)


/datum/gas_reaction/aranesp/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/epinephrine) + air.get_moles(/datum/gas/atropine) + air.get_moles(/datum/gas/morphine)
	remove_air = air.get_moles(/datum/gas/epinephrine)
	air.adjust_moles(/datum/gas/epinephrine, -remove_air)
	remove_air = air.get_moles(/datum/gas/atropine)
	air.adjust_moles(/datum/gas/atropine, -remove_air)
	remove_air = air.get_moles(/datum/gas/morphine)
	air.adjust_moles(/datum/gas/morphine, -remove_air)
	air.adjust_moles(/datum/gas/aranesp, cleaned_air)

/datum/gas_reaction/happiness
    priority = 1
    name = "happiness"
    id = "happiness"


/datum/gas_reaction/happiness/init_reqs()
	min_requirements = list(
		/datum/gas/nitrous_oxide = 2,
		/datum/gas/epinephrine = 2,
		/datum/gas/ethanol = 2
	)


/datum/gas_reaction/happiness/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/nitrous_oxide) + air.get_moles(/datum/gas/epinephrine) + air.get_moles(/datum/gas/ethanol)
	remove_air = air.get_moles(/datum/gas/nitrous_oxide)
	air.adjust_moles(/datum/gas/nitrous_oxide, -remove_air)
	remove_air = air.get_moles(/datum/gas/epinephrine)
	air.adjust_moles(/datum/gas/epinephrine, -remove_air)
	remove_air = air.get_moles(/datum/gas/ethanol)
	air.adjust_moles(/datum/gas/ethanol, -remove_air)
	air.adjust_moles(/datum/gas/happiness, cleaned_air)

/datum/gas_reaction/leporazine
    priority = 1
    name = "leporazine"
    id = "leporazine"


/datum/gas_reaction/leporazine/init_reqs()
	min_requirements = list(
		/datum/gas/silicon = 1,
		/datum/gas/copper = 1
	)


/datum/gas_reaction/leporazine/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/silicon) + air.get_moles(/datum/gas/copper)
	remove_air = air.get_moles(/datum/gas/silicon)
	air.adjust_moles(/datum/gas/silicon, -remove_air)
	remove_air = air.get_moles(/datum/gas/copper)
	air.adjust_moles(/datum/gas/copper, -remove_air)
	air.adjust_moles(/datum/gas/leporazine, cleaned_air)

/datum/gas_reaction/rezadone
    priority = 1
    name = "rezadone"
    id = "rezadone"


/datum/gas_reaction/rezadone/init_reqs()
	min_requirements = list(
		/datum/gas/carpotoxin = 1,
		/datum/gas/cryptobiolin = 1,
		/datum/gas/copper = 1
	)


/datum/gas_reaction/rezadone/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/carpotoxin) + air.get_moles(/datum/gas/cryptobiolin) + air.get_moles(/datum/gas/copper)
	remove_air = air.get_moles(/datum/gas/carpotoxin)
	air.adjust_moles(/datum/gas/carpotoxin, -remove_air)
	remove_air = air.get_moles(/datum/gas/cryptobiolin)
	air.adjust_moles(/datum/gas/cryptobiolin, -remove_air)
	remove_air = air.get_moles(/datum/gas/copper)
	air.adjust_moles(/datum/gas/copper, -remove_air)
	air.adjust_moles(/datum/gas/rezadone, cleaned_air)

/datum/gas_reaction/spaceacillin
    priority = 1
    name = "spaceacillin"
    id = "spaceacillin"


/datum/gas_reaction/spaceacillin/init_reqs()
	min_requirements = list(
		/datum/gas/cryptobiolin = 1,
		/datum/gas/epinephrine = 1
	)


/datum/gas_reaction/spaceacillin/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/cryptobiolin) + air.get_moles(/datum/gas/epinephrine)
	remove_air = air.get_moles(/datum/gas/cryptobiolin)
	air.adjust_moles(/datum/gas/cryptobiolin, -remove_air)
	remove_air = air.get_moles(/datum/gas/epinephrine)
	air.adjust_moles(/datum/gas/epinephrine, -remove_air)
	air.adjust_moles(/datum/gas/spaceacillin, cleaned_air)

/datum/gas_reaction/inacusiate
    priority = 1
    name = "inacusiate"
    id = "inacusiate"


/datum/gas_reaction/inacusiate/init_reqs()
	min_requirements = list(
		/datum/gas/water = 1,
		/datum/gas/carbon = 1,
		/datum/gas/charcoal = 1
	)


/datum/gas_reaction/inacusiate/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/water) + air.get_moles(/datum/gas/carbon) + air.get_moles(/datum/gas/charcoal)
	remove_air = air.get_moles(/datum/gas/water)
	air.adjust_moles(/datum/gas/water, -remove_air)
	remove_air = air.get_moles(/datum/gas/carbon)
	air.adjust_moles(/datum/gas/carbon, -remove_air)
	remove_air = air.get_moles(/datum/gas/charcoal)
	air.adjust_moles(/datum/gas/charcoal, -remove_air)
	air.adjust_moles(/datum/gas/inacusiate, cleaned_air)

/datum/gas_reaction/synaptizine
    priority = 1
    name = "synaptizine"
    id = "synaptizine"


/datum/gas_reaction/synaptizine/init_reqs()
	min_requirements = list(
		/datum/gas/sugar = 1,
		/datum/gas/lithium = 1,
		/datum/gas/water = 1
	)


/datum/gas_reaction/synaptizine/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/sugar) + air.get_moles(/datum/gas/lithium) + air.get_moles(/datum/gas/water)
	remove_air = air.get_moles(/datum/gas/sugar)
	air.adjust_moles(/datum/gas/sugar, -remove_air)
	remove_air = air.get_moles(/datum/gas/lithium)
	air.adjust_moles(/datum/gas/lithium, -remove_air)
	remove_air = air.get_moles(/datum/gas/water)
	air.adjust_moles(/datum/gas/water, -remove_air)
	air.adjust_moles(/datum/gas/synaptizine, cleaned_air)

/datum/gas_reaction/charcoal
    priority = 1
    name = "charcoal"
    id = "charcoal"


/datum/gas_reaction/charcoal/init_reqs()
	min_requirements = list(
		/datum/gas/ash = 1,
		/datum/gas/sodiumchloride = 1,
		"TEMP" = 380)

/datum/gas_reaction/charcoal/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/ash) + air.get_moles(/datum/gas/sodiumchloride)
	remove_air = air.get_moles(/datum/gas/ash)
	air.adjust_moles(/datum/gas/ash, -remove_air)
	remove_air = air.get_moles(/datum/gas/sodiumchloride)
	air.adjust_moles(/datum/gas/sodiumchloride, -remove_air)
	air.adjust_moles(/datum/gas/charcoal, cleaned_air)

/datum/gas_reaction/silver_sulfadiazine
    priority = 1
    name = "silver_sulfadiazine"
    id = "silver_sulfadiazine"


/datum/gas_reaction/silver_sulfadiazine/init_reqs()
	min_requirements = list(
		/datum/gas/ammonia = 1,
		/datum/gas/silver = 1,
		/datum/gas/sulfur = 1,
		/datum/gas/oxygen = 1,
		/datum/gas/chlorine = 1
	)


/datum/gas_reaction/silver_sulfadiazine/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/ammonia) + air.get_moles(/datum/gas/silver) + air.get_moles(/datum/gas/sulfur) + air.get_moles(/datum/gas/oxygen) + air.get_moles(/datum/gas/chlorine)
	remove_air = air.get_moles(/datum/gas/ammonia)
	air.adjust_moles(/datum/gas/ammonia, -remove_air)
	remove_air = air.get_moles(/datum/gas/silver)
	air.adjust_moles(/datum/gas/silver, -remove_air)
	remove_air = air.get_moles(/datum/gas/sulfur)
	air.adjust_moles(/datum/gas/sulfur, -remove_air)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	remove_air = air.get_moles(/datum/gas/chlorine)
	air.adjust_moles(/datum/gas/chlorine, -remove_air)
	air.adjust_moles(/datum/gas/silver_sulfadiazine, cleaned_air)

/datum/gas_reaction/salglu_solution
    priority = 1
    name = "salglu_solution"
    id = "salglu_solution"


/datum/gas_reaction/salglu_solution/init_reqs()
	min_requirements = list(
		/datum/gas/sodiumchloride = 1,
		/datum/gas/water = 1,
		/datum/gas/sugar = 1
	)


/datum/gas_reaction/salglu_solution/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/sodiumchloride) + air.get_moles(/datum/gas/water) + air.get_moles(/datum/gas/sugar)
	remove_air = air.get_moles(/datum/gas/sodiumchloride)
	air.adjust_moles(/datum/gas/sodiumchloride, -remove_air)
	remove_air = air.get_moles(/datum/gas/water)
	air.adjust_moles(/datum/gas/water, -remove_air)
	remove_air = air.get_moles(/datum/gas/sugar)
	air.adjust_moles(/datum/gas/sugar, -remove_air)
	air.adjust_moles(/datum/gas/salglu_solution, cleaned_air)

/datum/gas_reaction/mine_salve
    priority = 1
    name = "mine_salve"
    id = "mine_salve"


/datum/gas_reaction/mine_salve/init_reqs()
	min_requirements = list(
		/datum/gas/oil = 1,
		/datum/gas/water = 1,
		/datum/gas/iron = 1
	)


/datum/gas_reaction/mine_salve/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/oil) + air.get_moles(/datum/gas/water) + air.get_moles(/datum/gas/iron)
	remove_air = air.get_moles(/datum/gas/oil)
	air.adjust_moles(/datum/gas/oil, -remove_air)
	remove_air = air.get_moles(/datum/gas/water)
	air.adjust_moles(/datum/gas/water, -remove_air)
	remove_air = air.get_moles(/datum/gas/iron)
	air.adjust_moles(/datum/gas/iron, -remove_air)
	air.adjust_moles(/datum/gas/mine_salve, cleaned_air)

/datum/gas_reaction/synthflesh
    priority = 1
    name = "synthflesh"
    id = "synthflesh"


/datum/gas_reaction/synthflesh/init_reqs()
	min_requirements = list(
		/datum/gas/blood = 1,
		/datum/gas/carbon = 1,
		/datum/gas/styptic_powder = 1
	)


/datum/gas_reaction/synthflesh/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/blood) + air.get_moles(/datum/gas/carbon) + air.get_moles(/datum/gas/styptic_powder)
	remove_air = air.get_moles(/datum/gas/blood)
	air.adjust_moles(/datum/gas/blood, -remove_air)
	remove_air = air.get_moles(/datum/gas/carbon)
	air.adjust_moles(/datum/gas/carbon, -remove_air)
	remove_air = air.get_moles(/datum/gas/styptic_powder)
	air.adjust_moles(/datum/gas/styptic_powder, -remove_air)
	air.adjust_moles(/datum/gas/synthflesh, cleaned_air)

/datum/gas_reaction/styptic_powder
    priority = 1
    name = "styptic_powder"
    id = "styptic_powder"


/datum/gas_reaction/styptic_powder/init_reqs()
	min_requirements = list(
		/datum/gas/aluminium = 1,
		/datum/gas/hydrogen = 1,
		/datum/gas/oxygen = 1,
		/datum/gas/acid = 1
	)


/datum/gas_reaction/styptic_powder/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/aluminium) + air.get_moles(/datum/gas/hydrogen) + air.get_moles(/datum/gas/oxygen) + air.get_moles(/datum/gas/acid)
	remove_air = air.get_moles(/datum/gas/aluminium)
	air.adjust_moles(/datum/gas/aluminium, -remove_air)
	remove_air = air.get_moles(/datum/gas/hydrogen)
	air.adjust_moles(/datum/gas/hydrogen, -remove_air)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	remove_air = air.get_moles(/datum/gas/acid)
	air.adjust_moles(/datum/gas/acid, -remove_air)
	air.adjust_moles(/datum/gas/styptic_powder, cleaned_air)

/datum/gas_reaction/calomel
    priority = 1
    name = "calomel"
    id = "calomel"


/datum/gas_reaction/calomel/init_reqs()
	min_requirements = list(
		/datum/gas/mercury = 1,
		/datum/gas/chlorine = 1,
		"TEMP" = 374)

/datum/gas_reaction/calomel/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/mercury) + air.get_moles(/datum/gas/chlorine)
	remove_air = air.get_moles(/datum/gas/mercury)
	air.adjust_moles(/datum/gas/mercury, -remove_air)
	remove_air = air.get_moles(/datum/gas/chlorine)
	air.adjust_moles(/datum/gas/chlorine, -remove_air)
	air.adjust_moles(/datum/gas/calomel, cleaned_air)

/datum/gas_reaction/potass_iodide
    priority = 1
    name = "potass_iodide"
    id = "potass_iodide"


/datum/gas_reaction/potass_iodide/init_reqs()
	min_requirements = list(
		/datum/gas/potassium = 1,
		/datum/gas/iodine = 1
	)


/datum/gas_reaction/potass_iodide/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/potassium) + air.get_moles(/datum/gas/iodine)
	remove_air = air.get_moles(/datum/gas/potassium)
	air.adjust_moles(/datum/gas/potassium, -remove_air)
	remove_air = air.get_moles(/datum/gas/iodine)
	air.adjust_moles(/datum/gas/iodine, -remove_air)
	air.adjust_moles(/datum/gas/potass_iodide, cleaned_air)

/datum/gas_reaction/pen_acid
    priority = 1
    name = "pen_acid"
    id = "pen_acid"


/datum/gas_reaction/pen_acid/init_reqs()
	min_requirements = list(
		/datum/gas/fuel = 1,
		/datum/gas/chlorine = 1,
		/datum/gas/ammonia = 1,
		/datum/gas/formaldehyde = 1,
		/datum/gas/sodium = 1,
		/datum/gas/cyanide = 1
	)


/datum/gas_reaction/pen_acid/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/fuel) + air.get_moles(/datum/gas/chlorine) + air.get_moles(/datum/gas/ammonia) + air.get_moles(/datum/gas/formaldehyde) + air.get_moles(/datum/gas/sodium) + air.get_moles(/datum/gas/cyanide)
	remove_air = air.get_moles(/datum/gas/fuel)
	air.adjust_moles(/datum/gas/fuel, -remove_air)
	remove_air = air.get_moles(/datum/gas/chlorine)
	air.adjust_moles(/datum/gas/chlorine, -remove_air)
	remove_air = air.get_moles(/datum/gas/ammonia)
	air.adjust_moles(/datum/gas/ammonia, -remove_air)
	remove_air = air.get_moles(/datum/gas/formaldehyde)
	air.adjust_moles(/datum/gas/formaldehyde, -remove_air)
	remove_air = air.get_moles(/datum/gas/sodium)
	air.adjust_moles(/datum/gas/sodium, -remove_air)
	remove_air = air.get_moles(/datum/gas/cyanide)
	air.adjust_moles(/datum/gas/cyanide, -remove_air)
	air.adjust_moles(/datum/gas/pen_acid, cleaned_air)

/datum/gas_reaction/sal_acid
    priority = 1
    name = "sal_acid"
    id = "sal_acid"


/datum/gas_reaction/sal_acid/init_reqs()
	min_requirements = list(
		/datum/gas/sodium = 1,
		/datum/gas/phenol = 1,
		/datum/gas/carbon = 1,
		/datum/gas/oxygen = 1,
		/datum/gas/acid = 1
	)


/datum/gas_reaction/sal_acid/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/sodium) + air.get_moles(/datum/gas/phenol) + air.get_moles(/datum/gas/carbon) + air.get_moles(/datum/gas/oxygen) + air.get_moles(/datum/gas/acid)
	remove_air = air.get_moles(/datum/gas/sodium)
	air.adjust_moles(/datum/gas/sodium, -remove_air)
	remove_air = air.get_moles(/datum/gas/phenol)
	air.adjust_moles(/datum/gas/phenol, -remove_air)
	remove_air = air.get_moles(/datum/gas/carbon)
	air.adjust_moles(/datum/gas/carbon, -remove_air)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	remove_air = air.get_moles(/datum/gas/acid)
	air.adjust_moles(/datum/gas/acid, -remove_air)
	air.adjust_moles(/datum/gas/sal_acid, cleaned_air)

/datum/gas_reaction/oxandrolone
    priority = 1
    name = "oxandrolone"
    id = "oxandrolone"


/datum/gas_reaction/oxandrolone/init_reqs()
	min_requirements = list(
		/datum/gas/carbon = 3,
		/datum/gas/phenol = 3,
		/datum/gas/hydrogen = 3,
		/datum/gas/oxygen = 3
	)


/datum/gas_reaction/oxandrolone/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/carbon) + air.get_moles(/datum/gas/phenol) + air.get_moles(/datum/gas/hydrogen) + air.get_moles(/datum/gas/oxygen)
	remove_air = air.get_moles(/datum/gas/carbon)
	air.adjust_moles(/datum/gas/carbon, -remove_air)
	remove_air = air.get_moles(/datum/gas/phenol)
	air.adjust_moles(/datum/gas/phenol, -remove_air)
	remove_air = air.get_moles(/datum/gas/hydrogen)
	air.adjust_moles(/datum/gas/hydrogen, -remove_air)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	air.adjust_moles(/datum/gas/oxandrolone, cleaned_air)

/datum/gas_reaction/salbutamol
    priority = 1
    name = "salbutamol"
    id = "salbutamol"


/datum/gas_reaction/salbutamol/init_reqs()
	min_requirements = list(
		/datum/gas/sal_acid = 1,
		/datum/gas/lithium = 1,
		/datum/gas/aluminium = 1,
		/datum/gas/bromine = 1,
		/datum/gas/ammonia = 1
	)


/datum/gas_reaction/salbutamol/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/sal_acid) + air.get_moles(/datum/gas/lithium) + air.get_moles(/datum/gas/aluminium) + air.get_moles(/datum/gas/bromine) + air.get_moles(/datum/gas/ammonia)
	remove_air = air.get_moles(/datum/gas/sal_acid)
	air.adjust_moles(/datum/gas/sal_acid, -remove_air)
	remove_air = air.get_moles(/datum/gas/lithium)
	air.adjust_moles(/datum/gas/lithium, -remove_air)
	remove_air = air.get_moles(/datum/gas/aluminium)
	air.adjust_moles(/datum/gas/aluminium, -remove_air)
	remove_air = air.get_moles(/datum/gas/bromine)
	air.adjust_moles(/datum/gas/bromine, -remove_air)
	remove_air = air.get_moles(/datum/gas/ammonia)
	air.adjust_moles(/datum/gas/ammonia, -remove_air)
	air.adjust_moles(/datum/gas/salbutamol, cleaned_air)

/datum/gas_reaction/perfluorodecalin
    priority = 1
    name = "perfluorodecalin"
    id = "perfluorodecalin"


/datum/gas_reaction/perfluorodecalin/init_reqs()
	min_requirements = list(
		/datum/gas/hydrogen = 1,
		/datum/gas/fluorine = 1,
		/datum/gas/oil = 1,
		"TEMP" = 370)

/datum/gas_reaction/perfluorodecalin/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/hydrogen) + air.get_moles(/datum/gas/fluorine) + air.get_moles(/datum/gas/oil)
	remove_air = air.get_moles(/datum/gas/hydrogen)
	air.adjust_moles(/datum/gas/hydrogen, -remove_air)
	remove_air = air.get_moles(/datum/gas/fluorine)
	air.adjust_moles(/datum/gas/fluorine, -remove_air)
	remove_air = air.get_moles(/datum/gas/oil)
	air.adjust_moles(/datum/gas/oil, -remove_air)
	air.adjust_moles(/datum/gas/perfluorodecalin, cleaned_air)

/datum/gas_reaction/ephedrine
    priority = 1
    name = "ephedrine"
    id = "ephedrine"


/datum/gas_reaction/ephedrine/init_reqs()
	min_requirements = list(
		/datum/gas/sugar = 1,
		/datum/gas/oil = 1,
		/datum/gas/hydrogen = 1,
		/datum/gas/diethylamine = 1
	)


/datum/gas_reaction/ephedrine/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/sugar) + air.get_moles(/datum/gas/oil) + air.get_moles(/datum/gas/hydrogen) + air.get_moles(/datum/gas/diethylamine)
	remove_air = air.get_moles(/datum/gas/sugar)
	air.adjust_moles(/datum/gas/sugar, -remove_air)
	remove_air = air.get_moles(/datum/gas/oil)
	air.adjust_moles(/datum/gas/oil, -remove_air)
	remove_air = air.get_moles(/datum/gas/hydrogen)
	air.adjust_moles(/datum/gas/hydrogen, -remove_air)
	remove_air = air.get_moles(/datum/gas/diethylamine)
	air.adjust_moles(/datum/gas/diethylamine, -remove_air)
	air.adjust_moles(/datum/gas/ephedrine, cleaned_air)

/datum/gas_reaction/diphenhydramine
    priority = 1
    name = "diphenhydramine"
    id = "diphenhydramine"


/datum/gas_reaction/diphenhydramine/init_reqs()
	min_requirements = list(
		/datum/gas/oil = 1,
		/datum/gas/carbon = 1,
		/datum/gas/bromine = 1,
		/datum/gas/diethylamine = 1,
		/datum/gas/ethanol = 1
	)


/datum/gas_reaction/diphenhydramine/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/oil) + air.get_moles(/datum/gas/carbon) + air.get_moles(/datum/gas/bromine) + air.get_moles(/datum/gas/diethylamine) + air.get_moles(/datum/gas/ethanol)
	remove_air = air.get_moles(/datum/gas/oil)
	air.adjust_moles(/datum/gas/oil, -remove_air)
	remove_air = air.get_moles(/datum/gas/carbon)
	air.adjust_moles(/datum/gas/carbon, -remove_air)
	remove_air = air.get_moles(/datum/gas/bromine)
	air.adjust_moles(/datum/gas/bromine, -remove_air)
	remove_air = air.get_moles(/datum/gas/diethylamine)
	air.adjust_moles(/datum/gas/diethylamine, -remove_air)
	remove_air = air.get_moles(/datum/gas/ethanol)
	air.adjust_moles(/datum/gas/ethanol, -remove_air)
	air.adjust_moles(/datum/gas/diphenhydramine, cleaned_air)

/datum/gas_reaction/oculine
    priority = 1
    name = "oculine"
    id = "oculine"


/datum/gas_reaction/oculine/init_reqs()
	min_requirements = list(
		/datum/gas/charcoal = 1,
		/datum/gas/carbon = 1,
		/datum/gas/hydrogen = 1
	)


/datum/gas_reaction/oculine/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/charcoal) + air.get_moles(/datum/gas/carbon) + air.get_moles(/datum/gas/hydrogen)
	remove_air = air.get_moles(/datum/gas/charcoal)
	air.adjust_moles(/datum/gas/charcoal, -remove_air)
	remove_air = air.get_moles(/datum/gas/carbon)
	air.adjust_moles(/datum/gas/carbon, -remove_air)
	remove_air = air.get_moles(/datum/gas/hydrogen)
	air.adjust_moles(/datum/gas/hydrogen, -remove_air)
	air.adjust_moles(/datum/gas/oculine, cleaned_air)

/datum/gas_reaction/atropine
    priority = 1
    name = "atropine"
    id = "atropine"


/datum/gas_reaction/atropine/init_reqs()
	min_requirements = list(
		/datum/gas/ethanol = 1,
		/datum/gas/acetone = 1,
		/datum/gas/diethylamine = 1,
		/datum/gas/phenol = 1,
		/datum/gas/acid = 1
	)


/datum/gas_reaction/atropine/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/ethanol) + air.get_moles(/datum/gas/acetone) + air.get_moles(/datum/gas/diethylamine) + air.get_moles(/datum/gas/phenol) + air.get_moles(/datum/gas/acid)
	remove_air = air.get_moles(/datum/gas/ethanol)
	air.adjust_moles(/datum/gas/ethanol, -remove_air)
	remove_air = air.get_moles(/datum/gas/acetone)
	air.adjust_moles(/datum/gas/acetone, -remove_air)
	remove_air = air.get_moles(/datum/gas/diethylamine)
	air.adjust_moles(/datum/gas/diethylamine, -remove_air)
	remove_air = air.get_moles(/datum/gas/phenol)
	air.adjust_moles(/datum/gas/phenol, -remove_air)
	remove_air = air.get_moles(/datum/gas/acid)
	air.adjust_moles(/datum/gas/acid, -remove_air)
	air.adjust_moles(/datum/gas/atropine, cleaned_air)

/datum/gas_reaction/epinephrine
    priority = 1
    name = "epinephrine"
    id = "epinephrine"


/datum/gas_reaction/epinephrine/init_reqs()
	min_requirements = list(
		/datum/gas/phenol = 1,
		/datum/gas/acetone = 1,
		/datum/gas/diethylamine = 1,
		/datum/gas/oxygen = 1,
		/datum/gas/chlorine = 1,
		/datum/gas/hydrogen = 1
	)


/datum/gas_reaction/epinephrine/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/phenol) + air.get_moles(/datum/gas/acetone) + air.get_moles(/datum/gas/diethylamine) + air.get_moles(/datum/gas/oxygen) + air.get_moles(/datum/gas/chlorine) + air.get_moles(/datum/gas/hydrogen)
	remove_air = air.get_moles(/datum/gas/phenol)
	air.adjust_moles(/datum/gas/phenol, -remove_air)
	remove_air = air.get_moles(/datum/gas/acetone)
	air.adjust_moles(/datum/gas/acetone, -remove_air)
	remove_air = air.get_moles(/datum/gas/diethylamine)
	air.adjust_moles(/datum/gas/diethylamine, -remove_air)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	remove_air = air.get_moles(/datum/gas/chlorine)
	air.adjust_moles(/datum/gas/chlorine, -remove_air)
	remove_air = air.get_moles(/datum/gas/hydrogen)
	air.adjust_moles(/datum/gas/hydrogen, -remove_air)
	air.adjust_moles(/datum/gas/epinephrine, cleaned_air)

/datum/gas_reaction/strange_reagent
    priority = 1
    name = "strange_reagent"
    id = "strange_reagent"


/datum/gas_reaction/strange_reagent/init_reqs()
	min_requirements = list(
		/datum/gas/omnizine = 1,
		/datum/gas/holywater = 1,
		/datum/gas/mutagen = 1
	)


/datum/gas_reaction/strange_reagent/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/omnizine) + air.get_moles(/datum/gas/holywater) + air.get_moles(/datum/gas/mutagen)
	remove_air = air.get_moles(/datum/gas/omnizine)
	air.adjust_moles(/datum/gas/omnizine, -remove_air)
	remove_air = air.get_moles(/datum/gas/holywater)
	air.adjust_moles(/datum/gas/holywater, -remove_air)
	remove_air = air.get_moles(/datum/gas/mutagen)
	air.adjust_moles(/datum/gas/mutagen, -remove_air)
	air.adjust_moles(/datum/gas/strange_reagent, cleaned_air)

/datum/gas_reaction/mannitol
    priority = 1
    name = "mannitol"
    id = "mannitol"


/datum/gas_reaction/mannitol/init_reqs()
	min_requirements = list(
		/datum/gas/sugar = 1,
		/datum/gas/hydrogen = 1,
		/datum/gas/water = 1
	)


/datum/gas_reaction/mannitol/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/sugar) + air.get_moles(/datum/gas/hydrogen) + air.get_moles(/datum/gas/water)
	remove_air = air.get_moles(/datum/gas/sugar)
	air.adjust_moles(/datum/gas/sugar, -remove_air)
	remove_air = air.get_moles(/datum/gas/hydrogen)
	air.adjust_moles(/datum/gas/hydrogen, -remove_air)
	remove_air = air.get_moles(/datum/gas/water)
	air.adjust_moles(/datum/gas/water, -remove_air)
	air.adjust_moles(/datum/gas/mannitol, cleaned_air)

/datum/gas_reaction/neurine
    priority = 1
    name = "neurine"
    id = "neurine"


/datum/gas_reaction/neurine/init_reqs()
	min_requirements = list(
		/datum/gas/mannitol = 1,
		/datum/gas/acetone = 1,
		/datum/gas/oxygen = 1
	)


/datum/gas_reaction/neurine/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/mannitol) + air.get_moles(/datum/gas/acetone) + air.get_moles(/datum/gas/oxygen)
	remove_air = air.get_moles(/datum/gas/mannitol)
	air.adjust_moles(/datum/gas/mannitol, -remove_air)
	remove_air = air.get_moles(/datum/gas/acetone)
	air.adjust_moles(/datum/gas/acetone, -remove_air)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	air.adjust_moles(/datum/gas/neurine, cleaned_air)

/datum/gas_reaction/mutadone
    priority = 1
    name = "mutadone"
    id = "mutadone"


/datum/gas_reaction/mutadone/init_reqs()
	min_requirements = list(
		/datum/gas/mutagen = 1,
		/datum/gas/acetone = 1,
		/datum/gas/bromine = 1
	)


/datum/gas_reaction/mutadone/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/mutagen) + air.get_moles(/datum/gas/acetone) + air.get_moles(/datum/gas/bromine)
	remove_air = air.get_moles(/datum/gas/mutagen)
	air.adjust_moles(/datum/gas/mutagen, -remove_air)
	remove_air = air.get_moles(/datum/gas/acetone)
	air.adjust_moles(/datum/gas/acetone, -remove_air)
	remove_air = air.get_moles(/datum/gas/bromine)
	air.adjust_moles(/datum/gas/bromine, -remove_air)
	air.adjust_moles(/datum/gas/mutadone, cleaned_air)

/datum/gas_reaction/antihol
    priority = 1
    name = "antihol"
    id = "antihol"


/datum/gas_reaction/antihol/init_reqs()
	min_requirements = list(
		/datum/gas/ethanol = 1,
		/datum/gas/charcoal = 1,
		/datum/gas/copper = 1
	)


/datum/gas_reaction/antihol/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/ethanol) + air.get_moles(/datum/gas/charcoal) + air.get_moles(/datum/gas/copper)
	remove_air = air.get_moles(/datum/gas/ethanol)
	air.adjust_moles(/datum/gas/ethanol, -remove_air)
	remove_air = air.get_moles(/datum/gas/charcoal)
	air.adjust_moles(/datum/gas/charcoal, -remove_air)
	remove_air = air.get_moles(/datum/gas/copper)
	air.adjust_moles(/datum/gas/copper, -remove_air)
	air.adjust_moles(/datum/gas/antihol, cleaned_air)

/datum/gas_reaction/cryoxadone
    priority = 1
    name = "cryoxadone"
    id = "cryoxadone"


/datum/gas_reaction/cryoxadone/init_reqs()
	min_requirements = list(
		/datum/gas/stable_plasma = 1,
		/datum/gas/acetone = 1,
		/datum/gas/mutagen = 1
	)


/datum/gas_reaction/cryoxadone/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/stable_plasma) + air.get_moles(/datum/gas/acetone) + air.get_moles(/datum/gas/mutagen)
	remove_air = air.get_moles(/datum/gas/stable_plasma)
	air.adjust_moles(/datum/gas/stable_plasma, -remove_air)
	remove_air = air.get_moles(/datum/gas/acetone)
	air.adjust_moles(/datum/gas/acetone, -remove_air)
	remove_air = air.get_moles(/datum/gas/mutagen)
	air.adjust_moles(/datum/gas/mutagen, -remove_air)
	air.adjust_moles(/datum/gas/cryoxadone, cleaned_air)

/datum/gas_reaction/pyroxadone
    priority = 1
    name = "pyroxadone"
    id = "pyroxadone"


/datum/gas_reaction/pyroxadone/init_reqs()
	min_requirements = list(
		/datum/gas/cryoxadone = 1,
		/datum/gas/slimejelly = 1
	)


/datum/gas_reaction/pyroxadone/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/cryoxadone) + air.get_moles(/datum/gas/slimejelly)
	remove_air = air.get_moles(/datum/gas/cryoxadone)
	air.adjust_moles(/datum/gas/cryoxadone, -remove_air)
	remove_air = air.get_moles(/datum/gas/slimejelly)
	air.adjust_moles(/datum/gas/slimejelly, -remove_air)
	air.adjust_moles(/datum/gas/pyroxadone, cleaned_air)

/datum/gas_reaction/clonexadone
    priority = 1
    name = "clonexadone"
    id = "clonexadone"


/datum/gas_reaction/clonexadone/init_reqs()
	min_requirements = list(
		/datum/gas/cryoxadone = 1,
		/datum/gas/sodium = 1
	)


/datum/gas_reaction/clonexadone/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/cryoxadone) + air.get_moles(/datum/gas/sodium)
	remove_air = air.get_moles(/datum/gas/cryoxadone)
	air.adjust_moles(/datum/gas/cryoxadone, -remove_air)
	remove_air = air.get_moles(/datum/gas/sodium)
	air.adjust_moles(/datum/gas/sodium, -remove_air)
	air.adjust_moles(/datum/gas/clonexadone, cleaned_air)

/datum/gas_reaction/haloperidol
    priority = 1
    name = "haloperidol"
    id = "haloperidol"


/datum/gas_reaction/haloperidol/init_reqs()
	min_requirements = list(
		/datum/gas/chlorine = 1,
		/datum/gas/fluorine = 1,
		/datum/gas/aluminium = 1,
		/datum/gas/potass_iodide = 1,
		/datum/gas/oil = 1
	)


/datum/gas_reaction/haloperidol/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/chlorine) + air.get_moles(/datum/gas/fluorine) + air.get_moles(/datum/gas/aluminium) + air.get_moles(/datum/gas/potass_iodide) + air.get_moles(/datum/gas/oil)
	remove_air = air.get_moles(/datum/gas/chlorine)
	air.adjust_moles(/datum/gas/chlorine, -remove_air)
	remove_air = air.get_moles(/datum/gas/fluorine)
	air.adjust_moles(/datum/gas/fluorine, -remove_air)
	remove_air = air.get_moles(/datum/gas/aluminium)
	air.adjust_moles(/datum/gas/aluminium, -remove_air)
	remove_air = air.get_moles(/datum/gas/potass_iodide)
	air.adjust_moles(/datum/gas/potass_iodide, -remove_air)
	remove_air = air.get_moles(/datum/gas/oil)
	air.adjust_moles(/datum/gas/oil, -remove_air)
	air.adjust_moles(/datum/gas/haloperidol, cleaned_air)

/datum/gas_reaction/bicaridine
    priority = 1
    name = "bicaridine"
    id = "bicaridine"


/datum/gas_reaction/bicaridine/init_reqs()
	min_requirements = list(
		/datum/gas/carbon = 1,
		/datum/gas/oxygen = 1,
		/datum/gas/sugar = 1
	)


/datum/gas_reaction/bicaridine/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/carbon) + air.get_moles(/datum/gas/oxygen) + air.get_moles(/datum/gas/sugar)
	remove_air = air.get_moles(/datum/gas/carbon)
	air.adjust_moles(/datum/gas/carbon, -remove_air)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	remove_air = air.get_moles(/datum/gas/sugar)
	air.adjust_moles(/datum/gas/sugar, -remove_air)
	air.adjust_moles(/datum/gas/bicaridine, cleaned_air)

/datum/gas_reaction/kelotane
    priority = 1
    name = "kelotane"
    id = "kelotane"


/datum/gas_reaction/kelotane/init_reqs()
	min_requirements = list(
		/datum/gas/carbon = 1,
		/datum/gas/silicon = 1
	)


/datum/gas_reaction/kelotane/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/carbon) + air.get_moles(/datum/gas/silicon)
	remove_air = air.get_moles(/datum/gas/carbon)
	air.adjust_moles(/datum/gas/carbon, -remove_air)
	remove_air = air.get_moles(/datum/gas/silicon)
	air.adjust_moles(/datum/gas/silicon, -remove_air)
	air.adjust_moles(/datum/gas/kelotane, cleaned_air)

/datum/gas_reaction/antitoxin
    priority = 1
    name = "antitoxin"
    id = "antitoxin"


/datum/gas_reaction/antitoxin/init_reqs()
	min_requirements = list(
		/datum/gas/nitrogen = 1,
		/datum/gas/silicon = 1,
		/datum/gas/potassium = 1
	)


/datum/gas_reaction/antitoxin/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/nitrogen) + air.get_moles(/datum/gas/silicon) + air.get_moles(/datum/gas/potassium)
	remove_air = air.get_moles(/datum/gas/nitrogen)
	air.adjust_moles(/datum/gas/nitrogen, -remove_air)
	remove_air = air.get_moles(/datum/gas/silicon)
	air.adjust_moles(/datum/gas/silicon, -remove_air)
	remove_air = air.get_moles(/datum/gas/potassium)
	air.adjust_moles(/datum/gas/potassium, -remove_air)
	air.adjust_moles(/datum/gas/antitoxin, cleaned_air)

/datum/gas_reaction/tricordrazine
    priority = 1
    name = "tricordrazine"
    id = "tricordrazine"


/datum/gas_reaction/tricordrazine/init_reqs()
	min_requirements = list(
		/datum/gas/bicaridine = 1,
		/datum/gas/kelotane = 1,
		/datum/gas/antitoxin = 1
	)


/datum/gas_reaction/tricordrazine/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/bicaridine) + air.get_moles(/datum/gas/kelotane) + air.get_moles(/datum/gas/antitoxin)
	remove_air = air.get_moles(/datum/gas/bicaridine)
	air.adjust_moles(/datum/gas/bicaridine, -remove_air)
	remove_air = air.get_moles(/datum/gas/kelotane)
	air.adjust_moles(/datum/gas/kelotane, -remove_air)
	remove_air = air.get_moles(/datum/gas/antitoxin)
	air.adjust_moles(/datum/gas/antitoxin, -remove_air)
	air.adjust_moles(/datum/gas/tricordrazine, cleaned_air)

/datum/gas_reaction/regen_jelly
    priority = 1
    name = "regen_jelly"
    id = "regen_jelly"


/datum/gas_reaction/regen_jelly/init_reqs()
	min_requirements = list(
		/datum/gas/tricordrazine = 1,
		/datum/gas/slimejelly = 1
	)


/datum/gas_reaction/regen_jelly/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/tricordrazine) + air.get_moles(/datum/gas/slimejelly)
	remove_air = air.get_moles(/datum/gas/tricordrazine)
	air.adjust_moles(/datum/gas/tricordrazine, -remove_air)
	remove_air = air.get_moles(/datum/gas/slimejelly)
	air.adjust_moles(/datum/gas/slimejelly, -remove_air)
	air.adjust_moles(/datum/gas/regen_jelly, cleaned_air)

/datum/gas_reaction/corazone
    priority = 1
    name = "corazone"
    id = "corazone"


/datum/gas_reaction/corazone/init_reqs()
	min_requirements = list(
		/datum/gas/phenol = 2,
		/datum/gas/lithium = 2
	)


/datum/gas_reaction/corazone/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/phenol) + air.get_moles(/datum/gas/lithium)
	remove_air = air.get_moles(/datum/gas/phenol)
	air.adjust_moles(/datum/gas/phenol, -remove_air)
	remove_air = air.get_moles(/datum/gas/lithium)
	air.adjust_moles(/datum/gas/lithium, -remove_air)
	air.adjust_moles(/datum/gas/corazone, cleaned_air)

/datum/gas_reaction/morphine
    priority = 1
    name = "morphine"
    id = "morphine"


/datum/gas_reaction/morphine/init_reqs()
	min_requirements = list(
		/datum/gas/carbon = 2,
		/datum/gas/hydrogen = 2,
		/datum/gas/ethanol = 2,
		/datum/gas/oxygen = 2,
		"TEMP" = 480)

/datum/gas_reaction/morphine/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/carbon) + air.get_moles(/datum/gas/hydrogen) + air.get_moles(/datum/gas/ethanol) + air.get_moles(/datum/gas/oxygen)
	remove_air = air.get_moles(/datum/gas/carbon)
	air.adjust_moles(/datum/gas/carbon, -remove_air)
	remove_air = air.get_moles(/datum/gas/hydrogen)
	air.adjust_moles(/datum/gas/hydrogen, -remove_air)
	remove_air = air.get_moles(/datum/gas/ethanol)
	air.adjust_moles(/datum/gas/ethanol, -remove_air)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	air.adjust_moles(/datum/gas/morphine, cleaned_air)

/datum/gas_reaction/modafinil
    priority = 1
    name = "modafinil"
    id = "modafinil"


/datum/gas_reaction/modafinil/init_reqs()
	min_requirements = list(
		/datum/gas/diethylamine = 1,
		/datum/gas/ammonia = 1,
		/datum/gas/phenol = 1,
		/datum/gas/acetone = 1,
		/datum/gas/acid = 1
	)


/datum/gas_reaction/modafinil/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/diethylamine) + air.get_moles(/datum/gas/ammonia) + air.get_moles(/datum/gas/phenol) + air.get_moles(/datum/gas/acetone) + air.get_moles(/datum/gas/acid)
	remove_air = air.get_moles(/datum/gas/diethylamine)
	air.adjust_moles(/datum/gas/diethylamine, -remove_air)
	remove_air = air.get_moles(/datum/gas/ammonia)
	air.adjust_moles(/datum/gas/ammonia, -remove_air)
	remove_air = air.get_moles(/datum/gas/phenol)
	air.adjust_moles(/datum/gas/phenol, -remove_air)
	remove_air = air.get_moles(/datum/gas/acetone)
	air.adjust_moles(/datum/gas/acetone, -remove_air)
	remove_air = air.get_moles(/datum/gas/acid)
	air.adjust_moles(/datum/gas/acid, -remove_air)
	air.adjust_moles(/datum/gas/modafinil, cleaned_air)

/datum/gas_reaction/psicodine
    priority = 1
    name = "psicodine"
    id = "psicodine"


/datum/gas_reaction/psicodine/init_reqs()
	min_requirements = list(
		/datum/gas/mannitol = 2,
		/datum/gas/water = 2,
		/datum/gas/impedrezene = 2
	)


/datum/gas_reaction/psicodine/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/mannitol) + air.get_moles(/datum/gas/water) + air.get_moles(/datum/gas/impedrezene)
	remove_air = air.get_moles(/datum/gas/mannitol)
	air.adjust_moles(/datum/gas/mannitol, -remove_air)
	remove_air = air.get_moles(/datum/gas/water)
	air.adjust_moles(/datum/gas/water, -remove_air)
	remove_air = air.get_moles(/datum/gas/impedrezene)
	air.adjust_moles(/datum/gas/impedrezene, -remove_air)
	air.adjust_moles(/datum/gas/psicodine, cleaned_air)

/datum/gas_reaction/system_cleaner
    priority = 1
    name = "system_cleaner"
    id = "system_cleaner"


/datum/gas_reaction/system_cleaner/init_reqs()
	min_requirements = list(
		/datum/gas/ethanol = 1,
		/datum/gas/chlorine = 1,
		/datum/gas/phenol = 1,
		/datum/gas/potassium = 1
	)


/datum/gas_reaction/system_cleaner/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/ethanol) + air.get_moles(/datum/gas/chlorine) + air.get_moles(/datum/gas/phenol) + air.get_moles(/datum/gas/potassium)
	remove_air = air.get_moles(/datum/gas/ethanol)
	air.adjust_moles(/datum/gas/ethanol, -remove_air)
	remove_air = air.get_moles(/datum/gas/chlorine)
	air.adjust_moles(/datum/gas/chlorine, -remove_air)
	remove_air = air.get_moles(/datum/gas/phenol)
	air.adjust_moles(/datum/gas/phenol, -remove_air)
	remove_air = air.get_moles(/datum/gas/potassium)
	air.adjust_moles(/datum/gas/potassium, -remove_air)
	air.adjust_moles(/datum/gas/system_cleaner, cleaned_air)

/datum/gas_reaction/liquid_solder
    priority = 1
    name = "liquid_solder"
    id = "liquid_solder"


/datum/gas_reaction/liquid_solder/init_reqs()
	min_requirements = list(
		/datum/gas/ethanol = 1,
		/datum/gas/copper = 1,
		/datum/gas/silver = 1,
		"TEMP" = 370)

/datum/gas_reaction/liquid_solder/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/ethanol) + air.get_moles(/datum/gas/copper) + air.get_moles(/datum/gas/silver)
	remove_air = air.get_moles(/datum/gas/ethanol)
	air.adjust_moles(/datum/gas/ethanol, -remove_air)
	remove_air = air.get_moles(/datum/gas/copper)
	air.adjust_moles(/datum/gas/copper, -remove_air)
	remove_air = air.get_moles(/datum/gas/silver)
	air.adjust_moles(/datum/gas/silver, -remove_air)
	air.adjust_moles(/datum/gas/liquid_solder, cleaned_air)

/datum/gas_reaction/carthatoline
    priority = 1
    name = "carthatoline"
    id = "carthatoline"


/datum/gas_reaction/carthatoline/init_reqs()
	min_requirements = list(
		/datum/gas/antitoxin = 1,
		/datum/gas/carbon = 1
	)


/datum/gas_reaction/carthatoline/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/antitoxin) + air.get_moles(/datum/gas/carbon)
	remove_air = air.get_moles(/datum/gas/antitoxin)
	air.adjust_moles(/datum/gas/antitoxin, -remove_air)
	remove_air = air.get_moles(/datum/gas/carbon)
	air.adjust_moles(/datum/gas/carbon, -remove_air)
	air.adjust_moles(/datum/gas/carthatoline, cleaned_air)

/datum/gas_reaction/hepanephrodaxon
    priority = 1
    name = "hepanephrodaxon"
    id = "hepanephrodaxon"


/datum/gas_reaction/hepanephrodaxon/init_reqs()
	min_requirements = list(
		/datum/gas/carthatoline = 2,
		/datum/gas/carbon = 2,
		/datum/gas/lithium = 2
	)


/datum/gas_reaction/hepanephrodaxon/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/carthatoline) + air.get_moles(/datum/gas/carbon) + air.get_moles(/datum/gas/lithium)
	remove_air = air.get_moles(/datum/gas/carthatoline)
	air.adjust_moles(/datum/gas/carthatoline, -remove_air)
	remove_air = air.get_moles(/datum/gas/carbon)
	air.adjust_moles(/datum/gas/carbon, -remove_air)
	remove_air = air.get_moles(/datum/gas/lithium)
	air.adjust_moles(/datum/gas/lithium, -remove_air)
	air.adjust_moles(/datum/gas/hepanephrodaxon, cleaned_air)

/datum/gas_reaction/sterilizine
    priority = 1
    name = "sterilizine"
    id = "sterilizine"


/datum/gas_reaction/sterilizine/init_reqs()
	min_requirements = list(
		/datum/gas/ethanol = 1,
		/datum/gas/charcoal = 1,
		/datum/gas/chlorine = 1
	)


/datum/gas_reaction/sterilizine/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/ethanol) + air.get_moles(/datum/gas/charcoal) + air.get_moles(/datum/gas/chlorine)
	remove_air = air.get_moles(/datum/gas/ethanol)
	air.adjust_moles(/datum/gas/ethanol, -remove_air)
	remove_air = air.get_moles(/datum/gas/charcoal)
	air.adjust_moles(/datum/gas/charcoal, -remove_air)
	remove_air = air.get_moles(/datum/gas/chlorine)
	air.adjust_moles(/datum/gas/chlorine, -remove_air)
	air.adjust_moles(/datum/gas/sterilizine, cleaned_air)

/datum/gas_reaction/cooking_oil
    priority = 1
    name = "cooking_oil"
    id = "cooking_oil"


/datum/gas_reaction/cooking_oil/init_reqs()
	min_requirements = list(
		/datum/gas/hydrogen = 1,
		/datum/gas/oil = 1,
		/datum/gas/sugar = 1,
		/datum/gas/carbon = 1
	)


/datum/gas_reaction/cooking_oil/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/hydrogen) + air.get_moles(/datum/gas/oil) + air.get_moles(/datum/gas/sugar) + air.get_moles(/datum/gas/carbon)
	remove_air = air.get_moles(/datum/gas/hydrogen)
	air.adjust_moles(/datum/gas/hydrogen, -remove_air)
	remove_air = air.get_moles(/datum/gas/oil)
	air.adjust_moles(/datum/gas/oil, -remove_air)
	remove_air = air.get_moles(/datum/gas/sugar)
	air.adjust_moles(/datum/gas/sugar, -remove_air)
	remove_air = air.get_moles(/datum/gas/carbon)
	air.adjust_moles(/datum/gas/carbon, -remove_air)
	air.adjust_moles(/datum/gas/cooking_oil, cleaned_air)

/datum/gas_reaction/lube
    priority = 1
    name = "lube"
    id = "lube"


/datum/gas_reaction/lube/init_reqs()
	min_requirements = list(
		/datum/gas/water = 1,
		/datum/gas/silicon = 1,
		/datum/gas/oxygen = 1
	)


/datum/gas_reaction/lube/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/water) + air.get_moles(/datum/gas/silicon) + air.get_moles(/datum/gas/oxygen)
	remove_air = air.get_moles(/datum/gas/water)
	air.adjust_moles(/datum/gas/water, -remove_air)
	remove_air = air.get_moles(/datum/gas/silicon)
	air.adjust_moles(/datum/gas/silicon, -remove_air)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	air.adjust_moles(/datum/gas/lube, cleaned_air)

/datum/gas_reaction/spraytan
    priority = 1
    name = "spraytan"
    id = "spraytan"


/datum/gas_reaction/spraytan/init_reqs()
	min_requirements = list(
		/datum/gas/orangejuice = 1,
		/datum/gas/oil = 1
	)


/datum/gas_reaction/spraytan/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/orangejuice) + air.get_moles(/datum/gas/oil)
	remove_air = air.get_moles(/datum/gas/orangejuice)
	air.adjust_moles(/datum/gas/orangejuice, -remove_air)
	remove_air = air.get_moles(/datum/gas/oil)
	air.adjust_moles(/datum/gas/oil, -remove_air)
	air.adjust_moles(/datum/gas/spraytan, cleaned_air)

/datum/gas_reaction/impedrezene
    priority = 1
    name = "impedrezene"
    id = "impedrezene"


/datum/gas_reaction/impedrezene/init_reqs()
	min_requirements = list(
		/datum/gas/mercury = 1,
		/datum/gas/oxygen = 1,
		/datum/gas/sugar = 1
	)


/datum/gas_reaction/impedrezene/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/mercury) + air.get_moles(/datum/gas/oxygen) + air.get_moles(/datum/gas/sugar)
	remove_air = air.get_moles(/datum/gas/mercury)
	air.adjust_moles(/datum/gas/mercury, -remove_air)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	remove_air = air.get_moles(/datum/gas/sugar)
	air.adjust_moles(/datum/gas/sugar, -remove_air)
	air.adjust_moles(/datum/gas/impedrezene, cleaned_air)

/datum/gas_reaction/concentrated_bz
    priority = 1
    name = "concentrated_bz"
    id = "concentrated_bz"


/datum/gas_reaction/concentrated_bz/init_reqs()
	min_requirements = list(
		/datum/gas/plasma = 40,
		/datum/gas/nitrous_oxide = 40
	)


/datum/gas_reaction/concentrated_bz/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/plasma) + air.get_moles(/datum/gas/nitrous_oxide)
	remove_air = air.get_moles(/datum/gas/plasma)
	air.adjust_moles(/datum/gas/plasma, -remove_air)
	remove_air = air.get_moles(/datum/gas/nitrous_oxide)
	air.adjust_moles(/datum/gas/nitrous_oxide, -remove_air)
	air.adjust_moles(/datum/gas/concentrated_bz, cleaned_air)

/datum/gas_reaction/fake_cbz
    priority = 1
    name = "fake_cbz"
    id = "fake_cbz"


/datum/gas_reaction/fake_cbz/init_reqs()
	min_requirements = list(
		/datum/gas/concentrated_bz = 1,
		/datum/gas/neurine = 1
	)


/datum/gas_reaction/fake_cbz/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/concentrated_bz) + air.get_moles(/datum/gas/neurine)
	remove_air = air.get_moles(/datum/gas/concentrated_bz)
	air.adjust_moles(/datum/gas/concentrated_bz, -remove_air)
	remove_air = air.get_moles(/datum/gas/neurine)
	air.adjust_moles(/datum/gas/neurine, -remove_air)
	air.adjust_moles(/datum/gas/fake_cbz, cleaned_air)

/datum/gas_reaction/cryptobiolin
    priority = 1
    name = "cryptobiolin"
    id = "cryptobiolin"


/datum/gas_reaction/cryptobiolin/init_reqs()
	min_requirements = list(
		/datum/gas/potassium = 1,
		/datum/gas/oxygen = 1,
		/datum/gas/sugar = 1
	)


/datum/gas_reaction/cryptobiolin/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/potassium) + air.get_moles(/datum/gas/oxygen) + air.get_moles(/datum/gas/sugar)
	remove_air = air.get_moles(/datum/gas/potassium)
	air.adjust_moles(/datum/gas/potassium, -remove_air)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	remove_air = air.get_moles(/datum/gas/sugar)
	air.adjust_moles(/datum/gas/sugar, -remove_air)
	air.adjust_moles(/datum/gas/cryptobiolin, cleaned_air)

/datum/gas_reaction/glycerol
    priority = 1
    name = "glycerol"
    id = "glycerol"


/datum/gas_reaction/glycerol/init_reqs()
	min_requirements = list(
		/datum/gas/cornoil = 3,
		/datum/gas/acid = 3
	)


/datum/gas_reaction/glycerol/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/cornoil) + air.get_moles(/datum/gas/acid)
	remove_air = air.get_moles(/datum/gas/cornoil)
	air.adjust_moles(/datum/gas/cornoil, -remove_air)
	remove_air = air.get_moles(/datum/gas/acid)
	air.adjust_moles(/datum/gas/acid, -remove_air)
	air.adjust_moles(/datum/gas/glycerol, cleaned_air)

/datum/gas_reaction/sodiumchloride
    priority = 1
    name = "sodiumchloride"
    id = "sodiumchloride"


/datum/gas_reaction/sodiumchloride/init_reqs()
	min_requirements = list(
		/datum/gas/water = 1,
		/datum/gas/sodium = 1,
		/datum/gas/chlorine = 1
	)


/datum/gas_reaction/sodiumchloride/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/water) + air.get_moles(/datum/gas/sodium) + air.get_moles(/datum/gas/chlorine)
	remove_air = air.get_moles(/datum/gas/water)
	air.adjust_moles(/datum/gas/water, -remove_air)
	remove_air = air.get_moles(/datum/gas/sodium)
	air.adjust_moles(/datum/gas/sodium, -remove_air)
	remove_air = air.get_moles(/datum/gas/chlorine)
	air.adjust_moles(/datum/gas/chlorine, -remove_air)
	air.adjust_moles(/datum/gas/sodiumchloride, cleaned_air)

/datum/gas_reaction/carbondioxide
    priority = 1
    name = "carbondioxide"
    id = "carbondioxide"


/datum/gas_reaction/carbondioxide/init_reqs()
	min_requirements = list(
		/datum/gas/carbon = 1,
		/datum/gas/oxygen = 1,
		"TEMP" = 777)

/datum/gas_reaction/carbondioxide/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/carbon) + air.get_moles(/datum/gas/oxygen)
	remove_air = air.get_moles(/datum/gas/carbon)
	air.adjust_moles(/datum/gas/carbon, -remove_air)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	air.adjust_moles(/datum/gas/carbondioxide, cleaned_air)

/datum/gas_reaction/nitrous_oxide
    priority = 1
    name = "nitrous_oxide"
    id = "nitrous_oxide"


/datum/gas_reaction/nitrous_oxide/init_reqs()
	min_requirements = list(
		/datum/gas/ammonia = 2,
		/datum/gas/nitrogen = 2,
		/datum/gas/oxygen = 2,
		"TEMP" = 525)

/datum/gas_reaction/nitrous_oxide/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/ammonia) + air.get_moles(/datum/gas/nitrogen) + air.get_moles(/datum/gas/oxygen)
	remove_air = air.get_moles(/datum/gas/ammonia)
	air.adjust_moles(/datum/gas/ammonia, -remove_air)
	remove_air = air.get_moles(/datum/gas/nitrogen)
	air.adjust_moles(/datum/gas/nitrogen, -remove_air)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	air.adjust_moles(/datum/gas/nitrous_oxide, cleaned_air)

/datum/gas_reaction/mulligan
    priority = 1
    name = "mulligan"
    id = "mulligan"


/datum/gas_reaction/mulligan/init_reqs()
	min_requirements = list(
		/datum/gas/slime_toxin = 1,
		/datum/gas/mutagen = 1
	)


/datum/gas_reaction/mulligan/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/slime_toxin) + air.get_moles(/datum/gas/mutagen)
	remove_air = air.get_moles(/datum/gas/slime_toxin)
	air.adjust_moles(/datum/gas/slime_toxin, -remove_air)
	remove_air = air.get_moles(/datum/gas/mutagen)
	air.adjust_moles(/datum/gas/mutagen, -remove_air)
	air.adjust_moles(/datum/gas/mulligan, cleaned_air)

/datum/gas_reaction/virus_food
    priority = 1
    name = "virus_food"
    id = "virus_food"


/datum/gas_reaction/virus_food/init_reqs()
	min_requirements = list(
		/datum/gas/water = 5,
		/datum/gas/milk = 5
	)


/datum/gas_reaction/virus_food/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/water) + air.get_moles(/datum/gas/milk)
	remove_air = air.get_moles(/datum/gas/water)
	air.adjust_moles(/datum/gas/water, -remove_air)
	remove_air = air.get_moles(/datum/gas/milk)
	air.adjust_moles(/datum/gas/milk, -remove_air)
	air.adjust_moles(/datum/gas/virus_food, cleaned_air)

/datum/gas_reaction/foaming_agent
    priority = 1
    name = "foaming_agent"
    id = "foaming_agent"


/datum/gas_reaction/foaming_agent/init_reqs()
	min_requirements = list(
		/datum/gas/lithium = 1,
		/datum/gas/hydrogen = 1
	)


/datum/gas_reaction/foaming_agent/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/lithium) + air.get_moles(/datum/gas/hydrogen)
	remove_air = air.get_moles(/datum/gas/lithium)
	air.adjust_moles(/datum/gas/lithium, -remove_air)
	remove_air = air.get_moles(/datum/gas/hydrogen)
	air.adjust_moles(/datum/gas/hydrogen, -remove_air)
	air.adjust_moles(/datum/gas/foaming_agent, cleaned_air)

/datum/gas_reaction/smart_foaming_agent
    priority = 1
    name = "smart_foaming_agent"
    id = "smart_foaming_agent"


/datum/gas_reaction/smart_foaming_agent/init_reqs()
	min_requirements = list(
		/datum/gas/foaming_agent = 3,
		/datum/gas/acetone = 3,
		/datum/gas/iron = 3
	)


/datum/gas_reaction/smart_foaming_agent/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/foaming_agent) + air.get_moles(/datum/gas/acetone) + air.get_moles(/datum/gas/iron)
	remove_air = air.get_moles(/datum/gas/foaming_agent)
	air.adjust_moles(/datum/gas/foaming_agent, -remove_air)
	remove_air = air.get_moles(/datum/gas/acetone)
	air.adjust_moles(/datum/gas/acetone, -remove_air)
	remove_air = air.get_moles(/datum/gas/iron)
	air.adjust_moles(/datum/gas/iron, -remove_air)
	air.adjust_moles(/datum/gas/smart_foaming_agent, cleaned_air)

/datum/gas_reaction/ammonia
    priority = 1
    name = "ammonia"
    id = "ammonia"


/datum/gas_reaction/ammonia/init_reqs()
	min_requirements = list(
		/datum/gas/hydrogen = 3,
		/datum/gas/nitrogen = 3
	)


/datum/gas_reaction/ammonia/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/hydrogen) + air.get_moles(/datum/gas/nitrogen)
	remove_air = air.get_moles(/datum/gas/hydrogen)
	air.adjust_moles(/datum/gas/hydrogen, -remove_air)
	remove_air = air.get_moles(/datum/gas/nitrogen)
	air.adjust_moles(/datum/gas/nitrogen, -remove_air)
	air.adjust_moles(/datum/gas/ammonia, cleaned_air)

/datum/gas_reaction/diethylamine
    priority = 1
    name = "diethylamine"
    id = "diethylamine"


/datum/gas_reaction/diethylamine/init_reqs()
	min_requirements = list(
		/datum/gas/ammonia = 1,
		/datum/gas/ethanol = 1
	)


/datum/gas_reaction/diethylamine/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/ammonia) + air.get_moles(/datum/gas/ethanol)
	remove_air = air.get_moles(/datum/gas/ammonia)
	air.adjust_moles(/datum/gas/ammonia, -remove_air)
	remove_air = air.get_moles(/datum/gas/ethanol)
	air.adjust_moles(/datum/gas/ethanol, -remove_air)
	air.adjust_moles(/datum/gas/diethylamine, cleaned_air)

/datum/gas_reaction/space_cleaner
    priority = 1
    name = "space_cleaner"
    id = "space_cleaner"


/datum/gas_reaction/space_cleaner/init_reqs()
	min_requirements = list(
		/datum/gas/ammonia = 1,
		/datum/gas/water = 1
	)


/datum/gas_reaction/space_cleaner/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/ammonia) + air.get_moles(/datum/gas/water)
	remove_air = air.get_moles(/datum/gas/ammonia)
	air.adjust_moles(/datum/gas/ammonia, -remove_air)
	remove_air = air.get_moles(/datum/gas/water)
	air.adjust_moles(/datum/gas/water, -remove_air)
	air.adjust_moles(/datum/gas/space_cleaner, cleaned_air)

/datum/gas_reaction/plantbgone
    priority = 1
    name = "plantbgone"
    id = "plantbgone"


/datum/gas_reaction/plantbgone/init_reqs()
	min_requirements = list(
		/datum/gas/toxin = 1,
		/datum/gas/water = 1
	)


/datum/gas_reaction/plantbgone/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/toxin) + air.get_moles(/datum/gas/water)
	remove_air = air.get_moles(/datum/gas/toxin)
	air.adjust_moles(/datum/gas/toxin, -remove_air)
	remove_air = air.get_moles(/datum/gas/water)
	air.adjust_moles(/datum/gas/water, -remove_air)
	air.adjust_moles(/datum/gas/plantbgone, cleaned_air)

/datum/gas_reaction/weedkiller
    priority = 1
    name = "weedkiller"
    id = "weedkiller"


/datum/gas_reaction/weedkiller/init_reqs()
	min_requirements = list(
		/datum/gas/toxin = 1,
		/datum/gas/ammonia = 1
	)


/datum/gas_reaction/weedkiller/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/toxin) + air.get_moles(/datum/gas/ammonia)
	remove_air = air.get_moles(/datum/gas/toxin)
	air.adjust_moles(/datum/gas/toxin, -remove_air)
	remove_air = air.get_moles(/datum/gas/ammonia)
	air.adjust_moles(/datum/gas/ammonia, -remove_air)
	air.adjust_moles(/datum/gas/weedkiller, cleaned_air)

/datum/gas_reaction/pestkiller
    priority = 1
    name = "pestkiller"
    id = "pestkiller"


/datum/gas_reaction/pestkiller/init_reqs()
	min_requirements = list(
		/datum/gas/toxin = 1,
		/datum/gas/ethanol = 1
	)


/datum/gas_reaction/pestkiller/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/toxin) + air.get_moles(/datum/gas/ethanol)
	remove_air = air.get_moles(/datum/gas/toxin)
	air.adjust_moles(/datum/gas/toxin, -remove_air)
	remove_air = air.get_moles(/datum/gas/ethanol)
	air.adjust_moles(/datum/gas/ethanol, -remove_air)
	air.adjust_moles(/datum/gas/pestkiller, cleaned_air)

/datum/gas_reaction/drying_agent
    priority = 1
    name = "drying_agent"
    id = "drying_agent"


/datum/gas_reaction/drying_agent/init_reqs()
	min_requirements = list(
		/datum/gas/stable_plasma = 2,
		/datum/gas/ethanol = 2,
		/datum/gas/sodium = 2
	)


/datum/gas_reaction/drying_agent/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/stable_plasma) + air.get_moles(/datum/gas/ethanol) + air.get_moles(/datum/gas/sodium)
	remove_air = air.get_moles(/datum/gas/stable_plasma)
	air.adjust_moles(/datum/gas/stable_plasma, -remove_air)
	remove_air = air.get_moles(/datum/gas/ethanol)
	air.adjust_moles(/datum/gas/ethanol, -remove_air)
	remove_air = air.get_moles(/datum/gas/sodium)
	air.adjust_moles(/datum/gas/sodium, -remove_air)
	air.adjust_moles(/datum/gas/drying_agent, cleaned_air)

/datum/gas_reaction/acetone
    priority = 1
    name = "acetone"
    id = "acetone"


/datum/gas_reaction/acetone/init_reqs()
	min_requirements = list(
		/datum/gas/oil = 1,
		/datum/gas/fuel = 1,
		/datum/gas/oxygen = 1
	)


/datum/gas_reaction/acetone/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/oil) + air.get_moles(/datum/gas/fuel) + air.get_moles(/datum/gas/oxygen)
	remove_air = air.get_moles(/datum/gas/oil)
	air.adjust_moles(/datum/gas/oil, -remove_air)
	remove_air = air.get_moles(/datum/gas/fuel)
	air.adjust_moles(/datum/gas/fuel, -remove_air)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	air.adjust_moles(/datum/gas/acetone, cleaned_air)

/datum/gas_reaction/carpet
    priority = 1
    name = "carpet"
    id = "carpet"


/datum/gas_reaction/carpet/init_reqs()
	min_requirements = list(
		/datum/gas/space_drugs = 1,
		/datum/gas/blood = 1
	)


/datum/gas_reaction/carpet/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/space_drugs) + air.get_moles(/datum/gas/blood)
	remove_air = air.get_moles(/datum/gas/space_drugs)
	air.adjust_moles(/datum/gas/space_drugs, -remove_air)
	remove_air = air.get_moles(/datum/gas/blood)
	air.adjust_moles(/datum/gas/blood, -remove_air)
	air.adjust_moles(/datum/gas/carpet, cleaned_air)

/datum/gas_reaction/oil
    priority = 1
    name = "oil"
    id = "oil"


/datum/gas_reaction/oil/init_reqs()
	min_requirements = list(
		/datum/gas/fuel = 1,
		/datum/gas/carbon = 1,
		/datum/gas/hydrogen = 1
	)


/datum/gas_reaction/oil/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/fuel) + air.get_moles(/datum/gas/carbon) + air.get_moles(/datum/gas/hydrogen)
	remove_air = air.get_moles(/datum/gas/fuel)
	air.adjust_moles(/datum/gas/fuel, -remove_air)
	remove_air = air.get_moles(/datum/gas/carbon)
	air.adjust_moles(/datum/gas/carbon, -remove_air)
	remove_air = air.get_moles(/datum/gas/hydrogen)
	air.adjust_moles(/datum/gas/hydrogen, -remove_air)
	air.adjust_moles(/datum/gas/oil, cleaned_air)

/datum/gas_reaction/phenol
    priority = 1
    name = "phenol"
    id = "phenol"


/datum/gas_reaction/phenol/init_reqs()
	min_requirements = list(
		/datum/gas/water = 1,
		/datum/gas/chlorine = 1,
		/datum/gas/oil = 1
	)


/datum/gas_reaction/phenol/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/water) + air.get_moles(/datum/gas/chlorine) + air.get_moles(/datum/gas/oil)
	remove_air = air.get_moles(/datum/gas/water)
	air.adjust_moles(/datum/gas/water, -remove_air)
	remove_air = air.get_moles(/datum/gas/chlorine)
	air.adjust_moles(/datum/gas/chlorine, -remove_air)
	remove_air = air.get_moles(/datum/gas/oil)
	air.adjust_moles(/datum/gas/oil, -remove_air)
	air.adjust_moles(/datum/gas/phenol, cleaned_air)

/datum/gas_reaction/ash
    priority = 1
    name = "ash"
    id = "ash"


/datum/gas_reaction/ash/init_reqs()
	min_requirements = list(
		/datum/gas/oil = 1,
		"TEMP" = 480)

/datum/gas_reaction/ash/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/oil)
	remove_air = air.get_moles(/datum/gas/oil)
	air.adjust_moles(/datum/gas/oil, -remove_air)
	air.adjust_moles(/datum/gas/ash, cleaned_air)

/datum/gas_reaction/colorful_reagent
    priority = 1
    name = "colorful_reagent"
    id = "colorful_reagent"


/datum/gas_reaction/colorful_reagent/init_reqs()
	min_requirements = list(
		/datum/gas/stable_plasma = 1,
		/datum/gas/radium = 1,
		/datum/gas/space_drugs = 1,
		/datum/gas/cryoxadone = 1,
		/datum/gas/triple_citrus = 1
	)


/datum/gas_reaction/colorful_reagent/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/stable_plasma) + air.get_moles(/datum/gas/radium) + air.get_moles(/datum/gas/space_drugs) + air.get_moles(/datum/gas/cryoxadone) + air.get_moles(/datum/gas/triple_citrus)
	remove_air = air.get_moles(/datum/gas/stable_plasma)
	air.adjust_moles(/datum/gas/stable_plasma, -remove_air)
	remove_air = air.get_moles(/datum/gas/radium)
	air.adjust_moles(/datum/gas/radium, -remove_air)
	remove_air = air.get_moles(/datum/gas/space_drugs)
	air.adjust_moles(/datum/gas/space_drugs, -remove_air)
	remove_air = air.get_moles(/datum/gas/cryoxadone)
	air.adjust_moles(/datum/gas/cryoxadone, -remove_air)
	remove_air = air.get_moles(/datum/gas/triple_citrus)
	air.adjust_moles(/datum/gas/triple_citrus, -remove_air)
	air.adjust_moles(/datum/gas/colorful_reagent, cleaned_air)

/datum/gas_reaction/hair_dye
    priority = 1
    name = "hair_dye"
    id = "hair_dye"


/datum/gas_reaction/hair_dye/init_reqs()
	min_requirements = list(
		/datum/gas/colorful_reagent = 1,
		/datum/gas/radium = 1,
		/datum/gas/space_drugs = 1
	)


/datum/gas_reaction/hair_dye/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/colorful_reagent) + air.get_moles(/datum/gas/radium) + air.get_moles(/datum/gas/space_drugs)
	remove_air = air.get_moles(/datum/gas/colorful_reagent)
	air.adjust_moles(/datum/gas/colorful_reagent, -remove_air)
	remove_air = air.get_moles(/datum/gas/radium)
	air.adjust_moles(/datum/gas/radium, -remove_air)
	remove_air = air.get_moles(/datum/gas/space_drugs)
	air.adjust_moles(/datum/gas/space_drugs, -remove_air)
	air.adjust_moles(/datum/gas/hair_dye, cleaned_air)

/datum/gas_reaction/barbers_aid
    priority = 1
    name = "barbers_aid"
    id = "barbers_aid"


/datum/gas_reaction/barbers_aid/init_reqs()
	min_requirements = list(
		/datum/gas/carpet = 1,
		/datum/gas/radium = 1,
		/datum/gas/space_drugs = 1
	)


/datum/gas_reaction/barbers_aid/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/carpet) + air.get_moles(/datum/gas/radium) + air.get_moles(/datum/gas/space_drugs)
	remove_air = air.get_moles(/datum/gas/carpet)
	air.adjust_moles(/datum/gas/carpet, -remove_air)
	remove_air = air.get_moles(/datum/gas/radium)
	air.adjust_moles(/datum/gas/radium, -remove_air)
	remove_air = air.get_moles(/datum/gas/space_drugs)
	air.adjust_moles(/datum/gas/space_drugs, -remove_air)
	air.adjust_moles(/datum/gas/barbers_aid, cleaned_air)

/datum/gas_reaction/concentrated_barbers_aid
    priority = 1
    name = "concentrated_barbers_aid"
    id = "concentrated_barbers_aid"


/datum/gas_reaction/concentrated_barbers_aid/init_reqs()
	min_requirements = list(
		/datum/gas/barbers_aid = 1,
		/datum/gas/mutagen = 1
	)


/datum/gas_reaction/concentrated_barbers_aid/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/barbers_aid) + air.get_moles(/datum/gas/mutagen)
	remove_air = air.get_moles(/datum/gas/barbers_aid)
	air.adjust_moles(/datum/gas/barbers_aid, -remove_air)
	remove_air = air.get_moles(/datum/gas/mutagen)
	air.adjust_moles(/datum/gas/mutagen, -remove_air)
	air.adjust_moles(/datum/gas/concentrated_barbers_aid, cleaned_air)

/datum/gas_reaction/saltpetre
    priority = 1
    name = "saltpetre"
    id = "saltpetre"


/datum/gas_reaction/saltpetre/init_reqs()
	min_requirements = list(
		/datum/gas/potassium = 1,
		/datum/gas/nitrogen = 1,
		/datum/gas/oxygen = 1
	)


/datum/gas_reaction/saltpetre/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/potassium) + air.get_moles(/datum/gas/nitrogen) + air.get_moles(/datum/gas/oxygen)
	remove_air = air.get_moles(/datum/gas/potassium)
	air.adjust_moles(/datum/gas/potassium, -remove_air)
	remove_air = air.get_moles(/datum/gas/nitrogen)
	air.adjust_moles(/datum/gas/nitrogen, -remove_air)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	air.adjust_moles(/datum/gas/saltpetre, cleaned_air)

/datum/gas_reaction/lye
    priority = 1
    name = "lye"
    id = "lye"


/datum/gas_reaction/lye/init_reqs()
	min_requirements = list(
		/datum/gas/sodium = 1,
		/datum/gas/hydrogen = 1,
		/datum/gas/oxygen = 1
	)


/datum/gas_reaction/lye/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/sodium) + air.get_moles(/datum/gas/hydrogen) + air.get_moles(/datum/gas/oxygen)
	remove_air = air.get_moles(/datum/gas/sodium)
	air.adjust_moles(/datum/gas/sodium, -remove_air)
	remove_air = air.get_moles(/datum/gas/hydrogen)
	air.adjust_moles(/datum/gas/hydrogen, -remove_air)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	air.adjust_moles(/datum/gas/lye, cleaned_air)

/datum/gas_reaction/royal_bee_jelly
    priority = 1
    name = "royal_bee_jelly"
    id = "royal_bee_jelly"


/datum/gas_reaction/royal_bee_jelly/init_reqs()
	min_requirements = list(
		/datum/gas/mutagen = 10,
		/datum/gas/honey = 10
	)


/datum/gas_reaction/royal_bee_jelly/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/mutagen) + air.get_moles(/datum/gas/honey)
	remove_air = air.get_moles(/datum/gas/mutagen)
	air.adjust_moles(/datum/gas/mutagen, -remove_air)
	remove_air = air.get_moles(/datum/gas/honey)
	air.adjust_moles(/datum/gas/honey, -remove_air)
	air.adjust_moles(/datum/gas/royal_bee_jelly, cleaned_air)

/datum/gas_reaction/laughter
    priority = 1
    name = "laughter"
    id = "laughter"


/datum/gas_reaction/laughter/init_reqs()
	min_requirements = list(
		/datum/gas/sugar = 1,
		/datum/gas/banana = 1
	)


/datum/gas_reaction/laughter/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/sugar) + air.get_moles(/datum/gas/banana)
	remove_air = air.get_moles(/datum/gas/sugar)
	air.adjust_moles(/datum/gas/sugar, -remove_air)
	remove_air = air.get_moles(/datum/gas/banana)
	air.adjust_moles(/datum/gas/banana, -remove_air)
	air.adjust_moles(/datum/gas/laughter, cleaned_air)

/datum/gas_reaction/plastic_polymers
    priority = 1
    name = "plastic_polymers"
    id = "plastic_polymers"


/datum/gas_reaction/plastic_polymers/init_reqs()
	min_requirements = list(
		/datum/gas/oil = 5,
		/datum/gas/acid = 5,
		/datum/gas/ash = 5,
		"TEMP" = 374)

/datum/gas_reaction/plastic_polymers/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/oil) + air.get_moles(/datum/gas/acid) + air.get_moles(/datum/gas/ash)
	remove_air = air.get_moles(/datum/gas/oil)
	air.adjust_moles(/datum/gas/oil, -remove_air)
	remove_air = air.get_moles(/datum/gas/acid)
	air.adjust_moles(/datum/gas/acid, -remove_air)
	remove_air = air.get_moles(/datum/gas/ash)
	air.adjust_moles(/datum/gas/ash, -remove_air)
	air.adjust_moles(/datum/gas/plastic_polymers, cleaned_air)

/datum/gas_reaction/pax
    priority = 1
    name = "pax"
    id = "pax"


/datum/gas_reaction/pax/init_reqs()
	min_requirements = list(
		/datum/gas/mindbreaker = 1,
		/datum/gas/synaptizine = 1,
		/datum/gas/water = 1
	)


/datum/gas_reaction/pax/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/mindbreaker) + air.get_moles(/datum/gas/synaptizine) + air.get_moles(/datum/gas/water)
	remove_air = air.get_moles(/datum/gas/mindbreaker)
	air.adjust_moles(/datum/gas/mindbreaker, -remove_air)
	remove_air = air.get_moles(/datum/gas/synaptizine)
	air.adjust_moles(/datum/gas/synaptizine, -remove_air)
	remove_air = air.get_moles(/datum/gas/water)
	air.adjust_moles(/datum/gas/water, -remove_air)
	air.adjust_moles(/datum/gas/pax, cleaned_air)

/datum/gas_reaction/invisium
    priority = 1
    name = "invisium"
    id = "invisium"


/datum/gas_reaction/invisium/init_reqs()
	min_requirements = list(
		/datum/gas/teslium = 4,
		/datum/gas/space_cleaner = 4,
		/datum/gas/strange_reagent = 4,
		/datum/gas/methamphetamine = 4,
		/datum/gas/bluespace = 4
	)


/datum/gas_reaction/invisium/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/teslium) + air.get_moles(/datum/gas/space_cleaner) + air.get_moles(/datum/gas/strange_reagent) + air.get_moles(/datum/gas/methamphetamine) + air.get_moles(/datum/gas/bluespace)
	remove_air = air.get_moles(/datum/gas/teslium)
	air.adjust_moles(/datum/gas/teslium, -remove_air)
	remove_air = air.get_moles(/datum/gas/space_cleaner)
	air.adjust_moles(/datum/gas/space_cleaner, -remove_air)
	remove_air = air.get_moles(/datum/gas/strange_reagent)
	air.adjust_moles(/datum/gas/strange_reagent, -remove_air)
	remove_air = air.get_moles(/datum/gas/methamphetamine)
	air.adjust_moles(/datum/gas/methamphetamine, -remove_air)
	remove_air = air.get_moles(/datum/gas/bluespace)
	air.adjust_moles(/datum/gas/bluespace, -remove_air)
	air.adjust_moles(/datum/gas/invisium, cleaned_air)

/datum/gas_reaction/blackpowder
    priority = 1
    name = "blackpowder"
    id = "blackpowder"


/datum/gas_reaction/blackpowder/init_reqs()
	min_requirements = list(
		/datum/gas/saltpetre = 1,
		/datum/gas/charcoal = 1,
		/datum/gas/sulfur = 1
	)


/datum/gas_reaction/blackpowder/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/saltpetre) + air.get_moles(/datum/gas/charcoal) + air.get_moles(/datum/gas/sulfur)
	remove_air = air.get_moles(/datum/gas/saltpetre)
	air.adjust_moles(/datum/gas/saltpetre, -remove_air)
	remove_air = air.get_moles(/datum/gas/charcoal)
	air.adjust_moles(/datum/gas/charcoal, -remove_air)
	remove_air = air.get_moles(/datum/gas/sulfur)
	air.adjust_moles(/datum/gas/sulfur, -remove_air)
	air.adjust_moles(/datum/gas/blackpowder, cleaned_air)

/datum/gas_reaction/thermite
    priority = 1
    name = "thermite"
    id = "thermite"


/datum/gas_reaction/thermite/init_reqs()
	min_requirements = list(
		/datum/gas/aluminium = 1,
		/datum/gas/iron = 1,
		/datum/gas/oxygen = 1
	)


/datum/gas_reaction/thermite/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/aluminium) + air.get_moles(/datum/gas/iron) + air.get_moles(/datum/gas/oxygen)
	remove_air = air.get_moles(/datum/gas/aluminium)
	air.adjust_moles(/datum/gas/aluminium, -remove_air)
	remove_air = air.get_moles(/datum/gas/iron)
	air.adjust_moles(/datum/gas/iron, -remove_air)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	air.adjust_moles(/datum/gas/thermite, cleaned_air)

/datum/gas_reaction/stabilizing_agent
    priority = 1
    name = "stabilizing_agent"
    id = "stabilizing_agent"


/datum/gas_reaction/stabilizing_agent/init_reqs()
	min_requirements = list(
		/datum/gas/iron = 1,
		/datum/gas/oxygen = 1,
		/datum/gas/hydrogen = 1
	)


/datum/gas_reaction/stabilizing_agent/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/iron) + air.get_moles(/datum/gas/oxygen) + air.get_moles(/datum/gas/hydrogen)
	remove_air = air.get_moles(/datum/gas/iron)
	air.adjust_moles(/datum/gas/iron, -remove_air)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	remove_air = air.get_moles(/datum/gas/hydrogen)
	air.adjust_moles(/datum/gas/hydrogen, -remove_air)
	air.adjust_moles(/datum/gas/stabilizing_agent, cleaned_air)

/datum/gas_reaction/clf3
    priority = 1
    name = "clf3"
    id = "clf3"


/datum/gas_reaction/clf3/init_reqs()
	min_requirements = list(
		/datum/gas/chlorine = 1,
		/datum/gas/fluorine = 1,
		"TEMP" = 424)

/datum/gas_reaction/clf3/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/chlorine) + air.get_moles(/datum/gas/fluorine)
	remove_air = air.get_moles(/datum/gas/chlorine)
	air.adjust_moles(/datum/gas/chlorine, -remove_air)
	remove_air = air.get_moles(/datum/gas/fluorine)
	air.adjust_moles(/datum/gas/fluorine, -remove_air)
	air.adjust_moles(/datum/gas/clf3, cleaned_air)

/datum/gas_reaction/sorium
    priority = 1
    name = "sorium"
    id = "sorium"


/datum/gas_reaction/sorium/init_reqs()
	min_requirements = list(
		/datum/gas/mercury = 1,
		/datum/gas/oxygen = 1,
		/datum/gas/nitrogen = 1,
		/datum/gas/carbon = 1
	)


/datum/gas_reaction/sorium/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/mercury) + air.get_moles(/datum/gas/oxygen) + air.get_moles(/datum/gas/nitrogen) + air.get_moles(/datum/gas/carbon)
	remove_air = air.get_moles(/datum/gas/mercury)
	air.adjust_moles(/datum/gas/mercury, -remove_air)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	remove_air = air.get_moles(/datum/gas/nitrogen)
	air.adjust_moles(/datum/gas/nitrogen, -remove_air)
	remove_air = air.get_moles(/datum/gas/carbon)
	air.adjust_moles(/datum/gas/carbon, -remove_air)
	air.adjust_moles(/datum/gas/sorium, cleaned_air)

/datum/gas_reaction/liquid_dark_matter
    priority = 1
    name = "liquid_dark_matter"
    id = "liquid_dark_matter"


/datum/gas_reaction/liquid_dark_matter/init_reqs()
	min_requirements = list(
		/datum/gas/stable_plasma = 1,
		/datum/gas/radium = 1,
		/datum/gas/carbon = 1
	)


/datum/gas_reaction/liquid_dark_matter/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/stable_plasma) + air.get_moles(/datum/gas/radium) + air.get_moles(/datum/gas/carbon)
	remove_air = air.get_moles(/datum/gas/stable_plasma)
	air.adjust_moles(/datum/gas/stable_plasma, -remove_air)
	remove_air = air.get_moles(/datum/gas/radium)
	air.adjust_moles(/datum/gas/radium, -remove_air)
	remove_air = air.get_moles(/datum/gas/carbon)
	air.adjust_moles(/datum/gas/carbon, -remove_air)
	air.adjust_moles(/datum/gas/liquid_dark_matter, cleaned_air)

/datum/gas_reaction/flash_powder
    priority = 1
    name = "flash_powder"
    id = "flash_powder"


/datum/gas_reaction/flash_powder/init_reqs()
	min_requirements = list(
		/datum/gas/aluminium = 1,
		/datum/gas/potassium = 1,
		/datum/gas/sulfur = 1
	)


/datum/gas_reaction/flash_powder/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/aluminium) + air.get_moles(/datum/gas/potassium) + air.get_moles(/datum/gas/sulfur)
	remove_air = air.get_moles(/datum/gas/aluminium)
	air.adjust_moles(/datum/gas/aluminium, -remove_air)
	remove_air = air.get_moles(/datum/gas/potassium)
	air.adjust_moles(/datum/gas/potassium, -remove_air)
	remove_air = air.get_moles(/datum/gas/sulfur)
	air.adjust_moles(/datum/gas/sulfur, -remove_air)
	air.adjust_moles(/datum/gas/flash_powder, cleaned_air)

/datum/gas_reaction/smoke_powder
    priority = 1
    name = "smoke_powder"
    id = "smoke_powder"


/datum/gas_reaction/smoke_powder/init_reqs()
	min_requirements = list(
		/datum/gas/potassium = 1,
		/datum/gas/sugar = 1,
		/datum/gas/phosphorus = 1
	)


/datum/gas_reaction/smoke_powder/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/potassium) + air.get_moles(/datum/gas/sugar) + air.get_moles(/datum/gas/phosphorus)
	remove_air = air.get_moles(/datum/gas/potassium)
	air.adjust_moles(/datum/gas/potassium, -remove_air)
	remove_air = air.get_moles(/datum/gas/sugar)
	air.adjust_moles(/datum/gas/sugar, -remove_air)
	remove_air = air.get_moles(/datum/gas/phosphorus)
	air.adjust_moles(/datum/gas/phosphorus, -remove_air)
	air.adjust_moles(/datum/gas/smoke_powder, cleaned_air)

/datum/gas_reaction/sonic_powder
    priority = 1
    name = "sonic_powder"
    id = "sonic_powder"


/datum/gas_reaction/sonic_powder/init_reqs()
	min_requirements = list(
		/datum/gas/oxygen = 1,
		/datum/gas/space_cola = 1,
		/datum/gas/phosphorus = 1
	)


/datum/gas_reaction/sonic_powder/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/oxygen) + air.get_moles(/datum/gas/space_cola) + air.get_moles(/datum/gas/phosphorus)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	remove_air = air.get_moles(/datum/gas/space_cola)
	air.adjust_moles(/datum/gas/space_cola, -remove_air)
	remove_air = air.get_moles(/datum/gas/phosphorus)
	air.adjust_moles(/datum/gas/phosphorus, -remove_air)
	air.adjust_moles(/datum/gas/sonic_powder, cleaned_air)

/datum/gas_reaction/phlogiston
    priority = 1
    name = "phlogiston"
    id = "phlogiston"


/datum/gas_reaction/phlogiston/init_reqs()
	min_requirements = list(
		/datum/gas/phosphorus = 1,
		/datum/gas/acid = 1,
		/datum/gas/stable_plasma = 1
	)


/datum/gas_reaction/phlogiston/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/phosphorus) + air.get_moles(/datum/gas/acid) + air.get_moles(/datum/gas/stable_plasma)
	remove_air = air.get_moles(/datum/gas/phosphorus)
	air.adjust_moles(/datum/gas/phosphorus, -remove_air)
	remove_air = air.get_moles(/datum/gas/acid)
	air.adjust_moles(/datum/gas/acid, -remove_air)
	remove_air = air.get_moles(/datum/gas/stable_plasma)
	air.adjust_moles(/datum/gas/stable_plasma, -remove_air)
	air.adjust_moles(/datum/gas/phlogiston, cleaned_air)

/datum/gas_reaction/napalm
    priority = 1
    name = "napalm"
    id = "napalm"


/datum/gas_reaction/napalm/init_reqs()
	min_requirements = list(
		/datum/gas/oil = 1,
		/datum/gas/fuel = 1,
		/datum/gas/ethanol = 1
	)


/datum/gas_reaction/napalm/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/oil) + air.get_moles(/datum/gas/fuel) + air.get_moles(/datum/gas/ethanol)
	remove_air = air.get_moles(/datum/gas/oil)
	air.adjust_moles(/datum/gas/oil, -remove_air)
	remove_air = air.get_moles(/datum/gas/fuel)
	air.adjust_moles(/datum/gas/fuel, -remove_air)
	remove_air = air.get_moles(/datum/gas/ethanol)
	air.adjust_moles(/datum/gas/ethanol, -remove_air)
	air.adjust_moles(/datum/gas/napalm, cleaned_air)

/datum/gas_reaction/cryostylane
    priority = 1
    name = "cryostylane"
    id = "cryostylane"


/datum/gas_reaction/cryostylane/init_reqs()
	min_requirements = list(
		/datum/gas/water = 1,
		/datum/gas/stable_plasma = 1,
		/datum/gas/nitrogen = 1
	)


/datum/gas_reaction/cryostylane/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/water) + air.get_moles(/datum/gas/stable_plasma) + air.get_moles(/datum/gas/nitrogen)
	remove_air = air.get_moles(/datum/gas/water)
	air.adjust_moles(/datum/gas/water, -remove_air)
	remove_air = air.get_moles(/datum/gas/stable_plasma)
	air.adjust_moles(/datum/gas/stable_plasma, -remove_air)
	remove_air = air.get_moles(/datum/gas/nitrogen)
	air.adjust_moles(/datum/gas/nitrogen, -remove_air)
	air.adjust_moles(/datum/gas/cryostylane, cleaned_air)

/datum/gas_reaction/pyrosium
    priority = 1
    name = "pyrosium"
    id = "pyrosium"


/datum/gas_reaction/pyrosium/init_reqs()
	min_requirements = list(
		/datum/gas/stable_plasma = 1,
		/datum/gas/radium = 1,
		/datum/gas/phosphorus = 1
	)


/datum/gas_reaction/pyrosium/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/stable_plasma) + air.get_moles(/datum/gas/radium) + air.get_moles(/datum/gas/phosphorus)
	remove_air = air.get_moles(/datum/gas/stable_plasma)
	air.adjust_moles(/datum/gas/stable_plasma, -remove_air)
	remove_air = air.get_moles(/datum/gas/radium)
	air.adjust_moles(/datum/gas/radium, -remove_air)
	remove_air = air.get_moles(/datum/gas/phosphorus)
	air.adjust_moles(/datum/gas/phosphorus, -remove_air)
	air.adjust_moles(/datum/gas/pyrosium, cleaned_air)

/datum/gas_reaction/teslium
    priority = 1
    name = "teslium"
    id = "teslium"


/datum/gas_reaction/teslium/init_reqs()
	min_requirements = list(
		/datum/gas/stable_plasma = 1,
		/datum/gas/silver = 1,
		/datum/gas/blackpowder = 1,
		"TEMP" = 400)

/datum/gas_reaction/teslium/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/stable_plasma) + air.get_moles(/datum/gas/silver) + air.get_moles(/datum/gas/blackpowder)
	remove_air = air.get_moles(/datum/gas/stable_plasma)
	air.adjust_moles(/datum/gas/stable_plasma, -remove_air)
	remove_air = air.get_moles(/datum/gas/silver)
	air.adjust_moles(/datum/gas/silver, -remove_air)
	remove_air = air.get_moles(/datum/gas/blackpowder)
	air.adjust_moles(/datum/gas/blackpowder, -remove_air)
	air.adjust_moles(/datum/gas/teslium, cleaned_air)

/datum/gas_reaction/energized_jelly
    priority = 1
    name = "energized_jelly"
    id = "energized_jelly"


/datum/gas_reaction/energized_jelly/init_reqs()
	min_requirements = list(
		/datum/gas/slimejelly = 1,
		/datum/gas/teslium = 1
	)


/datum/gas_reaction/energized_jelly/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/slimejelly) + air.get_moles(/datum/gas/teslium)
	remove_air = air.get_moles(/datum/gas/slimejelly)
	air.adjust_moles(/datum/gas/slimejelly, -remove_air)
	remove_air = air.get_moles(/datum/gas/teslium)
	air.adjust_moles(/datum/gas/teslium, -remove_air)
	air.adjust_moles(/datum/gas/energized_jelly, cleaned_air)

/datum/gas_reaction/firefighting_foam
    priority = 1
    name = "firefighting_foam"
    id = "firefighting_foam"


/datum/gas_reaction/firefighting_foam/init_reqs()
	min_requirements = list(
		/datum/gas/stabilizing_agent = 1,
		/datum/gas/fluorosurfactant = 1,
		/datum/gas/carbon = 1,
		"TEMP" = 200)

/datum/gas_reaction/firefighting_foam/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/stabilizing_agent) + air.get_moles(/datum/gas/fluorosurfactant) + air.get_moles(/datum/gas/carbon)
	remove_air = air.get_moles(/datum/gas/stabilizing_agent)
	air.adjust_moles(/datum/gas/stabilizing_agent, -remove_air)
	remove_air = air.get_moles(/datum/gas/fluorosurfactant)
	air.adjust_moles(/datum/gas/fluorosurfactant, -remove_air)
	remove_air = air.get_moles(/datum/gas/carbon)
	air.adjust_moles(/datum/gas/carbon, -remove_air)
	air.adjust_moles(/datum/gas/firefighting_foam, cleaned_air)

/datum/gas_reaction/formaldehyde
    priority = 1
    name = "formaldehyde"
    id = "formaldehyde"


/datum/gas_reaction/formaldehyde/init_reqs()
	min_requirements = list(
		/datum/gas/ethanol = 1,
		/datum/gas/oxygen = 1,
		/datum/gas/silver = 1,
		"TEMP" = 420)

/datum/gas_reaction/formaldehyde/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/ethanol) + air.get_moles(/datum/gas/oxygen) + air.get_moles(/datum/gas/silver)
	remove_air = air.get_moles(/datum/gas/ethanol)
	air.adjust_moles(/datum/gas/ethanol, -remove_air)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	remove_air = air.get_moles(/datum/gas/silver)
	air.adjust_moles(/datum/gas/silver, -remove_air)
	air.adjust_moles(/datum/gas/formaldehyde, cleaned_air)

/datum/gas_reaction/fentanyl
    priority = 1
    name = "fentanyl"
    id = "fentanyl"


/datum/gas_reaction/fentanyl/init_reqs()
	min_requirements = list(
		/datum/gas/space_drugs = 1,
		"TEMP" = 674)

/datum/gas_reaction/fentanyl/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/space_drugs)
	remove_air = air.get_moles(/datum/gas/space_drugs)
	air.adjust_moles(/datum/gas/space_drugs, -remove_air)
	air.adjust_moles(/datum/gas/fentanyl, cleaned_air)

/datum/gas_reaction/cyanide
    priority = 1
    name = "cyanide"
    id = "cyanide"


/datum/gas_reaction/cyanide/init_reqs()
	min_requirements = list(
		/datum/gas/oil = 1,
		/datum/gas/ammonia = 1,
		/datum/gas/oxygen = 1,
		"TEMP" = 380)

/datum/gas_reaction/cyanide/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/oil) + air.get_moles(/datum/gas/ammonia) + air.get_moles(/datum/gas/oxygen)
	remove_air = air.get_moles(/datum/gas/oil)
	air.adjust_moles(/datum/gas/oil, -remove_air)
	remove_air = air.get_moles(/datum/gas/ammonia)
	air.adjust_moles(/datum/gas/ammonia, -remove_air)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	air.adjust_moles(/datum/gas/cyanide, cleaned_air)

/datum/gas_reaction/itching_powder
    priority = 1
    name = "itching_powder"
    id = "itching_powder"


/datum/gas_reaction/itching_powder/init_reqs()
	min_requirements = list(
		/datum/gas/fuel = 1,
		/datum/gas/ammonia = 1,
		/datum/gas/charcoal = 1
	)


/datum/gas_reaction/itching_powder/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/fuel) + air.get_moles(/datum/gas/ammonia) + air.get_moles(/datum/gas/charcoal)
	remove_air = air.get_moles(/datum/gas/fuel)
	air.adjust_moles(/datum/gas/fuel, -remove_air)
	remove_air = air.get_moles(/datum/gas/ammonia)
	air.adjust_moles(/datum/gas/ammonia, -remove_air)
	remove_air = air.get_moles(/datum/gas/charcoal)
	air.adjust_moles(/datum/gas/charcoal, -remove_air)
	air.adjust_moles(/datum/gas/itching_powder, cleaned_air)

/datum/gas_reaction/sulfonal
    priority = 1
    name = "sulfonal"
    id = "sulfonal"


/datum/gas_reaction/sulfonal/init_reqs()
	min_requirements = list(
		/datum/gas/perfluorodecalin = 1,
		/datum/gas/diethylamine = 1,
		/datum/gas/sulfur = 1
	)


/datum/gas_reaction/sulfonal/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/perfluorodecalin) + air.get_moles(/datum/gas/diethylamine) + air.get_moles(/datum/gas/sulfur)
	remove_air = air.get_moles(/datum/gas/perfluorodecalin)
	air.adjust_moles(/datum/gas/perfluorodecalin, -remove_air)
	remove_air = air.get_moles(/datum/gas/diethylamine)
	air.adjust_moles(/datum/gas/diethylamine, -remove_air)
	remove_air = air.get_moles(/datum/gas/sulfur)
	air.adjust_moles(/datum/gas/sulfur, -remove_air)
	air.adjust_moles(/datum/gas/sulfonal, cleaned_air)

/datum/gas_reaction/lipolicide
    priority = 1
    name = "lipolicide"
    id = "lipolicide"


/datum/gas_reaction/lipolicide/init_reqs()
	min_requirements = list(
		/datum/gas/mercury = 1,
		/datum/gas/diethylamine = 1,
		/datum/gas/ephedrine = 1
	)


/datum/gas_reaction/lipolicide/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/mercury) + air.get_moles(/datum/gas/diethylamine) + air.get_moles(/datum/gas/ephedrine)
	remove_air = air.get_moles(/datum/gas/mercury)
	air.adjust_moles(/datum/gas/mercury, -remove_air)
	remove_air = air.get_moles(/datum/gas/diethylamine)
	air.adjust_moles(/datum/gas/diethylamine, -remove_air)
	remove_air = air.get_moles(/datum/gas/ephedrine)
	air.adjust_moles(/datum/gas/ephedrine, -remove_air)
	air.adjust_moles(/datum/gas/lipolicide, cleaned_air)

/datum/gas_reaction/mutagen
    priority = 1
    name = "mutagen"
    id = "mutagen"


/datum/gas_reaction/mutagen/init_reqs()
	min_requirements = list(
		/datum/gas/radium = 1,
		/datum/gas/phosphorus = 1,
		/datum/gas/chlorine = 1
	)


/datum/gas_reaction/mutagen/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/radium) + air.get_moles(/datum/gas/phosphorus) + air.get_moles(/datum/gas/chlorine)
	remove_air = air.get_moles(/datum/gas/radium)
	air.adjust_moles(/datum/gas/radium, -remove_air)
	remove_air = air.get_moles(/datum/gas/phosphorus)
	air.adjust_moles(/datum/gas/phosphorus, -remove_air)
	remove_air = air.get_moles(/datum/gas/chlorine)
	air.adjust_moles(/datum/gas/chlorine, -remove_air)
	air.adjust_moles(/datum/gas/mutagen, cleaned_air)

/datum/gas_reaction/lexorin
    priority = 1
    name = "lexorin"
    id = "lexorin"


/datum/gas_reaction/lexorin/init_reqs()
	min_requirements = list(
		/datum/gas/plasma = 1,
		/datum/gas/hydrogen = 1,
		/datum/gas/oxygen = 1,
		/datum/gas/sulfonal = 1
	)


/datum/gas_reaction/lexorin/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/plasma) + air.get_moles(/datum/gas/hydrogen) + air.get_moles(/datum/gas/oxygen) + air.get_moles(/datum/gas/sulfonal)
	remove_air = air.get_moles(/datum/gas/plasma)
	air.adjust_moles(/datum/gas/plasma, -remove_air)
	remove_air = air.get_moles(/datum/gas/hydrogen)
	air.adjust_moles(/datum/gas/hydrogen, -remove_air)
	remove_air = air.get_moles(/datum/gas/oxygen)
	air.adjust_moles(/datum/gas/oxygen, -remove_air)
	remove_air = air.get_moles(/datum/gas/sulfonal)
	air.adjust_moles(/datum/gas/sulfonal, -remove_air)
	air.adjust_moles(/datum/gas/lexorin, cleaned_air)

/datum/gas_reaction/chloralhydrate
    priority = 1
    name = "chloralhydrate"
    id = "chloralhydrate"


/datum/gas_reaction/chloralhydrate/init_reqs()
	min_requirements = list(
		/datum/gas/ethanol = 1,
		/datum/gas/chlorine = 1,
		/datum/gas/water = 1
	)


/datum/gas_reaction/chloralhydrate/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/ethanol) + air.get_moles(/datum/gas/chlorine) + air.get_moles(/datum/gas/water)
	remove_air = air.get_moles(/datum/gas/ethanol)
	air.adjust_moles(/datum/gas/ethanol, -remove_air)
	remove_air = air.get_moles(/datum/gas/chlorine)
	air.adjust_moles(/datum/gas/chlorine, -remove_air)
	remove_air = air.get_moles(/datum/gas/water)
	air.adjust_moles(/datum/gas/water, -remove_air)
	air.adjust_moles(/datum/gas/chloralhydrate, cleaned_air)

/datum/gas_reaction/mutetoxin
    priority = 1
    name = "mutetoxin"
    id = "mutetoxin"


/datum/gas_reaction/mutetoxin/init_reqs()
	min_requirements = list(
		/datum/gas/uranium = 2,
		/datum/gas/water = 2,
		/datum/gas/carbon = 2
	)


/datum/gas_reaction/mutetoxin/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/uranium) + air.get_moles(/datum/gas/water) + air.get_moles(/datum/gas/carbon)
	remove_air = air.get_moles(/datum/gas/uranium)
	air.adjust_moles(/datum/gas/uranium, -remove_air)
	remove_air = air.get_moles(/datum/gas/water)
	air.adjust_moles(/datum/gas/water, -remove_air)
	remove_air = air.get_moles(/datum/gas/carbon)
	air.adjust_moles(/datum/gas/carbon, -remove_air)
	air.adjust_moles(/datum/gas/mutetoxin, cleaned_air)

/datum/gas_reaction/zombiepowder
    priority = 1
    name = "zombiepowder"
    id = "zombiepowder"


/datum/gas_reaction/zombiepowder/init_reqs()
	min_requirements = list(
		/datum/gas/carpotoxin = 5,
		/datum/gas/morphine = 5,
		/datum/gas/copper = 5
	)


/datum/gas_reaction/zombiepowder/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/carpotoxin) + air.get_moles(/datum/gas/morphine) + air.get_moles(/datum/gas/copper)
	remove_air = air.get_moles(/datum/gas/carpotoxin)
	air.adjust_moles(/datum/gas/carpotoxin, -remove_air)
	remove_air = air.get_moles(/datum/gas/morphine)
	air.adjust_moles(/datum/gas/morphine, -remove_air)
	remove_air = air.get_moles(/datum/gas/copper)
	air.adjust_moles(/datum/gas/copper, -remove_air)
	air.adjust_moles(/datum/gas/zombiepowder, cleaned_air)

/datum/gas_reaction/ghoulpowder
    priority = 1
    name = "ghoulpowder"
    id = "ghoulpowder"


/datum/gas_reaction/ghoulpowder/init_reqs()
	min_requirements = list(
		/datum/gas/zombiepowder = 1,
		/datum/gas/epinephrine = 1
	)


/datum/gas_reaction/ghoulpowder/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/zombiepowder) + air.get_moles(/datum/gas/epinephrine)
	remove_air = air.get_moles(/datum/gas/zombiepowder)
	air.adjust_moles(/datum/gas/zombiepowder, -remove_air)
	remove_air = air.get_moles(/datum/gas/epinephrine)
	air.adjust_moles(/datum/gas/epinephrine, -remove_air)
	air.adjust_moles(/datum/gas/ghoulpowder, cleaned_air)

/datum/gas_reaction/mindbreaker
    priority = 1
    name = "mindbreaker"
    id = "mindbreaker"


/datum/gas_reaction/mindbreaker/init_reqs()
	min_requirements = list(
		/datum/gas/silicon = 1,
		/datum/gas/hydrogen = 1,
		/datum/gas/charcoal = 1
	)


/datum/gas_reaction/mindbreaker/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/silicon) + air.get_moles(/datum/gas/hydrogen) + air.get_moles(/datum/gas/charcoal)
	remove_air = air.get_moles(/datum/gas/silicon)
	air.adjust_moles(/datum/gas/silicon, -remove_air)
	remove_air = air.get_moles(/datum/gas/hydrogen)
	air.adjust_moles(/datum/gas/hydrogen, -remove_air)
	remove_air = air.get_moles(/datum/gas/charcoal)
	air.adjust_moles(/datum/gas/charcoal, -remove_air)
	air.adjust_moles(/datum/gas/mindbreaker, cleaned_air)

/datum/gas_reaction/heparin
    priority = 1
    name = "heparin"
    id = "heparin"


/datum/gas_reaction/heparin/init_reqs()
	min_requirements = list(
		/datum/gas/formaldehyde = 1,
		/datum/gas/sodium = 1,
		/datum/gas/chlorine = 1,
		/datum/gas/lithium = 1
	)


/datum/gas_reaction/heparin/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/formaldehyde) + air.get_moles(/datum/gas/sodium) + air.get_moles(/datum/gas/chlorine) + air.get_moles(/datum/gas/lithium)
	remove_air = air.get_moles(/datum/gas/formaldehyde)
	air.adjust_moles(/datum/gas/formaldehyde, -remove_air)
	remove_air = air.get_moles(/datum/gas/sodium)
	air.adjust_moles(/datum/gas/sodium, -remove_air)
	remove_air = air.get_moles(/datum/gas/chlorine)
	air.adjust_moles(/datum/gas/chlorine, -remove_air)
	remove_air = air.get_moles(/datum/gas/lithium)
	air.adjust_moles(/datum/gas/lithium, -remove_air)
	air.adjust_moles(/datum/gas/heparin, cleaned_air)

/datum/gas_reaction/rotatium
    priority = 1
    name = "rotatium"
    id = "rotatium"


/datum/gas_reaction/rotatium/init_reqs()
	min_requirements = list(
		/datum/gas/mindbreaker = 1,
		/datum/gas/teslium = 1,
		/datum/gas/fentanyl = 1
	)


/datum/gas_reaction/rotatium/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/mindbreaker) + air.get_moles(/datum/gas/teslium) + air.get_moles(/datum/gas/fentanyl)
	remove_air = air.get_moles(/datum/gas/mindbreaker)
	air.adjust_moles(/datum/gas/mindbreaker, -remove_air)
	remove_air = air.get_moles(/datum/gas/teslium)
	air.adjust_moles(/datum/gas/teslium, -remove_air)
	remove_air = air.get_moles(/datum/gas/fentanyl)
	air.adjust_moles(/datum/gas/fentanyl, -remove_air)
	air.adjust_moles(/datum/gas/rotatium, cleaned_air)

/datum/gas_reaction/skewium
    priority = 1
    name = "skewium"
    id = "skewium"


/datum/gas_reaction/skewium/init_reqs()
	min_requirements = list(
		/datum/gas/rotatium = 2,
		/datum/gas/plasma = 2,
		/datum/gas/acid = 2
	)


/datum/gas_reaction/skewium/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/rotatium) + air.get_moles(/datum/gas/plasma) + air.get_moles(/datum/gas/acid)
	remove_air = air.get_moles(/datum/gas/rotatium)
	air.adjust_moles(/datum/gas/rotatium, -remove_air)
	remove_air = air.get_moles(/datum/gas/plasma)
	air.adjust_moles(/datum/gas/plasma, -remove_air)
	remove_air = air.get_moles(/datum/gas/acid)
	air.adjust_moles(/datum/gas/acid, -remove_air)
	air.adjust_moles(/datum/gas/skewium, cleaned_air)

/datum/gas_reaction/anacea
    priority = 1
    name = "anacea"
    id = "anacea"


/datum/gas_reaction/anacea/init_reqs()
	min_requirements = list(
		/datum/gas/haloperidol = 1,
		/datum/gas/impedrezene = 1,
		/datum/gas/radium = 1
	)


/datum/gas_reaction/anacea/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/haloperidol) + air.get_moles(/datum/gas/impedrezene) + air.get_moles(/datum/gas/radium)
	remove_air = air.get_moles(/datum/gas/haloperidol)
	air.adjust_moles(/datum/gas/haloperidol, -remove_air)
	remove_air = air.get_moles(/datum/gas/impedrezene)
	air.adjust_moles(/datum/gas/impedrezene, -remove_air)
	remove_air = air.get_moles(/datum/gas/radium)
	air.adjust_moles(/datum/gas/radium, -remove_air)
	air.adjust_moles(/datum/gas/anacea, cleaned_air)

/datum/gas_reaction/mimesbane
    priority = 1
    name = "mimesbane"
    id = "mimesbane"


/datum/gas_reaction/mimesbane/init_reqs()
	min_requirements = list(
		/datum/gas/radium = 1,
		/datum/gas/mutetoxin = 1,
		/datum/gas/nothing = 1
	)


/datum/gas_reaction/mimesbane/react(datum/gas_mixture/air, datum/holder)
	var/remove_air = 0
	var/cleaned_air = air.get_moles(/datum/gas/radium) + air.get_moles(/datum/gas/mutetoxin) + air.get_moles(/datum/gas/nothing)
	remove_air = air.get_moles(/datum/gas/radium)
	air.adjust_moles(/datum/gas/radium, -remove_air)
	remove_air = air.get_moles(/datum/gas/mutetoxin)
	air.adjust_moles(/datum/gas/mutetoxin, -remove_air)
	remove_air = air.get_moles(/datum/gas/nothing)
	air.adjust_moles(/datum/gas/nothing, -remove_air)
	air.adjust_moles(/datum/gas/mimesbane, cleaned_air)

// END

/datum/gas_reaction/stim_ball
	priority = 7
	name ="Stimulum Energy Ball"
	id = "stimball"

/datum/gas_reaction/stim_ball/init_reqs()
	min_requirements = list(
		/datum/gas/pluoxium = STIM_BALL_GAS_AMOUNT,
		/datum/gas/stimulum = STIM_BALL_GAS_AMOUNT,
		/datum/gas/nitryl = MINIMUM_MOLE_COUNT,
		/datum/gas/plasma = MINIMUM_MOLE_COUNT,
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	)

/datum/gas_reaction/stim_ball/react(datum/gas_mixture/air, datum/holder)
	var/turf/open/location
	var/old_heat_capacity = air.heat_capacity()
	if(istype(holder,/datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/pipenet = holder
		location = get_turf(pick(pipenet.members))
	else
		location = get_turf(holder)
	var/ball_shot_angle = 180*cos(air.get_moles(/datum/gas/water_vapor)/air.get_moles(/datum/gas/nitryl))+180
	var/stim_used = min(STIM_BALL_GAS_AMOUNT/air.get_moles(/datum/gas/plasma),air.get_moles(/datum/gas/stimulum))
	var/pluox_used = min(STIM_BALL_GAS_AMOUNT/air.get_moles(/datum/gas/plasma),air.get_moles(/datum/gas/pluoxium))
	var/energy_released = stim_used*STIMULUM_HEAT_SCALE//Stimulum has a lot of stored energy, and breaking it up releases some of it
	location.fire_nuclear_particle(ball_shot_angle)
	air.adjust_moles(/datum/gas/carbon_dioxide, 4*pluox_used)
	air.adjust_moles(/datum/gas/nitrogen, 8*stim_used)
	air.adjust_moles(/datum/gas/pluoxium, -pluox_used)
	air.adjust_moles(/datum/gas/stimulum, -stim_used)
	air.adjust_moles(/datum/gas/plasma, air.get_moles(/datum/gas/plasma)/2)
	if(energy_released)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.set_temperature(CLAMP((air.return_temperature()*old_heat_capacity + energy_released)/new_heat_capacity,TCMB,INFINITY))
		return REACTING
