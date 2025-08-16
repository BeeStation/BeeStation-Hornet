/obj/effect/anomaly/bluespace
	name = "bluespace anomaly"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bluespace"
	density = TRUE
	max_spawned_faked = 4
	anomaly_core = /obj/item/assembly/signaler/anomaly/bluespace

/obj/effect/anomaly/bluespace/anomalyEffect()
	..()
	for(var/mob/living/M in hearers(1,src))
		do_teleport(M, locate(M.x, M.y, M.z), 4, channel = TELEPORT_CHANNEL_BLUESPACE)

/obj/effect/anomaly/bluespace/Bumped(atom/movable/AM)
	if(isliving(AM))
		do_teleport(AM, locate(AM.x, AM.y, AM.z), 8, channel = TELEPORT_CHANNEL_BLUESPACE)

/obj/effect/anomaly/bluespace/detonate()
	var/turf/T = safepick(get_area_turfs(impact_area))
	if(!T)
		return
	// Calculate new position (searches through beacons in world)
	var/obj/item/beacon/chosen
	var/list/possible = list()
	for(var/obj/item/beacon/W in GLOB.teleportbeacons)
		possible += W

	if(possible.len > 0)
		chosen = pick(possible)

	if(!chosen)
		return

	// Calculate previous position for transition
	var/turf/FROM = T // the turf of origin we're travelling FROM
	var/turf/TO = get_turf(chosen) // the turf of origin we're travelling TO

	playsound(TO, 'sound/effects/phasein.ogg', 100, 1)
	priority_announce("Massive bluespace translocation detected.", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())

	var/list/flashers = list()
	for(var/mob/living/carbon/C in viewers(TO))
		if(C.flash_act())
			flashers += C

	var/y_distance = TO.y - FROM.y
	var/x_distance = TO.x - FROM.x
	for (var/atom/movable/A in urange(12, FROM )) // iterate thru list of mobs in the area
		if(istype(A, /obj/item/beacon))
			continue // don't teleport beacons because that's just insanely stupid
		if(iscameramob(A))
			continue
		if(A.anchored)
			continue

		var/turf/newloc = locate(A.x + x_distance, A.y + y_distance, TO.z) // calculate the new place
		if(!A.Move(newloc) && newloc) // if the atom, for some reason, can't move, FORCE them to move! :) We try Move() first to invoke any movement-related checks the atom needs to perform after moving
			A.forceMove(newloc)

		spawn()
			if(ismob(A) && !(A in flashers)) // don't flash if we're already doing an effect
				var/mob/M = A
				if(M.client)
					var/obj/blueeffect = new /obj(src)
					blueeffect.screen_loc = "WEST,SOUTH to EAST,NORTH"
					blueeffect.icon = 'icons/effects/effects.dmi'
					blueeffect.icon_state = "shieldsparkles"
					blueeffect.layer = FLASH_LAYER
					blueeffect.plane = FULLSCREEN_PLANE
					blueeffect.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
					M.client.screen += blueeffect
					sleep(20)
					M.client.screen -= blueeffect
					qdel(blueeffect)
	var/turf/F = get_turf(src)
	F.generate_fake_pierced_realities(FALSE, max_spawned_faked)
