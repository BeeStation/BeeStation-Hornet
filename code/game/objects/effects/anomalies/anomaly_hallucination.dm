/obj/effect/anomaly/hallucination
	name = "hallucination anomaly"
	icon_state = "hallucination_anomaly"
	aSignal = /obj/item/assembly/signaler/anomaly/hallucination

	COOLDOWN_DECLARE(pulse_cooldown)
	var/pulse_interval = 5 SECONDS

/obj/effect/anomaly/hallucination/anomalyEffect(delta_time)
	. = ..()

	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_interval)

	var/turf/open/our_turf = get_turf(src)
	if(!isturf(our_turf))
		return
	hallucination_pulse(our_turf, 5)

/obj/effect/anomaly/hallucination/detonate()
	var/turf/open/our_turf = get_turf(src)
	if(!isturf(our_turf))
		return
	hallucination_pulse(our_turf, 10)
	our_turf.generate_fake_pierced_realities(max_spawned_faked)

/proc/hallucination_pulse(turf/location, range, strength = 50)
	for(var/mob/living/carbon/human/near in view(location, range))
		// If they are immune to hallucinations
		if (HAS_TRAIT(near, TRAIT_MADNESS_IMMUNE) || (near.mind && HAS_TRAIT(near.mind, TRAIT_MADNESS_IMMUNE)))
			continue

		// Blind people don't get hallucinations
		if (near.is_blind())
			continue

		// Everyone else
		var/dist = sqrt(1 / max(1, get_dist(near, location)))
		near.hallucination = ADDCLAMP(near.hallucination, strength * dist, 0, 150)
		var/list/messages = list(
			"You feel your conscious mind fall apart!",
			"Reality warps around you!",
			"Something's wispering around you!",
			"You are going insane!",
			"What was that?!"
		)
		to_chat(near, "<span class='warning'>[pick(messages)]</span>")
