
/datum/damage/brute
	display_name = "brute"

/datum/damage/brute/apply_living(mob/living/target, damage, forced = FALSE)
	target.adjustBruteLossAbstract(damage, forced)

/datum/damage/brute/apply_bodypart(obj/item/bodypart/bodypart, damage, forced = FALSE)
	bodypart.receive_damage(damage)

/datum/damage/brute/apply_organ(obj/item/organ/organ, damage, forced = FALSE)
	organ.applyOrganDamage(damage)

/datum/damage/brute/apply_object(obj/target, damage)
	target.take_damage(damage, BRUTE)
