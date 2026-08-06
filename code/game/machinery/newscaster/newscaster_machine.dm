#define ALERT_DELAY 50 SECONDS

/obj/machinery/newscaster
	name = "newscaster"
	desc = "A standard Nanotrasen-licensed newsfeed handler for use in commercial space stations. All the news you absolutely have no use for, in one place!"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "newscaster_off"
	base_icon_state = "newscaster"
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	armor_type = /datum/armor/machinery_newscaster
	max_integrity = 200
	integrity_failure = 0.25
	///How much paper is contained within the newscaster?
	var/paper_remaining = 0

	///What newscaster channel is currently being viewed by the player?
	var/datum/feed_channel/current_channel
	///What newscaster feed_message is currently having a comment written for it?
	var/datum/feed_message/current_message
	///The message that's currently being written for a feed story.
	var/feed_channel_message
	///The headline currently being written.
	var/feed_channel_headline
	///The image used while making a wanted alert.
	var/datum/picture/current_image
	///List of photos being attached to an article.
	var/list/pending_photos = list()
	///Is there currently an alert on this newscaster that hasn't been seen yet?
	var/alert = FALSE
	///Is the current user viewing the issue at the moment?
	var/viewing_wanted = FALSE
	///Is the current user editing the wanted issue at the moment?
	var/editing_wanted = FALSE
	///Is the current user creating a new channel at the moment?
	var/creating_channel = FALSE
	///Is the current user editing the current channel at the moment?
	var/editing_channel = FALSE
	///Is the current user creating a new comment at the moment?
	var/creating_comment = FALSE
	///What is the user submitted, criminal name for the new wanted issue?
	var/criminal_name
	///What is the user submitted, crime description for the new wanted issue?
	var/crime_description
	///Sselected danger level for the created wanted issue.
	var/wanted_danger_level = "Armed and Dangerous"
	///Currently selected warrant in the ui.
	var/selected_wanted_id
	///Danger levels used by wanted alerts.
	var/static/list/wanted_danger_options = list(
		"Wanted - Low Threat",
		"Wanted - Caution",
		"Armed and Dangerous",
		"Lethal Threat",
		"Explosives Risk",
	)
	///If the current wanted issue has an image
	var/wanted_image = FALSE
	///What is the current, in-creation channel's name going to be?
	var/channel_name
	///What is the current, in-creation channel's description going to be?
	var/channel_desc
	///What is the current, in-creation channel's publicity going to be?
	var/channel_locked
	///What is the current, in-creation comment's body going to be?
	var/comment_text

	///The station request datum being affected by UI actions.
	var/datum/station_request/active_request
	///Is a user currently writing a story
	var/writing_story = FALSE
	///Value of the currently bounty input
	var/bounty_value = 1
	///Quantity of items requested for the bounty.
	var/bounty_quantity = 1
	///Title of the bounty.
	var/bounty_title = ""
	///Description text for the bounty.
	var/bounty_text = ""
	///Timer used to reset UI to hub after user leaves.
	var/idle_reset_timer

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/newscaster, 30)

CREATION_TEST_IGNORE_SUBTYPES(/obj/machinery/newscaster)


/datum/armor/machinery_newscaster
	melee = 50
	fire = 50
	acid = 30

/obj/machinery/newscaster/Initialize(mapload, ndir, building)
	. = ..()
	GLOB.allCasters += src
	GLOB.allbountyboards += src
	update_icon()

/obj/machinery/newscaster/Destroy()
	GLOB.allCasters -= src
	GLOB.allbountyboards -= src
	current_channel = null
	current_image = null
	active_request = null
	return ..()

/obj/machinery/newscaster/update_appearance(updates=ALL)
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		set_light(0)
		return
	set_light(1.4,0.7,"#34D352") // green light

/obj/machinery/newscaster/update_overlays()
	. = ..()
	if(!(machine_stat & (NOPOWER|BROKEN)))
		var/wanted_active = GLOB.news_network?.wanted_issue?.active
		var/state = "[base_icon_state]_[wanted_active ? "wanted" : "normal"]"
		. += mutable_appearance(icon, state)
		. += emissive_appearance(icon, state, layer, alpha = src.alpha)
		ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)

		if(!wanted_active && alert)
			. += mutable_appearance(icon, "[base_icon_state]_alert")
			. += emissive_appearance(icon, "[base_icon_state]_alert", layer, alpha = src.alpha)
			ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)

	var/hp_percent = (atom_integrity * 100) / max_integrity
	switch(hp_percent)
		if(75 to 100)
			return
		if(50 to 75)
			. += "crack1"
			. += emissive_blocker(icon, "crack1", alpha = src.alpha)
		if(25 to 50)
			. += "crack2"
			. += emissive_blocker(icon, "crack2", alpha = src.alpha)
		else
			. += "crack3"
			. += emissive_blocker(icon, "crack3", alpha = src.alpha)

/obj/machinery/newscaster/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(idle_reset_timer)
		deltimer(idle_reset_timer)
		idle_reset_timer = null
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PhysicalNewscaster", name)
		ui.open()
	alert = FALSE //We're checking our messages!
	update_icon()

/obj/machinery/newscaster/ui_close(mob/user, datum/tgui/ui)
	. = ..()
	if(idle_reset_timer)
		deltimer(idle_reset_timer)
	idle_reset_timer = addtimer(CALLBACK(src, PROC_REF(reset_to_picker)), 1 MINUTES, TIMER_STOPPABLE)

/obj/machinery/newscaster/proc/reset_to_picker()
	idle_reset_timer = null
	// If the user is doing the following the UI shouldnt reset to hub.
	if(creating_channel || editing_channel || creating_comment || editing_wanted || viewing_wanted || writing_story)
		return
	current_channel = null
	SStgui.update_uis(src)

/obj/machinery/newscaster/proc/get_registered_account(mob/user)
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	var/obj/item/card/id/card = living_user.get_idcard(hand_first = TRUE)
	if(istype(card))
		return card.registered_account

/obj/machinery/newscaster/ui_data(mob/user)
	var/list/data = list()
	var/list/message_list = list()

	//Code displaying name and Job Information, taken from the player mob's ID card if one exists.
	var/obj/item/card/id/card
	if(isliving(user))
		var/mob/living/living_user = user
		card = living_user.get_idcard(hand_first = TRUE)
	data["user"] = list()
	data["user"]["authenticated"] = FALSE
	data["user"]["silicon"] = FALSE
	data["security_mode"] = (ACCESS_SECURITY in card?.GetAccess())
	data["wanted_create_mode"] = (ACCESS_SEC_RECORDS in card?.GetAccess())
	data["command_mode"] = (ACCESS_CAPTAIN in card?.GetAccess())
	if(card?.registered_account)
		data["user"]["authenticated"] = TRUE
		data["user"]["name"] = card.registered_account.account_holder
		var/datum/record/crew/R = find_record(card.registered_account.account_holder, GLOB.manifest.general)
		if(R)
			data["user"]["job"] = R.rank
		else if(card.registered_account.account_job)
			data["user"]["job"] = card.registered_account.account_job.title
		else
			data["user"]["job"] = "No Job"
	else if(issilicon(user))
		data["user"]["authenticated"] = TRUE
		data["user"]["silicon"] = TRUE
		data["user"]["name"] = user.name
		data["user"]["job"] = user.job
		data["security_mode"] = !ispAI(user)
		data["wanted_create_mode"] = FALSE
		data["command_mode"] = FALSE
	else
		data["user"]["name"] = "Unknown"
		data["user"]["job"] = "N/A"

	data["photo_data"] = !isnull(current_image)
	data["photo_count"] = length(pending_photos)
	data["creating_channel"] = creating_channel
	data["editing_channel"] = editing_channel
	data["creating_comment"] = creating_comment
	data["viewing_wanted"] = viewing_wanted
	data["editing_wanted"] = editing_wanted

	//Here is all the UI_data sent about the current wanted issue, as well as making a new one in the UI.
	data["making_wanted_issue"] = !length(GLOB.news_network.wanted_issues)
	data["criminal_name"] = criminal_name
	data["crime_description"] = crime_description
	data["wanted_danger_level"] = wanted_danger_level
	data["wanted_danger_options"] = wanted_danger_options
	if(!selected_wanted_id && length(GLOB.news_network.wanted_issues))
		selected_wanted_id = GLOB.news_network.wanted_issues[1].wanted_id
	data["selected_wanted_id"] = selected_wanted_id
	var/list/wanted_info = list()
	for(var/datum/wanted_message/wanted_entry as anything in GLOB.news_network.wanted_issues)
		var/photo_id = null
		if(wanted_entry.img)
			photo_id = "wanted_photo_[wanted_entry.wanted_id].png"
			user << browse_rsc(wanted_entry.img, photo_id)
		wanted_info += list(list(
			"id" = wanted_entry.wanted_id,
			"active" = wanted_entry.active,
			"criminal" = wanted_entry.criminal,
			"crime" = wanted_entry.body,
			"danger_level" = wanted_entry.danger_level,
			"author" = wanted_entry.scanned_user,
			"image" = photo_id,
			"has_image" = wanted_entry.has_image,
		))

	//Code breaking down the channels that have been made on-station thus far. ha
	//Then, breaks down the messages that have been made on those channels.
	if(current_channel)
		for(var/datum/feed_message/feed_message as anything in current_channel.messages)
			var/photo_ID = null
			var/list/photo_IDs = list()
			var/list/comment_list
			if(length(feed_message.imgs))
				for(var/i in 1 to length(feed_message.imgs))
					var/icon/photo = feed_message.imgs[i]
					var/iter_photo_ID = "tmp_newscaster_[current_channel.channel_ID]_[feed_message.message_ID]_[i].png"
					user << browse_rsc(photo, iter_photo_ID)
					photo_IDs += iter_photo_ID
			else if(feed_message.img)
				photo_ID = "tmp_newscaster_[current_channel.channel_ID]_[feed_message.message_ID]_1.png"
				user << browse_rsc(feed_message.img, photo_ID)
				photo_IDs += photo_ID
			if(length(photo_IDs))
				photo_ID = photo_IDs[1]
			for(var/datum/feed_comment/comment_message as anything in feed_message.comments)
				comment_list += list(list(
					"auth" = comment_message.author,
					"body" = comment_message.body,
					"time" = comment_message.time_stamp,
				))
			var/auth_m = feed_message.return_author()
			message_list += list(list(
				"headline" = feed_message.headline,
				"auth" = auth_m,
				"body" = feed_message.body,
				"time" = feed_message.time_stamp,
				"channel_num" = feed_message.parent_ID,
				"censored_message" = feed_message.body_censor,
				"censored_author" = feed_message.author_censor,
				"ID" = feed_message.message_ID,
				"photo" = photo_ID,
				"photos" = photo_IDs,
				"photo_caption" = feed_message.caption,
				"comments" = comment_list
			))


	data["viewing_channel"] = current_channel?.channel_ID
	data["paper"] = paper_remaining
	var/current_user_name = data["user"]["name"]
	data["isChannelOwner"] = !!(current_channel && !data["user"]["silicon"] && current_user_name == current_channel.author)
	//Here we display all the information about the current channel.
	data["channelName"] = current_channel?.channel_name
	data["channelAuthor"] = current_channel?.author

	if(!current_channel)
		data["channelAuthor"] = "Nanotrasen Inc"
		data["channelDesc"] = "Please select a News Source to view broadcasts and articles."
		data["channelLocked"] = TRUE
		data["channelAllowedPosters"] = list()
		data["pinnedArticle"] = null
	else
		data["channelDesc"] = current_channel.channel_desc
		data["channelLocked"] = current_channel.locked
		data["channelCensored"] = current_channel.censored
		data["channelAllowedPosters"] = current_channel.allowed_posters
		var/list/pinned_article = null
		if(current_channel.pinned_message_id)
			for(var/datum/feed_message/potential_pinned as anything in current_channel.messages)
				if(potential_pinned.message_ID == current_channel.pinned_message_id)
					var/pinned_photo_id = null
					if(length(potential_pinned.imgs))
						var/icon/pinned_photo = potential_pinned.imgs[1]
						pinned_photo_id = "tmp_newscaster_[current_channel.channel_ID]_[potential_pinned.message_ID]_1.png"
						user << browse_rsc(pinned_photo, pinned_photo_id)
					else if(potential_pinned.img)
						pinned_photo_id = "tmp_newscaster_[current_channel.channel_ID]_[potential_pinned.message_ID]_1.png"
						user << browse_rsc(potential_pinned.img, pinned_photo_id)
					pinned_article = list(
						"ID" = potential_pinned.message_ID,
						"headline" = potential_pinned.headline,
						"photo" = pinned_photo_id,
					)
					break
		data["pinnedArticle"] = pinned_article

	data["editor"] = list()
	data["editor"]["channelName"] = channel_name
	data["editor"]["channelDesc"] = channel_desc
	data["editor"]["channelLocked"] = channel_locked

	//We send all the information about all messages in existence.
	data["messages"] = message_list
	data["wanted"] = wanted_info

	var/list/formatted_requests = list()
	var/list/formatted_completed_requests = list()
	for (var/datum/station_request/request as anything in GLOB.request_list)
		formatted_requests += list(list(
			"owner" = request.owner,
			"value" = request.value,
			"quantity" = request.quantity,
			"title" = request.title,
			"description" = request.description,
			"acc_number" = request.request_id || request.req_number,
			"status" = request.status,
			"claimant" = request.claimant_name,
		))
	for (var/datum/station_request/request as anything in GLOB.completed_request_list)
		formatted_completed_requests += list(list(
			"owner" = request.owner,
			"value" = request.value,
			"quantity" = request.quantity,
			"title" = request.title,
			"description" = request.description,
			"acc_number" = request.request_id || request.req_number,
			"status" = request.status,
			"claimant" = request.claimant_name,
			"tags" = request.status_tags?.Join(", "),
		))
	data["requests"] = formatted_requests
	data["completedRequests"] = formatted_completed_requests
	data["bountyValue"] = bounty_value
	data["bountyQuantity"] = bounty_quantity
	data["bountyTitle"] = bounty_title
	data["bountyText"] = bounty_text

	var/list/channel_list = list()
	for(var/datum/feed_channel/channel as anything in GLOB.news_network.network_channels)
		channel_list += list(list(
			"name" = channel.channel_name,
			"author" = channel.author,
			"censored" = channel.censored,
			"locked" = channel.locked,
			"ID" = channel.channel_ID,
			"desc" = channel.channel_desc,
		))

	data["channels"] = channel_list

	return data


/obj/machinery/newscaster/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/current_ref_num = params["request"]
	var/current_app_num = params["applicant"]
	var/datum/bank_account/request_target
	if(current_ref_num)
		for(var/datum/station_request/iterated_station_request as anything in GLOB.request_list)
			if(iterated_station_request.request_id == current_ref_num || iterated_station_request.req_number == current_ref_num)
				active_request = iterated_station_request
				break
	if(active_request?.claimant_account && active_request.claimant_account.account_id == current_app_num)
		request_target = active_request.claimant_account
	var/is_silicon_user = issilicon(usr)
	switch(action)
		if("setChannel")
			var/prototype_channel = params["channel"]
			if(isnull(prototype_channel))
				return TRUE
			for(var/datum/feed_channel/potential_channel as anything in GLOB.news_network.network_channels)
				if(prototype_channel == potential_channel.channel_ID)
					current_channel = potential_channel
			viewing_wanted = FALSE
			editing_wanted = FALSE

		if("returnToSourceSelect")
			current_channel = null
			viewing_wanted = FALSE
			editing_wanted = FALSE
			return TRUE

		if("createStory")
			if(!current_channel)
				balloon_alert(usr, "select a channel first!")
				return TRUE
			var/prototype_channel = params["current"]
			create_story(channel_name = prototype_channel)

		if("togglePhoto")
			toggle_photo()
			return TRUE

		if("clearPhotos")
			clear_photos()
			return TRUE

		if("startCreateChannel")
			start_create_channel()
			return TRUE

		if("startEditChannel")
			start_edit_channel()
			return TRUE

		if("setChannelName")
			var/pre_channel_name = params["channeltext"]
			if(!pre_channel_name)
				return TRUE
			channel_name = pre_channel_name

		if("setChannelDesc")
			var/pre_channel_desc = params["channeldesc"]
			if(!pre_channel_desc)
				return TRUE
			channel_desc = pre_channel_desc

		if("setChannelLocked")
			channel_locked = !!params["channellocked"]
			return TRUE

		if("manageSetChannelName")
			manage_set_channel_name()
			return TRUE

		if("manageSetChannelDesc")
			manage_set_channel_desc()
			return TRUE

		if("manageToggleChannelPrivacy")
			manage_toggle_channel_privacy()
			return TRUE

		if("manageAddAllowedPoster")
			manage_add_allowed_poster()
			return TRUE

		if("manageRemoveAllowedPoster")
			manage_remove_allowed_poster()
			return TRUE

		if("manageSetPinnedArticle")
			manage_set_pinned_article()
			return TRUE

		if("createChannel")
			if(creating_channel)
				create_channel()
			else if(editing_channel)
				edit_channel()
			return TRUE

		if("cancelCreation")
			stop_editing_channel()
			stop_creating_channel()
			creating_comment = FALSE
			viewing_wanted = FALSE
			editing_wanted = FALSE
			criminal_name = null
			crime_description = null
			wanted_danger_level = "Armed and Dangerous"
			return TRUE

		if("storyCensor")
			if(ispAI(usr))
				return TRUE
			if(!is_silicon_user)
				var/obj/item/card/id/id_card
				if(isliving(usr))
					var/mob/living/living_user = usr
					id_card = living_user.get_idcard(hand_first = TRUE)
				if(!(ACCESS_ARMORY in id_card?.GetAccess()))
					say("ERROR: Unauthorized request.")
					return TRUE
			var/questionable_message = params["messageID"]
			for(var/datum/feed_message/iterated_feed_message as anything in current_channel.messages)
				if(iterated_feed_message.message_ID == questionable_message)
					iterated_feed_message.toggle_censor_body()
					break

		if("authorCensor")
			if(ispAI(usr))
				return TRUE
			if(!is_silicon_user)
				var/obj/item/card/id/id_card
				if(isliving(usr))
					var/mob/living/living_user = usr
					id_card = living_user.get_idcard(hand_first = TRUE)
				if(!(ACCESS_ARMORY in id_card?.GetAccess()))
					say("ERROR: Unauthorized request.")
					return TRUE
			var/questionable_message = params["messageID"]
			for(var/datum/feed_message/iterated_feed_message in current_channel.messages)
				if(iterated_feed_message.message_ID == questionable_message)
					iterated_feed_message.toggle_censor_author()
					break

		if("channelDNotice")
			if(ispAI(usr))
				return TRUE
			if(!is_silicon_user)
				var/obj/item/card/id/id_card
				if(isliving(usr))
					var/mob/living/living_user = usr
					id_card = living_user.get_idcard(hand_first = TRUE)
				if(!(ACCESS_CAPTAIN in id_card?.GetAccess()))
					say("ERROR: Unauthorized request.")
					return TRUE
			var/prototype_channel = (params["channel"])
			for(var/datum/feed_channel/potential_channel in GLOB.news_network.network_channels)
				if(prototype_channel == potential_channel.channel_ID)
					current_channel = potential_channel
					break
			current_channel.toggle_censor_D_class()
			return TRUE

		if("startComment")
			if(!get_registered_account(usr) && !is_silicon_user)
				say("ERROR: Cannot locate linked account ID.")
				creating_comment = FALSE
				return TRUE
			creating_comment = TRUE
			var/commentable_message = params["messageID"]
			if(!commentable_message)
				return TRUE
			for(var/datum/feed_message/iterated_feed_message as anything in current_channel.messages)
				if(iterated_feed_message.message_ID == commentable_message)
					current_message = iterated_feed_message
			return TRUE

		if("setCommentBody")
			var/pre_comment_text = params["commenttext"]
			if(!pre_comment_text)
				return TRUE
			comment_text = pre_comment_text
			return TRUE

		if("createComment")
			create_comment()
			return TRUE

		if("showWanted")
			alert = FALSE
			viewing_wanted = TRUE
			editing_wanted = FALSE
			if(!selected_wanted_id && length(GLOB.news_network.wanted_issues))
				selected_wanted_id = GLOB.news_network.wanted_issues[1].wanted_id
			update_overlays()
			return TRUE

		if("createWantedCase")
			if(ispAI(usr))
				return TRUE
			var/datum/bank_account/account = get_registered_account(usr)
			if(!istype(account) && !is_silicon_user)
				say("ERROR: Cannot locate linked account ID.")
				return TRUE
			if(!is_silicon_user)
				var/obj/item/card/id/id_card
				if(isliving(usr))
					var/mob/living/living_user = usr
					id_card = living_user.get_idcard(hand_first = TRUE)
				if(!(ACCESS_SEC_RECORDS in id_card?.GetAccess()))
					say("ERROR: Unauthorized request.")
					return TRUE
			viewing_wanted = TRUE
			editing_wanted = TRUE
			selected_wanted_id = null
			current_image = null
			criminal_name = null
			crime_description = null
			wanted_danger_level = "Armed and Dangerous"
			alert = FALSE
			wanted_image = FALSE
			update_overlays()
			return TRUE

		if("setWantedTarget")
			selected_wanted_id = text2num(params["wantedID"])
			return TRUE

		if("editWanted")
			alert = FALSE
			viewing_wanted = TRUE
			editing_wanted = TRUE
			var/datum/wanted_message/selected_wanted
			for(var/datum/wanted_message/iterated_wanted as anything in GLOB.news_network.wanted_issues)
				if(iterated_wanted.wanted_id == selected_wanted_id)
					selected_wanted = iterated_wanted
					break
			if(!selected_wanted && length(GLOB.news_network.wanted_issues))
				selected_wanted = GLOB.news_network.wanted_issues[1]
				selected_wanted_id = selected_wanted.wanted_id
			criminal_name = selected_wanted?.criminal || criminal_name
			crime_description = selected_wanted?.body || crime_description
			wanted_danger_level = selected_wanted?.danger_level || wanted_danger_level
			update_overlays()
			return TRUE

		if("importWantedRecord")
			if(ispAI(usr))
				return TRUE
			if(!is_silicon_user)
				var/obj/item/card/id/id_card
				if(isliving(usr))
					var/mob/living/living_user = usr
					id_card = living_user.get_idcard(hand_first = TRUE)
				if(!(ACCESS_SEC_RECORDS in id_card?.GetAccess()))
					say("ERROR: Unauthorized request.")
					return TRUE
			var/list/record_options = list()
			for(var/datum/record/crew/record as anything in GLOB.manifest.general)
				if(!record?.name)
					continue
				record_options["[record.name] ([record.rank])"] = record.name
			if(!length(record_options))
				say("No crew records found.")
				return TRUE
			var/chosen_label = tgui_input_list(usr, "Import from security records", "Warrant Alert Handler", sort_list(record_options))
			if(!chosen_label)
				return TRUE
			var/chosen_name = record_options[chosen_label]
			var/datum/record/crew/chosen_record = find_record(chosen_name, GLOB.manifest.general)
			if(!chosen_record)
				say("ERROR: Record not found.")
				return TRUE
			var/import_mode = tgui_input_list(
				usr,
				"Choose data to import",
				"Warrant Alert Handler",
				list(
					"Name + Charges + Photo",
					"Name + Charges",
					"Name + Photo",
					"Photo Only",
					"Name Only",
				)
			)
			if(!import_mode)
				return TRUE
			if(import_mode != "Photo Only")
				criminal_name = chosen_record.name
			if(import_mode == "Name + Charges + Photo" || import_mode == "Name + Charges")
				var/list/charges = list()
				for(var/datum/crime_record/crime as anything in chosen_record.crimes)
					if(crime?.valid)
						charges += crime.name
				for(var/datum/crime_record/citation as anything in chosen_record.citations)
					if(citation?.valid)
						charges += citation.name
				if(length(charges))
					crime_description = "Known charges: [charges.Join(", ")]"
				else if(chosen_record.security_note)
					crime_description = "Security note: [chosen_record.security_note]"
				else
					crime_description = "Imported from security records."
			if(import_mode == "Name + Charges + Photo" || import_mode == "Name + Photo" || import_mode == "Photo Only")
				current_image = null
				wanted_image = FALSE
				if(chosen_record.character_appearance)
					var/obj/item/photo/photo = chosen_record.get_front_photo()
					if(photo?.picture)
						current_image = photo.picture
						wanted_image = TRUE
				if(!wanted_image)
					say("No record photo found for this crew member.")
			return TRUE

		if("setCriminalName")
			var/temp_name = stripped_input(usr, "Write the Criminal's Name", "Warrant Alert Handler", "John Doe", MAX_NAME_LEN)
			if(!temp_name)
				return TRUE
			criminal_name = temp_name
			return TRUE

		if("setCrimeData")
			var/list/charges = list()
			while(TRUE)
				var/prompt_text = length(charges) ? "Add another charge line (leave blank to finish)." : "Add a charge line (leave blank to finish)."
				var/temp_charge = stripped_input(usr, prompt_text, "Warrant Alert Handler", "", MAX_BROADCAST_LEN)
				if(isnull(temp_charge))
					return TRUE
				if(!length(temp_charge))
					break
				charges += temp_charge
			if(!length(charges))
				return TRUE
			crime_description = charges.Join("\n")
			return TRUE

		if("setDangerLevel")
			var/list/options = list()
			for(var/level as anything in wanted_danger_options)
				options += level
			var/temp_level = tgui_input_list(usr, "Set wanted danger level", "Warrant Alert Handler", options)
			if(!temp_level)
				return TRUE
			wanted_danger_level = temp_level
			return TRUE

		if("submitWantedIssue")
			if(ispAI(usr))
				return TRUE
			if(!crime_description || !criminal_name)
				say("ERROR: Missing crime details.")
				return TRUE
			var/datum/bank_account/account = get_registered_account(usr)
			if(!istype(account) && !is_silicon_user)
				say("ERROR: Cannot locate linked account ID.")
				return TRUE
			if(!is_silicon_user)
				var/obj/item/card/id/id_card
				if(isliving(usr))
					var/mob/living/living_user = usr
					id_card = living_user.get_idcard(hand_first = TRUE)
				if(!(ACCESS_SEC_RECORDS in id_card?.GetAccess()))
					say("ERROR: Unauthorized request.")
					return TRUE
			GLOB.news_network.submit_wanted(criminal_name, crime_description, is_silicon_user ? usr.name : account.account_holder, current_image, adminMsg = FALSE, newMessage = TRUE, has_image = wanted_image, danger_level = wanted_danger_level)
			selected_wanted_id = GLOB.news_network.wanted_issue?.wanted_id
			current_image = null
			viewing_wanted = TRUE
			editing_wanted = FALSE
			criminal_name = null
			crime_description = null
			wanted_danger_level = "Armed and Dangerous"
			wanted_image = FALSE
			return TRUE

		if("clearWantedIssue")
			if(ispAI(usr))
				return TRUE
			if(!is_silicon_user)
				var/obj/item/card/id/id_card
				if(isliving(usr))
					var/mob/living/living_user = usr
					id_card = living_user.get_idcard(hand_first = TRUE)
				if(!(ACCESS_SEC_RECORDS in id_card?.GetAccess()))
					say("ERROR: Unauthorized request.")
					return TRUE
			clear_wanted_issue(user = usr, wanted_id = selected_wanted_id)
			if(length(GLOB.news_network.wanted_issues))
				selected_wanted_id = GLOB.news_network.wanted_issues[1].wanted_id
			else
				selected_wanted_id = null
			for(var/obj/machinery/newscaster/other_newscaster in GLOB.allCasters)
				other_newscaster.update_icon()
				return TRUE

		if("printNewspaper")
			print_paper()
			return TRUE

		if("createBounty")
			create_bounty()
			return TRUE

		if("claim")
			apply_to_bounty()
			return TRUE

		if("payApplicant")
			pay_applicant(payment_target = request_target)
			return TRUE

		if("expireBounty")
			expire_bounty()
			return TRUE

		if("failBounty")
			fail_bounty()
			return TRUE

		if("unclaim")
			unclaim_bounty()
			return TRUE

		if("printBounty")
			print_bounty_request()
			return TRUE

		if("deleteRequest")
			delete_bounty_request()
			return TRUE

		if("bountyVal")
			bounty_value = text2num(params["bountyval"])
			if(!bounty_value)
				bounty_value = 1

		if("bountyQty")
			bounty_quantity = text2num(params["bountyqty"])
			if(!bounty_quantity)
				bounty_quantity = 1

		if("bountyTitle")
			var/pre_bounty_title = params["bountytitle"]
			if(isnull(pre_bounty_title))
				return
			bounty_title = pre_bounty_title

		if("bountyText")
			var/pre_bounty_text = params["bountytext"]
			if(isnull(pre_bounty_text))
				return
			bounty_text = pre_bounty_text
	return TRUE


/obj/machinery/newscaster/attackby(obj/item/I, mob/living/user, params)
	if(I.tool_behaviour == TOOL_WRENCH)
		to_chat(user, span_notice("You start [anchored ? "un" : ""]securing [name]..."))
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 60))
			playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
			if(machine_stat & BROKEN)
				to_chat(user, span_warning("The broken remains of [src] fall on the ground."))
				new /obj/item/stack/sheet/iron(loc, 5)
				new /obj/item/shard(loc)
				new /obj/item/shard(loc)
			else
				to_chat(user, span_notice("You [anchored ? "un" : ""]secure [name]."))
				new /obj/item/wallframe/newscaster(loc)
			qdel(src)
	else if(I.tool_behaviour == TOOL_WELDER && !user.combat_mode)
		if(machine_stat & BROKEN)
			if(!I.tool_start_check(user, amount=0))
				return
			user.visible_message(span_notice("[user] is repairing [src]."), \
							span_notice("You begin repairing [src]..."), \
							span_hear("You hear welding."))
			if(I.use_tool(src, user, 40, volume=50))
				if(!(machine_stat & BROKEN))
					return
				to_chat(user, span_notice("You repair [src]."))
				atom_integrity = max_integrity
				set_machine_stat(machine_stat & ~BROKEN)
				update_icon()
		else
			to_chat(user, span_notice("[src] does not need repairs."))

	else if(istype(I, /obj/item/paper))
		if(!user.temporarilyRemoveItemFromInventory(I))
			return
		else
			paper_remaining ++
			to_chat(user, span_notice("You insert the [I] into \the [src]! It now holds [paper_remaining] sheets of paper."))
			qdel(I)
			return
	return ..()

/obj/machinery/newscaster/play_attack_sound(damage, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(machine_stat & BROKEN)
				playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 100, TRUE)
			else
				playsound(loc, 'sound/effects/glasshit.ogg', 90, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)


/obj/machinery/newscaster/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc, 2)
		new /obj/item/shard(loc)
		new /obj/item/shard(loc)
	qdel(src)

/obj/machinery/newscaster/atom_break(damage_flag)
	. = ..()
	if(.)
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, TRUE)


/obj/machinery/newscaster/attack_paw(mob/living/user, list/modifiers)
	if(!user.combat_mode)
		to_chat(user, span_warning("The newscaster controls are far too complicated for your tiny brain!"))
	else
		take_damage(5, BRUTE, MELEE)

/obj/machinery/newscaster/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	update_icon()

/**
 * Sends photo data to build the newscaster article.
 * Returns all pending photos (up to 3) if any, otherwise null.
 */
/obj/machinery/newscaster/proc/send_photo_data()
	if(!length(pending_photos))
		return null
	var/list/photos = list()
	for(var/datum/picture/pic as anything in pending_photos)
		photos += pic
	return photos

/**
 * This takes a held photograph, and updates the current_image variable with that of the held photograph's image.
 * *user: The mob who is being checked for a held photo object.
 */
/obj/machinery/newscaster/proc/attach_photo(mob/user)
	if(issilicon(user))
		var/mob/living/silicon/S = user
		var/datum/picture/selection = S.aicamera?.selectpicture(user)
		if(selection)
			current_image = selection
	else
		var/obj/item/photo/photo = user.is_holding_item_of_type(/obj/item/photo)
		if(photo)
			current_image = photo.picture

/**
 * This takes all current feed stories and messages, and prints them onto a newspaper, after checking that the newscaster has been loaded with paper.
 * The newscaster then prints the paper to the floor.
 */
/obj/machinery/newscaster/proc/print_paper()
	if(issilicon(usr))
		return TRUE
	if(paper_remaining <= 0)
		balloon_alert_to_viewers("out of paper!")
		return TRUE
	SSblackbox.record_feedback("amount", "newspapers_printed", 1)
	var/obj/item/newspaper/new_newspaper = new /obj/item/newspaper
	for(var/datum/feed_channel/iterated_feed_channel in GLOB.news_network.network_channels)
		new_newspaper.news_content += iterated_feed_channel
	if(GLOB.news_network.wanted_issue.active)
		new_newspaper.wantedAuthor = GLOB.news_network.wanted_issue.scanned_user
		new_newspaper.wantedCriminal = GLOB.news_network.wanted_issue.criminal
		new_newspaper.wantedBody = GLOB.news_network.wanted_issue.body
		if(GLOB.news_network.wanted_issue.img)
			new_newspaper.wantedPhoto = GLOB.news_network.wanted_issue.img
	new_newspaper.forceMove(drop_location())
	new_newspaper.creation_time = GLOB.news_network.last_action
	paper_remaining--

/**
 * This clears alerts on the newscaster from a new message being published and updates the newscaster's appearance.
 */
/obj/machinery/newscaster/proc/remove_alert()
	alert = FALSE
	update_overlays()

/**
 * When a new feed message is made that will alert all newscasters, this causes the newscasters to sent out a spoken message as well as create a sound.
 */
/obj/machinery/newscaster/proc/news_alert(channel, update_alert = TRUE)
	if(channel)
		if(update_alert)
			say("Breaking news from [channel]!")
			playsound(loc, 'sound/machines/twobeep_high.ogg', 75, TRUE)
		alert = TRUE
		update_overlays()
		addtimer(CALLBACK(src, PROC_REF(remove_alert)), ALERT_DELAY, TIMER_UNIQUE|TIMER_OVERRIDE)

	else if(!channel && update_alert)
		say("Attention! Wanted issue distributed!")
		playsound(loc, 'sound/machines/warning-buzzer.ogg', 75, TRUE)

/**
 * Performs a series of sanity checks before giving the user confirmation to create a new feed_channel using channel_name, and channel_desc.
 */
/obj/machinery/newscaster/proc/create_channel()
	if(!channel_name)
		return
	for(var/datum/feed_channel/iterated_feed_channel as anything in GLOB.news_network.network_channels)
		if(iterated_feed_channel.channel_name == channel_name)
			alert(usr, "ERROR: Feed channel with that name already exists on the Network.", "Okay")
			return TRUE
	if(!channel_desc)
		say("ERROR: No channel description present.")
		return TRUE
	var/datum/bank_account/account = get_registered_account(usr)
	if(!istype(account) && !issilicon(usr))
		say("ERROR: Cannot locate linked account ID.")
		stop_creating_channel()
		return TRUE
	var/choice = alert(usr, "Please confirm feed channel creation","Network Channel Handler", "Confirm", "Cancel")
	if(choice == "Confirm")
		GLOB.news_network.create_feed_channel(channel_name, issilicon(usr) ? usr.name : account.account_holder, channel_desc, locked = channel_locked)
		SSblackbox.record_feedback("text", "newscaster_channels", 1, "[channel_name]")
	stop_creating_channel()

/obj/machinery/newscaster/proc/edit_channel()
	if(!channel_name)
		return
	for(var/datum/feed_channel/iterated_feed_channel as anything in GLOB.news_network.network_channels)
		if(iterated_feed_channel != current_channel && iterated_feed_channel.channel_name == channel_name)
			alert(usr, "ERROR: Feed channel with that name already exists on the Network.", "Okay")
			return TRUE
	if(!channel_desc)
		say("ERROR: No channel description present.")
		return TRUE
	var/datum/bank_account/account = get_registered_account(usr)
	if(!istype(account) && !issilicon(usr))
		say("ERROR: Cannot locate linked account ID.")
		stop_editing_channel()
		return TRUE
	if(current_channel.author != (issilicon(usr) ? usr.name : account.account_holder))
		say("ERROR: Unauthorized request.")
		stop_editing_channel()
		return TRUE
	current_channel.channel_name = channel_name
	current_channel.channel_desc = channel_desc
	current_channel.locked = channel_locked
	stop_editing_channel()

/obj/machinery/newscaster/proc/stop_editing_channel()
	editing_channel = FALSE
	channel_name = null
	channel_desc = null
	channel_locked = null

/obj/machinery/newscaster/proc/stop_creating_channel()
	creating_channel = FALSE
	channel_name = null
	channel_desc = null
	channel_locked = null

/**
 * Constructs a comment to attach to the currently selected feed_message of choice, assuming that a user can be found and that a message body has been written.
 */
/obj/machinery/newscaster/proc/create_comment()
	if(!comment_text)
		creating_comment = FALSE
		return TRUE
	var/datum/bank_account/account = get_registered_account(usr)
	if(!istype(account) && !issilicon(usr))
		say("ERROR: Cannot locate linked account ID.")
		creating_comment = FALSE
		return TRUE
	var/datum/feed_comment/new_feed_comment = new/datum/feed_comment
	var/author_text = issilicon(usr) ? "[usr.name] ([usr.job])" : "[account.account_holder] ([account.account_job?.title])"
	new_feed_comment.author = author_text
	new_feed_comment.body = comment_text
	new_feed_comment.time_stamp = station_time_timestamp()
	current_message.comments += new_feed_comment
	usr.log_message("(as [author_text]) commented on message [current_message.return_body(-1)] -- [current_message.body]", LOG_COMMENT)
	creating_comment = FALSE

/**
 * This proc performs checks before enabling the creating_channel var on the newscaster, such as preventing a user from having multiple channels,
 * preventing an un-ID'd user from making a channel, and preventing censored authors from making a channel.
 * Otherwise, sets creating_channel to TRUE.
 */
/obj/machinery/newscaster/proc/start_create_channel()
	if(editing_channel)
		return TRUE
	var/datum/bank_account/account = get_registered_account(usr)
	if(!istype(account) && !issilicon(usr))
		say("ERROR: Cannot locate linked account ID.")
		stop_creating_channel()
		return TRUE
	//This first block checks for pre-existing reasons to prevent you from making a new channel, like being censored, or if you have a channel already.
	var/list/existing_authors = list()
	for(var/datum/feed_channel/iterated_feed_channel as anything in GLOB.news_network.network_channels)
		if(iterated_feed_channel.author_censor)
			existing_authors += GLOB.news_network.redacted_text
		else
			existing_authors += iterated_feed_channel.author
	var/usr_name = issilicon(usr) ? usr.name : account.account_holder
	if((usr_name == "Unknown") || (usr_name in existing_authors) || isnull(usr_name))
		stop_creating_channel()
		alert(usr, "ERROR: User cannot be found or already has an owned feed channel.", "Okay")
		return TRUE
	creating_channel = TRUE
	return TRUE

/obj/machinery/newscaster/proc/start_edit_channel()
	if(creating_channel)
		return TRUE
	var/datum/bank_account/account = get_registered_account(usr)
	if(!istype(account) && !issilicon(usr))
		say("ERROR: Cannot locate linked account ID.")
		stop_editing_channel()
		return TRUE
	if(current_channel.author != (issilicon(usr) ? usr.name : account.account_holder))
		say("ERROR: Unauthorized request.")
		stop_editing_channel()
		return TRUE
	// set initial values to current channel settings
	channel_name = current_channel.channel_name
	channel_desc = current_channel.channel_desc
	channel_locked = current_channel.locked
	editing_channel = TRUE
	return TRUE

/obj/machinery/newscaster/proc/get_user_feed_name(mob/user = usr)
	if(issilicon(user))
		return null
	var/datum/bank_account/account = get_registered_account(user)
	if(istype(account))
		return account.account_holder
	return null

/obj/machinery/newscaster/proc/can_manage_current_channel(mob/user = usr)
	if(!current_channel)
		return FALSE
	var/user_name = get_user_feed_name(user)
	if(!user_name)
		return FALSE
	return current_channel.author == user_name

/obj/machinery/newscaster/proc/manage_set_channel_name()
	if(!can_manage_current_channel())
		say("ERROR: Unauthorized request.")
		return TRUE
	var/new_name = stripped_input(usr, "Set channel name", "Channel Management", current_channel.channel_name, 42)
	if(!new_name)
		return TRUE
	for(var/datum/feed_channel/iterated_feed_channel as anything in GLOB.news_network.network_channels)
		if(iterated_feed_channel != current_channel && iterated_feed_channel.channel_name == new_name)
			say("ERROR: Feed channel with that name already exists.")
			return TRUE
	current_channel.channel_name = new_name
	return TRUE

/obj/machinery/newscaster/proc/manage_set_channel_desc()
	if(!can_manage_current_channel())
		say("ERROR: Unauthorized request.")
		return TRUE
	var/new_desc = stripped_multiline_input(usr, "Set channel description", "Channel Management", current_channel.channel_desc, MAX_BROADCAST_LEN)
	if(!new_desc)
		return TRUE
	current_channel.channel_desc = new_desc
	return TRUE

/obj/machinery/newscaster/proc/manage_toggle_channel_privacy()
	if(!can_manage_current_channel())
		say("ERROR: Unauthorized request.")
		return TRUE
	current_channel.locked = !current_channel.locked
	say("Channel is now [current_channel.locked ? "Private" : "Public"].")
	return TRUE

/obj/machinery/newscaster/proc/manage_add_allowed_poster()
	if(!can_manage_current_channel())
		say("ERROR: Unauthorized request.")
		return TRUE
	var/list/crew_names = list()
	for(var/datum/record/crew/record as anything in GLOB.manifest.general)
		if(!record?.name)
			continue
		if(record.name == current_channel.author)
			continue
		if(record.name in current_channel.allowed_posters)
			continue
		crew_names += record.name
	if(!length(crew_names))
		say("No eligible crew found on manifest.")
		return TRUE
	crew_names = sort_list(crew_names)
	var/chosen_name = tgui_input_list(usr, "Select crewmember to allow posting", "Channel Management", crew_names)
	if(!chosen_name)
		return TRUE
	if(!find_record(chosen_name, GLOB.manifest.general))
		say("ERROR: Crewmember not found on manifest.")
		return TRUE
	if(!(chosen_name in current_channel.allowed_posters))
		current_channel.allowed_posters += chosen_name
	return TRUE

/obj/machinery/newscaster/proc/manage_remove_allowed_poster()
	if(!can_manage_current_channel())
		say("ERROR: Unauthorized request.")
		return TRUE
	if(!length(current_channel.allowed_posters))
		say("No additional posters set.")
		return TRUE
	var/list/removable = list()
	for(var/name as anything in current_channel.allowed_posters)
		removable += name
	removable = sort_list(removable)
	var/chosen_name = tgui_input_list(usr, "Select allowed poster to remove", "Channel Management", removable)
	if(!chosen_name)
		return TRUE
	current_channel.allowed_posters -= chosen_name
	return TRUE

/obj/machinery/newscaster/proc/manage_set_pinned_article()
	if(!can_manage_current_channel())
		say("ERROR: Unauthorized request.")
		return TRUE
	if(!length(current_channel.messages))
		say("No articles available to pin.")
		return TRUE
	var/list/choice_to_id = list("None (Unpin)" = null)
	var/list/options = list("None (Unpin)")
	for(var/datum/feed_message/message as anything in current_channel.messages)
		var/headline = message.headline || "Untitled Article"
		var/label = "[headline] (#ID [message.message_ID])"
		choice_to_id[label] = message.message_ID
		options += label
	var/chosen = tgui_input_list(usr, "Select pinned article", "Channel Management", options)
	if(isnull(chosen))
		return TRUE
	current_channel.pinned_message_id = choice_to_id[chosen]
	return TRUE

/**
 * Creates a new feed story to the global newscaster network.
 * Verifies that the message is being written to a real feed_channel, then provides a text input for the feed story to be written into.
 * Finally, it submits the message to the network, is logged globally, and clears all message-specific variables from the machine.
 */
/obj/machinery/newscaster/proc/create_story(channel_name)
	var/datum/bank_account/account = get_registered_account(usr)
	if(!istype(account) && !issilicon(usr))
		say("ERROR: Cannot locate linked account ID.")
		return TRUE
	for(var/datum/feed_channel/potential_channel as anything in GLOB.news_network.network_channels)
		if(channel_name == potential_channel.channel_ID)
			current_channel = potential_channel
			break
	var/usr_name = issilicon(usr) ? usr.name : account.account_holder
	if(current_channel.locked && current_channel.author != usr_name && !(usr_name in current_channel.allowed_posters))
		say("ERROR: Unauthorized request.")
		return TRUE
	writing_story = TRUE
	var/temp_headline = stripped_input(usr, "Write your article headline", "Network Channel Handler", feed_channel_headline, 250)
	if(length(temp_headline) <= 1)
		writing_story = FALSE
		return TRUE
	if(temp_headline)
		feed_channel_headline = temp_headline
	var/temp_message = stripped_multiline_input(usr, "Write your Feed story", "Network Channel Handler", feed_channel_message, 5000)
	if(length(temp_message) <= 1)
		writing_story = FALSE
		return TRUE
	if(temp_message)
		feed_channel_message = temp_message
	GLOB.news_network.submit_article("<font face=\"[PEN_FONT]\">[parsemarkdown(feed_channel_message, usr)]</font>", usr_name, current_channel.channel_name, send_photo_data(), adminMessage = FALSE, allow_comments = TRUE, author_job = issilicon(usr) ? usr.job : account.account_job.title, author_account = account, headline = feed_channel_headline)
	SSblackbox.record_feedback("amount", "newscaster_stories", 1)
	feed_channel_headline = ""
	feed_channel_message = ""
	pending_photos = list()
	writing_story = FALSE

/**
 * Selects a currently held photo from the user's hand and makes it the current_image held by the newscaster.
 * If a photo is still held in the newscaster, it will otherwise clear it from the machine.
 */
/obj/machinery/newscaster/proc/toggle_photo()
	if(editing_wanted)
		// Wanted issue: single image toggle
		if(current_image)
			balloon_alert(usr, "photo cleared.")
			current_image = null
			wanted_image = FALSE
			return TRUE
		attach_photo(usr)
		wanted_image = !!current_image
		if(current_image)
			balloon_alert(usr, "photo selected.")
			playsound(src, 'sound/machines/terminal_success.ogg', 15, TRUE)
		else
			balloon_alert(usr, "no photo identified.")
	else
		// Article photos: add to pending list (up to 3)
		if(length(pending_photos) >= 3)
			balloon_alert(usr, "max 3 photos queued!")
			return TRUE
		attach_photo(usr)
		if(current_image)
			pending_photos += current_image
			current_image = null
			balloon_alert(usr, "photo queued ([length(pending_photos)]/3).")
			playsound(src, 'sound/machines/terminal_success.ogg', 15, TRUE)
		else
			balloon_alert(usr, "no photo identified.")

/obj/machinery/newscaster/proc/clear_photos()
	pending_photos = list()
	balloon_alert(usr, "photos cleared.")

/obj/machinery/newscaster/proc/clear_wanted_issue(user, wanted_id)
	if(ispAI(user))
		return FALSE
	if(!issilicon(user))
		var/obj/item/card/id/id_card
		if(isliving(user))
			var/mob/living/living_user = user
			id_card = living_user.get_idcard(hand_first = TRUE)
		if(!(ACCESS_SEC_RECORDS in id_card?.GetAccess()))
			say("Clearance not found.")
			return TRUE
	GLOB.news_network.delete_wanted(wanted_id)
	GLOB.news_network.wanted_issue.danger_level = null
	wanted_image = FALSE
	current_image = null
	wanted_danger_level = "Armed and Dangerous"
	return TRUE

/**
 * This proc removes a station_request from the global list of requests, after checking that the owner of that request is the one who is trying to remove it.
 */
/obj/machinery/newscaster/proc/delete_bounty_request()
	if(issilicon(usr))
		return TRUE
	var/datum/bank_account/account = get_registered_account(usr)
	if(!istype(account))
		say("ERROR: Cannot locate linked account ID.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	if(!active_request)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	if(active_request?.owner != account.account_holder)
		say("ERROR: Unauthorized request.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	if(active_request.status != "open")
		say("ERROR: Only open bounties can be deleted.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	GLOB.request_list.Remove(active_request)
	active_request = null
	say("Bounty deleted.")

/obj/machinery/newscaster/proc/unclaim_bounty()
	if(issilicon(usr))
		return TRUE
	var/datum/bank_account/account = get_registered_account(usr)
	if(!istype(account))
		say("ERROR: Cannot locate linked account ID.")
		return TRUE
	if(!active_request)
		return TRUE
	if(active_request.owner != account.account_holder)
		say("ERROR: Unauthorized request.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	if(!active_request.unclaim())
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	say("Bounty reopened.")

/obj/machinery/newscaster/proc/expire_bounty()
	if(issilicon(usr))
		return TRUE
	var/datum/bank_account/account = get_registered_account(usr)
	if(!istype(account))
		say("ERROR: Cannot locate linked account ID.")
		return TRUE
	if(!active_request)
		return TRUE
	if(active_request.owner != account.account_holder)
		say("ERROR: Unauthorized request.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	if(active_request.status != "claimed")
		say("ERROR: Only claimed bounties can be expired.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	archive_bounty(active_request, list("Expired", "Completed"))
	say("Bounty marked as expired.")

/obj/machinery/newscaster/proc/fail_bounty()
	if(issilicon(usr))
		return TRUE
	var/datum/bank_account/account = get_registered_account(usr)
	if(!istype(account))
		say("ERROR: Cannot locate linked account ID.")
		return TRUE
	if(!active_request)
		return TRUE
	if(active_request.owner != account.account_holder)
		say("ERROR: Unauthorized request.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	if(active_request.status != "claimed")
		say("ERROR: Only claimed bounties can be failed.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	archive_bounty(active_request, list("Failed", "Completed"))
	say("Bounty marked as failed.")

/**
 * This creates a new bounty to the global list of bounty requests, alongisde the provided value of the request, and the owner of the request.
 * For more info, see datum/station_request.
 */
/obj/machinery/newscaster/proc/create_bounty()
	if(issilicon(usr))
		return TRUE
	var/datum/bank_account/account = get_registered_account(usr)
	if(!istype(account))
		say("ERROR: Cannot locate linked account ID.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	if(!bounty_title)
		say("ERROR: No bounty name.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	var/active_owned_bounties = 0
	for(var/datum/station_request/iterated_station_request as anything in GLOB.request_list)
		if(iterated_station_request.req_number == account.account_id)
			active_owned_bounties++
	if(active_owned_bounties >= 3)
		say("ERROR: Account already has 3 active bounties.")
		return TRUE
	var/datum/station_request/curr_request = new /datum/station_request(account.account_holder, bounty_value, bounty_quantity, bounty_title, bounty_text, account.account_id, account)
	GLOB.request_list += list(curr_request)
	bounty_quantity = 1
	bounty_title = ""
	bounty_text = ""
	for(var/obj/iterated_bounty_board as anything in GLOB.allbountyboards)
		iterated_bounty_board.say("New bounty added!")
		playsound(iterated_bounty_board.loc, 'sound/effects/cashregister.ogg', 30, TRUE)
/**
 * This sorts through the current list of bounties, and confirms that the intended request found is correct.
 * Then, adds the current user to the list of applicants to that bounty.
 */
/obj/machinery/newscaster/proc/apply_to_bounty()
	if(issilicon(usr))
		return TRUE
	var/datum/bank_account/account = get_registered_account(usr)
	if(!istype(account))
		say("ERROR: Cannot locate linked account ID.")
		return TRUE
	if(!active_request)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	if(account.account_holder == active_request.owner)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	if(active_request.status != "open")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	if(!active_request.claim(account))
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	say("Bounty claimed by [account.account_holder].")
	print_bounty_request()
	notify_bounty_owner(active_request, account.account_holder)

/**
 * Sends an automated PDA message to the bounty owner notifying them their bounty was claimed.
 */
/obj/machinery/newscaster/proc/notify_bounty_owner(datum/station_request/request, claimant_name)
	if(!request?.owner)
		return
	for(var/obj/item/modular_computer/tablet as anything in GLOB.TabletMessengers)
		if(tablet.saved_identification != request.owner)
			continue
		var/datum/signal/subspace/messaging/tablet_msg/signal = new(src, list(
			name = "Bounty Board",
			job = "Bounty Board",
			message = "Your bounty \"[request.title || "Untitled"]\" has been claimed by [claimant_name].",
			targets = list(tablet),
			automated = TRUE
		))
		signal.send_to_receivers()
		break

/**
 * This pays out the current request_target the amount held by the active request's assigned value, and then clears the active request from the global list.
 */
/obj/machinery/newscaster/proc/pay_applicant(datum/bank_account/payment_target)
	if(issilicon(usr))
		return TRUE
	var/datum/bank_account/account = get_registered_account(usr)
	if(!istype(account))
		say("ERROR: Cannot locate linked account ID.")
		return TRUE
	if(!active_request)
		return TRUE
	if(!payment_target)
		payment_target = active_request.claimant_account
	if(!payment_target)
		say("ERROR: No claimant selected.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		return TRUE
	var/has_money = account.has_money(active_request.value)
	if((account.account_holder != active_request.owner) || !has_money)
		if(has_money)
			say("ERROR: Unauthorized request.")
		else
			say("ERROR: Insufficient funds.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		return TRUE
	payment_target.transfer_money(account, active_request.value)
	say("Paid out [active_request.value] credits.")
	archive_bounty(active_request, list("Paid", "Completed"), payment_target)

/obj/machinery/newscaster/proc/archive_bounty(datum/station_request/request, list/tags, datum/bank_account/account = request?.claimant_account)
	if(!request)
		return FALSE
	request.complete(tags, account)
	GLOB.request_list.Remove(request)
	if(!(request in GLOB.completed_request_list))
		GLOB.completed_request_list += request
	if(active_request == request)
		active_request = null
	return TRUE

/obj/machinery/newscaster/proc/print_bounty_request()
	if(issilicon(usr))
		return TRUE
	if(!active_request)
		return TRUE
	if(active_request.status != "claimed")
		say("ERROR: Only claimed bounties can be printed.")
		return TRUE
	var/obj/item/paper/printed_paper = new /obj/item/paper(drop_location())
	printed_paper.name = "paper - '[active_request.title || "Bounty Record"]'"
	var/paper_text = "<center><b>Bounty Claim Slip</b></center><br>"
	paper_text += "<b>Name:</b> [active_request.title || "Untitled"]<br>"
	paper_text += "<b>Quantity:</b> [active_request.quantity || 1]<br>"
	paper_text += "<b>Reward:</b> [active_request.value] credits<br>"
	paper_text += "<b>Issuer:</b> [active_request.owner || "Unknown"]<br>"
	paper_text += "<b>Claimant:</b> [active_request.claimant_name || "Unassigned"]<br><br>"
	paper_text += "<b>Description:</b><br>[active_request.description || "None"]"
	printed_paper.add_raw_text(paper_text)
	printed_paper.update_appearance()
	return TRUE

/obj/item/wallframe/newscaster
	name = "newscaster frame"
	desc = "Used to build newscasters, just secure to the wall."
	icon_state = "newscaster"
	custom_materials = list(/datum/material/iron=14000, /datum/material/glass=8000)
	result_path = /obj/machinery/newscaster
	pixel_shift = 30

#undef ALERT_DELAY
