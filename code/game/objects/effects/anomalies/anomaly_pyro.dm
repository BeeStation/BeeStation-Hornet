/obj/effect/anomaly/pyro
	name = "pyroclastic anomaly"
	icon_state = "pyroclastic"
	anomaly_core = /obj/item/assembly/signaler/anomaly/pyro

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
	var/turf/open/tile = get_turf(src)
	if(istype(tile))
		tile.atmos_spawn_air("o2=500;plasma=500;TEMP=1000") //Make it hot and burny for the new slime
		log_game("A pyroclastic anomaly has detonated at [loc].")
		message_admins("A pyroclastic anomaly has detonated at [ADMIN_VERBOSEJMP(loc)].")
	var/new_colour = pick(SLIME_TYPE_ORANGE, SLIME_TYPE_RED)
	var/mob/living/simple_animal/slime/pyro = new(tile, new_colour)
	pyro.rabid = TRUE
	pyro.amount_grown = SLIME_EVOLUTION_THRESHOLD
	pyro.Evolve()
	pyro.flavor_text = FLAVOR_TEXT_EVIL
	pyro.transformeffects = SLIME_EFFECT_LIGHT_PINK
	pyro.set_playable_slime(ROLE_PYROCLASTIC_SLIME)
	pyro.mind.special_role = ROLE_PYROCLASTIC_SLIME
	pyro.mind.add_antag_datum(/datum/antagonist/pyro_slime)
	pyro.log_message("was made into a slime by pyroclastic anomaly", LOG_GAME)
