#define ALERT_DELAY 50 SECONDS

/obj/machinery/newscaster
	name = "newscaster"
	desc = "A standard Nanotrasen-licensed newsfeed handler for use in commercial space stations. All the news you absolutely have no use for, in one place!"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "newscaster_off"
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	armor = list(MELEE = 50,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 30)
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
	///The current image that will be submitted with the newscaster story.
	var/datum/picture/current_image
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
	///Value of the currently bounty input
	var/bounty_value = 1
	///Text of the currently written bounty
	var/bounty_text = ""

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

/obj/machinery/newscaster/update_icon()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		set_light(0)
		return
	set_light(1.4,0.7,"#34D352") // green light

/obj/machinery/newscaster/update_overlays()
	. = ..()
	if(!(machine_stat & (NOPOWER|BROKEN)))
		var/state = "newscaster_[GLOB.news_network.wanted_issue.active ? "wanted" : "normal"]"
		. += mutable_appearance(icon, state)

		if(GLOB.news_network.wanted_issue.active && alert)
			. += mutable_appearance(icon, "newscaster_alert")

	var/hp_percent = (obj_integrity * 100) / max_integrity
	switch(hp_percent)
		if(75 to 100)
			return
		if(50 to 75)
			. += mutable_appearance(icon, "crack1")
		if(25 to 50)
			. += mutable_appearance(icon, "crack2")
		else
			. += mutable_appearance(icon, "crack3")

/obj/machinery/newscaster/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PhysicalNewscaster", name)
		ui.open()
	alert = FALSE //We're checking our messages!
	update_icon()

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
	data["security_mode"] = (ACCESS_ARMORY in card?.GetAccess())
	if(card?.registered_account)
		data["user"]["authenticated"] = TRUE
		data["user"]["name"] = card.registered_account.account_holder
		var/datum/data/record/R = find_record("name", card.registered_account.account_holder, GLOB.data_core.general)
		if(R)
			data["user"]["job"] = R.fields["name"]
			data["user"]["department"] = R.fields[""]
		else if(card.registered_account.account_job)
			data["user"]["job"] = card.registered_account.account_job.title
			data["user"]["department"] = card.registered_account.account_job.bank_account_department
		else
			data["user"]["job"] = "No Job"
			data["user"]["department"] = "No Department"
	else if(issilicon(user))
		data["user"]["authenticated"] = TRUE
		data["user"]["silicon"] = TRUE
		data["user"]["name"] = user.name
		data["user"]["job"] = user.job
		data["security_mode"] = !ispAI(user)
	else
		data["user"]["name"] = "Unknown"
		data["user"]["job"] = "N/A"
		data["user"]["department"] = "N/A"

	data["photo_data"] = !isnull(current_image)
	data["creating_channel"] = creating_channel
	data["editing_channel"] = editing_channel
	data["creating_comment"] = creating_comment
	data["viewing_wanted"] = viewing_wanted
	data["editing_wanted"] = editing_wanted

	//Here is all the UI_data sent about the current wanted issue, as well as making a new one in the UI.
	data["making_wanted_issue"] = !(GLOB.news_network.wanted_issue?.active)
	data["criminal_name"] = criminal_name
	data["crime_description"] = crime_description
	var/list/wanted_info = list()
	if(GLOB.news_network.wanted_issue)
		if(GLOB.news_network.wanted_issue.img)
			user << browse_rsc(GLOB.news_network.wanted_issue.img, "wanted_photo.png")
		wanted_info = list(list(
			"active" = GLOB.news_network.wanted_issue.active,
			"criminal" = GLOB.news_network.wanted_issue.criminal,
			"crime" = GLOB.news_network.wanted_issue.body,
			"author" = GLOB.news_network.wanted_issue.scanned_user,
			"image" = "wanted_photo.png",
			"has_image" = GLOB.news_network.wanted_issue.has_image,
		))

	//Code breaking down the channels that have been made on-station thus far. ha
	//Then, breaks down the messages that have been made on those channels.
	if(current_channel)
		for(var/datum/feed_message/feed_message as anything in current_channel.messages)
			var/photo_ID = null
			var/list/comment_list
			if(feed_message.img)
				photo_ID = "tmp_newscaster_[current_channel.channel_ID]_[feed_message.message_ID].png"
				user << browse_rsc(feed_message.img, photo_ID)
			for(var/datum/feed_comment/comment_message as anything in feed_message.comments)
				comment_list += list(list(
					"auth" = comment_message.author,
					"body" = comment_message.body,
					"time" = comment_message.time_stamp,
				))
			var/auth_m = feed_message.return_author()
			message_list += list(list(
				"auth" = auth_m,
				"body" = feed_message.body,
				"time" = feed_message.time_stamp,
				"channel_num" = feed_message.parent_ID,
				"censored_message" = feed_message.body_censor,
				"censored_author" = feed_message.author_censor,
				"ID" = feed_message.message_ID,
				"photo" = photo_ID,
				"photo_caption" = feed_message.caption,
				"comments" = comment_list
			))


	data["viewing_channel"] = current_channel?.channel_ID
	data["paper"] = paper_remaining
	//Here we display all the information about the current channel.
	data["channelName"] = current_channel?.channel_name
	data["channelAuthor"] = current_channel?.author

	if(!current_channel)
		data["channelAuthor"] = "Nanotrasen Inc"
		data["channelDesc"] = "Welcome to Newscaster Net. Interface & News networks Operational."
		data["channelLocked"] = TRUE
	else
		data["channelDesc"] = current_channel.channel_desc
		data["channelLocked"] = current_channel.locked
		data["channelCensored"] = current_channel.censored

	data["editor"] = list()
	data["editor"]["channelName"] = channel_name
	data["editor"]["channelDesc"] = channel_desc
	data["editor"]["channelLocked"] = channel_locked

	//We send all the information about all messages in existence.
	data["messages"] = message_list
	data["wanted"] = wanted_info

	var/list/formatted_requests = list()
	var/list/formatted_applicants = list()
	for (var/datum/station_request/request as anything in GLOB.request_list)
		formatted_requests += list(list("owner" = request.owner, "value" = request.value, "description" = request.description, "acc_number" = request.req_number))
		if(request.applicants)
			for(var/datum/bank_account/applicant_bank_account as anything in request.applicants)
				formatted_applicants += list(list("name" = applicant_bank_account.account_holder, "request_id" = request.owner_account.account_id, "requestee_id" = applicant_bank_account.account_id))
	data["requests"] = formatted_requests
	data["applicants"] = formatted_applicants
	data["bountyValue"] = bounty_value
	data["bountyText"] = bounty_text

	var/list/channel_list = list()
	for(var/datum/feed_channel/channel as anything in GLOB.news_network.network_channels)
		channel_list += list(list(
			"name" = channel.channel_name,
			"author" = channel.author,
			"censored" = channel.censored,
			"locked" = channel.locked,
			"ID" = channel.channel_ID,
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
			if(iterated_station_request.req_number == current_ref_num)
				active_request = iterated_station_request
				break
	if(active_request)
		for(var/datum/bank_account/iterated_bank_account as anything in active_request.applicants)
			if(iterated_bank_account.account_id == current_app_num)
				request_target = iterated_bank_account
				break
	var/silicon = issilicon(usr)
	switch(action)
		if("setChannel")
			var/prototype_channel = params["channel"]
			if(isnull(prototype_channel))
				return TRUE
			for(var/datum/feed_channel/potential_channel as anything in GLOB.news_network.network_channels)
				if(prototype_channel == potential_channel.channel_ID)
					current_channel = potential_channel

		if("createStory")
			if(!current_channel)
				balloon_alert(usr, "select a channel first!")
				return TRUE
			var/prototype_channel = params["current"]
			create_story(channel_name = prototype_channel)

		if("togglePhoto")
			toggle_photo()
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
			return TRUE

		if("storyCensor")
			if(ispAI(usr))
				return TRUE
			if(!silicon)
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
			if(!silicon)
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
			if(!silicon)
				var/obj/item/card/id/id_card
				if(isliving(usr))
					var/mob/living/living_user = usr
					id_card = living_user.get_idcard(hand_first = TRUE)
				if(!(ACCESS_ARMORY in id_card?.GetAccess()))
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
			if(!get_registered_account(usr) && !silicon)
				say("ERROR: Cannote locate linked account ID.")
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
			update_overlays()
			return TRUE

		if("editWanted")
			alert = FALSE
			viewing_wanted = TRUE
			editing_wanted = TRUE
			update_overlays()
			return TRUE

		if("setCriminalName")
			var/temp_name = stripped_input(usr, "Write the Criminal's Name", "Warrent Alert Handler", "John Doe", MAX_NAME_LEN)
			if(!temp_name)
				return TRUE
			criminal_name = temp_name
			return TRUE

		if("setCrimeData")
			var/temp_desc = stripped_multiline_input(usr, "Write the Criminal's Crimes", "Warrent Alert Handler", "Unknown", MAX_BROADCAST_LEN)
			if(!temp_desc)
				return TRUE
			crime_description = temp_desc
			return TRUE

		if("submitWantedIssue")
			if(ispAI(usr))
				return TRUE
			if(!crime_description || !criminal_name)
				say("ERROR: Missing crime details.")
				return TRUE
			var/datum/bank_account/account = get_registered_account(usr)
			if(!istype(account) && !silicon)
				say("ERROR: Cannot locate linked account ID.")
				return TRUE
			if(!silicon)
				var/obj/item/card/id/id_card
				if(isliving(usr))
					var/mob/living/living_user = usr
					id_card = living_user.get_idcard(hand_first = TRUE)
				if(!(ACCESS_ARMORY in id_card?.GetAccess()))
					say("ERROR: Unauthorized request.")
					return TRUE
			GLOB.news_network.submit_wanted(criminal_name, crime_description, silicon ? usr.name : account.account_holder, current_image, adminMsg = FALSE, newMessage = TRUE, has_image = wanted_image)
			current_image = null
			viewing_wanted = FALSE
			editing_wanted = FALSE
			criminal_name = null
			crime_description = null
			wanted_image = FALSE
			return TRUE

		if("clearWantedIssue")
			if(ispAI(usr))
				return TRUE
			if(!silicon)
				var/obj/item/card/id/id_card
				if(isliving(usr))
					var/mob/living/living_user = usr
					id_card = living_user.get_idcard(hand_first = TRUE)
				if(!(ACCESS_ARMORY in id_card?.GetAccess()))
					say("ERROR: Unauthorized request.")
					return TRUE
			clear_wanted_issue(user = usr)
			for(var/obj/machinery/newscaster/other_newscaster in GLOB.allCasters)
				other_newscaster.update_icon()
				return TRUE

		if("printNewspaper")
			print_paper()
			return TRUE

		if("createBounty")
			create_bounty()
			return TRUE

		if("apply")
			apply_to_bounty()
			return TRUE

		if("payApplicant")
			pay_applicant(payment_target = request_target)
			return TRUE

		if("deleteRequest")
			delete_bounty_request()
			return TRUE

		if("bountyVal")
			bounty_value = text2num(params["bountyval"])
			if(!bounty_value)
				bounty_value = 1

		if("bountyText")
			var/pre_bounty_text = params["bountytext"]
			if(!pre_bounty_text)
				return
			bounty_text = pre_bounty_text
	return TRUE


/obj/machinery/newscaster/attackby(obj/item/I, mob/living/user, params)
	if(I.tool_behaviour == TOOL_WRENCH)
		to_chat(user, "<span class='notice'>You start [anchored ? "un" : ""]securing [name]...</span>")
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 60))
			playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
			if(machine_stat & BROKEN)
				to_chat(user, "<span class='warning'>The broken remains of [src] fall on the ground.</span>")
				new /obj/item/stack/sheet/iron(loc, 5)
				new /obj/item/shard(loc)
				new /obj/item/shard(loc)
			else
				to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secure [name].</span>")
				new /obj/item/wallframe/newscaster(loc)
			qdel(src)
	else if(I.tool_behaviour == TOOL_WELDER && user.a_intent != INTENT_HARM)
		if(machine_stat & BROKEN)
			if(!I.tool_start_check(user, amount=0))
				return
			user.visible_message("<span class='notice'>[user] is repairing [src].</span>", \
							"<span class='notice'>You begin repairing [src]...</span>", \
							"<span class='hear'>You hear welding.</span>")
			if(I.use_tool(src, user, 40, volume=50))
				if(!(machine_stat & BROKEN))
					return
				to_chat(user, "<span class='notice'>You repair [src].</span>")
				obj_integrity = max_integrity
				set_machine_stat(machine_stat & ~BROKEN)
				update_icon()
		else
			to_chat(user, "<span class='notice'>[src] does not need repairs.</span>")

	else if(istype(I, /obj/item/paper))
		if(!user.temporarilyRemoveItemFromInventory(I))
			return
		else
			paper_remaining ++
			to_chat(user, "<span class='notice'>You insert the [I] into \the [src]! It now holds [paper_remaining] sheets of paper.</span>")
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

/obj/machinery/newscaster/obj_break(damage_flag)
	. = ..()
	if(.)
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, TRUE)


/obj/machinery/newscaster/attack_paw(mob/living/user, list/modifiers)
	if(user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='warning'>The newscaster controls are far too complicated for your tiny brain!</span>")
	else
		take_damage(5, BRUTE, MELEE)

/obj/machinery/newscaster/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	update_icon()

/**
 * Sends photo data to build the newscaster article.
 */
/obj/machinery/newscaster/proc/send_photo_data()
	if(!current_image)
		return null
	return current_image

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
	if(current_channel.locked && current_channel.author != usr_name)
		say("ERROR: Unauthorized request.")
		return TRUE
	var/temp_message = stripped_multiline_input(usr, "Write your Feed story", "Network Channel Handler", feed_channel_message)
	if(length(temp_message) <= 1)
		return TRUE
	if(temp_message)
		feed_channel_message = temp_message
	GLOB.news_network.submit_article("<font face=\"[PEN_FONT]\">[parsemarkdown(feed_channel_message, usr)]</font>", usr_name, current_channel.channel_name, send_photo_data(), adminMessage = FALSE, allow_comments = TRUE, author_job = issilicon(usr) ? usr.job : account.account_job.title, author_account = account)
	SSblackbox.record_feedback("amount", "newscaster_stories", 1)
	feed_channel_message = ""
	current_image = null

/**
 * Selects a currently held photo from the user's hand and makes it the current_image held by the newscaster.
 * If a photo is still held in the newscaster, it will otherwise clear it from the machine.
 */
/obj/machinery/newscaster/proc/toggle_photo()
	if(current_image)
		balloon_alert(usr, "current photo cleared.")
		current_image = null
		if(editing_wanted)
			wanted_image = FALSE
		return TRUE
	else
		attach_photo(usr)
		if(editing_wanted)
			wanted_image = !!current_image
		if(current_image)
			balloon_alert(usr, "photo selected.")
			playsound(src, 'sound/machines/terminal_success.ogg', 15, TRUE)
		else
			balloon_alert(usr, "no photo identified.")

/obj/machinery/newscaster/proc/clear_wanted_issue(user)
	if(ispAI(usr))
		return FALSE
	if(!issilicon(usr))
		var/obj/item/card/id/id_card
		if(isliving(usr))
			var/mob/living/living_user = usr
			id_card = living_user.get_idcard(hand_first = TRUE)
		if(!(ACCESS_ARMORY in id_card?.GetAccess()))
			say("Clearance not found.")
			return TRUE
	GLOB.news_network.wanted_issue.active = FALSE
	wanted_image = FALSE
	current_image = null
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
	say("Deleted current request.")
	GLOB.request_list.Remove(active_request)

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
	if(!bounty_text)
		say("ERROR: No bounty text.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	for(var/datum/station_request/iterated_station_request as anything in GLOB.request_list)
		if(iterated_station_request.req_number == account.account_id)
			say("ERROR: Account already has active bounty.")
			return TRUE
	var/datum/station_request/curr_request = new /datum/station_request(account.account_holder, bounty_value,bounty_text, account.account_id, account)
	GLOB.request_list += list(curr_request)
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
	if(account.account_holder == active_request.owner)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	if(account in active_request.applicants)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	active_request.applicants += list(account)

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
	GLOB.request_list.Remove(active_request)
	qdel(active_request)

/obj/item/wallframe/newscaster
	name = "newscaster frame"
	desc = "Used to build newscasters, just secure to the wall."
	icon_state = "newscaster"
	custom_materials = list(/datum/material/iron=14000, /datum/material/glass=8000)
	result_path = /obj/machinery/newscaster
	pixel_shift = -32

#undef ALERT_DELAY
