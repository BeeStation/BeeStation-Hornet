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
/// TODO: Add on the punch message somewhere in this attack chain
/mob/living/proc/deal_generic_attack(atom/target)
	var/datum/damage_source/source = GET_DAMAGE_SOURCE(/datum/damage_source/blunt/light)
	return source.deal_attack(src, null, target, BRUTE, 3, ran_zone(zone_selected))

/mob/living/carbon/alien/humanoid/deal_generic_attack(atom/target)
	var/datum/damage_source/source = GET_DAMAGE_SOURCE(/datum/damage_source/sharp/light)
	return source.deal_attack(src, null, target, BRUTE, 20, ran_zone(zone_selected))

/mob/living/simple_animal/deal_generic_attack(atom/target)
	var/datum/damage_source/source = GET_DAMAGE_SOURCE(/datum/damage_source/blunt/light)
	return source.deal_attack(src, null, target, melee_damage_type, isobj(target) ? obj_damage : melee_damage_type, ran_zone(zone_selected))

/mob/living/simple_animal/slime/deal_generic_attack(atom/target)
	var/datum/damage_source/slime_damage_source = GET_DAMAGE_SOURCE(/datum/damage_source/slime)
	var/damage = 20
	if (is_adult)
		damage = 30
	if (transformeffects & SLIME_EFFECT_RED)
		damage *= 1.1
	slime_damage_source.deal_attack(src, null, target, melee_damage_type, damage, ran_zone(zone_selected))
	target.after_attacked_by_slime(src)
