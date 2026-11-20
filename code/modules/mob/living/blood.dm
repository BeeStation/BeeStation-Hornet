#define BLOOD_DRIP_RATE_MOD 90 //Greater number means creating blood drips more often while bleeding

/****************************************************
				BLOOD SYSTEM

https://www.desmos.com/calculator/vxrevmdvfx

To calculate the blood loss rate, use the following formula:
n = starting amount of blood in your mob
b = bleed rate of your mob
h = Rate at which bleeding decreases over time (0.02 constant, 0.08 for non-human mobs)

This function calculates the amount of blood left in your system at time x
q\left(x\right)=\left\{b<2.4:ne^{-\frac{1}{560}\left(bx-\frac{1}{2}x^{2}h\right)},ne^{-\frac{bx}{560}}\right\}

Hide this function
d\left(x\right)=\max\left(0,120-\frac{\left(120\cdot\max\left(0,\min\left(1,\frac{x-122}{560-122}\right)\right)\right)^{0.3}}{\left(120\right)^{-0.7}}\right)

This function calculates the amount of health that your mob has at time x
y=d\left(q\left(x\right)\right)

**Notes for porting/search:**
bleedsuppress has been replaced for is_bandaged(). Note that is_bleeding() returns if you are not bleeding, even if you have active bandages.

****************************************************/

/datum/status_effect/bleeding
	id = "bleeding"
	status_type = STATUS_EFFECT_MERGE
	alert_type = /atom/movable/screen/alert/status_effect/bleeding
	tick_interval = 0.2 SECONDS

	var/bandaged_bleeding = 0
	var/bleed_rate = 0
	var/time_applied = 0
	var/bleed_heal_multiplier = 1
	COOLDOWN_DECLARE(spray_cooldown)

/datum/status_effect/bleeding/merge(bleed_level)
	src.bleed_rate = src.bleed_rate + max(min(bleed_level * bleed_level, sqrt(bleed_level)) / max(src.bleed_rate, 1), bleed_level - src.bleed_rate)
	update_shown_duration()

/datum/status_effect/bleeding/on_creation(mob/living/new_owner, bleed_rate)
	src.bleed_rate = bleed_rate
	return ..()

/datum/status_effect/bleeding/tick(seconds_between_ticks)
	if (HAS_TRAIT(owner, TRAIT_NO_BLOOD))
		qdel(src)
		return

	time_applied += seconds_between_ticks SECONDS

	var/should_process = time_applied >= 1 SECONDS
	if (!should_process)
		// For heavy bleeding, leave drops if we are standing.
		// If we are lying down, allow the trail to form
		// This doesn't actually cause you to lose blood any faster
		if (bleed_rate > BLEED_RATE_MINOR && owner.body_position == STANDING_UP && !HAS_TRAIT(owner, TRAIT_BLEED_HELD))
			owner.add_splatter_floor(owner.loc, TRUE)
		return
	time_applied = 0
	// Non-humans stop bleeding a lot quicker, even if it is not a minor cut
	if (!ishuman(owner))
		bleed_rate -= BLEED_HEAL_RATE_MINOR * 4 * bleed_heal_multiplier
	// Reduce the actual rate of bleeding
	if (ishuman(owner))
		if (bleed_rate > 0 && bleed_rate < BLEED_RATE_MINOR)
			bleed_rate -= BLEED_HEAL_RATE_MINOR * bleed_heal_multiplier
		else
			bandaged_bleeding -= BLEED_HEAL_RATE_MINOR * bleed_heal_multiplier
	// We have finished bleeding
	if (bleed_rate <= 0 && bandaged_bleeding <= 0)
		qdel(src)
		return
	// The actual rate of bleeding, can be reduced by holding wounds
	var/final_bleed_rate = bleed_rate
	if (HAS_TRAIT(owner, TRAIT_BLEED_HELD))
		final_bleed_rate = max(0, final_bleed_rate - BLEED_RATE_MINOR)
	// We aren't actually bleeding
	if (final_bleed_rate <= 0)
		update_shown_duration()
		return
	// Actually do the bleeding
	owner.bleed(min(MAX_BLEED_RATE, final_bleed_rate))
	var/mob/living/carbon/carbon_owner = owner
	var/pumping = owner.stat != DEAD && owner.get_blood_volume() >= BLOOD_VOLUME_BAD && !(istype(carbon_owner) && carbon_owner.undergoing_cardiac_arrest())
	if(pumping && final_bleed_rate >= BLEED_CRITICAL && COOLDOWN_FINISHED(src, spray_cooldown) && owner.spray_blood(pick(GLOB.alldirs), 2))
		COOLDOWN_START(src, spray_cooldown, 8 SECONDS)
		owner.visible_message(span_danger("Blood sprays out of [owner]'s wounds!"), span_userdanger("Blood sprays out of your wounds!"))
	// Update the alert to show current bleed rate
	update_shown_duration()

/datum/status_effect/bleeding/update_shown_duration()
	if(QDELETED(owner))
		stack_trace("Tried to update bleeding icon [src] on deleted mob")
		return
	// The actual rate of bleeding, can be reduced by holding wounds
	// Calculate the message to show to the user
	if (HAS_TRAIT(owner, TRAIT_BLEED_HELD))
		linked_alert.name = "Bleeding (Held)"
		if (bleed_rate > BLEED_RATE_MINOR)
			linked_alert.desc = "You have serious wounds which are unlikely to heal themselves. You are applying pressure to them, slowing the rate of blood loss."
		else
			linked_alert.desc = "You are bleeding and are applying pressure to the wounds, preventing blood from pouring out."
		linked_alert.icon_state = "bleed_held"
	else if (bleed_rate == 0 && bandaged_bleeding > 0)
		linked_alert.name = "Bleeding (Bandaged)"
		linked_alert.desc = "You have bandages covering your wounds. They will heal slowly if they are not cauterized."
		linked_alert.icon_state = "bleed_bandage"
	else
		if (bleed_rate < BLEED_RATE_MINOR)
			linked_alert.name = "Bleeding (Light)"
			linked_alert.desc = "You have some minor cuts that look like they will heal themselves if you don't run out of blood first.[ishuman(owner) ? " Click to apply pressure to the wounds." : ""]"
			linked_alert.icon_state = "bleed"
		else
			linked_alert.name = "Bleeding (Heavy)"
			linked_alert.desc = "Your wounds are bleeding heavily and are unlikely to heal themselves. Seek medical attention immediately![ishuman(owner) ? " Click to apply pressure to the wounds." : ""]"
			linked_alert.icon_state = "bleed_heavy"

	if (HAS_TRAIT(owner, TRAIT_NO_BLEEDING) || HAS_TRAIT(owner, TRAIT_STASIS))
		linked_alert.maptext = MAPTEXT("<s>[owner.get_bleed_rate_string()]</s>")
	else
		linked_alert.maptext = MAPTEXT(owner.get_bleed_rate_string())

/datum/status_effect/bleeding/on_remove()
	var/mob/living/carbon/human/human = owner
	if (!istype(human))
		return
	// Not bleeding anymore, no need to hold wounds
	human.stop_holding_wounds()

/atom/movable/screen/alert/status_effect/bleeding
	name = "Bleeding"
	desc = "You are bleeding, find something to bandage the wound or you will die."
	icon_state = "bleed"
	clickable_glow = TRUE

/atom/movable/screen/alert/status_effect/bleeding/Click(location, control, params)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/human/human_owner = owner

	if (locate(/obj/item/offhand/bleeding_suppress) in human_owner.held_items)
		human_owner.stop_holding_wounds()
	else
		human_owner.hold_wounds()

/mob/living/carbon/proc/is_bandaged()
	if (HAS_TRAIT(src, TRAIT_NO_BLOOD))
		return FALSE
	var/datum/status_effect/bleeding/bleed = has_status_effect(/datum/status_effect/bleeding)
	if (!bleed)
		return FALSE
	return bleed.bandaged_bleeding > 0

/mob/living/carbon/proc/is_bleeding()
	if(!CAN_HAVE_BLOOD(src))
		return FALSE
	var/datum/status_effect/bleeding/bleed = has_status_effect(/datum/status_effect/bleeding)
	if (!bleed)
		return FALSE
	return bleed.bleed_rate > 0

/mob/living/carbon/proc/add_bleeding(bleed_level, sound_effect = TRUE)
	if (HAS_TRAIT(src, TRAIT_NO_BLOOD))
		return
	if(sound_effect)
		playsound(src, 'sound/surgery/blood_wound.ogg', 80, vary = TRUE)
	apply_status_effect(dna?.species?.bleed_effect || /datum/status_effect/bleeding, bleed_level)
	if (bleed_level >= BLEED_DEEP_WOUND)
		set_eye_blur_if_lower(2 SECONDS)
		var/datum/reagent/blood = get_blood_reagent() //Not every race has "BLOOD" rushing from the wound
		if(blood)
			to_chat(src, span_userdanger("[initial(blood.name)] starts rushing out of the open wound!"))

/mob/living/carbon/human/add_bleeding(bleed_level)
	if(HAS_TRAIT(src, TRAIT_NOBLOOD))
		return
	..()

/mob/living/carbon/proc/get_bleed_intensity()
	var/datum/status_effect/bleeding/bleed = has_status_effect(/datum/status_effect/bleeding)
	if (!bleed)
		return 0
	return 3 ** bleed.bleed_rate

/// A helper to see how much blood we're losing per tick
/mob/living/proc/get_bleed_rate()
	return 0

/mob/living/carbon/get_bleed_rate()
	if(HAS_TRAIT(src, TRAIT_GODMODE) || !can_bleed())
		return 0

	var/datum/status_effect/bleeding/bleed = has_status_effect(/datum/status_effect/bleeding)
	if(!bleed)
		return 0
	return bleed.bleed_rate

/// Can we heal bleeding using a welding tool?
/mob/living/carbon/proc/has_mechanical_bleeding()
	var/obj/item/bodypart/chest = get_bodypart(BODY_ZONE_CHEST)
	return chest.bodytype & BODYTYPE_ROBOTIC

/mob/living/proc/get_bleed_rate_string()
	return "0.0/s"

/mob/living/carbon/get_bleed_rate_string()
	var/datum/status_effect/bleeding/bleed = has_status_effect(/datum/status_effect/bleeding)
	if (!bleed)
		return "0.0/s"
	var/final_bleed_rate = bleed.bleed_rate
	if (HAS_TRAIT(src, TRAIT_BLEED_HELD))
		final_bleed_rate = max(0, final_bleed_rate - BLEED_RATE_MINOR)

	// Set the text to the final bleed rate
	final_bleed_rate = round(final_bleed_rate, 0.1)
	if ((final_bleed_rate * 10) % 10 == 0)
		return "[final_bleed_rate].0/s"
	return "[final_bleed_rate]/s"

/mob/living/carbon/proc/cauterise_wounds(amount = INFINITY)
	var/datum/status_effect/bleeding/bleed = has_status_effect(/datum/status_effect/bleeding)
	if (!bleed)
		return FALSE
	bleed.bleed_rate -= amount
	if (bleed.bleed_rate <= 0)
		remove_status_effect(/datum/status_effect/bleeding)
	return TRUE

/mob/living/carbon/proc/hold_wounds()
	if (stat >= UNCONSCIOUS)
		return
	if (!is_bleeding())
		if (is_bandaged())
			balloon_alert(src, "Wounds already bandaged!")
		else
			balloon_alert(src, "You are not wounded!")
		return
	if (locate(/obj/item/offhand/bleeding_suppress) in held_items)
		balloon_alert(src, "Already applying pressure!")
		return
	if (has_active_hand() && get_active_held_item())
		balloon_alert(src, "Active hand is full!")
		return
	var/obj/item/offhand/bleeding_suppress/supressed_thing = new()
	put_in_active_hand(supressed_thing)
	balloon_alert(src, "You apply pressure to your wounds...")
	var/datum/status_effect/bleeding/bleed = has_status_effect(/datum/status_effect/bleeding)
	if (!bleed)
		return
	bleed.update_shown_duration()

/mob/living/carbon/proc/stop_holding_wounds()
	var/located = FALSE
	for (var/obj/item/offhand/bleeding_suppress/bleed_suppression in held_items)
		qdel(bleed_suppression)
		located = TRUE
	if (located)
		balloon_alert(src, "You stop applying pressure to your wounds...")
	var/datum/status_effect/bleeding/bleed = has_status_effect(/datum/status_effect/bleeding)
	if (!bleed)
		return
	bleed.update_shown_duration()

/mob/living/carbon/proc/suppress_bloodloss(amount)
	var/datum/status_effect/bleeding/bleed = has_status_effect(/datum/status_effect/bleeding)
	if (!bleed)
		return
	var/reduced_amount = min(bleed.bleed_rate, amount)
	bleed.bleed_rate -= reduced_amount
	bleed.bandaged_bleeding += reduced_amount
	bleed.update_shown_duration()
	if (bleed.bleed_rate <= 0)
		stop_holding_wounds()

/mob/living/carbon/monkey/handle_blood()
	if(bodytemperature < TCRYO || HAS_TRAIT(src, TRAIT_HUSK)) //cryosleep or husked people do not pump the blood.
		return
	adjust_blood_volume(0.1, maximum = BLOOD_VOLUME_NORMAL) // regenerate blood VERY slowly
	var/modified_blood_volume = get_blood_volume(apply_modifiers = TRUE)
	if(modified_blood_volume < BLOOD_VOLUME_OKAY)
		adjustOxyLoss(round((BLOOD_VOLUME_NORMAL - modified_blood_volume) * 0.02, 1))

/// Returns whether this mob can have blood.
/// Use the CAN_HAVE_BLOOD(mob) macro instead, this is used to update the cached value.
/mob/living/proc/can_have_blood()
	return default_blood_volume > 0

/mob/living/carbon/can_have_blood()
	return !HAS_TRAIT(src, TRAIT_NOBLOOD)

/// Returns the blood volume of the mob.
/// Apply modifiers when reading blood volume for oxyloss damage, HUDs and analyzers.
/// Don't apply modifiers when using blood itself, like in spells and reagent transfers.
/mob/living/proc/get_blood_volume(apply_modifiers = FALSE)
	return CAN_HAVE_BLOOD(src) ? blood_volume : 0 // Overriding blood setting code can cause blood_volume to be non-zero even when a mob shouldn't have blood.

/mob/living/carbon/get_blood_volume(apply_modifiers = FALSE)
	if (!CAN_HAVE_BLOOD(src))
		return 0 // Overriding blood setting code can cause blood_volume to be non-zero even when a mob shouldn't have blood.
	if (!apply_modifiers)
		return blood_volume // Default behavior, returns the real blood volume.
	if (HAS_TRAIT(src, TRAIT_GODMODE))
		return default_blood_volume // Makes TRAIT_GODMODE grant immunity to the effects of bleeding. (oxyloss, passing out, etc.)

	var/amount = blood_volume

	// Handled here instead of in the saline reagent datum, because this way the modification order is consistent.
	// E.g. if you have an effect that modifies blood volume over the dilution cap, then saline should do nothing.
	var/datum/reagent/medicine/salglu_solution/saline = reagents?.has_reagent(/datum/reagent/medicine/salglu_solution)
	if (saline && amount < saline.dilution_cap)
		var/datum/blood_type/blood_type = get_bloodtype()
		if (blood_type?.restoration_chem == saline.required_restoration_chem)
			amount = min(amount + saline.volume * saline.dilution_per_unit, BLOOD_VOLUME_NORMAL)

	return amount

/// Sets the base blood volume of the mob, returns the blood volume of the mob after.
/mob/living/proc/set_blood_volume(amount, minimum = 0, maximum = BLOOD_VOLUME_MAXIMUM, cached_blood_volume = null)
	if (!isnum(cached_blood_volume))
		cached_blood_volume = get_blood_volume()

	if (!CAN_HAVE_BLOOD(src) && amount != 0)
		return cached_blood_volume

	// Don't return early even if "amount == cached_blood_volume", because we don't know if minimum or maximum would change it anyway.
	// Putting this here because I made that mistake and it led to a bug.

	blood_volume = clamp(amount, minimum, maximum)

	var/updated_blood_volume = get_blood_volume()

	if (cached_blood_volume != updated_blood_volume)
		living_flags |= QUEUE_BLOOD_UPDATE

	return updated_blood_volume

/// Adjusts the base blood volume of the mob and returns the change.
/// Increases in blood volume give a positive return value and vice versa.
/// Maximum only applies on positive amounts and vice versa.
/mob/living/proc/adjust_blood_volume(amount, minimum = 0, maximum = BLOOD_VOLUME_MAXIMUM)
	if (!CAN_HAVE_BLOOD(src) || amount == 0)
		return 0

	var/cached_blood_volume = get_blood_volume()

	if (amount < 0)
		if (cached_blood_volume <= minimum)
			// Already at or below the minimum, don't decrease further.
			return 0
		// Decreases shouldn't jump the pre-existing value to the maximum.
		maximum = INFINITY
	else
		if (cached_blood_volume >= maximum)
			// Already at or above the maximum, don't increase further.
			return 0
		// Increases shouldn't jump the pre-existing value to the minimum.
		minimum = -INFINITY

	var/updated_blood_volume = set_blood_volume(cached_blood_volume + amount, minimum = minimum, maximum = maximum, cached_blood_volume = cached_blood_volume)
	return updated_blood_volume - cached_blood_volume

/// Updates effects that rely on blood volume, like blood HUDs.
/mob/living/proc/update_blood_effects()
	living_flags &= ~QUEUE_BLOOD_UPDATE

/// Updates effects that rely on whether the mob can have blood.
/mob/living/proc/update_blood_status()
	var/had_blood = CAN_HAVE_BLOOD(src)

	living_flags = can_have_blood() ? (living_flags | LIVING_CAN_HAVE_BLOOD) : (living_flags & ~LIVING_CAN_HAVE_BLOOD)

	var/has_blood = CAN_HAVE_BLOOD(src)

	if (had_blood == has_blood)
		return

	var/old_blood_volume = get_blood_volume()

	set_blood_volume(has_blood ? default_blood_volume : 0)

	var/new_blood_volume = get_blood_volume()

	SEND_SIGNAL(src, COMSIG_LIVING_UPDATE_BLOOD_STATUS, had_blood, has_blood, old_blood_volume, new_blood_volume)

// Takes care blood loss and regeneration
/mob/living/carbon/human/handle_blood(delta_time, times_fired)
	if(mind && IS_VAMPIRE(src)) // vampires should not be affected by blood
		return

	if(!CAN_HAVE_BLOOD(src) || HAS_TRAIT(src, TRAIT_NO_BLOOD))
		cauterise_wounds()
		return

	if(bodytemperature < TCRYO || HAS_TRAIT(src, TRAIT_HUSK)) //cryosleep or husked people do not pump the blood.
		return

	//Blood regeneration if there is some space
	if(!is_bleeding() && get_blood_volume() < BLOOD_VOLUME_NORMAL && !HAS_TRAIT(src, TRAIT_NOHUNGER) && !HAS_TRAIT(src, TRAIT_BLOOD_COOLANT))
		var/nutrition_ratio = 0
		switch(nutrition)
			if(0 to NUTRITION_LEVEL_STARVING)
				nutrition_ratio = 0.2
			if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
				nutrition_ratio = 0.4
			if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
				nutrition_ratio = 0.6
			if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
				nutrition_ratio = 0.8
			else
				nutrition_ratio = 1
		if(satiety > SATIETY_WELL_NOURISHED)
			nutrition_ratio *= 1.25
		var/blood_to_restore = BLOOD_REGEN_FACTOR * nutrition_ratio * delta_time
		var/blood_restored = adjust_blood_volume(blood_to_restore, maximum = BLOOD_VOLUME_NORMAL)
		if(blood_restored > 0)
			adjust_nutrition(-nutrition_ratio * HUNGER_FACTOR * delta_time * (blood_restored / blood_to_restore))

	// Takes into account modifiers like saline-glucose solution in the blood
	var/modified_blood_volume = get_blood_volume(apply_modifiers = TRUE)

	//Effects of bloodloss
	var/word = pick("dizzy","woozy","faint")

	// How much oxyloss we want to be on
	var/desired_damage = (getMaxHealth() * 1.2) * CLAMP01((modified_blood_volume - BLOOD_VOLUME_SURVIVE) / (BLOOD_VOLUME_NORMAL - BLOOD_VOLUME_SURVIVE))
	// Make it so we only go unconcious at 25% blood remaining
	desired_damage = max(0, (getMaxHealth() * 1.2) - ((desired_damage ** 0.3) / ((getMaxHealth() * 1.2) ** (-0.7))))
	if (desired_damage >= getMaxHealth() * 1.2)
		desired_damage = getMaxHealth() * 2.0
	if (HAS_TRAIT(src, TRAIT_BLOOD_COOLANT))
		switch(modified_blood_volume)
			if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_SAFE)
				if(prob(3))
					to_chat(src, span_warning("Your sensors indicate [pick("overheating", "thermal throttling", "coolant issues")]."))
			if(-INFINITY to BLOOD_VOLUME_SURVIVE)
				desired_damage = getMaxHealth() * 2.0
				// Rapidly die with no saving you
				adjustFireLoss(clamp(getMaxHealth() * 2.0 - getFireLoss(), 0, 10))
		var/health_difference = clamp(desired_damage - getFireLoss(), 0, 5)
		adjustFireLoss(health_difference)
		return
	switch(modified_blood_volume)
		if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
			if(DT_PROB(2.5, delta_time))
				to_chat(src, span_warning("You feel [word]."))
		if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
			if(DT_PROB(2.5, delta_time))
				set_eye_blur_if_lower(12 SECONDS)
				to_chat(src, span_warning("You feel very [word]."))
		if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
			if(DT_PROB(15, delta_time))
				set_eye_blur_if_lower(12 SECONDS)
				Unconscious(rand(3,6))
				to_chat(src, span_warning("You feel extremely [word]."))
		if(-INFINITY to BLOOD_VOLUME_SURVIVE)
			desired_damage = getMaxHealth() * 2.0
			// Rapidly die with no saving you
			adjustOxyLoss(clamp(getMaxHealth() * 2.0 - getOxyLoss(), 0, 10))
	var/health_difference = clamp(desired_damage - getOxyLoss(), 0, 5)
	adjustOxyLoss(health_difference)

/// Bleeds amount units of blood from the mob, sometimes creating a blood splatter on the floor.
/mob/living/proc/bleed(amount)
	if(HAS_TRAIT(src, TRAIT_GODMODE) || !can_bleed())
		return

	var/amount_bled = -adjust_blood_volume(-amount)

	// Blood loss still happens in locker, floor stays clean
	if(isturf(loc) && prob(sqrt(amount_bled) * BLOOD_DRIP_RATE_MOD))
		add_splatter_floor(loc, TRUE)

/mob/living/carbon/bleed(amount)
	if(HAS_TRAIT(src, TRAIT_GODMODE) || !can_bleed() || HAS_TRAIT(src, TRAIT_NO_BLEEDING) || HAS_TRAIT(src, TRAIT_STASIS))
		return
	var/cached_blood_volume = get_blood_volume()
	if(!cached_blood_volume)
		return
	// As you get less bloodloss, you bleed slower
	// See the top of this file for desmos lines
	var/decrease_multiplier = BLEED_RATE_MULTIPLIER
	var/obj/item/organ/heart/heart = get_organ_slot(ORGAN_SLOT_HEART)
	if (!heart || !heart.beating || src.stat == DEAD)
		decrease_multiplier = BLEED_RATE_MULTIPLIER_NO_HEART
	var/blood_loss_amount = cached_blood_volume - cached_blood_volume * NUM_E ** (-(amount * decrease_multiplier) / BLOOD_VOLUME_NORMAL)
	var/amount_bled = -adjust_blood_volume(-blood_loss_amount)
	// Blood loss still happens in locker, floor stays clean
	if(isturf(loc) && prob(sqrt(amount_bled) * BLOOD_DRIP_RATE_MOD))
		add_splatter_floor(loc, amount_bled < 2)

/mob/living/carbon/human/bleed(amount)
	amount *= physiology.bleed_mod
	return ..()

/mob/living/proc/restore_blood()
	set_blood_volume(default_blood_volume)

/mob/living/carbon/human/restore_blood()
	. = ..()
	cauterise_wounds()

/****************************************************
				BLOOD TRANSFERS
****************************************************/

// Transfers blood from mob to a container or another mob, preserving all data in it.
// Returns how much blood was able to be transferred.
/mob/living/proc/transfer_blood_to(atom/movable/receiver, amount, ignore_low_blood = FALSE, ignore_incompatibility = FALSE, transfer_viruses = TRUE)
	var/cached_blood_volume = get_blood_volume()

	if(!cached_blood_volume || !receiver.reagents || amount <= 0)
		return 0

	if(cached_blood_volume < BLOOD_VOLUME_BAD && !ignore_low_blood)
		return 0

	var/datum/blood_type/blood_type = get_bloodtype()
	if (!blood_type)
		return 0

	var/blood_reagent = get_blood_reagent()
	var/list/blood_data = get_blood_data()

	// Caps the amount to how much blood we have.
	amount = min(amount, get_blood_volume())

	if (!ignore_low_blood)
		// Caps the amount to how much we can transfer before reaching low blood.
		amount = min(amount, get_blood_volume() - BLOOD_VOLUME_BAD)

	var/mob/living/target = receiver
	if (!isliving(receiver) || target.get_blood_reagent() != blood_reagent)
		// Further caps the amount to how much blood we were able to add to the target.
		amount = receiver.reagents.add_reagent(blood_reagent, amount, blood_data, bodytemperature, creation_callback = CALLBACK(src, PROC_REF(on_blood_created), blood_type))
		adjust_blood_volume(-amount)
		return amount

	if(blood_data["viruses"] && transfer_viruses)
		for(var/datum/disease/blood_disease as anything in blood_data["viruses"])
			if((blood_disease.spread_flags & DISEASE_SPREAD_SPECIAL) || (blood_disease.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS))
				continue
			target.ForceContractDisease(blood_disease)

	if(!ignore_incompatibility && !(blood_type.type_key() in target.get_bloodtype().compatible_types))
		// Yes, we cap it to the amount of toxin. This is ridiculously niche, but we do it anyway.
		amount = target.reagents.add_reagent(/datum/reagent/toxin, amount * 0.5) * 2
		adjust_blood_volume(-amount)
		return amount

	// And, obviously, cap it to how much blood the target can take if they're living.
	amount = target.adjust_blood_volume(amount)
	adjust_blood_volume(-amount)
	return amount

/// Callback that adds blood_reagent to any blood extracted from ourselves
/mob/living/proc/on_blood_created(datum/blood_type/blood_type, datum/reagent/new_blood)
	new_blood.AddElement(/datum/element/blood_reagent, src, blood_type)

/mob/living/proc/get_blood_data()
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)

	var/datum/blood_type/blood_type = get_bloodtype()
	if (!blood_type || !can_bleed())
		return

	var/blood_data = list()
	blood_data["blood_type"] = blood_type
	blood_data["blood_DNA"] = blood_type.dna_string

	if (reagents)
		var/list/temp_chem = list()
		for(var/datum/reagent/blood_reagent in reagents.reagent_list)
			temp_chem[blood_reagent.type] = blood_reagent.volume
		blood_data["trace_chem"] = list2params(temp_chem)

	if (blood_type.blood_flags & BLOOD_TRANSFER_VIRAL_DATA)
		blood_data["viruses"] = list()
		for(var/datum/disease/disease as anything in diseases)
			blood_data["viruses"] += disease.Copy()

		if(LAZYLEN(disease_resistances))
			blood_data["resistances"] = disease_resistances.Copy()

	// DNA, mind, factions, etc don't get stored in stuff like oil
	if (!(blood_type.blood_flags & BLOOD_ADD_DNA))
		return blood_data

	if(mind)
		blood_data["mind"] = mind

	if(ckey)
		blood_data["ckey"] = ckey

	blood_data["factions"] = faction
	return blood_data

/mob/living/carbon/get_blood_data()
	var/list/blood_data = ..()
	if (!blood_data)
		return

	var/datum/blood_type/blood_type = get_bloodtype()
	if (!(blood_type.blood_flags & BLOOD_ADD_DNA))
		return blood_data

	if(!suiciding)
		blood_data["cloneable"] = TRUE

	if (!blood_data["mind"] && last_mind)
		blood_data["mind"] = last_mind

	if (!blood_data["ckey"] && last_mind)
		blood_data["ckey"] = ckey(last_mind.key)

	blood_data["gender"] = gender
	blood_data["real_name"] = real_name
	if (dna)
		blood_data["blood_DNA"] = dna.unique_enzymes
		blood_data["features"] = dna.features

	return blood_data

/mob/living/proc/get_bloodtype()
	RETURN_TYPE(/datum/blood_type)
	if (!CAN_HAVE_BLOOD(src))
		return

	if (!(mob_biotypes & MOB_ORGANIC))
		if (mob_biotypes & MOB_ROBOTIC)
			return get_blood_type(BLOOD_TYPE_OIL)
		return

	if (mob_biotypes & MOB_REPTILE)
		return get_blood_type(BLOOD_TYPE_LIZARD)
	else if (mob_biotypes & MOB_HUMANOID)
		// O+ as to avoid mobs bleeding all human bloodtypes under the sun, and its statistically the most common one
		return get_blood_type(BLOOD_TYPE_O_PLUS)

	return get_blood_type(BLOOD_TYPE_ANIMAL)

/mob/living/carbon/get_bloodtype()
	RETURN_TYPE(/datum/blood_type)
	if(!CAN_HAVE_BLOOD(src))
		return
	return dna?.blood_type

/// Returns the reagent type this mob has for blood
/mob/living/proc/get_blood_reagent()
	if (!can_bleed())
		return

	var/datum/blood_type/blood_type = get_bloodtype()
	return blood_type?.reagent_type

/// Check if a mob can bleed, and possibly if they're capable of leaving decals on turfs/mobs/items
/mob/living/proc/can_bleed(bleed_flag = NONE)
	if (!CAN_HAVE_BLOOD(src) || HAS_TRAIT(src, TRAIT_NO_BLOOD))
		return BLEED_NONE

	if (!bleed_flag)
		return BLEED_SPLATTER

	var/datum/blood_type/blood_type = get_bloodtype()
	if (!blood_type)
		return BLEED_NONE

	if (blood_type.blood_flags & bleed_flag)
		return BLEED_SPLATTER

	if (blood_type.blood_flags & BLOOD_ADD_DNA)
		return BLEED_ADD_DNA

	return BLEED_NONE

/// Goes through the organs and bodyparts of the mob and updates their blood_dna_info, in case their blood type has changed (via set_species() or otherwise)
/mob/living/carbon/proc/update_cached_blood_dna_info()
	var/list/blood_dna_info = get_blood_dna_list()
	for(var/obj/item/organ/organ as anything in internal_organs)
		organ.blood_dna_info = blood_dna_info

/// Setter for changing a mob's blood type
/mob/living/carbon/proc/set_blood_type(datum/blood_type/new_blood_type, update_cached_blood_dna_info = TRUE)
	SHOULD_CALL_PARENT(TRUE)

	if(isnull(dna))
		return

	if(istext(new_blood_type))
		new_blood_type = get_blood_type(new_blood_type)
	if(!istype(new_blood_type))
		return

	if(get_bloodtype() == new_blood_type)
		return

	dna.blood_type = new_blood_type
	if(update_cached_blood_dna_info)
		update_cached_blood_dna_info()

/// Returns the blood_type datum that corresponds to the string id key in GLOB.blood_types
/proc/get_blood_type(id)
	RETURN_TYPE(/datum/blood_type)
	return GLOB.blood_types[id]

/// Returns one of the human blood types at random, weighted by their rarity
/proc/random_human_blood_type()
	RETURN_TYPE(/datum/blood_type)
	return get_blood_type(pick_weight(list(
		BLOOD_TYPE_O_MINUS = 4,
		BLOOD_TYPE_O_PLUS = 36,
		BLOOD_TYPE_A_MINUS = 3,
		BLOOD_TYPE_A_PLUS = 28,
		BLOOD_TYPE_B_MINUS = 1,
		BLOOD_TYPE_B_PLUS = 20,
		BLOOD_TYPE_AB_MINUS = 1,
		BLOOD_TYPE_AB_PLUS = 5,
	)))

/// Returns the hex color string of a given blood_type datum given an assoc list of blood_DNA e.g. ("Unknown Blood Type", "*X")
/proc/get_color_from_blood_list(list/blood_DNA)
	var/datum/blood_type/blood_type
	if(!length(blood_DNA))
		return get_blood_type(BLOOD_TYPE_O_PLUS).get_color()
	else if (length(blood_DNA) == 1) // Microop for when we don't need to do color mixing
		blood_type = blood_DNA[blood_DNA[length(blood_DNA)]]
		return blood_type.get_color()

	var/r_color = 0
	var/g_color = 0
	var/b_color = 0
	var/valid_colors = 0
	for (var/blood_key in blood_DNA)
		blood_type = blood_DNA[blood_key]
		if(!istype(blood_type))
			continue

		var/list/rgb_blood = rgb2num(blood_type.get_color())
		r_color += rgb_blood[1]
		g_color += rgb_blood[2]
		b_color += rgb_blood[3]
		valid_colors += 1

	if (valid_colors == 0)
		return get_blood_type(BLOOD_TYPE_O_PLUS).get_color()

	r_color /= valid_colors
	g_color /= valid_colors
	b_color /= valid_colors
	return rgb(r_color, g_color, b_color)

/// Checks if any of the passed blood types have certain blood flags
/proc/has_blood_flag(list/blood_DNA, blood_flags)
	if (isnull(blood_DNA))
		return FALSE

	if (!islist(blood_DNA))
		var/datum/blood_type/blood_type = blood_DNA
		blood_DNA = list(blood_type.dna_string = blood_type)

	var/matches = NONE
	for (var/blood_key in blood_DNA)
		var/datum/blood_type/blood_type = blood_DNA[blood_key]
		matches |= (blood_type.blood_flags & blood_flags)
	return matches

/**
 * Returns TRUE if src is compatible with donor's blood, otherwise FALSE.
 * * donor: Mob that is donating blood.
 */
/mob/living/proc/get_blood_compatibility(mob/living/donor)
	if (get_blood_reagent() != donor.get_blood_reagent())
		return FALSE

	var/datum/blood_type/patient_blood_data = get_bloodtype()
	var/datum/blood_type/donor_blood_data = donor.get_bloodtype()
	return (donor_blood_data?.type_key() in patient_blood_data?.compatible_types)

/// Create a small visual-only blood splatter
/mob/living/proc/create_splatter(splatter_dir = pick(GLOB.cardinals))
	// Check for TRAIT_NOBLOOD
	if (!can_bleed()) // Even if we can't cover turfs, we still can add DNA to everything our blood hits
		return
	new /obj/effect/temp_visual/dir_setting/bloodsplatter(get_turf(src), splatter_dir, get_bloodtype())

/*
 * Create a splatter or drip of this mob's blood type
 * Arguments:
 * * splatter_turf - If the splatter should be made on a different turf than the mob
 * * small_drip
 */
/mob/living/proc/add_splatter_floor(turf/splatter_turf, small_drip = FALSE)
	if (HAS_TRAIT(src, TRAIT_NO_BLEEDING) || HAS_TRAIT(src, TRAIT_STASIS))
		return

	if (!splatter_turf)
		splatter_turf = get_turf(src)
	if (!isturf(splatter_turf))
		return

	// Check for TRAIT_NOBLOOD
	switch (can_bleed(BLOOD_COVER_TURFS))
		if (BLEED_NONE)
			return
		if (BLEED_ADD_DNA)
			return splatter_turf.add_mob_blood(src)

	return get_bloodtype()?.make_blood_splatter(src, splatter_turf, small_drip)

/// Blood blown out the far side of us by a bullet, bigger for harder hits
/mob/living/proc/add_exit_splatter(splatter_dir, damage)
	if(HAS_TRAIT(src, TRAIT_NO_BLEEDING) || can_bleed(BLOOD_COVER_TURFS) != BLEED_SPLATTER)
		return
	var/turf/splatter_turf = get_step(src, splatter_dir)
	if(!splatter_turf || splatter_turf.density)
		splatter_turf = get_turf(src)
	if(!isturf(splatter_turf) || isgroundlessturf(splatter_turf))
		return
	var/obj/effect/decal/cleanable/blood/splatter/directional/splatter = locate() in splatter_turf
	if(splatter && !splatter.dried)
		splatter.add_mob_blood(src)
		return
	splatter = new(splatter_turf, get_static_viruses(), get_blood_dna_list())
	if(QDELETED(splatter))
		return
	splatter.setDir(splatter_dir)
	splatter.transform = matrix() * clamp(round(damage / 50, 0.2), 0.4, 1)

/**
 * Sprays blood that flies up to splatter_strength tiles, bloodying what it passes until a standing mob
 * catches it, and landing on the floor, or on the wall or window it hits.
 * Returns TRUE if any blood was sprayed.
 */
/mob/living/proc/spray_blood(splatter_direction, splatter_strength)
	if(!isturf(loc) || HAS_TRAIT(src, TRAIT_NO_BLEEDING) || can_bleed(BLOOD_COVER_TURFS) != BLEED_SPLATTER)
		return FALSE
	var/obj/effect/decal/cleanable/blood/hitsplatter/our_splatter = new(loc, get_static_viruses(), get_blood_dna_list(), splatter_strength)
	if(QDELETED(our_splatter))
		return FALSE
	our_splatter.fly_towards(get_ranged_target_turf(src, splatter_direction, splatter_strength), splatter_strength)
	return TRUE

// FIXME: This duplicates blood like crazy. The amount you bleed is way less than the splatter.
// To summarize, you can literally dupe blood and bypass bloodloss with a syringe and a beaker.
// I'm writing this here because it's out of scope for my PR, but was discovered because of it.
/mob/living/proc/make_blood_trail(turf/target_turf, turf/start, was_facing, movement_direction)
	if(!has_gravity() || !isturf(start) || !can_bleed())
		return

	var/cached_blood_volume = get_blood_volume()

	if(!cached_blood_volume)
		return

	var/base_bleed_rate = get_bleed_rate()
	var/base_brute = getBruteLoss()

	var/brute_ratio = round(base_brute / (maxHealth * 4), 0.1)
	var/bleeding_rate = round(base_bleed_rate / 4, 0.1)

	// We only leave a trail if we're below a certain blood threshold
	// The more brute damage we have, or the more we're bleeding, the less blood we need to leave a trail
	if(cached_blood_volume < max(BLOOD_VOLUME_NORMAL * (1 - max(bleeding_rate, brute_ratio)), 0))
		return

	var/blood_to_add = BLOOD_AMOUNT_PER_DECAL * 0.1

	if(body_position == LYING_DOWN)
		blood_to_add += bleed_drag_amount()
		adjust_blood_volume(-blood_to_add)
	else
		blood_to_add += base_bleed_rate

	// If we're very damaged or bleeding a lot, add even more blood to the trail
	if(base_brute >= 300 || base_bleed_rate >= BLEED_CRITICAL)
		blood_to_add *= 2

	// Checks if we can add visual blood effects on turfs.
	switch(can_bleed(BLOOD_COVER_TURFS))
		if(BLEED_NONE)
			return
		if(BLEED_ADD_DNA)
			return start.add_mob_blood(src)

	var/trail_dir = REVERSE_DIR(movement_direction)
	// The mob is performing a diagonal movement so we need to make a diagonal trail
	// This is not the same as a diagonal dir. Sorry.
	// This is insteas denoted by a negative direction (so we don't conflict with real dirs)
	if(movement_direction in GLOB.diagonals)
		trail_dir = -1 * movement_direction
		// Create a full trail on the tile we came from, and a start of a trail at the one we arrived to
		create_blood_trail_component(start, trail_dir, blood_to_add * 0.67, FALSE)
		create_blood_trail_component(target_turf, get_dir(start, target_turf), blood_to_add * 0.33, TRUE)
		return

	var/continuing_trail = FALSE
	// The mob is going a direction they were not previously facing
	// We now factor in their facing direction to make a trail that looks like they're turning
	// This is done by creating a diagonal dir
	if(trail_dir != was_facing && trail_dir != REVERSE_DIR(was_facing))
		// Look a step back to see if we should be constructing a diagonal dir
		// If there's no existing trail making a curve would look weird
		for(var/obj/effect/decal/cleanable/blood/trail_holder/past_trail in get_step(start, REVERSE_DIR(was_facing)))
			if(past_trail.get_trail_component(was_facing, check_reverse = TRUE, check_diagonals = TRUE, check_reverse_diagonals = TRUE))
				trail_dir |= was_facing
				continuing_trail = TRUE
				// In case we produced an invalid dir: go back on relevant axis
				if((trail_dir & (NORTH|SOUTH)) == (NORTH|SOUTH))
					trail_dir &= ~(was_facing & (NORTH|SOUTH))
				if((trail_dir & (EAST|WEST)) == (EAST|WEST))
					trail_dir &= ~(was_facing & (EAST|WEST))
				break

	if (continuing_trail || (trail_dir in GLOB.diagonals))
		create_blood_trail_component(start, trail_dir, blood_to_add * 0.67, FALSE)
		create_blood_trail_component(target_turf, get_dir(start, target_turf), blood_to_add * 0.33, TRUE)
		return

	// If we're still moving cardinally and didn't change our dir, there's a chance that there's a half-trail on our turf
	// in which case we want to continue it instead of doing a full trail
	// Only scenario in which we don't have one is if we just started the trail from our tile
	for(var/obj/effect/decal/cleanable/blood/trail_holder/trail_holder in start)
		var/obj/effect/decal/cleanable/blood/trail/trail = trail_holder.get_trail_component(trail_dir)
		if (trail?.half_piece) // We're moving straight, so just continue the path
			continuing_trail = TRUE
			break

	// If we've just started moving, put a half-trail on our previous turf instead of a full one
	create_blood_trail_component(start, trail_dir, blood_to_add * 0.67, !continuing_trail)
	create_blood_trail_component(target_turf, get_dir(start, target_turf), blood_to_add * 0.33, TRUE)

/*
 * Locate or create a trail holder, and add a dir to it
 * Arguments:
 * * trail_turf - Turf on which to look for/spawn a trail
 * * trail_dir - Direction in which the trail will be facing. Could be diagonal for a corner, or negative for a true diagonal trail
 * * blood_to_add - How much bloodiness we should add to the trail
 * * half_piece - Should we only create a beginning of a trail, and not a full tile trail? Does not support corners
 */
/mob/living/proc/create_blood_trail_component(turf/trail_turf, trail_dir, blood_to_add, half_piece)
	var/obj/effect/decal/cleanable/blood/trail_holder/trail
	var/check_reverse = TRUE
	// Do not check the reverse dir if we're a diagonal corner or a half piece
	if (trail_dir > 0 && !(trail_dir in GLOB.cardinals) || half_piece)
		check_reverse = FALSE
	// Pick any trail in the turf to add onto
	for(var/obj/effect/decal/cleanable/blood/trail_holder/any_trail in trail_turf)
		// If there exists a trail already, we will add onto the trial
		// UNLESS that trail has the same direction component and it is already dried
		//
		// If that is the case we will look for another trail (or create a new one)
		// (this will let fresh blood be laid over very dried blood)
		var/obj/effect/decal/cleanable/blood/trail/any_trail_component = any_trail.get_trail_component(trail_dir, check_reverse = check_reverse)
		if(isnull(any_trail_component) || !any_trail_component.dried)
			trail = any_trail
			break

	if(!isnull(trail))
		trail.adjust_bloodiness(blood_to_add)
		return trail.add_dir_to_trail(trail_dir, src, blood_to_add, half_piece)

	trail = new(trail_turf, get_static_viruses(), get_blood_dna_list())
	if(QDELETED(trail))
		return
	trail.bloodiness = blood_to_add
	return trail.add_dir_to_trail(trail_dir, src, blood_to_add, half_piece)

/mob/living/carbon/human/make_blood_trail(turf/target_turf, turf/start, was_facing, movement_direction)
	if(!is_bleeding())
		return
	return ..()

/// Returns how much blood we're losing from being dragged a tile, from [/mob/living/proc/make_blood_trail]
/mob/living/proc/bleed_drag_amount()
	var/brute_ratio = round(getBruteLoss() / maxHealth, 0.1)
	return max(1, brute_ratio * 2)

/**
 * Item to represent the fact that we are covering a wound
 */
/obj/item/offhand/bleeding_suppress
	name = "Applying pressure"
	desc = "You are applying pressure to your wounds."
	icon_state = "bleed_held"

/obj/item/offhand/bleeding_suppress/equipped(mob/living/carbon/user, slot)
	. = ..()
	if (istype(user))
		ADD_TRAIT(user, TRAIT_BLEED_HELD, ACTION_TRAIT)

/obj/item/offhand/bleeding_suppress/dropped(mob/living/carbon/user, silent)
	if (istype(user))
		REMOVE_TRAIT(user, TRAIT_BLEED_HELD, ACTION_TRAIT)
	return ..()

#undef BLOOD_DRIP_RATE_MOD
