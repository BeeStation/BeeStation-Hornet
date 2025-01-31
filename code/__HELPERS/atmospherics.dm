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
