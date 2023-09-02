
/datum/damage/suffocation

/datum/damage/suffocation/apply_living(mob/living/target, damage, update_health = TRUE, forced = FALSE)
	target.adjustOxyLoss(damage, update_health, forced)

/datum/damage/suffocation/apply_bodypart(obj/item/bodypart/bodypart, damage, update_health = TRUE, forced = FALSE)
	CRASH("Cannot apply oxyloss damage to bodyparts.")

/datum/damage/suffocation/apply_organ(obj/item/organ/organ, damage, update_health = TRUE, forced = FALSE)
	CRASH("Cannot apply oxyloss damage to internal organs.")
