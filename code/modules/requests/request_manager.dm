GLOBAL_DATUM_INIT(requests, /datum/request_manager, new)

/**
 * # Request Manager
 *
 * Handles all player requests (prayers, centcom requests, syndicate requests)
 * that occur in the duration of a round.
 */
/datum/request_manager
	/// Associative list of ckey -> list of requests
	var/list/requests = list()
	/// List where requests can be accessed by ID
	var/list/requests_by_id = list()

/datum/request_manager/Destroy(force, ...)
	QDEL_LIST(requests)
	return ..()

/**
 * Used in the new client pipeline to catch when clients are reconnecting and need to have their
 * reference re-assigned to the 'owner' variable of any requests
 *
 * Arguments:
 * * C - The client who is logging in
 */
/datum/request_manager/proc/client_login(client/C)
	if (!requests[C.ckey])
		return
	for (var/datum/request/request as anything in requests[C.ckey])
		request.owner = C

/**
 * Used in the destroy client pipeline to catch when clients are disconnecting and need to have their
 * reference nulled on the 'owner' variable of any requests
 *
 * Arguments:
 * * C - The client who is logging out
 */
/datum/request_manager/proc/client_logout(client/C)
	if (!requests[C.ckey])
		return
	for (var/datum/request/request as anything in requests[C.ckey])
		request.owner = null

/**
 * Creates a request for a prayer, and notifies admins who have the sound notifications enabled when appropriate
 *
 * Arguments:
 * * C - The client who is praying
 * * message - The prayer
 * * is_chaplain - Boolean operator describing if the prayer is from a chaplain
 */
/datum/request_manager/proc/pray(client/C, message, is_chaplain)
	request_for_client(C, REQUEST_PRAYER, message)
	for(var/client/admin in GLOB.admins)
		if(is_chaplain && admin.prefs.chat_toggles & CHAT_PRAYER && admin.prefs.toggles & PREFTOGGLE_SOUND_PRAYERS)
			SEND_SOUND(admin, sound('sound/effects/pray.ogg'))

/**
 * Creates a request for a Centcom message
 *
 * Arguments:
 * * C - The client who is sending the request
 * * message - The message
 */
/datum/request_manager/proc/message_centcom(client/C, message)
	request_for_client(C, REQUEST_CENTCOM, message)

/**
 * Creates a request for a Syndicate message
 *
 * Arguments:
 * * C - The client who is sending the request
 * * message - The message
 */
/datum/request_manager/proc/message_syndicate(client/C, message)
	request_for_client(C, REQUEST_SYNDICATE, message)

/**
 * Creates a request for the nuclear self destruct codes
 *
 * Arguments:
 * * C - The client who is sending the request
 * * message - The message
 */
/datum/request_manager/proc/nuke_request(client/C, message)
	request_for_client(C, REQUEST_NUKE, message)

/**
 * Creates a request and registers the request with all necessary internal tracking lists
 *
 * Arguments:
 * * C - The client who is sending the request
 * * type - The type of request, see defines
 * * message - The message
 */
/datum/request_manager/proc/request_for_client(client/C, type, message)
	var/datum/request/request = new(C, type, message)
	if (!requests[C.ckey])
		requests[C.ckey] = list()
	requests[C.ckey] += request
	requests_by_id.len++
	requests_by_id[request.id] = request
	SStgui.update_uis(src)

/datum/request_manager/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "RequestManager")
		ui.open()

/datum/request_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/request_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if (..())
		return

	// Only admins should be sending actions
	if (!check_rights(R_ADMIN))
		to_chat(usr, "You do not have permission to do this, you require +ADMIN")
		return

	// Get the request this relates to
	var/id = params["id"] != null ? text2num(params["id"]) : null
	if (!id)
		to_chat(usr, "Failed to find a request ID in your action, please report this")
		CRASH("Received an action without a request ID, this shouldn't happen!")
	var/datum/request/request = !id ? null : requests_by_id[id]
	var/datum/admins/admin_datum = GLOB.admin_datums[usr.ckey]

	switch(action)
		if ("pp")
			var/mob/M = request.owner?.mob
			usr.client.holder.show_player_panel(M)
			return TRUE
		if ("vv")
			var/mob/M = request.owner?.mob
			usr.client.debug_variables(M)
			return TRUE
		if ("sm")
			var/mob/M = request.owner?.mob
			usr.client.cmd_admin_subtle_message(M)
			return TRUE
		if ("flw")
			var/mob/M = request.owner?.mob
			admin_datum.admin_follow(M)
			return TRUE
		if ("tp")
			if(!SSticker.HasRoundStarted())
				to_chat(usr,"The game hasn't started yet!")
				return TRUE
			var/mob/M = request.owner?.mob
			if(!ismob(M))
				var/datum/mind/D = M
				if(!istype(D))
					to_chat(usr, "This can only be used on instances of type /mob and /mind")
					return TRUE
				else
					D.traitor_panel()
					return TRUE
			else
				usr.client.holder.show_traitor_panel(M)
				return TRUE
		if ("logs")
			var/mob/M = request.owner?.mob
			if(!ismob(M))
				to_chat(usr, "This can only be used on instances of type /mob.")
				return TRUE
			show_individual_logging_panel(M, null, null)
			return TRUE
		if ("smite")
			if(!check_rights(R_FUN))
				to_chat(usr, "Insufficient permissions to smite, you require +FUN")
				return TRUE
			var/mob/living/carbon/human/H = request.owner?.mob
			if (!H || !istype(H))
				to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
				return TRUE
			usr.client.smite(H)
			return TRUE
		if ("rply")
			if (request.req_type == REQUEST_PRAYER)
				to_chat(usr, "Cannot reply to a prayer")
				return TRUE
			var/mob/M = request.owner?.mob
			usr.client.admin_headset_message(M, request.req_type == REQUEST_SYNDICATE ? RADIO_CHANNEL_SYNDICATE : RADIO_CHANNEL_CENTCOM)
			return TRUE
		if ("setcode")
			if (request.req_type != REQUEST_NUKE)
				to_chat(usr, "You cannot set the nuke code for a non-nuke-code-request request!")
				return TRUE
			var/code = random_code(5)
			for(var/obj/machinery/nuclearbomb/selfdestruct/SD in GLOB.nuke_list)
				SD.r_code = code
			message_admins("[key_name_admin(usr)] has set the self-destruct code to \"[code]\".")
			return TRUE

/datum/request_manager/ui_data(mob/user)
	. = list(
		"requests" = list()
	)
	for (var/ckey in requests)
		for (var/datum/request/request as anything in requests[ckey])
			var/list/data = list(
				"id" = request.id,
				"req_type" = request.req_type,
				"owner" = request.owner ? "[REF(request.owner)]" : null,
				"owner_ckey" = request.owner_ckey,
				"owner_name" = request.owner_name,
				"message" = request.message,
				"timestamp" = request.timestamp,
				"timestamp_str" = gameTimestamp(wtime = request.timestamp)
			)
			.["requests"] += list(data)
