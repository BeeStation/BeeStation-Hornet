//"immutable" gas mixture used for immutable calculations
//it can be changed, but any changes will ultimately be undone before they can have any effect

/datum/gas_mixture/immutable
	var/initial_temperature = 0

/datum/gas_mixture/immutable/New()
	..()
	temperature = (initial_temperature)
	populate()
	mark_immutable()

/datum/gas_mixture/immutable/proc/populate()
	return

//used by space tiles
/datum/gas_mixture/immutable/space
	initial_temperature = TCMB

/datum/gas_mixture/immutable/space/populate()
	set_min_heat_capacity(HEAT_CAPACITY_VACUUM)

//used by cloners
/datum/gas_mixture/immutable/cloner
	initial_temperature = T20C

/datum/gas_mixture/immutable/cloner/populate()
	set_moles(/datum/gas/nitrogen, MOLES_O2STANDARD + MOLES_N2STANDARD)

//planet side stuff
/datum/gas_mixture/immutable/planetary
	var/list/initial_gas = list()

/datum/gas_mixture/immutable/planetary/garbage_collect()
	..()
	gases.Cut()
	for(var/id in initial_gas)
		ADD_GAS(id, gases)
		gases[id][MOLES] = initial_gas[id][MOLES]
		gases[id][ARCHIVE] = initial_gas[id][ARCHIVE]

/datum/gas_mixture/immutable/planetary/proc/parse_string_immutable(gas_string) //I know I know, I need this tho
	gas_string = SSair.preprocess_gas_string(gas_string)

	var/list/mix = initial_gas
	var/list/gas = params2list(gas_string)
	if(gas["TEMP"])
		initial_temperature = text2num(gas["TEMP"])
		temperature_archived = initial_temperature
		temperature = initial_temperature
		gas -= "TEMP"
	mix.Cut()
	for(var/id in gas)
		var/path = id
		if(!ispath(path))
			path = gas_id2path(path) //a lot of these strings can't have embedded expressions (especially for mappers), so support for IDs needs to stick around
		ADD_GAS(path, mix)
		mix[path][MOLES] = text2num(gas[id])
		mix[path][ARCHIVE] = mix[path][MOLES]

	for(var/id in mix)
		ADD_GAS(id, gases)
		gases[id][MOLES] = mix[id][MOLES]
		gases[id][ARCHIVE] = mix[id][MOLES]

