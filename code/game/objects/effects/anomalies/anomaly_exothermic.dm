/obj/effect/anomaly/exo
	name = "exothermic anomaly"
	icon_state = "exothermic"
	anomaly_core = /obj/item/assembly/signaler/anomaly/exo

	COOLDOWN_DECLARE(pulse_cooldown)
	var/pulse_interval = 10 SECONDS

/obj/effect/anomaly/exo/anomalyEffect(delta_time)
	. = ..()

	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_interval)

	var/turf/open/our_turf = get_turf(src)
	if(!isturf(our_turf))
		return
	our_turf.atmos_spawn_air("o2=15;plasma=10;TEMP=1000")
	playsound(src, 'sound/magic/fireball.ogg', 50, 1)

/obj/effect/anomaly/exo/detonate()
	playsound(src, 'sound/effects/explosion1.ogg', 50, 1)
	INVOKE_ASYNC(src, PROC_REF(makeexoslime))

/obj/effect/anomaly/exo/proc/makeexoslime()
	var/turf/open/T = get_turf(src)
	if(istype(T))
		T.atmos_spawn_air("o2=850;plasma=550;TEMP=1500") //Make it hot and burny for the new slime
		log_game("An exothermic anomaly has detonated at [loc].")
		message_admins("An exothermic anomaly has detonated at [ADMIN_VERBOSEJMP(loc)].")
	var/new_colour = pick(SLIME_TYPE_ORANGE, SLIME_TYPE_RED)
	var/mob/living/simple_animal/slime/S = new(T, new_colour)
	S.rabid = TRUE
	S.amount_grown = SLIME_EVOLUTION_THRESHOLD
	S.Evolve()
	S.flavor_text = FLAVOR_TEXT_EVIL
	S.transformeffects = SLIME_EFFECT_LIGHT_PINK
	S.set_playable_slime(ROLE_EXO_SLIME)
