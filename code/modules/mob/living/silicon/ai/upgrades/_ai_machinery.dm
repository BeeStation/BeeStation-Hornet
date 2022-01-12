#define TEMP_LIMIT 290.15 //17C, much hotter than a normal server room for leniency :)

/obj/machinery/ai/proc/valid_holder()
	if(stat & (BROKEN|NOPOWER|EMPED))
		return FALSE

	var/turf/T = get_turf(src)
	var/datum/gas_mixture/env = T.return_air()
	if(!env)
		return FALSE
	var/total_moles = env.total_moles()
	if(istype(T, /turf/open/space) || total_moles < 10)
		return FALSE

	if(env.return_temperature() > TEMP_LIMIT || !env.heat_capacity())
		return FALSE
	return TRUE
