 /*
What are the archived variables for?
	Calculations are done using the archived variables with the results merged into the regular variables.
	This prevents race conditions that arise based on the order of tile processing.
*/
#define MINIMUM_HEAT_CAPACITY	0.0003
#define MINIMUM_MOLE_COUNT		0.01
#define QUANTIZE(variable)		(round(variable,0.0000001))/*I feel the need to document what happens here. Basically this is used to catch most rounding errors, however it's previous value made it so that
															once gases got hot enough, most procedures wouldnt occur due to the fact that the mole counts would get rounded away. Thus, we lowered it a few orders of magnititude */
GLOBAL_LIST_INIT(meta_gas_info, meta_gas_list()) //see ATMOSPHERICS/gas_types.dm
GLOBAL_LIST_INIT(gaslist_cache, init_gaslist_cache())

/proc/init_gaslist_cache()
	. = list()
	for(var/id in GLOB.meta_gas_info)
		var/list/cached_gas = new(3)

		.[id] = cached_gas

		cached_gas[MOLES] = 0
		cached_gas[ARCHIVE] = 0
		cached_gas[GAS_META] = GLOB.meta_gas_info[id]

/datum/gas_mixture
	var/initial_volume = CELL_VOLUME //liters
	var/list/reaction_results
	var/list/analyzer_results //used for analyzer feedback - not initialized until its used
	var/_extools_pointer_gasmixture = 0 // Contains the memory address of the shared_ptr object for this gas mixture in c++ land. Don't. Touch. This. Var.

/datum/gas_mixture/New(volume)
	if (!isnull(volume))
		initial_volume = volume
	ATMOS_EXTOOLS_CHECK
	__gasmixture_register()
	reaction_results = new

/datum/gas_mixture/vv_edit_var(var_name, var_value)
	if(var_name == "_extools_pointer_gasmixture")
		return FALSE // please no. segfaults bad.
	return ..()

/datum/gas_mixture/proc/__gasmixture_unregister()
/datum/gas_mixture/proc/__gasmixture_register()

/proc/gas_types()
	var/list/L = subtypesof(/datum/gas)
	for(var/gt in L)
		var/datum/gas/G = gt
		L[gt] = initial(G.specific_heat)
	return L

/datum/gas_mixture/proc/heat_capacity(data = MOLES) //joules per kelvin

/datum/gas_mixture/proc/total_moles()

/datum/gas_mixture/proc/return_pressure() //kilopascals

/datum/gas_mixture/proc/return_temperature() //kelvins

/datum/gas_mixture/proc/set_min_heat_capacity(n)
/datum/gas_mixture/proc/set_temperature(new_temp)
/datum/gas_mixture/proc/set_volume(new_volume)
/datum/gas_mixture/proc/get_moles(gas_type)
/datum/gas_mixture/proc/set_moles(gas_type, moles)
/datum/gas_mixture/proc/scrub_into(datum/gas_mixture/target, list/gases)
/datum/gas_mixture/proc/mark_immutable()
/datum/gas_mixture/proc/get_gases()
/datum/gas_mixture/proc/multiply(factor)
/datum/gas_mixture/proc/get_last_share()
/datum/gas_mixture/proc/clear()

/datum/gas_mixture/proc/adjust_moles(gas_type, amt = 0)
	set_moles(gas_type, get_moles(gas_type) + amt)

/datum/gas_mixture/proc/return_volume() //liters

/datum/gas_mixture/proc/thermal_energy() //joules

/datum/gas_mixture/proc/archive()
	//Update archived versions of variables
	//Returns: 1 in all cases

/datum/gas_mixture/proc/merge(datum/gas_mixture/giver)
	//Merges all air from giver into self. Deletes giver.
	//Returns: 1 if we are mutable, 0 otherwise

/datum/gas_mixture/proc/remove(amount)
	//Proportionally removes amount of gas from the gas_mixture
	//Returns: gas_mixture with the gases removed

/datum/gas_mixture/proc/remove_ratio(ratio)
	//Proportionally removes amount of gas from the gas_mixture
	//Returns: gas_mixture with the gases removed

/datum/gas_mixture/proc/copy()
	//Creates new, identical gas mixture
	//Returns: duplicate gas mixture

/datum/gas_mixture/proc/copy_from(datum/gas_mixture/sample)
	//Copies variables from sample
	//Returns: 1 if we are mutable, 0 otherwise

/datum/gas_mixture/proc/copy_from_turf(turf/model)
	//Copies all gas info from the turf into the gas list along with temperature
	//Returns: 1 if we are mutable, 0 otherwise

/datum/gas_mixture/proc/parse_gas_string(gas_string)
	//Copies variables from a particularly formatted string.
	//Returns: 1 if we are mutable, 0 otherwise

/datum/gas_mixture/proc/share(datum/gas_mixture/sharer)
	//Performs air sharing calculations between two gas_mixtures assuming only 1 boundary length
	//Returns: amount of gas exchanged (+ if sharer received)

/datum/gas_mixture/proc/temperature_share(datum/gas_mixture/sharer, conduction_coefficient)
	//Performs temperature sharing calculations (via conduction) between two gas_mixtures assuming only 1 boundary length
	//Returns: new temperature of the sharer

/datum/gas_mixture/proc/compare(datum/gas_mixture/sample)
	//Compares sample to self to see if within acceptable ranges that group processing may be enabled
	//Returns: a string indicating what check failed, or "" if check passes

/datum/gas_mixture/proc/react(turf/open/dump_location)
	//Performs various reactions such as combustion or fusion (LOL)
	//Returns: 1 if any reaction took place; 0 otherwise

/datum/gas_mixture/proc/__remove()
/datum/gas_mixture/remove(amount)
	var/datum/gas_mixture/removed = new type
	__remove(removed, amount)

	return removed

/datum/gas_mixture/proc/__remove_ratio()
/datum/gas_mixture/remove_ratio(ratio)
	var/datum/gas_mixture/removed = new type
	__remove_ratio(removed, ratio)

	return removed

/datum/gas_mixture/copy()
	var/datum/gas_mixture/copy = new type
	copy.copy_from(src)

	return copy

/datum/gas_mixture/copy_from_turf(turf/model)
	parse_gas_string(model.initial_gas_mix)

	//acounts for changes in temperature
	var/turf/model_parent = model.parent_type
	if(model.temperature != initial(model.temperature) || model.temperature != initial(model_parent.temperature))
		set_temperature(model.temperature)

	return 1

/datum/gas_mixture/parse_gas_string(gas_string)
	gas_string = SSair.preprocess_gas_string(gas_string)

	var/list/gas = params2list(gas_string)
	if(gas["TEMP"])
		set_temperature(text2num(gas["TEMP"]))
		gas -= "TEMP"
	clear()
	for(var/id in gas)
		var/path = id
		if(!ispath(path))
			path = gas_id2path(path) //a lot of these strings can't have embedded expressions (especially for mappers), so support for IDs needs to stick around
		set_moles(path, text2num(gas[id]))
	return 1

/datum/gas_mixture/react(datum/holder)
	. = NO_REACTION
	var/list/reactions = list()
	for(var/I in get_gases())
		reactions += SSair.gas_reactions[I]
	if(!length(reactions))
		return
	reaction_results = new
	var/temp = return_temperature()
	var/ener = thermal_energy()

	reaction_loop:
		for(var/r in reactions)
			var/datum/gas_reaction/reaction = r

			var/list/min_reqs = reaction.min_requirements
			if((min_reqs["TEMP"] && temp < min_reqs["TEMP"]) \
			|| (min_reqs["ENER"] && ener < min_reqs["ENER"]))
				continue

			for(var/id in min_reqs)
				if (id == "TEMP" || id == "ENER")
					continue
				if(get_moles(id) < min_reqs[id])
					continue reaction_loop

			//at this point, all requirements for the reaction are satisfied. we can now react()

			. |= reaction.react(src, holder)
			if (. & STOP_REACTIONS)
				break

//Takes the amount of the gas you want to PP as an argument
//So I don't have to do some hacky switches/defines/magic strings
//eg:
//Tox_PP = get_partial_pressure(gas_mixture.toxins)
//O2_PP = get_partial_pressure(gas_mixture.oxygen)

/datum/gas_mixture/proc/get_breath_partial_pressure(gas_pressure)
	return (gas_pressure * R_IDEAL_GAS_EQUATION * return_temperature()) / BREATH_VOLUME
//inverse
/datum/gas_mixture/proc/get_true_breath_pressure(partial_pressure)
	return (partial_pressure * BREATH_VOLUME) / (R_IDEAL_GAS_EQUATION * return_temperature())

//Mathematical proofs:
/*
get_breath_partial_pressure(gas_pp) --> gas_pp/total_moles()*breath_pp = pp
get_true_breath_pressure(pp) --> gas_pp = pp/breath_pp*total_moles()

10/20*5 = 2.5
10 = 2.5/5*20
*/

/datum/gas_mixture/turf
