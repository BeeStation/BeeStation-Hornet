/proc/forcecryo(mob/target)
	var/turf/T = get_turf(target)
	new /obj/effect/temp_visual/tornado(T)
	sleep(20)
	for(var/obj/machinery/cryopod/C in GLOB.machines)
		if(!C.occupant)
			C.close_machine(target)
			C.despawn_occupant()
			break
