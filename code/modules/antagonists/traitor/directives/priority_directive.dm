NAMED_TUPLE_1(directive_team, /list, uplinks)
NAMED_TUPLE_1(directive_special_action,, action_name)

/// This can only be running once at a time, do not run in parallel
/datum/priority_directive
	var/name
	var/objective_explanation
	var/details
	var/end_at
	var/rejected = FALSE
	var/tc_reward
	VAR_PRIVATE/list/teams = list()

/datum/priority_directive/New()
	. = ..()

/// Check if we are allowed to run this directive or not
/datum/priority_directive/proc/can_run(list/uplinks, list/player_minds, force = FALSE)
	SHOULD_NOT_OVERRIDE(TRUE)
	teams.Cut()
	_allocate_teams(uplinks, player_minds, force)
	return !rejected

/// Allocate teams for this directive. Call reject() to reject this directive and
/// add_antagonist_team to add antagonist teams.
/datum/priority_directive/proc/_allocate_teams(list/uplinks, list/player_minds, force = FALSE)

/// Return the reward type and amount
/datum/priority_directive/proc/_generate(list/teams)

/// Get the tracking target of this atom
/datum/priority_directive/proc/get_track_atom()

/// Check if we have finished early. We always complete after a set time period.
/datum/priority_directive/proc/is_completed()
	return FALSE

/datum/priority_directive/proc/finish()
	SSdirectives.active_directive = null

/// Activate the directive, requires a list of traitor datums and security minsd
/datum/priority_directive/proc/start(list/uplinks, list/player_minds)
	SHOULD_NOT_OVERRIDE(TRUE)
	end_at = world.time + 10 MINUTES
	tc_reward = _generate(teams)
	for (var/datum/component/uplink/uplink in GLOB.uplinks)
		var/syndicate_antag = FALSE
		var/mob/living/current = uplink.parent
		while (current && !istype(current))
			current = current.loc
		if (istype(current))
			for (var/datum/antagonist/antag in current.mind?.antag_datums)
				syndicate_antag ||= antag.faction == FACTION_SYNDICATE
		else
			// Nobody to notify
			continue
		// If we are not held by a syndicate, and we are locked then do not give a notification
		if (!syndicate_antag && uplink.locked)
			continue
		to_chat(current, "<span class='traitor_objective'>NEW PRIORITY DIRECTIVE RECEIVED. SEE UPLINK FOR DETAILS.</span>")
		SEND_SOUND(current, sound('sound/machines/twobeep_high.ogg', volume = 50))

/// Advertise this directive to security objectives consoles
/datum/priority_directive/proc/advertise_security()
	SHOULD_NOT_OVERRIDE(TRUE)

/datum/priority_directive/proc/add_antagonist_team(list/uplinks)
	SHOULD_NOT_OVERRIDE(TRUE)
	teams += new /datum/directive_team(uplinks)

/// Reject this directive, prevent it from firing
/datum/priority_directive/proc/reject()
	SHOULD_NOT_OVERRIDE(TRUE)
	rejected = TRUE

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

/// Get any special uplink actions
/datum/priority_directive/proc/get_special_action(datum/component/uplink)
	RETURN_TYPE(/datum/directive_special_action)
	return null

/// Perform the special directive action
/datum/priority_directive/proc/perform_special_action(datum/component/uplink, mob/living/user)
