/**
 * Apply the damage to whatever we are targetting.
 */
/atom/proc/damage_apply_damage(datum/damage_source/source)
	return

/mob/living/damage_apply_damage(datum/damage_source/source)
	// Apply the damage
	var/datum/damage/damage = GET_DAMAGE(source.damage_type)
	damage.apply_living(src)

/obj/damage_apply_damage(datum/damage_source/source)
	// Apply the damage
	var/datum/damage/damage = GET_DAMAGE(source.damage_type)
	damage.apply_object(src)

/obj/item/bodypart/damage_apply_damage(datum/damage_source/source)
	// Apply the damage
	var/datum/damage/damage = GET_DAMAGE(source.damage_type)
	damage.apply_bodypart(src)

/obj/item/organ/damage_apply_damage(datum/damage_source/source)
	// Apply the damage
	var/datum/damage/damage = GET_DAMAGE(source.damage_type)
	damage.apply_organ(src)
