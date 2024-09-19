/**
 * ## AOE spells
 *
 * A spell that iterates over atoms near the caster and casts a spell on them.
 * Calls cast_on_thing_in_aoe on all atoms returned by get_things_to_cast_on by default.
 */
/datum/action/cooldown/spell/aoe
	/// The max amount of targets we can affect via our AOE. 0 = unlimited
	var/max_targets = 0
	/// The radius of the aoe.
	var/aoe_radius = 7

// At this point, cast_on == owner. Either works.
/datum/action/cooldown/spell/aoe/cast(atom/cast_on)
	. = ..()
	// Get every atom around us to our aoe cast on
	var/list/atom/things_to_cast_on = get_things_to_cast_on(cast_on)
	// If we have a target limit, shuffle it (for fariness)
	if(max_targets > 0)
		things_to_cast_on = shuffle(things_to_cast_on)

	SEND_SIGNAL(src, COMSIG_SPELL_AOE_ON_CAST, things_to_cast_on, cast_on)

	// Now go through and cast our spell where applicable
	var/num_targets = 0
	for(var/thing_to_target in things_to_cast_on)
		if(max_targets > 0 && num_targets >= max_targets)
			continue

		cast_on_thing_in_aoe(thing_to_target, cast_on)
		num_targets++

/**
 * Gets a list of atoms around [center]
 * that are within range and affected by our aoe.
 */
/datum/action/cooldown/spell/aoe/proc/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/atom/nearby_thing in range(aoe_radius, center))
		if(nearby_thing == owner || nearby_thing == center)
			continue

		things += nearby_thing

	return things

/**
 * Actually cause effects on the thing in our aoe.
 * Override this for your spell! Not cast().
 *
 * Arguments
 * * victim - the atom being affected by our aoe
 * * caster - the mob who cast the aoe
 */
/datum/action/cooldown/spell/aoe/proc/cast_on_thing_in_aoe(atom/victim, atom/caster)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("[type] did not implement cast_on_thing_in_aoe and either has no effects or implemented the spell incorrectly.")
