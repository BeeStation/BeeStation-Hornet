GLOBAL_LIST_INIT(electrolyzer_reactions, electrolyzer_reactions_list())

/*
 * Global proc to build the electrolyzer reactions list
 */
/proc/electrolyzer_reactions_list()
	var/list/built_reaction_list = list()
	for(var/reaction_path in subtypesof(/datum/electrolyzer_reaction))
		var/datum/electrolyzer_reaction/reaction = new reaction_path()

		built_reaction_list[reaction.id] = reaction

	return built_reaction_list

/datum/electrolyzer_reaction
	var/name = "reaction"
	var/desc = ""
	var/id = "r"
	var/list/requirements
	var/list/factor

/**
 * electrolyzer reaction.
 * Args:
 * * air_mixture: The gas_mixture receiving the electrolysis.
 * * working_power: How much energy to put into the electrolysis, in electrolyzer units. A value of 1 is what a tier 1 electrolyzer would put in.
 */
/datum/electrolyzer_reaction/proc/react(datum/gas_mixture/air_mixture, working_power)
	return

/**
 * Checks whether the requirements are met for a reaction.
 * Args:
 * * air_mixture: The air mixture to check the requirements for.
 */
/datum/electrolyzer_reaction/proc/reaction_check(datum/gas_mixture/air_mixture)
	var/temp = air_mixture.temperature
	var/list/cached_moles = air_mixture.moles
	if((requirements["MIN_TEMP"] && temp < requirements["MIN_TEMP"]) || (requirements["MAX_TEMP"] && temp > requirements["MAX_TEMP"]))
		return FALSE
	for(var/requirement, required_amount in requirements)
		if (requirement == "MIN_TEMP" || requirement == "MAX_TEMP")
			continue
		if(cached_moles[requirement] < required_amount)
			return FALSE
	return TRUE

/datum/electrolyzer_reaction/h2o_conversion
	name = "H2O Conversion"
	id = "h2o_conversion"
	desc = "Conversion of H2o into O2 and H2"
	requirements = list(
		/datum/gas/water_vapor = MINIMUM_MOLE_COUNT
	)
	factor = list(
		/datum/gas/water_vapor = "2 moles of H2O get consumed",
		/datum/gas/oxygen = "1 mole of O2 gets produced",
		/datum/gas/hydrogen = "2 moles of H2 get produced",
		"Location" = "Can only happen on turfs with an active electrolyzer.",
	)

/datum/electrolyzer_reaction/h2o_conversion/react(datum/gas_mixture/air_mixture, working_power)
	var/old_heat_capacity = air_mixture.heat_capacity()

	var/proportion = min(air_mixture.moles[/datum/gas/water_vapor] * INVERSE(2), (2.5 * (working_power ** 2)))
	air_mixture.adjust_gas(/datum/gas/water_vapor, -proportion * 2)
	air_mixture.adjust_gas(/datum/gas/oxygen, proportion)
	air_mixture.adjust_gas(/datum/gas/hydrogen, proportion * 2)
	var/new_heat_capacity = air_mixture.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air_mixture.temperature = max(air_mixture.temperature * old_heat_capacity / new_heat_capacity, TCMB)

/datum/electrolyzer_reaction/nob_conversion
	name = "Hyper-Noblium Conversion"
	id = "nob_conversion"
	desc = "Conversion of hyper-noblium into anti-noblium"
	requirements = list(
		/datum/gas/hypernoblium = MINIMUM_MOLE_COUNT,
		"MAX_TEMP" = 150
	)
	factor = list(
		/datum/gas/hypernoblium = "1 mole of hyper-noblium gets consumed",
		/datum/gas/antinoblium = "0.5 moles of anti-noblium get produced",
		"Temperature" = "Can only occur under 150 kelvin.",
		"Location" = "Can only happen on turfs with an active electrolyzer.",
	)

/datum/electrolyzer_reaction/nob_conversion/react(datum/gas_mixture/air_mixture, working_power)
	var/old_heat_capacity = air_mixture.heat_capacity()
	air_mixture.assert_gases(/datum/gas/hypernoblium, /datum/gas/antinoblium)
	var/proportion = min(air_mixture.moles[/datum/gas/hypernoblium], (1.5 * (working_power ** 2)))

	air_mixture.adjust_multiple_gases(list(
		/datum/gas/hypernoblium = -proportion,
		/datum/gas/antinoblium = proportion * 0.5,
	))

	var/new_heat_capacity = air_mixture.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air_mixture.temperature = max(air_mixture.temperature * old_heat_capacity / new_heat_capacity, TCMB)

/datum/electrolyzer_reaction/halon_generation
	name = "Halon Generation"
	id = "halon_generation"
	desc = "Production of halon from the electrolysis of BZ."
	requirements = list(
		/datum/gas/bz = MINIMUM_MOLE_COUNT,
	)
	factor = list(
		/datum/gas/bz = "Consumed during reaction.",
		/datum/gas/oxygen = "0.2 moles of oxygen gets produced per mole of BZ consumed.",
		/datum/gas/halon = "2 moles of Halon gets produced per mole of BZ consumed.",
		"Energy" = "91.2321 kJ of thermal energy is released per mole of BZ consumed.",
		"Temperature" = "Reaction efficiency is proportional to temperature.",
		"Location" = "Can only happen on turfs with an active electrolyzer.",
	)

/datum/electrolyzer_reaction/halon_generation/react(datum/gas_mixture/air_mixture, working_power, list/electrolyzer_args = list())
	var/old_heat_capacity = air_mixture.heat_capacity()
	air_mixture.assert_gases(/datum/gas/bz, /datum/gas/oxygen, /datum/gas/halon)
	var/bz_moles = air_mixture.moles[/datum/gas/bz]
	var/reaction_efficency = min(bz_moles * (1 - NUM_E ** (-0.5 * air_mixture.temperature * working_power / FIRE_MINIMUM_TEMPERATURE_TO_EXIST)), bz_moles)

	air_mixture.adjust_multiple_gases(list(
		/datum/gas/bz = -reaction_efficency,
		/datum/gas/oxygen = reaction_efficency * 0.2,
		/datum/gas/halon = reaction_efficency * 2,
	))

	var/energy_used = reaction_efficency * HALON_FORMATION_ENERGY
	var/new_heat_capacity = air_mixture.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air_mixture.temperature = max(((air_mixture.temperature * old_heat_capacity + energy_used) / new_heat_capacity), TCMB)
