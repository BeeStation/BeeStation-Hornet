// LOOC ported from Citadel, styling in stylesheet.dm and browseroutput.css

GLOBAL_VAR_INIT(looc_allowed, TRUE)

AUTH_CLIENT_VERB(looc, msg as text)
	set name = "LOOC"
	set desc = "Local OOC, seen only by those in view."
	set category = "OOC"

	if(GLOB.say_disabled)    //This is here to try to identify lag problems
		to_chat(usr, span_danger(" Speech is currently admin-disabled."))
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

	if(!holder)
		if(!CONFIG_GET(flag/looc_enabled))
			to_chat(src, span_danger("LOOC is disabled."))
			return
		if(!GLOB.dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, span_danger("LOOC for dead mobs has been turned off."))
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, span_danger("You cannot use LOOC (muted)."))
			return
		if(handle_spam_prevention(msg, MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, span_bolddanger("Advertising other servers is not allowed."))
			log_admin("[key_name(src)] has attempted to advertise in LOOC: [msg]")
			return
		if(mob.stat)
			to_chat(src, span_danger("You cannot salt in LOOC while unconscious or dead."))
			return
		if(isdead(mob))
			to_chat(src, span_danger("You cannot use LOOC while ghosting."))
			return
		if(OOC_FILTER_CHECK(raw_msg))
			to_chat(src, span_warning("That message contained a word prohibited in OOC chat! Consider reviewing the server rules.\n") + "<span replaceRegex='show_filtered_ooc_chat'>\"[raw_msg]\"</span>")
			return

	msg = emoji_parse(msg)

	mob.log_talk(raw_msg, LOG_OOC, tag="LOOC")

	// Search everything in the view for anything that might be a mob, or contain a mob.
	var/list/mob/targets = list()
	var/list/turf/in_view = list()
	for(var/turf/viewed_turf in view(get_turf(mob)))
		in_view[viewed_turf] = TRUE

	// Send to people in range
	for(var/client/client in GLOB.clients)
		if(!client.mob || !client.prefs.read_player_preference(/datum/preference/toggle/chat_ooc) || (client in GLOB.admins))
			continue

		if(in_view[get_turf(client.mob)])
			if(client.prefs.read_player_preference(/datum/preference/toggle/enable_runechat_looc))
				targets |= client.mob
			to_chat(client, span_looc("[span_prefix("LOOC:")] <EM>[span_name("[mob.name]")]:</EM> [span_message(msg)]"), avoid_highlighting = (client == src))

	// Send to admins
	for(var/client/admin in GLOB.admins)
		if(!admin.prefs.read_player_preference(/datum/preference/toggle/chat_ooc))
			continue

		if(in_view[get_turf(admin.mob)] && admin.prefs.read_player_preference(/datum/preference/toggle/enable_runechat_looc))
			targets |= admin.mob
		to_chat(admin, span_looc("[span_prefix("LOOC:")] <EM>[ADMIN_LOOKUPFLW(mob)]:</EM> [span_message(msg)]"), avoid_highlighting = (admin == src))

	// Create runechat message
	if(length(targets))
		create_chat_message(mob, /datum/language/metalanguage, targets, "\[LOOC: [raw_msg]\]", spans = list("looc"))

/proc/log_looc(text)
	if (CONFIG_GET(flag/log_ooc))
		WRITE_FILE(GLOB.world_game_log, "\[[time_stamp()]]LOOC: [text]")
