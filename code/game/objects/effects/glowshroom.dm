//separate dm since hydro is getting bloated already

/obj/structure/glowshroom
	name = "glowshroom"
	desc = "Mycena Bregprox, a species of mushroom that glows in the dark."
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	icon = 'icons/obj/lighting.dmi'
	icon_state = "glowshroom" //replaced in New
	layer = ABOVE_NORMAL_TURF_LAYER
	max_integrity = 30
	var/delay = 12 SECONDS
	var/floor = 0
	var/generation = 1
	var/spreadIntoAdjacentChance = 60
	var/obj/item/plant_seeds/myseed = /obj/item/plant_seeds/preset/glowshroom
	var/static/list/blacklisted_glowshroom_turfs = typecacheof(list(
		/turf/open/lava,
		/turf/open/floor/plating/beach/water,
	))

/obj/structure/glowshroom/glowcap
	name = "glowcap"
	desc = "Mycena Ruthenia, a species of mushroom that, while it does glow in the dark, is not actually bioluminescent."
	icon_state = "glowcap"
	myseed = /obj/item/plant_seeds/preset/glowcap

/obj/structure/glowshroom/shadowshroom
	name = "shadowshroom"
	desc = "Mycena Umbra, a species of mushroom that emits shadow instead of light."
	icon_state = "shadowshroom"
	myseed = /obj/item/plant_seeds/preset/shadowshroom

/obj/structure/glowshroom/single/Spread()
	return

/obj/structure/glowshroom/examine(mob/user)
	. = ..()
	. += "This is a [generation]\th generation [name]!"

/obj/structure/glowshroom/Destroy()
	if(myseed)
		QDEL_NULL(myseed)
	return ..()

/obj/structure/glowshroom/Initialize(mapload, obj/item/plant_seeds/newseed)
	. = ..()
	if(newseed)
		myseed = newseed.copy()
		myseed.forceMove(src)
	else
		myseed = new myseed(src)
//Stats
	var/datum/plant_feature/body/body_feature = locate(/datum/plant_feature/body) in myseed.plant_features
	if(body_feature)
		delay = max(delay - body_feature.yield_cooldown_time, 1 SECONDS) //So the delay goes DOWN with better stats instead of up. :I
		atom_integrity += round((body_feature.max_harvest / PLANT_BODY_HARVEST_LARGE) * 100)
		max_integrity += round((body_feature.max_harvest / PLANT_BODY_HARVEST_LARGE) * 100)
//Glow
	var/datum/plant_feature/fruit/fruit_feature = locate(/datum/plant_feature/fruit) in myseed.plant_features
	var/datum/plant_trait/fruit/biolight/light = locate(/datum/plant_trait/fruit/biolight) in fruit_feature?.plant_traits
	set_light(light?.glow_range, light?.glow_power, light?.glow_color)
//Smoothing
	setDir(CalcDir())
	var/base_icon_state = initial(icon_state)
	if(!floor)
		switch(dir) //offset to make it be on the wall rather than on the floor
			if(NORTH)
				pixel_y = 32
			if(SOUTH)
				pixel_y = -32
			if(EAST)
				pixel_x = 32
			if(WEST)
				pixel_x = -32
		icon_state = "[base_icon_state][rand(1,3)]"
	else //if on the floor, glowshroom on-floor sprite
		icon_state = base_icon_state

	addtimer(CALLBACK(src, PROC_REF(Spread)), delay)
	AddElement(/datum/element/atmos_sensitive)

/obj/structure/glowshroom/proc/Spread()
//Flight checks
	var/datum/plant_feature/body/body_feature = locate(/datum/plant_feature/body) in myseed.plant_features
	if(!body_feature)
		return
	var/turf/ownturf = get_turf(src)
	if(!TURF_SHARES(ownturf)) //If we are in a 1x1 room
		return //Deal with it not now
//Spread
	var/shrooms_planted = 0
	for(var/i in 1 to body_feature.max_harvest)
		if(prob(1/(generation * generation) * 100))//This formula gives you diminishing returns based on generation. 100% with 1st gen, decreasing to 25%, 11%, 6, 4, 2...
			var/list/possibleLocs = list()

			for(var/turf/open/floor/earth in view(3,src))
				if(is_type_in_typecache(earth, blacklisted_glowshroom_turfs))
					continue
				if(!TURF_SHARES(earth))
					continue
				possibleLocs += earth
				CHECK_TICK

			if(!possibleLocs.len)
				break

			if(!prob(spreadIntoAdjacentChance))
				return

			var/turf/newLoc = pick(possibleLocs)

			var/shroomCount = 0 //hacky
			var/placeCount = 1
			for(var/obj/structure/glowshroom/shroom in newLoc)
				shroomCount++
			for(var/wallDir in GLOB.cardinals)
				var/turf/isWall = get_step(newLoc,wallDir)
				if(isWall.density)
					placeCount++
			if(shroomCount >= placeCount)
				continue

			var/obj/structure/glowshroom/child = new type(newLoc, myseed, TRUE)
			child.generation = generation + 1
			shrooms_planted++

			CHECK_TICK
		else
			shrooms_planted++ //if we failed due to generation, don't try to plant one later
	if(shrooms_planted < body_feature.max_harvest) //if we didn't get all possible shrooms planted, try again later
		body_feature.max_harvest -= shrooms_planted
		addtimer(CALLBACK(src, PROC_REF(Spread)), delay)

/obj/structure/glowshroom/proc/CalcDir(turf/location = loc)
	var/direction = 16

	for(var/wallDir in GLOB.cardinals)
		var/turf/newTurf = get_step(location,wallDir)
		if(newTurf.density)
			direction |= wallDir

	for(var/obj/structure/glowshroom/shroom in location)
		if(shroom == src)
			continue
		if(shroom.floor) //special
			direction &= ~16
		else
			direction &= ~shroom.dir

	var/list/dirList = list()

	for(var/i=1,i<=16,i <<= 1)
		if(direction & i)
			dirList += i

	if(dirList.len)
		var/newDir = pick(dirList)
		if(newDir == 16)
			floor = 1
			newDir = 1
		return newDir

	floor = 1
	return 1

/obj/structure/glowshroom/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type == BURN && damage_amount)
		playsound(src, 'sound/items/welder.ogg', 100, 1)

/obj/structure/glowshroom/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > 300

/obj/structure/glowshroom/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(5, BURN, 0, 0)

/obj/structure/glowshroom/acid_act(acidpwr, acid_volume)
	. = 1
	visible_message(span_danger("[src] melts away!"))
	var/obj/effect/decal/cleanable/molten_object/I = new (get_turf(src))
	I.desc = "Looks like this was \an [src] some time ago."
	qdel(src)
