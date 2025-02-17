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
	INVOKE_ASYNC(src, PROC_REF(HandleStarving))
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
	if(target.reagents && target.reagents.total_volume)
		target.reagents.trans_to(owner.current, INGEST, 1) // Run transfer of 1 unit of reagent from them to me.
	owner.current.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, 1) // Play THIS sound for user only. The "null" is where turf would go if a location was needed. Null puts it right in their head.
	total_blood_drank += blood_taken
	return blood_taken

/**
 * ## HEALING
 */

/// Constantly runs on Vampire's LifeTick, and is increased by being in Torpor/Coffins
/datum/antagonist/vampire/proc/handle_healing(mult = 1)
	if(QDELETED(owner?.current))
		return
	var/in_torpor = is_in_torpor()
	// Don't heal if I'm staked or on Masquerade (+ not in a Coffin). Masqueraded Vampires in a Coffin however, will heal.
	if(check_staked())
		return FALSE
	if(!in_torpor && HAS_TRAIT(owner.current, TRAIT_MASQUERADE))
		return FALSE
	var/actual_regen = vampire_regen_rate + additional_regen
	owner.current.adjustCloneLoss(-1 * (actual_regen * 4) * mult)
	owner.current.adjustOrganLoss(ORGAN_SLOT_BRAIN, -1 * (actual_regen * 4) * mult) //adjustBrainLoss(-1 * (actual_regen * 4) * mult, 0)
	if(!iscarbon(owner.current)) // Damage Heal: Do I have damage to ANY bodypart?
		return
	var/mob/living/carbon/user = owner.current
	var/costMult = 1 // Coffin makes it cheaper
	var/bruteheal = min(user.getBruteLoss(), actual_regen) // BRUTE: Always Heal
	var/fireheal = 0 // BURN: Heal in Coffin while Fakedeath, or when damage above maxhealth (you can never fully heal fire)
	// Checks if you're in torpor here, additionally checks if you're in a coffin right below it.
	if(in_torpor)
		if(istype(user.loc, /obj/structure/closet/crate/coffin))
			if(HAS_TRAIT(owner.current, TRAIT_MASQUERADE) && (COOLDOWN_FINISHED(src, vampire_spam_healing)))
				to_chat(user, span_alert("You do not heal while your Masquerade ability is active."))
				COOLDOWN_START(src, vampire_spam_healing, VAMPIRE_SPAM_MASQUERADE)
				return
			fireheal = min(user.getFireLoss(), actual_regen)
			mult *= 5 // Increase multiplier if we're sleeping in a coffin.
			costMult /= 2 // Decrease cost if we're sleeping in a coffin.
			user.ExtinguishMob()
			user.remove_all_embedded_objects() // Remove Embedded!
			if(check_limbs(costMult))
				return TRUE
		// In Torpor, but not in a Coffin? Heal faster anyways.
		else
			fireheal = min(user.getFireLoss(), actual_regen) / 1.2 // 20% slower than being in a coffin
			mult *= 3
	// Heal if Damaged
	if((bruteheal + fireheal > 0) && mult > 0) // Just a check? Don't heal/spend, and return.
		// We have damage. Let's heal (one time)
		user.heal_overall_damage(brute = bruteheal * mult, burn = fireheal * mult) // Heal BRUTE / BURN in random portions throughout the body.
		AddBloodVolume(((bruteheal * -0.5) + (fireheal * -1)) * costMult * mult) // Costs blood to heal
		return TRUE

/datum/antagonist/vampire/proc/check_limbs(costMult = 1)
	var/limb_regen_cost = 50 * -costMult
	var/mob/living/carbon/user = owner.current
	var/list/missing = user.get_missing_limbs()
	if(missing.len && (vampire_blood_volume < limb_regen_cost + 5))
		return FALSE
	for(var/missing_limb in missing) //Find ONE Limb and regenerate it.
		user.regenerate_limb(missing_limb, FALSE)
		if(missing_limb == BODY_ZONE_HEAD)
			ensure_brain_nonvital()
		AddBloodVolume(-limb_regen_cost)
		var/obj/item/bodypart/missing_bodypart = user.get_bodypart(missing_limb) // 2) Limb returns Damaged
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
	current_eyes?.flash_protect = max(initial(current_eyes.flash_protect) - 1, - 1)
	current_eyes?.sight_flags = SEE_MOBS
	current_eyes?.see_in_dark = NIGHTVISION_FOV_RANGE
	current_eyes?.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	user.update_sight()

	if(user.stat == DEAD)
		user.revive()
	// From [powers/panacea.dm]
	var/list/bad_organs = list(
		user.getorgan(/obj/item/organ/body_egg),
		user.getorgan(/obj/item/organ/zombie_infection))
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
	if(gibbed)
		INVOKE_ASYNC(src, PROC_REF(final_death))
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
	// Not "Alive"?
	if(QDELETED(owner.current))
		final_death()
		return
	// Fire Damage? (above double health)
	if(owner.current.getFireLoss() >= (owner.current.maxHealth * 2.5))
		final_death()
		return
	// Staked while "Temp Death" or Asleep
	if(can_stake_kill() && check_staked())
		final_death()
		return
	// Temporary Death? Convert to Torpor.
	if(is_in_torpor())
		return
	to_chat(owner.current, span_userdanger("Your immortal body will not yet relinquish your soul to the abyss. You enter Torpor."))
	check_begin_torpor(TRUE)

/datum/antagonist/vampire/proc/HandleStarving() // I am thirsty for blood!
	// Nutrition - The amount of blood is how full we are.
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

/// Gibs the Vampire, roundremoving them.
/datum/antagonist/vampire/proc/final_death()
	if(has_succumb_to_final_death)
		return
	has_succumb_to_final_death = TRUE

	var/mob/living/carbon/user = owner.current

	// Free vassals
	for(var/datum/antagonist/vassal/vassal in vassals)
		if(vassal.special_type == REVENGE_VASSAL)
			continue
		var/datum/antagonist/ex_vassal/ex_vassal = new()
		ex_vassal.vampire_team = vampire_team
		vassal.owner.add_antag_datum(ex_vassal)

		vassal.owner.remove_antag_datum(/datum/antagonist/vassal)

	// If we have no body, end here.
	if(!user)
		return
	UnregisterSignal(src, list(
		COMSIG_VAMPIRE_ON_LIFETICK,
		COMSIG_LIVING_REVIVE,
		COMSIG_LIVING_LIFE,
		COMSIG_LIVING_DEATH,
	))
	UnregisterSignal(SSsunlight, list(
		COMSIG_SOL_RANKUP_VAMPIRES,
		COMSIG_SOL_NEAR_START,
		COMSIG_SOL_END,
		COMSIG_SOL_RISE_TICK,
		COMSIG_SOL_WARNING_GIVEN,
	))

	DisableAllPowers(forced = TRUE)
	if(!iscarbon(user))
		user.gib(TRUE, FALSE, FALSE)
		return
	// Drop anything in us and play a tune
	user.drop_all_held_items()
	user.unequip_everything()
	user.remove_all_embedded_objects()
	playsound(user, 'sound/effects/tendril_destroyed.ogg', 40, TRUE)

	var/unique_death = SEND_SIGNAL(src, VAMPIRE_FINAL_DEATH)
	if(unique_death & DONT_DUST)
		return

	// Elders get dusted, Fledglings get gibbed.
	if(vampire_level >= 4)
		user.visible_message(
			span_warning("[user]'s skin crackles and dries, their skin and bones withering to dust. A hollow cry whips from what is now a sandy pile of remains."),
			span_userdanger("Your soul escapes your withering body as the abyss welcomes you to your Final Death."),
			span_hear("You hear a dry, crackling sound."),
		)
		addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, dust)), 5 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)
		return

	user.visible_message(
		span_warning("[user]'s skin bursts forth in a spray of gore and detritus. A horrible cry echoes from what is now a wet pile of decaying meat."),
		span_userdanger("Your soul escapes your withering body as the abyss welcomes you to your Final Death."),
		span_hear("<span class='italics'>You hear a wet, bursting sound."),
	)
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, gib), TRUE, FALSE, FALSE), 2 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)

#undef VAMPIRE_PASSIVE_BLOOD_DRAIN
