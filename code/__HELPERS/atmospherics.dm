/proc/molar_cmp_less_than(a,b,epsilon = MAXIMUM_ERROR_GAS_REMOVAL)
	return (a < (b + epsilon))

/proc/molar_cmp_greater_than(a,b,epsilon = MAXIMUM_ERROR_GAS_REMOVAL)
	return ((a + epsilon) > b)

/proc/molar_cmp_equals(a,b,epsilon = MAXIMUM_ERROR_GAS_REMOVAL)
	return (((a + epsilon) > b) && ((a - epsilon) < b))

/** A simple rudimentary gasmix to information list converter. Can be used for UIs.
 * Args:
 * - gasmix: [/datum/gas_mixture]
 * - name: String used to name the list, optional.
 * Returns: A list parsed_gasmixes with the following structure:
 * - parsed_gasmixes - Assoc List
 * -- Key: name			Value: String			Desc: Gasmix Name
 * -- Key: temperature		Value: Number			Desc: Temperature in kelvins
 * -- Key: volume 			Value: Number			Desc: Volume in liters
 * -- Key: pressure 		Value: Number			Desc: Pressure in kPa
 * -- Key: ref				Value: Text				Desc: The reference for the instantiated gasmix.
 * -- Key: gases			Value: Assoc list		Desc: List of gasses in our gasmix
 * --- Key: gas_name 		Value: Gas Mole			Desc: Gas Name - Gas Amount pair
 * Returned list should always be filled with keys even if value are nulls.
 */
/proc/gas_mixture_parser(datum/gas_mixture/gasmix, name)
	. = list(
		"gases" = list(),
		"reactions" = list(),
		"name" = format_text(name),
		"total_moles" = null,
		"temperature" = null,
		"volume"= null,
		"pressure"= null,
		"reference" = null,
	)
	if(!gasmix)
		return
	for(var/gas_path in gasmix.gases)
		.["gases"] += list(list(
			gasmix.gases[gas_path][GAS_META][META_GAS_ID],
			gasmix.gases[gas_path][GAS_META][META_GAS_NAME],
			gasmix.gases[gas_path][MOLES],
		))
	for(var/datum/gas_reaction/reaction_result as anything in gasmix.reaction_results)
		.["reactions"] += list(list(
			initial(reaction_result.id),
			initial(reaction_result.name),
			gasmix.reaction_results[reaction_result],
		))
	.["total_moles"] = gasmix.total_moles()
	.["temperature"] = gasmix.temperature
	.["volume"] = gasmix.volume
	.["pressure"] = gasmix.return_pressure()
	.["reference"] = REF(gasmix)

GLOBAL_LIST_EMPTY(reaction_handbook)
GLOBAL_LIST_EMPTY(gas_handbook)

/// Automatically populates gas_handbook and reaction_handbook. They are formatted lists containing information regarding gases and reactions they participate in.
/// Structure can be found in TS form at AtmosHandbook.tsx
/proc/atmos_handbooks_init()
	if(length(GLOB.reaction_handbook))
		GLOB.reaction_handbook = list()
	if(length(GLOB.gas_handbook))
		GLOB.gas_handbook = list()

	/// Final product is a numbered list, this one is assoc just so we can generate the "reactions" entry easily.
	var/list/momentary_gas_list = list()

	for (var/datum/gas/gas_path as anything in subtypesof(/datum/gas))
		var/list/gas_info = list()
		var/list/meta_information = GLOB.meta_gas_info[gas_path]
		if(!meta_information)
			continue
		gas_info["id"] = meta_information[META_GAS_ID]
		gas_info["name"] = meta_information[META_GAS_NAME]
		gas_info["description"] = meta_information[META_GAS_DESC]
		gas_info["specific_heat"] = meta_information[META_GAS_SPECIFIC_HEAT]
		gas_info["reactions"] = list()
		momentary_gas_list[gas_path] = gas_info

	for (var/datum/gas_reaction/reaction_path as anything in subtypesof(/datum/gas_reaction))
		var/datum/gas_reaction/reaction = new reaction_path
		var/list/reaction_info = list()
		reaction_info["id"] = reaction.id
		reaction_info["name"] = reaction.name
		reaction_info["description"] = reaction.desc
		reaction_info["factors"] = list()
		for (var/factor in reaction.factor)
			var/list/factor_info = list()
			factor_info["desc"] = reaction.factor[factor]

			if(factor in momentary_gas_list)
				momentary_gas_list[factor]["reactions"] += list(reaction.id = reaction.name)
				factor_info["factor_id"] = momentary_gas_list[factor]["id"] //Gas id
				factor_info["factor_type"] = "gas"
				factor_info["factor_name"] = momentary_gas_list[factor]["name"] //Common name
			else
				factor_info["factor_name"] = factor
				factor_info["factor_type"] = "misc"
				if(factor == "Temperature" || factor == "Pressure")
					factor_info["tooltip"] = "Reaction is influenced by the [LOWER_TEXT(factor)] of the place where the reaction is occuring."
				else if(factor == "Energy")
					factor_info["tooltip"] = "Energy released by the reaction, may or may not result in linear temperature change depending on a slew of other factors."
				else if(factor == "Radiation")
					factor_info["tooltip"] = "This reaction emits dangerous radiation! Take precautions."
				else if (factor == "Location")
					factor_info["tooltip"] = "This reaction has special behaviour when occuring in specific locations."
				else if(factor == "Hot Ice")
					factor_info["tooltip"] = "Hot ice are solidified stacks of plasma. Ignition of one will result in a raging fire."
			reaction_info["factors"] += list(factor_info)
		GLOB.reaction_handbook += list(reaction_info)
		qdel(reaction)

	for (var/gas_info_index in momentary_gas_list)
		GLOB.gas_handbook += list(momentary_gas_list[gas_info_index])

/// Returns an assoc list of the gas handbook and the reaction handbook.
/// For UIs, simply do data += return_atmos_handbooks() to use.
/proc/return_atmos_handbooks()
	return list("gasInfo" = GLOB.gas_handbook, "reactionInfo" = GLOB.reaction_handbook)

/proc/extract_id_tags(list/objects)
	var/list/tags = list()

	for (var/obj/object as anything in objects)
		tags += object.id_tag

	return tags

/proc/find_by_id_tag(list/objects, id_tag)
	for (var/obj/object as anything in objects)
		if (object.id_tag == id_tag)
			return object

	return null

/proc/print_gas_mixture(datum/gas_mixture/gas_mixture)
	var/message = "TEMPERATURE: [gas_mixture.temperature]K, QUANTITY: [gas_mixture.total_moles()] mols, VOLUME: [gas_mixture.volume]L; "
	for(var/key in gas_mixture.gases)
		var/list/gaslist = gas_mixture.gases[key]
		message += "[gaslist[GAS_META][META_GAS_ID]]=[gaslist[MOLES]] mols;"
	return message

/proc/log_atmos(text, datum/gas_mixture/gas_mixture)
	var/message = "[text]\"[print_gas_mixture(gas_mixture)]\""
	//Cache commonly accessed information.
	var/list/gases = gas_mixture.gases //List of gas datum paths that are associated with a list of information related to the gases.
	var/heat_capacity = gas_mixture.heat_capacity()
	var/temperature = gas_mixture.return_temperature()
	var/thermal_energy = temperature * heat_capacity
	var/volume = gas_mixture.return_volume()
	var/pressure = gas_mixture.return_pressure()
	var/total_moles = gas_mixture.total_moles()
	///The total value of the gas mixture in credits.
	var/total_value = 0
	var/list/specific_gas_data = list()

	//Gas specific information assigned to each gas.
	for(var/datum/gas/gas_path as anything in gases)
		var/list/gas = gases[gas_path]
		var/moles = gas[MOLES]
		var/composition = moles / total_moles
		var/energy = temperature * moles * gas[GAS_META][META_GAS_SPECIFIC_HEAT]
		var/value = initial(gas_path.base_value) * moles
		total_value += value
		specific_gas_data[gas[GAS_META][META_GAS_NAME]] = list(
			"moles" = moles,
			"composition" = composition,
			"molar concentration" = moles / volume,
			"partial pressure" = composition * pressure,
			"energy" = energy,
			"energy density" = energy / volume,
			"value" = value,
		)

	log_game(
		list(
			message,
			"total moles" = total_moles,
			"volume" = volume,
			"molar density" = total_moles / volume,
			"temperature" = temperature,
			"pressure" = pressure,
			"heat capacity" = heat_capacity,
			"energy" = thermal_energy,
			"energy density" = thermal_energy / volume,
			"value" = total_value,
			"gases" = specific_gas_data,
		)
	)
