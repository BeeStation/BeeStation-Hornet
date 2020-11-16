/datum/atmosphere
	var/gas_string
	var/id

	var/list/base_gases // A list of gases to always have
	var/list/normal_gases // A list of allowed gases:base_amount
	var/list/restricted_gases // A list of allowed gases like normal_gases but each can only be selected a maximum of one time
	var/restricted_chance = 10 // Chance per iteration to take from restricted gases

	var/minimum_pressure
	var/maximum_pressure

	var/minimum_temp
	var/maximum_temp

/datum/atmosphere/New()
	generate_gas_string()

/datum/atmosphere/proc/generate_gas_string()
	var/target_pressure = rand(minimum_pressure, maximum_pressure)
	var/pressure_scalar = target_pressure / maximum_pressure

	// First let's set up the gasmix and base gases for this template
	// We make the string from a gasmix in this proc because gases need to calculate their pressure
	var/datum/gas_mixture/gasmix = new
	gasmix.set_temperature(rand(minimum_temp, maximum_temp))
	for(var/i in base_gases)
		gasmix.set_moles(i, base_gases[i])

	// Now let the random choices begin
	var/datum/gas/gastype
	var/amount
	while(gasmix.return_pressure() < target_pressure)
		if(!prob(restricted_chance))
			gastype = pick(normal_gases)
			amount = normal_gases[gastype]
		else
			gastype = pick(restricted_gases)
			amount = restricted_gases[gastype]
			if(gasmix.get_moles(gastype))
				continue

		amount *= rand(50, 200) / 100	// Randomly modifes the amount from half to double the base for some variety
		amount *= pressure_scalar		// If we pick a really small target pressure we want roughly the same mix but less of it all
		amount = CEILING(amount, 0.1)

		gasmix.set_moles(gastype, gasmix.get_moles(gastype) + amount)

	// That last one put us over the limit, remove some of it
	while(gasmix.return_pressure() > target_pressure)
		gasmix.set_moles(gastype, gasmix.get_moles(gastype) - (gasmix.get_moles(gastype) * 0.1))
	gasmix.set_moles(gastype, FLOOR(gasmix.get_moles(gastype), 0.1))

	// Now finally lets make that string
	var/list/gas_string_builder = list()
	for(var/i in gasmix.get_gases())
		gas_string_builder += "[GLOB.meta_gas_info[i][META_GAS_ID]]=[gasmix.get_moles(i)]"
	gas_string_builder += "TEMP=[gasmix.return_temperature()]"
	gas_string = gas_string_builder.Join(";")
