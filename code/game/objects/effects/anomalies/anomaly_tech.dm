/obj/effect/anomaly/tech
	name = "tech anomaly"
	icon_state = "tech"
	anomaly_core = /obj/item/assembly/signaler/anomaly/tech

	COOLDOWN_DECLARE(pulse_cooldown)
	var/pulse_interval = 20 SECONDS


/obj/effect/anomaly/tech/anomalyEffect(delta_time)
	. = ..()

	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_interval)

	var/turf/open/our_turf = get_turf(src)
	if(!isturf(our_turf))
		return
	empulse(our_turf, 1, 3)

/obj/effect/anomaly/tech/detonate()
	playsound(src, 'sound/effects/empulse.ogg', 50, 1)
	var/machine_count = 0
	for(var/obj/machinery/M in range(loc, 3))
		machine_count++ // shit but it works
	if(machine_count > 0)
		log_game("A tech anomaly has detonated at [loc].")
		message_admins("A tech anomaly has detonated at [ADMIN_VERBOSEJMP(loc)].")
		var/emp_strength = (machine_count / 2)
		empulse(src, emp_strength - 2, emp_strength - 4, TRUE) //in spacemen terms, more machines more power. Keep toned down or experience a solar flare.
	else
		log_game("A tech anomaly detonated at [loc], but there were no machines nearby to increase EMP strength.")
		message_admins("A tech anomaly detonated at [ADMIN_VERBOSEJMP(loc)], but there were no machines nearby to increase EMP strength.")
		empulse(src, 3, 5)
