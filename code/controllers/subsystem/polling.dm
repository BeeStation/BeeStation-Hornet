SUBSYSTEM_DEF(polling)
	name = "Polling"
	flags = SS_BACKGROUND
	wait = 1 SECONDS
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	/// List of polls currently ongoing, to be checked on next fire()
	var/list/datum/candidate_poll/currently_polling
	/// Number of polls performed since the start
	var/total_polls = 0

/datum/controller/subsystem/polling/Initialize()
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGGED_IN, PROC_REF(on_ghost_appeared))
	return SS_INIT_SUCCESS

/datum/controller/subsystem/polling/fire()
	if(!currently_polling) // if polls_active is TRUE then this shouldn't happen, but still..
		currently_polling = list()

	for(var/datum/candidate_poll/running_poll as anything in currently_polling)
		if(running_poll.time_left() <= 0)
			polling_finished(running_poll)

/**
 * Starts a poll.
 *
 * Arguments
 * * config: The config for how the poll should be displayed, see datum/poll_config
 * * group: The candidates to be polled
 *
 * Returns a list of all mobs who signed up for the poll, OR, in the case that amount_to_pick is equal to 1 the singular mob/null if no available candidates.
 */
/datum/controller/subsystem/polling/proc/poll_candidates(datum/poll_config/config, list/group)
	if(!length(group))
		return
	if(config.role && !config.role_name_text)
		config.role_name_text = config.role
	if(config.role_name_text && !config.question)
		config.question = "Do you want to play as [span_notice(config.role_name_text)]?"
	if(!config.question)
		config.question = "Do you want to play as a special role?"
	log_game("Polling candidates [config.role_name_text ? "for [config.role_name_text]" : "\"[config.question]\""] for [DisplayTimeText(config.poll_time)]")

	// Start firing
	total_polls++

	if(isnull(config.jump_target) && isatom(config.alert_pic))
		config.jump_target = config.alert_pic

	// Apply custom filtering callback
	if (config.check_candidate)
		var/list/filtered_group = list()
		for (var/mob/source as anything in group)
			if (config.check_candidate.Invoke(source))
				filtered_group += source
		group = filtered_group

	var/datum/candidate_poll/new_poll = new(config)
	LAZYADD(currently_polling, new_poll)

	for(var/mob/candidate_mob as anything in group)
		new_poll.show_to(candidate_mob, config.start_signed_up, config.flash_window)

	// Sleep until the time is up
	UNTIL(new_poll.finished)
	if(!config.amount_to_pick)
		return new_poll.signed_up
	if (!length(new_poll.signed_up))
		return null
	for(var/pick in 1 to config.amount_to_pick)
		// There may be less people signed up than amount_to_pick
		// pick_n_take returns the default return value of null if passed an empty list, so just break in that case rather than adding null to the list.
		if(!length(new_poll.signed_up))
			break
		new_poll.chosen_candidates += pick_n_take(new_poll.signed_up)
	if(config.announce_chosen)
		new_poll.announce_chosen(group)
	if(new_poll.chosen_candidates.len == 1)
		var/chosen_one = pick(new_poll.chosen_candidates)
		return chosen_one
	return new_poll.chosen_candidates

/*
* Polls all ghosts
*/
/datum/controller/subsystem/polling/proc/poll_ghost_candidates(datum/poll_config/config)
	var/list/candidates = list()
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		return
	for(var/mob/dead/observer/ghost_player in GLOB.player_list)
		candidates += ghost_player
	config.auto_add_type = POLL_AUTO_ADD_GHOSTS

	return poll_candidates(config, candidates)

/*
* Polls ghosts for a single target and returns one ghost
* Used when you want to make a poll for something (Alien Embryo) and don't want multiple polls running for it at the same time
*/
/datum/controller/subsystem/polling/proc/poll_ghosts_for_target(datum/poll_config/config, atom/movable/checked_target)
	var/static/list/atom/movable/currently_polling_targets = list()
	if(currently_polling_targets.Find(checked_target))
		return
	currently_polling_targets += checked_target
	var/mob/chosen_one = poll_ghost_candidates(config)
	currently_polling_targets -= checked_target
	if(!checked_target || QDELETED(checked_target) || !checked_target.loc)
		return null
	return chosen_one

/*
* Polls all ghosts for a list of targets
* See `fun_balloon.dm`
*/
/datum/controller/subsystem/polling/proc/poll_ghosts_for_targets(datum/poll_config/config, list/checked_targets)
	var/list/candidate_list = poll_ghost_candidates(config)
	for(var/atom/movable/potential_target as anything in checked_targets)
		if(QDELETED(potential_target) || !potential_target.loc)
			checked_targets -= potential_target
	if(!length(checked_targets))
		return list()
	return candidate_list

/*
* Polls all ghosted mentors
*/
/datum/controller/subsystem/polling/proc/poll_mentor_ghost_candidates(datum/poll_config/config)
	var/list/candidates = list()

	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		return candidates
	for(var/mob/dead/observer/ghost_player in GLOB.player_list)
		if(ghost_player.client?.is_mentor())
			candidates += ghost_player

	return poll_candidates(config, candidates)

/datum/controller/subsystem/polling/proc/poll_ghosts_one_choice(datum/poll_config/config)
	if (config.amount_to_pick == 0)
		config.amount_to_pick = 1
	var/list/candidates = poll_ghost_candidates(config)

	return pick(candidates)

/**
 * Starts a persistent poll which stays open until it concludes.
 *
 * Arguments
 * * config: The poll configuration, ignores the time property
 *
 * Returns a candidate_poll datum to cancel the poll early.
 */
/datum/controller/subsystem/polling/proc/poll_candidates_persistently(datum/poll_config/config, list/group)
	if(config.role && !config.role_name_text)
		config.role_name_text = config.role
	if(config.role_name_text && !config.question)
		config.question = "Do you want to play as [span_notice(config.role_name_text)]?"
	if(!config.question)
		config.question = "Do you want to play as a special role?"
	log_game("Polling candidates persistently [config.role_name_text ? "for [config.role_name_text]" : "\"[config.question]\""]")

	// Start firing
	total_polls++

	if(isnull(config.jump_target) && isatom(config.alert_pic))
		config.jump_target = config.alert_pic

	var/datum/candidate_poll/persistent/new_poll = new(config)
	LAZYADD(currently_polling, new_poll)

	// Apply custom filtering callback
	if (config.check_candidate)
		var/list/filtered_group = list()
		for (var/mob/source as anything in group)
			if (config.check_candidate.Invoke(source))
				filtered_group += source
		group = filtered_group

	for(var/mob/candidate_mob as anything in group)
		new_poll.show_to(candidate_mob, config.start_signed_up, config.flash_window)

	return new_poll

/*
* Polls ghosts until someone accepts
*/
/datum/controller/subsystem/polling/proc/poll_ghost_candidates_persistently(datum/poll_config/config)
	var/list/candidates = list()
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		return
	for(var/mob/dead/observer/ghost_player in GLOB.player_list)
		candidates += ghost_player

	config.auto_add_type = POLL_AUTO_ADD_GHOSTS
	var/datum/candidate_poll/poll = poll_candidates_persistently(config, candidates)

	return poll

/datum/controller/subsystem/polling/proc/on_ghost_appeared(datum/source, mob/created_mob)
	SIGNAL_HANDLER
	if (!isobserver(created_mob))
		return
	for (var/datum/candidate_poll/poll in currently_polling)
		if (poll.config.auto_add_type != POLL_AUTO_ADD_GHOSTS)
			continue
		if (poll.config.check_candidate != null)
			if (!poll.config.check_candidate.Invoke(created_mob))
				continue
		INVOKE_ASYNC(poll, TYPE_PROC_REF(/datum/candidate_poll, show_to), created_mob)

/datum/controller/subsystem/polling/proc/is_eligible(mob/potential_candidate, role, check_jobban, the_ignore_category)
	if(isnull(potential_candidate.key) || isnull(potential_candidate.client))
		return FALSE

	if(!potential_candidate.client.should_include_for_role(
		role_preference_key = role,
		banning_key = check_jobban,
		poll_ignore_key = the_ignore_category,
	))
		return FALSE

	if(the_ignore_category)
		if(potential_candidate.ckey in GLOB.poll_ignore[the_ignore_category])
			return FALSE

	return TRUE

/datum/controller/subsystem/polling/proc/polling_finished(datum/candidate_poll/finishing_poll)
	currently_polling -= finishing_poll
	// Trim players who aren't eligible anymore
	var/length_pre_trim = length(finishing_poll.signed_up)
	finishing_poll.trim_candidates()
	log_game("Candidate poll [finishing_poll.config.role_name_text ? "for [finishing_poll.config.role_name_text]" : "\"[finishing_poll.config.question]\""] finished. [length_pre_trim] players signed up, [length(finishing_poll.signed_up)] after trimming")
	finishing_poll.finished = TRUE

	// Take care of updating the remaining screen alerts if a similar poll is found, or deleting them.
	if(length(finishing_poll.alert_buttons))
		for(var/atom/movable/screen/alert/poll_alert/alert as anything in finishing_poll.alert_buttons)
			if(duplicate_message_check(finishing_poll))
				alert.update_stacks_overlay()
			else
				alert.owner.clear_alert("[finishing_poll.poll_key]_poll_alert")

	//More than enough time for the the `UNTIL()` stopping loop in `poll_candidates()` to be over, and the results to be turned in.
	QDEL_IN(finishing_poll, 0.5 SECONDS)

/datum/controller/subsystem/polling/stat_entry(msg)
	msg += "Active: [length(currently_polling)] | Total: [total_polls]"
	var/datum/candidate_poll/soonest_to_complete = get_next_poll_to_finish()
	if(soonest_to_complete)
		msg += " | Next: [DisplayTimeText(soonest_to_complete.time_left())] ([length(soonest_to_complete.signed_up)] candidates)"
	return ..()

///Is there a multiple of the given event type running right now?
/datum/controller/subsystem/polling/proc/duplicate_message_check(datum/candidate_poll/poll_to_check)
	for(var/datum/candidate_poll/running_poll as anything in currently_polling)
		if((running_poll.poll_key == poll_to_check.poll_key && running_poll != poll_to_check) && running_poll.time_left() > 0)
			return TRUE
	return FALSE

/datum/controller/subsystem/polling/proc/get_next_poll_to_finish()
	var/lowest_time_left = INFINITY
	var/next_poll_to_finish
	for(var/datum/candidate_poll/poll as anything in currently_polling)
		var/time_left = poll.time_left()
		if(time_left >= lowest_time_left && time_left < INFINITY)
			continue
		lowest_time_left = time_left
		next_poll_to_finish = poll

	if(isnull(next_poll_to_finish))
		return FALSE

	return next_poll_to_finish
