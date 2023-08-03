// LOOC ported from Citadel, styling in stylesheet.dm and browseroutput.css

GLOBAL_VAR_INIT(looc_allowed, TRUE)

/client/verb/looc(msg as text)
	set name = "LOOC"
	set desc = "Local OOC, seen only by those in view."
	set category = "OOC"

	if(GLOB.say_disabled)    //This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'> Speech is currently admin-disabled.</span>")
		return

	if(!mob?.ckey)
		return

	msg = trim(sanitize(msg), MAX_MESSAGE_LEN)
	if(!length(msg))
		return

	var/raw_msg = msg

	if(!(prefs.toggles & CHAT_OOC))
		to_chat(src, "<span class='danger'>You have OOC (and therefore LOOC) muted.</span>")
		return

	if(is_banned_from(mob.ckey, BAN_OOC))
		to_chat(src, "<span class='danger'>You have been banned from OOC and LOOC.</span>")
		return

	if(!holder)
		if(!CONFIG_GET(flag/looc_enabled))
			to_chat(src, "<span class='danger'>LOOC is disabled.</span>")
			return
		if(!GLOB.dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='danger'>LOOC for dead mobs has been turned off.</span>")
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, "<span class='danger'>You cannot use LOOC (muted).</span>")
			return
		if(handle_spam_prevention(msg, MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<span class='bold danger'>Advertising other servers is not allowed.</span>")
			log_admin("[key_name(src)] has attempted to advertise in LOOC: [msg]")
			return
		if(mob.stat)
			to_chat(src, "<span class='danger'>You cannot salt in LOOC while unconscious or dead.</span>")
			return
		if(isdead(mob))
			to_chat(src, "<span class='danger'>You cannot use LOOC while ghosting.</span>")
			return
		if(OOC_FILTER_CHECK(raw_msg))
			to_chat(src, "<span class='warning'>That message contained a word prohibited in OOC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ooc_chat'>\"[raw_msg]\"</span></span>")
			return

	msg = emoji_parse(msg)

	mob.log_talk(raw_msg, LOG_OOC, tag="LOOC")

	// Search everything in the view for anything that might be a mob, or contain a mob.
	var/list/client/targets = list()
	var/list/turf/in_view = list()
	for(var/turf/viewed_turf in view(get_turf(mob)))
		in_view[viewed_turf] = TRUE
	for(var/client/client in GLOB.clients)
		if(!client.mob || !(client.prefs.toggles & CHAT_OOC) || (client in GLOB.admins))
			continue
		if(in_view[get_turf(client.mob)])
			targets |= client
			to_chat(client, "<span class='looc'><span class='prefix'>LOOC:</span> <EM><span class='name'>[mob.name]</span>:</EM> <span class='message'>[msg]</span></span>", avoid_highlighting = (client == src))

	for(var/client/client in GLOB.admins)
		if(!(client.prefs.toggles & CHAT_OOC))
			continue
		var/prefix = "[(client in targets) ? "" : "(R)"]LOOC"
		to_chat(client, "<span class='looc'><span class='prefix'>[prefix]:</span> <EM>[ADMIN_LOOKUPFLW(mob)]:</EM> <span class='message'>[msg]</span></span>", avoid_highlighting = (client == src))

/proc/log_looc(text)
	if (CONFIG_GET(flag/log_ooc))
		WRITE_FILE(GLOB.world_game_log, "\[[time_stamp()]]LOOC: [text]")
