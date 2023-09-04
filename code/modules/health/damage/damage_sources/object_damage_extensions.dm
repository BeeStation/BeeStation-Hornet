/**
 * Perform the generic attack function which will use this object's damage
 * profile to attack the target.
 * This will handle
 * - Attack animations
 * - Attack sounds
 * - Armour penetration (damage source handles this)
 * - Bleeding (damage source handles this)
 */
/obj/proc/deal_attack(mob/living/user, atom/target, target_zone = null, update_health = TRUE, forced = FALSE, override_damage = null)
	SHOULD_NOT_OVERRIDE(TRUE)
	// Get the damage source that we want to use
	var/datum/damage_source/damage_provider = GET_DAMAGE_SOURCE(damage_source)
	if (!damage_provider)
		CRASH("[type] has not provided a valid damage source. Value provided: [damage_source], expected path of type /datum/damage_source")
	// Deal the actaul damage
	damage_provider.deal_attack(user, src, target, damtype, override_damage || force, target_zone, update_health, forced)

/// If user is null, no animation will be played and there will be no attack message.
/obj/proc/damage_direct(mob/living/user, atom/target, target_zone = null, update_health = TRUE, forced = FALSE, override_damage = null)
