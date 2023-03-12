#define PDA_SPAM_DELAY 1 MINUTES
/datum/computer_file/program/messenger
	filename = "nt_messenger"
	filedesc = "Direct Messenger"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "command"
	// This should be running when the tablet is created, so it's minimized by default
	program_state = PROGRAM_STATE_BACKGROUND
	extended_desc = "This program allows old-school communication with other modular devices."
	size = 0
	undeletable = TRUE // It comes by default in tablets, can't be downloaded, takes no space and should obviously not be able to be deleted.
	available_on_ntnet = FALSE
	usage_flags = PROGRAM_TABLET
	ui_header = "ntnrc_idle.gif"
	tgui_id = "NtosMessenger"
	program_icon = "comment-alt"
	alert_able = TRUE

	/// The current ringtone (displayed in the chat when a message is received).
	var/ringtone = "beep"
	/// Whether or not the ringtone is currently on.
	var/ringer_status = TRUE
	/// Whether or not we're sending and receiving messages.
	var/sending_and_receiving = TRUE
	/// The messages currently saved in the app.
	var/messages = list()
	/// great wisdom from PDA.dm - "no spamming" (prevents people from spamming the same message over and over)
	var/last_text
	/// even more wisdom from PDA.dm - "no everyone spamming" (prevents people from spamming the same message over and over)
	var/last_text_everyone
	/// Whether or not we allow emojis to be sent by the user.
	var/allow_emojis = FALSE
	/// Whether or not we're currently looking at the message list.
	var/viewing_messages = FALSE
	// Whether or not this device is currently hidden from the message monitor.
	var/monitor_hidden = FALSE
	// Whether or not we're sorting by job.
	var/sort_by_job = TRUE
	// Whether or not we're sending (or trying to send) a virus.
	var/sending_virus = FALSE

	/// The path for the current loaded image in rsc - used only for the "saved image" preview in the Messenger before sending
	var/photo_path

	/// Whether or not this app is loaded on a silicon's tablet.
	var/is_silicon = FALSE
	/// Whether or not we're in a mime PDA.
	var/mime_mode = FALSE

/datum/computer_file/program/messenger/proc/ScrubMessengerList()
	var/list/dictionary = list()

	for(var/obj/item/modular_computer/messenger in GetViewableDevices(sort_by_job))
		if(messenger.saved_identification && messenger.saved_job && !(messenger == computer))
			var/list/data = list()
			data["name"] = messenger.saved_identification
			data["job"] = messenger.saved_job
			data["ref"] = REF(messenger)

			//if(data["ref"] != REF(computer)) // you cannot message yourself (despite all my rage)
			dictionary += list(data)

	return dictionary

/proc/GetViewableDevices(sort_by_job = FALSE)
	var/list/dictionary = list()

	var/sortmode
	if(sort_by_job)
		sortmode = GLOBAL_PROC_REF(cmp_pdajob_asc)
	else
		sortmode = GLOBAL_PROC_REF(cmp_pdaname_asc)

	for(var/obj/item/modular_computer/P in sortList(GLOB.TabletMessengers, sortmode))
		var/obj/item/computer_hardware/hard_drive/drive = P.all_components[MC_HDD]
		if(!drive)
			continue
		for(var/datum/computer_file/program/messenger/app in drive.stored_files)
			if(!P.saved_identification || !P.saved_job || P.messenger_invisible || app.monitor_hidden)
				continue
			dictionary += P

	return dictionary

/datum/computer_file/program/messenger/proc/StringifyMessengerTarget(obj/item/modular_computer/messenger)
	return "[messenger.saved_identification] ([messenger.saved_job])"

/datum/computer_file/program/messenger/proc/ProcessPhoto()
	if(computer.saved_image)
		var/icon/img = computer.saved_image.picture_image
		var/deter_path = "tmp_msg_photo[rand(0, 99999)].png"
		usr << browse_rsc(img, deter_path) // funny random assignment for now, i'll make an actual key later
		photo_path = deter_path

/datum/computer_file/program/messenger/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/chat),
	)

/datum/computer_file/program/messenger/ui_static_data(mob/user)
	var/list/data = list()
	data["emoji_names"] = icon_states('icons/emoji.dmi')
	return data

/datum/computer_file/program/messenger/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("PDA_ringSet")
			var/mob/living/usr_mob = usr
			if(!in_range(computer, usr_mob) || computer.loc != usr_mob)
				return
			var/new_ringtone = stripped_input(usr, "Enter a new ringtone", "Ringtone", ringtone, 20)
			if(!new_ringtone)
				return
			if(SEND_SIGNAL(computer, COMSIG_TABLET_CHANGE_RINGTONE, usr_mob, new_ringtone) & COMPONENT_STOP_RINGTONE_CHANGE)
				ui.close(can_be_suspended = FALSE)
				return
			ringtone = new_ringtone
			return TRUE
		if("PDA_ringer_status")
			ringer_status = !ringer_status
			return TRUE
		if("PDA_sAndR")
			sending_and_receiving = !sending_and_receiving
			return TRUE
		if("PDA_viewMessages")
			viewing_messages = !viewing_messages
			return TRUE
		if("PDA_clearMessages")
			messages = list()
			return TRUE
		if("PDA_changeSortStyle")
			sort_by_job = !sort_by_job
			return TRUE
		if("PDA_sendEveryone")
			if(!sending_and_receiving)
				to_chat(usr, "<span class='notice'>ERROR: Device has sending disabled.</span>")
				return
			var/obj/item/computer_hardware/hard_drive/role/disk = computer.all_components[MC_HDD_JOB]
			if(!disk?.spam_delay)
				if(!disk)
					return
				log_href_exploit(usr, " Attempted sending PDA message to all without a disk capable of doing so: [disk].")
				return

			var/list/targets = list()

			for(var/obj/item/modular_computer/mc in GetViewableDevices())
				targets += mc

			if(targets.len > 0)
				if(last_text_everyone && world.time < (last_text_everyone + PDA_SPAM_DELAY * disk.spam_delay))
					to_chat(usr, "<span class='warning'>Send To All function is still on cooldown. Enabled in [(last_text_everyone + PDA_SPAM_DELAY * disk.spam_delay - world.time)/10] seconds.")
					return
				send_message(usr, targets, TRUE, multi_delay = disk.spam_delay)

			return TRUE
		if("PDA_sendMessage")
			if(!sending_and_receiving)
				to_chat(usr, "<span class='notice'>ERROR: Device has sending disabled.</span>")
				return
			var/obj/item/modular_computer/target = locate(params["ref"])
			if(!istype(target))
				return // we don't want tommy sending his messages to nullspace
			if(!(target.saved_identification == params["name"] && target.saved_job == params["job"]))
				to_chat(usr, "<span class='notice'>ERROR: User no longer exists.</span>")
				return

			var/obj/item/computer_hardware/hard_drive/drive = target.all_components[MC_HDD]

			for(var/datum/computer_file/program/messenger/app in drive.stored_files)
				if(!app.sending_and_receiving && !sending_virus)
					to_chat(usr, "<span class='notice'>ERROR: Device has receiving disabled.</span>")
					return
				if(sending_virus)
					var/obj/item/computer_hardware/hard_drive/role/virus/disk = computer.all_components[MC_HDD_JOB]
					if(istype(disk))
						disk.send_virus(target, usr)
						return TRUE
				send_message(usr, list(target))
				return TRUE
		if("PDA_clearPhoto")
			computer.saved_image = null
			photo_path = null
			return TRUE
		if("PDA_selectPhoto")
			if(!issilicon(usr))
				return
			var/mob/living/silicon/user = usr
			if(!user.aicamera)
				return
			if(!length(user.aicamera.stored))
				to_chat(user, "<span class='notice'>ERROR: No stored photos located.</span>")
				if(ringer_status)
					playsound(computer, 'sound/machines/terminal_error.ogg', 15, TRUE)
				return
			var/datum/picture/selected_photo = user.aicamera.selectpicture(user, title = "Select Message Attachment")
			if(!istype(selected_photo, /datum/picture))
				return
			computer.saved_image = selected_photo
			ProcessPhoto()
			return TRUE
		if("PDA_toggleVirus")
			sending_virus = !sending_virus
			return TRUE

/datum/computer_file/program/messenger/ui_data(mob/user)
	var/list/data = list()

	var/obj/item/computer_hardware/hard_drive/role/disk = computer.all_components[MC_HDD_JOB]

	data["owner"] = computer.saved_identification
	// Convert the photo object into a file so it can be rendered properly in Show Messages
	for(var/list/message as() in messages)
		var/datum/picture/pic = message["photo_obj"]
		if(!message["photo"] && istype(pic))
			message["photo"] = pda_rsc_image(pic, message["ref"], user)
			message["photo_width"] = pic.psize_x
			message["photo_height"] = pic.psize_y
	data["messages"] = messages
	data["ringer_status"] = ringer_status
	data["sending_and_receiving"] = sending_and_receiving
	data["messengers"] = ScrubMessengerList()
	data["viewing_messages"] = viewing_messages
	data["sortByJob"] = sort_by_job
	data["isSilicon"] = is_silicon
	data["photo"] = photo_path

	if(disk)
		data["canSpam"] = disk.spam_delay > 0
		data["virus_attach"] = istype(disk, /obj/item/computer_hardware/hard_drive/role/virus)
		data["sending_virus"] = sending_virus

	return data

/proc/pda_rsc_image(datum/picture/photo, ref, user)
	if(!istype(photo) || !photo.picture_image)
		return
	var/path = "pda_img[ref].png"
	user << browse_rsc(photo.picture_image, path)
	return path

////////////////////////
// MESSAGE HANDLING
////////////////////////

// How I Learned To Stop Being A PDA Bloat Chump And Learn To Embrace The Lightweight

// Gets the input for a message being sent.

/datum/computer_file/program/messenger/proc/msg_input(mob/living/user = usr, target_name = null)
	var/message = null

	if(mime_mode)
		message = emoji_sanitize(tgui_input_emoji(user, "NT Messaging"))
	else
		message = tgui_input_text(user, "Enter a message", "NT Messaging[target_name ? " ([target_name])" : ""]")

	if (!message || !sending_and_receiving)
		return
	if(!user.canUseTopic(computer, BE_CLOSE))
		return
	return sanitize(message)

/datum/computer_file/program/messenger/proc/send_message(mob/living/user, list/obj/item/modular_computer/targets, everyone = FALSE, fake_name = null, fake_job = null, multi_delay = 0)
	if(!targets.len)
		return FALSE
	var/target_name = length(targets) == 1 ? targets[1].saved_identification : "Everyone"
	var/message = msg_input(user, target_name)
	if(!message)
		return FALSE
	// notifying is done somewhere else, this is just a sanity check
	if((last_text && world.time < last_text + 10) || (everyone && last_text_everyone && world.time < (last_text_everyone + PDA_SPAM_DELAY * multi_delay)))
		return FALSE
	if(prob(1))
		message += "\nSent from my PDA"

	// Filter
	if(CHAT_FILTER_CHECK(message))
		to_chat(user, "<span class='warning'>ERROR: Prohibited word(s) detected in message.</span>")
		return

	// Check for jammers
	var/turf/position = get_turf(computer)
	for(var/datum/component/radio_jamming/jammer as anything in GLOB.active_jammers)
		var/turf/jammer_turf = get_turf(jammer.parent)
		if(position?.get_virtual_z_level() == jammer_turf.get_virtual_z_level() && (get_dist(position, jammer_turf) <= jammer.range))
			return FALSE

	// Send the signal
	var/list/string_targets = list()
	for (var/obj/item/modular_computer/comp in targets)
		if (comp.saved_identification && comp.saved_job)  // != src is checked by the UI
			string_targets += "[comp.saved_identification] ([comp.saved_job])"

	if (!string_targets.len)
		return FALSE

	var/datum/signal/subspace/messaging/tablet_msg/signal = new(computer, list(
		"name" = fake_name || computer.saved_identification,
		"job" = fake_job || computer.saved_job,
		"message" = html_decode(message),
		"ref" = REF(computer),
		"targets" = targets,
		"emojis" = allow_emojis,
		"photo" = computer.saved_image,
		"automated" = FALSE,
	))

	signal.send_to_receivers()

	// If it didn't reach, note that fact
	if (!signal.data["done"])
		to_chat(user, "<span class='notice'>ERROR: Server isn't responding.</span>")
		if(ringer_status)
			playsound(computer, 'sound/machines/terminal_error.ogg', 15, TRUE)
		return FALSE

	var/target_text = signal.format_target()

	// Create log entry
	var/list/message_data = list()
	message_data["name"] = signal.data["name"]
	message_data["job"] = signal.data["job"]
	message_data["target"] = target_text
	message_data["contents"] = html_decode(signal.data["message"])
	message_data["outgoing"] = TRUE
	message_data["ref"] = signal.data["ref"]
	message_data["photo_obj"] = signal.data["photo"]
	message_data["emojis"] = signal.data["emojis"]

	// Parse emojis before to_chat
	if(allow_emojis)
		message = emoji_parse(message)//already sent- this just shows the sent emoji as one to the sender in the to_chat
		signal.data["message"] = emoji_parse(signal.data["message"])

	// Show it to ghosts
	var/ghost_message = "<span class='name'>[message_data["name"]] </span><span class='game say'>PDA Message</span> --> <span class='name'>[target_text]</span>: <span class='message'>[signal.format_message(include_photo = TRUE)]</span>"
	for(var/mob/M in GLOB.player_list)
		if(isobserver(M) && (M.client?.prefs.chat_toggles & CHAT_GHOSTPDA))
			to_chat(M, "[FOLLOW_LINK(M, user)] [ghost_message]")

	// Log in the talk log
	user.log_talk(message, LOG_PDA, tag="PDA: [initial(message_data["name"])] to [target_text]")
	to_chat(user, "<span class='info'>PDA message sent to [target_text]: [signal.format_message()]</span>")

	if (ringer_status)
		computer.send_sound()

	last_text = world.time
	if (everyone)
		message_data["name"] = "Everyone"
		message_data["job"] = ""
		last_text_everyone = world.time

	// Log it in the local PDA's logs
	messages += list(message_data)
	return TRUE

/datum/computer_file/program/messenger/proc/receive_message(datum/signal/subspace/messaging/tablet_msg/signal)
	var/list/message_data = list()
	message_data["name"] = signal.data["name"]
	message_data["job"] = signal.data["job"]
	message_data["contents"] = html_decode(signal.data["message"])
	message_data["outgoing"] = FALSE
	message_data["ref"] = signal.data["ref"]
	message_data["automated"] = signal.data["automated"]
	message_data["photo_obj"] = signal.data["photo"]
	message_data["emojis"] = signal.data["emojis"]
	messages += list(message_data)

	var/mob/living/L = null
	if(isliving(computer.loc))
		L = computer.loc
	//Maybe they are a pAI!
	else if(computer)
		L = get(computer, /mob/living/silicon)

	if(L && (L.stat == CONSCIOUS || L.stat == SOFT_CRIT))
		var/reply = "(<a href='byond://?src=[REF(src)];choice=Message;skiprefresh=1;target=[signal.data["ref"]]'>Reply</a>)"
		var/hrefstart
		var/hrefend
		if (isAI(L))
			hrefstart = "<a href='?src=[REF(L)];track=[html_encode(signal.data["name"])]'>"
			hrefend = "</a>"

		if(signal.data["automated"])
			reply = "\[Automated Message\]"

		var/inbound_message = signal.format_message(include_photo = TRUE)
		if(signal.data["emojis"] == TRUE)//so will not parse emojis as such from pdas that don't send emojis
			inbound_message = emoji_parse(inbound_message)

		to_chat(L, "<span class='infoplain'>[icon2html(src)] <b>PDA message from [hrefstart][signal.data["name"]] ([signal.data["job"]])[hrefend], </b>[inbound_message] [reply]</span>")


	if (ringer_status)
		computer.ring(ringtone)

/// topic call that answers to people pressing "(Reply)" in chat
/datum/computer_file/program/messenger/Topic(href, href_list)
	..()
	if(QDELETED(src))
		return
	// Open messenger in the background
	if(!computer.enabled)
		if(!computer.turn_on(usr, open_ui = FALSE))
			return
	if(computer.active_program != src)
		if(!computer.open_program(usr, src, in_background = TRUE))
			return
	if(!href_list["close"] && usr.canUseTopic(computer, BE_CLOSE, FALSE, NO_TK))
		switch(href_list["choice"])
			if("Message")
				send_message(usr, list(locate(href_list["target"])))
#undef PDA_SPAM_DELAY
