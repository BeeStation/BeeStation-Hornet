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


/// If user is null, no animation will be played and there will be no attack message.
/obj/proc/damage_direct(mob/living/user, atom/target, target_zone = null, update_health = TRUE, forced = FALSE, override_damage = null)
