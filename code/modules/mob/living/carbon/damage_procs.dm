

/mob/living/carbon/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked = FALSE, forced = FALSE, spread_damage = FALSE)
	SEND_SIGNAL(src, COMSIG_MOB_APPLY_DAMGE, damage, damagetype, def_zone)
	var/hit_percent = (100-blocked)/100
	if(!damage || (!forced && hit_percent <= 0))
		return 0

	var/obj/item/bodypart/BP = null
	if(!spread_damage)
		if(isbodypart(def_zone)) //we specified a bodypart object
			BP = def_zone
		else
			if(!def_zone)
				def_zone = ran_zone(def_zone)
			BP = get_bodypart(check_zone(def_zone))
			if(!BP)
				BP = bodyparts[1]

	var/damage_amount = forced ? damage : damage * hit_percent
	switch(damagetype)
		if(BRUTE)
			if(BP)
				if(BP.receive_damage(damage_amount, 0))
					update_damage_overlays()
			else //no bodypart, we deal damage with a more general method.
				adjustBruteLoss(damage_amount, forced = forced)
		if(BURN)
			if(BP)
				if(BP.receive_damage(0, damage_amount))
					update_damage_overlays()
			else
				adjustFireLoss(damage_amount, forced = forced)
		if(TOX)
			adjustToxLoss(damage_amount, forced = forced)
		if(OXY)
			adjustOxyLoss(damage_amount, forced = forced)
		if(CLONE)
			adjustCloneLoss(damage_amount, forced = forced)
		if(STAMINA)
			if(BP)
				if(BP.receive_damage(0, 0, damage_amount))
					update_damage_overlays()
			else
				adjustStaminaLoss(damage_amount, forced = forced)
	return TRUE


//These procs fetch a cumulative total damage from all bodyparts
/mob/living/carbon/getBruteLoss()
	var/amount = 0
	for(var/obj/item/bodypart/BP as() in bodyparts)
		amount += BP.brute_dam
	return amount

/mob/living/carbon/getFireLoss()
	var/amount = 0
	for(var/obj/item/bodypart/BP as() in bodyparts)
		amount += BP.burn_dam
	return amount


/mob/living/carbon/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	if(amount > 0)
		take_overall_damage(brute = amount, updating_health = updating_health, forced = forced, required_bodytype = required_bodytype)
	else
		if(!required_bodytype)
			required_bodytype = forced ? null : BODYTYPE_ORGANIC
		heal_overall_damage(brute = abs(amount), required_bodytype = required_bodytype, updating_health = updating_health, forced = forced)
	return amount


/mob/living/carbon/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	if(amount > 0)
		take_overall_damage(burn = amount, updating_health = updating_health, forced = forced, required_bodytype = required_bodytype)
	else
		if(!required_bodytype)
			required_bodytype = forced ? null : BODYTYPE_ORGANIC
		heal_overall_damage(burn = abs(amount), required_bodytype = required_bodytype, updating_health = updating_health, forced = forced)
	return amount

/mob/living/carbon/getStaminaLoss()
	. = 0
	for(var/obj/item/bodypart/BP as() in bodyparts)
		. += round(BP.stamina_dam * BP.stam_damage_coeff, DAMAGE_PRECISION)

/mob/living/carbon/adjustStaminaLoss(amount, updating_stamina = TRUE, forced = FALSE, required_biotype)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	if(amount > 0)
		take_overall_damage(stamina = amount, updating_health = updating_stamina)
	else
		heal_overall_damage(0, 0, abs(amount), null, updating_stamina)
	return amount

/mob/living/carbon/setStaminaLoss(amount, updating_health = TRUE, forced = FALSE)
	var/current = getStaminaLoss()
	var/diff = amount - current
	if(!diff)
		return
	adjustStaminaLoss(diff, updating_health, forced)

/** adjustOrganLoss
* * slot - organ slot, like [ORGAN_SLOT_HEART]
 * * amount - damage to be done
 * * maximum - currently an arbitrarily large number, can be set so as to limit damage
 * * required_organ_flag - targets only a specific organ type if set to ORGAN_ORGANIC or ORGAN_ROBOTIC
 */
/mob/living/carbon/adjustOrganLoss(slot, amount, maximum = INFINITY, required_organ_flag = NONE)
	var/obj/item/organ/affected_organ = get_organ_slot(slot)
	if(!affected_organ || (status_flags & GODMODE))
		return
	if(required_organ_flag && !(affected_organ.organ_flags & required_organ_flag))
		return
	affected_organ.applyOrganDamage(amount, maximum)

/**
 * If an organ exists in the slot requested, and we are capable of taking damage (we don't have [GODMODE] on), call the set damage proc on that organ, which can
 * set or clear the failing variable on that organ, making it either cease or start functions again, unlike adjustOrganLoss.
 *
 * Arguments:
 * * slot - organ slot, like [ORGAN_SLOT_HEART]
 * * amount - damage to be set to
 * * required_organ_flag - targets only a specific organ type if set to ORGAN_ORGANIC or ORGAN_ROBOTIC
 *
 * Returns: The net change in damage from set_organ_damage()
 */
/mob/living/carbon/setOrganLoss(slot, amount, required_organ_flag = NONE)
	var/obj/item/organ/affected_organ = get_organ_slot(slot)
	if(!affected_organ || (status_flags & GODMODE))
		return FALSE
	if(required_organ_flag && !(affected_organ.organ_flags & required_organ_flag))
		return FALSE
	if(affected_organ.damage == amount)
		return FALSE
	return affected_organ.set_organ_damage(amount)

/** getOrganLoss
  * inputs: slot (organ slot, like ORGAN_SLOT_HEART)
  * outputs: organ damage
  * description: If an organ exists in the slot requested, return the amount of damage that organ has
  */
/mob/living/carbon/getOrganLoss(slot)
	var/obj/item/organ/O = get_organ_slot(slot)
	if(O)
		return O.damage

////////////////////////////////////////////

//Returns a list of damaged bodyparts
/mob/living/carbon/proc/get_damaged_bodyparts(brute = FALSE, burn = FALSE, stamina = FALSE, status)
	var/list/obj/item/bodypart/parts = list()
	for(var/obj/item/bodypart/BP as() in bodyparts)
		if(status && !(BP.bodytype & status))
			continue
		if((brute && BP.brute_dam) || (burn && BP.burn_dam) || (stamina && BP.stamina_dam))
			parts += BP
	return parts

//Returns a list of damageable bodyparts
/mob/living/carbon/proc/get_damageable_bodyparts(required_bodytype)
	var/list/obj/item/bodypart/parts = list()
	for(var/obj/item/bodypart/BP as() in bodyparts)
		if(required_bodytype && !(BP.bodytype & required_bodytype))
			continue
		if(BP.brute_dam + BP.burn_dam < BP.max_damage)
			parts += BP
	return parts

/**
 * Heals ONE bodypart randomly selected from damaged ones.

 * It automatically updates damage overlays if necessary
 *
 * It automatically updates health status
 */
/mob/living/carbon/heal_bodypart_damage(brute = 0, burn = 0, stamina = 0, updating_health = TRUE, required_bodytype = NONE)
	var/list/obj/item/bodypart/parts = get_damaged_bodyparts(brute, burn, stamina, required_bodytype)
	if(!parts.len)
		return

	var/obj/item/bodypart/picked = pick(parts)
	var/damage_calculator = picked.get_damage(TRUE) //heal_damage returns update status T/F instead of amount healed so we dance gracefully around this
	if(picked.heal_damage(abs(brute), abs(burn), abs(stamina), required_bodytype = required_bodytype))
		update_damage_overlays()
	return max(damage_calculator - picked.get_damage(TRUE), 0)

/**
 * Damages ONE bodypart randomly selected from damagable ones.
 *
 * It automatically updates damage overlays if necessary
 *
 * It automatically updates health status
 */
/mob/living/carbon/take_bodypart_damage(brute = 0, burn = 0, stamina = 0, updating_health = TRUE, required_bodytype, check_armor = FALSE)
	var/list/obj/item/bodypart/parts = get_damageable_bodyparts(required_bodytype)
	if(!parts.len)
		return

	var/obj/item/bodypart/picked = pick(parts)
	var/damage_calculator = picked.get_damage(TRUE)
	if(picked.receive_damage(abs(brute), abs(burn), abs(stamina), check_armor ? run_armor_check(picked, (brute ? MELEE : burn ? FIRE : stamina ? STAMINA : null)) : FALSE))
		update_damage_overlays()
	return (damage_calculator - picked.get_damage(TRUE))

//Heal MANY bodyparts, in random order
/mob/living/carbon/heal_overall_damage(brute = 0, burn = 0, stamina = 0, required_bodytype, updating_health = TRUE, forced = FALSE)
	var/list/obj/item/bodypart/parts = get_damaged_bodyparts(brute, burn, stamina, required_bodytype)

	var/update = NONE
	while(parts.len && (brute > 0 || burn > 0 || stamina > 0))
		var/obj/item/bodypart/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam
		var/stamina_was = picked.stamina_dam

		update |= picked.heal_damage(brute, burn, stamina, updating_health = FALSE, forced = forced, required_bodytype = required_bodytype)

		brute = round(brute - (brute_was - picked.brute_dam), DAMAGE_PRECISION)
		burn = round(burn - (burn_was - picked.burn_dam), DAMAGE_PRECISION)
		stamina = round(stamina - (stamina_was - picked.stamina_dam), DAMAGE_PRECISION)

		parts -= picked

	if(updating_health)
		updatehealth()
		update_stamina(stamina >= DAMAGE_PRECISION)
	if(update)
		update_damage_overlays()

// damage MANY bodyparts, in random order
/mob/living/carbon/take_overall_damage(brute = 0, burn = 0, stamina = 0, updating_health = TRUE, forced = FALSE, required_bodytype)
	if(status_flags & GODMODE)
		return	//godmode

	var/list/obj/item/bodypart/parts = get_damageable_bodyparts(required_bodytype)
	var/update = 0
	while(parts.len && (brute > 0 || burn > 0 || stamina > 0))
		var/obj/item/bodypart/picked = pick(parts)
		var/brute_per_part = round(brute/parts.len, DAMAGE_PRECISION)
		var/burn_per_part = round(burn/parts.len, DAMAGE_PRECISION)
		var/stamina_per_part = round(stamina/parts.len, DAMAGE_PRECISION)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam
		var/stamina_was = picked.stamina_dam

		update |= picked.receive_damage(brute = brute_per_part, burn = burn_per_part, stamina = stamina_per_part, blocked = FALSE, updating_health = updating_health, required_bodytype = required_bodytype)

		brute = round(brute - (picked.brute_dam - brute_was), DAMAGE_PRECISION)
		burn = round(burn - (picked.burn_dam - burn_was), DAMAGE_PRECISION)
		stamina = round(stamina - (picked.stamina_dam - stamina_was), DAMAGE_PRECISION)

		parts -= picked

	if(updating_health)
		updatehealth()
	if(update)
		update_damage_overlays()
	update_stamina(stamina >= DAMAGE_PRECISION)
