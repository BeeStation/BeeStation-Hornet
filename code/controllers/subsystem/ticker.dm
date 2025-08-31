#define ROUND_START_MUSIC_LIST "strings/round_start_sounds.txt"
GLOBAL_LIST_EMPTY(roundstart_areas_lights_on)

SUBSYSTEM_DEF(ticker)
	name = "Ticker"
	init_order = INIT_ORDER_TICKER

	priority = FIRE_PRIORITY_TICKER
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME

	var/current_state = GAME_STATE_STARTUP	//state of current round (used by process()) Use the defines GAME_STATE_* !
	var/force_ending = 0					//Round was ended by admin intervention
	// If true, there is no lobby phase, the game starts immediately.
	var/start_immediately = FALSE
	var/setup_done = FALSE //All game setup done including mode post setup and

	var/login_music							//music played in pregame lobby
	var/round_end_sound						//music/jingle played when the world reboots
	var/round_end_sound_sent = TRUE			//If all clients have loaded it

	var/list/datum/mind/minds = list()		//The characters in the game. Used for objective tracking.

	var/delay_end = 0						//if set true, the round will not restart on it's own
	var/admin_delay_notice = ""				//a message to display to anyone who tries to restart the world after a delay
	var/ready_for_reboot = FALSE			//all roundend preparation done with, all that's left is reboot

	var/triai = 0							//Global holder for Triumvirate
	var/tipped = 0							//Did we broadcast the tip of the day yet?
	var/selected_tip						// What will be the tip of the day?

	var/timeLeft						//pregame timer
	var/start_at

	var/gametime_offset = 432000		//Deciseconds to add to world.time for station time.
	var/station_time_rate_multiplier = 12		//factor of station time progressal vs real time.

	var/totalPlayers = 0					//used for pregame stats on statpanel
	var/totalPlayersReady = 0				//used for pregame stats on statpanel
	var/totalPlayersPreAuth = 0				//used for pregame stats on statpanel

	var/queue_delay = 0
	var/list/queued_players = list()		//used for join queues when the server exceeds the hard population cap

	var/maprotatechecked = 0

	var/news_report

	var/late_join_disabled

	var/roundend_check_paused = FALSE

	var/round_start_time = 0
	var/round_start_timeofday = 0
	var/list/round_start_events
	var/list/round_end_events
	var/mode_result = "undefined"
	var/end_state = "undefined"

/datum/controller/subsystem/ticker/Initialize()
	var/list/byond_sound_formats = list(
		"mid"  = TRUE,
		"midi" = TRUE,
		"mod"  = TRUE,
		"it"   = TRUE,
		"s3m"  = TRUE,
		"xm"   = TRUE,
		"oxm"  = TRUE,
		"wav"  = TRUE,
		"ogg"  = TRUE,
		"raw"  = TRUE,
		"wma"  = TRUE,
		"aiff" = TRUE
	)

	var/list/provisional_title_music = flist("[global.config.directory]/title_music/sounds/")
	var/list/music = list()
	var/use_rare_music = prob(1)

	for(var/S in provisional_title_music)
		var/lower = LOWER_TEXT(S)
		var/list/L = splittext(lower,"+")
		switch(L.len)
			if(3) //rare+MAP+sound.ogg or MAP+rare.sound.ogg -- Rare Map-specific sounds
				if(use_rare_music)
					if(L[1] == "rare" && L[2] == SSmapping.config.map_name)
						music += S
					else if(L[2] == "rare" && L[1] == SSmapping.config.map_name)
						music += S
			if(2) //rare+sound.ogg or MAP+sound.ogg -- Rare sounds or Map-specific sounds
				if((use_rare_music && L[1] == "rare") || (L[1] == SSmapping.config.map_name))
					music += S
			if(1) //sound.ogg -- common sound
				if(L[1] == "exclude")
					continue
				music += S

	var/old_login_music = trim(rustg_file_read("data/last_round_lobby_music.txt"))
	if(music.len > 1)
		music -= old_login_music

	for(var/S in music)
		var/list/L = splittext(S,".")
		if(L.len >= 2)
			var/ext = LOWER_TEXT(L[L.len]) //pick the real extension, no 'honk.ogg.exe' nonsense here
			if(byond_sound_formats[ext])
				continue
		music -= S

	if(!length(music))
		music = world.file2list(ROUND_START_MUSIC_LIST, "\n")
		login_music = pick(music)
	else
		login_music = "[global.config.directory]/title_music/sounds/[pick(music)]"


	if(!GLOB.syndicate_code_phrase)
		GLOB.syndicate_code_phrase	= generate_code_phrase(return_list=TRUE)

		var/codewords = jointext(GLOB.syndicate_code_phrase, "|")
		var/regex/codeword_match = new("([codewords])", "ig")

		GLOB.syndicate_code_phrase_regex = codeword_match

	if(!GLOB.syndicate_code_response)
		GLOB.syndicate_code_response = generate_code_phrase(return_list=TRUE)

		var/codewords = jointext(GLOB.syndicate_code_response, "|")
		var/regex/codeword_match = new("([codewords])", "ig")

		GLOB.syndicate_code_response_regex = codeword_match

	start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 10)
	if(CONFIG_GET(flag/randomize_shift_time))
		gametime_offset = rand(0, 23) HOURS
	else if(CONFIG_GET(flag/shift_time_realtime))
		gametime_offset = world.timeofday

	return SS_INIT_SUCCESS

/datum/controller/subsystem/ticker/fire()
	switch(current_state)
		if(GAME_STATE_STARTUP)
			if(Master.initializations_finished_with_no_players_logged_in)
				start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 10)
			for(var/client/C in GLOB.clients_unsafe)
				window_flash(C, ignorepref = TRUE) //let them know lobby has opened up.
			to_chat(world, span_boldnotice("Welcome to [station_name()]!"))
			send2chat(new /datum/tgs_message_content("New round starting on [SSmapping.config.map_name]!"), CONFIG_GET(string/chat_announce_new_game))
			current_state = GAME_STATE_PREGAME
			//Everyone who wants to be an observer is now spawned
			create_observers()
			fire()
		if(GAME_STATE_PREGAME)
				//lobby stats for statpanels
			if(isnull(timeLeft))
				timeLeft = max(0,start_at - world.time)
			totalPlayers = 0
			totalPlayersReady = 0
			totalPlayersPreAuth = 0
			for(var/mob/dead/new_player/pre_auth/player in GLOB.player_list)
				++totalPlayersPreAuth
				++totalPlayers
			for(var/mob/dead/new_player/authenticated/player in GLOB.player_list)
				++totalPlayers
				if(player.ready == PLAYER_READY_TO_PLAY)
					++totalPlayersReady

			if(start_immediately)
				timeLeft = 0

			//countdown
			if(timeLeft < 0)
				return
			timeLeft -= wait

			if(timeLeft <= 300 && !tipped)
				send_tip_of_the_round()
				tipped = TRUE

			if(timeLeft <= 0)
				current_state = GAME_STATE_SETTING_UP
				Master.SetRunLevel(RUNLEVEL_SETUP)
				if(start_immediately)
					fire()

		if(GAME_STATE_SETTING_UP)
			if(!setup())
				//setup failed
				current_state = GAME_STATE_STARTUP
				start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 5)
				timeLeft = null
				Master.SetRunLevel(RUNLEVEL_LOBBY)

		if(GAME_STATE_PLAYING)
			SSdynamic.process_rulesets()
			check_queue()
			check_maprotate()

			if(!roundend_check_paused && (check_finished() || force_ending))
				current_state = GAME_STATE_FINISHED
				toggle_ooc(TRUE) // Turn it on
				toggle_dooc(TRUE)
				declare_completion(force_ending)
				Master.SetRunLevel(RUNLEVEL_POSTGAME)

/// Checks if the round should be ending, called every ticker tick
/datum/controller/subsystem/ticker/proc/check_finished()
	if(!setup_done)
		return FALSE
	if(SSshuttle.emergency && (SSshuttle.emergency.mode == SHUTTLE_ENDGAME))
		return TRUE
	if(GLOB.station_was_nuked)
		return TRUE
	return FALSE

/datum/controller/subsystem/ticker/proc/setup()
	to_chat(world, span_boldannounce("Starting game..."))
	var/init_start = world.timeofday

	CHECK_TICK
	// Configure dynamic
	var/can_continue = FALSE
	can_continue = SSdynamic.select_roundstart_antagonists() //Choose antagonists
	CHECK_TICK
	can_continue = can_continue && SSjob.DivideOccupations() //Distribute jobs
	CHECK_TICK

	if(!GLOB.Debug2)
		if(!can_continue)
			log_game("Dynamic failed pre_setup")
			to_chat(world, "<B>Error setting up dynamic.</B> Reverting to pre-game lobby.")
			SSjob.ResetOccupations()
			return FALSE
	else
		message_admins("DEBUG: Bypassing prestart checks...")

	CHECK_TICK

	if(!CONFIG_GET(flag/ooc_during_round))
		toggle_ooc(FALSE) // Turn it off

	CHECK_TICK
	GLOB.start_landmarks_list = shuffle(GLOB.start_landmarks_list) //Shuffle the order of spawn points so they dont always predictably spawn bottom-up and right-to-left
	create_characters() //Create player characters
	collect_minds()
	equip_characters()

	GLOB.manifest.build()

	transfer_characters()	//transfer keys to the new mobs

	log_world("Game start took [(world.timeofday - init_start)/10]s")
	round_start_time = world.time
	round_start_timeofday = world.timeofday
	INVOKE_ASYNC(SSdbcore, TYPE_PROC_REF(/datum/controller/subsystem/dbcore, SetRoundStart))

	current_state = GAME_STATE_PLAYING

	// Now that nothing can enter the callback list, fire them off
	for(var/I in round_start_events)
		var/datum/callback/cb = I
		cb.InvokeAsync()
	LAZYCLEARLIST(round_start_events)

	to_chat(world, span_notice("<B>Welcome to [station_name()], enjoy your stay!</B>"))
	SEND_SOUND(world, sound(SSstation.announcer.get_rand_welcome_sound()))

	Master.SetRunLevel(RUNLEVEL_GAME)

	if(SSevents.holidays)
		to_chat(world, span_notice("and..."))
		for(var/holidayname in SSevents.holidays)
			var/datum/holiday/holiday = SSevents.holidays[holidayname]
			to_chat(world, "<h4>[holiday.greet()]</h4>")

	//Setup orbits.
	SSorbits.post_load_init()

	// Store areas where lights need to stay on
	var/list/lightup_area_typecache = list()
	var/minimal_access = SSjob.initial_players_to_assign < LOWPOP_JOB_LIMIT
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		var/role = player.mind?.assigned_role
		if(!role)
			continue
		var/datum/job/job = SSjob.GetJob(role)
		if(!job)
			continue
		lightup_area_typecache |= job.areas_to_light_up(minimal_access)
	var/list/target_area_list = typecache_filter_list(GLOB.areas, lightup_area_typecache)
	if(length(target_area_list))
		GLOB.roundstart_areas_lights_on.Add(target_area_list)

	PostSetup()
	SSstat.clear_global_alert()

	return TRUE

/datum/controller/subsystem/ticker/proc/PostSetup()
	set waitfor = FALSE

	// Execute dynamic rulesets
	SSdynamic.execute_roundstart_rulesets()

	// Send roundstart report
	SScommunications.queue_roundstart_report()

	// Handle database
	if(SSdbcore.Connect())
		var/list/to_set = list()
		var/arguments = list()
		if(GLOB.revdata.originmastercommit)
			to_set += "commit_hash = :commit_hash"
			arguments["commit_hash"] = GLOB.revdata.originmastercommit
		if(to_set.len)
			arguments["round_id"] = GLOB.round_id
			var/datum/db_query/query_round_game_mode = SSdbcore.NewQuery(
				"UPDATE [format_table_name("round")] SET [to_set.Join(", ")] WHERE id = :round_id",
				arguments
			)
			query_round_game_mode.Execute()
			qdel(query_round_game_mode)

	GLOB.start_state = new /datum/station_state()
	GLOB.start_state.count()

	var/list/adm = get_admin_counts()
	var/list/allmins = adm["present"]
	send2tgs("Server", "Round [GLOB.round_id ? "#[GLOB.round_id]:" : ""] has started[allmins.len ? "." : " with no active admins online!"]")
	setup_done = TRUE

	for(var/obj/effect/landmark/start/S as anything in GLOB.start_landmarks_list)
		if(istype(S)) //we can not runtime here. not in this important of a proc.
			S.after_round_start()
		else
			stack_trace("[S] [S.type] found in start landmarks list, which isn't a start landmark!")

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_POST_START)

//These callbacks will fire after roundstart key transfer
/datum/controller/subsystem/ticker/proc/OnRoundstart(datum/callback/cb)
	if(!HasRoundStarted())
		LAZYADD(round_start_events, cb)
	else
		cb.InvokeAsync()

//These callbacks will fire before roundend report
/datum/controller/subsystem/ticker/proc/OnRoundend(datum/callback/cb)
	if(current_state >= GAME_STATE_FINISHED)
		cb.InvokeAsync()
	else
		LAZYADD(round_end_events, cb)

/datum/controller/subsystem/ticker/proc/station_explosion_detonation(atom/bomb)
	if(bomb)	//BOOM
		qdel(bomb)
		for(var/mob/M in GLOB.mob_list)
			var/turf/T = get_turf(M)
			if(T && is_station_level(T.z) && !istype(M.loc, /obj/structure/closet/secure_closet/freezer)) //protip: freezers protect you from nukes
				M.gib(TRUE)

/datum/controller/subsystem/ticker/proc/create_characters()
	for(var/mob/dead/new_player/authenticated/player in GLOB.player_list)
		if(player.ready == PLAYER_READY_TO_PLAY && player.mind)
			GLOB.joined_player_list += player.ckey
			player.create_character(FALSE)
		else
			player.new_player_panel()
		CHECK_TICK

/datum/controller/subsystem/ticker/proc/collect_minds()
	for(var/mob/dead/new_player/authenticated/P in GLOB.player_list)
		if(P.new_character?.mind)
			SSticker.minds += P.new_character.mind
		CHECK_TICK


/datum/controller/subsystem/ticker/proc/equip_characters()
	var/captainless = TRUE
	var/highest_rank = length(SSjob.chain_of_command) + 1
	var/list/spare_id_candidates = list()
	var/enforce_coc = CONFIG_GET(flag/spare_enforce_coc)

	for(var/mob/dead/new_player/authenticated/N in GLOB.player_list)
		var/mob/living/carbon/human/player = N.new_character
		var/datum/mind/mind = player?.mind
		if(istype(player) && mind && mind.assigned_role)
			if(mind.assigned_role == JOB_NAME_CAPTAIN)
				captainless = FALSE
				spare_id_candidates += N
			else if(captainless && (mind.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND)) && !(is_banned_from(N.ckey, JOB_NAME_CAPTAIN)))
				if(!enforce_coc)
					spare_id_candidates += N
				else
					var/spare_id_priority = SSjob.chain_of_command[mind.assigned_role]
					if(spare_id_priority)
						if(spare_id_priority < highest_rank)
							spare_id_candidates.Cut()
							spare_id_candidates += N
							highest_rank = spare_id_priority
						else if(spare_id_priority == highest_rank)
							spare_id_candidates += N
			if(mind.assigned_role != mind.special_role)
				SSjob.EquipRank(N, mind.assigned_role, FALSE)
			if(CONFIG_GET(flag/roundstart_traits))
				SSquirks.AssignQuirks(mind, N.client, TRUE)
		CHECK_TICK
	if(length(spare_id_candidates))			//No captain, time to choose acting captain
		if(!enforce_coc)
			for(var/mob/dead/new_player/authenticated/player in spare_id_candidates)
				SSjob.promote_to_captain(player, captainless)

		else
			SSjob.promote_to_captain(pick(spare_id_candidates), captainless)		//This is just in case 2 heads of the same priority spawn
		CHECK_TICK


/datum/controller/subsystem/ticker/proc/transfer_characters()
	var/list/livings = list()
	for(var/mob/dead/new_player/authenticated/player in GLOB.mob_list)
		var/mob/living = player.transfer_character()
		if(living)
			qdel(player)
			living.notransform = TRUE
			if(living.client)
				var/atom/movable/screen/splash/S = new(null, living.client, TRUE)
				S.Fade(TRUE)
			livings += living
	if(livings.len)
		addtimer(CALLBACK(src, PROC_REF(release_characters), livings), 30, TIMER_CLIENT_TIME)

/datum/controller/subsystem/ticker/proc/release_characters(list/livings)
	for(var/I in livings)
		var/mob/living/L = I
		L.notransform = FALSE

/datum/controller/subsystem/ticker/proc/send_tip_of_the_round()
	var/m
	if(selected_tip)
		m = selected_tip
	else
		var/list/randomtips = world.file2list("strings/tips.txt")
		var/list/memetips = world.file2list("strings/sillytips.txt")
		if(randomtips.len && prob(95))
			m = pick(randomtips)
		else if(memetips.len)
			m = pick(memetips)

	if(m)
		to_chat(world, examine_block(span_purple("<b>Tip of the round: </b>[html_encode(m)]")))

/datum/controller/subsystem/ticker/proc/check_queue()
	if(!queued_players.len)
		return
	var/hpc = CONFIG_GET(number/hard_popcap)
	if(!hpc)
		list_clear_nulls(queued_players)
		for (var/mob/dead/new_player/authenticated/NP in queued_players)
			to_chat(NP, span_userdanger("The alive players limit has been released!<br><a href='byond://?src=[REF(NP)];late_join=override'>[html_encode(">>Join Game<<")]</a>"))
			SEND_SOUND(NP, sound('sound/misc/notice1.ogg'))
			NP.LateChoices()
		queued_players.len = 0
		queue_delay = 0
		return

	queue_delay++
	var/mob/dead/new_player/authenticated/next_in_line = queued_players[1]

	switch(queue_delay)
		if(5) //every 5 ticks check if there is a slot available
			list_clear_nulls(queued_players)
			if(living_player_count() < hpc)
				if(next_in_line && next_in_line.client)
					to_chat(next_in_line, span_userdanger("A slot has opened! You have approximately 20 seconds to join. <a href='byond://?src=[REF(next_in_line)];late_join=override'>\>\>Join Game\<\<</a>"))
					SEND_SOUND(next_in_line, sound('sound/misc/notice1.ogg'))
					next_in_line.LateChoices()
					return
				queued_players -= next_in_line //Client disconnected, remove he
			queue_delay = 0 //No vacancy: restart timer
		if(25 to INFINITY)  //No response from the next in line when a vacancy exists, remove he
			to_chat(next_in_line, span_danger("No response received. You have been removed from the line."))
			queued_players -= next_in_line
			queue_delay = 0

/datum/controller/subsystem/ticker/proc/check_maprotate()
	if (!CONFIG_GET(flag/maprotation))
		return
	if (SSshuttle.emergency && SSshuttle.emergency.mode != SHUTTLE_ESCAPE || SSshuttle.canRecall())
		return
	if (maprotatechecked)
		return

	maprotatechecked = 1

	//map rotate chance defaults to 75% of the length of the round (in minutes)
	if (!prob((world.time/600)*CONFIG_GET(number/maprotatechancedelta)))
		return
	INVOKE_ASYNC(SSmapping, TYPE_PROC_REF(/datum/controller/subsystem/mapping, maprotate))

/datum/controller/subsystem/ticker/proc/HasRoundStarted()
	return current_state >= GAME_STATE_PLAYING

/datum/controller/subsystem/ticker/proc/IsRoundInProgress()
	return current_state == GAME_STATE_PLAYING

/datum/controller/subsystem/ticker/Recover()
	current_state = SSticker.current_state
	force_ending = SSticker.force_ending

	login_music = SSticker.login_music
	round_end_sound = SSticker.round_end_sound

	minds = SSticker.minds

	delay_end = SSticker.delay_end

	triai = SSticker.triai
	tipped = SSticker.tipped
	selected_tip = SSticker.selected_tip

	timeLeft = SSticker.timeLeft

	totalPlayers = SSticker.totalPlayers
	totalPlayersReady = SSticker.totalPlayersReady
	totalPlayersPreAuth = SSticker.totalPlayersPreAuth

	queue_delay = SSticker.queue_delay
	queued_players = SSticker.queued_players
	maprotatechecked = SSticker.maprotatechecked
	round_start_time = SSticker.round_start_time
	round_start_timeofday = SSticker.round_start_timeofday

	queue_delay = SSticker.queue_delay
	queued_players = SSticker.queued_players
	maprotatechecked = SSticker.maprotatechecked

	if (Master) //Set Masters run level if it exists
		switch (current_state)
			if(GAME_STATE_SETTING_UP)
				Master.SetRunLevel(RUNLEVEL_SETUP)
			if(GAME_STATE_PLAYING)
				Master.SetRunLevel(RUNLEVEL_GAME)
			if(GAME_STATE_FINISHED)
				Master.SetRunLevel(RUNLEVEL_POSTGAME)

/datum/controller/subsystem/ticker/proc/send_news_report()
	var/news_message
	var/news_source = "Nanotrasen News Network"
	switch(news_report)
		if(NUKE_SYNDICATE_BASE)
			news_message = "In a daring raid, the heroic crew of [station_name()] detonated a nuclear device in the heart of a terrorist base."
		if(STATION_DESTROYED_NUKE)
			news_message = "We would like to reassure all employees that the reports of a Syndicate backed nuclear attack on [station_name()] are, in fact, a hoax. Have a secure day!"
		if(STATION_EVACUATED)
			news_message = "The crew of [station_name()] has been evacuated amid unconfirmed reports of enemy activity."
		if(BLOB_WIN)
			news_message = "[station_name()] was overcome by an unknown biological outbreak, killing all crew on board. Don't let it happen to you! Remember, a clean work station is a safe work station."
		if(BLOB_NUKE)
			news_message = "[station_name()] is currently undergoing decontanimation after a controlled burst of radiation was used to remove a biological ooze. All employees were safely evacuated prior, and are enjoying a relaxing vacation."
		if(BLOB_DESTROYED)
			news_message = "[station_name()] is currently undergoing decontamination procedures after the destruction of a biological hazard. As a reminder, any crew members experiencing cramps or bloating should report immediately to security for incineration."
		if(CULT_ESCAPE)
			news_message = "Security Alert: A group of religious fanatics have escaped from [station_name()]."
		if(CULT_FAILURE)
			news_message = "Following the dismantling of a restricted cult aboard [station_name()], we would like to remind all employees that worship outside of the Chapel is strictly prohibited, and cause for termination."
		if(CULT_SUMMON)
			news_message = "Company officials would like to clarify that [station_name()] was scheduled to be decommissioned following meteor damage earlier this year. Earlier reports of an unknowable eldritch horror were made in error."
		if(NUKE_MISS)
			news_message = "The Syndicate have bungled a terrorist attack [station_name()], detonating a nuclear weapon in empty space nearby."
		if(OPERATIVES_KILLED)
			news_message = "Repairs to [station_name()] are underway after an elite Syndicate death squad was wiped out by the crew."
		if(OPERATIVE_SKIRMISH)
			news_message = "A skirmish between security forces and Syndicate agents aboard [station_name()] ended with both sides bloodied but intact."
		if(REVS_WIN)
			news_message = "Company officials have reassured investors that despite a union led revolt aboard [station_name()] there will be no wage increases for workers."
		if(REVS_LOSE)
			news_message = "[station_name()] quickly put down a misguided attempt at mutiny. Remember, unionizing is illegal!"
		if(WIZARD_KILLED)
			news_message = "Tensions have flared with the Space Wizard Federation following the death of one of their members aboard [station_name()]."
		if(STATION_NUKED)
			news_message = "[station_name()] activated its self-destruct device for unknown reasons. Attempts to clone the Captain so he can be arrested and executed are underway."
		if(CLOCK_SUMMON)
			news_message = "The garbled messages about hailing a mouse and strange energy readings from [station_name()] have been discovered to be an ill-advised, if thorough, prank by a clown."
		if(CLOCK_SILICONS)
			news_message = "The project started by [station_name()] to upgrade their silicon units with advanced equipment have been largely successful, though they have thus far refused to release schematics in a violation of company policy."
		if(CLOCK_PROSELYTIZATION)
			news_message = "The burst of energy released near [station_name()] has been confirmed as merely a test of a new weapon. However, due to an unexpected mechanical error, their communications system has been knocked offline."
		if(SHUTTLE_HIJACK)
			news_message = "During routine evacuation procedures, the emergency shuttle of [station_name()] had its navigation protocols corrupted and went off course, but was recovered shortly after."

	if(news_message)
		if(!AWAIT(SStopic.crosscomms_send_async("news_report", news_message, news_source), 10 SECONDS))
			message_admins("Failed to send news report through crosscomms. The sending task expired.")
			log_game("Failed to send news report through crosscomms. The sending task expired.")

/datum/controller/subsystem/ticker/proc/generate_credit_text()
	var/list/round_credits = list()
	var/len_before_addition
	var/custom_title_holder

	// HEADS OF STAFF
	round_credits += "<center><h1>The Glorious Command Staff:</h1>"
	len_before_addition = round_credits.len
	for(var/mob/player in GLOB.mob_list)
		if(player.mind && (player.mind.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND)))
			custom_title_holder = get_custom_title_from_id(player.mind, newline=TRUE)
			round_credits += "<center><h2>[player] as the [player.mind.assigned_role][custom_title_holder]</h2>"
	if(round_credits.len == len_before_addition)
		round_credits += list("<center><h2>A serious bureaucratic error has occurred!</h2>", "<center><h2>No one was in charge of the crew!</h2>")
	round_credits += "<br>"

	// SILICONS
	round_credits += "<center><h1>The Silicon \"Intelligences\":</h1>"
	len_before_addition = round_credits.len
	for(var/mob/living/silicon/player in GLOB.mob_list)
		if(player.mind && (player.mind.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SILICON)))
			round_credits += "<center><h2>[player] as the [player.mind.assigned_role]</h2>"
	if(round_credits.len == len_before_addition)
		round_credits += list("<center><h2>[station_name()] had no silicon helpers!</h2>", "<center><h2>Not a single door was opened today!</h2>")
	round_credits += "<br>"

	// SECURITY
	round_credits += "<center><h1>The Brave Security Officers:</h1>"
	len_before_addition = round_credits.len
	for(var/mob/player in GLOB.mob_list)
		if(player.mind && (player.mind.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SECURITY)))
			custom_title_holder = get_custom_title_from_id(player.mind, newline=TRUE)
			round_credits += "<center><h2>[player] as the [player.mind.assigned_role][custom_title_holder]</h2>"
	if(round_credits.len == len_before_addition)
		round_credits += list("<center><h2>[station_name()] has fallen to Communism!</h2>", "<center><h2>No one was there to protect the crew!</h2>")
	round_credits += "<br>"

	// MEDICAL
	round_credits += "<center><h1>The Wise Medical Department:</h1>"
	len_before_addition = round_credits.len
	for(var/mob/player in GLOB.mob_list)
		if(player.mind && (player.mind.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_MEDICAL)))
			custom_title_holder = get_custom_title_from_id(player.mind, newline=TRUE)
			round_credits += "<center><h2>[player] as the [player.mind.assigned_role][custom_title_holder]</h2>"
	if(round_credits.len == len_before_addition)
		round_credits += list("<center><h2>Healthcare was not included!</h2>", "<center><h2>There were no doctors today!</h2>")
	round_credits += "<br>"

	// ENGINEERING
	round_credits += "<center><h1>The Industrious Engineers:</h1>"
	len_before_addition = round_credits.len
	for(var/mob/player in GLOB.mob_list)
		if(player.mind && (player.mind.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_ENGINEERING)))
			custom_title_holder = get_custom_title_from_id(player.mind, newline=TRUE)
			round_credits += "<center><h2>[player] as the [player.mind.assigned_role][custom_title_holder]</h2>"
	if(round_credits.len == len_before_addition)
		round_credits += list("<center><h2>[station_name()] probably did not last long!</h2>", "<center><h2>No one was holding the station together!</h2>")
	round_credits += "<br>"

	// SCIENCE
	round_credits += "<center><h1>The Inventive Science Employees:</h1>"
	len_before_addition = round_credits.len
	for(var/mob/player in GLOB.mob_list)
		if(player.mind && (player.mind.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SCIENCE)))
			custom_title_holder = get_custom_title_from_id(player.mind, newline=TRUE)
			round_credits += "<center><h2>[player] as the [player.mind.assigned_role][custom_title_holder]</h2>"
	if(round_credits.len == len_before_addition)
		round_credits += list("<center><h2>No one was doing \"science\" today!</h2>", "<center><h2>Everyone probably made it out alright, then!</h2>")
	round_credits += "<br>"

	// CARGO
	round_credits += "<center><h1>The Rugged Cargo Crew:</h1>"
	len_before_addition = round_credits.len
	for(var/mob/player in GLOB.mob_list)
		if(player.mind && (player.mind.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_CARGO)))
			custom_title_holder = get_custom_title_from_id(player.mind, newline=TRUE)
			round_credits += "<center><h2>[player] as the [player.mind.assigned_role][custom_title_holder]</h2>"
	if(round_credits.len == len_before_addition)
		round_credits += list("<center><h2>The station was freed from paperwork!</h2>", "<center><h2>No one worked in cargo today!</h2>")
	round_credits += "<br>"

	// CIVILIANS
	var/list/human_garbage = list()
	round_credits += "<center><h1>The Hardy Civilians:</h1>"
	len_before_addition = round_credits.len
	for(var/mob/player in GLOB.mob_list) // gimmicks shouldn't be here, but let's not make the code dirty
		if(player.mind && (player.mind.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_CIVILIAN)))
			if(player.mind.assigned_role == JOB_NAME_ASSISTANT)
				human_garbage += player.mind
			else
				custom_title_holder = get_custom_title_from_id(player.mind, newline=TRUE)
				round_credits += "<center><h2>[player] as the [player.mind.assigned_role][custom_title_holder]</h2>"
	if(round_credits.len == len_before_addition)
		round_credits += list("<center><h2>Everyone was stuck in traffic this morning!</h2>", "<center><h2>No civilians made it to work!</h2>")
	round_credits += "<br>"

	round_credits += "<center><h1>The Helpful Assistants:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/current in human_garbage)
		custom_title_holder = get_custom_title_from_id(current, newline=TRUE)
		round_credits += "<center><h2>[current.name][custom_title_holder]</h2>"
	if(round_credits.len == len_before_addition)
		round_credits += list("<center><h2>The station was free of <s>greytide</s> assistance!</h2>", "<center><h2>Not a single Assistant showed up on the station today!</h2>")

	return round_credits

/datum/controller/subsystem/ticker/proc/GetTimeLeft()
	if(isnull(SSticker.timeLeft))
		return max(0, start_at - world.time)
	return timeLeft

/datum/controller/subsystem/ticker/proc/SetTimeLeft(newtime)
	if(newtime >= 0 && isnull(timeLeft))	//remember, negative means delayed
		start_at = world.time + newtime
	else
		timeLeft = newtime

//Everyone who wanted to be an observer gets made one now
/datum/controller/subsystem/ticker/proc/create_observers()
	for(var/mob/dead/new_player/authenticated/player in GLOB.player_list)
		if(player.ready == PLAYER_READY_TO_OBSERVE && player.mind)
			//Break chain since this has a sleep input in it
			addtimer(CALLBACK(player, TYPE_PROC_REF(/mob/dead/new_player/authenticated, make_me_an_observer)), 1)

/datum/controller/subsystem/ticker/proc/SetRoundEndSound(the_sound)
	set waitfor = FALSE
	round_end_sound_sent = FALSE
	round_end_sound = fcopy_rsc(the_sound)
	for(var/thing in GLOB.clients_unsafe)
		var/client/C = thing
		if (!C)
			continue
		C.Export("##action=load_rsc", round_end_sound)
	round_end_sound_sent = TRUE

/datum/controller/subsystem/ticker/proc/Reboot(reason, end_string, delay)
	set waitfor = FALSE
	if(usr && !check_rights(R_ADMIN || R_SERVER, TRUE))
		return

	if(!delay)
		delay = CONFIG_GET(number/round_end_countdown) * 10

	var/skip_delay = check_rights()
	if(delay_end && !skip_delay)
		to_chat(world, span_boldannounce("An admin has delayed the round end."))
		return

	to_chat(world, span_boldannounce("Rebooting World in [DisplayTimeText(delay)]. [reason]"))

	var/start_wait = world.time
	UNTIL(round_end_sound_sent || (world.time - start_wait) > (delay * 2))	//don't wait forever
	sleep(delay - (world.time - start_wait))

	if(delay_end && !skip_delay)
		to_chat(world, span_boldannounce("Reboot was cancelled by an admin."))
		return
	if(end_string)
		end_state = end_string

	var/statspage = CONFIG_GET(string/roundstatsurl)
	var/gamelogloc = CONFIG_GET(string/gamelogurl)
	if(statspage)
		to_chat(world, span_info("Round statistics and logs can be viewed <a href=\"[statspage][GLOB.round_id]\">at this website!</a>"))
	else if(gamelogloc)
		to_chat(world, span_info("Round logs can be located <a href=\"[gamelogloc]\">at this website!</a>"))

	log_game(span_boldannounce("Rebooting World. [reason]"))

	world.Reboot()

/datum/controller/subsystem/ticker/Shutdown()
	gather_newscaster() //called here so we ensure the log is created even upon admin reboot
	save_admin_data()
	update_everything_flag_in_db()
	if(!round_end_sound)
		var/list/tracks = flist("sound/roundend/")
		if(tracks.len)
			round_end_sound = "sound/roundend/[pick(tracks)]"

	SEND_SOUND(world, sound(round_end_sound))
	rustg_file_append(login_music, "data/last_round_lobby_music.txt")

#undef ROUND_START_MUSIC_LIST
