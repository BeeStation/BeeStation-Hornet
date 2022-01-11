/datum/action/changeling/chameleon_skin
	name = "Chameleon Skin"
	desc = "Our skin pigmentation rapidly changes to suit our current environment. Costs 25 chemicals."
	helptext = "Allows us to become invisible after a few seconds of standing still. Can be toggled on and off. This ability is passive and doesnt cost any chemicals"
	button_icon_state = "chameleon_skin"
	dna_cost = 1
	chemical_cost = 0

/datum/action/changeling/chameleon_skin/sting_action(mob/user)
	var/mob/living/carbon/H = user
	if(!H.has_dna())
		return
	..()
	if(H.dna.get_mutation(CHAMELEON))
		H.dna.remove_mutation(CHAMELEON)
	else
		H.dna.add_mutation(CHAMELEON)
	return TRUE

/datum/action/changeling/chameleon_skin/Remove(mob/user)
	if(user.has_dna())
		var/mob/living/carbon/C = user
		C.dna.remove_mutation(CHAMELEON)
	..()
