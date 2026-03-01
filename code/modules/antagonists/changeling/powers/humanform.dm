/datum/action/changeling/humanform
	name = "Human Form"
	desc = "We change into a human. Costs 10 chemicals."
	button_icon_state = "human_form"
	chemical_cost = 10
	req_dna = 1

//Transform into a human.
/datum/action/changeling/humanform/sting_action(mob/living/carbon/user)
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	var/datum/changeling_profile/chosen_prof = changeling.select_dna()
	if(!chosen_prof)
		return
	if(!user || user.notransform)
		return 0
	to_chat(user, span_notice("We transform our appearance."))
	..()
	changeling.purchased_powers -= src.type
	Remove(user)

	var/datum/dna/chosen_dna = chosen_prof.dna
	var/datum/species/chosen_species = chosen_dna.species
	user.humanize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPORGANS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSE, species = chosen_species)

	changeling.transform(user, chosen_prof)
	user.regenerate_icons()
	return TRUE
