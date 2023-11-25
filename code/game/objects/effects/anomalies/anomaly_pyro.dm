/obj/effect/anomaly/pyro
	name = "pyroclastic anomaly"
	icon_state = "mustard"
	aSignal = /obj/item/assembly/signaler/anomaly/pyro

	COOLDOWN_DECLARE(pulse_cooldown)
	var/pulse_interval = 10 SECONDS

/obj/effect/anomaly/pyro/anomalyEffect(delta_time)
	. = ..()

	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_interval)

	var/turf/open/our_turf = get_turf(src)
	if(!isturf(our_turf))
		return
	our_turf.atmos_spawn_air("o2=5;plasma=5;TEMP=1000")

/obj/effect/anomaly/pyro/detonate()
	INVOKE_ASYNC(src, PROC_REF(makepyroslime))

/obj/effect/anomaly/pyro/proc/makepyroslime()
	var/turf/open/T = get_turf(src)
	if(istype(T))
		T.atmos_spawn_air("o2=500;plasma=500;TEMP=1000") //Make it hot and burny for the new slime
		log_game("A pyroclastic anomaly has detonated at [loc].")
		message_admins("A pyroclastic anomaly has detonated at [ADMIN_VERBOSEJMP(loc)].")
	var/new_colour = pick("red", "orange")
	var/mob/living/simple_animal/slime/S = new(T, new_colour)
	S.rabid = TRUE
	S.amount_grown = SLIME_EVOLUTION_THRESHOLD
	S.Evolve()
	S.flavor_text = FLAVOR_TEXT_EVIL
	S.set_playable(ROLE_PYRO_SLIME)
