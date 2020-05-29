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
