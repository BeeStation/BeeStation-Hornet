#define IMPORTANT_ACTION_COOLDOWN (60 SECONDS)

#define STATE_BUYING_SHUTTLE "buying_shuttle"
#define STATE_CHANGING_STATUS "changing_status"
#define STATE_MESSAGES "messages"

// The communications computer
/obj/machinery/computer/communications
	name = "communications console"
	desc = "A console used for high-priority announcements and emergencies."
	icon_screen = "comm"
	icon_keyboard = "tech_key"
	req_access = list(ACCESS_HEADS)
	circuit = /obj/item/circuitboard/computer/communications
	light_color = LIGHT_COLOR_BLUE

	/// Cooldown for important actions, such as messaging CentCom or other sectors
	COOLDOWN_DECLARE(static/important_action_cooldown)

	/// The current state of the UI
	var/state = STATE_MESSAGES

	/// The current state of the UI for AIs
	var/cyborg_state = STATE_MESSAGES

	/// The name of the user who logged in
	var/authorize_name

	/// The access that the card had on login
	var/list/authorize_access

	/// The messages this console has been sent
	var/list/datum/comm_message/messages

	/// How many times the alert level has been changed
	/// Used to clear the modal to change alert level
	var/alert_level_tick = 0

	/// The last lines used for changing the status display
	var/static/last_status_display

/obj/machinery/computer/communications/Initialize(mapload)
	. = ..()
	GLOB.shuttle_caller_list += src

/// Are we NOT a silicon, AND we're logged in as the captain?
/obj/machinery/computer/communications/proc/authenticated_as_non_silicon_captain(mob/user)
	if (issilicon(user))
		return FALSE
	return ACCESS_CAPTAIN in authorize_access

/// Are we a silicon, OR we're logged in as the captain?
/obj/machinery/computer/communications/proc/authenticated_as_silicon_or_captain(mob/user)
	if (issilicon(user))
		return TRUE
	return ACCESS_CAPTAIN in authorize_access

/// Are we a silicon, OR logged in?
/obj/machinery/computer/communications/proc/authenticated(mob/user)
	if (issilicon(user))
		return TRUE
	return authenticated

/obj/machinery/computer/communications/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/card/id))
		attack_hand(user)
	else
		return ..()

/obj/machinery/computer/communications/on_emag(mob/user)
	..()
	if (authenticated)
		authorize_access = get_all_accesses()
	to_chat(user, span_danger("You scramble the communication routing circuits!"))
	playsound(src, 'sound/machines/terminal_alert.ogg', 50, 0)

/obj/machinery/computer/communications/ui_act(action, list/params)
	var/static/list/approved_states = list(STATE_BUYING_SHUTTLE, STATE_CHANGING_STATUS, STATE_MESSAGES)

	. = ..()
	if (.)
		return

	if (!has_communication())
		return

	switch (action)
		if ("answerMessage")
			if (!authenticated(usr))
				return
			var/answer_key = params["answer"]
			var/message_index = text2num(params["message"])
			if (!answer_key || !message_index || message_index < 1)
				return
			var/datum/comm_message/message = messages[message_index]
			if (!(answer_key in message.possible_answers) || message.answered)
				return
			message.answered = answer_key
			message.answer_callback.InvokeAsync()
			. = TRUE
		if ("callShuttle")
			if (!authenticated(usr))
				return
			var/reason = trim(params["reason"], MAX_MESSAGE_LEN)
			if (length(reason) < CALL_SHUTTLE_REASON_LENGTH)
				return
			SSshuttle.requestEvac(usr, reason)
			post_status("shuttle")
			. = TRUE
		if ("changeSecurityLevel")
			if (!authenticated_as_silicon_or_captain(usr))
				return

			// Check if they have
			if (!issilicon(usr))
				var/obj/item/held_item = usr.get_active_held_item()
				var/obj/item/card/id/id_card = held_item?.GetID()
				if (!istype(id_card))
					to_chat(usr, span_warning("You need to swipe your ID!"))
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
					return
				if (!(ACCESS_CAPTAIN in id_card.access))
					to_chat(usr, span_warning("You are not authorized to do this!"))
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
					return

			var/new_sec_level = SSsecurity_level.text_level_to_number(params["newSecurityLevel"])
			var/current_sec_level = SSsecurity_level.get_current_level_as_number()
			if (current_sec_level > SEC_LEVEL_BLACK)
				to_chat(usr, span_warning("Alert cannot be manually lowered from the current security level!"))
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
				return
			if (current_sec_level == new_sec_level)
				return

			SSsecurity_level.set_level(new_sec_level)

			to_chat(usr, span_notice("Authorization confirmed. Modifying security level."))
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)

			// Only notify people if an actual change happened
			log_game("[key_name(usr)] has changed the security level to [params["newSecurityLevel"]] with [src] at [AREACOORD(usr)].")
			message_admins("[ADMIN_LOOKUPFLW(usr)] has changed the security level to [params["newSecurityLevel"]] with [src] at [AREACOORD(usr)].")
			deadchat_broadcast(" has changed the security level to [params["newSecurityLevel"]] with [src] at [span_name("[get_area_name(usr, TRUE)]")].", span_name("[usr.real_name]"), usr, message_type=DEADCHAT_ANNOUNCEMENT)

			alert_level_tick += 1
			. = TRUE
		if ("deleteMessage")
			if (!authenticated(usr))
				return
			var/message_index = text2num(params["message"])
			if (!message_index)
				return
			LAZYREMOVE(messages, LAZYACCESS(messages, message_index))
			. = TRUE
		if ("makePriorityAnnouncement")
			if (!authenticated_as_silicon_or_captain(usr))
				return
			var/emagged = obj_flags & EMAGGED
			make_announcement(usr, emagged)
			. = TRUE
		if ("messageAssociates")
			if (!authenticated(usr) || issilicon(usr) || (SSsecurity_level.get_current_level_as_number() < SEC_LEVEL_RED && !authenticated_as_non_silicon_captain(usr)))
				return
			if (!COOLDOWN_FINISHED(src, important_action_cooldown))
				return

			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			var/message = trim(html_encode(params["message"]), MAX_MESSAGE_LEN)

			var/emagged = obj_flags & EMAGGED
			if (emagged)
				message_syndicate(message, usr)
				to_chat(usr, span_danger("SYSERR @l(19833)of(transmit.dm): !@$ MESSAGE TRANSMITTED TO SYNDICATE COMMAND."))
			else
				message_centcom(message, usr)
				to_chat(usr, span_notice("Message transmitted to Central Command."))

			var/associates = emagged ? "the Syndicate": "CentCom"
			usr.log_talk(message, LOG_SAY, tag = "message to [associates]")
			deadchat_broadcast(" has messaged [associates], \"[message]\" at [span_name("[get_area_name(usr, TRUE)]")].", span_name("[usr.real_name]"), usr, message_type = DEADCHAT_ANNOUNCEMENT)
			COOLDOWN_START(src, important_action_cooldown, IMPORTANT_ACTION_COOLDOWN)
			. = TRUE
		if ("purchaseShuttle")
			var/can_buy_shuttles_or_fail_reason = can_buy_shuttles(usr)
			if (can_buy_shuttles_or_fail_reason != TRUE)
				if (can_buy_shuttles_or_fail_reason != FALSE)
					to_chat(usr, span_alert("[can_buy_shuttles_or_fail_reason]"))
				return
			var/list/shuttles = flatten_list(SSmapping.shuttle_templates)
			var/datum/map_template/shuttle/shuttle = locate(params["shuttle"]) in shuttles
			if (!istype(shuttle))
				return
			if (!can_purchase_this_shuttle(shuttle))
				return
			if (!shuttle.prerequisites_met())
				to_chat(usr, span_alert("You have not met the requirements for purchasing this shuttle."))
				return
			var/datum/bank_account/bank_account = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
			if (bank_account.account_balance < shuttle.credit_cost)
				return
			SSshuttle.shuttle_purchased = TRUE
			SSshuttle.existing_shuttle = SSshuttle.emergency
			SSshuttle.action_load(shuttle)
			bank_account.adjust_money(-shuttle.credit_cost)
			minor_announce("[shuttle.name] has been purchased for [shuttle.credit_cost] credits! Purchase authorized by [authorize_name] [shuttle.extra_desc ? " [shuttle.extra_desc]" : ""]" , "Shuttle Purchase")
			message_admins("[ADMIN_LOOKUPFLW(usr)] purchased [shuttle.name].")
			log_game("[key_name(usr)] has purchased [shuttle.name].")
			SSblackbox.record_feedback("text", "shuttle_purchase", 1, shuttle.name)
			//state = STATE_MAIN
			. = TRUE
		if ("recallShuttle")
			// AIs cannot recall the shuttle
			if (!authenticated(usr) || issilicon(usr))
				return
			. = SSshuttle.cancelEvac(usr)
		if ("requestNukeCodes")
			if (!authenticated_as_non_silicon_captain(usr))
				return
			if (!COOLDOWN_FINISHED(src, important_action_cooldown))
				return
			var/reason = trim(html_encode(params["reason"]), MAX_MESSAGE_LEN)
			nuke_request(reason, usr)
			to_chat(usr, span_notice("Request sent."))
			usr.log_message("has requested the nuclear codes from CentCom with reason \"[reason]\"", LOG_SAY)
			priority_announce("The codes for the on-station nuclear self-destruct have been requested by [usr]. Confirmation or denial of this request will be sent shortly.", "Nuclear Self-Destruct Codes Requested", SSstation.announcer.get_rand_report_sound())
			playsound(src, 'sound/machines/terminal_prompt.ogg', 50, FALSE)
			COOLDOWN_START(src, important_action_cooldown, IMPORTANT_ACTION_COOLDOWN)
			. = TRUE
		if ("restoreBackupRoutingData")
			if (!authenticated_as_non_silicon_captain(usr))
				return
			if (!(obj_flags & EMAGGED))
				return
			to_chat(usr, span_notice("Backup routing data restored."))
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			obj_flags &= ~EMAGGED
			. = TRUE
		if ("sendToOtherSector")
			if (!authenticated_as_non_silicon_captain(usr))
				return
			if (!can_send_messages_to_other_sectors(usr))
				return
			if (!COOLDOWN_FINISHED(src, important_action_cooldown))
				return

			var/message = trim(html_encode(params["message"]), MAX_MESSAGE_LEN)
			if (!message)
				return
			if(CHAT_FILTER_CHECK(message))
				to_chat(usr, span_warning("Your message contains forbidden words."))
				return

			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)

			SStopic.crosscomms_send_async("comms_console", message, station_name())
			minor_announce(message, title = "Outgoing message to allied station", html_encode = FALSE)
			usr.log_talk(message, LOG_SAY, tag="message to the other server")
			message_admins("[ADMIN_LOOKUPFLW(usr)] has sent a message to the other server.")
			deadchat_broadcast(" has sent an outgoing message to the other station(s).</span>", "<span class='bold'>[usr.real_name]", usr, message_type = DEADCHAT_ANNOUNCEMENT)

			COOLDOWN_START(src, important_action_cooldown, IMPORTANT_ACTION_COOLDOWN)
			. = TRUE
		if ("setState")
			if (!authenticated(usr))
				return
			if (!(params["state"] in approved_states))
				return
			var/newState = params["state"]
			if (newState == STATE_BUYING_SHUTTLE && can_buy_shuttles(usr) != TRUE)
				return
			set_state(usr, newState)
			playsound(src, "terminal_type", 50, FALSE)
			. = TRUE
		if ("setStatusMessage")
			if (!authenticated(usr))
				return
			var/line_one = reject_bad_text(params["upperText"] || "", MAX_STATUS_LINE_LENGTH)
			var/line_two = reject_bad_text(params["lowerText"] || "", MAX_STATUS_LINE_LENGTH)
			message_admins("[ADMIN_LOOKUPFLW(usr)] changed the Status Message to - [line_one], [line_two] - From a Communications Console.")
			log_game("[key_name(usr)] changed the Status Message to - [line_one], [line_two] - From a Communications Console.")
			post_status("message", line_one, line_two)
			last_status_display = list(line_one, line_two)
			playsound(src, "terminal_type", 50, FALSE)
			. = TRUE
		if ("setStatusPicture")
			if (!authenticated(usr))
				return
			var/picture = params["picture"]
			if (!(picture in GLOB.status_display_approved_pictures))
				return
			if(picture in GLOB.status_display_state_pictures)
				post_status(picture)
			else
				if(picture == "currentalert") // You cannot set Code Blue display during Code Red and similiar
					switch(SSsecurity_level.get_current_level_as_number())
						if(SEC_LEVEL_DELTA)
							post_status("alert", "deltaalert")
						if(SEC_LEVEL_RED)
							post_status("alert", "redalert")
						if(SEC_LEVEL_BLUE)
							post_status("alert", "bluealert")
						if(SEC_LEVEL_GREEN)
							post_status("alert", "greenalert")
				else
					post_status("alert", picture)
			playsound(src, "terminal_type", 50, FALSE)
			. = TRUE
		if ("toggleAuthentication")
			// Log out if we're logged in
			if (authorize_name)
				authenticated = FALSE
				authorize_access = null
				authorize_name = null
				playsound(src, 'sound/machines/terminal_off.ogg', 50, FALSE)
				return TRUE

			if (obj_flags & EMAGGED)
				authenticated = TRUE
				authorize_access = get_all_accesses()
				authorize_name = "Unknown"
				to_chat(usr, span_warning("[src] lets out a quiet alarm as its login is overridden."))
				playsound(src, 'sound/machines/terminal_alert.ogg', 25, FALSE)
			else
				var/obj/item/card/id/id_card = usr.get_idcard(hand_first = TRUE)
				if (check_access(id_card))
					authenticated = TRUE
					authorize_access = id_card.access
					authorize_name = "[id_card.registered_name] - [id_card.assignment]"

			state = STATE_MESSAGES
			playsound(src, 'sound/machines/terminal_on.ogg', 50, FALSE)
			. = TRUE
		if ("toggleEmergencyAccess")
			if (!authenticated_as_silicon_or_captain(usr))
				return
			. = TRUE
			if (GLOB.emergency_access)
				revoke_maint_all_access()
				log_game("[key_name(usr)] disabled emergency maintenance access.")
				message_admins("[ADMIN_LOOKUPFLW(usr)] disabled emergency maintenance access.")
				deadchat_broadcast(" disabled emergency maintenance access at [span_name("[get_area_name(usr, TRUE)]")].", span_name("[usr.real_name]"), usr, message_type = DEADCHAT_ANNOUNCEMENT)
			else
				make_maint_all_access()
				log_game("[key_name(usr)] enabled emergency maintenance access.")
				message_admins("[ADMIN_LOOKUPFLW(usr)] enabled emergency maintenance access.")
				deadchat_broadcast(" enabled emergency maintenance access at [span_name("[get_area_name(usr, TRUE)]")].", span_name("[usr.real_name]"), usr, message_type = DEADCHAT_ANNOUNCEMENT)
		// Request codes for the Captain's Spare ID safe.
		if("requestSafeCodes")
			if(SSjob.assigned_captain)
				to_chat(usr, span_warning("There is already an assigned Captain or Acting Captain on deck!"))
				return

			if(SSjob.safe_code_timer_id)
				to_chat(usr, span_warning("The safe code has already been requested and is being delivered to your station!"))
				return

			if(SSjob.safe_code_requested)
				to_chat(usr, span_warning("The safe code has already been requested and delivered to your station!"))
				return

			if(!SSjob.spare_id_safe_code)
				to_chat(usr, span_warning("There is no safe code to deliver to your station!"))
				return

			var/turf/pod_location = get_turf(src)

			SSjob.safe_code_request_loc = pod_location
			SSjob.safe_code_requested = TRUE
			SSjob.safe_code_timer_id = addtimer(CALLBACK(SSjob, TYPE_PROC_REF(/datum/controller/subsystem/job, send_spare_id_safe_code), pod_location), 120 SECONDS, TIMER_UNIQUE | TIMER_STOPPABLE)
			minor_announce("Due to staff shortages, your station has been approved for delivery of access codes to secure the Captain's Spare ID. Delivery via drop pod at [get_area(pod_location)]. ETA 120 seconds.")
			. = TRUE

/obj/machinery/computer/communications/ui_data(mob/user)
	var/list/data = list(
		"authenticated" = FALSE,
		"emagged" = FALSE,
	)

	var/ui_state = issilicon(user) ? cyborg_state : state

	var/has_connection = has_communication()
	data["hasConnection"] = has_connection

	if(!SSjob.assigned_captain && !SSjob.safe_code_requested && SSjob.spare_id_safe_code && has_connection)
		data["canRequestSafeCode"] = TRUE
		data["safeCodeDeliveryWait"] = 0
	else
		data["canRequestSafeCode"] = FALSE
		if(SSjob.safe_code_timer_id && has_connection)
			data["safeCodeDeliveryWait"] = timeleft(SSjob.safe_code_timer_id)
			data["safeCodeDeliveryArea"] = get_area(SSjob.safe_code_request_loc)
		else
			data["safeCodeDeliveryWait"] = 0
			data["safeCodeDeliveryArea"] = null

	if (authenticated || issilicon(user))
		data["authenticated"] = TRUE
		data["canLogOut"] = !issilicon(user)
		data["page"] = ui_state

		if (obj_flags & EMAGGED)
			data["emagged"] = TRUE

		//Main section is always visible when authenticated
		data["canBuyShuttles"] = can_buy_shuttles(user)
		data["canMakeAnnouncement"] = FALSE
		data["canMessageAssociates"] = !issilicon(user) && SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED
		data["canRecallShuttles"] = !issilicon(user)
		data["canRequestNuke"] = FALSE
		data["canSendToSectors"] = FALSE
		data["canSetAlertLevel"] = FALSE
		data["canToggleEmergencyAccess"] = FALSE
		data["importantActionReady"] = COOLDOWN_FINISHED(src, important_action_cooldown)
		data["shuttleCalled"] = FALSE
		data["shuttleLastCalled"] = FALSE

		data["alertLevel"] = SSsecurity_level.get_current_level_as_text()
		data["authorizeName"] = authorize_name
		data["canLogOut"] = !issilicon(user)
		data["shuttleCanEvacOrFailReason"] = SSshuttle.canEvac(user)

		if (authenticated_as_non_silicon_captain(user))
			data["canMessageAssociates"] = TRUE
			data["canRequestNuke"] = TRUE

		if (can_send_messages_to_other_sectors(user))
			data["canSendToSectors"] = TRUE

		if (authenticated_as_silicon_or_captain(user))
			data["canToggleEmergencyAccess"] = TRUE
			data["emergencyAccess"] = GLOB.emergency_access

			data["alertLevelTick"] = alert_level_tick
			data["canMakeAnnouncement"] = TRUE
			data["canSetAlertLevel"] = issilicon(user) ? "NO_SWIPE_NEEDED" : "SWIPE_NEEDED"

		if (SSshuttle.emergency.mode != SHUTTLE_IDLE && SSshuttle.emergency.mode != SHUTTLE_RECALL)
			data["shuttleCalled"] = TRUE
			data["shuttleRecallable"] = SSshuttle.canRecall()

		if (SSshuttle.emergencyCallAmount)
			data["shuttleCalledPreviously"] = TRUE
			if (SSshuttle.emergencyLastCallLoc)
				data["shuttleLastCalled"] = format_text(SSshuttle.emergencyLastCallLoc.name)

		switch (ui_state)
			if (STATE_MESSAGES)
				data["messages"] = list()

				if (messages)
					for (var/_message in messages)
						var/datum/comm_message/message = _message
						data["messages"] += list(list(
							"answered" = message.answered,
							"content" = message.content,
							"title" = message.title,
							"possibleAnswers" = message.possible_answers,
						))
			if (STATE_BUYING_SHUTTLE)
				var/datum/bank_account/bank_account = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
				var/list/shuttles = list()

				for (var/shuttle_id in SSmapping.shuttle_templates)
					var/datum/map_template/shuttle/shuttle_template = SSmapping.shuttle_templates[shuttle_id]
					if (shuttle_template.credit_cost == INFINITY)
						continue
					if (!can_purchase_this_shuttle(shuttle_template))
						continue
					shuttles += list(list(
						"name" = shuttle_template.name,
						"description" = shuttle_template.description,
						"creditCost" = shuttle_template.credit_cost,
						"illegal" = shuttle_template.illegal_shuttle,
						"danger" = shuttle_template.danger_level,
						"prerequisites" = shuttle_template.prerequisites,
						"ref" = REF(shuttle_template),
					))

				data["budget"] = bank_account.account_balance
				data["shuttles"] = shuttles
			if (STATE_CHANGING_STATUS)
				data["upperText"] = last_status_display ? last_status_display[1] : ""
				data["lowerText"] = last_status_display ? last_status_display[2] : ""

	return data

/obj/machinery/computer/communications/ui_interact(mob/user, datum/tgui/ui)
	play_click_sound(user)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "CommunicationsConsole")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/communications/ui_static_data(mob/user)
	return list(
		"callShuttleReasonMinLength" = CALL_SHUTTLE_REASON_LENGTH,
		"maxStatusLineLength" = MAX_STATUS_LINE_LENGTH,
		"maxMessageLength" = MAX_MESSAGE_LEN,
	)

/// Returns whether or not the communications console can communicate with the station
/obj/machinery/computer/communications/proc/has_communication()
	var/turf/current_turf = get_turf(src)
	var/z_level = current_turf.z
	return is_station_level(z_level) || is_centcom_level(z_level)

/obj/machinery/computer/communications/proc/set_state(mob/user, new_state)
	if (issilicon(user))
		cyborg_state = new_state
	else
		state = new_state

/// Returns TRUE if the user can buy shuttles.
/// If they cannot, returns FALSE or a string detailing why.
/obj/machinery/computer/communications/proc/can_buy_shuttles(mob/user)
	if (!SSmapping.current_map.allow_custom_shuttles)
		return FALSE
	if (!authenticated_as_non_silicon_captain(user))
		return FALSE
	if (SSshuttle.emergency.mode != SHUTTLE_RECALL && SSshuttle.emergency.mode != SHUTTLE_IDLE)
		return "The shuttle is already in transit."
	if (SSshuttle.shuttle_purchased)
		return "A replacement shuttle has already been purchased."
	return TRUE

/// Returns whether we are authorized to buy this specific shuttle.
/// Does not handle prerequisite checks, as those should still *show*.
/obj/machinery/computer/communications/proc/can_purchase_this_shuttle(datum/map_template/shuttle/shuttle_template)
	if(shuttle_template.credit_cost == INFINITY)
		return FALSE
	var/obj/item/circuitboard/computer/communications/CM = circuit
	if(shuttle_template.illegal_shuttle && !((obj_flags & EMAGGED) || CM.insecure))
		return FALSE
	if(!shuttle_template.can_be_bought && !shuttle_template.illegal_shuttle)
		return FALSE

	return TRUE

/obj/machinery/computer/communications/proc/can_send_messages_to_other_sectors(mob/user)
	if (!authenticated_as_non_silicon_captain(user))
		return

	return length(CONFIG_GET(keyed_list/cross_server)) > 0

/obj/machinery/computer/communications/proc/make_announcement(mob/living/user, syndicate)
	var/is_ai = issilicon(user)
	if(!SScommunications.can_announce(user, is_ai))
		to_chat(user, span_alert("Intercomms recharging. Please stand by."))
		return
	var/input = tgui_input_text(user, "Please choose a message to announce to the station crew.", "Make Priority Announcement")
	if(!input || !user.canUseTopic(src, !issilicon(usr)))
		return
	if(CHAT_FILTER_CHECK(input))
		to_chat(user, span_warning("You cannot send an announcement that contains prohibited words."))
		return
	if(user.try_speak(input))
		//Adds slurs and so on. Someone should make this use languages too.
		var/list/input_data = user.treat_message(input)
		input = input_data["message"]
	else
		//No cheating, mime/random mute guy!
		input = "..."
		user.visible_message(
			span_notice("You leave the mic on in awkward silence..."),
			span_notice("[user] holds down [src]'s announcement button, leaving the mic on in awkward silence."),
			span_hear("You hear an awkward silence, somehow."),
			vision_distance = 4,
		)

	SScommunications.make_announcement(user, is_ai, input, null, syndicate)
	deadchat_broadcast(" made a priority announcement from [span_name("[get_area_name(user, TRUE)]")].", span_name("[user.real_name]"), user, message_type=DEADCHAT_ANNOUNCEMENT)

/obj/machinery/computer/communications/proc/post_status(command, data1, data2)

	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

	if(!frequency)
		return

	var/datum/signal/status_signal = new(list("command" = command))
	switch(command)
		if("message")
			status_signal.data["top_text"] = data1
			status_signal.data["bottom_text"] = data2
		if("alert")
			status_signal.data["picture_state"] = data1

	frequency.post_signal(src, status_signal)

/obj/machinery/computer/communications/Destroy()
	GLOB.shuttle_caller_list -= src
	SSshuttle.autoEvac()
	return ..()

/// Override the cooldown for special actions
/// Used in places such as CentCom messaging back so that the crew can answer right away
/obj/machinery/computer/communications/proc/override_cooldown()
	COOLDOWN_RESET(src, important_action_cooldown)

/obj/machinery/computer/communications/proc/add_message(datum/comm_message/new_message)
	LAZYADD(messages, new_message)
	ui_update()

/datum/comm_message
	var/title
	var/content
	var/list/possible_answers = list()
	var/answered
	var/datum/callback/answer_callback

/datum/comm_message/New(new_title,new_content,new_possible_answers)
	..()
	if(new_title)
		title = new_title
	if(new_content)
		content = new_content
	if(new_possible_answers)
		possible_answers = new_possible_answers

#undef IMPORTANT_ACTION_COOLDOWN
#undef STATE_BUYING_SHUTTLE
#undef STATE_CHANGING_STATUS
#undef STATE_MESSAGES
