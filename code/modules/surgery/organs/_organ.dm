/obj/item/organ
	name = "organ"
	icon = 'icons/obj/medical/organs/organs.dmi'
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	/// The mob that owns this organ.
	var/mob/living/carbon/owner = null
	/// Reference to the limb we're inside of
	var/obj/item/bodypart/bodypart_owner
	/// The cached info about the blood this organ belongs to
	var/list/blood_dna_info = list("Synthetic DNA" = "O+") // not every organ spawns inside a person
	/// The body zone this organ is supposed to inhabit.
	var/zone = BODY_ZONE_CHEST
	/**
	 * The organ slot this organ is supposed to inhabit. This should be unique by type. (Lungs, Appendix, Stomach, etc)
	 * Do NOT add slots with matching names to different zones - it will break the organs_slot list!
	 */
	var/slot
	// DO NOT add slots with matching names to different zones - it will break organs_slot list!
	var/organ_flags = ORGAN_ORGANIC | ORGAN_EDIBLE | ORGAN_VIRGIN
	/// Maximum damage the organ can take, ever.
	var/maxHealth = STANDARD_ORGAN_THRESHOLD
	/**
	 * Total damage this organ has sustained.
	 * Should only ever be modified by apply_organ_damage!
	 */
	var/damage = 0
	/// Healing factor and decay factor function on % of maxhealth, and do not work by applying a static number per tick
	var/healing_factor = 0 //fraction of maxhealth healed per on_life(), set to 0 for generic organs
	var/decay_factor = 0 //same as above but when without a living owner, set to 0 for generic organs
	var/high_threshold = STANDARD_ORGAN_THRESHOLD * 0.45 //when severe organ damage occurs
	var/low_threshold = STANDARD_ORGAN_THRESHOLD * 0.1 //when minor organ damage occurs
	var/severe_cooldown //cooldown for severe effects, used for synthetic organ emp effects.

	// Organ variables for determining what we alert the owner with when they pass/clear the damage thresholds
	var/prev_damage = 0
	var/low_threshold_passed
	var/high_threshold_passed
	var/now_failing
	var/now_fixed
	var/high_threshold_cleared
	var/low_threshold_cleared

	/// When set to false, this can't be used in surgeries and such - Honestly a terrible variable.
	var/useable = TRUE

	/// Food reagents if the organ is edible
	var/list/food_reagents = list(/datum/reagent/consumable/nutriment = 5)
	/// The size of the reagent container if the organ is edible
	var/reagent_vol = 10

	/// Time this organ has failed for
	var/failure_time = 0
	/// Do we affect the appearance of our mob. Used to save time in preference code
	var/visual = TRUE
	/**
	 * Traits that are given to the holder of the organ.
	 * If you want an effect that changes this, don't add directly to this. Use the add_organ_trait() proc.
	 */
	var/list/organ_traits
	/// Status Effects that are given to the holder of the organ.
	var/list/organ_effects

// Players can look at prefs before atoms SS init, and without this
// they would not be able to see external organs, such as moth wings.
// This is also necessary because assets SS is before atoms, and so
// any nonhumans created in that time would experience the same effect.
INITIALIZE_IMMEDIATE(/obj/item/organ)

/obj/item/organ/Initialize(mapload)
	. = ..()
	if(organ_flags & ORGAN_EDIBLE)
		AddComponent(/datum/component/edible,\
			initial_reagents = food_reagents,\
			foodtypes = RAW | MEAT | GROSS,\
			volume = reagent_vol,\
			after_eat = CALLBACK(src, PROC_REF(OnEatFrom)))

	if(bodypart_overlay)
		setup_bodypart_overlay()
	START_PROCESSING(SSobj, src)

/obj/item/organ/Destroy()
	if(bodypart_owner && !owner && !QDELETED(bodypart_owner))
		bodypart_remove(bodypart_owner)
	else if(owner && QDESTROYING(owner))
		// The mob is being deleted, don't update the mob
		Remove(owner, special=TRUE)
	else if(owner)
		Remove(owner)
	else
		STOP_PROCESSING(SSobj, src)
	return ..()

/// Add a Trait to an organ that it will give its owner.
/obj/item/organ/proc/add_organ_trait(trait)
	LAZYADD(organ_traits, trait)
	if(isnull(owner))
		return
	ADD_TRAIT(owner, trait, REF(src))

/// Removes a Trait from an organ, and by extension, its owner.
/obj/item/organ/proc/remove_organ_trait(trait)
	LAZYREMOVE(organ_traits, trait)
	if(isnull(owner))
		return
	REMOVE_TRAIT(owner, trait, REF(src))

/// Add a Status Effect to an organ that it will give its owner.
/obj/item/organ/proc/add_organ_status(status)
	LAZYADD(organ_effects, status)
	if(isnull(owner))
		return
	owner.apply_status_effect(status, type)

/// Removes a Status Effect from an organ, and by extension, its owner.
/obj/item/organ/proc/remove_organ_status(status)
	LAZYREMOVE(organ_effects, status)
	if(isnull(owner))
		return
	owner.remove_status_effect(status, type)

/obj/item/organ/proc/on_find(mob/living/finder)
	return

/obj/item/organ/wash(clean_types)
	. = ..()

	// always add the original dna to the organ after it's washed
	if(!IS_ROBOTIC_ORGAN(src) && (clean_types & CLEAN_TYPE_BLOOD))
		add_blood_DNA(blood_dna_info)

/obj/item/organ/proc/on_death(delta_time, times_fired) //runs decay when outside of a person
	if(organ_flags & (ORGAN_ROBOTIC | ORGAN_FROZEN))
		return
	apply_organ_damage(decay_factor * maxHealth * delta_time)

/// NOTE: THIS IS VERY HOT. Be careful what you put in here
/// To give you some scale, if there's 100 carbons in the game, they each have maybe 9 organs
/// So that's 900 calls to this proc every life process. Please don't be dumb
/obj/item/organ/proc/on_life(delta_time, times_fired) //repair organ damage if the organ is not failing
	if(organ_flags & ORGAN_FAILING)
		return

	if(!damage) // No sense healing if you're not even hurt bro
		return

	if(IS_ROBOTIC_ORGAN(src)) // Robotic organs don't naturally heal
		return

	///Damage decrements by a percent of its maxhealth
	var/healing_amount = healing_factor
	///Damage decrements again by a percent of its maxhealth, up to a total of 4 extra times depending on the owner's health
	if(owner)
		healing_amount += (owner.satiety > 0) ? (4 * healing_factor * owner.satiety / MAX_SATIETY) : 0
	apply_organ_damage(-healing_amount * maxHealth * delta_time, damage) // pass current damage incase we are over cap

/obj/item/organ/examine(mob/user)
	. = ..()

	. += span_notice("It should be inserted in the [parse_zone(zone)].")

	if(organ_flags & ORGAN_FAILING)
		if(IS_ROBOTIC_ORGAN(src))
			. += span_warning("[src] seems to be broken.")
			return
		. += span_warning("[src] has decayed for too long, and has turned a sickly color. It probably won't work without repairs.")
		return

	if(damage > high_threshold)
		if(IS_ROBOTIC_ORGAN(src))
			. += span_warning("[src] seems to be malfunctioning.")
			return
		. += span_warning("[src] is starting to look discolored.")

///Used as callbacks by object pooling
/obj/item/organ/proc/exit_wardrobe()
	START_PROCESSING(SSobj, src)
	bodypart_overlay?.imprint_on_next_insertion = TRUE

//See above
/obj/item/organ/proc/enter_wardrobe()
	STOP_PROCESSING(SSobj, src)

/obj/item/organ/process(delta_time, times_fired)
	on_death(delta_time, times_fired) //Kinda hate doing it like this, but I really don't want to call process directly.

/obj/item/organ/proc/OnEatFrom(eater, feeder)
	useable = FALSE //You can't use it anymore after eating it you spaztic

/obj/item/organ/item_action_slot_check(slot,mob/user)
	return //so we don't grant the organ's action to mobs who pick up the organ.

///Adjusts an organ's damage by the amount "damage_amount", up to a maximum amount, which is by default max damage. Returns the net change in organ damage.
/obj/item/organ/proc/apply_organ_damage(damage_amount, maximum = maxHealth, required_organ_flag = NONE) //use for damaging effects
	if(!damage_amount) //Micro-optimization.
		return FALSE
	if(maximum < damage)
		return FALSE
	if(required_organ_flag && !(organ_flags & required_organ_flag))
		return FALSE
	damage = clamp(damage + damage_amount, 0, maximum)
	. = (prev_damage - damage) // return net damage
	var/message = check_damage_thresholds(owner)
	prev_damage = damage

	if(damage >= maxHealth)
		organ_flags |= ORGAN_FAILING
	else
		organ_flags &= ~ORGAN_FAILING

	if(message && owner && owner.stat <= SOFT_CRIT)
		to_chat(owner, message)

///SETS an organ's damage to the amount "damage_amount", and in doing so clears or sets the failing flag, good for when you have an effect that should fix an organ if broken
/obj/item/organ/proc/set_organ_damage(damage_amount, required_organ_flag = NONE) //use mostly for admin heals
	return apply_organ_damage(damage_amount - damage, required_organ_flag = required_organ_flag)

/** check_damage_thresholds
 * input: mob/organ_owner (a mob, the owner of the organ we call the proc on)
 * output: returns a message should get displayed.
 * description: By checking our current damage against our previous damage, we can decide whether we've passed an organ threshold.
 *  If we have, send the corresponding threshold message to the owner, if such a message exists.
 */
/obj/item/organ/proc/check_damage_thresholds(mob/organ_owner)
	if(damage == prev_damage)
		return
	var/delta = damage - prev_damage
	if(delta > 0)
		if(damage >= maxHealth)
			return now_failing
		if(damage > high_threshold && prev_damage <= high_threshold)
			return high_threshold_passed
		if(damage > low_threshold && prev_damage <= low_threshold)
			return low_threshold_passed
	else
		if(prev_damage > low_threshold && damage <= low_threshold)
			return low_threshold_cleared
		if(prev_damage > high_threshold && damage <= high_threshold)
			return high_threshold_cleared
		if(prev_damage == maxHealth)
			return now_fixed


//Looking for brains?
//Try code/modules/mob/living/carbon/brain/brain_item.dm

/**
 * Heals all of the mob's organs, and re-adds any missing ones.
 *
 * * regenerate_existing - if TRUE, existing organs will be deleted and replaced with new ones
 */
/mob/living/carbon/proc/regenerate_organs(regenerate_existing = FALSE)

	// Delegate to species if possible.
	if(dna?.species)
		dna.species.regenerate_organs(src, replace_current = regenerate_existing)

		// Species regenerate organs doesn't ALWAYS handle healing the organs because it's dumb
		for(var/obj/item/organ/organ as anything in organs)
			organ.set_organ_damage(0)
		set_heartattack(FALSE)

		// Ears have aditional vаr "deaf", need to update it too
		var/obj/item/organ/ears/ears = get_organ_slot(ORGAN_SLOT_EARS)
		ears?.adjustEarDamage(0, -INFINITY) // full heal ears deafness

		return

	// Default organ fixing handling
	// May result in kinda cursed stuff for mobs which don't need these organs
	var/obj/item/organ/lungs/lungs = get_organ_slot(ORGAN_SLOT_LUNGS)
	if(!lungs)
		lungs = new()
		lungs.Insert(src)
	lungs.set_organ_damage(0)

	var/obj/item/organ/heart/heart = get_organ_slot(ORGAN_SLOT_HEART)
	if(heart)
		set_heartattack(FALSE)
	else
		heart = new()
		heart.Insert(src)
	heart.set_organ_damage(0)

	var/obj/item/organ/tongue/tongue = get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!tongue)
		tongue = new()
		tongue.Insert(src)
	tongue.set_organ_damage(0)

	var/obj/item/organ/eyes/eyes = get_organ_slot(ORGAN_SLOT_EYES)
	if(!eyes)
		eyes = new()
		eyes.Insert(src)
	eyes.set_organ_damage(0)

	var/obj/item/organ/ears/ears = get_organ_slot(ORGAN_SLOT_EARS)
	if(!ears)
		ears = new()
		ears.Insert(src)
	ears.adjustEarDamage(-INFINITY, -INFINITY)

/obj/item/organ/proc/handle_failing_organs(delta_time)
	return

/** organ_failure
 * generic proc for handling dying organs
 *
 * Arguments:
 * delta_time - seconds since last tick
 */
/obj/item/organ/proc/organ_failure(delta_time)
	return

/** get_availability
  * returns whether the species should innately have this organ.
  *
  * regenerate organs works with generic organs, so we need to get whether it can accept certain organs just by what this returns.
  * This is set to return true or false, depending on if a species has a specific organless trait. stomach for example checks if the species has NOSTOMACH and return based on that.
  * Arguments:
  * owner_species - species, needed to return the mutant slot as true or false. stomach set to null means it shouldn't have one.
  * owner_mob - for more specific checks, like nightmares.
 */
/obj/item/organ/proc/get_availability(datum/species/owner_species, mob/living/owner_mob)
	return TRUE

/// Called before organs are replaced in regenerate_organs with new ones
/obj/item/organ/proc/before_organ_replacement(obj/item/organ/replacement)
	SHOULD_CALL_PARENT(TRUE)

	SEND_SIGNAL(src, COMSIG_ORGAN_BEING_REPLACED, replacement)

	// If we're being replace with an identical type we should take organ damage
	if(replacement.type == type)
		replacement.set_organ_damage(damage)

/// Called by medical scanners to get a simple summary of how healthy the organ is. Returns an empty string if things are fine.
/obj/item/organ/proc/get_status_text()
	var/status = ""
	if(organ_flags & ORGAN_FAILING)
		status = "<font color='#cc3333'>Non-Functional</font>"
	else if(damage > high_threshold)
		status = "<font color='#ff9933'>Severely Damaged</font>"
	else if (damage > low_threshold)
		status = "<font color='#ffcc33'>Mildly Damaged</font>"

	return status

/// Tries to replace the existing organ on the passed mob with this one, with special handling for replacing a brain without ghosting target
/obj/item/organ/proc/replace_into(mob/living/carbon/new_owner)
	return Insert(new_owner, special = TRUE, movement_flags = DELETE_IF_REPLACED)

/// Get all possible organ slots by checking every organ, and then store it and give it whenever needed
/proc/get_all_slots()
	var/static/list/all_organ_slots = list()

	if(!all_organ_slots.len)
		for(var/obj/item/organ/an_organ as anything in subtypesof(/obj/item/organ))
			if(!initial(an_organ.slot))
				continue
			all_organ_slots |= initial(an_organ.slot)

	return all_organ_slots
