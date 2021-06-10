/datum/action/changeling/gaseous_pores
	name = "Gaseous Pores"
	desc = "Our skins bursts, releasing somniferous gases to put opponents to sleep and cover our retreat."
	helptext = "Our kind are immune to the gases internals are not necessary"
	button_icon_state = "smoke"
	chemical_cost = 35
	dna_cost = 2
	req_stat = UNCONSCIOUS
	var/range = 4

/obj/effect/particle_effect/smoke/sleeping/changeling
	color = "#9C3636"
	lifetime = 10

/obj/effect/particle_effect/smoke/sleeping/changeling/smoke_mob(mob/living/carbon/M,datum/antagonist)
	if(is_changeling(M))
		return FALSE
	if(..())
		M.Sleeping(200)
		INVOKE_ASYNC(M, /mob.proc/emote, "cough")
		return TRUE

/datum/effect_system/smoke_spread/sleeping/changeling
	effect_type = /obj/effect/particle_effect/smoke/sleeping/changeling

/datum/action/changeling/gaseous_pores/sting_action(mob/user)
	..()
	user.visible_message("<span class='warning'>[user]'s skin begins to bubble!</span>")
	playsound(user, 'sound/machines/fryer/deep_fryer_1.ogg', 30, 1)
	sleep(10)
	var/turf/T = get_turf(user)
	if(!T)
		return FALSE
	var/datum/effect_system/smoke_spread/sleeping/changeling/smoke = new(T)
	smoke.set_up(range, T)
	smoke.start()
	user.visible_message("<span class='warning'>With a guttural screech, [user]'s skin bursts into gas!</span>")
	playsound(user, 'sound/voice/lizard/lizard_scream_1.ogg', 30, 1)
	return TRUE
