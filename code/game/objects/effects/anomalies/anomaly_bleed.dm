/obj/effect/anomaly/blood
	name = "blood anomaly"
	icon_state = "blood"
	density = TRUE
	anomaly_core = /obj/item/assembly/signaler/anomaly/blood
	var/sucking = FALSE

/obj/effect/anomaly/blood/anomalyEffect(delta_time)
	if (sucking)
		return
	..()
	if (DT_PROB(20, delta_time))
		AddComponent(/datum/component/pellet_cloud, projectile_type=/obj/projectile/bullet/shrapnel/bleed, magnitude=3)
		playsound(src, 'sound/weapons/shrapnel.ogg', 70, TRUE)
	if (DT_PROB(10, delta_time))
		for (var/mob/living/carbon/bleed_target in view(6, src))
			if (!bleed_target.resting)
				continue
			if (do_teleport(src, get_turf(bleed_target), channel = TELEPORT_CHANNEL_BLUESPACE))
				bleed_target.Stun(3 SECONDS)
				INVOKE_ASYNC(src, PROC_REF(suck_blood))
			break

/obj/effect/anomaly/blood/detonate()
	// Stop processing here since we don't want to keep moving while doing the detonation action
	STOP_PROCESSING(SSobj, src)
	// Needs to sleep since this gets instantly deleted as soon as the proc ends
	for (var/mob/living/carbon/human/player in shuffle(GLOB.player_list))
		if (!is_station_level(player.z))
			continue
		var/turf/player_loc = get_turf(player)
		var/list/nearby_turfs = RANGE_TURFS(4, player_loc)
		shuffle_inplace(nearby_turfs)
		var/turf/target = locate(/turf/open) in nearby_turfs
		if (!target)
			continue
		// Blocked by the bluespace anchor
		if (!do_teleport(src, target, channel = TELEPORT_CHANNEL_BLUESPACE))
			return
		sleep(40)
		if (QDELETED(src))
			return
		AddComponent(/datum/component/pellet_cloud, projectile_type=/obj/projectile/bullet/shrapnel/bleed, magnitude=3)
		playsound(src, 'sound/weapons/shrapnel.ogg', 70, TRUE)
		sleep(20)
		if (QDELETED(src))
			return

/obj/effect/anomaly/blood/proc/suck_blood()
	sucking = FALSE
	for (var/mob/living/carbon/bleed_target in loc)
		bleed_target.add_bleeding(BLEED_SURFACE)
		bleed_target.emote("scream")
		sucking = TRUE
	if (sucking)
		new /obj/effect/temp_visual/cult/sparks(loc)
		addtimer(CALLBACK(src, PROC_REF(suck_blood)), 0.5 SECONDS)

/obj/projectile/bullet/shrapnel/bleed
	damage = 4
	bleed_force = BLEED_DEEP_WOUND
