/datum/orbital_object/hazard/vortex
	name = "Gravitational Vortex"
	//This one can move
	static_object = FALSE
	mass = 50000

/datum/orbital_object/hazard/vortex/post_map_setup()
	. = ..()
	//Oh god its moving
	velocity.AddSelf(new /datum/orbital_vector(rand(-200, 200), rand(-200, 200)))
	//Scale down
	radius *= 0.35

/datum/orbital_object/hazard/vortex/effect(datum/shuttle_data/shuttle_data)
	if(prob(95))
		return
	//Tear ships apart
	var/obj/docking_port/mobile/target_port = SSshuttle.getShuttle(shuttle_data.port_id)
	if(!target_port)
		return
	var/turf/target = pick(target_port.return_turfs())
	for(var/area/area in target_port.shuttle_areas)
		for(var/mob/living/L in area)
			to_chat(L, "<span class='userdanger'>You are violently thrown against the floor!</span>")
			L.Knockdown(20)
			L.throw_at(pick(view(2, L)), 2, 14)
		for(var/obj/item/thing in area)
			if(prob(70) || thing.anchored)
				continue
			thing.throw_at(target, 2, 12)
	if(prob(35))
		explosion(target, 0, 0, 2, adminlog = FALSE)
