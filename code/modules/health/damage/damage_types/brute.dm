
/datum/damage/brute
	display_name = "brute"

/datum/damage/brute/apply_living(mob/living/target, damage, update_health = TRUE, forced = FALSE)
	target.adjustBruteLoss(damage, forced)

/datum/damage/brute/apply_bodypart(obj/item/bodypart/bodypart, damage, update_health = TRUE, forced = FALSE)
	bodypart.receive_damage(damage, updating_health = update_health)

/datum/damage/brute/apply_organ(obj/item/organ/organ, damage, update_health = TRUE, forced = FALSE)
	organ.applyOrganDamage(damage)

/datum/damage/brute/apply_object(obj/target, damage)
	target.take_damage(damage, BRUTE)
