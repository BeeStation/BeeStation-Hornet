/proc/tgui_send_admin_pda(mob/user, obj/signal_source, obj/machinery/telecomms/message_server/server, theme, allow_send_all = FALSE)
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
	pda_input.can_send_all = allow_send_all
	pda_input.theme = theme
	pda_input.ui_interact(user)
	pda_input.wait()
	if (!pda_input)
		return
	if(!pda_input.submit || (!pda_input.send_all && (!istype(pda_input.target) || QDELETED(pda_input.target))))
		qdel(pda_input)
		return
	if(istype(signal_source) && usr.default_can_use_topic(signal_source) != UI_INTERACTIVE)
		to_chat(usr, "<span class='warning'>Out of range! Message not sent!</span>")
		qdel(pda_input)
		return
	// If we are impersonating someone, we should match their computer in the (Reply) href
	var/ref
	for(var/obj/item/modular_computer/messenger in GetViewableDevices())
		if(messenger.saved_identification == pda_input.name && messenger.saved_job == pda_input.job && (pda_input.send_all || messenger != pda_input.target))
			ref = REF(messenger)
			break
	var/has_photo = !!pda_input.current_image
	var/datum/signal/subspace/messaging/tablet_msg/signal = new(signal_source ? signal_source : server, list(
		"name" = "[pda_input.name]",
		"job" = "[pda_input.job]",
		"message" = pda_input.text,
		"emojis" = TRUE,
		"photo" = pda_input.current_image,
		"ref" = ref,
		"targets" = pda_input.send_all ? GetViewableDevices() : list(pda_input.target),
	))
	if(istype(server) && !QDELETED(server))
		server.receive_information(signal, null)
	else
		signal.send_to_receivers()
	var/turf/source_turf = signal_source ? get_turf(signal_source) : null
	var/target_fmt = pda_input.send_all ? "Everyone" : signal.format_target()
	usr.log_message("(PDA: [pda_input.name] | [usr.real_name]) sent \"[pda_input.text]\"[has_photo ? " (Photo Attached)" : ""] to [target_fmt] via [signal_source ? "[signal_source] at [AREACOORD(source_turf)]" : "Admin UI"]", LOG_PDA)
	message_admins("[key_name_admin(usr)][ADMIN_FLW(usr)] sent PDA message: \"[pda_input.text]\"[has_photo ? " (Photo Attached)" : ""] to [target_fmt] via [signal_source ? "[signal_source] at [ADMIN_VERBOSEJMP(source_turf)]" : "Admin UI"]")
	qdel(pda_input)

/datum/tgui_input_pda_message
	var/closed
	var/submit
	var/name = "System Administrator"
	var/job = "Admin"
	var/text = ""
	var/theme
	var/datum/picture/current_image
	var/obj/item/modular_computer/target
	var/can_send_all = FALSE
	var/send_all = FALSE
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
	if(theme)
		.["theme"] = theme
	if(istype(target))
		.["target"] = "[target.saved_identification] ([target.saved_job])"
	.["everyone"] = send_all

/datum/tgui_input_pda_message/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("submit")
			if(!send_all && !istype(target))
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
			send_all = FALSE
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
			if(can_send_all)
				devices["Everyone"] = "Everyone"
			var/choice = input(usr, "Select PDA to send message to.", "Select PDA.", null) as null|anything in devices
			if(istype(target))
				UnregisterSignal(target, COMSIG_PARENT_QDELETING)
				target = null
			if(can_send_all && choice == "Everyone")
				send_all = TRUE
			else if(choice in devices)
				send_all = FALSE
				target = devices[choice]
				RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(target_deleting))
			else
				target = null
				send_all = FALSE
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
			if(current_image)
				current_image = null
				return TRUE
			if(issilicon(usr))
				var/mob/living/silicon/S = usr
				var/datum/picture/selection = S.aicamera?.selectpicture(usr)
				current_image = istype(selection) ? selection : null
			else
				var/obj/item/photo/photo = usr?.is_holding_item_of_type(/obj/item/photo)
				current_image = istype(photo) ? photo.picture : null
			if(current_image)
				if(src_console)
					src_console.balloon_alert(usr, "photo selected.")
					playsound(src_console, 'sound/machines/terminal_success.ogg', 15, TRUE)
				else
					usr.balloon_alert(usr, "photo selected.")
					SEND_SOUND(usr, 'sound/machines/terminal_success.ogg')
			else
				if(src_console)
					src_console.balloon_alert(usr, "no photo identified.")
				else
					usr.balloon_alert(usr, "no photo identified.")
			return TRUE
		if("send_all")
			if(!check_rights(R_ADMIN))
				return TRUE
			send_all = TRUE

/datum/tgui_input_pda_message/proc/target_deleting()
	target = null
	ui_update()
