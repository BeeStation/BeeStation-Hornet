
/**
 * Applies damage to this mob.
 *
 * Sends [COMSIG_MOB_APPLY_DAMAGE]
 *
 * Arguuments:
 * * damage - Amount of damage
 * * damagetype - What type of damage to do. one of [BRUTE], [BURN], [TOX], [OXY], [CLONE], [STAMINA], [BRAIN].
 * * def_zone - What body zone is being hit. Or a reference to what bodypart is being hit.
 * * blocked - Percent modifier to damage. 100 = 100% less damage dealt, 50% = 50% less damage dealt.
 * * forced - "Force" exactly the damage dealt. This means it skips damage modifier from blocked.
 * * spread_damage - For carbons, spreads the damage across all bodyparts rather than just the targeted zone.
 * * sharpness - Sharpness of the weapon.
 * * attack_direction - Direction of the attack from the attacker to [src].
 * * attacking_item - Item that is attacking [src].
 *
 * Returns the amount of damage dealt.
 */
/mob/living/proc/apply_damage(
	damage = 0,
	damagetype = BRUTE,
	def_zone = null,
	blocked = 0,
	forced = FALSE,
	spread_damage = FALSE,
	sharpness = NONE,
	attack_direction = null,
	attacking_item,
)
	SHOULD_CALL_PARENT(TRUE)
	var/damage_amount = damage
	if(!forced)
		damage_amount *= ((100 - blocked) / 100)
		damage_amount *= get_incoming_damage_modifier(damage_amount, damagetype, def_zone, sharpness, attack_direction, attacking_item)
	if(damage_amount <= 0)
		return 0

	SEND_SIGNAL(src, COMSIG_MOB_APPLY_DAMAGE, damage_amount, damagetype, def_zone, blocked, sharpness, attack_direction, attacking_item)

	var/damage_dealt = 0
	switch(damagetype)
		if(BRUTE)
			if(isbodypart(def_zone))
				var/obj/item/bodypart/actual_hit = def_zone
				var/delta = actual_hit.get_damage()
				if(actual_hit.receive_damage(
					brute = damage_amount,
					burn = 0,
					forced = forced,
					sharpness = sharpness,
					attack_direction = attack_direction,
					damage_source = attacking_item,
				))
					update_damage_overlays()
				damage_dealt = actual_hit.get_damage() - delta // Unfortunately bodypart receive_damage doesn't return damage dealt so we do it manually
			else
				damage_dealt = -1 * adjustBruteLoss(damage_amount, forced = forced)
		if(BURN)
			if(isbodypart(def_zone))
				var/obj/item/bodypart/actual_hit = def_zone
				var/delta = actual_hit.get_damage()
				if(actual_hit.receive_damage(
					brute = 0,
					burn = damage_amount,
					forced = forced,
					sharpness = sharpness,
					attack_direction = attack_direction,
					damage_source = attacking_item,
				))
					update_damage_overlays()
				damage_dealt = actual_hit.get_damage() - delta // See above
			else
				damage_dealt = -1 * adjustFireLoss(damage_amount, forced = forced)
		if(TOX)
			damage_dealt = -1 * adjustToxLoss(damage_amount, forced = forced)
		if(OXY)
			damage_dealt = -1 * adjustOxyLoss(damage_amount, forced = forced)
		if(CLONE)
			damage_dealt = -1 * adjustCloneLoss(damage_amount, forced = forced)
		if(STAMINA)
			damage_dealt = -1 * adjustStaminaLoss(damage_amount, forced = forced)
		if(BRAIN)
			damage_dealt = -1 * adjustOrganLoss(ORGAN_SLOT_BRAIN, damage_amount)

	SEND_SIGNAL(src, COMSIG_MOB_AFTER_APPLY_DAMAGE, damage_dealt, damagetype, def_zone, blocked, sharpness, attack_direction, attacking_item)
	return damage_dealt

/**
 * Used in tandem with [/mob/living/proc/apply_damage] to calculate modifier applied into incoming damage
 */
/mob/living/proc/get_incoming_damage_modifier(
	damage = 0,
	damagetype = BRUTE,
	def_zone = null,
	sharpness = NONE,
	attack_direction = null,
	attacking_item,
)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_BE_PURE(TRUE)

	var/list/damage_mods = list()
	SEND_SIGNAL(src, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, damage_mods, damage, damagetype, def_zone, sharpness, attack_direction, attacking_item)

	var/final_mod = 1
	for(var/new_mod in damage_mods)
		final_mod *= new_mod
	return final_mod

/**
 * Simply a wrapper for calling mob adjustXLoss() procs to heal a certain damage type,
 * when you don't know what damage type you're healing exactly.
 */
/mob/living/proc/heal_damage_type(heal_amount = 0, damagetype = BRUTE)
	heal_amount = abs(heal_amount) * -1

	switch(damagetype)
		if(BRUTE)
			return adjustBruteLoss(heal_amount)
		if(BURN)
			return adjustFireLoss(heal_amount)
		if(TOX)
			return adjustToxLoss(heal_amount)
		if(OXY)
			return adjustOxyLoss(heal_amount)
		if(CLONE)
			return adjustCloneLoss(heal_amount)
		if(STAMINA)
			return adjustStaminaLoss(heal_amount)

/// return the damage amount for the type given
/**
 * Simply a wrapper for calling mob getXLoss() procs to get a certain damage type,
 * when you don't know what damage type you're getting exactly.
 */
/mob/living/proc/get_current_damage_of_type(damagetype = BRUTE)
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
		if(STAMINA)
			return getStaminaLoss()

/// return the total damage of all types which update your health
/mob/living/proc/get_total_damage(precision = DAMAGE_PRECISION)
	return round(getBruteLoss() + getFireLoss() + getToxLoss() + getOxyLoss() + getCloneLoss(), precision)

/// Applies multiple damages at once via [apply_damage][/mob/living/proc/apply_damage]
/mob/living/proc/apply_damages(
	brute = 0,
	burn = 0,
	tox = 0,
	oxy = 0,
	clone = 0,
	def_zone = null,
	blocked = 0,
	stamina = 0,
	brain = 0,
)
	var/total_damage = 0
	if(brute)
		total_damage += apply_damage(brute, BRUTE, def_zone, blocked)
	if(burn)
		total_damage += apply_damage(burn, BURN, def_zone, blocked)
	if(tox)
		total_damage += apply_damage(tox, TOX, def_zone, blocked)
	if(oxy)
		total_damage += apply_damage(oxy, OXY, def_zone, blocked)
	if(clone)
		total_damage += apply_damage(clone, CLONE, def_zone, blocked)
	if(stamina)
		total_damage += apply_damage(stamina, STAMINA, def_zone, blocked)
	if(brain)
		total_damage += apply_damage(brain, BRAIN, def_zone, blocked)
	return total_damage



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
	return 1


/mob/living/proc/apply_effects(
	stun = 0,
	knockdown = 0,
	unconscious = 0,
	slur = 0 SECONDS,
	stutter = 0 SECONDS,
	eyeblur = 0 SECONDS,
	drowsy = 0 SECONDS,
	blocked = 0, // This one's not an effect, don't be confused - it's block chance
	stamina = 0, // This one's a damage type, and not an effect
	jitter = 0 SECONDS,
	paralyze = 0,
	immobilize = 0
	)
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

	if(stamina)
		apply_damage(stamina, STAMINA, null, blocked)

	if(drowsy)
		adjust_drowsiness(drowsy)
	if(eyeblur)
		adjust_eye_blur(eyeblur)
	if(jitter && (status_flags & CANSTUN) && !HAS_TRAIT(src, TRAIT_STUNIMMUNE))
		adjust_timed_status_effect(jitter, /datum/status_effect/jitter)
	if(slur)
		adjust_timed_status_effect(slur, /datum/status_effect/speech/slurring/drunk)
	if(stutter)
		adjust_timed_status_effect(stutter, /datum/status_effect/speech/stutter)

	return BULLET_ACT_HIT


/mob/living/proc/getBruteLoss()
	return bruteloss

/mob/living/proc/can_adjust_brute_loss(amount, forced, required_bodytype)
	if(!forced && HAS_TRAIT(src, TRAIT_GODMODE))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_LIVING_ADJUST_BRUTE_DAMAGE, BRUTE, amount, forced) & COMPONENT_IGNORE_CHANGE)
		return FALSE
	return TRUE

/mob/living/proc/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype = ALL)
	if (!can_adjust_brute_loss(amount, forced, required_bodytype))
		return 0
	. = bruteloss
	bruteloss = clamp((bruteloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	. -= bruteloss
	if(!.) // no change, no need to update
		return 0
	if(updating_health)
		updatehealth()

/mob/living/proc/setBruteLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype = ALL)
	if(!forced && HAS_TRAIT(src, TRAIT_GODMODE))
		return FALSE
	. = bruteloss
	bruteloss = amount

	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()
	. -= bruteloss

/mob/living/proc/getOxyLoss()
	return oxyloss

/mob/living/proc/can_adjust_oxy_loss(amount, forced, required_biotype)
	if(!forced)
		if(HAS_TRAIT(src, TRAIT_GODMODE))
			return FALSE
		/*
		if (required_respiration_type)
			var/obj/item/organ/internal/lungs/affected_lungs = get_organ_slot(ORGAN_SLOT_LUNGS)
			if(isnull(affected_lungs))
				if(!(mob_respiration_type & required_respiration_type))  // if the mob has no lungs, use mob_respiration_type
					return FALSE
			else
				if(!(affected_lungs.respiration_type & required_respiration_type)) // otherwise use the lungs' respiration_type
					return FALSE
		*/
	if(SEND_SIGNAL(src, COMSIG_LIVING_ADJUST_OXY_DAMAGE, OXY, amount, forced) & COMPONENT_IGNORE_CHANGE)
		return FALSE
	return TRUE

/mob/living/proc/adjustOxyLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype = ALL)
	if(!can_adjust_oxy_loss(amount, forced, required_biotype))
		return 0
	. = oxyloss
	oxyloss = clamp((oxyloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	. -= oxyloss
	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()

/mob/living/proc/setOxyLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype = ALL)
	if(!forced)
		if(HAS_TRAIT(src, TRAIT_GODMODE))
			return FALSE

		/*
		var/obj/item/organ/internal/lungs/affected_lungs = get_organ_slot(ORGAN_SLOT_LUNGS)
		if(isnull(affected_lungs))
			if(!(mob_respiration_type & required_respiration_type))
				return FALSE
		else
			if(!(affected_lungs.respiration_type & required_respiration_type))
				return FALSE
		*/
	. = oxyloss
	oxyloss = amount
	. -= oxyloss
	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()

/mob/living/proc/getToxLoss()
	return toxloss

/mob/living/proc/can_adjust_tox_loss(amount, forced, required_biotype)
	if(!forced && (HAS_TRAIT(src, TRAIT_GODMODE) || !(mob_biotypes & required_biotype)))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_LIVING_ADJUST_TOX_DAMAGE, TOX, amount, forced) & COMPONENT_IGNORE_CHANGE)
		return FALSE
	return TRUE

/mob/living/proc/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype = ALL)
	if(!can_adjust_tox_loss(amount, forced, required_biotype))
		return 0
	. = toxloss
	toxloss = clamp((toxloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	. -= toxloss
	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()

/mob/living/proc/setToxLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype = ALL)
	if(!forced && HAS_TRAIT(src, TRAIT_GODMODE))
		return FALSE
	if(!forced && !(mob_biotypes & required_biotype))
		return FALSE
	. = toxloss
	toxloss = amount
	. -= toxloss
	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()

/mob/living/proc/getFireLoss()
	return fireloss

/mob/living/proc/can_adjust_fire_loss(amount, forced, required_bodytype)
	if(!forced && (HAS_TRAIT(src, TRAIT_GODMODE)))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_LIVING_ADJUST_BURN_DAMAGE, BURN, amount, forced) & COMPONENT_IGNORE_CHANGE)
		return FALSE
	return TRUE

/mob/living/proc/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype = ALL)
	if(!can_adjust_fire_loss(amount, forced, required_bodytype))
		return 0
	. = fireloss
	fireloss = clamp((fireloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	. -= fireloss
	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()

/mob/living/proc/setFireLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype = ALL)
	if(!forced && HAS_TRAIT(src, TRAIT_GODMODE))
		return
	. = fireloss
	fireloss = amount
	. -= fireloss
	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()

/mob/living/proc/getCloneLoss()
	return cloneloss

/mob/living/proc/can_adjust_clone_loss(amount, forced, required_biotype = ALL)
	if(!forced && (!(mob_biotypes & required_biotype) || HAS_TRAIT(src, TRAIT_GODMODE) || HAS_TRAIT(src, TRAIT_NOCLONELOSS)))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_LIVING_ADJUST_CLONE_DAMAGE, CLONE, amount, forced) & COMPONENT_IGNORE_CHANGE)
		return FALSE
	return TRUE

/mob/living/proc/adjustCloneLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype = ALL)
	if(!can_adjust_clone_loss(amount, forced, required_biotype))
		return 0
	. = cloneloss
	cloneloss = clamp((cloneloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	. -= cloneloss
	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()

/mob/living/proc/setCloneLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype = ALL)
	if(!forced && (HAS_TRAIT(src, TRAIT_GODMODE) || HAS_TRAIT(src, TRAIT_NOCLONELOSS)))
		return FALSE
	if(!forced && !(mob_biotypes & required_biotype))
		return FALSE
	. = cloneloss
	cloneloss = amount
	. -= cloneloss
	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()

/mob/living/proc/adjustOrganLoss(slot, amount, maximum, required_organ_flag)
	return

/mob/living/proc/setOrganLoss(slot, amount, maximum, required_organ_flag)
	return

/mob/living/proc/getOrganLoss(slot)
	return

/mob/living/proc/getStaminaLoss()
	return staminaloss

/mob/living/proc/can_adjust_stamina_loss(amount, forced, required_biotype = ALL)
	if(!forced && (!(mob_biotypes & required_biotype) || HAS_TRAIT(src, TRAIT_GODMODE)))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_LIVING_ADJUST_STAMINA_DAMAGE, STAMINA, amount, forced) & COMPONENT_IGNORE_CHANGE)
		return FALSE
	return TRUE

/mob/living/proc/adjustStaminaLoss(amount, updating_stamina = TRUE, forced = FALSE, required_biotype = ALL)
	if(!can_adjust_stamina_loss(amount, forced, required_biotype))
		return 0
	return

/mob/living/proc/setStaminaLoss(amount, updating_stamina = TRUE, forced = FALSE, required_biotype = ALL)
	if(!forced && (HAS_TRAIT(src, TRAIT_GODMODE)))
		return FALSE
	if(!forced && !(mob_biotypes & required_biotype))
		return FALSE
	return

/**
 * heal ONE external organ, organ gets randomly selected from damaged ones.
 *
 * returns the net change in damage
 */
/mob/living/proc/heal_bodypart_damage(brute = 0, burn = 0, stamina = 0, updating_health = TRUE, required_bodytype = NONE, target_zone = null)
	. = (adjustBruteLoss(-abs(brute), updating_health = FALSE) + adjustFireLoss(-abs(burn), updating_health = FALSE) + adjustStaminaLoss(-abs(stamina), updating_stamina = FALSE))
	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()
		update_stamina()

// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/take_bodypart_damage(brute = 0, burn = 0, stamina = 0, updating_health = TRUE, required_bodytype, check_armor = FALSE)
	. = (adjustBruteLoss(abs(brute), updating_health = FALSE) + adjustFireLoss(abs(burn), updating_health = FALSE) + adjustStaminaLoss(abs(stamina), updating_stamina = FALSE))
	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()
		update_stamina(stamina >= DAMAGE_PRECISION)

/// heal MANY bodyparts, in random order.
/mob/living/proc/heal_overall_damage(brute = 0, burn = 0, stamina = 0, required_bodytype, updating_health = TRUE, forced = FALSE)
	. = (adjustBruteLoss(-abs(brute), updating_health = FALSE, forced = forced) + \
			adjustFireLoss(-abs(burn), updating_health = FALSE, forced = forced) + \
			adjustStaminaLoss(-abs(stamina), updating_stamina = FALSE, forced = forced))
	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()
		update_stamina()

// damage MANY bodyparts, in random order
/mob/living/proc/take_overall_damage(brute = 0, burn = 0, stamina = 0, updating_health = TRUE, forced = FALSE, required_bodytype)
	. = (adjustBruteLoss(abs(brute), updating_health = FALSE, forced = forced) + \
			adjustFireLoss(abs(burn), updating_health = FALSE, forced = forced) + \
			adjustStaminaLoss(abs(stamina), updating_stamina = FALSE, forced = forced))
	if(!.) // no change, no need to update
		return FALSE
	if(updating_health)
		updatehealth()
		update_stamina(stamina >= DAMAGE_PRECISION)

///heal up to amount damage, in a given order
/mob/living/proc/heal_ordered_damage(amount, list/damage_types)
	. = 0 //we'll return the amount of damage healed
	for(var/damagetype in damage_types)
		var/amount_to_heal = min(abs(amount), get_current_damage_of_type(damagetype)) //heal only up to the amount of damage we have
		if(amount_to_heal)
			. += heal_damage_type(amount_to_heal, damagetype)
			amount -= amount_to_heal //remove what we healed from our current amount
		if(!amount)
			break
