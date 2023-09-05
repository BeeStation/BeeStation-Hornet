
/datum/damage/stamina
	display_name = "stamina"

/datum/damage/stamina/apply_living(mob/living/target, damage, update_health = TRUE, forced = FALSE)
	target.adjustStaminaLoss(damage, update_health, forced)

/datum/damage/stamina/apply_bodypart(obj/item/bodypart/bodypart, damage, update_health = TRUE, forced = FALSE)
	bodypart.receive_damage(stamina = damage, updating_health = update_health)

/datum/damage/stamina/apply_organ(obj/item/organ/organ, damage, update_health = TRUE, forced = FALSE)
	return

/datum/damage/stamina/apply_object(obj/target, damage)
	target.take_damage(damage, STAMINA_DAMTYPE)

