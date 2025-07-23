/// Don't target an atom in our friends list (or turfs), anything else is fair game
/datum/targetting_datum/not_friends
	/// Stop regarding someone as a valid target once they pass this stat level, setting it to DEAD means you will happily attack corpses
	var/attack_until_past_stat = HARD_CRIT
	/// If we can try to closed turfs or not
	var/attack_closed_turf = FALSE

///Returns true or false depending on if the target can be attacked by the mob
/datum/targetting_datum/not_friends/can_attack(mob/living/living_mob, atom/target)
	if (!target)
		return FALSE
	if (attack_closed_turf)
		if (isopenturf(target))
			return FALSE
	else
		if (isturf(target))
			return FALSE

	if (ismob(target))
		var/mob/mob_target = target
		if (mob_target.status_flags & GODMODE)
			return FALSE
		if (mob_target.stat > attack_until_past_stat)
			return FALSE

	if (living_mob.see_invisible < target.invisibility)
		return FALSE
	if (isturf(target.loc) && living_mob.z != target.z) // z check will always fail if target is in a mech
		return FALSE
	if (!living_mob.ai_controller) // How did you get here?
		return FALSE

	if (!(target in living_mob.ai_controller.blackboard[BB_FRIENDS_LIST]))
		// We don't have any friends, anything's fair game
		// OR This is not our friend, fire at will
		return TRUE

	return FALSE

/datum/targetting_datum/not_friends/attack_closed_turfs
	attack_closed_turf = TRUE
