
/mob/living/silicon/take_direct_damage(amount, type = BRUTE, flag = DAMAGE_STANDARD, zone = null)
	switch(type)
		if(BRUTE)
			adjustBruteLoss(amount, forced = TRUE)
		if(BURN)
			adjustFireLoss(amount, forced = TRUE)
		if(OXY)
			if(amount < 0)
				adjustOxyLoss(amount, forced = TRUE)
	return 1


/mob/living/silicon/apply_effect(effect = 0,effecttype = EFFECT_STUN, blocked = FALSE)
	return FALSE //The only effect that can hit them atm is flashes and they still directly edit so this works for now

/mob/living/silicon/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE) //immune to tox damage
	return FALSE

/mob/living/silicon/setToxLoss(amount, updating_health = TRUE, forced = FALSE)
	return FALSE

/mob/living/silicon/adjustCloneLoss(amount, updating_health = TRUE, forced = FALSE) //immune to clone damage
	return FALSE

/mob/living/silicon/setCloneLoss(amount, updating_health = TRUE, forced = FALSE)
	return FALSE

/mob/living/silicon/adjustExhaustion(amount, updating_health = TRUE, forced = FALSE)//immune to stamina damage.
	return FALSE

/mob/living/silicon/setStaminaLoss(amount, updating_health = TRUE)
	return FALSE

/mob/living/silicon/adjustOrganLoss(slot, amount, maximum = 500, required_status)
	return FALSE

/mob/living/silicon/setOrganLoss(slot, amount)
	return FALSE
