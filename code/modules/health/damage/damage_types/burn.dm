
/datum/damage/burn
	display_name = "burn"

/datum/damage/burn/apply_living(mob/living/target, damage, update_health = TRUE, forced = FALSE)
	target.adjustFireLoss(damage, update_health, forced)

/datum/damage/burn/apply_bodypart(obj/item/bodypart/bodypart, damage, update_health = TRUE, forced = FALSE)
	bodypart.receive_damage(burn = damage, updating_health = update_health)

/datum/damage/burn/apply_organ(obj/item/organ/organ, damage, update_health = TRUE, forced = FALSE)
	organ.applyOrganDamage(damage)

/datum/damage/burn/apply_object(obj/target, damage)
	target.take_damage(damage, BURN)

