/obj/effect/anomaly/insanity_pulse
	name = "sanity disruption pulse anomaly"
	icon_state = "insanity"

	COOLDOWN_DECLARE(pulse_cooldown)
	anomaly_core = /obj/item/assembly/signaler/anomaly/insanity
	var/pulse_interval = 7 SECONDS

	var/weak_pulse_power = 8
	var/strong_pulse_power = 150

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

/// Sends the insanity pulses from center upto the impact size.
/// * atom/center: where the pulse starts from.
/// * impact_size: radius of the pulse.
/// * starting_value: usually 0. Old artifact code uses 1 because mobs on center takes strong effects than this
/// Original code comes from '/datum/artifact_effect/insanity_pulse'
/proc/sends_insanity_pulse(atom/center, impact_size = 10, starting_value = 0)
	if(impact_size >= 50)
		SEND_SOUND(world, 'sound/magic/repulse.ogg')
		log_game("massive insanity pulse was generated - stuns and blinds crews.")
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(_sends_insanity_pulse), center, impact_size, starting_value)

/// This proc takes a lot of time (usually 10s at 100 impact size) to complete. Only call this through `sends_insanity_pulse`
/proc/_sends_insanity_pulse(turf/center, impact_size, starting_value)
	for(var/pulse_radius in starting_value to impact_size)
		var/list/edge_turfs = get_edge_turfs(center, pulse_radius)
		if(!length(edge_turfs)) // it looks everything reached the end of world map. No need to run more.
			break
		var/datum/enumerator/turf_enumerator = get_dereferencing_enumerator(edge_turfs)
		SSenumeration.tickcheck(turf_enumerator.foreach(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_insanity_pulse_on_turf))))
		sleep(1)

/proc/_insanity_pulse_on_turf(turf/target_turf)
	if((!isspaceturf(target_turf) && isopenturf(target_turf)) || isopenspace(target_turf)) // you don't see what's comming...
		new /obj/effect/temp_visual/mining_scanner(target_turf) // actually, making effects for every turf is laggy. This is good to reduce lags.
	for(var/mob/living/each_mob in target_turf.get_all_mobs()) // hiding in a closet? No, no, you cheater
		if(each_mob.anti_artifact_check())
			to_chat(each_mob, span_notice("A weird energy from you blocks the pulse."))
			each_mob.adjust_eye_blur(5 SECONDS)
			continue
		to_chat(each_mob, span_warning("A wave of dread washes over you..."))
		each_mob.adjust_blindness(1.5) // very mild blindness
		each_mob.Knockdown(10)
		each_mob.emote("scream")
		each_mob.set_jitter_if_lower(100 SECONDS)
		each_mob.adjust_hallucinations(40 SECONDS)
