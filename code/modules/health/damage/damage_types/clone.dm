
/datum/damage/clone
	display_name = "cellular"

/datum/damage/clone/apply_living(mob/living/target, damage, forced = FALSE)
	target.adjustCloneLossAbstract(damage, forced)

/datum/damage/clone/apply_bodypart(obj/item/bodypart/bodypart, damage, forced = FALSE)
	bodypart.owner?.adjustCloneLossAbstract(damage, forced)

/datum/damage/clone/apply_organ(obj/item/organ/organ, damage, forced = FALSE)
	organ.owner?.adjustCloneLossAbstract(damage, forced)

/datum/damage/clone/apply_object(obj/target, damage)
	target.take_damage(damage, CLONE)

