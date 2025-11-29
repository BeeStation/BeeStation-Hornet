/// The datum that describes one instance of candidate polling
/datum/candidate_poll
	/// Settings for the poll
	var/datum/poll_config/config
	/// The players who signed up to this poll
	var/list/mob/signed_up
	/// the linked alert buttons
	var/list/atom/movable/screen/alert/poll_alert/alert_buttons = list()
	/// The world.time at which the poll was created
	var/time_started
	/// Whether the polling is finished
	var/finished = FALSE
	/// Used to categorize in the alerts system and identify polls of same question+role so we can stack the alert buttons
	var/poll_key
	///Response messages sent in specific key areas for full customization of polling.
	var/list/response_messages = list(
		POLL_RESPONSE_SIGNUP = "You have signed up for %ROLE%! A candidate will be picked randomly soon.",
		POLL_RESPONSE_ALREADY_SIGNED = "You have already signed up for this!",
		POLL_RESPONSE_NOT_SIGNED = "You aren't signed up for this!",
		POLL_RESPONSE_TOO_LATE_TO_UNREGISTER = "It's too late to unregister yourself, selection has already begun!",
		POLL_RESPONSE_UNREGISTERED = "You have been unregistered as a candidate for %ROLE%. You can sign up again before the poll ends.",
	)
	/// List of candidates chosen by the poll
	var/list/chosen_candidates = list()

/datum/candidate_poll/New(datum/poll_config/config)
	if (config == null)
		CRASH("Assertion Violation: Creating a poll without passing a valid config for that poll.")
	signed_up = list()
	time_started = world.time
	poll_key = "[config.question]_[config.role ? config.role : "0"]"
	src.config = config
	if(length(config.custom_response_messages))
		response_messages = config.custom_response_messages
	for(var/individual_message in response_messages)
		response_messages[individual_message] = replacetext(response_messages[individual_message], "%ROLE%", config.role_name_text)
	// Add to spawners
	if (config.include_in_spawners)
		LAZYADD(GLOB.mob_spawners["[config.role_name_text]"], src)
		SSmobs.update_spawners()
	return ..()

/datum/candidate_poll/Destroy()
	if(src in SSpolling.currently_polling)
		SSpolling.polling_finished(src)
		return QDEL_HINT_IWILLGC // the above proc will call QDEL_IN(src, 0.5 SECONDS)
	config.jump_target = null
	signed_up = null
	// Remove from spawners
	if (config.include_in_spawners)
		var/list/spawners = GLOB.mob_spawners[config.role_name_text]
		LAZYREMOVE(spawners, src)
		if(!LAZYLEN(spawners))
			GLOB.mob_spawners -= config.role_name_text
		SSmobs.update_spawners()
	return ..()

/datum/candidate_poll/proc/clear_alert_ref(atom/movable/screen/alert/poll_alert/source)
	SIGNAL_HANDLER
	alert_buttons -= source

/datum/candidate_poll/proc/sign_up(mob/candidate, silent = FALSE, skip_confirmation = FALSE)
	if(!istype(candidate) || isnull(candidate.key) || isnull(candidate.client))
		return FALSE
	if(candidate in signed_up)
		if(!silent)
			to_chat(candidate, span_warning(response_messages[POLL_RESPONSE_ALREADY_SIGNED]))
		return FALSE
	if(time_left() <= 0)
		if(!silent)
			to_chat(candidate, span_danger("Sorry, you were too late for the consideration!"))
			SEND_SOUND(candidate, 'sound/machines/buzz-sigh.ogg')
		return FALSE

	if (!skip_confirmation && config.requires_confirmation)
		if (tgui_alert(candidate, "Are you sure you want to sign up to be \a [config.role_name_text]?", "Confirm Action", list("Yes", "No"), 10 SECONDS) != "Yes")
			return FALSE
		// Re-check all initial conditions
		if(!istype(candidate) || isnull(candidate.key) || isnull(candidate.client))
			return FALSE
		if(candidate in signed_up)
			if(!silent)
				to_chat(candidate, span_warning(response_messages[POLL_RESPONSE_ALREADY_SIGNED]))
			return FALSE
		if(time_left() <= 0)
			if(!silent)
				to_chat(candidate, span_danger("Sorry, you were too late for the consideration!"))
				SEND_SOUND(candidate, 'sound/machines/buzz-sigh.ogg')
			return FALSE

	signed_up += candidate
	if(!silent)
		to_chat(candidate, span_notice(response_messages[POLL_RESPONSE_SIGNUP]))
		// Sign them up for any other polls with the same mob type
		for(var/datum/candidate_poll/existing_poll as anything in SSpolling.currently_polling)
			if(src != existing_poll && poll_key == existing_poll.poll_key && !(candidate in existing_poll.signed_up))
				existing_poll.sign_up(candidate, TRUE)
	for(var/atom/movable/screen/alert/poll_alert/linked_button as anything in alert_buttons)
		linked_button.update_candidates_number_overlay()
	return TRUE

/datum/candidate_poll/proc/remove_candidate(mob/candidate, silent = FALSE)
	if(!istype(candidate) || isnull(candidate.key) || isnull(candidate.client))
		return FALSE
	if(!(candidate in signed_up))
		if(!silent)
			to_chat(candidate, span_warning(response_messages[POLL_RESPONSE_NOT_SIGNED]))
		return FALSE

	if(time_left() <= 0)
		if(!silent)
			to_chat(candidate, span_danger(response_messages[POLL_RESPONSE_TOO_LATE_TO_UNREGISTER]))
		return FALSE

	signed_up -= candidate
	if(!silent)
		to_chat(candidate, span_danger(response_messages[POLL_RESPONSE_UNREGISTERED]))

		for(var/datum/candidate_poll/existing_poll as anything in SSpolling.currently_polling)
			if(src != existing_poll && poll_key == existing_poll.poll_key && (candidate in existing_poll.signed_up))
				existing_poll.remove_candidate(candidate, TRUE)
	for(var/atom/movable/screen/alert/poll_alert/linked_button as anything in alert_buttons)
		linked_button.update_candidates_number_overlay()
	return TRUE

/datum/candidate_poll/proc/do_never_for_this_round(mob/candidate)
	var/list/ignore_list = GLOB.poll_ignore[config.ignore_category]
	if(!ignore_list)
		GLOB.poll_ignore[config.ignore_category] = list()
	GLOB.poll_ignore[config.ignore_category] += candidate.ckey
	to_chat(candidate, span_danger("Choice registered: Never for this round."))
	remove_candidate(candidate, silent = TRUE)

/datum/candidate_poll/proc/undo_never_for_this_round(mob/candidate)
	GLOB.poll_ignore[config.ignore_category] -= candidate.ckey
	to_chat(candidate, span_notice("Choice registered: Eligible for this round"))

/datum/candidate_poll/proc/trim_candidates()
	list_clear_nulls(signed_up)
	for(var/mob/candidate as anything in signed_up)
		if(isnull(candidate.key) || isnull(candidate.client))
			signed_up -= candidate

/datum/candidate_poll/proc/time_left()
	return config.poll_time - (world.time - time_started)

/// Print to chat which candidate was selected
/datum/candidate_poll/proc/announce_chosen(list/poll_recipients)
	if(!length(chosen_candidates))
		return
	for(var/mob/chosen in chosen_candidates)
		var/client/chosen_client = chosen.client
		for(var/mob/poll_recipient as anything in poll_recipients)
			to_chat(poll_recipient, span_ooc("[isobserver(poll_recipient) ? FOLLOW_LINK(poll_recipient, chosen_client.mob) : null][span_warning(" [full_capitalize(config.role)] Poll: ")]Player was selected."))

/datum/candidate_poll/proc/show_to(mob/candidate_mob, start_signed_up = FALSE, flash_window = FALSE)
	if(!candidate_mob.client)
		return
	// Universal opt-out for all players.
	if(!SSpolling.is_eligible(candidate_mob, config.role, config.check_jobban, config.ignore_category))
		return

	if(start_signed_up)
		sign_up(candidate_mob, TRUE)
	if(flash_window && !config.silent)
		window_flash(candidate_mob.client)

	var/category = "[poll_key]_poll_alert"

	// If we somehow send two polls for the same mob type, but with a duration on the second one shorter than the time left on the first one,
	// we need to keep the first one's timeout rather than use the shorter one
	var/atom/movable/screen/alert/poll_alert/current_alert = LAZYACCESS(candidate_mob.alerts, category)
	var/alert_time = config.poll_time
	var/datum/candidate_poll/alert_poll = src
	if(current_alert && current_alert.timeout > (world.time + config.poll_time - world.tick_lag))
		alert_time = current_alert.timeout - world.time + world.tick_lag
		alert_poll = current_alert.poll

	// Send them an on-screen alert
	var/atom/movable/screen/alert/poll_alert/poll_alert_button = create_alert(candidate_mob, alert_poll, category, alert_time, start_signed_up, flash_window)
	if(!poll_alert_button)
		return

	alert_buttons += poll_alert_button
	RegisterSignal(poll_alert_button, COMSIG_QDELETING, TYPE_PROC_REF(/datum/candidate_poll, clear_alert_ref))



	// Sign up inheritance and stacking
	for(var/datum/candidate_poll/other_poll as anything in SSpolling.currently_polling)
		if(src == other_poll || poll_key != other_poll.poll_key)
			continue
		// If there's already a poll for an identical mob type ongoing and the client is signed up for it, sign them up for this one
		if((candidate_mob in other_poll.signed_up) && src.sign_up(candidate_mob, TRUE))
			break

	// Image to display
	var/image/poll_image
	if(ispath(config.alert_pic, /atom) || isatom(config.alert_pic))
		poll_image = new /mutable_appearance(config.alert_pic)
		poll_image.layer = FLOAT_LAYER
		poll_image.plane = poll_alert_button.plane
		poll_image.pixel_z = 0
	else if(!isnull(config.alert_pic))
		poll_image = config.alert_pic
	else
		poll_image = image('icons/effects/effects.dmi', icon_state = "static")
		poll_image.layer = FLOAT_LAYER
		poll_image.plane = poll_alert_button.plane

	if(poll_image)
		poll_alert_button.add_overlay(poll_image)

	// Chat message
	var/act_jump = ""
	var/custom_link_style_start = "<style>a:visited{color:Crimson !important}</style>"
	var/custom_link_style_end = "style='color:DodgerBlue;font-weight:bold;-dm-text-outline: 1px black'"
	if(isatom(config.alert_pic) && isobserver(candidate_mob))
		act_jump = "[custom_link_style_start]<a href='byond://?src=[REF(poll_alert_button)];jump=1'[custom_link_style_end]>\[Teleport\]</a>"
	var/act_signup = "[custom_link_style_start]<a href='byond://?src=[REF(poll_alert_button)];signup=1'[custom_link_style_end]>\[[start_signed_up ? "Opt out" : "Sign Up"]\]</a>"
	var/act_never = ""
	if(config.ignore_category)
		act_never = "[custom_link_style_start]<a href='byond://?src=[REF(poll_alert_button)];never=1'[custom_link_style_end]>\[Never For This Round\]</a>"

	if(!SSpolling.duplicate_message_check(alert_poll) && !config.silent) //Only notify people once. They'll notice if there are multiple and we don't want to spam people.
		// ghost poll sounds
		if(candidate_mob.client?.prefs.read_preference(/datum/preference/toggle/sound_ghostpoll))
			candidate_mob.playsound_local(null, 'sound/misc/prompt.ogg', 50)

		var/surrounding_icon
		if(config.chat_text_border_icon)
			var/image/surrounding_image
			if(!ispath(config.chat_text_border_icon))
				var/mutable_appearance/border_image = config.chat_text_border_icon
				surrounding_image = border_image
			else
				surrounding_image = image(config.chat_text_border_icon)
			surrounding_icon = icon2html(surrounding_image, candidate_mob, extra_classes = "bigicon")
		var/final_message = examine_block("<span style='text-align:center;display:block'>[surrounding_icon] <span style='font-size:1.2em'>[span_ooc(config.question)]</span> [surrounding_icon]\n[act_jump]      [act_signup]      [act_never]</span>")
		to_chat(candidate_mob, final_message)

	// Start processing it so it updates visually the timer
	START_PROCESSING(SSprocessing, poll_alert_button)

/datum/candidate_poll/proc/create_alert(mob/candidate_mob, datum/candidate_poll/alert_poll, category, alert_time, start_signed_up = FALSE, flash_window = FALSE)
	var/atom/movable/screen/alert/poll_alert/poll_alert_button = candidate_mob.throw_alert(category, /atom/movable/screen/alert/poll_alert, timeout_override = alert_time, no_anim = TRUE)
	if(!poll_alert_button)
		return null
	poll_alert_button.icon = ui_style2icon(candidate_mob.client?.prefs?.read_preference(/datum/preference/choiced/ui_style))
	poll_alert_button.desc = "[config.question]"
	poll_alert_button.show_time_left = TRUE
	poll_alert_button.poll = alert_poll
	poll_alert_button.set_role_overlay()
	poll_alert_button.update_stacks_overlay()
	poll_alert_button.update_candidates_number_overlay()
	poll_alert_button.update_signed_up_overlay()
	return poll_alert_button

// ================================
// Persistent Candidate Poll
// ================================

/datum/candidate_poll/persistent
	/// Called when a mob signs up, passing thruogh the
	/// persistent poll as the first argument, and the list
	/// of candidates as the second
	var/datum/callback/on_signup

/datum/candidate_poll/persistent/sign_up(mob/candidate, silent = FALSE, skip_confirmation = FALSE)
	if (!..())
		return FALSE
	on_signup?.Invoke(src, signed_up)
	return TRUE

/datum/candidate_poll/persistent/time_left()
	return INFINITY

/datum/candidate_poll/persistent/create_alert(mob/candidate_mob, datum/candidate_poll/alert_poll, category, alert_time, start_signed_up = FALSE, flash_window = FALSE)
	var/atom/movable/screen/alert/poll_alert/poll_alert_button = candidate_mob.throw_alert(category, /atom/movable/screen/alert/poll_alert, no_anim = TRUE)
	if(!poll_alert_button)
		return null
	poll_alert_button.icon = ui_style2icon(candidate_mob.client?.prefs?.read_preference(/datum/preference/choiced/ui_style))
	poll_alert_button.desc = "[config.question]"
	poll_alert_button.show_time_left = FALSE
	poll_alert_button.poll = alert_poll
	poll_alert_button.set_role_overlay()
	poll_alert_button.update_stacks_overlay()
	poll_alert_button.update_candidates_number_overlay()
	poll_alert_button.update_signed_up_overlay()
	poll_alert_button.timeout = INFINITY
	return poll_alert_button

/datum/candidate_poll/persistent/proc/end_poll()
	SSpolling.polling_finished(src)
