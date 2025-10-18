/datum/injury
	// =================================
	// Meta
	// =================================
	/// The starting point of the injury tree
	var/base_type = null
	/// Flags about how the injury can be applied
	var/injury_flags = INJURY_BODY | INJURY_LIMB
	// =================================
	// Presentation
	// =================================
	/// The severity level of this injury
	var/severity_level = INJURY_PRIORITY_NONE
	/// The health doll state to add
	var/health_doll_icon = null
	/// How the injury shows up when examined, prefaced by the auxiliary verb
	var/examine_description = null
	/// Should we be treated as if we are coming from the body instead?
	var/whole_body = FALSE
	/// Is this injury visible by inspection of the body?
	var/external = FALSE
	/// The status icon which shows when you are selecting a bodypart to apply a medical item to
	/// Defined in 'icons/mob/zone_dam.dmi'
	var/status_icon_state = null
	// =================================
	// Effects
	// =================================
	/// How much damage this injury adds to the limb when it is applied, regardless
	/// of how much progression the injury has.
	var/added_damage = 0
	/// The amount of damage applied by this will be this value multiplied by the
	/// progression of the injury.
	var/damage_multiplier = 0
	/// Current amount of damage taken
	/// Progression represents the amount of damage applied to the injury, so typically
	/// would be in the range of 0-100, but it may be more in cases of extreme damage.
	/// If this has an initial value other than 0, then the injury is given a progression
	/// value as soon as it is applied, which may be the case for injuries where progression
	/// is not directly tied to damage.
	var/progression = 0
	/// Effectiveness modifier to the limb. Reduces the effectiveness on the limb even
	/// without causing damage to it.
	var/effectiveness_modifier = 1
	/// Modifier to the bone armour provided by the limb
	var/bone_armour_modifier = 1
	/// Modifier to the skin armour provided by the limb
	var/skin_armour_modifier = 1
	/// How much pain this injury causes
	var/pain = 0
	/// Added pain based on this multiplier * amount of damage this injury is causing
	/// Total pain = pain + pain_multiplier * damae
	var/pain_multiplier = 0
	// =================================
	// Healing
	// =================================
	/// List of surgeries provided by this injury
	var/list/surgeries_provided = null
	/// The progression value that we need to reach for the injury to be fully healed
	var/minimum_progression = 0
	/// What do we need to do to heal this injury?
	var/heal_description = null
	/// The type we transition to upon being healed
	var/healed_type
	/// Max amount of damage we can absorb as a fresh injury. This means that new injuries
	/// have more health than old ones.
	var/max_absorption = 30
	// =================================
	// Instanced
	// =================================
	/// Bodypart we are attached to, if we are a bodypart injury
	var/obj/item/bodypart/bodypart
	/// The mob that we are attached to, if we are a mob injury
	var/mob/living/mob
	/// When did we gain this injury?
	var/gained_time
	/// How much damage have we absorbed, when injuries are gained for the first time
	/// there is a short period in which they absorb additional damage, so that a single
	/// fight doesn't progress you to fatal injuries instantly
	var/absorbed_damage = 0

/datum/injury/process(delta_time)
	if (!bodypart.owner)
		return PROCESS_KILL
	if (bodypart.owner.stat == DEAD || IS_IN_STASIS(bodypart.owner))
		return
	on_tick(bodypart.owner, delta_time)

/// Called only if we are gained while a human has the bodypart
/// attached. Not called if a bodypart with the injury is
/// attached.
/datum/injury/proc/gain_message(mob/living/carbon/human/target, obj/item/bodypart/part)

/// Apply the injury to the bodypart
/datum/injury/proc/apply_to_part(obj/item/bodypart/part)
	return

/// Remove the injury from the bodypart
/datum/injury/proc/remove_from_part(obj/item/bodypart/part)
	return

/// Apply the injury to the target
/datum/injury/proc/apply_to_human(mob/living/carbon/human/target)
	RegisterSignal(target, COMSIG_ATOM_ATTACKBY, PROC_REF(item_interaction))
	target.update_health_hud()
	START_PROCESSING(SSinjuries, src)
	if (pain)
		target.pain.set_pain_source(pain, "[type]")
	// Update progression, to apply initial effects
	update_progressive_effects()

/// Take the injury away from the person who owns the limb
/datum/injury/proc/remove_from_human(mob/living/carbon/human/target)
	remove_progressive_effects()
	UnregisterSignal(target, COMSIG_ATOM_ATTACKBY)
	target.update_health_hud()
	STOP_PROCESSING(SSinjuries, src)

/datum/injury/proc/apply_damage(delta_damage, damage_type = BRUTE, damage_flag = DAMAGE_STANDARD, is_sharp = FALSE)
	if (on_damage_taken((progression - initial(progression)) + delta_damage, delta_damage, damage_type, damage_flag, is_sharp))
		adjust_progression(delta_damage)

/datum/injury/proc/adjust_progression(delta_damage)
	// Absorb damage if we are a brand new injury.
	var/duration = world.time - gained_time
	var/propotion = CLAMP01(1 - (duration / INJURY_ABSORPTION_DURATION))
	var/absorbed_amount = max(0, min(delta_damage, (max_absorption * propotion) - absorbed_damage))
	absorbed_damage += absorbed_amount
	// Increase our total damage amount
	var/applied = delta_damage - absorbed_amount
	var/previous_progression = progression
	progression += delta_damage - absorbed_amount
	// Progression of the injury decreased to 0, heal the injury
	if (progression < minimum_progression)
		heal()
		bodypart?.update_damage()
		// If progression was 10 before, the delta was -10
		return -previous_progression
	else
		update_progressive_effects()
		bodypart?.update_damage()
		// Return however much progression was applied
		return applied

/datum/injury/proc/update_progressive_effects()
	return

/datum/injury/proc/remove_progressive_effects()
	return

/// Called when damage is taken
/// Return false if the damage is not relevant and should be ignored, true otherwise.
/datum/injury/proc/on_damage_taken(total_damage, delta_damage, damage_type = BRUTE, damage_flag = DAMAGE_STANDARD, is_sharp = FALSE)
	return FALSE

/// Called when the limb processes, target may be null
/datum/injury/proc/on_tick(mob/living/carbon/human/target, delta_time)
	return

/// Transition to a new type of injury state.
/datum/injury/proc/transition_to(new_type)
	SHOULD_NOT_OVERRIDE(TRUE)
	bodypart.remove_injury_tree(src)
	bodypart.apply_injury_tree(new_type, base_type)

/// Intercept item interactions. Return COMPONENT_NO_AFTERATTACK if successful.
/datum/injury/proc/item_interaction(mob/living/carbon/human/source, obj/item, mob/living/attacker, params)
	return 0

/// Intercept the application of medical items.
/// This differs from item_interaction, as it applies after standard medical item checks are applied.
/// Return either MEDICAL_ITEM_APPLIED or MEDICAL_ITEM_FAILED to intercept
/datum/injury/proc/intercept_medical_application(obj/item/stack/medical/medical_item, mob/living/carbon/human/victim, mob/living/actor)
	return MEDICAL_ITEM_NO_INTERCEPT

/// Intercept the exposure of a reagent to a mob.
/// Adds additional behaviour on top of the standard exposure of the reagent
/datum/injury/proc/intercept_reagent_exposure(datum/reagent, mob/living/victim, method = TOUCH, reac_volume = 0, touch_protection = 0)
	return

/// Perform the default heal
/datum/injury/proc/heal()
	if (healed_type)
		transition_to(healed_type)
