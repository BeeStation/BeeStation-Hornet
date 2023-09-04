
/datum/damage/clone
	display_name = "cellular"

/datum/damage/clone/apply_living(mob/living/target, damage, update_health = TRUE, forced = FALSE)
	target.adjustCloneLoss(damage, update_health, forced)

/datum/damage/clone/apply_bodypart(obj/item/bodypart/bodypart, damage, update_health = TRUE, forced = FALSE)
	bodypart.owner?.adjustCloneLoss(damage, update_health, forced)

/datum/damage/clone/apply_organ(obj/item/organ/organ, damage, update_health = TRUE, forced = FALSE)
	organ.owner?.adjustCloneLoss(damage, update_health, forced)

/datum/damage/clone/apply_object(obj/target, damage)
	target.take_damage(damage, CLONE)

