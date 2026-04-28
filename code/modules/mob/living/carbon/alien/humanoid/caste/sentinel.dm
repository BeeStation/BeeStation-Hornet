/mob/living/carbon/alien/humanoid/sentinel
	name = "alien sentinel"
	caste = "s"
	maxHealth = 225
	health = 225
	icon_state = "aliens"

/mob/living/carbon/alien/humanoid/sentinel/Initialize(mapload)
	var/datum/action/alien/sneak/sneaky_beaky = new(src)
	sneaky_beaky.Grant(src)
	return ..()


/mob/living/carbon/alien/humanoid/sentinel/create_internal_organs()
	internal_organs += new /obj/item/organ/alien/plasmavessel
	internal_organs += new /obj/item/organ/alien/acid
	internal_organs += new /obj/item/organ/alien/neurotoxin
	return ..()
