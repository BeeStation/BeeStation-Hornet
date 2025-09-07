// LOOC ported from Citadel, styling in stylesheet.dm and browseroutput.css

GLOBAL_VAR_INIT(looc_allowed, TRUE)

AUTH_CLIENT_VERB(private_ooc)
	set name = "Private OOC"
	set desc = "Private OOC, can only be seen by the target which must be in view of the user."
	set category = "OOC"

	if(GLOB.say_disabled)    //This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return

	if(!mob?.ckey)
		return

	// Search everything in the view for anything that might be a mob, or contain a mob.
	var/list/mob/message_targets = list()
	for(var/mob/living/target_mob in view(get_turf(mob)))
		if (!target_mob.client)
			continue
		message_targets += target_mob



	var/mob/living/target = tgui_input_list(
		usr,
		"Who would you like to contact?.",
		"Send out-of-character message",
		message_targets,
		null,
		30 SECONDS
	)

	if (!target)
		to_chat(usr, span_danger("You decided not to send an OOC communication!"))
		return

	var/msg = tgui_input_text(usr, "What would you like to tell them? Please avoid discouraging players from playstyles that you dislike, work around it!", "LOOC Message", "", MAX_MESSAGE_LEN, FALSE, TRUE, 30 SECONDS)

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

	if (!target.client)
		return

	var/list/targets = list()

	to_chat(usr, span_looc("[span_prefix("LOOC:")] <EM>[span_name("[mob.name]")]:</EM> [span_message(msg)]"), avoid_highlighting = TRUE)
	if (usr != target)
		to_chat(target, span_looc("[span_prefix("LOOC:")] <EM>[span_name("[mob.name]")]:</EM> [span_message(msg)]"), avoid_highlighting = FALSE)

	if(target.client.prefs.read_player_preference(/datum/preference/toggle/enable_runechat_looc))
		targets |= target
	if(usr.client.prefs.read_player_preference(/datum/preference/toggle/enable_runechat_looc))
		targets |= usr

	// Send to admins
	for(var/client/admin in GLOB.admins)
		if(!admin.prefs.read_player_preference(/datum/preference/toggle/chat_ooc))
			continue

		if (admin == usr.client || admin == target.client)
			continue

		targets |= admin.mob
		to_chat(admin, span_looc("[span_prefix("LOOC:")] <EM>[ADMIN_LOOKUPFLW(mob)]:</EM> [span_message(msg)]"), avoid_highlighting = (admin == src))

	// Create runechat message
	if(length(targets))
		create_chat_message(mob, /datum/language/metalanguage, targets, "\[LOOC: [raw_msg]\]", spans = list("looc"))

/proc/log_looc(text)
	if (CONFIG_GET(flag/log_ooc))
		WRITE_FILE(GLOB.world_game_log, "\[[time_stamp()]]LOOC: [text]")
