/// This can only be running once at a time, do not run in parallel
/datum/priority_directive
	var/name
	var/desc
	var/end_at
	var/rejected = FALSE

/datum/priority_directive/New()
	. = ..()

/datum/priority_directive/proc/check()
	SHOULD_NOT_OVERRIDE(TRUE)

/datum/priority_directive/proc/allocate_teams(list/antag_datums, list/player_minds)

/// Return the reward type and amount
/datum/priority_directive/proc/generate(list/antag_datums, list/player_minds)

/// Check if we have finished early. We always complete after a set time period.
/datum/priority_directive/proc/is_completed()
	return FALSE

/datum/priority_directive/proc/finish()

/// Activate the directive, requires a list of traitor datums and security minsd
/datum/priority_directive/proc/activate(list/antag_datums, list/player_minds)
	SHOULD_NOT_OVERRIDE(TRUE)

/// Advertise this directive to security objectives consoles
/datum/priority_directive/proc/advertise_security()
	SHOULD_NOT_OVERRIDE(TRUE)

/datum/priority_directive/proc/add_antagonist_team(list/antag_datums)
	SHOULD_NOT_OVERRIDE(TRUE)

/// Reject this directive, prevent it from firing
/datum/priority_directive/proc/reject()
	SHOULD_NOT_OVERRIDE(TRUE)

/// Pick a random target with some specified restrictions
/datum/priority_directive/proc/get_random_target(list/player_minds, list/allowed_roles = null, list/disallowed_roles = null)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/list/targets = list()
	for (var/datum/mind/mind in player_minds)
		var/mob/living/mob = mind.current
		if (!ishuman(mob) || !is_station_level(mob.z))
			continue
		if (allowed_roles && !(mind.assigned_role in allowed_roles) && !(mind.special_role in allowed_roles))
			continue
		if (disallowed_roles && ((mind.assigned_role in disallowed_roles) || (mind.special_role in disallowed_roles)))
			continue
		targets += mind
	return pick(targets)

/datum/priority_directive/proc/get_independent_difficulty()

/datum/priority_directive/proc/tc_curve(input)
	return input
