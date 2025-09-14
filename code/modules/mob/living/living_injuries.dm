/// Adjust the progression of an injury.
/// This represents injuries acting on the whole body for a mob,
/// injury_type: The type of the injury to progress.
/// amount: The amount to progress the injury by
/// zone: Optional zone, applies the injury to a specific bodypart instead of the whole body
/// for mobs that support zone damage.
/// Returns the amount of progression applied to the injury, which may differ in cases where
/// the progression was healed before it could be all applied.
/mob/living/proc/adjust_injury(injury_type, amount, zone = null)
	var/datum/injury/injury_path = injury_type
	// If a mob does not have limbs, then it must apply to the entire
	// body.
	if (has_limbs)
		// If we have no zone but the injury must be applied to a limb,
		// then randomly select a zone.
		if (!zone && !(injury_path:injury_flags & INJURY_BODY))
			zone = ran_zone()
		// If the injury can be applied to a limb and a zone was selected
		// apply to that area
		if (zone && !(injury_path:injury_flags & INJURY_LIMB))
			var/obj/item/bodypart/part = get_bodypart(zone)
			if (!part)
				return 0
			return part.increase_injury(injury_type, amount)
		// The injury cannot be applied to the body or a limb
		if (!(injury_path:injury_flags & INJURY_BODY))
			return 0
	// Either get the existing injury, or apply the new injury
	if (amount > 0)
		var/datum/injury/injury = apply_injury(injury_type)
		return injury.adjust_progression(amount)
	else
		// When healing an injury, we don't apply it
		var/datum/injury/injury = get_injury(injury_type)
		if (!injury)
			return 0
		return injury.adjust_progression(amount)

/// Set the progression of an injury, a value of 0 will remove it.
/// This represents injuries acting on the whole body for a mob,
/// injury_type: The type, or base-type (for injury trees), of the injury to progress.
/// amount: The amount to progress the injury by
/// zone: Optional zone, applies the injury to a specific bodypart instead of the whole body
/// for mobs that support zone damage.
/mob/living/proc/set_injury(injury_type, amount, zone = null)
	var/datum/injury/injury_path = injury_type

/// Removes an injury from the mob.
/// This represents injuries acting on the whole body for a mob,
/// injury_type: The type, or base-type (for injury trees), of the injury to progress.
/// amount: The amount to progress the injury by
/// zone: Optional zone, applies the injury to a specific bodypart instead of the whole body
/// for mobs that support zone damage.
/mob/living/proc/remove_injury(injury_type, amount, zone = null)
	var/datum/injury/injury_path = injury_type

/// Get an injury by its base type. For all damages, the base type is the type of
/// the injury, for some progressive/graphed injuries, the base-type is the first
/// injury in the graph (the healthy state).
/mob/living/proc/get_injury(injury_type, zone = null)
	RETURN_TYPE(/datum/injury)
	var/datum/injury/injury_path = injury_type
	if (zone)
		var/obj/item/bodypart/part = get_bodypart(zone)
		if (!part)
			return
		return part.get_injury(injury_path:base_type)
	return injuries[injury_path:base_type]

/// Get an injury's progression by its base type. For all damages, the base type is the type of
/// the injury, for some progressive/graphed injuries, the base-type is the first
/// injury in the graph (the healthy state).
/mob/living/proc/get_injury_amount(injury_type, zone = null)
	var/datum/injury/injury_path = injury_type
	var/datum/injury/injury = injuries[injury_path:base_type]
	if (zone)
		var/obj/item/bodypart/part = get_bodypart(zone)
		if (!part)
			return 0
		injury = part.get_injury(injury_path:base_type)
	if (!injury)
		return 0
	return injury.progression

/// Apply a specific injury to a mob, without having any progression
/// injury_type: The type, or base-type (for injury trees), of the injury to progress.
/// zone: Optional zone, applies the injury to a specific bodypart instead of the whole body
/// for mobs that support zone damage.
/mob/living/proc/apply_injury(injury_type, zone = null)
	RETURN_TYPE(/datum/injury)
	var/datum/injury/injury_path = injury_type
	if (zone)
		var/obj/item/bodypart/part = get_bodypart(zone)
		if (!part)
			return null
		return part.apply_injury_tree(injury_type)
	// Get or apply the injury
	if (injuries[injury_path:base_type])
		return injuries[injury_path:base_type]
	var/datum/injury/injury = new injury_type
	injury.gained_time = world.time
	injuries[injury_path:base_type] = injury
	return injury
