/datum/injury/acute/genetic
	base_type = /datum/injury/acute/genetic
	examine_description = "<b>cellular decay</b>"
	heal_description = "This injury requires advanced chemicals to heal."
	max_absorption = 0
	external = TRUE
	injury_flags = INJURY_LIMB
	damage_multiplier = 1
	pain_multiplier = 0.6

/datum/injury/acute/genetic/update_progressive_effects()
	var/mob/living/owner = mob || bodypart.owner
	if (!owner)
		return
	if (owner.getCloneLoss() > 50)
		ADD_TRAIT(owner, TRAIT_DISFIGURED, FROM_GENETIC_DAMAGE)
	else
		REMOVE_TRAIT(owner, TRAIT_DISFIGURED, FROM_GENETIC_DAMAGE)
