/obj/effect/anomaly/endo
	name = "endothermic anomaly"
	icon_state = "endothermic"
	anomaly_core = /obj/item/assembly/signaler/anomaly/endo

	COOLDOWN_DECLARE(pulse_cooldown)
	var/pulse_interval = 20 SECONDS

/obj/effect/anomaly/endo/anomalyEffect(delta_time)
	. = ..()

	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_interval)

	var/turf/open/our_turf = get_turf(src)
	if(!isturf(our_turf))
		return
	our_turf.atmos_spawn_air("pluoxium=5;hypernoblium=5;TEMP=-500")
	playsound(src, 'sound/magic/smoke.ogg', 50, 1)

/obj/effect/anomaly/endo/detonate()
	playsound(src, 'sound/effects/explosion1.ogg', 50, 1)
	INVOKE_ASYNC(src, PROC_REF(makeendothermiccreature))

/obj/effect/anomaly/endo/proc/makeendothermiccreature()
	var/turf/open/T = get_turf(src)
	if(istype(T))
		T.atmos_spawn_air("pluoxium=750;hypernoblium=500;TEMP=-750") //Make it hot and burny for the new slime
		log_game("An endothermic anomaly has detonated at [loc].")
		message_admins("An endothermic anomaly has detonated at [ADMIN_VERBOSEJMP(loc)].")
	for(var/i = 1 to 5)
		new /mob/living/simple_animal/hostile/warmless(T)
