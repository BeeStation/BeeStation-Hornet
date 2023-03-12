/datum/admins/proc/access_news_network() //MARKER
	set category = "Round"
	set name = "Access Newscaster Network"
	set desc = "Allows you to view, add and edit news feeds."

	if (!istype(src, /datum/admins))
		src = usr.client.holder
	if (!istype(src, /datum/admins))
		return

	var/datum/newspanel/new_newspanel = new
	new_newspanel.ui_interact(usr)

/datum/newspanel
	///What newscaster channel is currently being viewed by the player?
	var/datum/feed_channel/current_channel
	///What newscaster feed_message is currently having a comment written for it?
	var/datum/feed_message/current_message
	///The message that's currently being written for a feed story.
	var/feed_channel_message
	///The current image that will be submitted with the newscaster story.
	var/datum/picture/current_image
	///Is the current user creating a new channel at the moment?
	var/creating_channel = FALSE
	///Is the current user editing the current channel at the moment?
	var/editing_channel = FALSE
	///Is the current user creating a new comment at the moment?
	var/creating_comment = FALSE
	///Is the current user editing or viewing a new wanted issue at the moment?
	var/viewing_wanted  = FALSE
	///Is the current user editing the wanted issue at the moment?
	var/editing_wanted = FALSE
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

/datum/newspanel/ui_state(mob/user)
	return GLOB.admin_state

/datum/newspanel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PhysicalNewscaster")
		ui.open()

/datum/newspanel/ui_data(mob/user)
	. = list()
	var/list/data = list()
	var/list/channel_list = list()
	var/list/message_list = list()

	data["user"] = list()
	data["user"]["authenticated"] = TRUE
	data["user"]["admin"] = TRUE
	data["user"]["name"] = "Centcom Official"
	data["user"]["job"] = "Official"
	data["user"]["department"] = "Department of News"

	data["security_mode"] = TRUE
	data["photo_data"] = !isnull(current_image)
	data["creating_channel"] = creating_channel
	data["editing_channel"] = editing_channel
	data["creating_comment"] = creating_comment

	//Here is all the UI_data sent about the current wanted issue, as well as making a new one in the UI.
	data["viewing_wanted"] = viewing_wanted
	data["editing_wanted"] = editing_wanted
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
			"image" = "wanted_photo.png"
		))

	//Code breaking down the channels that have been made on-station thus far. ha
	//Then, breaks down the messages that have been made on those channels.
	for(var/datum/feed_channel/channel as anything in GLOB.news_network.network_channels)
		channel_list += list(list(
			"name" = channel.channel_name,
			"author" = channel.author,
			"censored" = channel.censored,
			"locked" = channel.locked,
			"ID" = channel.channel_ID,
		))
	if(current_channel)
		for(var/datum/feed_message/feed_message as anything in current_channel.messages)
			var/photo_ID = null
			var/list/comment_list
			if(feed_message.img)
				user << browse_rsc(feed_message.img, "tmp_photo[feed_message.message_ID].png")
				photo_ID = "tmp_photo[feed_message.message_ID].png"
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

	//We send all the information about all channels and all messages in existence.
	data["channels"] = channel_list
	data["messages"] = message_list
	data["wanted"] = wanted_info
	return data

/datum/newspanel/ui_act(action, params)
	. = ..()
	if(.)
		return

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
				to_chat(usr, "select a channel first!")
				return TRUE
			var/prototype_channel = params["current"]
			create_story(channel_name = prototype_channel)

		if("togglePhoto")
			toggle_photo()
			return TRUE

		if("startCreateChannel")
			start_creating_channel()
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
			var/locked = params["lockedmode"]
			if(creating_channel)
				create_channel(locked)
			else if(editing_channel)
				edit_channel(locked)
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
			var/questionable_message = params["messageID"]
			for(var/datum/feed_message/iterated_feed_message as anything in current_channel.messages)
				if(iterated_feed_message.message_ID == questionable_message)
					iterated_feed_message.toggle_censor_body()
					break

		if("author_censor")
			var/questionable_message = params["messageID"]
			for(var/datum/feed_message/iterated_feed_message in current_channel.messages)
				if(iterated_feed_message.message_ID == questionable_message)
					iterated_feed_message.toggle_censor_author()
					break

		if("channelDNotice")
			var/prototype_channel = (params["channel"])
			for(var/datum/feed_channel/potential_channel in GLOB.news_network.network_channels)
				if(prototype_channel == potential_channel.channel_ID)
					current_channel = potential_channel
					break
			current_channel.toggle_censor_D_class()
			// Channel censor is part of static data
			update_static_data(usr)
			return TRUE

		if("startComment")
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
			viewing_wanted = TRUE
			editing_wanted = FALSE
			return TRUE

		if("editWanted")
			viewing_wanted = TRUE
			editing_wanted = TRUE
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
			if(!crime_description || !criminal_name)
				return TRUE
			GLOB.news_network.submit_wanted(criminal_name, crime_description, "Centcom Official", current_image, adminMsg = TRUE, newMessage = TRUE, has_image = wanted_image)
			current_image = null
			viewing_wanted = FALSE
			editing_wanted = FALSE
			criminal_name = null
			crime_description = null
			wanted_image = FALSE
			return TRUE

		if("clearWantedIssue")
			clear_wanted_issue(user = usr)
			return TRUE

	return TRUE

/datum/newspanel/proc/stop_editing_channel()
	editing_channel = FALSE
	channel_name = null
	channel_desc = null
	channel_locked = null

/datum/newspanel/proc/stop_creating_channel()
	creating_channel = FALSE
	channel_name = null
	channel_desc = null
	channel_locked = null

/**
 * Sends photo data to build the newscaster article.
 */
/datum/newspanel/proc/send_photo_data()
	if(!current_image)
		return null
	return current_image

/**
 * This takes a held photograph, and updates the current_image variable with that of the held photograph's image.
 * *user: The mob who is being checked for a held photo object.
 */
/datum/newspanel/proc/attach_photo(mob/user)
	to_chat(user, "I didn't add this!")
	return

/**
 * Performs a series of sanity checks before giving the user confirmation to create a new feed_channel using channel_name, and channel_desc.
 * *channel_locked: This variable determines if other users than the author can make comments and new feed_stories on this channel.
 */
/datum/newspanel/proc/create_channel()
	if(!channel_name)
		return
	for(var/datum/feed_channel/iterated_feed_channel as anything in GLOB.news_network.network_channels)
		if(iterated_feed_channel.channel_name == channel_name)
			alert(usr, "ERROR: Feed channel with that name already exists on the Network.", "Okay")
			return TRUE
	if(!channel_desc)
		return TRUE
	var/choice = alert(usr, "Please confirm feed channel creation","Network Channel Handler", "Confirm", "Cancel")
	if(choice == "Confirm")
		GLOB.news_network.create_feed_channel(channel_name, "Centcom Official", channel_desc, locked = channel_locked)
		SSblackbox.record_feedback("text", "newscaster_channels", 1, "[channel_name]")
	stop_creating_channel()
	update_static_data(usr)

/datum/newspanel/proc/edit_channel()
	if(!channel_name)
		return
	for(var/datum/feed_channel/iterated_feed_channel as anything in GLOB.news_network.network_channels)
		if(iterated_feed_channel != current_channel && iterated_feed_channel.channel_name == channel_name)
			alert(usr, "ERROR: Feed channel with that name already exists on the Network.", "Okay")
			return TRUE
	if(!channel_desc)
		return TRUE
	current_channel.channel_name = channel_name
	current_channel.channel_desc = channel_desc
	current_channel.locked = channel_locked
	stop_editing_channel()
	update_static_data(usr)

/**
 * Constructs a comment to attach to the currently selected feed_message of choice, assuming that a user can be found and that a message body has been written.
 */
/datum/newspanel/proc/create_comment()
	if(!comment_text)
		creating_comment = FALSE
		return TRUE
	var/datum/feed_comment/new_feed_comment = new /datum/feed_comment
	new_feed_comment.author = "Centcom Offical"
	new_feed_comment.body = comment_text
	new_feed_comment.time_stamp = station_time_timestamp()
	current_message.comments += new_feed_comment
	usr.log_message("(as an admin) commented on message [current_message.return_body(-1)] -- [current_message.body]", LOG_COMMENT)
	creating_comment = FALSE

/**
 * This proc performs checks before enabling the creating_channel var on the newscaster, such as preventing a user from having multiple channels,
 * preventing an un-ID'd user from making a channel, and preventing censored authors from making a channel.
 * Otherwise, sets creating_channel to TRUE.
 */
/datum/newspanel/proc/start_creating_channel()
	creating_channel = TRUE

/datum/newspanel/proc/start_edit_channel()
	// bad
	if(current_channel.channel_name == "Station Announcements")
		return TRUE
	channel_name = current_channel.channel_name
	channel_desc = current_channel.channel_desc
	channel_locked = current_channel.locked
	editing_channel = TRUE

/**
 * Creates a new feed story to the global newscaster network.
 * Verifies that the message is being written to a real feed_channel, then provides a text input for the feed story to be written into.
 * Finally, it submits the message to the network, is logged globally, and clears all message-specific variables from the machine.
 */
/datum/newspanel/proc/create_story(channel_name)
	for(var/datum/feed_channel/potential_channel as anything in GLOB.news_network.network_channels)
		if(channel_name == potential_channel.channel_ID)
			current_channel = potential_channel
			break
	var/temp_message = stripped_multiline_input(usr, "Write your Feed story", "Network Channel Handler", feed_channel_message)
	if(length(temp_message) <= 1)
		return TRUE
	if(temp_message)
		feed_channel_message = temp_message
	GLOB.news_network.submit_article("<font face=\"[PEN_FONT]\">[parsemarkdown(feed_channel_message, usr)]</font>", "Centcom Official", current_channel.channel_name, send_photo_data(), adminMessage = TRUE, allow_comments = TRUE, author_job = "Official")
	SSblackbox.record_feedback("amount", "newscaster_stories", 1)
	feed_channel_message = ""
	current_image = null

/**
 * Selects a currently held photo from the user's hand and makes it the current_image held by the newscaster.
 * If a photo is still held in the newscaster, it will otherwise clear it from the machine.
 */
/datum/newspanel/proc/toggle_photo()
	if(current_image)
		current_image = null
		return TRUE
	else
		attach_photo(usr)
		return TRUE

/datum/newspanel/proc/clear_wanted_issue(user)
	GLOB.news_network.wanted_issue.active = FALSE
	wanted_image = FALSE
	current_image = null
	return
