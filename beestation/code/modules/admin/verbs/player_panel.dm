
/datum/admins/show_player_panel(mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Show Player Panel"
	set desc="Edit player (respawn, ban, heal, etc)"

	if(!check_rights())
		return

	log_admin("[key_name(usr)] checked the individual player panel for [key_name(M)][isobserver(usr)?"":" while in game"].")

	if(!M)
		to_chat(usr, "You seem to be selecting a mob that doesn't exist anymore.")
		return

	var/body = "<body>Options panel for <b>[M]</b>"
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
		var/beecoins = M.client.get_beecoin_count()
		body += "<br><b>BeeCoins</b>: [beecoins] "
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
		body += "<A href='?_src_=holder;[HrefToken()];mute=[M.ckey];mute_type=[MUTE_OOC]'> [(muted & MUTE_OOC)?"style='font-weight: bold'":""]OOC</a> "
		body += "<A href='?_src_=holder;[HrefToken()];mute=[M.ckey];mute_type=[MUTE_PRAY]' [(muted & MUTE_PRAY)?"style='font-weight: bold'":""]>PRAY</a> "
		body += "<A href='?_src_=holder;[HrefToken()];mute=[M.ckey];mute_type=[MUTE_ADMINHELP]' [(muted & MUTE_ADMINHELP)?"style='font-weight: bold'":""]>ADMINHELP</a> "
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
