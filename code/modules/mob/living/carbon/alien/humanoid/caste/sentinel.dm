/mob/living/carbon/alien/humanoid/sentinel
	name = "alien sentinel"
	caste = "s"
	maxHealth = 225
	health = 225
	icon_state = "aliens"

/mob/living/carbon/alien/humanoid/sentinel/Initialize(mapload)
	GRANT_ACTION(/datum/action/cooldown/mob_cooldown/sneak/alien)
	return ..()


/mob/living/carbon/alien/humanoid/sentinel/create_internal_organs()
	internal_organs += new /obj/item/organ/alien/plasmavessel
	internal_organs += new /obj/item/organ/alien/acid
	internal_organs += new /obj/item/organ/alien/neurotoxin
	return ..()
