
/mob/living/simple_animal/proc/adjustHealth(amount, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	bruteloss = round(CLAMP(bruteloss + amount, 0, maxHealth),DAMAGE_PRECISION)
	UPDATE_HEALTH(src)
	return amount

/mob/living/simple_animal/adjustBruteLossAbstract(amount, forced = FALSE)
	if(forced)
		. = adjustHealth(amount * CONFIG_GET(number/damage_multiplier), forced)
	else if(damage_coeff[BRUTE])
		. = adjustHealth(amount * damage_coeff[BRUTE] * CONFIG_GET(number/damage_multiplier), forced)

/mob/living/simple_animal/adjustFireLoss(amount, forced = FALSE)
	if(forced)
		. = adjustHealth(amount * CONFIG_GET(number/damage_multiplier), forced)
	else if(damage_coeff[BURN])
		. = adjustHealth(amount * damage_coeff[BURN] * CONFIG_GET(number/damage_multiplier), forced)

/mob/living/simple_animal/adjustOxyLoss(amount, forced = FALSE)
	if(forced)
		. = adjustHealth(amount * CONFIG_GET(number/damage_multiplier), forced)
	else if(damage_coeff[OXY])
		. = adjustHealth(amount * damage_coeff[OXY] * CONFIG_GET(number/damage_multiplier), forced)

/mob/living/simple_animal/adjustToxLoss(amount, forced = FALSE)
	if(forced)
		. = adjustHealth(amount * CONFIG_GET(number/damage_multiplier), forced)
	else if(damage_coeff[TOX])
		. = adjustHealth(amount * damage_coeff[TOX] * CONFIG_GET(number/damage_multiplier), forced)

/mob/living/simple_animal/adjustCloneLossAbstract(amount, forced = FALSE)
	if(forced)
		. = adjustHealth(amount * CONFIG_GET(number/damage_multiplier), forced)
	else if(damage_coeff[CLONE])
		. = adjustHealth(amount * damage_coeff[CLONE] * CONFIG_GET(number/damage_multiplier), forced)

/mob/living/simple_animal/adjustStaminaLoss(amount, forced = FALSE)
	return
