/// Runs from COMSIG_LIVING_LIFE, handles Vampire constant processes.
/datum/antagonist/vampire/proc/LifeTick(delta_time, times_fired)
	SIGNAL_HANDLER

	// Weirdness shield
	if(isbrain(owner?.current))
		return
	if(QDELETED(owner))
		INVOKE_ASYNC(src, PROC_REF(handle_death))
		return

	// Handle Torpor
	if(is_in_torpor())
		check_end_torpor()

	// Deduct Blood
	if(owner.current.stat == CONSCIOUS && !HAS_TRAIT(owner.current, TRAIT_IMMOBILIZED) && !HAS_TRAIT(owner.current, TRAIT_NODEATH))
		INVOKE_ASYNC(src, PROC_REF(AdjustBloodVolume), -VAMPIRE_PASSIVE_BLOOD_DRAIN)

	// Healing
	if(handle_healing() && !istype(owner, /mob/living/simple_animal/hostile))
		if((COOLDOWN_FINISHED(src, vampire_spam_healing)) && current_vitae > 0)
			to_chat(owner.current, span_notice("The power of your blood knits your wounds..."))
			COOLDOWN_START(src, vampire_spam_healing, VAMPIRE_SPAM_HEALING)

	var/area/current_area = get_area(owner.current)
	if(istype(current_area, /area/chapel) && humanity <= 2)
		to_chat(owner, span_warning("Your inhuman nature is rejected by a holy presence!"))
		owner.current.adjustFireLoss(10)
		owner.current.adjust_fire_stacks(4)
		owner.current.IgniteMob()

	// Standard Updates

	// Clan specific stuff
	if(my_clan)
		INVOKE_ASYNC(my_clan, TYPE_PROC_REF(/datum/vampire_clan, handle_clan_life))
	else
		INVOKE_ASYNC(src, PROC_REF(provide_clan_selector))

	// Handle blood
	INVOKE_ASYNC(src, PROC_REF(handle_blood), delta_time)

	// Set our body's blood_volume to mimick our vampire one (if we aren't using the Masquerade power)
	INVOKE_ASYNC(src, PROC_REF(update_blood))
	INVOKE_ASYNC(src, PROC_REF(update_hud))

/**
 * Assuming you aren't Masquerading and your species has blood
**/
/datum/antagonist/vampire/proc/update_blood()
	if(HAS_TRAIT(owner.current, TRAIT_NO_BLOOD))
		return

	if(HAS_TRAIT(owner.current, TRAIT_MASQUERADE))
		owner.current.blood_volume = BLOOD_VOLUME_NORMAL
		return

	owner.current.blood_volume = min(560, current_vitae)	// we want to get pale

/**
 * Pretty simple, add a value to the vampire's blood volume
**/
/datum/antagonist/vampire/proc/AdjustBloodVolume(value)
	current_vitae = clamp(current_vitae + value, 0, max_vitae)

/**
 * Runs on the vampire's lifetick.
 * Heal clone, brain, brute and burn damage.
 *
 * By default, burn damage is healed 50% as effectively as brute
 * When undergoing torpor it's 80%, if you're in a coffin 100%
**/
/datum/antagonist/vampire/proc/handle_healing()
	var/in_torpor = is_in_torpor()

	// Weirdness shield
	if(QDELETED(owner?.current))
		return FALSE
	// Dont heal if you have TRAIT_MASQUERADE and not undergoing torpor
	if(!in_torpor && HAS_TRAIT(owner.current, TRAIT_MASQUERADE))
		return FALSE
	// No healing during sol, cry about it
	if(!in_torpor && owner.current.has_status_effect(/datum/status_effect/vampire_sol))
		return FALSE

	var/actual_regen = vampire_regen_rate + additional_regen

	// Heal clone and brain damage
	owner.current.adjustCloneLoss(-1 * actual_regen * 4)
	owner.current.adjustOrganLoss(ORGAN_SLOT_BRAIN, -1 * (actual_regen * 4))

	if(!iscarbon(owner.current))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner.current

	var/vitaecost_multiplier = 1 // Coffin makes it cheaper
	var/healing_mulitplier = 1

	var/brute_heal = min(carbon_owner.getBruteLoss(), actual_regen) * healing_mulitplier
	var/burn_heal = min(carbon_owner.getFireLoss(), actual_regen) * 0.75 * healing_mulitplier

	carbon_owner.suppress_bloodloss(BLEED_TINY * healing_mulitplier)

	if(in_torpor)
		// If in a coffin: heal 5x as fast, heal burn damage at full capacity, set vitaecost to 50%, and regenerate limbs
		// If not: heal 3x as fast and heal burn damage at 80%
		if(istype(carbon_owner.loc, /obj/structure/closet/crate/coffin))
			if(HAS_TRAIT(owner.current, TRAIT_MASQUERADE) && (COOLDOWN_FINISHED(src, vampire_spam_healing)))
				to_chat(carbon_owner, span_alert("You do not heal while your Masquerade ability is active."))
				COOLDOWN_START(src, vampire_spam_healing, VAMPIRE_SPAM_MASQUERADE)
				return FALSE

			burn_heal = min(carbon_owner.getFireLoss(), actual_regen)
			healing_mulitplier = 5
			vitaecost_multiplier = 0.5 // Decrease cost if we're sleeping in a coffin.

			// Extinguish and remove embedded objects
			carbon_owner.ExtinguishMob()
			carbon_owner.remove_all_embedded_objects()

			if(try_regenerate_limbs(vitaecost_multiplier))
				return TRUE
		else
			burn_heal = min(carbon_owner.getFireLoss(), actual_regen) * 0.8
			healing_mulitplier = 3

	// Heal if Damaged
	brute_heal *= healing_mulitplier
	burn_heal *= healing_mulitplier

	if(brute_heal > 0 || burn_heal > 0) // Just a check? Don't heal/spend, and return.
		var/vitaecost = (brute_heal * 0.5 + burn_heal) * vitaecost_multiplier * healing_mulitplier
		carbon_owner.heal_overall_damage(brute_heal, burn_heal)
		AdjustBloodVolume(-vitaecost)
		return TRUE

	// Revive them if dead and there is no damage left to heal, just in case we are not in torpor because of some wackyness.
	// Note this doesn't revive when staked.
	if(carbon_owner.stat == DEAD && !in_torpor)
		heal_vampire_organs()
		return TRUE

	return FALSE

/datum/antagonist/vampire/proc/try_regenerate_limbs(cost_muliplier = 1)
	var/mob/living/carbon/carbon_owner = owner.current
	var/limb_regen_cost = 50 * -cost_muliplier

	var/list/missing = carbon_owner.get_missing_limbs()
	if(missing.len && (current_vitae < limb_regen_cost + 5))
		return FALSE
	for(var/missing_limb in missing) //Find ONE Limb and regenerate it.
		carbon_owner.regenerate_limb(missing_limb, FALSE)
		AdjustBloodVolume(-limb_regen_cost)
		var/obj/item/bodypart/missing_bodypart = carbon_owner.get_bodypart(missing_limb)
		missing_bodypart.brute_dam = 60
		to_chat(carbon_owner, span_notice("Your flesh knits as it regrows your [missing_bodypart]!"))
		playsound(carbon_owner, 'sound/magic/demon_consume.ogg', 50, TRUE)
		return TRUE

/**
 * This is used when exiting Torpor and when given vampire status, these are the steps of this proc:
 * Step 1 - Cure husking and Regenerate organs. regenerate_organs() removes their Vampire Heart & Eye augments, which leads us to...
 * Step 2 - Repair any (shouldn't be possible) Organ damage, then return their Vampiric Heart & Eye benefits.
 * Step 3 - Revive them, clear all wounds, remove any Tumors (If any).
**/
/datum/antagonist/vampire/proc/heal_vampire_organs()
	var/mob/living/carbon/carbon_user = owner.current
	if(!istype(carbon_user))
		return

	// Clear husk and regenerate organs
	carbon_user.cure_husk()
	carbon_user.regenerate_organs()

	// Heal organs
	for(var/obj/item/organ/organ as anything in carbon_user.internal_organs)
		organ.set_organ_damage(0)

	// Heart
	if(!HAS_TRAIT(carbon_user, TRAIT_MASQUERADE))
		var/obj/item/organ/heart/current_heart = carbon_user.get_organ_slot(ORGAN_SLOT_HEART)
		current_heart?.Stop()

	// Eyes
	var/obj/item/organ/eyes/current_eyes = carbon_user.get_organ_slot(ORGAN_SLOT_EYES)
	if(current_eyes)
		current_eyes.flash_protect = max(initial(current_eyes.flash_protect) - 1, - 1)
		current_eyes.sight_flags = SEE_MOBS
		current_eyes.see_in_dark = NIGHTVISION_FOV_RANGE
		current_eyes.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		carbon_user.update_sight()

	// Get rid of icky organs. From `panacea.dm`
	var/list/bad_organs = list(
		carbon_user.get_organ_by_type(/obj/item/organ/body_egg),
		carbon_user.get_organ_by_type(/obj/item/organ/zombie_infection),
	)
	for(var/obj/item/organ/bad_organ as anything in bad_organs)
		var/obj/item/organ/yucky_organ = bad_organ
		if(!istype(yucky_organ))
			continue

		yucky_organ.Remove(carbon_user)
		yucky_organ.forceMove(get_turf(carbon_user))

	// Don't Revive if staked
	if(!check_if_staked())
		if(carbon_user.stat == DEAD)
			carbon_user.revive()
			// Heal suffocation
			carbon_user.setOxyLoss(0)

/**
 * Called when we die
**/
/datum/antagonist/vampire/proc/on_death(mob/living/source, gibbed)
	SIGNAL_HANDLER

	if(source.stat != DEAD) // weirdness shield
		return

	INVOKE_ASYNC(src, PROC_REF(handle_death))

/datum/antagonist/vampire/proc/handle_death()
	if(QDELETED(owner.current) || check_if_staked() || is_in_torpor())
		return

	// Fire Damage? (above double health)
	if(owner.current.getFireLoss() >= (owner.current.maxHealth * 2.5))
		final_death()
		return

	torpor_begin()

/**
 * Handle things related to blood
 *
 * Step 1 - Set nutrition to our blood level
 * Step 2 - If we are in a frenzy, check if we have enough blood to exit it
 * Step 3 - If we have too little blood, enter a frenzy
 * Step 4 - If we're low on blood, start jittering
 * Step 5 - Set regeneration rate based off how much blood we have
**/
/datum/antagonist/vampire/proc/handle_blood(delta_time)
	// Set nutrition
	if(!isoozeling(owner.current))
		owner.current.set_nutrition(min(current_vitae, NUTRITION_LEVEL_WELL_FED))

	// Try and exit frenzy
	if(current_vitae >= FRENZY_THRESHOLD_EXIT && frenzied)
		owner.current.remove_status_effect(/datum/status_effect/frenzy)

	// Blood is low, lets show some effects
	if(current_vitae < 100 && !HAS_TRAIT(owner.current, TRAIT_MASQUERADE))
		owner.current.set_jitter_if_lower(6 SECONDS)

	// Enter frenzy if our blood is low enough
	if(current_vitae < FRENZY_THRESHOLD_ENTER && !frenzied)
		owner.current.apply_status_effect(/datum/status_effect/frenzy)

	// Warn them at low blood
	if(current_vitae < VAMPIRE_LOW_BLOOD_WARNING && !low_blood_alerted)
		owner.current.playsound_local(null, 'sound/vampires/bloodneed.ogg', 100, FALSE, pressure_affected = FALSE)
		to_chat(owner.current, span_narsiesmall("Care now. Your vitae runs low!"), type = MESSAGE_TYPE_WARNING)
		low_blood_alerted = TRUE
	else if(current_vitae > VAMPIRE_LOW_BLOOD_WARNING)
		low_blood_alerted = FALSE

	// The more blood, the better the regeneration
	if(current_vitae < BLOOD_VOLUME_BAD)
		additional_regen = 0.1
	else if(current_vitae < BLOOD_VOLUME_OKAY)
		additional_regen = 0.2
	else if(current_vitae < BLOOD_VOLUME_NORMAL)
		additional_regen = 0.3
	else if(current_vitae < BS_BLOOD_VOLUME_MAX_REGEN)
		additional_regen = 0.4
	else
		additional_regen = 0.5

/// dust
/datum/antagonist/vampire/proc/final_death(skip_destruction = FALSE)
	var/mob/living/body = owner.current
	// If we have no body, end here.
	if(QDELETED(body))
		return

	UnregisterSignal(body, list(
		COMSIG_LIVING_LIFE,
		COMSIG_ATOM_EXAMINE,
		COMSIG_LIVING_DEATH,
		COMSIG_MOVABLE_MOVED,
	))

	final_death = TRUE
	free_all_vassals()

	if(!skip_destruction)
		if(iscarbon(body))
			// Drop anything in us and play a tune
			var/mob/living/carbon/carbon_body = body
			carbon_body.drop_all_held_items()
			carbon_body.unequip_everything()
			carbon_body.remove_all_embedded_objects()
			playsound(owner.current, 'sound/vampires/burning_death.ogg', 80, TRUE)
		else
			body.dust(drop_items = TRUE)

	if(SEND_SIGNAL(src, COMSIG_VAMPIRE_FINAL_DEATH) & DONT_DUST)
		return

	if(skip_destruction || QDELETED(body))
		return

	// Get dusted lmao
	body.visible_message(
		span_warning("[body]'s skin crackles and dries, [body.p_their()] skin and bones withering to dust. A hollow cry whips from what is now a sandy pile of remains."),
		span_userdanger("Your soul escapes your withering body as the abyss welcomes you to your Final Death."),
		span_hear("You hear a dry, crackling sound.")
	)
	addtimer(CALLBACK(body, TYPE_PROC_REF(/mob/living, dust)), 5 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)
