/datum/action/changeling/refractive_chitin
	name = "Refractive Chitin"
	desc = "We form a refractive chitin around our skin, causing light to pass around us."
	helptext = "Can be toggled on or off. Causes us to go invisible over time, moving or being attack while disrupt the refractive chitin making us more visible. Consumes 2 chemicals per second while active."
	button_icon_state = "chameleon_skin"
	dna_cost = 2
	chemical_cost = 1
	req_human = TRUE

/datum/action/changeling/refractive_chitin/sting_action(mob/living/user)
	var/mob/living/carbon/human/H = user //SHOULD always be human, because req_human = TRUE
	if(!istype(H)) // req_human could be done in can_sting stuff.
		return
	..()

	if(!user.has_status_effect(/datum/status_effect/changeling/camouflage))
		user.apply_status_effect(/datum/status_effect/changeling/camouflage)
	else
		user.remove_status_effect(/datum/status_effect/changeling/camouflage)
	return TRUE

/datum/action/changeling/refractive_chitin/Remove(mob/living/user)
	user.remove_status_effect(/datum/status_effect/changeling/camouflage)
	..()
