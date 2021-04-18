/datum/action/changeling/gaseous_pores
	name = "Gaseous Pores"
	desc = "Our skins bursts, releasing somniferous gases to put opponents to sleep and cover our retreat."
	helptext = "We are still affected by the gases we emit, internals are recommended. Functions while unconscious."
	button_icon_state = "smoke"
	chemical_cost = 35
	dna_cost = 2
	req_stat = UNCONSCIOUS
	var/range = 4

/datum/action/changeling/gaseous_pores/sting_action(mob/user)
	..()
	var/turf/T = get_turf(user)
	if(!T)
		return FALSE
	var/datum/effect_system/smoke_spread/sleeping/smoke = new(T)
	smoke.set_up(range, T)
	smoke.start()
	user.visible_message("<span class='warning'>With a guttural screech, [user]'s skin bursts into gas.</span>")
	playsound(user, 'sound/voice/lizard/lizard_scream_1.ogg', 30, 1)
	return TRUE
