GLOBAL_DATUM_INIT(fax_manager, /datum/fax_manager, new)

/**
 * Fax Request Manager
 *
 * In its functionality it is similar to the usual Request Manager, but respectively for faxes.
 * This manager allows you to send faxes on behalf of certain virtual faxes to all existing faxes,
 * as well as receive faxes in their name from the players.
 */
/datum/fax_manager
	/// A list that contains faxes from players and other related information. You can view the filling of its fields in the procedure receive_request.
	var/list/requests = list()

/datum/fax_manager/Destroy(force, ...)
	QDEL_LIST(requests)
	return ..()

/datum/fax_manager/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FaxManager")
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/fax_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/fax_manager/ui_static_data(mob/user)
	var/list/data = list()
	//Record additional faxes on a separate list
	data["additional_faxes"] = GLOB.additional_faxes_list + GLOB.syndicate_faxes_list
	return data

/datum/fax_manager/ui_data(mob/user)
	var/list/data = list()
	//Record a list of all existing faxes.
	for(var/obj/machinery/fax/fax as anything in GLOB.fax_machines)
		var/list/fax_data = list()
		fax_data["fax_name"] = fax.fax_name
		fax_data["fax_id"] = fax.fax_id
		fax_data["syndicate_network"] = fax.syndicate_network
		data["faxes"] += list(fax_data)
	for(var/list/requested in requests)
		var/list/request = list()
		request["id_message"] = requested["id_message"]
		request["time"] = requested["time"]
		var/mob/sender = requested["sender"]
		request["sender_name"] = sender.name
		request["sender_fax_id"] = requested["sender_fax_id"]
		request["sender_fax_name"] = requested["sender_fax_name"]
		request["receiver_fax_name"] = requested["receiver_fax_name"]
		data["requests"] += list(request)
	return data

/datum/fax_manager/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/datum/admins/admin_datum = GLOB.admin_datums[usr.ckey]

	switch(action)
		if("send")
			for(var/obj/machinery/fax/fax as anything in GLOB.fax_machines)
				if(fax.fax_id == params["fax_id"])
					var/obj/item/paper/paper = new()
					paper.add_raw_text(params["message"])
					paper.update_appearance()
					fax.receive(paper, params["fax_name"], important = TRUE)
					return TRUE
		if("flw_fax")
			for(var/obj/machinery/fax/fax as anything in GLOB.fax_machines)
				if(fax.fax_id == params["fax_id"])
					admin_datum.admin_follow(fax)
					return TRUE
		if("read_message")
			var/list/request = get_request(params["id_message"])
			var/obj/item/paper/request/paper = request["paper"]
			paper.ui_interact(usr)
			return TRUE
		if("flw")
			var/list/request = get_request(params["id_message"])
			admin_datum.admin_follow(request["sender"])
			return TRUE
		if("pp")
			var/list/request = get_request(params["id_message"])
			usr.client.holder.show_player_panel(request["sender"])
			return TRUE
		if("vv")
			var/list/request = get_request(params["id_message"])
			usr.client.debug_variables(request["sender"])
			return TRUE
		if("sm")
			var/list/request = get_request(params["id_message"])
			usr.client.cmd_admin_subtle_message(request["sender"])
			return TRUE
		if("logs")
			var/list/request = get_request(params["id_message"])
			if(!ismob(request["sender"]))
				to_chat(usr, "This can only be used on instances of type /mob.")
				return TRUE
			show_individual_logging_panel(request["sender"], null, null)
			return TRUE
		if("smite")
			var/list/request = get_request(params["id_message"])
			if(!check_rights(R_FUN))
				to_chat(usr, "Insufficient permissions to smite, you require +FUN")
				return TRUE
			var/mob/living/carbon/human/H = request["sender"]
			if (!H || !istype(H))
				to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
				return TRUE
			usr.client.smite(H)
			return TRUE

/datum/fax_manager/proc/get_request(id_message)
	for(var/list/request in requests)
		if(request["id_message"] == id_message)
			return request

/datum/fax_manager/proc/receive_request(mob/sender, obj/machinery/fax/sender_fax, receiver_fax_name, obj/item/paper/paper, receiver_color)
	var/list/request = list()
	var/obj/item/paper/request/message = new()
	request["id_message"] = requests.len
	request["time"] = gameTimestamp()
	request["sender"] = sender
	request["sender_fax_id"] = sender_fax.fax_id
	request["sender_fax_name"] = sender_fax.fax_name
	request["receiver_fax_name"] = receiver_fax_name
	message.copy_properties(paper)
	request["paper"] = message
	requests += list(request)
	var/msg = "<span class='adminnotice'><b><font color=[receiver_color]>[sanitize(receiver_fax_name)] fax</font> received a message from [sanitize(sender_fax.fax_name)][ADMIN_FLW(sender)][ADMIN_JMP(sender_fax)]/[ADMIN_FULLMONTY(sender)]</b></span>"
	to_chat(GLOB.admins, msg)

	for(var/obj/machinery/fax/fax as anything in GLOB.fax_machines)
		if(fax.radio_channel == RADIO_CHANNEL_CENTCOM)
			fax.receive(paper, sender_fax.fax_name)
			break

	for(var/client/admin in GLOB.admins)
		if((admin.prefs.chat_toggles & CHAT_PRAYER) && (admin.prefs.toggles & PREFTOGGLE_SOUND_PRAYERS))
			SEND_SOUND(admin, sound('sound/items/poster_being_created.ogg'))

// A special piece of paper for the administrator that will open the interface no matter what.
/obj/item/paper/request/ui_status()
	return UI_INTERACTIVE

// I'm sure there's a better way to transfer it, I just couldn't find it
/obj/item/paper/request/proc/copy_properties(obj/item/paper/paper)
	raw_text_inputs = paper.raw_text_inputs
	raw_stamp_data = paper.raw_stamp_data
	raw_field_input_data = paper.raw_field_input_data
	show_written_words = paper.show_written_words
	stamp_cache = paper.stamp_cache
	contact_poison = paper.contact_poison
	contact_poison_volume = paper.contact_poison_volume
	default_raw_text = paper.default_raw_text
	input_field_count = paper.input_field_count
