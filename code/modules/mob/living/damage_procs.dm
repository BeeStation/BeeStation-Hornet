
/*
	apply_damage_old(a,b,c)
	args
	a:damage - How much damage to take
	b:damage_type - What type of damage to take, brute, burn
	c:def_zone - Where to take the damage if its brute or burn
	Returns
	standard 0 if fail
*/
/mob/living/proc/apply_damage_old(damage = 0,damagetype = BRUTE, def_zone = null, blocked = FALSE, forced = FALSE)
	SEND_SIGNAL(src, COMSIG_MOB_APPLY_DAMGE, damage, damagetype, def_zone)
	var/hit_percent = (100-blocked)/100
	if(!damage || (!forced && hit_percent <= 0))
		return 0
	var/damage_amount =  forced ? damage : damage * hit_percent
	switch(damagetype)
		if(BRUTE)
			adjustBruteLossAbstract(damage_amount, forced = forced)
		if(BURN)
			adjustFireLoss(damage_amount, forced = forced)
		if(TOX)
			adjustToxLoss(damage_amount, forced = forced)
		if(OXY)
			adjustOxyLoss(damage_amount, forced = forced)
		if(CLONE)
			adjustCloneLossAbstract(damage_amount, forced = forced)
		if(STAMINA_DAMTYPE)
			adjustStaminaLoss(damage_amount, forced = forced)
	return 1

/mob/living/proc/get_damage_amount(damagetype = BRUTE)
	switch(damagetype)
		if(BRUTE)
			return getBruteLoss()
		if(BURN)
			return getFireLoss()
		if(TOX)
			return getToxLoss()
		if(OXY)
			return getOxyLoss()
		if(CLONE)
			return getCloneLoss()
		if(STAMINA_DAMTYPE)
			return getStaminaLoss()

/mob/living/proc/apply_effect(effect = 0,effecttype = EFFECT_STUN, blocked = FALSE)
	var/hit_percent = (100-blocked)/100
	if(!effect || (hit_percent <= 0))
		return 0
	switch(effecttype)
		if(EFFECT_STUN)
			Stun(effect * hit_percent)
		if(EFFECT_KNOCKDOWN)
			Knockdown(effect * hit_percent)
		if(EFFECT_PARALYZE)
			Paralyze(effect * hit_percent)
		if(EFFECT_IMMOBILIZE)
			Immobilize(effect * hit_percent)
		if(EFFECT_UNCONSCIOUS)
			Unconscious(effect * hit_percent)
		if(EFFECT_IRRADIATE)
			radiation += max(effect * hit_percent, 0)
		if(EFFECT_SLUR)
			slurring = max(slurring,(effect * hit_percent))
		if(EFFECT_STUTTER)
			if((status_flags & CANSTUN) && !HAS_TRAIT(src, TRAIT_STUNIMMUNE)) // stun is usually associated with stutter
				stuttering = max(stuttering,(effect * hit_percent))
		if(EFFECT_EYE_BLUR)
			blur_eyes(effect * hit_percent)
		if(EFFECT_DROWSY)
			drowsyness = max(drowsyness,(effect * hit_percent))
		if(EFFECT_JITTER)
			if((status_flags & CANSTUN) && !HAS_TRAIT(src, TRAIT_STUNIMMUNE))
				jitteriness = max(jitteriness,(effect * hit_percent))
	return 1


/mob/living/proc/apply_effects(stun = 0, knockdown = 0, unconscious = 0, irradiate = 0, slur = 0, stutter = 0, eyeblur = 0, drowsy = 0, blocked = FALSE, stamina = 0, jitter = 0, paralyze = 0, immobilize = 0)
	if(blocked >= 100)
		return BULLET_ACT_BLOCK
	if(stun)
		apply_effect(stun, EFFECT_STUN, blocked)
	if(knockdown)
		apply_effect(knockdown, EFFECT_KNOCKDOWN, blocked)
	if(unconscious)
		apply_effect(unconscious, EFFECT_UNCONSCIOUS, blocked)
	if(paralyze)
		apply_effect(paralyze, EFFECT_PARALYZE, blocked)
	if(immobilize)
		apply_effect(immobilize, EFFECT_IMMOBILIZE, blocked)
	if(irradiate)
		apply_effect(irradiate, EFFECT_IRRADIATE, blocked)
	if(slur)
		apply_effect(slur, EFFECT_SLUR, blocked)
	if(stutter)
		apply_effect(stutter, EFFECT_STUTTER, blocked)
	if(eyeblur)
		apply_effect(eyeblur, EFFECT_EYE_BLUR, blocked)
	if(drowsy)
		apply_effect(drowsy, EFFECT_DROWSY, blocked)
	if(stamina)
		apply_damage_old(stamina, STAMINA_DAMTYPE, null, blocked)
	if(jitter)
		apply_effect(jitter, EFFECT_JITTER, blocked)
	return BULLET_ACT_HIT


/mob/living/proc/getBruteLoss()
	return bruteloss

/mob/living/proc/adjustBruteLossAbstract(amount, forced = FALSE, required_status)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	bruteloss = CLAMP((bruteloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	UPDATE_HEALTH(src)
	return amount

/mob/living/proc/getOxyLoss()
	return oxyloss

/mob/living/proc/adjustOxyLoss(amount, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	oxyloss = CLAMP((oxyloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	UPDATE_HEALTH(src)
	return amount

/mob/living/proc/setOxyLoss(amount, forced = FALSE)
	if(status_flags & GODMODE)
		return 0
	oxyloss = amount
	UPDATE_HEALTH(src)
	return amount

/mob/living/proc/getToxLoss()
	return toxloss

/mob/living/proc/adjustToxLoss(amount, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	toxloss = CLAMP((toxloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	UPDATE_HEALTH(src)
	return amount

/mob/living/proc/setToxLoss(amount, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	toxloss = amount
	UPDATE_HEALTH(src)
	return amount

/mob/living/proc/getFireLoss()
	return fireloss

/mob/living/proc/adjustFireLoss(amount, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	fireloss = CLAMP((fireloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	UPDATE_HEALTH(src)
	return amount

/mob/living/proc/getCloneLoss()
	return cloneloss

/mob/living/proc/adjustCloneLossAbstract(amount, forced = FALSE)
	if(!forced && ((status_flags & GODMODE) || HAS_TRAIT(src, TRAIT_NOCLONELOSS)))
		return FALSE
	cloneloss = CLAMP((cloneloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	UPDATE_HEALTH(src)
	return amount

/mob/living/proc/setCloneLoss(amount, forced = FALSE)
	if(!forced && ((status_flags & GODMODE) || HAS_TRAIT(src, TRAIT_NOCLONELOSS)))
		return FALSE
	cloneloss = amount
	UPDATE_HEALTH(src)
	return amount

/mob/living/proc/adjustOrganLoss(slot, amount, maximum, required_status)
	return

/mob/living/proc/setOrganLoss(slot, amount, maximum)
	return

/mob/living/proc/getOrganLoss(slot)
	return

/mob/living/proc/getStaminaLoss()
	return staminaloss

/mob/living/proc/adjustStaminaLoss(amount, forced = FALSE)
	return

/mob/living/proc/setStaminaLoss(amount, forced = FALSE)
	return

// heal ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/heal_bodypart_damage(brute = 0, burn = 0, stamina = 0, required_status)
	adjustBruteLossAbstract(-brute, FALSE) //zero as argument for no instant health update
	adjustFireLoss(-burn, FALSE)
	adjustStaminaLoss(-stamina, FALSE)
	if (stamina != 0)
		update_stamina()

// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/take_bodypart_damage(brute = 0, burn = 0, stamina = 0, required_status, check_armor = FALSE)
	adjustBruteLossAbstract(brute, FALSE) //zero as argument for no instant health update
	adjustFireLoss(burn, FALSE)
	adjustStaminaLoss(stamina, FALSE)
	if (stamina != 0)
		update_stamina(stamina >= DAMAGE_PRECISION)

// heal MANY bodyparts, in random order
/mob/living/proc/heal_overall_damage(brute = 0, burn = 0, stamina = 0, required_status)
	adjustBruteLossAbstract(-brute, FALSE) //zero as argument for no instant health update
	adjustFireLoss(-burn, FALSE)
	adjustStaminaLoss(-stamina, FALSE)
	if (stamina != 0)
		update_stamina()

// damage MANY bodyparts, in random order
/mob/living/proc/take_overall_damage(brute = 0, burn = 0, stamina = 0, required_status = null)
	adjustBruteLossAbstract(brute) //zero as argument for no instant health update
	adjustFireLoss(burn)
	adjustStaminaLoss(stamina)
	if (stamina != 0)
		update_stamina(stamina >= DAMAGE_PRECISION)

//heal up to amount damage, in a given order
/mob/living/proc/heal_ordered_damage(amount, list/damage_types)
	. = amount //we'll return the amount of damage healed
	for(var/i in damage_types)
		var/amount_to_heal = min(amount, get_damage_amount(i)) //heal only up to the amount of damage we have
		if(amount_to_heal)
			//BACONTODO apply_damage_old_type(-amount_to_heal, i)
			amount -= amount_to_heal //remove what we healed from our current amount
		if(!amount)
			break
	. -= amount //if there's leftover healing, remove it from what we return
