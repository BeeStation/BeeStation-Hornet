#define LINKIFY_READY(string, value) "<a href='byond://?src=[REF(src)];ready=[value]'>[string]</a>"

/mob/dead/new_player
	flags_1 = NONE
	invisibility = INVISIBILITY_ABSTRACT
	density = FALSE
	stat = DEAD
	shift_to_open_context_menu = FALSE

/mob/dead/new_player/authenticated
	var/ready = PLAYER_NOT_READY
	var/spawning = 0//Referenced when you want to delete the new_player later on in the code.
	var/mob/living/new_character	//for instant transfer once the round is set up
	///Used to make sure someone doesn't get spammed with messages if they're ineligible for roles.
	var/ineligible_for_roles = FALSE

/mob/dead/new_player/Initialize(mapload)
	if(client && SSticker.state == GAME_STATE_STARTUP)
		var/atom/movable/screen/splash/S = new(null, client, TRUE, TRUE)
		S.Fade(TRUE)

	if(length(GLOB.newplayer_start))
		forceMove(pick(GLOB.newplayer_start))
	else
		forceMove(locate(1,1,1))

	. = ..()

/mob/dead/new_player/authenticated/Initialize(mapload)
	. = ..()
	GLOB.auth_new_player_list += src

/mob/dead/new_player/authenticated/Destroy()
	GLOB.auth_new_player_list -= src
	return ..()

/mob/dead/new_player/mob_negates_gravity()
	return TRUE //no need to calculate if they have gravity.

/mob/dead/new_player/prepare_huds()
	return

/mob/dead/new_player/authenticated/proc/new_player_panel()
	if (client?.interviewee)
		return

	var/datum/asset/asset_datum = get_asset_datum(/datum/asset/simple/lobby)
	asset_datum.send(client)
	var/output = "<center><p><a href='byond://?src=[REF(src)];show_preferences=1'>Setup Character</a></p>"

	if(SSticker.current_state <= GAME_STATE_PREGAME)
		switch(ready)
			if(PLAYER_NOT_READY)
				output += "<p>\[ [LINKIFY_READY("Ready", PLAYER_READY_TO_PLAY)] | <b>Not Ready</b> | [LINKIFY_READY("Observe", PLAYER_READY_TO_OBSERVE)] \]</p>"
			if(PLAYER_READY_TO_PLAY)
				output += "<p>\[ <b>Ready</b> | [LINKIFY_READY("Not Ready", PLAYER_NOT_READY)] | [LINKIFY_READY("Observe", PLAYER_READY_TO_OBSERVE)] \]</p>"
			if(PLAYER_READY_TO_OBSERVE)
				output += "<p>\[ [LINKIFY_READY("Ready", PLAYER_READY_TO_PLAY)] | [LINKIFY_READY("Not Ready", PLAYER_NOT_READY)] | <b> Observe </b> \]</p>"
	else
		output += "<p><a href='byond://?src=[REF(src)];manifest=1'>View the Crew Manifest</a></p>"
		output += "<p><a href='byond://?src=[REF(src)];late_join=1'>Join Game!</a></p>"
		output += "<p>[LINKIFY_READY("Observe", PLAYER_READY_TO_OBSERVE)]</p>"

	if(!IS_GUEST_KEY(src.key))
		if (SSdbcore.Connect())
			var/isadmin = FALSE
			if(client?.holder)
				isadmin = TRUE
			var/datum/db_query/query_get_new_polls = SSdbcore.NewQuery({"
				SELECT id FROM [format_table_name("poll_question")]
				WHERE (adminonly = 0 OR :isadmin = 1)
				AND Now() BETWEEN starttime AND endtime
				AND deleted = 0
				AND id NOT IN (
					SELECT pollid FROM [format_table_name("poll_vote")]
					WHERE ckey = :ckey
					AND deleted = 0
				)
				AND id NOT IN (
					SELECT pollid FROM [format_table_name("poll_textreply")]
					WHERE ckey = :ckey
					AND deleted = 0
				)
			"}, list("isadmin" = isadmin, "ckey" = ckey))
			var/rs = REF(src)
			if(!query_get_new_polls.Execute())
				qdel(query_get_new_polls)
				return
			if(query_get_new_polls.NextRow())
				output += "<p><b><a href='byond://?src=[rs];showpoll=1'>Show Player Polls</A> (NEW!)</b></p>"
			else
				output += "<p><a href='byond://?src=[rs];showpoll=1'>Show Player Polls</A></p>"
			qdel(query_get_new_polls)
			if(QDELETED(src))
				return

	output += "</center>"

	var/datum/browser/popup = new(src, "playersetup", "<div align='center'>New Player Options</div>", 250, 265)
	popup.set_window_options("can_close=0")
	popup.set_content(output)
	popup.open(FALSE)

/mob/dead/new_player/Topic(href, href_list[])
	return FALSE

/mob/dead/new_player/authenticated/Topic(href, href_list[])
	if(src != usr)
		return 0

	if(!client)
		return 0

	if(client.interviewee)
		return FALSE

	//Determines Relevent Population Cap
	var/relevant_cap
	var/hpc = CONFIG_GET(number/hard_popcap)
	var/epc = CONFIG_GET(number/extreme_popcap)
	if(hpc && epc)
		relevant_cap = min(hpc, epc)
	else
		relevant_cap = max(hpc, epc)

	if(href_list["show_preferences"])
		var/datum/preferences/preferences = client.prefs
		preferences.current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES
		preferences.update_static_data(usr)
		preferences.ui_interact(usr)
		return 1

	if(href_list["ready"])
		var/tready = text2num(href_list["ready"])
		//Avoid updating ready if we're after PREGAME (they should use latejoin instead)
		//This is likely not an actual issue but I don't have time to prove that this
		//no longer is required
		if(SSticker.current_state <= GAME_STATE_PREGAME)
			ready = tready
		//if it's post initialisation and they're trying to observe we do the needful
		if(!SSticker.current_state < GAME_STATE_PREGAME && tready == PLAYER_READY_TO_OBSERVE)
			ready = tready
			make_me_an_observer()
			return

	if(href_list["refresh"])
		src << browse(null, "window=playersetup") //closes the player setup window
		new_player_panel()

	if(href_list["late_join"])
		if(!SSticker || !SSticker.IsRoundInProgress())
			to_chat(usr, span_danger("The round is either not ready, or has already finished..."))
			return

		if(href_list["late_join"] == "override")
			LateChoices()
			return

		if(SSticker.queued_players.len || (relevant_cap && living_player_count() >= relevant_cap))
			if(IS_PATRON(src.ckey) || is_admin(src.ckey))
				LateChoices()
				return
			to_chat(usr, span_danger("[CONFIG_GET(string/hard_popcap_message)]"))

			var/queue_position = SSticker.queued_players.Find(usr)
			if(queue_position == 1)
				to_chat(usr, span_notice("You are next in line to join the game. You will be notified when a slot opens up."))
			else if(queue_position)
				to_chat(usr, span_notice("There are [queue_position-1] players in front of you in the queue to join the game."))
			else
				SSticker.queued_players += usr
				to_chat(usr, span_notice("You have been added to the queue to join the game. Your position in queue is [SSticker.queued_players.len]."))
			return
		LateChoices()

	if(href_list["manifest"])
		ViewManifest()

	if(href_list["SelectedJob"])
		if(!SSticker || !SSticker.IsRoundInProgress())
			to_chat(usr, span_danger("The round is either not ready, or has already finished..."))
			return

		if(!GLOB.enter_allowed)
			to_chat(usr, span_notice("There is an administrative lock on entering the game!"))
			return

		if(SSticker.queued_players.len && !is_admin(ckey(key)) && !IS_PATRON(ckey(key)))
			if((living_player_count() >= relevant_cap) || (src != SSticker.queued_players[1]))
				to_chat(usr, span_warning("Server is full."))
				return

		AttemptLateSpawn(href_list["SelectedJob"])
		return

	else if(!href_list["late_join"])
		new_player_panel()

	if(href_list["showpoll"])
		handle_player_polling()
		return

	if(href_list["viewpoll"])
		var/datum/poll_question/poll = locate(href_list["viewpoll"]) in GLOB.active_polls
		poll_player(poll)

	if(href_list["votepollref"])
		var/datum/poll_question/poll = locate(href_list["votepollref"]) in GLOB.active_polls
		vote_on_poll_handler(poll, href_list)

//When you cop out of the round (NB: this HAS A SLEEP FOR PLAYER INPUT IN IT)
/mob/dead/new_player/authenticated/proc/make_me_an_observer(force_observe=FALSE)
	if(QDELETED(src) || !src.client)
		ready = PLAYER_NOT_READY
		return FALSE

	var/this_is_like_playing_right = "Yes"
	if(!force_observe)
		this_is_like_playing_right = tgui_alert(src, "Are you sure you wish to observe? You will not be able to play this round!", "Player Setup", list("Yes", "No"))

	if(QDELETED(src) || !src.client)
		ready = PLAYER_NOT_READY
		return FALSE

	if(this_is_like_playing_right != "Yes")
		ready = PLAYER_NOT_READY
		src << browse(null, "window=playersetup") //closes the player setup window
		new_player_panel()
		return FALSE

	var/mob/dead/observer/observer = new()
	spawning = TRUE

	observer.started_as_observer = TRUE
	close_spawn_windows()
	var/obj/effect/landmark/observer_start/O = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list
	to_chat(src, span_notice("Now teleporting."))
	if (O)
		observer.forceMove(O.loc)
	else
		to_chat(src, span_notice("Teleporting failed. Ahelp an admin please"))
		stack_trace("There's no freaking observer landmark available on this map or you're making observers before the map is initialised")
	observer.key = key
	observer.client = client
	observer.set_ghost_appearance()
	if(observer.client && observer.client.prefs)
		observer.real_name = observer.client.prefs.read_character_preference(/datum/preference/name/real_name)
		observer.name = observer.real_name
	observer.update_icon()
	observer.stop_sound_channel(CHANNEL_LOBBYMUSIC)
	QDEL_NULL(mind)
	qdel(src)
	return TRUE

/proc/get_job_unavailable_error_message(retval, jobtitle)
	switch(retval)
		if(JOB_AVAILABLE)
			return "[jobtitle] is available."
		if(JOB_UNAVAILABLE_GENERIC)
			return "[jobtitle] is unavailable."
		if(JOB_UNAVAILABLE_BANNED)
			return "You are currently banned from [jobtitle]."
		if(JOB_UNAVAILABLE_PLAYTIME)
			return "You do not have enough relevant playtime for [jobtitle]."
		if(JOB_UNAVAILABLE_ACCOUNTAGE)
			return "Your account is not old enough for [jobtitle]."
		if(JOB_UNAVAILABLE_SLOTFULL)
			return "[jobtitle] is already filled to capacity."
		if(JOB_UNAVAILABLE_LOCKED)
			return "[jobtitle] is locked by the system."
	return "Error: Unknown job availability."

/mob/dead/new_player/authenticated/proc/IsJobUnavailable(rank, latejoin = FALSE)
	var/datum/job/job = SSjob.GetJob(rank)
	if(!job)
		return JOB_UNAVAILABLE_GENERIC
	if(job.lock_flags)
		return JOB_UNAVAILABLE_LOCKED
	if(!job.has_space())
		if(job.title == JOB_NAME_ASSISTANT)
			//Newbies can always be assistants
			if(isnum_safe(client.player_age) && client.player_age <= 14)
				return JOB_AVAILABLE
			// If there are other jobs that this user can select, then the assistant is unavailable
			// If the user has no other choices, then we will display the assistant
			for(var/datum/job/J in SSjob.occupations)
				if(J && J.title != job.title && IsJobUnavailable(J.title, latejoin) == JOB_AVAILABLE)
					return JOB_UNAVAILABLE_SLOTFULL
		else
			return JOB_UNAVAILABLE_SLOTFULL
	if(is_banned_from(ckey, rank))
		return JOB_UNAVAILABLE_BANNED
	if(QDELETED(src))
		return JOB_UNAVAILABLE_GENERIC
	if(!job.player_old_enough(client))
		return JOB_UNAVAILABLE_ACCOUNTAGE
	if(job.required_playtime_remaining(client))
		return JOB_UNAVAILABLE_PLAYTIME
	if(latejoin && !job.special_check_latejoin(client))
		return JOB_UNAVAILABLE_GENERIC
	return JOB_AVAILABLE

/mob/dead/new_player/authenticated/proc/AttemptLateSpawn(rank)
	var/error = IsJobUnavailable(rank)
	if(error != JOB_AVAILABLE)
		tgui_alert(src, get_job_unavailable_error_message(error, rank))
		return FALSE

	if(SSticker.late_join_disabled)
		tgui_alert(src, "An administrator has disabled late join spawning.")
		return FALSE

	var/arrivals_docked = TRUE
	if(SSshuttle.arrivals)
		close_spawn_windows()	//In case we get held up
		if(SSshuttle.arrivals.damaged && CONFIG_GET(flag/arrivals_shuttle_require_safe_latejoin))
			tgui_alert(src, "The arrivals shuttle is currently malfunctioning! You cannot join.")
			return FALSE

		if(CONFIG_GET(flag/arrivals_shuttle_require_undocked))
			SSshuttle.arrivals.RequireUndocked(src)
		arrivals_docked = SSshuttle.arrivals.mode != SHUTTLE_CALL

	//Remove the player from the join queue if he was in one and reset the timer
	SSticker.queued_players -= src
	SSticker.queue_delay = 4

	SSjob.AssignRole(src, rank, 1)

	var/mob/living/character = create_character(TRUE)	//creates the human and transfers vars and mind
	var/equip = SSjob.EquipRank(character, rank, TRUE)
	if(isliving(equip))	//Borgs get borged in the equip, so we need to make sure we handle the new mob.
		character = equip

	var/datum/job/job = SSjob.GetJob(rank)

	if(job && !job.override_latejoin_spawn(character))
		SSjob.SendToLateJoin(character)
		if(!arrivals_docked)
			var/atom/movable/screen/splash/Spl = new(null, character.client, TRUE)
			Spl.Fade(TRUE)
			character.playsound_local(get_turf(character), 'sound/voice/welcomeBee.ogg', 50)

		character.update_parallax_teleport()

	SSticker.minds += character.mind

	var/mob/living/carbon/human/humanc
	if(ishuman(character))
		humanc = character	//Let's retypecast the var to be human,

	if(humanc)	//These procs all expect humans
		if(SSshuttle.arrivals)
			SSshuttle.arrivals.QueueAnnounce(humanc, rank)
		else
			AnnounceArrival(humanc, rank)
		AddEmploymentContract(humanc)
		if(GLOB.highlander)
			to_chat(humanc, span_userdanger("<i>THERE CAN BE ONLY ONE!!!</i>"))
			humanc.make_scottish()

		if(GLOB.summon_guns_triggered)
			give_guns(humanc)
		if(GLOB.summon_magic_triggered)
			give_magic(humanc)
		if(GLOB.curse_of_madness_triggered)
			give_madness(humanc, GLOB.curse_of_madness_triggered)

		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CREWMEMBER_JOINED, humanc, rank)

	GLOB.joined_player_list += character.ckey

	//Borgs aren't allowed to be antags. Will need to be tweaked if we get true latejoin ais.
	if(CONFIG_GET(flag/allow_latejoin_antagonists) && humanc)
		SSdynamic.on_player_latejoin(humanc)

	if(CONFIG_GET(flag/roundstart_traits))
		SSquirks.AssignQuirks(character.mind, character.client, TRUE)

	if(humanc)
		GLOB.manifest.inject(humanc)
	log_manifest(character.mind.key,character.mind,character,latejoin = TRUE)

/mob/dead/new_player/authenticated/proc/AddEmploymentContract(mob/living/carbon/human/employee)
	//TODO:  figure out a way to exclude wizards/nukeops/demons from this.
	for(var/C in GLOB.employmentCabinets)
		var/obj/structure/filingcabinet/employment/employmentCabinet = C
		if(!employmentCabinet.virgin)
			employmentCabinet.addFile(employee)


/*
	Ported from yogs: https://github.com/yogstation13/Yogstation-TG/blob/master/yogstation/code/modules/mob/dead/new_player/new_player.dm
*/

/mob/dead/new_player/authenticated/proc/LateChoices()
	var/list/dat = list("<div class='notice'>Round Duration: [DisplayTimeText(world.time - SSticker.round_start_time)]</div>")
	if(SSjob.prioritized_jobs.len > 0)
		dat+="<div class='priority' style='text-align:center'>Jobs in Green have been prioritized by the Head of Personnel.<br>Please consider joining the game as that role.</div>"
	if(SSshuttle.emergency)
		switch(SSshuttle.emergency.mode)
			if(SHUTTLE_ESCAPE)
				dat += "<div class='notice red'>The station has been evacuated.</div><br>"
			if(SHUTTLE_CALL)
				if(!SSshuttle.canRecall())
					dat += "<div class='notice red'>The station is currently undergoing evacuation procedures.</div><br>"
	for(var/datum/job/prioritized_job in SSjob.prioritized_jobs)
		if(!prioritized_job.has_space())
			SSjob.prioritized_jobs -= prioritized_job
	dat += "<table><tr><td valign='top'>"
	var/column_counter = 0
	for(var/datum/department_group/each_dept as anything in SSdepartment.sorted_department_for_latejoin)
		var/dept_name = each_dept.pref_category_name
		var/cat_color = each_dept.dept_colour || "#ff46c7" // failsafe colour
		dat += "<fieldset style='width: 185px; border: 2px solid [cat_color]; display: inline'>"
		dat += "<legend align='center' style='color: [cat_color]'>[dept_name]</legend>"
		var/list/valid_jobs = list()
		for(var/job in each_dept.jobs)
			var/datum/job/job_datum = SSjob.name_occupations[job]
			if(job_datum && IsJobUnavailable(job_datum.title, TRUE) == JOB_AVAILABLE)
				var/command_bold = ""
				if(each_dept.dept_id == DEPT_NAME_COMMAND || (job in each_dept.leaders))
					command_bold = " command"
				if(job_datum in SSjob.prioritized_jobs)
					valid_jobs += "<a class='job[command_bold]' href='byond://?src=[REF(src)];SelectedJob=[job_datum.title]'>[span_priority("[job_datum.title] ([job_datum.current_positions])")]</a>"
				else
					valid_jobs += "<a class='job[command_bold]' href='byond://?src=[REF(src)];SelectedJob=[job_datum.title]'>[job_datum.title] ([job_datum.current_positions])</a>"
		if(!valid_jobs.len)
			valid_jobs += span_nopositions("No positions open.")
		dat += jointext(valid_jobs, "")
		dat += "</fieldset><br>"
		column_counter++
		if(column_counter > 0 && (column_counter % 3 == 0))
			dat += "</td><td valign='top'>"
	dat += "</td></tr></table></center>"
	dat += "</div></div>"
	var/datum/browser/popup = new(src, "latechoices", "Choose Profession", 680, 580)
	popup.add_stylesheet("playeroptions", 'html/browser/playeroptions.css')
	popup.set_content(jointext(dat, ""))
	popup.open(FALSE) // 0 is passed to open so that it doesn't use the onclose() proc

/// Creates, assigns and returns the new_character to spawn as. Assumes a valid mind.assigned_role exists.
/mob/dead/new_player/authenticated/proc/create_character(transfer_after)
	spawning = TRUE
	close_spawn_windows()

	var/mob/living/carbon/human/H = new(loc)

	H.apply_prefs_job(client, SSjob.GetJob(mind.assigned_role))
	if(QDELETED(src) || !client)
		return // Disconnected while checking for the appearance ban.
	if(mind)
		if(transfer_after)
			mind.late_joiner = TRUE
		mind.active = 0					//we wish to transfer the key manually
		mind.transfer_to(H)					//won't transfer key since the mind is not active

	H.name = real_name

	. = H
	new_character = .
	if(transfer_after)
		transfer_character()

/mob/dead/new_player/authenticated/proc/transfer_character()
	. = new_character
	if(.)
		new_character.key = key		//Manually transfer the key to log them in
		new_character.stop_sound_channel(CHANNEL_LOBBYMUSIC)
		new_character = null
		qdel(src)

/mob/dead/new_player/authenticated/proc/ViewManifest()
	if(!client || !COOLDOWN_FINISHED(client, crew_manifest_delay))
		return
	COOLDOWN_START(client, crew_manifest_delay, 1 SECONDS)
	GLOB.crew_manifest_tgui.ui_interact(src)

/mob/dead/new_player/Move()
	return 0


/mob/dead/new_player/authenticated/proc/close_spawn_windows()

	src << browse(null, "window=latechoices") //closes late choices window
	src << browse(null, "window=playersetup") //closes the player setup window
	src << browse(null, "window=preferences") //closes job selection
	src << browse(null, "window=mob_occupation")
	src << browse(null, "window=latechoices") //closes late job selection

// Used to make sure that a player has a valid job preference setup, used to knock players out of eligibility for anything if their prefs don't make sense.
// A "valid job preference setup" in this situation means at least having one job set to low, or not having "return to lobby" enabled
// Prevents "antag rolling" by setting antag prefs on, all jobs to never, and "return to lobby if preferences not available"
// Doing so would previously allow you to roll for antag, then send you back to lobby if you didn't get an antag role
// This also does some admin notification and logging as well, as well as some extra logic to make sure things don't go wrong
/mob/dead/new_player/authenticated/proc/check_preferences()
	if(!client)
		return FALSE //Not sure how this would get run without the mob having a client, but let's just be safe.
	if(client.prefs.read_character_preference(/datum/preference/choiced/jobless_role) != RETURNTOLOBBY)
		return TRUE
	// If they have antags enabled, they're potentially doing this on purpose instead of by accident. Notify admins if so.
	var/has_antags = (length(client.prefs.role_preferences_global) + length(client.prefs.role_preferences)) > 0
	if(!length(client.prefs.job_preferences))
		if(!ineligible_for_roles)
			to_chat(src, span_danger("You have no jobs enabled, along with return to lobby if job is unavailable. This makes you ineligible for any round start role, please update your job preferences."))
		ineligible_for_roles = TRUE
		ready = PLAYER_NOT_READY
		if(has_antags)
			log_admin("[src.ckey] just got booted back to lobby with no jobs, but antags enabled.")
			message_admins("[src.ckey] just got booted back to lobby with no jobs enabled, but antag rolling enabled. Likely antag rolling abuse.")

		return FALSE //This is the only case someone should actually be completely blocked from antag rolling as well
	return TRUE

/**
  * Prepares a client for the interview system, and provides them with a new interview
  *
  * This proc will both prepare the user by removing all verbs from them, as well as
  * giving them the interview form and forcing it to appear.
  */
/mob/dead/new_player/authenticated/proc/register_for_interview()
	// First we detain them by removing all the verbs they have on client
	for (var/v in client.verbs)
		var/procpath/verb_path = v
		client.remove_verb(verb_path, FALSE)

	// Then remove those on their mob as well
	for (var/v in verbs)
		var/procpath/verb_path = v
		remove_verb(verb_path, FALSE)

	// Then we create the interview form and show it to the client
	var/datum/interview/I = GLOB.interviews.interview_for_client(client)
	if (I)
		I.ui_interact(src)

	// Add verb for re-opening the interview panel, and re-init the verbs for the stat panel
	add_verb(/mob/dead/new_player/proc/open_interview)

	UpdateMobStat(forced = TRUE)
	set_stat_tab("Interview")

	to_chat(src, span_boldannounce("Panic Bunker Active - Interview Required") \
					+ "\n[span_danger("To prevent abuse, players with no/low playtime are required to complete an interview to gain access.\nThis is only required once and only for the duration that the panic bunker is active.")] \
					\n[span_boldwarning("If the interview interface is not open, use the Open Interview verb in the top right.")]")

/mob/dead/new_player/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	return

#undef LINKIFY_READY
