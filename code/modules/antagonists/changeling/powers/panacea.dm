/datum/action/changeling/panacea
	name = "Total Purge"
	desc = "Expels impurities in our form, causing us to heal toxin damage, expel all chemicals, curing most diseases, brain damage, and traumas and resetting our genetic code completely. Costs 20 chemicals."
	helptext = "Obvious when used, as it sprays all reagents out in a violent manner. Can be used while unconscious."
	button_icon_state = "panacea"
	chemical_cost = 20
	dna_cost = 1
	req_stat = UNCONSCIOUS

//Heals the things that the other regenerative abilities don't.
/datum/action/changeling/panacea/sting_action(mob/user)
	to_chat(user, "<span class='notice'>We cleanse impurities from our form.</span>")
	..()
	var/list/bad_organs = list(
		user.getorgan(/obj/item/organ/body_egg),
		user.getorgan(/obj/item/organ/zombie_infection))

	for(var/o in bad_organs)
		var/obj/item/organ/O = o
		if(!istype(O))
			continue

		O.Remove(user)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.vomit(0, toxic = TRUE)
		O.forceMove(get_turf(user))

	if(isoozeling(user))
		for(var/datum/reagent/R in user.reagents.reagent_list)
			var/thisamount = user.reagents.get_reagent_amount(R.type)
			user.reagents.remove_reagent(R.type, thisamount)
	else
		var/obj/effect/sweatsplash/S = new(user.loc)
		for(var/datum/reagent/R in user.reagents.reagent_list) //Not just toxins!
			var/amount = R.volume
			user.reagents.remove_reagent(R.type, amount)
			S.reagents.add_reagent(R.type, amount)
		S.splash()
	user.reagents.add_reagent(/datum/reagent/medicine/mutadone, 1)

	if(iscarbon(user))
		var/mob/living/carbon/L = user
		L.drunkenness = 0
		L.setToxLoss(0, 0)
		L.adjustOrganLoss(ORGAN_SLOT_BRAIN, -100)
		L.cure_all_traumas(TRAUMA_RESILIENCE_SURGERY)
		for(var/thing in L.diseases)
			var/datum/disease/D = thing
			if(D.danger == DISEASE_POSITIVE || D.danger == DISEASE_BENEFICIAL || D.spread_flags == DISEASE_SPREAD_SPECIAL)
				continue
			if(D in subtypesof(/datum/disease/advance))
				var/datum/disease/advance/A = D
				if(A.resistance >= 12)
					continue
			D.cure(FALSE)
	return TRUE
