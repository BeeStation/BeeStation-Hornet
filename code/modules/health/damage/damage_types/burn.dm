
/datum/damage/burn
	display_name = "burn"

/datum/damage/burn/apply_living(mob/living/target, damage, forced = FALSE)
	target.adjustFireLoss(damage, forced)

/datum/damage/burn/apply_bodypart(obj/item/bodypart/bodypart, damage, forced = FALSE)
	bodypart.receive_damage(burn = damage)

/datum/damage/burn/apply_organ(obj/item/organ/organ, damage, forced = FALSE)
	organ.applyOrganDamage(damage)

/datum/damage/burn/apply_object(obj/target, damage)
	target.take_damage(damage, BURN)

