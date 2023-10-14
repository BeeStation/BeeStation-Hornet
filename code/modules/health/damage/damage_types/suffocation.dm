
/datum/damage/suffocation
	display_name = "suffocation"

/datum/damage/suffocation/apply_living(mob/living/target, damage, forced = FALSE)
	target.adjustOxyLoss(damage, forced)

/datum/damage/suffocation/apply_bodypart(obj/item/bodypart/bodypart, damage, forced = FALSE)
	CRASH("Cannot apply oxyloss damage to bodyparts.")

/datum/damage/suffocation/apply_organ(obj/item/organ/organ, damage, forced = FALSE)
	CRASH("Cannot apply oxyloss damage to internal organs.")

/datum/damage/suffocation/apply_object(obj/target, damage)
	target.take_damage(damage, OXY)

