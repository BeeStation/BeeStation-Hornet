GLOBAL_VAR_INIT(OOC_COLOR, null)//If this is null, use the CSS for OOC. Otherwise, use a custom colour.
GLOBAL_VAR_INIT(normal_ooc_colour, "#002eb8")

/client/verb/ooc(msg as text)
	set name = "OOC" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set category = "OOC"

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Speech is currently admin-disabled.</span>")
		return

	if(!mob)
		return

	if(!holder)
		if(!GLOB.ooc_allowed)
			to_chat(src, "<span class='danger'>OOC is globally muted.</span>")
			return
		if(!GLOB.dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='danger'>OOC for dead mobs has been turned off.</span>")
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, "<span class='danger'>You cannot use OOC (muted).</span>")
			return
	if(is_banned_from(ckey, "OOC"))
		to_chat(src, "<span class='danger'>You have been banned from OOC.</span>")
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

	if(!(prefs.chat_toggles & CHAT_OOC))
		to_chat(src, "<span class='danger'>You have OOC muted.</span>")
		return
	if(OOC_FILTER_CHECK(raw_msg))
		to_chat(src, "<span class='warning'>That message contained a word prohibited in OOC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ooc_chat'>\"[raw_msg]\"</span></span>")
		return

	mob.log_talk(raw_msg, LOG_OOC)

	var/keyname = key
	if(prefs.unlock_content)
		if(prefs.toggles & MEMBER_PUBLIC)
			keyname = "<font color='[prefs.ooccolor ? prefs.ooccolor : GLOB.normal_ooc_colour]'>[icon2html('icons/member_content.dmi', world, "blag")][keyname]</font>"
	//The linkify span classes and linkify=TRUE below make ooc text get clickable chat href links if you pass in something resembling a url
	for(var/client/C in GLOB.clients)
		if(C.prefs.chat_toggles & CHAT_OOC)
			if(holder)
				if(!holder.fakekey || C.holder)
					if(check_rights_for(src, R_ADMIN))
						to_chat(C, "<span class='adminooc'>[CONFIG_GET(flag/allow_admin_ooccolor) && prefs.ooccolor ? "<font color=[prefs.ooccolor]>" :"" ]<span class='prefix'>OOC:</span> <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message linkify'>[msg]</span></span></font>", allow_linkify = TRUE)
					else
						to_chat(C, "<span class='adminobserverooc'><span class='prefix'>OOC:</span> <EM>[keyname][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message linkify'>[msg]</span></span>")
				else
					if(GLOB.OOC_COLOR)
						to_chat(C, "<font color='[GLOB.OOC_COLOR]'><b><span class='prefix'>OOC:</span> <EM>[holder.fakekey ? holder.fakekey : key]:</EM> <span class='message linkify'>[msg]</span></b></font>")
					else
						to_chat(C, "<span class='ooc'><span class='prefix'>OOC:</span> <EM>[holder.fakekey ? holder.fakekey : key]:</EM> <span class='message linkify'>[msg]</span></span>")

			else if(!(key in C.prefs.ignoring))
				if(GLOB.OOC_COLOR)
					to_chat(C, "<font color='[GLOB.OOC_COLOR]'><b><span class='prefix'>OOC:</span> <EM>[keyname]:</EM> <span class='message linkify'>[msg]</span></b></font>")
				else
					to_chat(C, "<span class='ooc'><span class='prefix'>OOC:</span> <EM>[keyname]:</EM> <span class='message linkify'>[msg]</span></span>")
	// beestation, send to discord
	if(holder?.fakekey)
		discordsendmsg("ooc", "**[holder.fakekey]:** [msg]")
	else
		discordsendmsg("ooc", "**[key]:** [msg]")

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
	set name = "Set Player OOC Color"
	set desc = "Modifies player OOC Color"
	set category = "Fun"
	GLOB.OOC_COLOR = sanitize_ooccolor(newColor)

/client/proc/reset_ooc()
	set name = "Reset Player OOC Color"
	set desc = "Returns player OOC Color to default"
	set category = "Fun"
	GLOB.OOC_COLOR = null

/client/verb/colorooc()
	set name = "Set Your OOC Color"
	set category = "Preferences"

	if(!holder || !check_rights_for(src, R_ADMIN))
		if(!is_content_unlocked())
			return

	var/new_ooccolor = input(src, "Please select your OOC color.", "OOC color", prefs.ooccolor) as color|null
	if(new_ooccolor)
		prefs.ooccolor = sanitize_ooccolor(new_ooccolor)
		prefs.save_preferences()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Set OOC Color") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/verb/resetcolorooc()
	set name = "Reset Your OOC Color"
	set desc = "Returns your OOC Color to default"
	set category = "Preferences"

	if(!holder || !check_rights_for(src, R_ADMIN))
		if(!is_content_unlocked())
			return

		prefs.ooccolor = initial(prefs.ooccolor)
		prefs.save_preferences()

//Checks admin notice
/client/verb/admin_notice()
	set name = "Adminnotice"
	set category = "Admin"
	set desc ="Check the admin notice if it has been set"

	if(GLOB.admin_notice)
		to_chat(src, "<span class='boldnotice'>Admin Notice:</span>\n \t [GLOB.admin_notice]")
	else
		to_chat(src, "<span class='notice'>There are no admin notices at the moment.</span>")

/client/verb/motd()
	set name = "MOTD"
	set category = "OOC"
	set desc ="Check the Message of the Day"

	var/motd = global.config.motd
	if(motd)
		to_chat(src, "<div class=\"motd\">[motd]</div>", handle_whitespace=FALSE, allow_linkify = TRUE)
	else
		to_chat(src, "<span class='notice'>The Message of the Day has not been set.</span>")

/client/proc/self_notes()
	set name = "View Admin Remarks"
	set category = "OOC"
	set desc = "View the notes that admins have written about you"

	if(!CONFIG_GET(flag/see_own_notes))
		to_chat(usr, "<span class='notice'>Sorry, that function is not enabled on this server.</span>")
		return

	browse_messages(null, usr.ckey, null, TRUE)

/client/proc/self_playtime()
	set name = "View tracked playtime"
	set category = "OOC"
	set desc = "View the amount of playtime for roles the server has tracked."

	if(!CONFIG_GET(flag/use_exp_tracking))
		to_chat(usr, "<span class='notice'>Sorry, tracking is currently disabled.</span>")
		return

	new /datum/job_report_menu(src, usr)

/client/proc/ignore_key(client, displayed_key)
	var/client/C = client
	if(C.key in prefs.ignoring)
		prefs.ignoring -= C.key
	else
		prefs.ignoring |= C.key
	to_chat(src, "You are [(C.key in prefs.ignoring) ? "now" : "no longer"] ignoring [displayed_key] on the OOC channel.")
	prefs.save_preferences()

/client/verb/select_ignore()
	set name = "Ignore"
	set category = "OOC"
	set desc ="Ignore a player's messages on the OOC channel"


	var/see_ghost_names = isobserver(mob)
	var/list/choices = list()
	var/displayed_choicename = ""
	for(var/client/C in GLOB.clients)
		if(C.holder?.fakekey)
			displayed_choicename = C.holder.fakekey
		else
			displayed_choicename = C.key
		if(isobserver(C.mob) && see_ghost_names)
			choices["[C.mob]([displayed_choicename])"] = C
		else
			choices[displayed_choicename] = C
	choices = sortList(choices)
	var/selection = input("Please, select a player!", "Ignore", null, null) as null|anything in choices
	if(!selection || !(selection in choices))
		return
	displayed_choicename = selection // ckey string
	selection = choices[selection] // client
	if(selection == src)
		to_chat(src, "You can't ignore yourself.")
		return
	ignore_key(selection, displayed_choicename)

/client/proc/show_previous_roundend_report()
	set name = "Your Last Round"
	set category = "OOC"
	set desc = "View the last round end report you've seen"

	SSticker.show_roundend_report(src, TRUE)

/client/verb/fit_viewport()
	set name = "Fit Viewport"
	set category = "OOC"
	set desc = "Fit the width of the map window to match the viewport"

	// Fetch aspect ratio
	var/view_size = getviewsize(view)
	var/aspect_ratio = view_size[1] / view_size[2]

	// Calculate desired pixel width using window size and aspect ratio
	var/sizes = params2list(winget(src, "mainwindow.split;mapwindow", "size"))
	var/map_size = splittext(sizes["mapwindow.size"], "x")
	var/height = text2num(map_size[2])
	var/desired_width = round(height * aspect_ratio)
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
