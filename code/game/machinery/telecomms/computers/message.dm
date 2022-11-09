/*
	The monitoring computer for the messaging server.
	Lets you read PDA and request console messages.
*/
/obj/machinery/computer/message_monitor
	name = "message monitor console"
	desc = "Used to monitor the crew's PDA messages, as well as request console messages."
	icon_screen = "comm_logs"
	circuit = /obj/item/circuitboard/computer/message_monitor
	light_color = LIGHT_COLOR_GREEN
	/// Message server selected to receive data from
	var/obj/machinery/telecomms/message_server/linked_server
	/// If the console is currently being hacked by a silicon
	var/hacking = FALSE

/obj/machinery/computer/message_monitor/attackby(obj/item/O, mob/living/user, params)
	if(O.tool_behaviour == TOOL_SCREWDRIVER && (obj_flags & EMAGGED))
		//Stops people from just unscrewing the monitor and putting it back to get the console working again.
		to_chat(user, "<span class='warning'>It is too hot to mess with!</span>")
	else
		return ..()

/obj/machinery/computer/message_monitor/should_emag(mob/user)
	if(!..())
		return FALSE
	if(!linked_server)
		to_chat(user, "<span class='notice'>A 'no server detected' error appears on the screen.</span>")
		return FALSE
	return TRUE

/obj/machinery/computer/message_monitor/on_emag(mob/user)
	..()
	ui_update()
	do_sparks(5, FALSE, src)
	addtimer(CALLBACK(src, .proc/after_emag), 10 * length(linked_server.decryptkey) SECONDS)

/obj/machinery/computer/message_monitor/proc/after_emag()
	// Print an "error" decryption key, leaving physical evidence of the hack.
	if(linked_server)
		var/obj/item/paper/monitorkey/MK = new(loc, linked_server)
		MK.info += "<br><br><font color='red'>£%@%(*$%&(£&?*(%&£/{}</font>"
	else
		say("Error: Server link lost!")
	obj_flags &= ~EMAGGED
	ui_update()

/obj/machinery/computer/message_monitor/proc/finish_hack(mob/living/silicon/user)
	hacking = FALSE
	ui_update()
	if(!linked_server)
		to_chat(user, "<span class='warning'>Could not complete brute-force: Linked Server Disconnected!</span>")
		return
	to_chat(user, "<span class='warning'>Brute-force completed! The decryption key is '[linked_server.decryptkey]'.</span>")

/obj/machinery/computer/message_monitor/New()
	..()
	GLOB.telecomms_list += src

/obj/machinery/computer/message_monitor/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/message_monitor/LateInitialize()
	//If the server isn't linked to a server, and there's a server available, default it to the first one in the list.
	if(!linked_server)
		for(var/obj/machinery/telecomms/message_server/S in GLOB.telecomms_list)
			set_linked_server(S)
			break

/obj/machinery/computer/message_monitor/proc/set_linked_server(var/obj/machinery/telecomms/message_server/server)
	if(linked_server)
		UnregisterSignal(linked_server, COMSIG_PARENT_QDELETING)
	if(server != linked_server)
		authenticated = FALSE
	linked_server = server
	if(server)
		RegisterSignal(server, COMSIG_PARENT_QDELETING, .proc/server_deleting)
	ui_update()

/obj/machinery/computer/message_monitor/proc/server_deleting()
	set_linked_server(null)

/obj/machinery/computer/message_monitor/Destroy()
	GLOB.telecomms_list -= src
	set_linked_server(null)
	return ..()

/obj/machinery/computer/message_monitor/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/chat),
	)

/obj/machinery/computer/message_monitor/ui_static_data(mob/user)
	var/list/data = list()
	data["emoji_names"] = icon_states('icons/emoji.dmi')
	return data

/obj/machinery/computer/message_monitor/ui_data(mob/user)
	var/list/data = ..()
	data["server_on"] = linked_server?.on
	data["authenticated"] = authenticated
	data["hacking"] = hacking || (obj_flags & EMAGGED)
	var/mob/living/silicon/S = user
	data["can_hack"] = istype(S) && S.hack_software
	var/no_server = !linked_server || (linked_server.machine_stat & (NOPOWER|BROKEN))
	data["no_server"] = no_server
	if(no_server || !authenticated)
		return data
	var/list/pda_messages = list()
	for(var/datum/data_tablet_msg/message in linked_server.modular_msgs)
		var/list/message_data = list()
		var/datum/picture/pic = message.picture
		if(istype(pic))
			message_data["photo"] = pda_rsc_image(pic, "[REF(message)]", user)
			message_data["photo_width"] = pic.psize_x
			message_data["photo_height"] = pic.psize_y
		message_data["sender"] = message.sender
		message_data["recipient"] = message.recipient
		message_data["contents"] = message.message
		message_data["emojis"] = message.emojis
		message_data["ref"] = REF(message)
		pda_messages += list(message_data)
	data["pda_messages"] = pda_messages
	var/list/request_messages = list()
	for(var/datum/data_rc_msg/req in linked_server.rc_msgs)
		request_messages += list(list(
			"sending_department" = req.send_dpt,
			"receiving_department" = req.rec_dpt,
			"stamp" = req.stamp,
			"id_auth" = req.id_auth,
			"priority" = req.priority,
			"message" = req.message,
			"ref" = REF(req),
		))
	data["request_messages"] = request_messages
	return data

/obj/machinery/computer/message_monitor/ui_act(action, params)
	. = ..()
	if(.)
		return TRUE
	switch(action)
		if("login")
			if(!usr || authenticated)
				return TRUE
			if(!linked_server)
				to_chat(usr, "<span class='warning'>The console flashes a message: 'ERROR: Server connection lost.'</span>")
				return TRUE
			var/dkey = capped_input(usr, "Please enter the decryption key.")
			if(dkey && linked_server.decryptkey == dkey)
				authenticated = TRUE
			else
				to_chat(usr, "<span class='warning'>The console flashes a message: 'ALERT: Incorrect decryption key!'</span>")
			return TRUE
		if("logout")
			authenticated = FALSE
			return TRUE
		if("hack")
			var/mob/living/silicon/S = usr
			if(!istype(S) || !S.hack_software)
				return TRUE
			if(!linked_server)
				to_chat(S, "<span class='warning'>The console flashes a message: 'ERROR: Server connection lost.'</span>")
				return TRUE
			hacking = TRUE
			var/duration = 10 * length(linked_server.decryptkey) SECONDS
			var/approx_duration = max(duration + rand(-20, 20), 1)
			to_chat(S, "<span class='warning'>Brute-force decryption started. This will take approximately [DisplayTimeText(approx_duration, round_seconds_to = 10)].</span>")
			addtimer(CALLBACK(src, .proc/finish_hack, S), duration)
			return TRUE
		if("link")
			var/list/message_servers = list()
			var/obj/machinery/telecomms/message_server/last
			for (var/obj/machinery/telecomms/message_server/M in GLOB.telecomms_list)
				var/key_base = "[M.network] - [M.name]"
				var/key = key_base
				var/number = 1
				while(key in message_servers)
					key = key_base + " ([number])"
					number++
				message_servers[key] = M
				last = M

			if(length(message_servers) > 1)
				var/choice = input(usr, "Please select a server.", "Select a server.", null) as null|anything in message_servers
				if(choice in message_servers)
					set_linked_server(message_servers[choice])
				else
					set_linked_server(null)
			else if(length(message_servers) == 1)
				set_linked_server(last)
			else
				set_linked_server(null)
			return TRUE
		if("power")
			if(!authenticated)
				return TRUE
			if(!linked_server)
				to_chat(usr, "<span class='warning'>The console flashes a message: 'ERROR: Server connection lost.'</span>")
				return TRUE
			linked_server.toggled = !linked_server.toggled
			// Trigger this immediately or hte UI will not update properly... wow this is a dumb proc
			linked_server.update_power()
			return TRUE
		if("reset_key")
			if(!usr || !authenticated)
				return TRUE
			if(!linked_server)
				to_chat(usr, "<span class='warning'>The console flashes a message: 'ERROR: Server connection lost.'</span>")
				return TRUE
			var/dkey = capped_input(usr, "Please enter the decryption key.")
			if(!dkey)
				return
			if(linked_server.decryptkey == dkey)
				var/newkey = capped_input(usr, "Please enter the new key (4-16 characters):")
				if(length(newkey) < 4)
					to_chat(usr, "<span class='warning'>The console flashes a message: 'NOTICE: Decryption key too short!'</span>")
				else if(length(newkey) > 16)
					to_chat(usr, "<span class='warning'>The console flashes a message: 'NOTICE: Decryption key too long!'</span>")
				else if(newkey && newkey != "")
					linked_server.decryptkey = newkey
					to_chat(usr, "<span class='notice'>The console flashes a message: 'NOTICE: Decryption key set.'</span>")
			else
				to_chat(usr,"<span class='warning'>The console flashes a message: 'ALERT: Incorrect decryption key!'</span>")
		if("clear_logs")
			var/type = params["type"]
			if(!usr || !authenticated || (type != "pda" && type != "request"))
				return TRUE
			if(!linked_server)
				to_chat(usr, "<span class='warning'>The console flashes a message: 'ERROR: Server connection lost.'</span>")
				return TRUE
			if(type == "request")
				linked_server.rc_msgs.Cut()
			else
				linked_server.modular_msgs.Cut()
			to_chat(usr, "<span class='notice'>The console flashes a message: 'NOTICE: Logs cleared.'</span>")
			var/turf/the_turf = get_turf(src)
			usr.log_message("cleared [type] logs using [src] at [AREACOORD(the_turf)]", LOG_GAME)
			message_admins("[ADMIN_FLW(usr)] cleared [type] logs using [src] at [ADMIN_VERBOSEJMP(the_turf)]")
			return TRUE
		if("delete_log")
			var/ref = params["ref"]
			var/type = params["type"]
			if(!usr || !authenticated || (type != "pda" && type != "request") || !ref)
				return TRUE
			if(!linked_server)
				to_chat(usr, "<span class='warning'>The console flashes a message: 'ERROR: Server connection lost.'</span>")
				return TRUE
			var/list/target = type == "request" ? linked_server.rc_msgs : linked_server.modular_msgs
			var/datum/entry = locate(ref) in target
			if(!entry)
				return
			target -= entry
			var/msg = ""
			if(istype(entry, /datum/data_tablet_msg))
				var/datum/data_tablet_msg/pda_entry = entry
				msg = "[pda_entry.sender] to [pda_entry.recipient]: [pda_entry.message]"
			else if(istype(entry, /datum/data_rc_msg))
				var/datum/data_rc_msg/rc_entry = entry
				msg = "[rc_entry.send_dpt] to [rc_entry.rec_dpt] PRIORITY [rc_entry.priority] AUTH [rc_entry.id_auth] STAMP [rc_entry.stamp]: [rc_entry.message]"
			to_chat(usr, "<span class='notice'>The console flashes a message: 'NOTICE: Log entry deleted.'</span>")
			var/turf/the_turf = get_turf(src)
			usr.log_message("cleared [type] log entry \"[msg]\" using [src] at [AREACOORD(the_turf)]", LOG_GAME)
			message_admins("[key_name_admin(usr)][ADMIN_FLW(usr)] deleted [type] log entry \"[msg]\" using [src] at [ADMIN_VERBOSEJMP(the_turf)]")
			return TRUE
		if("admin_message")
			if(!usr || !authenticated)
				return TRUE
			if(!linked_server)
				to_chat(usr, "<span class='warning'>The console flashes a message: 'ERROR: Server connection lost.'</span>")
				return TRUE
			tgui_send_admin_pda(usr, src, linked_server)

/obj/machinery/computer/message_monitor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MessageMonitor")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/item/paper/monitorkey
	name = "monitor decryption key"

/obj/item/paper/monitorkey/Initialize(mapload, obj/machinery/telecomms/message_server/server)
	..()
	if (server)
		print(server)
		return INITIALIZE_HINT_NORMAL
	else
		return INITIALIZE_HINT_LATELOAD

/obj/item/paper/monitorkey/proc/print(obj/machinery/telecomms/message_server/server)
	info = "<h2>Telecommunications Security Notice</h2><br />\
	<strong><pre>INCOMING TRANSMISSION - KEY RESET REPORT</pre></strong><br />\
	<p>\
	<pre>\
	REPORT: PREVIOUS SHIFT DATA WIPED.<br />\
	KEY UPDATED.<br />\
	</pre>\
	<strong>Monitor Decryption Key: </strong>[server.decryptkey]\
	</p>\
	<p><pre>\
	PLEASE MAXIMIZE KEY SECURITY.<br />\
	UPDATE KEY IF NECESSARY.<br />\
	TRANSMISSION END.<br />\
	SENDER: CentCom Telecommunications Data Retention\
	</pre></p>"
	add_overlay("paper_words")

/obj/item/paper/monitorkey/LateInitialize()
	for (var/obj/machinery/telecomms/message_server/preset/server in GLOB.telecomms_list)
		if (server.decryptkey)
			print(server)
			break

/proc/tgui_send_admin_pda(mob/user, obj/signal_source, obj/machinery/telecomms/message_server/server)
	if (!user)
		user = usr
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return
	var/datum/tgui_input_pda_message/pda_input = new(user)
	pda_input.src_console = signal_source
	pda_input.ui_interact(user)
	pda_input.wait()
	if (!pda_input)
		return
	if(!pda_input.submit || !istype(pda_input.target) || QDELETED(pda_input.target))
		qdel(pda_input)
		return
	if(istype(signal_source) && usr.default_can_use_topic(signal_source) != UI_INTERACTIVE)
		to_chat(usr, "<span class='warning'>Out of range! Message not sent!</span>")
		qdel(pda_input)
		return
	// If we are impersonating someone, we should match their computer in the (Reply) href
	var/ref
	for(var/obj/item/modular_computer/messenger in GetViewableDevices(TRUE))
		if(messenger.saved_identification == pda_input.name && messenger.saved_job == pda_input.job && messenger != pda_input.target)
			ref = REF(messenger)
			break
	var/datum/signal/subspace/messaging/tablet_msg/signal = new(signal_source ? signal_source : server, list(
		"name" = "[pda_input.name]",
		"job" = "[pda_input.job]",
		"message" = pda_input.text,
		"emojis" = TRUE,
		"photo" = pda_input.current_image,
		"ref" = ref,
		"targets" = list(pda_input.target),
	))
	if(istype(server) && !QDELETED(server))
		server.receive_information(signal, null)
	else
		signal.send_to_receivers()
	usr.log_message("(PDA: [pda_input.name] | [usr.real_name]) sent \"[pda_input.text]\" to [signal.format_target()]", LOG_PDA)
	qdel(pda_input)

/datum/tgui_input_pda_message
	var/closed
	var/submit
	var/name = "System Administrator"
	var/job = "Admin"
	var/text = ""
	var/datum/picture/current_image
	var/obj/item/modular_computer/target
	var/obj/src_console
	var/static/datum/ui_state/tgui_input_pda_state/tgui_input_pda_state

/datum/tgui_input_pda_message/New()

/datum/tgui_input_pda_message/Destroy(force, ...)
	SStgui.close_uis(src)
	. = ..()

/datum/tgui_input_pda_message/proc/wait()
	UNTIL(submit || closed || QDELETED(src))

/datum/tgui_input_pda_message/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PDAInputModal")
		ui.open()

/datum/tgui_input_pda_message/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/tgui_input_pda_message/ui_state(mob/user)
	if(!tgui_input_pda_state)
		tgui_input_pda_state = new()
	return tgui_input_pda_state

/datum/ui_state/tgui_input_pda_state/can_use_topic(src_object, mob/user)
	var/datum/tgui_input_pda_message/src_object_pda = src_object
	if(!istype(src_object_pda))
		return UI_CLOSE
	return src_object_pda.src_console ? user.default_can_use_topic(src_object_pda.src_console) : UI_INTERACTIVE

/datum/tgui_input_pda_message/ui_data(mob/user)
	. = list()
	.["name"] = name
	.["job"] = job
	.["text"] = text
	.["image"] = istype(current_image)
	if(target)
		.["target"] = "[target.saved_identification] ([target.saved_job])"

/datum/tgui_input_pda_message/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("submit")
			if(!istype(target))
				alert(usr, "Please select a recipient!", "Send Failure", "OK")
				return
			if(!length(name) || !length(job) || !length(text))
				alert(usr, "Please enter text into all fields!", "Send Failure", "OK")
				return
			submit = TRUE
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE
		if("cancel")
			// don't send the message
			target = null
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE
		if("select")
			var/list/devices = list()
			for(var/obj/item/modular_computer/messenger in GetViewableDevices(TRUE))
				if(!messenger.saved_identification || !messenger.saved_job)
					continue
				var/key_base = "[messenger.saved_identification] ([messenger.saved_job])"
				var/key = key_base
				var/number = 1
				while(key in devices)
					key = key_base + " ([number])"
					number++
				devices[key] = messenger
			var/choice = input(usr, "Select PDA to send message to.", "Select PDA.", null) as null|anything in devices
			if(istype(target))
				UnregisterSignal(src, COMSIG_PARENT_QDELETING)
			if(choice in devices)
				target = devices[choice]
				RegisterSignal(src, COMSIG_PARENT_QDELETING, .proc/target_deleting)
			else
				target = null
			return TRUE
		if("set_message")
			text = trim(params["value"], MAX_MESSAGE_LEN)
			return TRUE
		if("set_name")
			name = trim(params["value"], MAX_NAME_LEN)
			return TRUE
		if("set_job")
			job = trim(params["value"], MAX_NAME_LEN)
			return TRUE
		if("photo")
			var/had_image = !!current_image
			if(issilicon(usr))
				var/mob/living/silicon/S = usr
				var/datum/picture/selection = S.aicamera?.selectpicture(usr)
				current_image = selection ? selection : null
			else
				var/obj/item/photo/photo = usr?.is_holding_item_of_type(/obj/item/photo)
				current_image = photo?.picture
			if(current_image)
				balloon_alert(usr, "photo selected.")
				if(src_console)
					playsound(src_console, 'sound/machines/terminal_success.ogg', 15, TRUE)
			else if(!had_image)
				balloon_alert(usr, "no photo identified.")
			return TRUE

/datum/tgui_input_pda_message/proc/target_deleting()
	target = null
	ui_update()
