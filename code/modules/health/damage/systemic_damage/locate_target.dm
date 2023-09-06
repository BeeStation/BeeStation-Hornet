
/**
 * Identify the target of our attack. For most things, we are just going
 * to attack ourselves however for certain objects we may want to relay the
 * damage to another source, such as mobs relaying the damage to limbs.
 */
/atom/proc/damage_get_target(datum/damage_source/source)
	return

/mob/living/carbon/damage_get_target(datum/damage_source/source)
	// Attack the mob as a whole
	if (!source.target_zone)
		return
	var/obj/item/bodypart/targetted_bodypart = get_bodypart(check_zone(source.target_zone))
	if (targetted_bodypart)
		source.target = targetted_bodypart
		return
	targetted_bodypart = pick(bodyparts)
	if (istype(targetted_bodypart))
		source.target = targetted_bodypart
		return
