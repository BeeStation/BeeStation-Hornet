SUBSYSTEM_DEF(polling)
	name = "Polling"
	flags = SS_BACKGROUND | SS_NO_INIT
	wait = 1 SECONDS
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	/// List of polls currently ongoing, to be checked on next fire()
	var/list/datum/candidate_poll/currently_polling
	/// Number of polls performed since the start
	var/total_polls = 0

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
 * * question: Optional, The question to ask the candidates. If null, a default question will be used. ("Do you want to play as role?")
 * * role: Optional, A role preference (/datum/role_preference/roundstart/traitor) to pass, it won't show to any candidates who don't have it in their preferences.
 * * check_jobban: Optional, What jobban role / flag to check, it won't show to any candidates who have this jobban.
 * * poll_time: How long the poll will last.
 * * ignore_category: Optional, A poll category. If a candidate has this category in their ignore list, they won't be polled.
 * * flash_window: If TRUE, the candidate's window will flash when they're polled.
 * * list/group: A list of candidates to poll.
 * * alert_pic: Optional, An /atom or an /image to display on the poll alert.
 * * jump_target: An /atom to teleport/jump to, if alert_pic is an /atom defaults to that.
 * * role_name_text: Optional, A string to display in logging / the (default) question. If null, the role name will be used.
 * * list/custom_response_messages: Optional, A list of strings to use as responses to the poll. If null, the default responses will be used. see __DEFINES/polls.dm for valid keys to use.
 * * start_signed_up: If TRUE, all candidates will start signed up for the poll, making it opt-out rather than opt-in.
 * * amount_to_pick: Lets you pick candidates and return a single mob or list of mobs that were chosen.
 * * chat_text_border_icon: Object or path to make an icon of to decorate the chat announcement.
 * * announce_chosen: Whether we should announce the chosen candidates in chat. This is ignored unless amount_to_pick is greater than 0.
 *
 * Returns a list of all mobs who signed up for the poll, OR, in the case that amount_to_pick is equal to 1 the singular mob/null if no available candidates.
 */
/datum/controller/subsystem/polling/proc/poll_candidates(
	question,
	role,
	check_jobban,
	poll_time = 30 SECONDS,
	ignore_category = null,
	flash_window = TRUE,
	list/group = null,
	alert_pic,
	jump_target,
	role_name_text,
	list/custom_response_messages,
	start_signed_up = FALSE,
	amount_to_pick = 0,
	chat_text_border_icon,
	announce_chosen = TRUE
)
	if(!length(group))
		return
	if(role && !role_name_text)
		role_name_text = role
	if(role_name_text && !question)
		question = "Do you want to play as [span_notice(role_name_text)]?"
	if(!question)
		question = "Do you want to play as a special role?"
	log_game("Polling candidates [role_name_text ? "for [role_name_text]" : "\"[question]\""] for [DisplayTimeText(poll_time)]")

	// Start firing
	total_polls++

	if(isnull(jump_target) && isatom(alert_pic))
		jump_target = alert_pic

	var/datum/candidate_poll/new_poll = new(
		role_name_text,
		role,
		question,
		poll_time,
		ignore_category,
		jump_target,
		custom_response_messages,
		check_jobban,
		alert_pic,
		chat_text_border_icon
	)
	LAZYADD(currently_polling, new_poll)

	for(var/mob/candidate_mob as anything in group)
		new_poll.show_to(candidate_mob, start_signed_up, flash_window)

	// Sleep until the time is up
	UNTIL(new_poll.finished)
	if(!amount_to_pick)
		return new_poll.signed_up
	if (!length(new_poll.signed_up))
		return null
	for(var/pick in 1 to amount_to_pick)
		// There may be less people signed up than amount_to_pick
		// pick_n_take returns the default return value of null if passed an empty list, so just break in that case rather than adding null to the list.
		if(!length(new_poll.signed_up))
			break
		new_poll.chosen_candidates += pick_n_take(new_poll.signed_up)
	if(announce_chosen)
		new_poll.announce_chosen(group)
	if(new_poll.chosen_candidates.len == 1)
		var/chosen_one = pick(new_poll.chosen_candidates)
		return chosen_one
	return new_poll.chosen_candidates

/*
* Polls all ghosts
*/
/datum/controller/subsystem/polling/proc/poll_ghost_candidates(
	question,
	role,
	check_jobban,
	poll_time = 30 SECONDS,
	ignore_category = null,
	flashwindow = TRUE,
	alert_pic,
	jump_target,
	role_name_text,
	list/custom_response_messages,
	start_signed_up = FALSE,
	amount_to_pick = 0,
	chat_text_border_icon,
	announce_chosen = TRUE,
)
	var/list/candidates = list()
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		return
	for(var/mob/dead/observer/ghost_player in GLOB.player_list)
		candidates += ghost_player

	return poll_candidates(question, role, check_jobban, poll_time, ignore_category, flashwindow, candidates, alert_pic, jump_target, role_name_text, custom_response_messages, start_signed_up, amount_to_pick, chat_text_border_icon, announce_chosen)

/*
* Polls ghosts for a single target and returns one ghost
* Used when you want to make a poll for something (Alien Embryo) and don't want multiple polls running for it at the same time
*/
/datum/controller/subsystem/polling/proc/poll_ghosts_for_target(
	question,
	role,
	check_jobban,
	poll_time = 30 SECONDS,
	atom/movable/checked_target,
	ignore_category = null,
	flashwindow = TRUE,
	alert_pic,
	jump_target,
	role_name_text,
	list/custom_response_messages,
	start_signed_up = FALSE,
	chat_text_border_icon,
	announce_chosen = TRUE,
)
	var/static/list/atom/movable/currently_polling_targets = list()
	if(currently_polling_targets.Find(checked_target))
		return
	currently_polling_targets += checked_target
	var/mob/chosen_one = poll_ghost_candidates(question, role, check_jobban, poll_time, ignore_category, flashwindow, alert_pic, jump_target, role_name_text, custom_response_messages, start_signed_up, amount_to_pick = 1, chat_text_border_icon = chat_text_border_icon, announce_chosen = announce_chosen)
	currently_polling_targets -= checked_target
	if(!checked_target || QDELETED(checked_target) || !checked_target.loc)
		return null
	return chosen_one

/*
* Polls all ghosts for a list of targets
* See `fun_balloon.dm`
*/
/datum/controller/subsystem/polling/proc/poll_ghosts_for_targets(
	question,
	role,
	check_jobban,
	poll_time = 30 SECONDS,
	list/checked_targets,
	ignore_category = null,
	flashwindow = TRUE,
	alert_pic,
	jump_target,
	role_name_text,
	list/custom_response_messages,
	start_signed_up = FALSE,
	chat_text_border_icon,
)
	var/list/candidate_list = poll_ghost_candidates(question, role, check_jobban, poll_time, ignore_category, flashwindow, alert_pic, jump_target, role_name_text, custom_response_messages, start_signed_up, chat_text_border_icon = chat_text_border_icon)
	for(var/atom/movable/potential_target as anything in checked_targets)
		if(QDELETED(potential_target) || !potential_target.loc)
			checked_targets -= potential_target
	if(!length(checked_targets))
		return list()
	return candidate_list

/*
* Polls all ghosted mentors
*/
/datum/controller/subsystem/polling/proc/poll_mentor_ghost_candidates(
	question,
	role,
	check_jobban,
	poll_time = 30 SECONDS,
	ignore_category = null,
	flashwindow = TRUE,
	alert_pic,
	jump_target,
	role_name_text,
	list/custom_response_messages,
	start_signed_up = FALSE,
	amount_to_pick = 0,
	chat_text_border_icon,
	announce_chosen = TRUE,
)
	var/list/candidates = list()

	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		return candidates
	for(var/mob/dead/observer/ghost_player in GLOB.player_list)
		if(ghost_player.client?.is_mentor())
			candidates += ghost_player

	return poll_candidates(question, role, check_jobban, poll_time, ignore_category, flashwindow, candidates, alert_pic, jump_target, role_name_text, custom_response_messages, start_signed_up, amount_to_pick, chat_text_border_icon, announce_chosen)

/datum/controller/subsystem/polling/proc/poll_ghosts_one_choice(
	question,
	role,
	check_jobban,
	poll_time = 30 SECONDS,
	ignore_category = null,
	flashwindow = TRUE,
	alert_pic,
	jump_target,
	role_name_text,
	list/custom_response_messages,
	start_signed_up = FALSE,
	amount_to_pick = 0,
	chat_text_border_icon,
	announce_chosen = TRUE,
)
	var/list/candidates = poll_ghost_candidates(question, role, check_jobban, poll_time, ignore_category, flashwindow, alert_pic, jump_target, role_name_text, custom_response_messages, start_signed_up, amount_to_pick = 1, chat_text_border_icon = chat_text_border_icon, announce_chosen = announce_chosen)

	return pick(candidates)

/**
 * Starts a persistent poll which stays open until it concludes.
 *
 * Arguments
 * * question: Optional, The question to ask the candidates. If null, a default question will be used. ("Do you want to play as role?")
 * * role: Optional, A role preference (/datum/role_preference/roundstart/traitor) to pass, it won't show to any candidates who don't have it in their preferences.
 * * check_jobban: Optional, What jobban role / flag to check, it won't show to any candidates who have this jobban.
 * * ignore_category: Optional, A poll category. If a candidate has this category in their ignore list, they won't be polled.
 * * flash_window: If TRUE, the candidate's window will flash when they're polled.
 * * list/group: A list of candidates to poll.
 * * alert_pic: Optional, An /atom or an /image to display on the poll alert.
 * * jump_target: An /atom to teleport/jump to, if alert_pic is an /atom defaults to that.
 * * role_name_text: Optional, A string to display in logging / the (default) question. If null, the role name will be used.
 * * list/custom_response_messages: Optional, A list of strings to use as responses to the poll. If null, the default responses will be used. see __DEFINES/polls.dm for valid keys to use.
 * * amount_to_pick: Lets you pick candidates and return a single mob or list of mobs that were chosen.
 * * chat_text_border_icon: Object or path to make an icon of to decorate the chat announcement.
 * * announce_chosen: Whether we should announce the chosen candidates in chat. This is ignored unless amount_to_pick is greater than 0.
 *
 * Returns a candidate_poll datum to cancel the poll early.
 */
/datum/controller/subsystem/polling/proc/poll_candidates_persistently(
	question,
	role,
	check_jobban,
	ignore_category = null,
	flash_window = FALSE,
	list/group = null,
	alert_pic,
	jump_target,
	role_name_text,
	list/custom_response_messages,
	amount_to_pick = 0,
	chat_text_border_icon,
	announce_chosen = TRUE
)
	if(!length(group))
		return
	if(role && !role_name_text)
		role_name_text = role
	if(role_name_text && !question)
		question = "Do you want to play as [span_notice(role_name_text)]?"
	if(!question)
		question = "Do you want to play as a special role?"
	log_game("Polling candidates persistently [role_name_text ? "for [role_name_text]" : "\"[question]\""]")

	// Start firing
	total_polls++

	if(isnull(jump_target) && isatom(alert_pic))
		jump_target = alert_pic

	var/datum/candidate_poll/persistent/new_poll = new(
		role_name_text,
		role,
		question,
		0,
		ignore_category,
		jump_target,
		custom_response_messages,
		check_jobban,
		alert_pic,
		chat_text_border_icon
	)
	LAZYADD(currently_polling, new_poll)

	for(var/mob/candidate_mob as anything in group)
		new_poll.show_to(candidate_mob, flash_window)

	return new_poll

/*
* Polls ghosts until someone accepts
*/
/datum/controller/subsystem/polling/proc/poll_ghost_candidates_persistently(
	question,
	role,
	check_jobban,
	ignore_category = null,
	flashwindow = TRUE,
	alert_pic,
	jump_target,
	role_name_text,
	list/custom_response_messages,
	amount_to_pick = 0,
	chat_text_border_icon,
	announce_chosen = TRUE,
)
	var/list/candidates = list()
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		return
	for(var/mob/dead/observer/ghost_player in GLOB.player_list)
		candidates += ghost_player

	var/datum/candidate_poll/poll = poll_candidates_persistently(question, role, check_jobban, ignore_category, flashwindow, candidates, alert_pic, jump_target, role_name_text, custom_response_messages, amount_to_pick, chat_text_border_icon, announce_chosen)

	return poll

/datum/controller/subsystem/polling/proc/on_ghost_appeared(datum/source, mob/created_mob)
	SIGNAL_HANDLER
	if (isobserver(created_mob))
		return

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
	log_game("Candidate poll [finishing_poll.role ? "for [finishing_poll.role]" : "\"[finishing_poll.question]\""] finished. [length_pre_trim] players signed up, [length(finishing_poll.signed_up)] after trimming")
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
