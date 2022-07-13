/datum/orbital_object/hazard/black_hole
	name = "BLACK HOLE !!DANGER!!"
	mass = 200000
	radius = 400
	collision_ignored = FALSE
	collision_flags = COLLISION_SHUTTLES | COLLISION_Z_LINKED | COLLISION_METEOR

//Die
/datum/orbital_object/hazard/black_hole/effect(datum/shuttle_data/shuttle_data)
	//Randomly EMP the shuttle
	var/obj/docking_port/mobile/target_port = SSshuttle.getShuttle(shuttle_data.port_id)
	if(!target_port)
		return
	for(var/area/A in target_port.shuttle_areas)
		for(var/mob/living/L in A)
			L.client.color = COLOR_BLACK
			animate(L.client, color=COLOR_WHITE, time=30)
			new /obj/anomaly/singularity(get_turf(L))
	target_port.intoTheSunset()

/datum/orbital_object/hazard/black_hole/collision(datum/orbital_object/other)
	. = ..()
	other.explode()
