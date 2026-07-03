/obj/effect/anomaly/vortex
	name = "vortex anomaly"
	icon_state = "vortex"
	desc = "That's a nice station you have there. It'd be a shame if something happened to it."
	anomaly_core = /obj/item/assembly/signaler/anomaly/vortex

/obj/effect/anomaly/vortex/anomaly_process()
	. = ..()
	if(!isturf(loc)) //blackhole cannot be contained inside anything. Weird stuff might happen
		detonate()
		qdel(src)
		return

	grav(rand(0,3), rand(2,3), 50, 25)

	//Throwing stuff around!
	var/list/mob/living/nearby_people
	for(var/obj/nearby_obj in orange(2,src))
		if(nearby_obj.anchored)
			SSexplosions.med_mov_atom += nearby_obj
			continue

		nearby_people ||= hearers(4, src)
		var/mob/living/target = locate() in nearby_people
		if(target?.stat == CONSCIOUS)
			nearby_obj.throw_at(target, 7, 5)

/obj/effect/anomaly/vortex/detonate()
	generate_fake_pierced_realities(center_turf = get_turf(src), max_amount = max_spawned_faked)

/obj/effect/anomaly/vortex/proc/grav(r, ex_act_force, pull_chance, turf_removal_chance)
	for(var/t = -r, t < r, t++)
		affect_coord(x+t, y-r, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x-t, y+r, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x+r, y+t, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x-r, y-t, ex_act_force, pull_chance, turf_removal_chance)

/obj/effect/anomaly/vortex/proc/affect_coord(x, y, ex_act_force, pull_chance, turf_removal_chance)
	//Get turf at coordinate
	var/turf/T = locate(x, y, z)
	if(isnull(T))
		return

	//Pulling and/or ex_act-ing movable atoms in that turf
	if(prob(pull_chance))
		for(var/obj/O in T.contents)
			if(O.anchored)
				switch(ex_act_force)
					if(EXPLODE_DEVASTATE)
						SSexplosions.high_mov_atom += O
					if(EXPLODE_HEAVY)
						SSexplosions.med_mov_atom += O
					if(EXPLODE_LIGHT)
						SSexplosions.low_mov_atom += O
			else
				step_towards(O,src)
		for(var/mob/living/M in T.contents)
			step_towards(M,src)

	//Damaging the turf
	if(prob(turf_removal_chance))
		switch(ex_act_force)
			if(EXPLODE_DEVASTATE)
				SSexplosions.highturf += T
			if(EXPLODE_HEAVY)
				SSexplosions.medturf += T
			if(EXPLODE_LIGHT)
				SSexplosions.lowturf += T
