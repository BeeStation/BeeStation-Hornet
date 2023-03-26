////////////////////////////////
/proc/message_admins(msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message linkify\">[msg]</span></span>"
	to_chat(GLOB.admins,
		type = MESSAGE_TYPE_ADMINLOG,
		html = msg)

/proc/relay_msg_admins(msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">RELAY:</span> <span class=\"message linkify\">[msg]</span></span>"
	to_chat(GLOB.admins,
		type = MESSAGE_TYPE_ADMINLOG,
		html = msg)


///////////////////////////////////////////////////////////////////////////////////////////////Panels

/datum/admins/proc/show_player_panel(mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Show Player Panel"
	set desc="Edit player (respawn, ban, heal, etc)"

	if(!check_rights())
		return

	log_admin("[key_name(usr)] checked the individual player panel for [key_name(M)][isobserver(usr)?"":" while in game"].")

	if(!M)
		to_chat(usr, "You seem to be selecting a mob that doesn't exist anymore.")
		return

	var/body = "<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><body>Options panel for <b>[M]</b>"
	if(M.client)
		body += " played by <b>[M.client]</b>"
		body += " <A href='?_src_=holder;[HrefToken()];editrights=[(GLOB.admin_datums[M.client.ckey] || GLOB.deadmins[M.client.ckey]) ? "rank" : "add"];key=[M.key]'>[M.client.holder ? M.client.holder.rank : "Player"]</A>"
		if(CONFIG_GET(flag/use_exp_tracking))
			body += " <A href='?_src_=holder;[HrefToken()];getplaytimewindow=[REF(M)]'>" + M.client.get_exp_living() + "</a>"

	if(isnewplayer(M))
		body += " <B>Hasn't Entered Game</B>"
	else
		body += " <A href='?_src_=holder;[HrefToken()];revive=[REF(M)]'>Heal</A>"

	if(M.client)
		body += "<br><br><b>First Seen:</b> [M.client.player_join_date]<br><b>Byond account registered on:</b> [M.client.account_join_date]"

		if(M.client?.tgui_panel)
			body += M.client.tgui_panel.show_notices() //The datum holds a reference to the client already, no need to pass it.
		else //This should never happen in practice.
			body += "<br><b>Telemetry Status:</b> <span class='bad'>USER CHAT NOT LOADED, CALL A CODER MAYBE?</span>"

		body += "<br><br><b>CentCom Galactic Ban DB: </b> "
		if(CONFIG_GET(string/centcom_ban_db))
			body += "<a href='?_src_=holder;[HrefToken()];centcomlookup=[M.client.ckey]'>Search</a>"
		else
			body += "<i>Disabled</i>"
		body += "<br><br><b>Show related accounts by:</b> "
		body += "<a href='?_src_=holder;[HrefToken()];showrelatedacc=cid;client=[REF(M.client)]'>CID</a> "
		body += "<a href='?_src_=holder;[HrefToken()];showrelatedacc=ip;client=[REF(M.client)]'>IP</a>"
		var/rep = 0
		rep += SSpersistence.antag_rep[M.ckey]
		body += "<br><br><b>Antag Rep:</b> [rep] "
		body += "<a href='?_src_=holder;[HrefToken()];modantagrep=add;mob=[REF(M)]'>+</a> "
		body += "<a href='?_src_=holder;[HrefToken()];modantagrep=subtract;mob=[REF(M)]'>-</a> "
		body += "<a href='?_src_=holder;[HrefToken()];modantagrep=set;mob=[REF(M)]'>=</a> "
		body += "<a href='?_src_=holder;[HrefToken()];modantagrep=zero;mob=[REF(M)]'>0</a>"
		var/antag_tokens = M.client.get_antag_token_count()
		body += "<br><b>Antag Tokens</b>: [antag_tokens] "
		body += "<a href='?_src_=holder;[HrefToken()];modantagtokens=add;mob=[REF(M)]'>+</a> "
		body += "<a href='?_src_=holder;[HrefToken()];modantagtokens=subtract;mob=[REF(M)]'>-</a> "
		body += "<a href='?_src_=holder;[HrefToken()];modantagtokens=set;mob=[REF(M)]'>=</a> "
		body += "<a href='?_src_=holder;[HrefToken()];modantagtokens=zero;mob=[REF(M)]'>0</a>"
		var/metabalance = M.client.get_metabalance()
		body += "<br><b>[CONFIG_GET(string/metacurrency_name)]s</b>: [metabalance] "
		var/full_version = "Unknown"
		if(M.client.byond_version)
			full_version = "[M.client.byond_version].[M.client.byond_build ? M.client.byond_build : "xxx"]"
		body += "<br><br><b>Byond Version:</b> [full_version]<br>"


	body += "<br>"
	body += "<a href='?_src_=vars;[HrefToken()];Vars=[REF(M)]'>VV</a> "
	if(M.mind)
		body += "<a href='?_src_=holder;[HrefToken()];traitor=[REF(M)]'>TP</a> "
	else
		body += "<a href='?_src_=holder;[HrefToken()];initmind=[REF(M)]'>Init Mind</a> "
	if (iscyborg(M))
		body += "<a href='?_src_=holder;[HrefToken()];borgpanel=[REF(M)]'>BP</a> "
	body += "<a href='?priv_msg=[M.ckey]'>PM</a> "
	body += "<a href='?_src_=holder;[HrefToken()];subtlemessage=[REF(M)]'>SM</a> "
	if (ishuman(M) && M.mind)
		body += "<a href='?_src_=holder;[HrefToken()];HeadsetMessage=[REF(M)]'>HM</a> "
	body += "<a href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(M)]'>FLW</a> "
	//Default to client logs if available
	var/source = LOGSRC_MOB
	if(M.client)
		source = LOGSRC_CLIENT
	body += "<a href='?_src_=holder;[HrefToken()];individuallog=[REF(M)];log_src=[source]'>LOGS</a><br>"

	body += "<br><b>Mob Type:</b> [M.type]<br><br>"

	body += "<A href='?_src_=holder;[HrefToken()];boot2=[REF(M)]'>Kick</A> "
	if(M.client)
		body += "<A href='?_src_=holder;[HrefToken()];newbankey=[M.key];newbanip=[M.client.address];newbancid=[M.client.computer_id]'>Ban</A> "
	else
		body += "<A href='?_src_=holder;[HrefToken()];newbankey=[M.key]'>Ban</A> "

	body += "<A href='?_src_=holder;[HrefToken()];showmessageckey=[M.ckey]'>Notes</A>"
	if(M.client)
		body += " <A href='?_src_=holder;[HrefToken()];sendtoprison=[REF(M)]'>Prison</A> "
		body += " <A href='?_src_=holder;[HrefToken()];sendbacktolobby=[REF(M)]'>Send to Lobby</A>"
		var/muted = M.client.prefs.muted
		body += "<br><br><b>Mute: </b> "
		body += "<A href='?_src_=holder;[HrefToken()];mute=[M.ckey];mute_type=[MUTE_IC]' [(muted & MUTE_IC)?"style='font-weight: bold'":""]>IC</a> "
		body += "<A href='?_src_=holder;[HrefToken()];mute=[M.ckey];mute_type=[MUTE_OOC]' [(muted & MUTE_OOC)?"style='font-weight: bold'":""]>OOC</a> "
		body += "<A href='?_src_=holder;[HrefToken()];mute=[M.ckey];mute_type=[MUTE_PRAY]' [(muted & MUTE_PRAY)?"style='font-weight: bold'":""]>PRAY</a> "
		body += "<A href='?_src_=holder;[HrefToken()];mute=[M.ckey];mute_type=[MUTE_ADMINHELP]' [(muted & MUTE_ADMINHELP)?"style='font-weight: bold'":""]>ADMINHELP</a> "
		body += "<A href='?_src_=holder;[HrefToken()];mute=[M.ckey];mute_type=[MUTE_MHELP]' [(muted & MUTE_MHELP)?"style='font-weight: bold'":""]>MHELP</a> "
		body += "<A href='?_src_=holder;[HrefToken()];mute=[M.ckey];mute_type=[MUTE_DEADCHAT]' [(muted & MUTE_DEADCHAT)?"style='font-weight: bold'":""]>DEADCHAT</a> "

	body += "<br><br>"
	body += "<A href='?_src_=holder;[HrefToken()];jumpto=[REF(M)]'>Jump to</A> "
	body += "<A href='?_src_=holder;[HrefToken()];getmob=[REF(M)]'>Get</A> "
	body += "<A href='?_src_=holder;[HrefToken()];sendmob=[REF(M)]'>Send To</A>"

	body += "<br><br>"
	body += "<A href='?_src_=holder;[HrefToken()];traitor=[REF(M)]'>Traitor Panel</A> "
	body += "<A href='?_src_=holder;[HrefToken()];narrateto=[REF(M)]'>Narrate To</A> "
	body += "<A href='?_src_=holder;[HrefToken()];subtlemessage=[REF(M)]'>Subtle Message</A> "
	body += "<A href='?_src_=holder;[HrefToken()];languagemenu=[REF(M)]'>Language Menu</A>"

	if (M.client)
		if(!isnewplayer(M))
			body += "<br><br>"
			body += "<b>Transformation:</b>"
			body += "<br>"

			//Human
			if(ishuman(M))
				body += "<B>Human</B> "
			else
				body += "<A href='?_src_=holder;[HrefToken()];humanone=[REF(M)]'>Humanize</A> "

			//Monkey
			if(ismonkey(M))
				body += "<B>Monkeyized</B> "
			else
				body += "<A href='?_src_=holder;[HrefToken()];monkeyone=[REF(M)]'>Monkeyize</A> "

			//Corgi
			if(iscorgi(M))
				body += "<B>Corgized</B> "
			else
				body += "<A href='?_src_=holder;[HrefToken()];corgione=[REF(M)]'>Corgize</A> "

			//AI / Cyborg
			if(isAI(M))
				body += "<B>Is an AI</B> "
			else if(ishuman(M))
				body += "<A href='?_src_=holder;[HrefToken()];makeai=[REF(M)]'>Make AI</A> "
				body += "<A href='?_src_=holder;[HrefToken()];makepai=[REF(M)]'>Make PAI</A> "
				body += "<A href='?_src_=holder;[HrefToken()];makerobot=[REF(M)]'>Make Robot</A> "
				body += "<A href='?_src_=holder;[HrefToken()];makealien=[REF(M)]'>Make Alien</A> "
				body += "<A href='?_src_=holder;[HrefToken()];makeslime=[REF(M)]'>Make Slime</A> "
				body += "<A href='?_src_=holder;[HrefToken()];makeblob=[REF(M)]'>Make Blob</A> "

			if(istype(M, /mob/living/simple_animal/cluwne))
				body += "<B>Is a Cluwne</B> "
			else if(ishuman(M))
				body += "<A href='?_src_=holder;[HrefToken()];makecluwne=[REF(M)]'>Make Cluwne</A> "

			//Simple Animals
			if(isanimal(M))
				body += "<A href='?_src_=holder;[HrefToken()];makeanimal=[REF(M)]'>Re-Animalize</A> "
			else
				body += "<A href='?_src_=holder;[HrefToken()];makeanimal=[REF(M)]'>Animalize</A> "

			body += "<br><br>"
			body += "<b>Rudimentary transformation:</b><font size=2><br>These transformations only create a new mob type and copy stuff over. The buttons in 'Transformations' are preferred, when possible.</font><br>"

			body += "<A href='?_src_=holder;[HrefToken()];simplemake=observer;mob=[REF(M)]'>Observer</A> "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=human;mob=[REF(M)]'>Human</A> "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=monkey;mob=[REF(M)]'>Monkey</A> "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=robot;mob=[REF(M)]'>Cyborg</A> "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=cat;mob=[REF(M)]'>Cat</A> "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=runtime;mob=[REF(M)]'>Runtime</A> "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=corgi;mob=[REF(M)]'>Corgi</A> "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=ian;mob=[REF(M)]'>Ian</A> "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=crab;mob=[REF(M)]'>Crab</A> "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=coffee;mob=[REF(M)]'>Coffee</A> "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=shade;mob=[REF(M)]'>Shade</A> "

			body += "<br><b>Slime:</b> <A href='?_src_=holder;[HrefToken()];simplemake=slime;mob=[REF(M)]'>Baby</A> "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=adultslime;mob=[REF(M)]'>Adult</A> "

			body += "<br><b>Alien:</b> <A href='?_src_=holder;[HrefToken()];simplemake=drone;mob=[REF(M)]'>Drone</A> "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=hunter;mob=[REF(M)]'>Hunter</A> "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=sentinel;mob=[REF(M)]'>Sentinel</A> "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=praetorian;mob=[REF(M)]'>Praetorian</A> "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=queen;mob=[REF(M)]'>Queen</A> "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=larva;mob=[REF(M)]'>Larva</A> "

			body += "<br><b>Construct:</b> <A href='?_src_=holder;[HrefToken()];simplemake=constructarmored;mob=[REF(M)]'>Juggernaut</A> "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=constructbuilder;mob=[REF(M)]'>Artificer</A> "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=constructwraith;mob=[REF(M)]'>Wraith</A> "

			body += "<br>"

	if (M.client)
		body += "<br><br>"
		body += "<b>Other actions:</b>"
		body += "<br>"
		body += "<A href='?_src_=holder;[HrefToken()];forcespeech=[REF(M)]'>Forcesay</A> "
		body += "<A href='?_src_=holder;[HrefToken()];tdome1=[REF(M)]'>Thunderdome 1</A> "
		body += "<A href='?_src_=holder;[HrefToken()];tdome2=[REF(M)]'>Thunderdome 2</A> "
		body += "<A href='?_src_=holder;[HrefToken()];tdomeadmin=[REF(M)]'>Thunderdome Admin</A> "
		body += "<A href='?_src_=holder;[HrefToken()];tdomeobserve=[REF(M)]'>Thunderdome Observer</A> "

	body += "<br></body>"

	var/datum/browser/popup = new(usr, "adminplayeropts-[REF(M)]", "<div align='center'>Options for [M.key]</div>", 700, 600)
	popup.set_content(body)
	popup.open(0)

	//usr << browse(body, "window=adminplayeropts-[REF(M)];size=550x515")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Player Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/Game()
	if(!check_rights(0))
		return

	var/dat = {"
		<center><B>Game Panel</B></center><hr>\n
		<A href='?src=[REF(src)];[HrefToken()];c_mode=1'>Change Game Mode</A><br>
		"}
	if(GLOB.master_mode == "secret")
		dat += "<A href='?src=[REF(src)];[HrefToken()];f_secret=1'>(Force Secret Mode)</A><br>"
	if(SSticker.is_mode("dynamic"))
		if(SSticker.current_state <= GAME_STATE_PREGAME)
			dat += "<A href='?src=[REF(src)];[HrefToken()];f_dynamic_roundstart=1'>(Force Roundstart Rulesets)</A><br>"
			if (GLOB.dynamic_forced_roundstart_ruleset.len > 0)
				for(var/datum/dynamic_ruleset/roundstart/rule in GLOB.dynamic_forced_roundstart_ruleset)
					dat += {"<A href='?src=[REF(src)];[HrefToken()];f_dynamic_roundstart_remove=\ref[rule]'>-> [rule.name] <-</A><br>"}
				dat += "<A href='?src=[REF(src)];[HrefToken()];f_dynamic_roundstart_clear=1'>(Clear Rulesets)</A><br>"
			dat += "<A href='?src=[REF(src)];[HrefToken()];f_dynamic_options=1'>(Dynamic mode options)</A><br>"
		else if (SSticker.IsRoundInProgress())
			dat += "<A href='?src=[REF(src)];[HrefToken()];f_dynamic_latejoin=1'>(Force Next Latejoin Ruleset)</A><br>"
			if (SSticker && SSticker.mode && istype(SSticker.mode,/datum/game_mode/dynamic))
				var/datum/game_mode/dynamic/mode = SSticker.mode
				if (mode.forced_latejoin_rule)
					dat += {"<A href='?src=[REF(src)];[HrefToken()];f_dynamic_latejoin_clear=1'>-> [mode.forced_latejoin_rule.name] <-</A><br>"}
			dat += "<A href='?src=[REF(src)];[HrefToken()];f_dynamic_midround=1'>(Execute Midround Ruleset!)</A><br>"
		dat += "<hr/>"
	if(SSticker.IsRoundInProgress())
		dat += "<a href='?src=[REF(src)];[HrefToken()];gamemode_panel=1'>(Game Mode Panel)</a><BR>"

	dat += {"
		<BR>
		<A href='?src=[REF(src)];[HrefToken()];create_object=1'>Create Object</A><br>
		<A href='?src=[REF(src)];[HrefToken()];quick_create_object=1'>Quick Create Object</A><br>
		<A href='?src=[REF(src)];[HrefToken()];create_turf=1'>Create Turf</A><br>
		<A href='?src=[REF(src)];[HrefToken()];create_mob=1'>Create Mob</A><br>
		"}

	if(marked_datum && istype(marked_datum, /atom))
		dat += "<A href='?src=[REF(src)];[HrefToken()];dupe_marked_datum=1'>Duplicate Marked Datum</A><br>"

	usr << browse(dat, "window=admin2;size=210x200")
	return

/////////////////////////////////////////////////////////////////////////////////////////////////admins2.dm merge
//i.e. buttons/verbs


/datum/admins/proc/restart()
	set category = "Server"
	set name = "Reboot World"
	set desc="Restarts the world immediately"
	if (!usr.client.holder)
		return

	var/list/options = list("Regular Restart", "Regular Restart (with delay)", "Hard Restart (No Delay/Feeback Reason)", "Hardest Restart (No actions, just reboot)")
	if(world.TgsAvailable())
		options += "Server Restart (Kill and restart DD)";

	var/rebootconfirm
	if(SSticker.admin_delay_notice)
		if(alert(usr, "Are you sure? An admin has already delayed the round end for the following reason: [SSticker.admin_delay_notice]", "Confirmation", "Yes", "No") == "Yes")
			rebootconfirm = TRUE
	else
		rebootconfirm = TRUE
	if(rebootconfirm)
		var/result = input(usr, "Select reboot method", "World Reboot", options[1]) as null|anything in options
		if(result)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Reboot World") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
			var/init_by = "Initiated by [usr.client.holder.fakekey ? "Admin" : usr.key]."
			switch(result)
				if("Regular Restart")
					SSticker.Reboot(init_by, "admin reboot - by [usr.key] [usr.client.holder.fakekey ? "(stealth)" : ""]", 10)
				if("Regular Restart (with delay)")
					var/delay = input("What delay should the restart have (in seconds)?", "Restart Delay", 5) as num|null
					if(!delay)
						return FALSE
					SSticker.Reboot(init_by, "admin reboot - by [usr.key] [usr.client.holder.fakekey ? "(stealth)" : ""]", delay * 10)
				if("Hard Restart (No Delay, No Feeback Reason)")
					to_chat(world, "World reboot - [init_by]")
					world.Reboot()
				if("Hardest Restart (No actions, just reboot)")
					to_chat(world, "Hard world reboot - [init_by]")
					world.Reboot(fast_track = TRUE)
				if("Server Restart (Kill and restart DD)")
					to_chat(world, "Server restart - [init_by]")
					world.TgsEndProcess()

/datum/admins/proc/end_round()
	set category = "Round"
	set name = "End Round"
	set desc = "Attempts to produce a round end report and then restart the server organically."

	if (!usr.client.holder)
		return
	var/confirm = alert("End the round and  restart the game world?", "End Round", "Yes", "Cancel")
	if(confirm != "Yes")
		return
	SSticker.force_ending = 1
	SSblackbox.record_feedback("tally", "admin_verb", 1, "End Round") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/dynamic_mode_options(mob/user)
	var/dat = {"
		<center><B><h2>Dynamic Mode Options</h2></B></center><hr>
		<br/>
		<h3>Common options</h3>
		<i>All these options can be changed midround.</i> <br/>
		<br/>
		<b>Force extended:</b> - Option is <a href='?src=[REF(src)];[HrefToken()];f_dynamic_force_extended=1'> <b>[GLOB.dynamic_forced_extended ? "ON" : "OFF"]</a></b>.
		<br/>This will force the round to be extended. No rulesets will be drafted. <br/>
		<br/>
		<b>No stacking:</b> - Option is <a href='?src=[REF(src)];[HrefToken()];f_dynamic_no_stacking=1'> <b>[GLOB.dynamic_no_stacking ? "ON" : "OFF"]</b></a>.
		<br/>Unless the threat goes above [GLOB.dynamic_stacking_limit], only one "round-ender" ruleset will be drafted. <br/>
		<br/>
		<b>Forced threat level:</b> Current value : <a href='?src=[REF(src)];[HrefToken()];f_dynamic_forced_threat=1'><b>[GLOB.dynamic_forced_threat_level]</b></a>.
		<br/>The value threat is set to if it is higher than -1.<br/>
		<br/>
		<br/>
		<b>Stacking threeshold:</b> Current value : <a href='?src=[REF(src)];[HrefToken()];f_dynamic_stacking_limit=1'><b>[GLOB.dynamic_stacking_limit]</b></a>.
		<br/>The threshold at which "round-ender" rulesets will stack. A value higher than 100 ensure this never happens. <br/>
		"}

	user << browse(dat, "window=dyn_mode_options;size=900x650")
/datum/admins/proc/announce()
	set category = "Admin"
	set name = "Announce"
	set desc="Announce your desires to the world"
	if(!check_rights(0))
		return

	var/message = capped_multiline_input(usr, "Global message to send:", "Admin Announce")
	if(message)
		if(!check_rights(R_SERVER,0))
			message = adminscrub(message,500)
		to_chat(world, "<span class='adminnotice'><b>[usr.client.holder.fakekey ? "Administrator" : usr.key] Announces:</b></span>\n \t [message]")
		log_admin("Announce: [key_name(usr)] : [message]")
		sendooc2tgs("***[usr.client.holder.fakekey ? "Administrator" : usr.key] Announces:***\n       [message]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Announce") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/set_admin_notice()
	set category = "Adminbus"
	set name = "Set Admin Notice"
	set desc ="Set an announcement that appears to everyone who joins the server. Only lasts this round"
	if(!check_rights(0))
		return

	var/new_admin_notice = capped_multiline_input(usr, "Set a public notice for this round. Everyone who joins the server will see it.\n(Leaving it blank will delete the current notice):","Set Notice",GLOB.admin_notice)
	if(new_admin_notice == null)
		return
	if(new_admin_notice == GLOB.admin_notice)
		return
	if(new_admin_notice == "")
		message_admins("[key_name(usr)] removed the admin notice.")
		log_admin("[key_name(usr)] removed the admin notice:\n[GLOB.admin_notice]")
	else
		message_admins("[key_name(usr)] set the admin notice.")
		log_admin("[key_name(usr)] set the admin notice:\n[new_admin_notice]")
		to_chat(world, "<span class ='adminnotice'><b>Admin Notice:</b>\n \t [new_admin_notice]</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Set Admin Notice") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	GLOB.admin_notice = new_admin_notice
	return

/datum/admins/proc/toggleooc()
	set category = "Server"
	set desc="Toggle dis bitch"
	set name="Toggle OOC"
	toggle_ooc()
	log_admin("[key_name(usr)] toggled OOC.")
	message_admins("[key_name_admin(usr)] toggled OOC.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle OOC", "[GLOB.ooc_allowed ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleoocdead()
	set category = "Server"
	set desc="Toggle dis bitch"
	set name="Toggle Dead OOC"
	toggle_dooc()

	log_admin("[key_name(usr)] toggled OOC.")
	message_admins("[key_name_admin(usr)] toggled Dead OOC.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Dead OOC", "[GLOB.dooc_allowed ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/startnow()
	set category = "Round"
	set desc="Start the round RIGHT NOW"
	set name="Start Now"
	if(SSticker.current_state == GAME_STATE_PREGAME || SSticker.current_state == GAME_STATE_STARTUP)
		SSticker.start_immediately = TRUE
		log_admin("[usr.key] has started the game.")
		var/msg = ""
		if(SSticker.current_state == GAME_STATE_STARTUP)
			msg = " (The server is still setting up, but the round will be \
				started as soon as possible.)"
		message_admins("<font color='blue'>\
			[usr.key] has started the game.[msg]</font>")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Start Now") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return 1
	else
		to_chat(usr, "<font color='red'>Error: Start Now: Game has already started.</font>")

	return 0

/datum/admins/proc/toggleenter()
	set category = "Server"
	set desc="People can't enter"
	set name="Toggle Entering"
	GLOB.enter_allowed = !( GLOB.enter_allowed )
	if (!( GLOB.enter_allowed ))
		to_chat(world, "<B>New players may no longer enter the game.</B>")
	else
		to_chat(world, "<B>New players may now enter the game.</B>")
	log_admin("[key_name(usr)] toggled new player game entering.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] toggled new player game entering.</span>")
	world.update_status()
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Entering", "[GLOB.enter_allowed ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleAI()
	set category = "Server"
	set desc="People can't be AI"
	set name="Toggle AI"
	var/alai = CONFIG_GET(flag/allow_ai)
	CONFIG_SET(flag/allow_ai, !alai)
	if (alai)
		to_chat(world, "<B>The AI job is no longer chooseable.</B>")
	else
		to_chat(world, "<B>The AI job is chooseable now.</B>")
	log_admin("[key_name(usr)] toggled AI allowed.")
	world.update_status()
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle AI", "[!alai ? "Disabled" : "Enabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleaban()
	set category = "Server"
	set desc="Respawn basically"
	set name="Toggle Respawn"
	var/new_nores = !CONFIG_GET(flag/norespawn)
	CONFIG_SET(flag/norespawn, new_nores)
	if (!new_nores)
		to_chat(world, "<B>You may now respawn.</B>")
	else
		to_chat(world, "<B>You may no longer respawn :(</B>")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] toggled respawn to [!new_nores ? "On" : "Off"].</span>")
	log_admin("[key_name(usr)] toggled respawn to [!new_nores ? "On" : "Off"].")
	world.update_status()
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Respawn", "[!new_nores ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/delay()
	set category = "Round"
	set desc="Delay the game start"
	set name="Delay pre-game"

	var/newtime = input("Set a new time in seconds. Set -1 for indefinite delay.","Set Delay",round(SSticker.GetTimeLeft()/10)) as num|null
	if(SSticker.current_state > GAME_STATE_PREGAME)
		return alert("Too late... The game has already started!")
	if(newtime)
		newtime = newtime*10
		SSticker.SetTimeLeft(newtime)
		if(newtime < 0)
			to_chat(world, "<b>The game start has been delayed.</b>")
			log_admin("[key_name(usr)] delayed the round start.")
		else
			to_chat(world, "<b>The game will start in [DisplayTimeText(newtime)].</b>")
			SEND_SOUND(world, sound('sound/ai/default/attention.ogg'))
			log_admin("[key_name(usr)] set the pre-game delay to [DisplayTimeText(newtime)].")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Delay Game Start") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/delay_round_end()
	set category = "Round"
	set desc= "Delay server from rebooting the server after the round has ended"
	set name= "Delay round end"
	if(!SSticker.delay_end)
		SSticker.admin_delay_notice = input(usr, "Enter a reason for delaying the round end", "Round Delay Reason") as null|text
		if(isnull(SSticker.admin_delay_notice))
			return
		for(var/client/admin in GLOB.admins)
			if(check_rights(R_FUN) && !GLOB.battle_royale && admin.tgui_panel && SSticker.current_state == GAME_STATE_FINISHED)
				admin.tgui_panel.give_br_popup()
	else
		if(alert(usr, "Really cancel current round end delay? The reason for the current delay is: \"[SSticker.admin_delay_notice]\"", "Undelay round end", "Yes", "No") != "Yes")
			return
		SSticker.admin_delay_notice = null
	SSticker.delay_end = !SSticker.delay_end
	var/reason = SSticker.delay_end ? "for reason: [SSticker.admin_delay_notice]" : "."//laziness
	var/msg = "[SSticker.delay_end ? "delayed" : "undelayed"] the round end [reason]"
	log_admin("[key_name(usr)] [msg]")
	message_admins("[key_name_admin(usr)] [msg]")
	if(SSticker.ready_for_reboot && !SSticker.delay_end) //we undelayed after standard reboot would occur
		SSticker.standard_reboot()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Delay round end") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/unprison(mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Unprison"
	if (is_centcom_level(M.z))
		SSjob.SendToLateJoin(M)
		message_admins("[key_name_admin(usr)] has unprisoned [key_name_admin(M)]")
		log_admin("[key_name(usr)] has unprisoned [key_name(M)]")
	else
		alert("[M.name] is not prisoned.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Unprison") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

/datum/admins/proc/spawn_atom(object as text)
	set category = "Debug"
	set desc = "(atom path) Spawn an atom"
	set name = "Spawn"

	if(!check_rights(R_SPAWN))
		return

	var/chosen = pick_closest_path(object)
	if(!chosen)
		return
	var/turf/T = get_turf(usr)

	if(ispath(chosen, /turf))
		T.ChangeTurf(chosen)
	else
		var/atom/A = new chosen(T)
		A.flags_1 |= ADMIN_SPAWNED_1

	log_admin("[key_name(usr)] spawned [chosen] at [AREACOORD(usr)]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Spawn Atom") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/podspawn_atom(object as text)
	set category = "Debug"
	set desc = "(atom path) Spawn an atom via supply drop"
	set name = "Podspawn"

	if(!check_rights(R_SPAWN))
		return

	var/chosen = pick_closest_path(object)
	if(!chosen)
		return
	var/turf/T = get_turf(usr)

	if(ispath(chosen, /turf))
		T.ChangeTurf(chosen)
	else
		var/obj/structure/closet/supplypod/centcompod/pod = new()
		var/atom/A = new chosen(pod)
		A.flags_1 |= ADMIN_SPAWNED_1
		new /obj/effect/pod_landingzone(T, pod)

	log_admin("[key_name(usr)] pod-spawned [chosen] at [AREACOORD(usr)]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Podspawn Atom") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/spawn_cargo(object as text)
	set category = "Debug"
	set desc = "(atom path) Spawn a cargo crate"
	set name = "Spawn Cargo"

	if(!check_rights(R_SPAWN))
		return

	var/chosen = pick_closest_path(object, make_types_fancy(subtypesof(/datum/supply_pack)))
	if(!chosen)
		return
	var/datum/supply_pack/S = new chosen
	S.admin_spawned = TRUE
	S.generate(get_turf(usr))

	log_admin("[key_name(usr)] spawned cargo pack [chosen] at [AREACOORD(usr)]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Spawn Cargo") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/show_traitor_panel(mob/M in GLOB.mob_list)
	set category = "Admin"
	set desc = "Edit mobs's memory and role"
	set name = "Show Traitor Panel"

	if(!istype(M))
		to_chat(usr, "This can only be used on instances of type /mob")
		return
	if(!M.mind)
		to_chat(usr, "This mob has no mind!")
		return

	M.mind.traitor_panel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Traitor Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/toggletintedweldhelmets()
	set category = "Debug"
	set desc="Reduces view range when wearing welding helmets"
	set name="Toggle tinted welding helmes"
	GLOB.tinted_weldhelh = !( GLOB.tinted_weldhelh )
	if (GLOB.tinted_weldhelh)
		to_chat(world, "<B>The tinted_weldhelh has been enabled!</B>")
	else
		to_chat(world, "<B>The tinted_weldhelh has been disabled!</B>")
	log_admin("[key_name(usr)] toggled tinted_weldhelh.")
	message_admins("[key_name_admin(usr)] toggled tinted_weldhelh.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Tinted Welding Helmets", "[GLOB.tinted_weldhelh ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleguests()
	set category = "Server"
	set desc="Guests can't enter"
	set name="Toggle guests"
	var/new_guest_ban = !CONFIG_GET(flag/guest_ban)
	CONFIG_SET(flag/guest_ban, new_guest_ban)
	if (new_guest_ban)
		to_chat(world, "<B>Guests may no longer enter the game.</B>")
	else
		to_chat(world, "<B>Guests may now enter the game.</B>")
	log_admin("[key_name(usr)] toggled guests game entering [!new_guest_ban ? "" : "dis"]allowed.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] toggled guests game entering [!new_guest_ban ? "" : "dis"]allowed.</span>")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Guests", "[!new_guest_ban ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/output_ai_laws()
	var/ai_number = 0
	for(var/i in GLOB.silicon_mobs)
		var/mob/living/silicon/S = i
		ai_number++
		var/message = ""
		if(isAI(S))
			message += "<b>AI [key_name(S, usr)]'s laws:</b>"
		else if(iscyborg(S))
			var/mob/living/silicon/robot/R = S
			message += "<b>CYBORG [key_name(S, usr)] [R.connected_ai?"(Slaved to: [key_name(R.connected_ai)])":"(Independent)"]: laws:</b>"
		else if (ispAI(S))
			message += "<b>pAI [key_name(S, usr)]'s laws:</b>"
		else
			message += "<b>SOMETHING SILICON [key_name(S, usr)]'s laws:</b>"

		message += "<br>"

		if (S.laws == null)
			message += "[key_name(S, usr)]'s laws are null?? Contact a coder."
		else
			message += jointext(S.laws.get_law_list(include_zeroth = TRUE), "<br>")

		to_chat(usr, message)

	if(!ai_number)
		to_chat(usr, "<b>No AIs located</b>" )

/datum/admins/proc/output_all_devil_info()
	var/devil_number = 0
	for(var/datum/mind/D in SSticker.mode.devils)
		devil_number++
		var/datum/antagonist/devil/devil = D.has_antag_datum(/datum/antagonist/devil)
		to_chat(usr, "Devil #[devil_number]:<br><br>" + devil.printdevilinfo())
	if(!devil_number)
		to_chat(usr, "<b>No Devils located</b>" )

/datum/admins/proc/output_devil_info(mob/living/M)
	if(is_devil(M))
		var/datum/antagonist/devil/devil = M.mind.has_antag_datum(/datum/antagonist/devil)
		to_chat(usr, devil.printdevilinfo())
	else
		to_chat(usr, "<b>[M] is not a devil.")

/datum/admins/proc/manage_free_slots()
	if(!check_rights())
		return
	var/datum/browser/browser = new(usr, "jobmanagement", "Manage Free Slots", 520)
	var/list/dat = list()
	var/count = 0

	if(!SSjob.initialized)
		alert(usr, "You cannot manage jobs before the job subsystem is initialized!")
		return

	dat += "<table>"

	for(var/j in SSjob.occupations)
		var/datum/job/job = j
		count++
		var/J_title = html_encode(job.title)
		var/J_opPos = html_encode(job.total_positions - (job.total_positions - job.current_positions))
		var/J_totPos = html_encode(job.total_positions)
		dat += "<tr><td>[J_title]:</td> <td>[J_opPos]/[job.total_positions < 0 ? " (unlimited)" : J_totPos]"

		dat += "</td>"
		dat += "<td>"
		if(job.total_positions >= 0)
			dat += "<A href='?src=[REF(src)];[HrefToken()];customjobslot=[job.title]'>Custom</A> | "
			dat += "<A href='?src=[REF(src)];[HrefToken()];addjobslot=[job.title]'>Add 1</A> | "
			if(job.total_positions > job.current_positions)
				dat += "<A href='?src=[REF(src)];[HrefToken()];removejobslot=[job.title]'>Remove</A> | "
			else
				dat += "Remove | "
			dat += "<A href='?src=[REF(src)];[HrefToken()];unlimitjobslot=[job.title]'>Unlimit</A></td>"
		else
			dat += "<A href='?src=[REF(src)];[HrefToken()];limitjobslot=[job.title]'>Limit</A></td>"

	browser.height = min(100 + count * 20, 650)
	browser.set_content(dat.Join())
	browser.open()

/datum/admins/proc/create_or_modify_area()
	set category = "Debug"
	set name = "Create or modify area"
	create_area(usr)

//
//
//ALL DONE
//*********************************************************************************************************
//TO-DO:
//
//

//RIP ferry snowflakes

//Kicks all the clients currently in the lobby. The second parameter (kick_only_afk) determins if an is_afk() check is ran, or if all clients are kicked
//defaults to kicking everyone (afk + non afk clients in the lobby)
//returns a list of ckeys of the kicked clients
/proc/kick_clients_in_lobby(message, kick_only_afk = 0)
	var/list/kicked_client_names = list()
	for(var/client/C in GLOB.clients)
		if(isnewplayer(C.mob))
			if(kick_only_afk && !C.is_afk()) //Ignore clients who are not afk
				continue
			if(message)
				to_chat(C, message)
			kicked_client_names.Add("[C.key]")
			qdel(C)
	return kicked_client_names

//returns 1 to let the dragdrop code know we are trapping this event
//returns 0 if we don't plan to trap the event
/datum/admins/proc/cmd_ghost_drag(mob/dead/observer/frommob, mob/tomob)

	//this is the exact two check rights checks required to edit a ckey with vv.
	if (!check_rights(R_VAREDIT,0) || !check_rights(R_SPAWN|R_DEBUG,0))
		return 0

	if (!frommob.ckey)
		return 0

	var/question = ""
	if (tomob.ckey)
		question = "This mob already has a user ([tomob.key]) in control of it! "
	question += "Are you sure you want to place [frommob.name]([frommob.key]) in control of [tomob.name]?"

	var/ask = alert(question, "Place ghost in control of mob?", "Yes", "No")
	if (ask != "Yes")
		return 1

	if (!frommob || !tomob) //make sure the mobs don't go away while we waited for a response
		return 1

	tomob.ghostize(FALSE)

	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has put [frommob.key] in control of [tomob.name].</span>")
	log_admin("[key_name(usr)] stuffed [frommob.key] into [tomob.name].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Ghost Drag Control")

	tomob.ckey = frommob.ckey
	qdel(frommob)

	return 1

/client/proc/adminGreet(logout)
	if(SSticker.HasRoundStarted())
		var/string
		if(logout && CONFIG_GET(flag/announce_admin_logout))
			string = pick(
				"Admin logout: [key_name(src)]")
		else if(!logout && CONFIG_GET(flag/announce_admin_login) && (prefs.toggles & PREFTOGGLE_ANNOUNCE_LOGIN))
			string = pick(
				"Admin login: [key_name(src)]")
		if(string)
			message_admins("[string]")
