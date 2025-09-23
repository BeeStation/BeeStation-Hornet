

/mob/living/carbon/apply_damage(
	damage = 0,
	damagetype = BRUTE,
	def_zone = null,
	blocked = FALSE,
	forced = FALSE,
	spread_damage = FALSE,
	sharpness = NONE,
	attack_direction = null,
)
	// Spread damage should always have def zone be null
	if(spread_damage)
		def_zone = null

	// Otherwise if def zone is null, we'll get a random bodypart / zone to hit.
	// ALso we'll automatically covnert string def zones into bodyparts to pass into parent call.
	else if(!isbodypart(def_zone))
		var/random_zone = check_zone(def_zone || get_random_valid_zone(def_zone))
		def_zone = get_bodypart(random_zone) || bodyparts[1]

	. = ..()
	// Taking brute or burn to bodyparts gives a damage flash
	if(def_zone && (damagetype == BRUTE || damagetype == BURN))
		damageoverlaytemp += .

	return .

/mob/living/carbon/human/apply_damage(
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

	// depending on the species, it will run the corresponding apply_damage code there
	if(stat != DEAD && (damagetype==BRUTE || damagetype==BURN) && damage>10 && prob(10+damage/2))
		INVOKE_ASYNC(src, PROC_REF(emote), "scream")
	// Add relevant DR modifiers into blocked value to pass to parent
	blocked += physiology?.damage_resistance
	blocked += dna?.species?.damage_modifier
	return ..()

/mob/living/carbon/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	if(excess_healing)
		if(dna && !HAS_TRAIT(src, TRAIT_NOBLOOD))
			blood_volume += (excess_healing * 2) //1 excess = 10 blood

		for(var/obj/item/organ/target_organ as anything in organs)
			if(!target_organ.damage)
				continue

			target_organ.apply_organ_damage(excess_healing * -1, required_organ_flag = ORGAN_ORGANIC) //1 excess = 5 organ damage healed

	return ..()

/mob/living/carbon/human/get_incoming_damage_modifier(
	damage = 0,
	damagetype = BRUTE,
	def_zone = null,
	sharpness = NONE,
	attack_direction = null,
	attacking_item,
)
	var/final_mod = ..()

	switch(damagetype)
		if(BRUTE)
			final_mod *= physiology.brute_mod
		if(BURN)
			final_mod *= physiology.burn_mod
		if(TOX)
			final_mod *= physiology.tox_mod
		if(OXY)
			final_mod *= physiology.oxy_mod
		if(CLONE)
			final_mod *= physiology.clone_mod
		if(STAMINA)
			final_mod *= physiology.stamina_mod
		if(BRAIN)
			final_mod *= physiology.brain_mod

	return final_mod


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
	if(!can_adjust_brute_loss(amount, forced, required_bodytype))
		return 0
	if(amount > 0)
		. = take_overall_damage(brute = amount, updating_health = updating_health, forced = forced, required_bodytype = required_bodytype)
	else
		if(!required_bodytype)
			required_bodytype = forced ? null : BODYTYPE_ORGANIC
		. = heal_overall_damage(brute = abs(amount), required_bodytype = required_bodytype, updating_health = updating_health, forced = forced)

/mob/living/carbon/setBruteLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	if(!forced && HAS_TRAIT(src, TRAIT_GODMODE))
		return FALSE
	var/current = getBruteLoss()
	var/diff = amount - current
	if(!diff)
		return FALSE
	return adjustBruteLoss(diff, updating_health, forced, required_bodytype)

/mob/living/carbon/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	if(!can_adjust_fire_loss(amount, forced, required_bodytype))
		return 0
	if(amount > 0)
		. = take_overall_damage(burn = amount, updating_health = updating_health, forced = forced, required_bodytype = required_bodytype)
	else
		if(!required_bodytype)
			required_bodytype = forced ? null : BODYTYPE_ORGANIC
		. = heal_overall_damage(burn = abs(amount), required_bodytype = required_bodytype, updating_health = updating_health, forced = forced)

/mob/living/carbon/setFireLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	if(!forced && HAS_TRAIT(src, TRAIT_GODMODE))
		return FALSE
	var/current = getFireLoss()
	var/diff = amount - current
	if(!diff)
		return FALSE
	return adjustFireLoss(diff, updating_health, forced, required_bodytype)

/mob/living/carbon/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype = ALL)
	if(!can_adjust_tox_loss(amount, forced, required_biotype))
		return 0
	if(!forced && HAS_TRAIT(src, TRAIT_TOXINLOVER)) //damage becomes healing and healing becomes damage
		amount = -amount
		if(HAS_TRAIT(src, TRAIT_TOXIMMUNE)) //Prevents toxin damage, but not healing
			amount = min(amount, 0)
		if(amount > 0)
			blood_volume = max(blood_volume - (5*amount), 0)
		else
			blood_volume = max(blood_volume - amount, 0)
	else if(!forced && HAS_TRAIT(src, TRAIT_TOXIMMUNE)) //Prevents toxin damage, but not healing
		amount = min(amount, 0)
	return ..()

/mob/living/carbon/getStaminaLoss()
	. = 0
	for(var/obj/item/bodypart/BP as anything in bodyparts)
		. += round(BP.stamina_dam * BP.stam_damage_coeff, DAMAGE_PRECISION)

/mob/living/carbon/adjustStaminaLoss(amount, updating_stamina = TRUE, forced = FALSE, required_biotype)
	if(!forced && HAS_TRAIT(src, TRAIT_GODMODE))
		return FALSE
	if(amount > 0)
		. = take_overall_damage(stamina = amount, updating_health = updating_stamina)
	else
		. = heal_overall_damage(0, 0, abs(amount), null, updating_stamina)

/mob/living/carbon/setStaminaLoss(amount, updating_stamina = TRUE, forced = FALSE, required_biotype)
	if(!forced && HAS_TRAIT(src, TRAIT_GODMODE))
		return FALSE
	var/current = getStaminaLoss()
	var/diff = amount - current
	if(!diff)
		return FALSE
	return adjustStaminaLoss(diff, updating_stamina, forced, required_biotype)

/** adjustOrganLoss
* * slot - organ slot, like [ORGAN_SLOT_HEART]
* * amount - damage to be done
 * * maximum - currently an arbitrarily large number, can be set so as to limit damage
 * * required_organ_flag - targets only a specific organ type if set to ORGAN_ORGANIC or ORGAN_ROBOTIC
 *
 * Returns: The net change in damage from apply_organ_damage()
 */
/mob/living/carbon/adjustOrganLoss(slot, amount, maximum = INFINITY, required_organ_flag = NONE)
	var/obj/item/organ/affected_organ = get_organ_slot(slot)
	if(!affected_organ || HAS_TRAIT(src, TRAIT_GODMODE))
		return FALSE
	if(required_organ_flag && !(affected_organ.organ_flags & required_organ_flag))
		return FALSE
	return affected_organ.apply_organ_damage(amount, maximum)

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
	if(!affected_organ || HAS_TRAIT(src, TRAIT_GODMODE))
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
	. = FALSE
	var/list/obj/item/bodypart/parts = get_damaged_bodyparts(brute, burn, stamina, required_bodytype)
	if(!parts.len)
		return

	var/obj/item/bodypart/picked = pick(parts)
	var/damage_calculator = picked.get_damage(TRUE) //heal_damage returns update status T/F instead of amount healed so we dance gracefully around this
	if(picked.heal_damage(abs(brute), abs(burn), abs(stamina), required_bodytype = required_bodytype))
		update_damage_overlays()
	return (damage_calculator - picked.get_damage(TRUE))

/**
 * Damages ONE bodypart randomly selected from damagable ones.
 *
 * It automatically updates damage overlays if necessary
 *
 * It automatically updates health status
 */
/mob/living/carbon/take_bodypart_damage(brute = 0, burn = 0, stamina = 0, updating_health = TRUE, required_bodytype, check_armor = FALSE)
	. = FALSE
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	var/list/obj/item/bodypart/parts = get_damageable_bodyparts(required_bodytype)
	if(!parts.len)
		return

	var/obj/item/bodypart/picked = pick(parts)
	var/damage_calculator = picked.get_damage(TRUE)
	if(picked.receive_damage(abs(brute), abs(burn), abs(stamina), check_armor ? run_armor_check(picked, (brute ? MELEE : burn ? FIRE : stamina ? STAMINA : null)) : FALSE))
		update_damage_overlays()
	return (damage_calculator - picked.get_damage(TRUE))

/mob/living/carbon/heal_overall_damage(brute = 0, burn = 0, stamina = 0, required_bodytype, updating_health = TRUE, forced = FALSE)
	. = FALSE
	// treat negative args as positive
	brute = abs(brute)
	burn = abs(burn)
	stamina = abs(stamina)
	var/list/obj/item/bodypart/parts = get_damaged_bodyparts(brute, burn, stamina, required_bodytype)

	var/update = NONE
	while(parts.len && (brute > 0 || burn > 0 || stamina > 0))
		var/obj/item/bodypart/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam
		var/stamina_was = picked.stamina_dam
		. += picked.get_damage(TRUE)

		update |= picked.heal_damage(brute, burn, stamina, updating_health = FALSE, forced = forced, required_bodytype = required_bodytype)

		. -= picked.get_damage(TRUE) // return the net amount of damage healed

		brute = round(brute - (brute_was - picked.brute_dam), DAMAGE_PRECISION)
		burn = round(burn - (burn_was - picked.burn_dam), DAMAGE_PRECISION)
		stamina = round(stamina - (stamina_was - picked.stamina_dam), DAMAGE_PRECISION)

		parts -= picked

	if(!.) // no change? no need to update anything
		return

	if(updating_health)
		updatehealth()
		update_stamina(stamina >= DAMAGE_PRECISION)
	if(update)
		update_damage_overlays()

/mob/living/carbon/take_overall_damage(brute = 0, burn = 0, stamina = 0, updating_health = TRUE, forced = FALSE, required_bodytype)
	. = FALSE
	if(!forced && HAS_TRAIT(src, TRAIT_GODMODE))
		return
	// treat negative args as positive
	brute = abs(brute)
	burn = abs(burn)
	stamina = abs(stamina)

	var/list/obj/item/bodypart/parts = get_damageable_bodyparts(required_bodytype)
	var/update = NONE
	while(parts.len && (brute > 0 || burn > 0 || stamina > 0))
		var/obj/item/bodypart/picked = pick(parts)
		var/brute_per_part = round(brute/parts.len, DAMAGE_PRECISION)
		var/burn_per_part = round(burn/parts.len, DAMAGE_PRECISION)
		var/stamina_per_part = round(stamina/parts.len, DAMAGE_PRECISION)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam
		var/stamina_was = picked.stamina_dam
		. += picked.get_damage(TRUE)

		update |= picked.receive_damage(brute = brute_per_part, burn = burn_per_part, stamina = stamina_per_part, blocked = FALSE, updating_health = FALSE, forced = forced, required_bodytype = required_bodytype)

		. -= picked.get_damage(TRUE) // return the net amount of damage healed

		brute = round(brute - (picked.brute_dam - brute_was), DAMAGE_PRECISION)
		burn = round(burn - (picked.burn_dam - burn_was), DAMAGE_PRECISION)
		stamina = round(stamina - (picked.stamina_dam - stamina_was), DAMAGE_PRECISION)

		parts -= picked

	if(!.) // no change? no need to update anything
		return

	if(updating_health)
		updatehealth()
	if(update)
		update_damage_overlays()
	update_stamina(stamina >= DAMAGE_PRECISION)
