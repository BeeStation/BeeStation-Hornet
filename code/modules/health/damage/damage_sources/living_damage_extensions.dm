/// Damage source will decide if this should respect armour or not
/// If you want an object to be the attacker, do not use this as it does not use the items
/// armour penetration value.
/// Target zone may be a def_zone or bodypart
/mob/living/proc/apply_damage(damage_source, damage_type, damage, target_zone = null, update_health = TRUE, forced = FALSE)
	// Get the damage source
	var/datum/damage_source/source = damage_source
	if (!istype(source))
		source = GET_DAMAGE_SOURCE(damage_source)
	return source.apply_direct(src, damage_type, damage, target_zone)

/// Perform the mobs default attack protocols (punching/biting/whatever)
/// Returns the amount of damage dealt
/mob/living/proc/deal_generic_attack(atom/target)
	return FALSE
