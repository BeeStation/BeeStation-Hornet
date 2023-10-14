
/datum/damage/toxin
	display_name = "toxic"

/datum/damage/toxin/apply_living(mob/living/target, damage, forced = FALSE)
	target.adjustToxLoss(damage, forced)

/datum/damage/toxin/apply_bodypart(obj/item/bodypart/bodypart, damage, forced = FALSE)
	CRASH("Cannot apply toxin damage to bodyparts.")

/datum/damage/toxin/apply_organ(obj/item/organ/organ, damage, forced = FALSE)
	organ.applyOrganDamage(damage)

/datum/damage/toxin/apply_object(obj/target, damage)
	target.take_damage(damage, TOX)

