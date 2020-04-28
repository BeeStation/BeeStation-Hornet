/datum/action/changeling/fleshmend
	name = "Fleshmend"
	desc = "We will passively heal our wounds. This is far more effective on bruises than on burns."
	helptext = "If we are on fire, the healing effect will not function. Does not regrow limbs or restore lost blood. Functions while unconscious. Continued use slows chemical production"
	button_icon_state = "fleshmend"
	chemical_cost = 0
	dna_cost = 2
	req_stat = UNCONSCIOUS

/datum/action/changeling/fleshmend/sting_action(mob/living/user)
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(user.has_status_effect(STATUS_EFFECT_FLESHMEND))
		to_chat(user, "<span class='warning'>We stop fleshmending!</span>")
		user.remove_status_effect(STATUS_EFFECT_FLESHMEND)
		changeling.chem_recharge_slowdown -= 0.5
		return
	..()
	to_chat(user, "<span class='notice'>We begin to heal passively.</span>")
	user.apply_status_effect(STATUS_EFFECT_FLESHMEND)
	changeling.chem_recharge_slowdown += 0.5
	return TRUE

//Check buffs.dm for the fleshmend status effect code

/datum/action/changeling/fleshmend/Remove(mob/user)
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(isliving(user))
		var/mob/living/L = user
		if(L.has_status_effect(STATUS_EFFECT_FLESHMEND))
			to_chat(L, "<span class='warning'>We stop fleshmending!</span>")
			L.remove_status_effect(STATUS_EFFECT_FLESHMEND)
			changeling.chem_recharge_slowdown -= 0.5
			return
	..()
