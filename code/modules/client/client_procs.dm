	////////////
	//SECURITY//
	////////////


#define UPLOAD_LIMIT		10485760	//Restricts client uploads to the server to 1MB //Could probably do with being lower.

GLOBAL_LIST_INIT(blacklisted_builds, list(
	"1407" = "bug preventing client display overrides from working leads to clients being able to see things/mobs they shouldn't be able to see",
	"1408" = "bug preventing client display overrides from working leads to clients being able to see things/mobs they shouldn't be able to see",
	"1428" = "bug causing right-click menus to show too many verbs that's been fixed in version 1429",
	))

#define LIMITER_SIZE	5
#define CURRENT_SECOND	1
#define SECOND_COUNT	2
#define CURRENT_MINUTE	3
#define MINUTE_COUNT	4
#define ADMINSWARNED_AT	5
	/*
	When somebody clicks a link in game, this Topic is called first.
	It does the stuff in this proc and  then is redirected to the Topic() proc for the src=[0xWhatever]
	(if specified in the link). ie locate(hsrc).Topic()

	Such links can be spoofed.

	Because of this certain things MUST be considered whenever adding a Topic() for something:
		- Can it be fed harmful values which could cause runtimes?
		- Is the Topic call an admin-only thing?
		- If so, does it have checks to see if the person who called it (usr.client) is an admin?
		- Are the processes being called by Topic() particularly laggy?
		- If so, is there any protection against somebody spam-clicking a link?
	If you have any  questions about this stuff feel free to ask. ~Carn

	the undocumented 4th argument is for ?[0x\ref] style topic links. hsrc is set to the reference and anything after the ] gets put into hsrc_command
	*/

/client/Topic(href, href_list, hsrc, hsrc_command)
	if(!usr || usr != mob)	//stops us calling Topic for somebody else's client. Also helps prevent usr=null
		return

#ifndef TESTING
	//disable the integrated byond vv in the client side debugging tools since it doesn't respect vv read protections
	if (LOWER_TEXT(hsrc_command) == "_debug")
		return
#endif

	// asset_cache
	var/asset_cache_job
	if(href_list["asset_cache_confirm_arrival"])
		asset_cache_job = asset_cache_confirm_arrival(href_list["asset_cache_confirm_arrival"])
		if (!asset_cache_job)
			return

	var/mtl = CONFIG_GET(number/minute_topic_limit)
	if (!holder && mtl)
		var/minute = round(world.time, 600)
		if (!topiclimiter)
			topiclimiter = new(LIMITER_SIZE)
		if (minute != topiclimiter[CURRENT_MINUTE])
			topiclimiter[CURRENT_MINUTE] = minute
			topiclimiter[MINUTE_COUNT] = 0
		topiclimiter[MINUTE_COUNT] += 1
		if (topiclimiter[MINUTE_COUNT] > mtl)
			var/msg = "Your previous action was ignored because you've done too many in a minute."
			if (minute != topiclimiter[ADMINSWARNED_AT]) //only one admin message per-minute. (if they spam the admins can just boot/ban them)
				topiclimiter[ADMINSWARNED_AT] = minute
				msg += " Administrators have been informed."
				log_game("[key_name(src)] Has hit the per-minute topic limit of [mtl] topic calls in a given game minute")
				message_admins("[ADMIN_LOOKUPFLW(src)] [ADMIN_KICK(usr)] Has hit the per-minute topic limit of [mtl] topic calls in a given game minute")
			to_chat(src, span_danger("[msg]"))
			return

	var/stl = CONFIG_GET(number/second_topic_limit)
	if (!holder && stl)
		var/second = round(world.time, 10)
		if (!topiclimiter)
			topiclimiter = new(LIMITER_SIZE)
		if (second != topiclimiter[CURRENT_SECOND])
			topiclimiter[CURRENT_SECOND] = second
			topiclimiter[SECOND_COUNT] = 0
		topiclimiter[SECOND_COUNT] += 1
		if (topiclimiter[SECOND_COUNT] > stl)
			to_chat(src, span_danger("Your previous action was ignored because you've done too many in a second"))
			return

	//Logs all hrefs, except chat pings and session tokens
	var/is_chat_ping = href_list["window_id"] == "browseroutput" && href_list["type"] == "ping" && LAZYLEN(href_list) == 4
	if(!is_chat_ping)
		var/logged_href = href
		if(href_list["session_token"])
			logged_href = replacetextEx(logged_href, href_list["session_token"], "TOKEN_REDACTED")
		log_href("[src] (usr:[usr]\[[COORD(usr)]\]) : [hsrc ? "[hsrc] " : ""][logged_href]")

	// Run this EARLY so it can't be hijacked by any other topics later on
	if(href_list["session_token"])
		var/token = href_list["session_token"]
		href_list["session_token"] = ""
		href = replacetextEx(href, href_list["session_token"], "")
		login_with_token(token, text2num(href_list["from_ui"]))
		return

	//byond bug ID:2256651
	if (asset_cache_job && (asset_cache_job in completed_asset_jobs))
		to_chat(src, span_danger("An error has been detected in how your client is receiving resources. Attempting to correct.... (If you keep seeing these messages you might want to close byond and reconnect)"))
		src << browse("...", "window=asset_cache_browser")
		return
	if (href_list["asset_cache_preload_data"])
		asset_cache_preload_data(href_list["asset_cache_preload_data"])
		return

	// Tgui Topic middleware
	if(tgui_Topic(href_list))
		return

	if(href_list["reload_tguipanel"])
		nuke_chat()

	// Admin PM
	if(href_list["priv_msg"])
		cmd_admin_pm(href_list["priv_msg"],null)
		return

	// Mentor PM
	if(href_list["mentor_msg"])
		cmd_mentor_pm(href_list["mentor_msg"], null)
		return TRUE

	// LOOC commendation


	if(href_list["commandbar_typing"])
		handle_commandbar_typing(href_list)

	if(href_list["seeker_port"])
		winshow(src, "login", FALSE) // make sure this thing is hidden
		var/port_num = text2num(href_list["seeker_port"])
		if(isnum_safe(port_num))
			seeker_port = port_num
		if(!logged_in) // the login handler is ready now
			src?.send_saved_session_token()

	switch(href_list["_src_"])
		if("holder")
			hsrc = holder
		if("mentor")
			hsrc = mentor_datum
		if("usr")
			hsrc = mob
		if("vars")
			return view_var_Topic(href,href_list,hsrc)

	switch(href_list["action"])
		if("openLink")
			src << link(href_list["link"])
	if (hsrc)
		var/datum/real_src = hsrc
		if(QDELETED(real_src))
			return

	..()	//redirect to hsrc.Topic()

/// If this client is BYOND member.
/client/proc/is_content_unlocked()
	return prefs?.unlock_content

/*
 * Call back proc that should be checked in all paths where a client can send messages
 *
 * Handles checking for people sending messages too fast.
 *
 * This is defined as sending SPAM_TRIGGER_AUTOMUTE (10) messages within 5 seconds, which gets you auto-muted.
 *
 * You will be warned if you send SPAM_TRIGGER_WARNING(5) messages withing 5 seconds to hopefully prevent false positives.
 *
 */
/client/proc/handle_spam_prevention(message, mute_type)
	if(!(CONFIG_GET(flag/automute_on)))
		return FALSE

	if(COOLDOWN_FINISHED(src, total_count_reset))
		total_message_count = 0 //reset the count if it's been more than 5 seconds since the first message
		COOLDOWN_START(src, total_count_reset, 5 SECONDS) //inside this if so we don't reset it every single message

	total_message_count++

	if(total_message_count >= SPAM_TRIGGER_AUTOMUTE)
		to_chat(src, span_userdanger("You have exceeded the spam filter limit for too many messages. An auto-mute was applied. Make an adminhelp ticket if you think this was in error."))
		cmd_admin_mute(src, mute_type, TRUE)
		return TRUE

	if(total_message_count >= SPAM_TRIGGER_WARNING)
		to_chat(src, span_userdanger("You are nearing the spam filter limit for too many messages in a short period. Slow down."))
		return FALSE

/client/proc/silicon_spam_grace()
	total_message_count = max(total_message_count--, 0)
	// Stating laws isn't spam at all.

/client/proc/silicon_spam_grace_done(total_laws_count)
	if(total_laws_count>2)
		total_laws_count = 2
	total_message_count += total_laws_count
	// Stating laws isn't spam, but doing so much is spam.

//This stops files larger than UPLOAD_LIMIT being sent from client to server via input(), client.Import() etc.
/client/AllowUpload(filename, filelength)
	if(filelength > UPLOAD_LIMIT)
		to_chat(src, "<font color='red'>Error: AllowUpload(): File Upload too large. Upload Limit: [UPLOAD_LIMIT/1024]KiB.</font>")
		return 0
	return 1

/client/proc/is_localhost()
	return isnull(address) || address == "127.0.0.1" || address == "::1"

/client/proc/time_to_redirect()
	var/redirect_address = CONFIG_GET(string/redirect_address)
	GLOB.ckey_redirects -= ckey
	if(GLOB.joined_player_list.Find(ckey))
		GLOB.joined_player_list -= ckey
	src << link("[redirect_address]")
	qdel(src)

/client/proc/generate_uuid_string()
	var/fiftyfifty = prob(50) ? FEMALE : MALE
	var/hashtext = "[ckey][rand(0,9999)][world.realtime][rand(0,9999)][generate_random_name(fiftyfifty)][rand(0,9999)][address][rand(0,9999)][computer_id][rand(0,9999)][GLOB.round_id]"
	return "[rustg_hash_string(RUSTG_HASH_SHA256, hashtext)]"

/client/proc/generate_uuid()
	if(IsAdminAdvancedProcCall())
		log_admin("Attempted admin generate_uuid() proc call blocked.")
		message_admins("Attempted admin generate_uuid() proc call blocked.")
		return FALSE

	var/uuid = generate_uuid_string()

	if(!SSdbcore.Connect())
		return FALSE

	var/datum/db_query/query_update_uuid = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET uuid = :uuid WHERE ckey = :ckey",
		list("uuid" = uuid, "ckey" = ckey)
	)
	query_update_uuid.Execute()
	qdel(query_update_uuid)

	return uuid

/client/proc/fetch_uuid()
	if(IsAdminAdvancedProcCall())
		log_admin("Attempted admin fetch_uuid() proc call blocked.")
		message_admins("Attempted admin fetch_uuid() proc call blocked.")
		return FALSE

	if(!SSdbcore.Connect())
		return FALSE

	var/datum/db_query/query_get_uuid = SSdbcore.NewQuery(
		"SELECT uuid FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	if(!query_get_uuid.Execute())
		qdel(query_get_uuid)
		return FALSE
	var/uuid = null
	if(query_get_uuid.NextRow())
		uuid = query_get_uuid.item[1]
	qdel(query_get_uuid)
	if(uuid == null)
		return generate_uuid()
	else
		return uuid

//////////////
//DISCONNECT//
//////////////

/client/Del()
	// We have a mob worth keeping and are authenticated
	var/mob_logout = FALSE
	var/mob/my_mob = src.mob
	if(src.logged_in && ismob(my_mob) && !istype(my_mob, /mob/dead/new_player/pre_auth))
		// Don't let the game reassociate with the mob without authenticating again.
		mob_logout = TRUE
		GLOB.disconnected_mobs[src.ckey] = my_mob // now we know on login that we've signed out from this mob and can reassociate.
	if(!gc_destroyed)
		Destroy() //Clean up signals and timers.
	if(mob_logout)
		// Destroy() has to run first because it cleans up our references on the mob
		// Changing the key calls /mob/Logout() which is supposed to run AFTER Destroy.
		my_mob.key = "@DC@[my_mob.key]" // make sure this mob keeps a key that doesn't exist. Very similiar to the adminghost @
	return ..()

/client/Destroy()
	GLOB.clients_unsafe -= src
	GLOB.directory -= ckey
	GLOB.clients -= src
	GLOB.mentors -= src
	log_access("Logout: [key_name(src)]")
	GLOB.ahelp_tickets.ClientLogout(src)
	GLOB.mhelp_tickets.ClientLogout(src)
	GLOB.interviews.client_logout(src)

	if(holder)
		adminGreet(1)
		holder.owner = null
		GLOB.admins -= src
		if (!GLOB.admins.len && SSticker.IsRoundInProgress()) //Only report this stuff if we are currently playing.
			var/cheesy_message = pick(
				"I have no admins online!",\
				"I'm all alone :(",\
				"I'm feeling lonely :(",\
				"I'm so lonely :(",\
				"Why does nobody love me? :(",\
				"I want a man :(",\
				"Where has everyone gone?",\
				"I need a hug :(",\
				"Someone come hold me :(",\
				"I need someone on me :(",\
				"What happened? Where has everyone gone?",\
				"Forever alone :("\
			)

			send2tgs("Server", "[cheesy_message] (No admins online)")

	if(isatom(eye)) // admeme vv failproof. eye must be atom
		var/atom/eye_thing = eye
		LAZYREMOVE(eye_thing.eye_users, src)
	GLOB.requests.client_logout(src)


	SSambience.remove_ambience_client(src)
	Master.UpdateTickRate()
	..() //Even though we're going to be hard deleted there are still some things that want to know the destroy is happening
	return QDEL_HINT_HARDDEL_NOW

/client/proc/check_randomizer(topic)
	. = FALSE
	if (connection != "seeker")
		return
	topic = params2list(topic)
	if (!CONFIG_GET(flag/check_randomizer))
		return
	var/static/cidcheck = list()
	var/static/tokens = list()
	var/static/cidcheck_failedckeys = list() //to avoid spamming the admins if the same guy keeps trying.
	var/static/cidcheck_spoofckeys = list()
	var/datum/db_query/query_cidcheck = SSdbcore.NewQuery(
		"SELECT computerid FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	query_cidcheck.Execute()

	var/lastcid
	if (query_cidcheck.NextRow())
		lastcid = query_cidcheck.item[1]
	qdel(query_cidcheck)
	var/oldcid = cidcheck[ckey]

	if (oldcid)
		if (!topic || !topic["token"] || !tokens[ckey] || topic["token"] != tokens[ckey])
			if (!cidcheck_spoofckeys[ckey])
				message_admins(span_adminnotice("[key_name(src)] appears to have attempted to spoof a cid randomizer check."))
				cidcheck_spoofckeys[ckey] = TRUE
			cidcheck[ckey] = computer_id
			tokens[ckey] = cid_check_reconnect()

			sleep(15 SECONDS) //Longer sleep here since this would trigger if a client tries to reconnect manually because the inital reconnect failed

			//we sleep after telling the client to reconnect, so if we still exist something is up
			log_access("Forced disconnect: [key] [computer_id] [address] - CID randomizer check")

			qdel(src)
			return TRUE

		if (oldcid != computer_id && computer_id != lastcid) //IT CHANGED!!!
			cidcheck -= ckey //so they can try again after removing the cid randomizer.

			to_chat_immediate(src, span_userdanger("Connection Error:"))
			to_chat_immediate(src, span_danger("Invalid ComputerID(spoofed). Please remove the ComputerID spoofer from your byond installation and try again."))

			if (!cidcheck_failedckeys[ckey])
				message_admins(span_adminnotice("[key_name(src)] has been detected as using a cid randomizer. Connection rejected."))
				send2tgs_adminless_only("CidRandomizer", "[key_name(src)] has been detected as using a cid randomizer. Connection rejected.")
				cidcheck_failedckeys[ckey] = TRUE
				note_randomizer_user()

			log_access("Failed Login: [key] [computer_id] [address] - CID randomizer confirmed (oldcid: [oldcid])")

			qdel(src)
			return TRUE
		else
			if (cidcheck_failedckeys[ckey])
				message_admins(span_adminnotice("[key_name_admin(src)] has been allowed to connect after showing they removed their cid randomizer"))
				send2tgs_adminless_only("CidRandomizer", "[key_name(src)] has been allowed to connect after showing they removed their cid randomizer.")
				cidcheck_failedckeys -= ckey
			if (cidcheck_spoofckeys[ckey])
				message_admins(span_adminnotice("[key_name_admin(src)] has been allowed to connect after appearing to have attempted to spoof a cid randomizer check because it <i>appears</i> they aren't spoofing one this time"))
				cidcheck_spoofckeys -= ckey
			cidcheck -= ckey
	else if (computer_id != lastcid)
		cidcheck[ckey] = computer_id
		tokens[ckey] = cid_check_reconnect()

		sleep(5 SECONDS) //browse is queued, we don't want them to disconnect before getting the browse() command.

		//we sleep after telling the client to reconnect, so if we still exist something is up
		log_access("Forced disconnect: [key] [computer_id] [address] - CID randomizer check")

		qdel(src)
		return TRUE

/client/proc/cid_check_reconnect()
	var/token = rustg_hash_string(RUSTG_HASH_MD5, "[rand(0,9999)][world.time][rand(0,9999)][ckey][rand(0,9999)][address][rand(0,9999)][computer_id][rand(0,9999)]")
	. = token
	log_access("Failed Login: [key] [computer_id] [address] - CID randomizer check")
	var/url = winget(src, null, "url")
	//special javascript to make them reconnect under a new window.
	src << browse({"<a id='link' href="byond://[url]?token=[token]">byond://[url]?token=[token]</a><script type="text/javascript">document.getElementById("link").click();window.location="byond://winset?command=.quit"</script>"}, "border=0;titlebar=0;size=1x1;window=redirect")
	to_chat_immediate(src, {"<a href="byond://[url]?token=[token]">You will be automatically taken to the game, if not, click here to be taken manually</a>"})

/client/proc/note_randomizer_user()
	add_system_note("CID-Error", "Detected as using a cid randomizer.")

/client/proc/add_system_note(system_ckey, message)
	//check to see if we noted them in the last day.
	var/datum/db_query/query_get_notes = SSdbcore.NewQuery(
		"SELECT id FROM [format_table_name("messages")] WHERE type = 'note' AND targetckey = :targetckey AND adminckey = :adminckey AND timestamp + INTERVAL 1 DAY < NOW() AND deleted = 0 AND (expire_timestamp > NOW() OR expire_timestamp IS NULL)",
		list("targetckey" = ckey, "adminckey" = system_ckey)
	)
	if(!query_get_notes.Execute())
		qdel(query_get_notes)
		return
	if(query_get_notes.NextRow())
		qdel(query_get_notes)
		return
	qdel(query_get_notes)
	//regardless of above, make sure their last note is not from us, as no point in repeating the same note over and over.
	query_get_notes = SSdbcore.NewQuery(
		"SELECT adminckey FROM [format_table_name("messages")] WHERE targetckey = :targetckey AND deleted = 0 AND (expire_timestamp > NOW() OR expire_timestamp IS NULL) ORDER BY timestamp DESC LIMIT 1",
		list("targetckey" = ckey)
	)
	if(!query_get_notes.Execute())
		qdel(query_get_notes)
		return
	if(query_get_notes.NextRow())
		if (query_get_notes.item[1] == system_ckey)
			qdel(query_get_notes)
			return
	qdel(query_get_notes)
	create_message("note", key, system_ckey, message, null, null, 0, 0, null, 0, 0)


/client/proc/check_ip_intel()
	set waitfor = 0 //we sleep when getting the intel, no need to hold up the client connection while we sleep
	if (!is_localhost() && CONFIG_GET(string/ipintel_email))
		var/datum/ipintel/res = get_ip_intel(address)
		if (res.intel >= CONFIG_GET(number/ipintel_rating_bad))
			message_admins(span_adminnotice("Proxy Detection: [key_name_admin(src)] IP intel rated [res.intel*100]% likely to be a Proxy/VPN."))
		ip_intel = res.intel

/client/Click(atom/object, atom/location, control, params)
	var/ab = FALSE
	var/list/modifiers = params2list(params)

	var/dragged = LAZYACCESS(modifiers, DRAG)
	if(dragged && !LAZYACCESS(modifiers, dragged)) //I don't know what's going on here, but I don't trust it
		return

	if (object && object == middragatom && LAZYACCESS(modifiers, LEFT_CLICK))
		ab = max(0, 5 SECONDS-(world.time-middragtime)*0.1)

	var/mcl = CONFIG_GET(number/minute_click_limit)
	if (!holder && mcl)
		var/minute = round(world.time, 600)
		if (!clicklimiter)
			clicklimiter = new(LIMITER_SIZE)
		if (minute != clicklimiter[CURRENT_MINUTE])
			clicklimiter[CURRENT_MINUTE] = minute
			clicklimiter[MINUTE_COUNT] = 0
		clicklimiter[MINUTE_COUNT] += 1+(ab)
		if (clicklimiter[MINUTE_COUNT] > mcl)
			var/msg = "Your previous click was ignored because you've done too many in a minute."
			if (minute != clicklimiter[ADMINSWARNED_AT]) //only one admin message per-minute. (if they spam the admins can just boot/ban them)
				clicklimiter[ADMINSWARNED_AT] = minute

				msg += " Administrators have been informed."
				if (ab)
					log_game("[key_name(src)] is using the middle click aimbot exploit")
					message_admins("[ADMIN_LOOKUPFLW(src)] [ADMIN_KICK(usr)] is using the middle click aimbot exploit")
					add_system_note("aimbot", "Is using the middle click aimbot exploit")
				log_game("[key_name(src)] Has hit the per-minute click limit of [mcl] clicks in a given game minute")
				message_admins("[ADMIN_LOOKUPFLW(src)] [ADMIN_KICK(usr)] Has hit the per-minute click limit of [mcl] clicks in a given game minute")
			to_chat(src, span_danger("[msg]"))
			return

	var/scl = CONFIG_GET(number/second_click_limit)
	if (!holder && scl)
		var/second = round(world.time, 10)
		if (!clicklimiter)
			clicklimiter = new(LIMITER_SIZE)
		if (second != clicklimiter[CURRENT_SECOND])
			clicklimiter[CURRENT_SECOND] = second
			clicklimiter[SECOND_COUNT] = 0
		clicklimiter[SECOND_COUNT] += 1+(!!ab)
		if (clicklimiter[SECOND_COUNT] > scl)
			to_chat(src, span_danger("Your previous click was ignored because you've done too many in a second"))
			return

	if (hotkeys)
		// If hotkey mode is enabled, then clicking the map will automatically
		// unfocus the text bar. This removes the red color from the text bar
		// so that the visual focus indicator matches reality.
		winset(src, null, "input.background-color=[COLOR_INPUT_DISABLED]")
	else
		winset(src, null, "input.focus=true input.background-color=[COLOR_INPUT_ENABLED]")

	..()

/// Sets client eye to 1st param.
/// * WARN: Do not change old_eye. Check client/var/eye_weakref
/client/proc/set_eye(atom/new_eye, atom/old_eye = src.eye)
	if(new_eye == old_eye)
		return

	if(isatom(old_eye)) // admeme vv failproof. /datum can't be their eyes
		LAZYREMOVE(old_eye.eye_users, src)

	eye = new_eye
	eye_weakref = WEAKREF(eye)

	if(isatom(new_eye))
		LAZYADD(new_eye.eye_users, src)

	// SEND_SIGNAL(src, COMSIG_CLIENT_SET_EYE, old_eye, new_eye) // use this when you want a thing from TG //This is from planecube pr, dragon, we most certainly dont want from that pr


/client/proc/add_verbs_from_config()
	if(CONFIG_GET(flag/see_own_notes))
		add_verb(/client/proc/self_notes)
	if(CONFIG_GET(flag/use_exp_tracking))
		add_verb(/client/proc/self_playtime)
	if(CONFIG_GET(flag/enable_mrat))
		add_verb(/client/proc/mrat)


#undef UPLOAD_LIMIT

//checks if a client is afk
//3000 frames = 5 minutes
/client/proc/is_afk(duration = CONFIG_GET(number/inactivity_period))
	if(inactivity > duration)
		return inactivity
	return FALSE

/// Send resources to the client.
/// Sends both game resources and browser assets.
/client/proc/send_resources()
#if (PRELOAD_RSC == 0)
	var/static/next_external_rsc = 0
	var/list/external_rsc_urls = CONFIG_GET(keyed_list/external_rsc_urls)
	if(length(external_rsc_urls.len))
		next_external_rsc = WRAP(next_external_rsc+1, 1, external_rsc_urls.len+1)
		preload_rsc = external_rsc_urls[next_external_rsc]
#endif
	spawn (10) //removing this spawn causes all clients to not get verbs.
		//load info on what assets the client has
		src << browse('code/modules/asset_cache/validate_assets.html', "window=asset_cache_browser")
		//Precache the client with all other assets slowly, so as to not block other browse() calls
		if (CONFIG_GET(flag/asset_simple_preload))
			addtimer(CALLBACK(SSassets.transport, TYPE_PROC_REF(/datum/asset_transport, send_assets_slow), src, SSassets.transport.preload), 5 SECONDS)
		#if (PRELOAD_RSC == 0)
		for (var/name in GLOB.vox_sounds)
			var/file = GLOB.vox_sounds[name]
			Export("##action=load_rsc", file)
			stoplag()
		#endif


//Hook, override it to run code when dir changes
//Like for /atoms, but clients are their own snowflake FUCK
/client/proc/setDir(newdir)
	dir = newdir

/client/vv_edit_var(var_name, var_value)
	switch (var_name)
		if (NAMEOF(src, holder))
			return FALSE
		if (NAMEOF(src, ckey))
			return FALSE
		if (NAMEOF(src, key))
			return FALSE
		if (NAMEOF(src, cached_badges))
			return FALSE
		if (NAMEOF(src, metabalance_cached))
			return FALSE
		if (NAMEOF(src, antag_token_count_cached))
			return FALSE
		if (NAMEOF(src, authenticate))
			return FALSE
		if (NAMEOF(src, logged_in))
			log_admin_private("[key_name(usr)] attempted to auth bypass [key_name(src)] via client.logged_in")
			return FALSE
		if (NAMEOF(src, byond_authenticated_key))
			return FALSE
		if (NAMEOF(src, key_is_external))
			return FALSE
		if (NAMEOF(src, external_method))
			return FALSE
		if (NAMEOF(src, external_uid))
			return FALSE
		if (NAMEOF(src, external_display_name))
			return FALSE
		if (NAMEOF(src, temp_topicdata))
			return FALSE
		if (NAMEOF(src, seeker_port))
			return FALSE
		if (NAMEOF(src, ban_cache))
			return FALSE
		if (NAMEOF(src, mentor_datum))
			return FALSE
		if (NAMEOF(src, view))
			view_size.setDefault(var_value)
			return TRUE
	. = ..()

/client/proc/rescale_view(change, min, max)
	view_size.setTo(clamp(change, min, max), clamp(change, min, max))

/client/proc/change_view(new_size)
	if (isnull(new_size))
		CRASH("change_view called without argument.")

	view = new_size
	apply_clickcatcher()
	mob.reload_fullscreen()
	if (isliving(mob))
		var/mob/living/M = mob
		M.update_damage_hud()
	attempt_auto_fit_viewport()

/client/proc/generate_clickcatcher()
	if(!void)
		void = new()
		screen += void

/client/proc/apply_clickcatcher()
	generate_clickcatcher()
	var/list/actualview = getviewsize(view)
	void.UpdateGreed(actualview[1],actualview[2])

/client/proc/AnnouncePR(announcement)
	if(prefs && prefs.read_player_preference(/datum/preference/toggle/chat_pullr))
		to_chat(src, announcement)

/client/proc/show_account_identifier()
	set name = "Show Account Identifier"
	set category = "OOC"
	set desc ="Get your ID for account verification."

	remove_verb(/client/proc/show_account_identifier)
	addtimer(CALLBACK(src, PROC_REF(restore_account_identifier)), 20) //Don't DoS DB queries, asshole

	var/confirm = alert("Do NOT share the verification ID in the following popup. Understand?", "Important Warning", "Yes", "Cancel")
	if(confirm != "Yes")
		return
	var/uuid = fetch_uuid()
	if(!uuid)
		alert("Failed to fetch your verification ID. Try again later. If problems persist, tell an admin.", "Account Verification", "Okay")
		log_sql("Failed to fetch UUID for [key_name(src)]")
	else
		var/dat
		dat += "<h3>Account Identifier</h3>"
		dat += "<br>"
		dat += "<h3>Do NOT share this id:</h3>"
		dat += "<br>"
		dat += "[uuid]"

		src << browse(HTML_SKELETON(dat), "window=accountidentifier;size=600x320")
		onclose(src, "accountidentifier")

/client/proc/restore_account_identifier()
	add_verb(/client/proc/show_account_identifier)

/client/proc/check_upstream_bans()
	set waitfor = 0

	if(!CONFIG_GET(string/centcom_ban_db))
		return

	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/centcom_ban_db)]/[ckey]", "", "")
	request.begin_async()
	UNTIL(request.is_complete())

	var/datum/http_response/response = request.into_response()

	var/list/bans

	if(response.errored || response.status_code != 200 || response.body == "[]")
		return

	bans = json_decode(response.body)
	for(var/list/ban in bans)
		var/list/ban_attributes = ban["banAttributes"]
		if(ban_attributes["BeeStationGlobal"])
			if(CONFIG_GET(flag/respect_upstream_permabans) && ban["expires"])
				continue

			to_chat_immediate(src, span_userdanger("Your connection has been closed because you are currently banned from BeeStation."))
			message_admins("[key_name(src)] was removed from the game due to a ban from BeeStation.")
			qdel(src)
			return

/client/proc/open_filter_editor(atom/in_atom)
	if(holder)
		holder.filteriffic = new /datum/filter_editor(in_atom)
		holder.filteriffic.ui_interact(mob)

/client/proc/open_particle_editor(atom/in_atom)
	if(holder)
		holder.particool = new /datum/particle_editor(in_atom)
		holder.particool.ui_interact(mob)

/client/proc/give_award(achievement_type, mob/user)
	return player_details.achievements.unlock(achievement_type, user)

/client/proc/increase_score(achievement_type, mob/user, value)
	return player_details.achievements.increase_score(achievement_type, user, value)

#undef LIMITER_SIZE
#undef CURRENT_SECOND
#undef SECOND_COUNT
#undef CURRENT_MINUTE
#undef MINUTE_COUNT
#undef ADMINSWARNED_AT
