/datum/action/changeling/gaseous_pores
	name = "Gaseous Pores"
	desc = "Our skins bursts, releasing gases which bring confusion to our pursuers, covering our escape."
	helptext = "Our kind are immune to the gases internals are not necessary"
	button_icon_state = "smoke"
	chemical_cost = 25
	dna_cost = 1
	req_stat = UNCONSCIOUS
	var/range = 4

/obj/effect/particle_effect/smoke/confusing/changeling
	color = "#9C3636"
	lifetime = 10

/obj/effect/particle_effect/smoke/confusing/changeling/smoke_mob(mob/living/carbon/M,datum/antagonist)
	if(is_changeling(M))
		return FALSE
	if(..())
		M.confused = max(M.confused, 12)
		INVOKE_ASYNC(M, TYPE_PROC_REF(/mob, emote), "cough")
		return TRUE

/datum/effect_system/smoke_spread/confusing/changeling
	effect_type = /obj/effect/particle_effect/smoke/confusing/changeling

/datum/action/changeling/gaseous_pores/sting_action(mob/user)
	..()
	user.visible_message("<span class='warning'>[user]'s skin begins to bubble!</span>")
	playsound(user, 'sound/machines/fryer/deep_fryer_1.ogg', 30, 1)
	sleep(10)
	var/turf/T = get_turf(user)
	if(!T)
		return FALSE
	var/datum/effect_system/smoke_spread/confusing/changeling/smoke = new(T)
	smoke.set_up(range, T)
	smoke.start()
	user.visible_message("<span class='warning'>With a guttural screech, [user]'s skin bursts into gas!</span>")
	playsound(user, 'sound/voice/lizard/lizard_scream_1.ogg', 30, 1)
	return TRUE
