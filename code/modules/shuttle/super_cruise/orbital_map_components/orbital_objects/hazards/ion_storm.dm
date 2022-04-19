/datum/orbital_object/hazard/ion_storm
	name = "Ion Storm"

/datum/orbital_object/hazard/ion_storm/effect(datum/shuttle_data/shuttle_data)
	//Reduce the chance of ion storm having an effect on the shuttle with this 1 simple trick!
	if(prob(80))
		return
	//Randomly EMP the shuttle
	var/obj/docking_port/mobile/target_port = SSshuttle.getShuttle(shuttle_data.port_id)
	if(!target_port)
		return
	var/turf/target = pick(target_port.return_turfs())
	empulse(target, 1, 2)
