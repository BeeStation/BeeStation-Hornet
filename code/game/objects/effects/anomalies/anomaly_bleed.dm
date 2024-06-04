/obj/effect/anomaly/blood
	name = "blood anomaly"
	icon_state = "blood_anomaly"
	density = TRUE
	aSignal = /obj/item/assembly/signaler/anomaly/blood

/obj/effect/anomaly/blood/anomalyEffect(delta_time)
	..()
	if (DT_PROB(20, delta_time))
		AddComponent(/datum/component/pellet_cloud, projectile_type=/obj/projectile/bullet/shrapnel/bleed, magnitude=3)
		playsound(src, 'sound/weapons/shrapnel.ogg', 70, TRUE)

/obj/effect/anomaly/blood/detonate()
	STOP_PROCESSING(SSobj, src)
	// Needs to sleep since this gets instantly deleted as soon as the proc ends
	for (var/mob/living/carbon/human/player in GLOB.player_list)
		if (!is_station_level(player.z))
			continue
		forceMove(pick(RANGE_TURFS(4, get_turf(player))))
		sleep(40)
		if (QDELETED(src))
			return
		AddComponent(/datum/component/pellet_cloud, projectile_type=/obj/projectile/bullet/shrapnel/bleed, magnitude=3)
		playsound(src, 'sound/weapons/shrapnel.ogg', 70, TRUE)
		sleep(20)
		if (QDELETED(src))
			return

/obj/projectile/bullet/shrapnel/bleed
	damage = 4
	bleed_force = BLEED_DEEP_WOUND
