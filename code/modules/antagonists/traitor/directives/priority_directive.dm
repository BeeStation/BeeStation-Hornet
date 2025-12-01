NAMED_TUPLE_2(directive_team, var/list, uplinks, var/list, data)
NAMED_TUPLE_1(directive_special_action, var, action_name)

/datum/directive_team/proc/grant_reward(tc_amount, reputation_amount)
	for (var/datum/component/uplink/uplink in uplinks)
		uplink.telecrystals += tc_amount * uplink.directive_tc_multiplier
		uplink.reputation += reputation_amount
	send_message("[tc_amount] telecrystals and [reputation_amount] reputation points have been authorised for your use.")

/datum/directive_team/proc/grant_punishment(loss_amount)
	for (var/datum/component/uplink/uplink in uplinks)
		uplink.reputation -= loss_amount
	if (loss_amount)
		send_message("You have failed to complete a direct order from Syndicate command. You have lost [loss_amount] reputation points as a result of administrative punishment.")
	else
		send_message("You have failed to complete a direct order from Syndicate command. Await further instructions and proceed with prior mission objectives.")

/datum/directive_team/proc/send_message(message)
	for (var/datum/component/uplink/uplink in uplinks)
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
		to_chat(current, "<span class='traitor_objective'>[uppertext(message)]</span>")
		SEND_SOUND(current, sound('sound/machines/twobeep_high.ogg', volume = 50))

/datum/priority_directive
	var/id = 0
	var/name
	var/objective_explanation
	var/details
	var/last_for = 10 MINUTES
	var/end_at
	var/rejected = FALSE
	var/tc_reward
	var/reputation_reward = REPUTATION_GAIN_PER_DIRECTIVE
	var/reputation_loss = REPUTATION_LOSS_SOLO_DIRECTIVE
	var/can_timeout = TRUE
	var/shared = FALSE
	VAR_PRIVATE/list/teams = list()

/// Check if we are allowed to run this directive or not
/datum/priority_directive/proc/can_run(list/uplinks, list/player_minds, force = FALSE)
	SHOULD_NOT_OVERRIDE(TRUE)
	teams.Cut()
	rejected = FALSE
	can_timeout = TRUE
	_allocate_teams(uplinks, player_minds, force)
	return !rejected

/// Allocate teams for this directive. Call reject() to reject this directive and
/// add_antagonist_team to add antagonist teams.
/datum/priority_directive/proc/_allocate_teams(list/uplinks, list/player_minds, force = FALSE)
	PROTECTED_PROC(TRUE)

/// Handle late allocation
/datum/priority_directive/proc/late_allocate(datum/component/uplink)
	RETURN_TYPE(/datum/directive_team)
	return null

/// Return the reward type and amount
/datum/priority_directive/proc/_generate(list/teams)
	PROTECTED_PROC(TRUE)

/// Get the tracking target of this atom
/datum/priority_directive/proc/get_track_atom()

/// Check if we have finished early. We always complete after a set time period.
/datum/priority_directive/proc/is_completed()
	return FALSE

/datum/priority_directive/proc/is_timed_out()
	SHOULD_NOT_OVERRIDE(TRUE)
	return can_timeout && (world.time > end_at)

/datum/priority_directive/proc/finish()
	SHOULD_CALL_PARENT(TRUE)
	SSdirectives.active_directives -= src
	if (shared)
		SSdirectives.queue_directive()
	qdel(src)

/// Activate the directive, requires a list of traitor datums and security minsd
/datum/priority_directive/proc/start(list/uplinks, list/player_minds)
	SHOULD_NOT_OVERRIDE(TRUE)
	end_at = world.time + last_for
	tc_reward = _generate(teams)
	mission_update("NEW PRIORITY DIRECTIVE RECEIVED. SEE UPLINK FOR DETAILS.", prefix = "")

/// Advertise this directive to security objectives consoles
/datum/priority_directive/proc/advertise_security()
	PROTECTED_PROC(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)

/datum/priority_directive/proc/add_antagonist_team(list/uplinks, list/data = null)
	SHOULD_NOT_OVERRIDE(TRUE)
	RETURN_TYPE(/datum/directive_team)
	var/created = new /datum/directive_team(islist(uplinks) ? uplinks : list(uplinks), islist(data) ? data : list())
	teams += created
	return created

/// Reject this directive, prevent it from firing
/datum/priority_directive/proc/reject()
	PROTECTED_PROC(TRUE)
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

/datum/priority_directive/proc/get_team(datum/component/uplink)
	SHOULD_NOT_OVERRIDE(TRUE)
	RETURN_TYPE(/datum/directive_team)
	for (var/datum/directive_team/team in teams)
		if (uplink in team.uplinks)
			return team
	return null

/// Perform the special directive action
/datum/priority_directive/proc/perform_special_action(datum/component/uplink, mob/living/user)

/datum/priority_directive/proc/get_explanation(datum/component/uplink)
	return objective_explanation

/datum/priority_directive/proc/get_details(datum/component/uplink)
	return details

/datum/priority_directive/proc/mission_update(message, prefix = "IMPORTANT MISSION CRITICAL NOTIFICATION: ")
	PROTECTED_PROC(TRUE)
	for (var/datum/directive_team/team in teams)
		team.send_message("[prefix][uppertext(message)]")
	var/atom/follow_atom = get_track_atom()
	if (follow_atom)
		if (ismob(follow_atom.loc))
			deadchat_broadcast("<span class='deadsay bold'>Syndicate Mission Update: [message]</span>", follow_target = follow_atom)
		else
			deadchat_broadcast("<span class='deadsay bold'>Syndicate Mission Update: [message]</span>", turf_target = get_turf(follow_atom))
	else
		deadchat_broadcast("<span class='deadsay bold'>Syndicate Mission Update: [message]</span>")

/datum/priority_directive/proc/grant_victory(datum/directive_team/victor_team)
	victor_team?.grant_reward(tc_reward, reputation_reward)
	if (victor_team != null)
		for (var/datum/directive_team/team in teams)
			if (team == victor_team)
				continue
			team.grant_punishment(reputation_loss)

/datum/priority_directive/proc/grant_universal_victory()
	for (var/datum/directive_team/team in teams)
		team.grant_reward(tc_reward, reputation_reward)
