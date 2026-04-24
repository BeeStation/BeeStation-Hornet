/**
  * Run when a client is put in this mob or reconnets to byond and their client was on this mob
  *
  * Things it does:
  * * call set_eye() to manually manage atom/list/eye_users
  * * Adds player to player_list
  * * sets lastKnownIP
  * * sets computer_id
  * * logs the login
  * * tells the world to update it's status (for player count)
  * * create mob huds for the mob if needed
  * * reset next_move to 1
  * * Set statobj to our mob
  * * NOT the parent call. The only unique thing it does is a very obtuse move op, see the comment lower down
  * * parent call
  * * if the client exists set the perspective to the mob loc
  * * call on_log on the loc (sigh)
  * * reload the huds for the mob
  * * reload all full screen huds attached to this mob
  * * load any global alternate apperances
  * * sync the mind datum via sync_mind()
  * * call any client login callbacks that exist
  * * grant any actions the mob has to the client
  * * calls [auto_deadmin_on_login](mob.html#proc/auto_deadmin_on_login)
  * * send signal COMSIG_MOB_CLIENT_LOGIN
  * * client can be deleted mid-execution of this proc, chiefly on parent calls, with lag
  * * attaches the ash listener element so clients can hear weather
  */
/mob/Login()
	if(!client)
		return FALSE
	// This can happen in some cases, mainly when a client logs in with the same CKEY as another client
	// Both clients will get deleted which should ensure nobody uses a mob they don't have access to...
	if(!istype(src, /mob/dead/new_player/pre_auth) && !client.logged_in)
		var/msg = "/mob/Login() was called on [key_name(src)] without the assigned client being authenticated! Possible auth bypass! Caller: [key_name(usr)]"
		var/report_info = "Round ID: [GLOB.round_id] \n\
		CKEY: [client.ckey] \n\
		Key: [client.key] \n\
		BYOND Authenticated Key: [client.byond_authenticated_key] \n\
		External UID: [client.external_uid] \n\
		Mob Type: [src.type] \n\
		Mob Name: [src.name]"
		log_access("[msg]\n[report_info]")
		send2tgs("Auth", "[msg]\n[report_info]")
		message_admins(msg) // just so it's more likely to get reported to maints
		client << browse(HTML_SKELETON_TITLE("Login Error", "<h2>Danger!</h2><p>You were logged into your mob without fully authenticating. Please report this issue to maintainers.</p><br><br><pre>[report_info]</pre>"))
		spawn(1)
			qdel(client)
		. = FALSE
		CRASH(msg)
	// set_eye() is important here, because your eye doesn't know if you're using them as your eye
	// FALSE when weakref doesn't exist, to prevent using their current eye
	client.set_eye(client.eye, client.eye_weakref?.resolve() || FALSE)
	add_to_player_list()
	lastKnownIP	= client.address
	computer_id	= client.computer_id
	log_access("Mob Login: [key_name(src)] was assigned to a [type]")
	world.update_status()
	client.screen = list() //remove hud items just in case
	client.images = list()
	client.set_right_click_menu_mode(shift_to_open_context_menu)

	if(!hud_used)
		create_mob_hud() // creating a hud will add it to the client's screen, which can process a disconnect
		if(!client)
			return FALSE

	if(hud_used)
		hud_used.show_hud(hud_used.hud_version) // see above, this can process a disconnect
		if(!client)
			return FALSE
		hud_used.update_ui_style(ui_style2icon(client.prefs?.read_player_preference(/datum/preference/choiced/ui_style)))

	next_move = 1

	client.statobj = src

	// DO NOT CALL PARENT HERE
	// BYOND's internal implementation of login does two things
	// 1: Set statobj to the mob being logged into (We got this covered)
	// 2: And I quote "If the mob has no location, place it near (1,1,1) if possible"
	// See, near is doing an agressive amount of legwork there
	// What it actually does is takes the area that (1,1,1) is in, and loops through all those turfs
	// If you successfully move into one, it stops
	// Because we want Move() to mean standard movements rather then just what byond treats it as (ALL moves)
	// We don't allow moves from nullspace -> somewhere. This means the loop has to iterate all the turfs in (1,1,1)'s area
	// For us, (1,1,1) is a space tile. This means roughly 200,000! calls to Move()
	// You do not want this

	if(!client)
		return FALSE

	//We do this here to prevent hanging refs from ghostize or whatever, since if we were in another mob before this'll take care of it
	clear_important_client_contents(client)
	enable_client_mobs_in_contents(client)

	SEND_SIGNAL(src, COMSIG_MOB_LOGIN)

	if (key != client.key)
		key = client.key
	reset_perspective(loc)

	if(loc)
		loc.on_log(TRUE)

	//readd this mob's HUDs (antag, med, etc)
	reload_huds()

	reload_fullscreen() // Reload any fullscreen overlays this mob has.

	add_click_catcher()

	sync_mind()

	//Reload alternate appearances
	for(var/v in GLOB.active_alternate_appearances)
		if(!v)
			continue
		var/datum/atom_hud/alternate_appearance/AA = v
		AA.onNewMob(src)

	update_client_colour()
	update_mouse_pointer()
	if(client)
		if(client.view_size)
			client.view_size.resetToDefault(getScreenSize(src))	// Sets the defaul view_size because it can be different to what it was on the lobby.
		else
			client.change_view(getScreenSize(src)) // Resets the client.view in case it was changed.

		//Reset verb information, give verbs accessible to the mob.
		if(client.tgui_panel)
			client.tgui_panel.set_verb_infomation(client)

		if(client.player_details)
			if(client.player_details.player_actions.len)
				for(var/datum/action/A in client.player_details.player_actions)
					A.Grant(src)

			for(var/foo in client.player_details.post_login_callbacks)
				var/datum/callback/CB = foo
				CB.Invoke()
			log_played_names(client.ckey,name,real_name)
		auto_deadmin_on_login()

	//Sort verbs
	add_verb(verbs.Copy(), TRUE)	//verbs.Copy() because otherwise you can't see the list

	//Add the move relay
	AddComponent(/datum/component/moved_relay)

	log_message("Client [key_name(src)] has taken ownership of mob [src]([src.type])", LOG_OWNERSHIP)
	SEND_SIGNAL(src, COMSIG_MOB_CLIENT_LOGIN, client)

	AddElement(/datum/element/weather_listener, /datum/weather/ash_storm, ZTRAIT_ASHSTORM, GLOB.ash_storm_sounds)
	AddElement(/datum/element/weather_listener, /datum/weather/rad_storm, ZTRAIT_STATION, GLOB.rad_storm_sounds)

	// Set mouse pointer
	client.mouse_override_icon = null
	update_mouse_pointer()

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MOB_LOGGED_IN, src)

	return TRUE

/**
  * Checks if the attached client is an admin and may deadmin them
  *
  * Configs:
  * * flag/auto_deadmin_players
  * * client?.prefs?.read_player_preference(/datum/preference/toggle/deadmin_always)
  * * User is antag and flag/auto_deadmin_antagonists or client?.prefs?.read_player_preference(/datum/preference/toggle/deadmin_antagonist)
  * * or if their job demands a deadminning SSjob.handle_auto_deadmin_roles()
  *
  * Called from [login](mob.html#proc/Login)
  */
/mob/proc/auto_deadmin_on_login() //return true if they're not an admin at the end.
	if(!client?.holder)
		return TRUE
	if(CONFIG_GET(flag/auto_deadmin_players) || client?.prefs?.read_player_preference(/datum/preference/toggle/deadmin_always))
		return client.holder.auto_deadmin()
	if(mind.has_antag_datum(/datum/antagonist) && (CONFIG_GET(flag/auto_deadmin_antagonists) || client.prefs?.read_player_preference(/datum/preference/toggle/deadmin_antagonist)))
		return client.holder.auto_deadmin()
	if(job)
		return SSjob.handle_auto_deadmin_roles(client, job)

