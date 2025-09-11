//These procs fetch a cumulative total damage from all bodyparts
/mob/living/carbon/getBruteLoss()
	var/amount = 0
	for(var/obj/item/bodypart/BP as() in bodyparts)
		var/datum/injury/injury = BP.get_injury_by_base(/datum/injury/brute)
		if (injury)
			amount += injury.progression
	return amount

/mob/living/carbon/getFireLoss()
	var/amount = 0
	for(var/obj/item/bodypart/BP as() in bodyparts)
		var/datum/injury/injury = BP.get_injury_by_base(/datum/injury/burn)
		if (injury)
			amount += injury.progression
	return amount


/mob/living/carbon/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE, required_status)
	if(!forced && HAS_TRAIT(src, TRAIT_GODMODE))
		return FALSE
	if(amount > 0)
		take_overall_damage(amount, 0, 0, updating_health, required_status)
	else
		if(!required_status)
			required_status = forced ? null : BODYTYPE_ORGANIC
		heal_overall_damage(abs(amount), 0, 0, required_status, updating_health)
	return amount

/mob/living/carbon/setBruteLoss(amount, updating_health = TRUE, forced = FALSE)
	var/current = getBruteLoss()
	var/diff = amount - current
	if(!diff)
		return
	adjustBruteLoss(diff, updating_health, forced)

/mob/living/carbon/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE, required_status)
	if(!forced && HAS_TRAIT(src, TRAIT_GODMODE))
		return FALSE
	if(amount > 0)
		take_overall_damage(0, amount, 0, updating_health, required_status)
	else
		if(!required_status)
			required_status = forced ? null : BODYTYPE_ORGANIC
		heal_overall_damage(0, abs(amount), 0, required_status, updating_health)
	return amount

/mob/living/carbon/setFireLoss(amount, updating_health = TRUE, forced = FALSE)
	var/current = getFireLoss()
	var/diff = amount - current
	if(!diff)
		return
	adjustFireLoss(diff, updating_health, forced)

/mob/living/carbon/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && HAS_TRAIT(src, TRAIT_TOXINLOVER)) //damage becomes healing and healing becomes damage
		amount = -amount
		if(amount > 0)
			blood.volume -= 5*amount
		else
			blood.volume -= amount
	if(HAS_TRAIT(src, TRAIT_TOXIMMUNE)) //Prevents toxin damage, but not healing
		amount = min(amount, 0)
	return ..()

/mob/living/carbon/getExhaustion()
	return exhaustion

/mob/living/carbon/adjustExhaustion(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && HAS_TRAIT(src, TRAIT_GODMODE))
		return FALSE
	exhaustion += amount
	return amount

/mob/living/carbon/setStaminaLoss(amount, updating_health = TRUE, forced = FALSE)
	var/current = getExhaustion()
	var/diff = amount - current
	if(!diff)
		return
	adjustExhaustion(diff, updating_health, forced)

/** adjustOrganLoss
  * inputs: slot (organ slot, like ORGAN_SLOT_HEART), amount (damage to be done), and maximum (currently an arbitrarily large number, can be set so as to limit damage)
  * outputs:
  * description: If an organ exists in the slot requested, and we are capable of taking damage (we don't have GODMODE on), call the damage proc on that organ.
  */
/mob/living/carbon/adjustOrganLoss(slot, amount, maximum, required_status)
	var/obj/item/organ/O = get_organ_slot(slot)
	if(O && !HAS_TRAIT(src, TRAIT_GODMODE))
		if(required_status && O.status != required_status)
			return FALSE
		O.applyOrganDamage(amount, maximum)

/** setOrganLoss
  * inputs: slot (organ slot, like ORGAN_SLOT_HEART), amount(damage to be set to)
  * outputs:
  * description: If an organ exists in the slot requested, and we are capable of taking damage (we don't have GODMODE on), call the set damage proc on that organ, which can
  *				 set or clear the failing variable on that organ, making it either cease or start functions again, unlike adjustOrganLoss.
  */
/mob/living/carbon/setOrganLoss(slot, amount)
	var/obj/item/organ/O = get_organ_slot(slot)
	if(O && !HAS_TRAIT(src, TRAIT_GODMODE))
		O.set_organ_damage(amount)

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

/// Returns a list of damaged bodyparts
/// required_injury: The typepath of the injury that we are scanning for, or the base typepath of an injury tree.
/// Lists are also supported.
/// status: The required status of the bodypart
/mob/living/carbon/proc/get_injured_bodyparts(required_injury = null, status = null)
	var/list/obj/item/bodypart/parts = list()
	for(var/obj/item/bodypart/BP as() in bodyparts)
		if(status && !(BP.bodytype & status))
			continue
		if (islist(required_injury))
			for (var/injury_path in required_injury)
				if (BP.get_injury_by_base(required_injury))
					parts += BP
					break
		else if (required_injury)
			if (BP.get_injury_by_base(required_injury))
				parts += BP
		else
			if (BP.accumulated_damage > 0)
				parts += BP
	return parts

//Returns a list of damageable bodyparts
/mob/living/carbon/proc/get_damageable_bodyparts(status)
	var/list/obj/item/bodypart/parts = list()
	for(var/obj/item/bodypart/BP as() in bodyparts)
		if(status && !(BP.bodytype & status))
			continue
		if (!BP.destroyed)
			parts += BP
	return parts

//Heals ONE bodypart randomly selected from damaged ones.
//It automatically updates damage overlays if necessary
//It automatically updates health status
/mob/living/carbon/heal_bodypart_injuries(injury, amount, required_status, updating_health = TRUE)
	var/list/obj/item/bodypart/parts = get_injured_bodyparts(injury, required_status)
	if(!parts.len)
		return
	var/obj/item/bodypart/picked = pick(parts)
	var/damage_calculator = picked.get_damage(TRUE) //heal_damage returns update status T/F instead of amount healed so we dance gracefully around this
	picked.heal_injury(injury, amount, required_status, updating_health)
	return max(damage_calculator - picked.get_damage(TRUE), 0)

//Damages ONE bodypart randomly selected from damagable ones.
//It automatically updates damage overlays if necessary
//It automatically updates health status
/mob/living/carbon/take_bodypart_damage(brute = 0, burn = 0, stamina = 0, updating_health = TRUE, required_status)
	var/list/obj/item/bodypart/parts = get_damageable_bodyparts(required_status)
	if(!parts.len)
		return
	var/obj/item/bodypart/picked = pick(parts)
	if(picked.receive_damage(brute, burn, stamina))
		update_damage_overlays()

//Heal MANY bodyparts, in random order
/mob/living/carbon/heal_overall_damage(brute = 0, burn = 0, stamina = 0, required_status, updating_health = TRUE)
	var/list/obj/item/bodypart/parts = get_damaged_bodypartsa(brute, burn, stamina, required_status)

	var/update = NONE
	while(parts.len && (brute > 0 || burn > 0 || stamina > 0))
		var/obj/item/bodypart/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam
		var/stamina_was = picked.stamina_dam

		update |= picked.heal_damage(brute, burn, stamina, required_status, FALSE)

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
/mob/living/carbon/take_overall_damage(brute = 0, burn = 0, stamina = 0, updating_health = TRUE, required_status)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return	//godmode

	var/list/obj/item/bodypart/parts = get_damageable_bodyparts(required_status)
	var/update = 0
	while(parts.len && (brute > 0 || burn > 0 || stamina > 0))
		var/obj/item/bodypart/picked = pick(parts)
		var/brute_per_part = round(brute/parts.len, DAMAGE_PRECISION)
		var/burn_per_part = round(burn/parts.len, DAMAGE_PRECISION)
		var/stamina_per_part = round(stamina/parts.len, DAMAGE_PRECISION)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam
		var/stamina_was = picked.stamina_dam


		update |= picked.receive_damage(brute_per_part, burn_per_part, stamina_per_part, FALSE, required_status)

		brute	= round(brute - (picked.brute_dam - brute_was), DAMAGE_PRECISION)
		burn	= round(burn - (picked.burn_dam - burn_was), DAMAGE_PRECISION)
		stamina = round(stamina - (picked.stamina_dam - stamina_was), DAMAGE_PRECISION)

		parts -= picked
	if(updating_health)
		updatehealth()
	if(update)
		update_damage_overlays()
	update_stamina(stamina >= DAMAGE_PRECISION)
