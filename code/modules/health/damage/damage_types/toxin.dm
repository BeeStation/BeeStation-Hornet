
/datum/damage/toxin

/datum/damage/toxin/apply_living(mob/living/target, damage, update_health = TRUE, forced = FALSE)
	target.adjustToxLoss(damage, update_health, forced)

/datum/damage/toxin/apply_bodypart(obj/item/bodypart/bodypart, damage, update_health = TRUE, forced = FALSE)
	CRASH("Cannot apply toxin damage to bodyparts.")

/datum/damage/toxin/apply_organ(obj/item/organ/organ, damage, update_health = TRUE, forced = FALSE)
	organ.applyOrganDamage(damage)
