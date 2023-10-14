
/datum/damage/stamina
	display_name = "stamina"

/datum/damage/stamina/apply_living(mob/living/target, damage, forced = FALSE)
	target.adjustStaminaLoss(damage, forced)

/datum/damage/stamina/apply_bodypart(obj/item/bodypart/bodypart, damage, forced = FALSE)
	bodypart.receive_damage(stamina = damage)

/datum/damage/stamina/apply_organ(obj/item/organ/organ, damage, forced = FALSE)
	return

/datum/damage/stamina/apply_object(obj/target, damage)
	target.take_damage(damage, STAMINA_DAMTYPE)

