///How much Blood it costs to live.
#define VAMPIRE_PASSIVE_BLOOD_DRAIN 0.1

/// Runs from COMSIG_LIVING_LIFE, handles Vampire constant proccesses.
/datum/antagonist/vampire/proc/LifeTick(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	if(isbrain(owner.current))
		return
	if(HAS_TRAIT(owner.current, TRAIT_NODEATH))
		check_end_torpor()
	// Deduct Blood
	if(owner.current.stat == CONSCIOUS && !HAS_TRAIT(owner.current, TRAIT_IMMOBILIZED) && !HAS_TRAIT(owner.current, TRAIT_NODEATH))
		INVOKE_ASYNC(src, PROC_REF(AddBloodVolume), -VAMPIRE_PASSIVE_BLOOD_DRAIN)
	if(handle_healing())
		if((COOLDOWN_FINISHED(src, vampire_spam_healing)) && vampire_blood_volume > 0)
			to_chat(owner.current, span_notice("The power of your blood knits your wounds..."))
			COOLDOWN_START(src, vampire_spam_healing, VAMPIRE_SPAM_HEALING)
	// Standard Updates
	SEND_SIGNAL(src, COMSIG_VAMPIRE_ON_LIFETICK)
	INVOKE_ASYNC(src, PROC_REF(handle_starving))
	INVOKE_ASYNC(src, PROC_REF(update_blood))

	INVOKE_ASYNC(src, PROC_REF(update_hud))

/**
 * ## BLOOD STUFF
 */
/datum/antagonist/vampire/proc/AddBloodVolume(value)
	vampire_blood_volume = clamp(vampire_blood_volume + value, 0, max_blood_volume)

/// mult: SILENT feed is 1/3 the amount
/datum/antagonist/vampire/proc/handle_feeding(mob/living/carbon/target, mult=1, power_level)
	// Starts at 15 (now 8 since we doubled the Feed time)
	var/feed_amount = 15 + (power_level * 2)
	var/blood_taken = min(feed_amount, target.blood_volume) * mult
	target.blood_volume -= blood_taken

	///////////
	// Shift Body Temp (toward Target's temp, by volume taken)
	owner.current.bodytemperature = ((vampire_blood_volume * owner.current.bodytemperature) + (blood_taken * target.bodytemperature)) / (vampire_blood_volume + blood_taken)
	// our volume * temp, + their volume * temp, / total volume
	///////////
	// Reduce Value Quantity
	if(target.stat == DEAD) // Penalty for Dead Blood
		blood_taken /= 3
	if(!ishuman(target)) // Penalty for Non-Human Blood
		blood_taken /= 2
	//if (!iscarbon(target)) // Penalty for Animals (they're junk food)
	// Apply to Volume
	AddBloodVolume(blood_taken)
	// Reagents (NOT Blood!)
	if(target.reagents?.total_volume)
		target.reagents.trans_to(owner.current, INGEST, 1) // Run transfer of 1 unit of reagent from them to me.
	owner.current.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, 1) // Play THIS sound for user only. The "null" is where turf would go if a location was needed. Null puts it right in their head.
	total_blood_drank += blood_taken
	return blood_taken

/*
* Runs on the vampire's lifetick.
* Heal clone damage, brain damage, brute and burn damage.
*
* By default, burn damage is healed 50% as much as brute
* When undergoing torpor it's 80%, if you're in a coffin 100%
*/

/// Constantly runs on Vampire's LifeTick, and is increased by being in Torpor/Coffins
/datum/antagonist/vampire/proc/handle_healing()
	var/in_torpor = is_in_torpor()

	// Weirdness shield
	if(QDELETED(owner?.current))
		return FALSE
	// Don't heal if  staked
	if(check_if_staked())
		return FALSE
	// Dont heal if you have TRAIT_MASQUERADE and not undergoing torpor
	if(!in_torpor && HAS_TRAIT(owner.current, TRAIT_MASQUERADE))
		return FALSE
	// No healing during sol, cry about it
	if(!in_torpor && (HAS_TRAIT(owner.current, TRAIT_MASQUERADE) || owner.current.has_status_effect(/datum/status_effect/vampire_sol)))
		return FALSE

	var/actual_regen = vampire_regen_rate + additional_regen

	// Heal clone and brain damage
	owner.current.adjustCloneLoss(-1 * (actual_regen * 4))
	owner.current.adjustOrganLoss(ORGAN_SLOT_BRAIN, -1 * (actual_regen * 4))

	if(!iscarbon(owner.current))
		return FALSE
	var/mob/living/carbon/user = owner.current

	var/bloodcost_multiplier = 1 // Coffin makes it cheaper
	var/healing_mulitplier = 1

	var/brute_heal = min(user.getBruteLoss(), actual_regen) * healing_mulitplier
	var/burn_heal = min(user.getFireLoss(), actual_regen) * 0.75 * healing_mulitplier

	if(in_torpor)
		// If in a coffin: heal 5x as fast, heal burn damage at full capacity, set bloodcost to 50%, and regenerate limbs
		// If not: heal 3x as fast and heal burn damage at 80%
		if(istype(user.loc, /obj/structure/closet/crate/coffin))
			if(HAS_TRAIT(owner.current, TRAIT_MASQUERADE) && (COOLDOWN_FINISHED(src, vampire_spam_healing)))
				to_chat(user, span_alert("You do not heal while your Masquerade ability is active."))
				COOLDOWN_START(src, vampire_spam_healing, VAMPIRE_SPAM_MASQUERADE)
				return FALSE

			burn_heal = min(user.getFireLoss(), actual_regen)
			healing_mulitplier = 5
			bloodcost_multiplier = 0.5 // Decrease cost if we're sleeping in a coffin.
			// Extinguish and remove embedded objects
			user.ExtinguishMob()
			user.remove_all_embedded_objects()
			if(try_regenerate_limbs(bloodcost_multiplier))
				return TRUE
		else
			burn_heal = min(user.getFireLoss(), actual_regen) * 0.8
			healing_mulitplier = 3

	// Heal if Damaged
	brute_heal *= healing_mulitplier
	burn_heal *= healing_mulitplier

	if(brute_heal > 0 || burn_heal > 0) // Just a check? Don't heal/spend, and return.
		var/bloodcost = (brute_heal * 0.5 + burn_heal) * bloodcost_multiplier * healing_mulitplier
		user.heal_overall_damage(brute_heal, burn_heal)
		AddBloodVolume(-bloodcost)
		return TRUE
	return FALSE

/datum/antagonist/vampire/proc/try_regenerate_limbs(cost_muliplier = 1)
	var/mob/living/carbon/user = owner.current
	var/limb_regen_cost = 50 * -cost_muliplier

	var/list/missing = user.get_missing_limbs()
	if(missing.len && (vampire_blood_volume < limb_regen_cost + 5))
		return FALSE
	for(var/missing_limb in missing) //Find ONE Limb and regenerate it.
		user.regenerate_limb(missing_limb, FALSE)
		if(missing_limb == BODY_ZONE_HEAD)
			ensure_brain_nonvital()
		AddBloodVolume(-limb_regen_cost)
		var/obj/item/bodypart/missing_bodypart = user.get_bodypart(missing_limb)
		missing_bodypart.brute_dam = 60
		to_chat(user, span_notice("Your flesh knits as it regrows your [missing_bodypart]!"))
		playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)
		return TRUE

/*
 *	# Heal Vampire Organs
 *
 *	This is used by Vampires, these are the steps of this proc:
 *	Step 1 - Cure husking and Regenerate organs. regenerate_organs() removes their Vampire Heart & Eye augments, which leads us to...
 *	Step 2 - Repair any (shouldn't be possible) Organ damage, then return their Vampiric Heart & Eye benefits.
 *	Step 3 - Revive them, clear all wounds, remove any Tumors (If any).
 *
 *	This is called on Vampire's Assign, and when they end Torpor.
 */

/datum/antagonist/vampire/proc/heal_vampire_organs()
	var/mob/living/carbon/user = owner.current

	user.cure_husk()
	user.regenerate_organs()

	for(var/obj/item/organ/organ as anything in user.internal_organs)
		organ.setOrganDamage(0)
	if(!HAS_TRAIT(user, TRAIT_MASQUERADE))
		var/obj/item/organ/heart/current_heart = user.get_organ_slot(ORGAN_SLOT_HEART)
		current_heart?.Stop()
	// Eyes
	var/obj/item/organ/eyes/current_eyes = user.get_organ_slot(ORGAN_SLOT_EYES)
	if(current_eyes)
		current_eyes.flash_protect = max(initial(current_eyes.flash_protect) - 1, - 1)
		current_eyes.sight_flags = SEE_MOBS
		current_eyes.see_in_dark = NIGHTVISION_FOV_RANGE
		current_eyes.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		user.update_sight()

	if(user.stat == DEAD)
		user.revive()
	// From 'panacea.dm'
	var/list/bad_organs = list(user.getorgan(/obj/item/organ/body_egg), user.getorgan(/obj/item/organ/zombie_infection))

	for(var/tumors in bad_organs)
		var/obj/item/organ/yucky_organs = tumors
		if(!istype(yucky_organs))
			continue
		yucky_organs.Remove(user)
		yucky_organs.forceMove(get_turf(user))

	user.adjustOxyLoss(-200)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//			DEATH

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/vampire/proc/on_death(mob/living/source, gibbed)
	SIGNAL_HANDLER

	if(source.stat != DEAD) // weirdness shield
		return

	RegisterSignal(owner.current, COMSIG_LIVING_REVIVE, PROC_REF(on_revive))
	RegisterSignal(src, COMSIG_VAMPIRE_ON_LIFETICK, PROC_REF(handle_death))

/datum/antagonist/vampire/proc/on_revive()
	SIGNAL_HANDLER

	UnregisterSignal(owner.current, COMSIG_LIVING_REVIVE)
	UnregisterSignal(src, COMSIG_VAMPIRE_ON_LIFETICK)

/datum/antagonist/vampire/proc/handle_death()
	var/static/handling_death = FALSE
	if(handling_death)
		return
	handling_death = TRUE
	do_handle_death()
	handling_death = FALSE

/// FINAL DEATH.
/// Don't call this directly, use handle_death().
/datum/antagonist/vampire/proc/do_handle_death()
	if(QDELETED(owner.current) || check_if_staked() || is_in_torpor())
		return

	to_chat(owner.current, span_userdanger("Your immortal body will not yet relinquish your soul to the abyss. You enter Torpor."))
	torpor_begin()

/datum/antagonist/vampire/proc/handle_starving() // I am thirsty for blood!
	// Nutrition - The amount of blood is how full we are.
	if(!isoozeling(owner.current))
		owner.current.set_nutrition(min(vampire_blood_volume, NUTRITION_LEVEL_FED))

	// BLOOD_VOLUME_GOOD: [336] - Pale
	// handled in vampire_integration.dm

	// BLOOD_VOLUME_EXIT: [250] - Exit Frenzy (If in one) This is high because we want enough to kill the poor soul they feed off of.
	if(vampire_blood_volume >= FRENZY_THRESHOLD_EXIT && frenzied)
		owner.current.remove_status_effect(/datum/status_effect/frenzy)
	// BLOOD_VOLUME_BAD: [224] - Jitter
	if(vampire_blood_volume < BLOOD_VOLUME_BAD && prob(0.5) && !HAS_TRAIT(owner.current, TRAIT_NODEATH) && !HAS_TRAIT(owner.current, TRAIT_MASQUERADE))
		owner.current.jitteriness = 3 SECONDS
	// BLOOD_VOLUME_SURVIVE: [122] - Blur Vision
	if(vampire_blood_volume < BLOOD_VOLUME_SURVIVE)
		owner.current.set_blurriness((8 - 8 * (vampire_blood_volume / BLOOD_VOLUME_BAD))*2 SECONDS)

	// The more blood, the better the Regeneration, get too low blood, and you enter Frenzy.
	if(vampire_blood_volume < FRENZY_THRESHOLD_ENTER && !frenzied)
		owner.current.apply_status_effect(/datum/status_effect/frenzy)
	else if(vampire_blood_volume < BLOOD_VOLUME_BAD)
		additional_regen = 0.1
	else if(vampire_blood_volume < BLOOD_VOLUME_OKAY)
		additional_regen = 0.2
	else if(vampire_blood_volume < BLOOD_VOLUME_NORMAL)
		additional_regen = 0.3
	else if(vampire_blood_volume < BS_BLOOD_VOLUME_MAX_REGEN)
		additional_regen = 0.4
	else
		additional_regen = 0.5

/// Makes your blood_volume look like your vampire blood, unless you're Masquerading.
/datum/antagonist/vampire/proc/update_blood()
	if(HAS_TRAIT(owner.current, TRAIT_NO_BLOOD))
		return
	//If we're on Masquerade, we appear to have full blood, unless we are REALLY low, in which case we don't look as bad.
	if(HAS_TRAIT(owner.current, TRAIT_MASQUERADE))
		switch(vampire_blood_volume)
			if(BLOOD_VOLUME_OKAY to INFINITY) // 336 and up, we are perfectly fine.
				owner.current.blood_volume = initial(vampire_blood_volume)
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY) // 224 to 336
				owner.current.blood_volume = BLOOD_VOLUME_SAFE
			else // 224 and below
				owner.current.blood_volume = BLOOD_VOLUME_OKAY
		return

	owner.current.blood_volume = vampire_blood_volume

#undef VAMPIRE_PASSIVE_BLOOD_DRAIN
