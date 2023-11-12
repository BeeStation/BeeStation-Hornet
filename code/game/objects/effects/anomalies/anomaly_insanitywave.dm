/obj/effect/anomaly/insanity_pulse
	name = "sanity disruption pulse anomaly"
	icon_state = "purplecrack"
	aSignal = null // we don't have this yet

	COOLDOWN_DECLARE(pulse_cooldown)
	var/pulse_interval = 10 SECONDS

	var/weak_pulse_power = 8
	var/strong_pulse_power = 100

/obj/effect/anomaly/insanity_pulse/anomalyEffect(delta_time)
	. = ..()

	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_interval)

	var/turf/open/our_turf = get_turf(src)
	if(!isturf(our_turf))
		return
	sends_insanity_pulse(our_turf, weak_pulse_power)

/obj/effect/anomaly/insanity_pulse/detonate()
	var/turf/open/our_turf = get_turf(src)
	if(!isturf(our_turf))
		return
	sends_insanity_pulse(our_turf, strong_pulse_power)
	our_turf.generate_fake_pierced_realities(max_spawned_faked)

/// Original code comes from '/datum/artifact_effect/insanity_pulse'
/proc/sends_insanity_pulse(turf/center, impact_size = 10)
	if(impact_size >= 50)
		SEND_SOUND(world, 'sound/magic/repulse.ogg')
		log_game("massive insanity pulse was generated - stuns and blinds crews.")
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(_sends_insanity_pulse), center, impact_size)

/// This proc takes a lot of time (usually 10s at 100 impact size) to complete. Only call this through `sends_insanity_pulse`
/proc/_sends_insanity_pulse(list/center, impact_size)
	for(var/each_group in get_pulsing_turfs(center, impact_size))
		for(var/turf/each_turf as() in each_group)
			if(!isspaceturf(each_turf)) // you don't see what's comming...
				new /obj/effect/temp_visual/mining_scanner(each_turf)
			for(var/mob/living/each_mob in each_turf.get_all_mobs()) // hiding in a closet? No, no, you cheater
				to_chat(each_mob, "<span class='warning'>A wave of dread washes over you...</span>")
				each_mob.adjust_blindness(30)
				each_mob.Knockdown(10)
				each_mob.emote("scream")
				each_mob.Jitter(50)
				each_mob.hallucination = each_mob.hallucination + 20
			CHECK_TICK
		sleep(1)

