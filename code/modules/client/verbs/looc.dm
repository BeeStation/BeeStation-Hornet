// LOOC ported from Citadel, styling in stylesheet.dm and browseroutput.css

GLOBAL_VAR_INIT(looc_allowed, TRUE)

GLOBAL_LIST_EMPTY(sent_looc_messages)

AUTH_CLIENT_VERB(looc, msg as text)
	set name = "LOOC"
	set desc = "Local OOC, seen only by those in view."
	set category = "OOC"

	// Thumbs emojis
	var/datum/asset/spritesheet_batched/sheet = get_asset_datum(/datum/asset/spritesheet_batched/chat)
	var/thumbs_up = sheet.icon_tag("emoji-up")
	var/thumbs_down = sheet.icon_tag("emoji-down")

	if(GLOB.say_disabled)    //This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return

	if(!mob?.ckey)
		return

	msg = trim(sanitize(msg), MAX_MESSAGE_LEN)
	if(!length(msg))
		return

	var/raw_msg = msg

	if(!prefs.read_player_preference(/datum/preference/toggle/chat_ooc))
		to_chat(src, span_danger("You have OOC (and therefore LOOC) muted."))
		return

	if(is_banned_from(mob.ckey, BAN_OOC))
		to_chat(src, span_danger("You have been banned from OOC and LOOC."))
		return

	var/failed = FALSE

	if(!holder)
		failed = TRUE
		if(!CONFIG_GET(flag/looc_enabled))
			to_chat(src, span_danger("LOOC is disabled."))
		else if(player_details.muted & MUTE_OOC)
			to_chat(src, span_danger("You cannot use LOOC (muted)."))
		else if(handle_spam_prevention(msg, MUTE_OOC))
			failed = TRUE
		else if(findtext(msg, "byond://"))
			to_chat(src, span_bolddanger("Advertising other servers is not allowed."))
			log_admin("[key_name(src)] has attempted to advertise in LOOC: [msg]")
		else if(mob.stat)
			to_chat(src, span_danger("You cannot salt in LOOC while unconscious or dead."))
		else if(isdead(mob))
			to_chat(src, span_danger("You cannot use LOOC while ghosting."))
		else if(OOC_FILTER_CHECK(raw_msg))
			to_chat(src, span_warning("That message contained a word prohibited in OOC chat! Consider reviewing the server rules.\n") + "<span replaceRegex='show_filtered_ooc_chat'>\"[raw_msg]\"</span>")
		else
			failed = FALSE

	if (failed)
		mob.log_talk(raw_msg, LOG_OOC, tag="LOOC (Failed)")
		return

	msg = emoji_parse(msg)

	mob.log_talk(raw_msg, LOG_OOC, tag="LOOC")

	// Search everything in the view for anything that might be a mob, or contain a mob.
	var/list/mob/targets = list()
	var/list/hearers = list()
	var/list/turf/in_view = list()
	for(var/turf/viewed_turf in view(get_turf(mob)))
		in_view[viewed_turf] = TRUE

	// Hearers is a reference so is updated below
	var/datum/looc_message/message_datum = new /datum/looc_message(mob.name, player_details, hearers)

	// Send to people in range
	for(var/client/client in GLOB.clients)
		if(!client.mob || !client.prefs.read_player_preference(/datum/preference/toggle/chat_ooc) || (client in GLOB.admins))
			continue

		// Ghosts are not allowed to use this
		if (isdead(client.mob))
			continue

		// Must be conscious to hear LOOC
		if (client.mob.stat != CONSCIOUS)
			continue

		if(in_view[get_turf(client.mob)])
			if(client.prefs.read_player_preference(/datum/preference/toggle/enable_runechat_looc))
				targets |= client.mob
			var/commendations = ""
			if (client != src)
				commendations += "<span style='float: right'>"
				commendations += span_emojibutton("<a href='byond://?src=[REF(message_datum)];looc_commend=1'>[thumbs_up]</a>")
				if (!client.player_details.has_criticized && !holder)
					commendations += " "
					commendations += span_emojibutton("<a href='byond://?src=[REF(message_datum)];looc_critic=1'>[thumbs_down]</a>")
				commendations += "</span>"
				hearers |= client.ckey
			var/rendered_message = span_looc("[span_prefix("LOOC:")] <EM>[span_name("[mob.name]")]:</EM> [span_message(msg)] [commendations]")
			to_chat(client, rendered_message, avoid_highlighting = (client == src))

	// Send to admins
	for(var/client/admin in GLOB.admins)
		if(!admin.prefs.read_player_preference(/datum/preference/toggle/chat_ooc))
			continue

		if(in_view[get_turf(admin.mob)] && admin.prefs.read_player_preference(/datum/preference/toggle/enable_runechat_looc))
			targets |= admin.mob
			to_chat(admin, span_looc("[span_prefix("LOOC (NEARBY):")] <EM>[ADMIN_LOOKUPFLW(mob)]:</EM> [span_message(msg)]"), avoid_highlighting = (admin == src))
		else
			to_chat(admin, span_looc("[span_prefix("LOOC:")] <EM>[ADMIN_LOOKUPFLW(mob)]:</EM> [span_message(msg)]"), avoid_highlighting = (admin == src))

	// Create runechat message
	if(length(targets))
		create_chat_message(mob, /datum/language/metalanguage, targets, "\[LOOC: [raw_msg]\]", spans = list("looc"))

	// Timeout the LOOC message, so you can't commend over a long period of time
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(timeout_looc_message), message_datum), 2 MINUTES)

/proc/timeout_looc_message(datum/looc_message/message)
	message.expired = TRUE
	message.expire()

/datum/looc_message
	var/uuid
	var/mob_name
	var/datum/player_details/sender
	var/list/hearers
	var/list/commenders = null
	var/expired = FALSE
	var/timer_active = FALSE

/datum/looc_message/New(mob_name, sender, hearers)
	. = ..()
	src.mob_name = mob_name
	src.sender = sender
	src.hearers = hearers
	// Not secure, but we secure them anyway so it doesn't matter
	uuid = GUID()
	GLOB.sent_looc_messages[uuid] = src

/datum/looc_message/Destroy(force, ...)
	. = ..()
	GLOB.sent_looc_messages -= uuid

/datum/looc_message/Topic(href, list/href_list)
	if (QDELETED(src) || expired)
		return
	. = ..()
	if (href_list["looc_commend"])
		try_commend(usr.client)
	else if (href_list["looc_critic"])
		try_criticise(usr.client)

/datum/looc_message/proc/try_commend(client/listener)
	if (listener.player_details.muted & MUTE_OOC)
		return
	if (!(listener.ckey in hearers))
		return
	if (LAZYFIND(commenders, listener.ckey))
		to_chat(listener, span_good("You have already rated this message, thank you for creating a positive atmosphere!"))
		return
	var/client/sender_client = sender.find_client()
	if (sender_client)
		if (sender.commendations_received > 10)
			to_chat(listener, span_good("You sent a commendation to [mob_name], thank you for creating a positive atmosphere!"))
			to_chat(sender_client, span_good("You received a commendation for being helpful, but have been so helpful that you already hit the limit! Thank you for creating a positive atmosphere!"))
		else
			if (CONFIG_GET(flag/grant_metacurrency))
				listener.inc_metabalance(1, TRUE, reason = "You sent a commendation to [mob_name], thank you for creating a positive atmosphere!")
				sender_client.inc_metabalance(1, TRUE, reason = "You have received a commendation for helpful messages, thank you for creating a positive atmosphere!")
			else
				to_chat(listener, span_good("You sent a commendation to [mob_name], thank you for creating a positive atmosphere!"))
				to_chat(sender_client, span_good("You have received a commendation for helpful messages, thank you for creating a positive atmosphere!"))
	LAZYADD(commenders, listener.ckey)
	// Maximum of 20 commendations, which protects you from 3 criticisms, to discourage building
	// a clique and talking in LOOC for commendations
	if (sender.commendations_received < 20)
		sender.commendations_received ++

/datum/looc_message/proc/try_criticise(client/listener)
	if (listener.player_details.muted & MUTE_OOC)
		return
	if (tgui_alert(listener, "Are you sure you want to criticise this message?", "Downvote message", list("Criticize", "Abort")) == "Abort")
		return
	if (!(listener.ckey in hearers))
		return
	if (listener.player_details.has_criticized)
		to_chat(listener, span_warning("You may only use the criticize function once per round."))
		return
	if (LAZYFIND(commenders, listener.ckey))
		to_chat(listener, span_good("You have already rated this message, thank you for maintaining mutual respect even when the game gets tough."))
		return
	to_chat(listener, span_good("You criticised a message from [mob_name], thank you for maintaining mutual respect even when the game gets tough."))
	LAZYADD(commenders, listener.ckey)
	var/client/sender_client = sender.find_client()
	listener.player_details.has_criticized = TRUE
	// Do nothing instead
	if (sender_client && sender_client.holder)
		return
	sender.criticisms_received ++
	// Will hold a reference until complete, at which point the datum will be deleted
	if (!timer_active)
		addtimer(CALLBACK(src, PROC_REF(issue_warning)), rand(2 MINUTES, 5 MINUTES))
		timer_active = TRUE

/datum/looc_message/proc/issue_warning()
	timer_active = FALSE
	expire()
	var/delta = sender.commendations_received - (sender.criticisms_received * 5)
	var/client/sender_client = sender.find_client()
	if (sender.muted & MUTE_OOC)
		return
	if (delta < 0)
		if (sender_client)
			to_chat(sender_client, span_rosebold("You have temporarily lost access to OOC communications due to automated feedback. Do not panic; \
			you are not in trouble, this will automatically revert at the end of the round, and is not logged against you!"))
		sender.muted |= MUTE_OOC
		log_admin("AUTOMUTE: [sender.ckey] from LOOC")

/datum/looc_message/proc/expire()
	if (!expired)
		return
	if (timer_active)
		return
	qdel(src)

/proc/log_looc(text)
	if (CONFIG_GET(flag/log_ooc))
		WRITE_FILE(GLOB.world_game_log, "\[[time_stamp()]]LOOC: [text]")
