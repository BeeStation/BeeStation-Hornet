/obj/effect/anomaly/hallucination
	name = "hallucination anomaly"
	icon_state = "hallucination"
	anomaly_core = /obj/item/assembly/signaler/anomaly/hallucination
	var/static/list/sounds = list(
			'sound/effects/laughtrack.ogg',
			'sound/effects/inhale.ogg',
			'sound/effects/hit_on_shattered_glass.ogg',
			'sound/effects/glassknock.ogg',
			'sound/effects/servostep.ogg',
			'sound/effects/light_flicker.ogg',
			'sound/effects/grillehit.ogg',
			'sound/effects/fuse.ogg',
			'sound/effects/explosioncreak1.ogg',
			'sound/effects/explosioncreak2.ogg',
			'sound/effects/explosion_distant.ogg',
			'sound/effects/doorcreaky.ogg',
			'sound/effects/one_mind.ogg',
		)

	COOLDOWN_DECLARE(pulse_cooldown)
	/// How many seconds between each small hallucination pulses
	var/pulse_interval = 5 SECONDS
	/// Messages sent to people feeling the pulses
	var/static/list/messages = list(
		span_warning("You feel your conscious mind fall apart!"),
		span_warning("Reality warps around you!"),
		span_warning("Something's wispering around you!"),
		span_warning("You are going insane!"),
	)

/obj/effect/anomaly/hallucination/anomalyEffect(delta_time)
	. = ..()

	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_interval)

	if(!isturf(loc))
		return

	var/sound_to_play = pick(sounds)
	playsound(src, sound_to_play, 50, 1)
	visible_hallucination_pulse(
		center = get_turf(src),
		radius = 5,
		hallucination_duration = 50 SECONDS,
		hallucination_max_duration = 300 SECONDS,
		optional_messages = messages,
	)

/obj/effect/anomaly/hallucination/detonate()
	var/turf/open/our_turf = get_turf(src)

	hallucination_pulse(
		center = our_turf,
		radius = 15,
		hallucination_duration = 50 SECONDS,
		hallucination_max_duration = 300 SECONDS,
		optional_messages = messages,
	)
	our_turf.generate_fake_pierced_realities(max_spawned_faked)
