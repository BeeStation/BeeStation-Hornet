
GLOBAL_VAR_INIT(OOC_COLOR, null)//If this is null, use the CSS for OOC. Otherwise, use a custom colour.
GLOBAL_VAR_INIT(normal_ooc_colour, "#002eb8")

AUTH_CLIENT_VERB(ooc, msg as text)
	set name = "OOC" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set category = "OOC"

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return

	if(!mob)
		return

	if(!holder)
		if(!GLOB.ooc_allowed)
			to_chat(src, span_danger("OOC is globally muted."))
			return
		if(SSticker.current_state < GAME_STATE_PLAYING && !istype(mob, /mob/dead/new_player))
			to_chat(src, span_danger("Observers cannot use OOC pre-game."))
			return
		if(mob.stat == DEAD && !GLOB.dooc_allowed)
			to_chat(usr, span_danger("OOC for dead mobs has been turned off."))
			return
		if(prefs && (player_details.muted & MUTE_OOC))
			to_chat(src, span_danger("You cannot use OOC (muted)."))
			return
	else
		if(SSticker.current_state == GAME_STATE_PLAYING && holder.ooc_confirmation_enabled)
			var/choice = alert("The round is still ongoing, are you sure you wish to send an OOC message?", "Confirm midround OOC?", "No", "Yes", "Always yes for this round")
			switch(choice)
				if("No")
					return
				if("Always yes for this round")
					holder.ooc_confirmation_enabled = FALSE
	if(is_banned_from(ckey, BAN_OOC))
		to_chat(src, span_danger("You have been banned from OOC."))
		return
	if(QDELETED(src))
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)
	var/raw_msg = msg

	if(!msg)
		return

	msg = emoji_parse(msg)

	if((msg[1] in list(".",";",":","#")) || findtext_char(msg, "say", 1, 5))
		if(alert("Your message \"[raw_msg]\" looks like it was meant for in game communication, say it in OOC?", "Meant for OOC?", "No", "Yes") != "Yes")
			return

	if(!holder)
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in OOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
			return
		if(findtext(msg, "://") || findtext(msg, "www."))
			to_chat(src, "<B>Posting clickable links in OOC is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to post a clickable link in OOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to post a clickable link in OOC: [msg]")
			return

	if(prefs && !prefs.read_player_preference(/datum/preference/toggle/chat_ooc))
		to_chat(src, span_danger("You have OOC muted."))
		return
	if(OOC_FILTER_CHECK(raw_msg))
		to_chat(src, span_warning("That message contained a word prohibited in OOC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ooc_chat'>\"[raw_msg]\""))
		return

	mob.log_talk(raw_msg, LOG_OOC)

	var/display_name = display_name()
	var/keyname = display_name
	var/ooccolor = prefs?.read_player_preference(/datum/preference/color/ooc_color) || DEFAULT_BONUS_OOC_COLOR
	if(prefs.unlock_content && prefs.read_player_preference(/datum/preference/toggle/member_public))
		keyname = "<font color='[ooccolor ? ooccolor : GLOB.normal_ooc_colour]'>[icon2html('icons/member_content.dmi', world, "blag")][keyname]</font>"
	//Get client badges
	var/badge_data = badge_parse(get_badges())
	//The linkify span classes and linkify=TRUE below make ooc text get clickable chat href links if you pass in something resembling a url
	for(var/client/C in GLOB.clients)
		if(!C.prefs || C.prefs.read_player_preference(/datum/preference/toggle/chat_ooc))
			if(holder?.fakekey in C.prefs.ignoring)
				continue
			if(holder)
				if(!holder.fakekey || C.holder)
					if(check_rights_for(src, R_ADMIN))
						to_chat(C, "[badge_data][span_adminooc("[CONFIG_GET(flag/allow_admin_ooccolor) && ooccolor ? "<font color=[ooccolor]>" : ""][span_prefix("OOC:")] <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> [span_messagelinkify(msg)]</font>")]", allow_linkify = TRUE)
					else
						to_chat(C, "[badge_data][span_adminobserverooc("[span_prefix("OOC:")] <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> [span_messagelinkify(msg)]")]")
				else
					if(GLOB.OOC_COLOR)
						to_chat(C, "[badge_data]<font color='[GLOB.OOC_COLOR]'><b>[span_prefix("OOC:")] <EM>[holder.fakekey ? holder.fakekey : key]:</EM> [span_messagelinkify(msg)]</b></font>")
					else
						to_chat(C, "[badge_data][span_ooc("[span_prefix("OOC:")] <EM>[holder.fakekey ? holder.fakekey : key]:</EM> [span_messagelinkify(msg)]")]")

			else if(!C.prefs || !(key in C.prefs.ignoring))
				if(GLOB.OOC_COLOR)
					to_chat(C, "[badge_data]<font color='[GLOB.OOC_COLOR]'><b>[span_prefix("OOC:")] <EM>[keyname]:</EM> [span_messagelinkify(msg)]</b></font>")
				else
					to_chat(C, "[badge_data][span_ooc("[span_prefix("OOC:")] <EM>[keyname]:</EM> [span_messagelinkify(msg)]")]")
	// beestation, send to discord
	send_chat_to_discord(CHAT_TYPE_OOC, holder?.fakekey || display_name, raw_msg)

/proc/send_chat_to_discord(type, sayer, msg)
	var/discord_ooc_tag = CONFIG_GET(string/discord_ooc_tag) // check server config file. check `config.txt` file for the usage.
	discord_ooc_tag = discord_ooc_tag ? "\[[discord_ooc_tag]\] " : ""
	switch(type)
		if(CHAT_TYPE_OOC)
			sendooc2ext("[discord_ooc_tag](OOC) **[sayer]:** [msg]")
		if(CHAT_TYPE_DEADCHAT) // don't send these until a round is finished
			if(SSticker.current_state == GAME_STATE_FINISHED)
				var/regex/R = regex("<span class=' '>(\[\\s\\S.\]+)</span>\"")
				if(!R.Find(msg))
					return
				msg = R.group[1] // wipes some bad dchat format
				sendooc2ext("[discord_ooc_tag](Dead) **[sayer]:** [msg]")

/proc/toggle_ooc(toggle = null)
	if(toggle != null) //if we're specifically en/disabling ooc
		if(toggle != GLOB.ooc_allowed)
			GLOB.ooc_allowed = toggle
		else
			return
	else //otherwise just toggle it
		GLOB.ooc_allowed = !GLOB.ooc_allowed
	to_chat(world, "<B>The OOC channel has been globally [GLOB.ooc_allowed ? "enabled" : "disabled"].</B>")

/proc/toggle_dooc(toggle = null)
	if(toggle != null)
		if(toggle != GLOB.dooc_allowed)
			GLOB.dooc_allowed = toggle
		else
			return
	else
		GLOB.dooc_allowed = !GLOB.dooc_allowed

/client/proc/set_ooc(newColor as color)
	set name = "Set All Player OOC Color"
	set desc = "Modifies player OOC Color"
	set category = "Fun"
	GLOB.OOC_COLOR = sanitize_hexcolor(newColor, include_crunch = TRUE)

/client/proc/reset_ooc()
	set name = "Reset All Player OOC Color"
	set desc = "Returns player OOC Color to default"
	set category = "Fun"
	GLOB.OOC_COLOR = null

//Checks admin notice
AUTH_CLIENT_VERB(admin_notice)
	set name = "Adminnotice"
	set category = "Admin"
	set desc ="Check the admin notice if it has been set"

	if(GLOB.admin_notice)
		to_chat(src, "[span_boldnotice("Admin Notice:")]\n \t [GLOB.admin_notice]")
	else
		to_chat(src, span_notice("There are no admin notices at the moment."))

AUTH_CLIENT_VERB(motd)
	set name = "MOTD"
	set category = "OOC"
	set desc ="Check the Message of the Day"

	var/motd = global.config.motd
	if(motd)
		to_chat(src, "<div class=\"motd\">[motd]</div>", handle_whitespace=FALSE, allow_linkify = TRUE)
	else
		to_chat(src, span_notice("The Message of the Day has not been set."))

/client/proc/self_notes()
	set name = "View Admin Remarks"
	set category = "OOC"
	set desc = "View the notes that admins have written about you"

	if(!CONFIG_GET(flag/see_own_notes))
		to_chat(usr, span_notice("Sorry, that function is not enabled on this server."))
		return

	browse_messages(null, usr.ckey, null, TRUE)

/client/proc/self_playtime()
	set name = "View tracked playtime"
	set category = "OOC"
	set desc = "View the amount of playtime for roles the server has tracked."

	if(!CONFIG_GET(flag/use_exp_tracking))
		to_chat(usr, span_notice("Sorry, tracking is currently disabled."))
		return

	new /datum/job_report_menu(src, usr)

// Ignore verb
AUTH_CLIENT_VERB(select_ignore)
	set name = "Ignore"
	set category = "OOC"
	set desc ="Ignore a player's messages on the OOC channel"

	if(!prefs)
		return
	// Make a list to choose players from
	var/list/players = list()

	// Use keys and fakekeys for the same purpose
	var/displayed_key = ""

	// Try to add every player who's online to the list
	for(var/client/C in GLOB.clients)
		// Don't add ourself
		if(C == src)
			continue

		// Don't add players we've already ignored if they're not using a fakekey
		if((C.key in prefs.ignoring) && !C.holder?.fakekey)
			continue

		// Don't add players using a fakekey we've already ignored
		if(C.holder?.fakekey in prefs.ignoring)
			continue

		// Use the player's fakekey if they're using one
		if(C.holder?.fakekey)
			displayed_key = C.holder.fakekey

		// Use the player's key if they're not using a fakekey
		else
			displayed_key = C.key

		// Check if both we and the player are ghosts and they're not using a fakekey
		if(isobserver(mob) && isobserver(C.mob) && !C.holder?.fakekey)
			// Show us the player's mob name in the list in front of their displayed key
			// Add the player's displayed key to the list
			players["[C.mob]([displayed_key])"] = displayed_key

		// Add the player's displayed key to the list if we or the player aren't a ghost or they're using a fakekey
		else
			players[displayed_key] = displayed_key

	// Check if the list is empty
	if(!length(players))
		// Express that there are no players we can ignore in chat
		to_chat(src, "There are no other players you can ignore!")

		// Stop running
		return

	// Sort the list
	players = sort_list(players)

	// Request the player to ignore
	var/selection = tgui_input_list(src, "Select a player", "Ignore", players)

	// Stop running if we didn't receieve a valid selection
	if(isnull(selection) || !(selection in players))
		return

	// Store the selected player
	selection = players[selection]

	// Check if the selected player is on our ignore list
	if(selection in prefs.ignoring)
		// Express that the selected player is already on our ignore list in chat
		to_chat(src, "You are already ignoring [selection]!")

		// Stop running
		return

	// Add the selected player to our ignore list
	prefs.ignoring.Add(selection)

	// Save our preferences
	prefs.mark_undatumized_dirty_player()

	// Express that we've ignored the selected player in chat
	to_chat(src, "You are now ignoring [selection] on the OOC channel.")

// Unignore verb
/client/verb/select_unignore()
	set name = "Unignore"
	set category = "OOC"
	set desc = "Stop ignoring a player's messages on the OOC channel"

	// Check if we've ignored any players
	if(!length(prefs.ignoring))
		// Express that we haven't ignored any players in chat
		to_chat(src, "You haven't ignored any players!")

		// Stop running
		return

	// Request the player to unignore
	var/selection = tgui_input_list(src, "Select a player", "Unignore", prefs.ignoring)

	// Stop running if we didn't receive a selection
	if(isnull(selection))
		return

	// Check if the selected player is not on our ignore list
	if(!(selection in prefs.ignoring))
		// Express that the selected player is not on our ignore list in chat
		to_chat(src, "You are not ignoring [selection]!")

		// Stop running
		return

	// Remove the selected player from our ignore list
	prefs.ignoring.Remove(selection)

	// Save our preferences
	prefs.mark_undatumized_dirty_player()

	// Express that we've unignored the selected player in chat
	to_chat(src, "You are no longer ignoring [selection] on the OOC channel.")

/client/proc/show_previous_roundend_report()
	set name = "Your Last Round"
	set category = "OOC"
	set desc = "View the last round end report you've seen"

	SSticker.show_roundend_report(src, TRUE)

AUTH_CLIENT_VERB(fit_viewport)
	set name = "Fit Viewport"
	set category = "OOC"
	set desc = "Fit the width of the map window to match the viewport"

	// Fetch aspect ratio
	var/view_size = getviewsize(view)
	var/aspect_ratio = view_size[1] / view_size[2]

	// Calculate desired pixel width using window size and aspect ratio
	var/list/sizes = params2list(winget(src, "mainwindow.split;mapwindow", "size"))

	// Client closed the window? Some other error? This is unexpected behaviour, let's
	// CRASH with some info.
	if(!sizes["mapwindow.size"])
		CRASH("sizes does not contain mapwindow.size key. This means a winget failed to return what we wanted. --- sizes var: [sizes] --- sizes length: [length(sizes)]")

	var/list/map_size = splittext(sizes["mapwindow.size"], "x")

	// Gets the type of zoom we're currently using from our view datum
	// If it's 0 we do our pixel calculations based off the size of the mapwindow
	// If it's not, we already know how big we want our window to be, since zoom is the exact pixel ratio of the map
	var/zoom_value = src.view_size?.zoom || 0

	var/desired_width = 0
	if(zoom_value)
		desired_width = round(view_size[1] * zoom_value * world.icon_size)
	else

		// Looks like we expect mapwindow.size to be "ixj" where i and j are numbers.
		// If we don't get our expected 2 outputs, let's give some useful error info.
		if(length(map_size) != 2)
			CRASH("map_size of incorrect length --- map_size var: [map_size] --- map_size length: [length(map_size)]")
		var/height = text2num(map_size[2])
		desired_width = round(height * aspect_ratio)

	if (text2num(map_size[1]) == desired_width)
		// Nothing to do
		return

	var/split_size = splittext(sizes["mainwindow.split.size"], "x")
	var/split_width = text2num(split_size[1])

	// Calculate and apply a best estimate
	// +4 pixels are for the width of the splitter's handle
	var/pct = 100 * (desired_width + 4) / split_width
	winset(src, "mainwindow.split", "splitter=[pct]")

	// Apply an ever-lowering offset until we finish or fail
	var/delta
	for(var/safety in 1 to 10)
		var/after_size = winget(src, "mapwindow", "size")
		map_size = splittext(after_size, "x")
		var/got_width = text2num(map_size[1])

		if (got_width == desired_width)
			// success
			return
		else if (isnull(delta))
			// calculate a probable delta value based on the difference
			delta = 100 * (desired_width - got_width) / split_width
		else if ((delta > 0 && got_width > desired_width) || (delta < 0 && got_width < desired_width))
			// if we overshot, halve the delta and reverse direction
			delta = -delta/2

		pct += delta
		winset(src, "mainwindow.split", "splitter=[pct]")

/// Attempt to automatically fit the viewport, assuming the user wants it
/client/proc/attempt_auto_fit_viewport()
	if (!prefs || !prefs.read_preference(/datum/preference/toggle/auto_fit_viewport))
		return
	// No need to attempt to fit the viewport on non-initialized clients as they'll auto-fit viewport right before finishing init
	if(fully_created)
		INVOKE_ASYNC(src, PROC_REF(fit_viewport))

AUTH_CLIENT_VERB(view_runtimes_minimal)
	set name = "View Minimal Runtimes"
	set category = "OOC"
	set desc = "Open the runtime error viewer, with reduced information"

	if(!isobserver(mob) && SSticker.current_state != GAME_STATE_FINISHED)
		to_chat(src, span_warning("You cannot currently do that at this time, please wait until the round end or while you are observing."))
		return

	GLOB.error_cache.show_to_minimal(src)

AUTH_CLIENT_VERB(speech_format_help)
	set name = "Speech Format Help"
	set category = "OOC"
	set desc = "Chat formatting help"

	var/message = "[span_big("You can add emphasis to your text by surrounding words or sentences in certain characters.")]\n \
		**bold**, and _italics_ are supported.\n\n \
		[span_big("You can made custom saymods by doing <i>say 'screams| HELP IM DYING!'</i>. This works over the radio, and can be used to emote over the radio.")]\n \
		Example: say ';laughs maniacally!|' >> \[Common] Joe Schmoe laughs maniacally!"


	to_chat(usr, span_notice("[message]"))

AUTH_CLIENT_VERB(show_map_vote_tallies)
	set name = "Show Map Vote Tallies"
	set category = "OOC"
	set desc = "View the current map vote tally counts."

	to_chat(src, SSmap_vote.tally_printout)
