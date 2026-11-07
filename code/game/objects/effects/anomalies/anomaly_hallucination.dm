/obj/effect/anomaly/hallucination
	name = "hallucination anomaly"
	icon_state = "hallucination"
	anomaly_core = /obj/item/assembly/signaler/anomaly/hallucination

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

/obj/effect/anomaly/hallucination/anomaly_process(delta_time)
	. = ..()
	var/turf/our_turf = get_turf(src)
	if(!COOLDOWN_FINISHED(src, pulse_cooldown) || !istype(our_turf))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_interval)

	visible_hallucination_pulse(
		center = our_turf,
		radius = 5,
		hallucination_duration = 50 SECONDS,
		hallucination_max_duration = 5 MINUTES,
		optional_messages = messages,
	)

/obj/effect/anomaly/hallucination/detonate()
	var/turf/open/our_turf = get_turf(src)

	hallucination_pulse(
		center = our_turf,
		radius = 15,
		hallucination_duration = 50 SECONDS,
		hallucination_max_duration = 5 MINUTES,
		optional_messages = messages,
	)
	generate_fake_pierced_realities(center_turf = our_turf, max_amount = max_spawned_faked)
