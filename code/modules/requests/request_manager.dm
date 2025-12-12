/// Requests from prayers
#define REQUEST_PRAYER "request_prayer"
/// Requests for Centcom
#define REQUEST_CENTCOM "request_centcom"
/// Requests for the Syndicate
#define REQUEST_SYNDICATE "request_syndicate"
/// Requests for the nuke code
#define REQUEST_NUKE "request_nuke"
/// Requests somebody from fax
#define REQUEST_FAX "request_fax"

GLOBAL_DATUM_INIT(requests, /datum/request_manager, new)

/**
 * # Request Manager
 *
 * Handles all player requests (prayers, centcom requests, syndicate requests)
 * that occur in the duration of a round.
 */
/datum/request_manager
	/// Associative list of ckey -> list of requests (each entry is a list of /datum/request)
	var/list/list/datum/request/requests = list()
	/// List where requests can be accessed by ID
	var/list/datum/request/requests_by_id = list()

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
		if(is_chaplain && admin.prefs.read_player_preference(/datum/preference/toggle/chat_prayer) && admin.prefs.read_player_preference(/datum/preference/toggle/sound_prayers))
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
	for(var/client/admin in GLOB.admins)
		if(admin.prefs.read_player_preference(/datum/preference/toggle/chat_prayer) && admin.prefs.read_player_preference(/datum/preference/toggle/sound_prayers))
			SEND_SOUND(admin, sound('sound/misc/compiler-stage2.ogg'))

/**
 * Creates a request for a Syndicate message
 *
 * Arguments:
 * * C - The client who is sending the request
 * * message - The message
 */
/datum/request_manager/proc/message_syndicate(client/C, message)
	request_for_client(C, REQUEST_SYNDICATE, message)
	for(var/client/admin in GLOB.admins)
		if(admin.prefs.read_player_preference(/datum/preference/toggle/chat_prayer) && admin.prefs.read_player_preference(/datum/preference/toggle/sound_prayers))
			SEND_SOUND(admin, sound('sound/misc/compiler-stage2.ogg'))
/**
 * Creates a request for the nuclear self destruct codes
 *
 * Arguments:
 * * C - The client who is sending the request
 * * message - The message
 */
/datum/request_manager/proc/nuke_request(client/C, message)

	request_for_client(C, REQUEST_NUKE, message)
	for(var/client/admin in GLOB.admins)
		if(admin.prefs.read_player_preference(/datum/preference/toggle/chat_prayer) && admin.prefs.read_player_preference(/datum/preference/toggle/sound_prayers))
			SEND_SOUND(admin, sound('sound/misc/compiler-stage2.ogg'))
	// Auto-approve timer: if no admin rejects within approval_time, set the code
	var/request_list = requests[C.ckey]
	if(!request_list)
		return
	// find the most recent nuke request for this client
	var/datum/request/request
	for(var/datum/request/r as anything in request_list)
		if(r.req_type == REQUEST_NUKE)
			request = r
	if(!request)
		return
	// set a response timer id on the request to allow veto
	var/approval_time = 60 SECONDS// seconds until auto-approve
	request.response_timer_id = addtimer(CALLBACK(src, PROC_REF(_auto_approve_nuke_request), request.id), approval_time, TIMER_STOPPABLE)
	// notify admins with a clickable veto link
	var/msg = span_adminnotice("<b><font color=orange>NUKE CODE REQUEST:</font></b> Self-destruct code requested with the following message: [request.message] (will autoapprove in [DisplayTimeText(approval_time)]). [ADMIN_REJECT_SD_REQUEST(request)]")

	to_chat(GLOB.admins, msg)

/**
 * Creates a request for fax answer
 *
 * Arguments:
 * * requester - The client who is sending the request
 * * message - Paper with text.. some stamps.. and another things.
 */
/datum/request_manager/proc/fax_request(client/requester, message, additional_info)
	request_for_client(requester, REQUEST_FAX, message, additional_info)
	for(var/client/admin in GLOB.admins)
		if(admin.prefs.read_player_preference(/datum/preference/toggle/chat_prayer) && admin.prefs.read_player_preference(/datum/preference/toggle/sound_prayers))
			SEND_SOUND(admin, sound('sound/misc/compiler-stage1.ogg'))
/**
 * Creates a request and registers the request with all necessary internal tracking lists
 *
 * Arguments:
 * * C - The client who is sending the request
 * * type - The type of request, see defines
 * * message - The message
 */
/datum/request_manager/proc/request_for_client(client/C, type, message, additional_info)
	var/datum/request/request = new(C, type, message, additional_info)
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
		if ("show")
			if(request.req_type != REQUEST_FAX)
				to_chat(usr, "Request doesn't have a paper to read.")
				return TRUE
			var/obj/item/paper/request_message = request.additional_information
			request_message.ui_interact(usr)
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
				"additional_info" = request.additional_information,
				"timestamp" = request.timestamp,
				"timestamp_str" = gameTimestamp(wtime = request.timestamp)
			)
			.["requests"] += list(data)

/datum/request_manager/proc/_auto_approve_nuke_request(request_id)
	var/datum/request/request = requests_by_id[request_id]
	if(!request)
		return
	// If the admin rejected, the request may have been deleted or response_timer_id nulled
	if(!request.response_timer_id)
		return

	// Generate code and apply to all nukes
	var/code = random_code(5)
	for(var/obj/machinery/nuclearbomb/selfdestruct/SD in GLOB.nuke_list)
		SD.r_code = code
		SD.minimum_timer_set = 300 // Set minimum timer to 5 minutes

	// Announce to admins and requester
	message_admins(span_adminnotice("Auto-approved nuke request from [request.owner_name]: code set to [code]."))

	priority_announce("Request for activation of stationside nuclear self destruct detected. Classified response available at all communications consoles.", "Central High Command (Automated)", 'sound/machines/engine_alert3.ogg')
	print_command_report(
		"<code><center>--- AUTOMATED MESSAGE --- \n\
		Request for stationside nuclear authorization detected.\n\
		This transmission has been generated automatically.\n\n\
		ATTENTION:\n\
		Misuse of this function will trigger direct disciplinary action upon review by High Command.\n\n\
		Authorization codes for your station have been assigned:\n\
		=>>> [code] <<<=\n\n\
		Per regulation, minimum detonation core timer is locked at 5 minutes.\n\n\
		Your alert level has been set to RED automatically.\n\n\
		--- END OF MESSAGE ---</code></center>", "Automated Message", FALSE)

	addtimer(CALLBACK(src, PROC_REF(set_nuke_level)), 5 SECONDS)

	// Cleanup on aisle six
	request.response_timer_id = null
	// Remove request from tracking lists
	if(requests[request.owner_ckey])
		requests[request.owner_ckey].Remove(request)
	requests_by_id[request.id] = null
	qdel(request)

// If there is a better way, please tell me
/datum/request_manager/proc/set_nuke_level()
	SSsecurity_level.set_level(SEC_LEVEL_RED)

#undef REQUEST_PRAYER
#undef REQUEST_CENTCOM
#undef REQUEST_SYNDICATE
#undef REQUEST_NUKE
#undef REQUEST_FAX
