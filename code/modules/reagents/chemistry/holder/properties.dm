//============================VOLUME======================================
/// Is this holder full or not
/datum/reagents/proc/holder_full()
	return total_volume >= maximum_volume

/**
 * Get the amount of this reagent or the sum of all its subtypes if specified
 * Arguments
 * * [reagent][datum/reagent] - the typepath of the reagent to look for
 * * type_check - see defines under reagents.dm file
 */
/datum/reagents/proc/get_reagent_amount(datum/reagent/reagent, type_check = REAGENT_STRICT_TYPE)
	if(!ispath(reagent))
		stack_trace("invalid path passed to get_reagent_amount [reagent]")
		return 0
	var/list/cached_reagents = reagent_list

	var/total_amount = 0
	for(var/datum/reagent/cached_reagent as anything in cached_reagents)
		switch(type_check)
			if(REAGENT_STRICT_TYPE)
				if(cached_reagent.type != reagent)
					continue
			if(REAGENT_PARENT_TYPE) //to simulate typesof() which returns the type and then child types
				if(cached_reagent.type != reagent && cached_reagent::parent_type != reagent)
					continue
			else
				if(!istype(cached_reagent, reagent))
					continue

		total_amount += cached_reagent.volume

		//short cut to break when we have found our one exact type
		if(type_check == REAGENT_STRICT_TYPE)
			break

	return total_amount


//==========================TEMPERATURE======================================
/// Returns the total heat capacity for all of the reagents currently in this holder.
/datum/reagents/proc/heat_capacity()
	. = 0
	var/list/cached_reagents = reagent_list //cache reagents
	for(var/datum/reagent/reagent in cached_reagents)
		. += reagent.specific_heat * reagent.volume

/** Adjusts the thermal energy of the reagents in this holder by an amount.
 *
 * Arguments:
 * - delta_energy: The amount to change the thermal energy by.
 * - min_temp: The minimum temperature that can be reached.
 * - max_temp: The maximum temperature that can be reached.
 */
/datum/reagents/proc/adjust_thermal_energy(delta_energy, min_temp = 2.7, max_temp = 1000)
	var/heat_capacity = heat_capacity()
	if(!heat_capacity)
		return // no div/0 please
	set_temperature(clamp(chem_temp + (delta_energy / heat_capacity), min_temp, max_temp))

/** Sets the temperature of this reagent container to a new value.
 *
 * Handles setter signals.
 *
 * Arguments:
 * - _temperature: The new temperature value.
 */
/datum/reagents/proc/set_temperature(_temperature)
	if(_temperature == chem_temp)
		return

	. = chem_temp
	chem_temp = clamp(_temperature, 0, CHEMICAL_MAXIMUM_TEMPERATURE)
	SEND_SIGNAL(src, COMSIG_REAGENTS_TEMP_CHANGE, _temperature, .)

//================================TASTE===================================================
/**
  * Returns what this holder's reagents taste like
  *
  * Arguments:
  * * minimum_percent - the lower the minimum percent, the more sensitive the message is.
  */
/datum/reagents/proc/generate_taste_message(minimum_percent=15)
	var/list/out = list()
	var/list/tastes = list() //descriptor = strength
	if(minimum_percent <= 100)
		for(var/datum/reagent/R in reagent_list)
			if(!R.taste_mult)
				continue

			if(istype(R, /datum/reagent/consumable/nutriment))
				var/list/taste_data = R.data
				for(var/taste in taste_data)
					var/ratio = taste_data[taste]
					var/amount = ratio * R.taste_mult * R.volume
					if(taste in tastes)
						tastes[taste] += amount
					else
						tastes[taste] = amount
			else
				var/taste_desc = R.taste_description
				var/taste_amount = R.volume * R.taste_mult
				if(taste_desc in tastes)
					tastes[taste_desc] += taste_amount
				else
					tastes[taste_desc] = taste_amount
		//deal with percentages
		// TODO it would be great if we could sort these from strong to weak
		var/total_taste = counterlist_sum(tastes)
		if(total_taste > 0)
			for(var/taste_desc in tastes)
				var/percent = tastes[taste_desc]/total_taste * 100
				if(percent < minimum_percent)
					continue
				var/intensity_desc = "a hint of"
				if(percent > minimum_percent * 2 || percent == 100)
					intensity_desc = ""
				else if(percent > minimum_percent * 3)
					intensity_desc = "the strong flavor of"
				if(intensity_desc != "")
					out += "[intensity_desc] [taste_desc]"
				else
					out += "[taste_desc]"

	return english_list(out, "something indescribable")
