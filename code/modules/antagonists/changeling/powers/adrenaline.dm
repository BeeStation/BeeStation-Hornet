/datum/action/changeling/adrenaline
	name = "Adrenaline Sacs"
	desc = "We evolve additional sacs of adrenaline throughout our body. Costs 20 chemicals."
	helptext = "Removes all stuns instantly and adds a short-term reduction in further stuns. Can be used while unconscious."
	button_icon_state = "adrenaline"
	chemical_cost = 20
	dna_cost = 2
	req_human = 1
	check_flags = AB_CHECK_DEAD

//Recover from stuns.
/datum/action/changeling/adrenaline/sting_action(mob/living/user)
	..()
	to_chat(user, span_notice("Energy rushes through us.[(user.body_position == LYING_DOWN) ? " We arise." : ""]"))
	user.SetSleeping(0)
	user.SetUnconscious(0)
	user.SetStun(0)
	user.SetKnockdown(0)
	user.SetImmobilized(0)
	user.SetParalyzed(0)
	user.reagents.add_reagent(/datum/reagent/medicine/changelingadrenaline, 10)
	user.reagents.add_reagent(/datum/reagent/medicine/changelinghaste, 2) //For a really quick burst of speed
	user.stamina.adjust(200)
	return TRUE
