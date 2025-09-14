/datum/injury/acute/genetic
	base_type = /datum/injury/acute/genetic
	examine_description = "<b>cellular damage</b>"
	heal_description = "The injury can be treated by applying ointment to the affected limb."
	max_absorption = 0
	external = TRUE
	injury_flags = INJURY_LIMB

/datum/injury/acute/genetic/update_progressive_effects()
	var/mob/living/owner = mob || bodypart.owner
	if (!owner)
		return
	if (owner.getCloneLoss() > 50)
		ADD_TRAIT(owner, TRAIT_DISFIGURED, FROM_GENETIC_DAMAGE)
	else
		REMOVE_TRAIT(owner, TRAIT_DISFIGURED, FROM_GENETIC_DAMAGE)
