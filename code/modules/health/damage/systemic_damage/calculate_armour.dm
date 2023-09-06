
/**
 * Runs the damage armour subroutine and mutates the state
 * to account for any modifications that come as a result of
 * armour.
 */
/atom/proc/damage_run_armour(datum/damage_source/source)
	return

/**
 * Mobs:
 * Reduce damage according to armour.
 * Mutate the damage source if required.
 */
/mob/living/damage_run_armour(datum/damage_source/source)
	var/armour_value = run_armor_check(source.target_zone || BODY_ZONE_CHEST, source.armour_flag, armour_penetration = source.armour_penetration)
	// The armour was fully effective
	if (armour_value >= 100)
		source.damage_amount = 0
		return
	source.damage_amount = source.damage_amount * (1 - (armour_value / 100)) * (source.weapon ? check_weakness(source.weapon, src) : 1)

/**
 * Mobs:
 * Mutate damage to reduce it according to armour block.
 */
/obj/damage_run_armour(datum/damage_source/source)
	var/armour_value = run_obj_armor(source.damage_type, source.armour_flag, armour_penetration = source.armour_penetration)
	// The armour was fully effective
	if (armour_value >= 100)
		source.damage_amount = 0
		return
	source.damage_amount = source.damage_amount * (1 - (armour_value / 100))
