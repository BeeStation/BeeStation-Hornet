#define ADD_BARRIER_IMAGE(pos, direction) barrier_images += image('icons/effects/effects.dmi', pos, "barrier", FLOAT_LAYER, direction)

/mob/living/simple_animal/hostile/holoparasite
	/// A lazy list of images that represent the range barrier shown to the holoparasite's client.
	var/list/barrier_images

/mob/living/simple_animal/hostile/holoparasite/Logout()
	. = ..()
	cut_barriers()

/mob/living/simple_animal/hostile/holoparasite/proc/cut_barriers()
	if(LAZYLEN(barrier_images))
		if(client)
			client.images -= barrier_images
		QDEL_LAZYLIST(barrier_images)

/mob/living/simple_animal/hostile/holoparasite/proc/setup_barriers()
	cut_barriers()

	if(!client || !isturf(loc) || !summoner.current || stats.range == 1)
		return

	var/list/view_size = getviewsize(world.view)
	var/turf/summoner_turf = get_turf(summoner.current)
	var/dist_from_summoner = get_dist(summoner_turf, get_turf(src))
	if((range - dist_from_summoner) > max(view_size[1], view_size[2]))
		return

	var/sx = summoner_turf.x
	var/sy = summoner_turf.y
	var/sz = summoner_turf.z

	LAZYINITLIST(barrier_images)
	for(var/direction in GLOB.cardinals)
		var/turf/start_pos
		var/turf/end_pos
		switch(direction)
			if(SOUTH)
				start_pos = locate(max(sx - range, 1), min(sy + range + 1, world.maxy), sz)
				end_pos = locate(min(sx + range, world.maxx), min(sy + range + 1, world.maxy), sz)
			if(NORTH)
				start_pos = locate(max(sx - range, 1), max(sy - range - 1, 1), sz)
				end_pos = locate(min(sx + range, world.maxx), max(sy - range - 1, 1), sz)
			if(EAST)
				start_pos = locate(max(sx - range - 1, 1), max(sy - range, 1), sz)
				end_pos = locate(max(sx - range - 1, 1), min(sy + range, world.maxy), sz)
			if(WEST)
				start_pos = locate(min(sx + range + 1, world.maxx), max(sy - range, 1), sz)
				end_pos = locate(min(sx + range + 1, world.maxx), min(sy + range, world.maxy), sz)
		for(var/turf/edge in get_line(start_pos, end_pos))
			ADD_BARRIER_IMAGE(edge, direction)

	ADD_BARRIER_IMAGE(locate(max(sx - range - 1, 1), sy + range + 1, sz), SOUTHEAST)
	ADD_BARRIER_IMAGE(locate(min(sx + range + 1, world.maxx), min(sy + range + 1, world.maxx), sz), SOUTHWEST)
	ADD_BARRIER_IMAGE(locate(min(sx + range + 1, world.maxx), max(sy - range - 1, 1), sz), NORTHWEST)
	ADD_BARRIER_IMAGE(locate(max(sx - range - 1, 1), max(sy - range - 1, 1), sz), NORTHEAST)

	for(var/image/barrier_part as() in barrier_images)
		barrier_part.plane = ABOVE_LIGHTING_PLANE
		client.images += barrier_part

#undef ADD_BARRIER_IMAGE
