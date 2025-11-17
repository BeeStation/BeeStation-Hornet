#define RESTART_COUNTER_PATH "data/round_counter.txt"

GLOBAL_VAR(restart_counter)

/**
 * WORLD INITIALIZATION
 * THIS IS THE INIT ORDER:
 *
 * BYOND =>
 * - (secret init native) =>
 *   - world.Genesis() =>
 *     - world.init_byond_tracy()
 *   - (/static variable inits, reverse declaration order)
 * - Master/New()
 * - (all pre-mapped atoms) /atom/New()
 * - world.New()
 *
 * Now listen up because I want to make something clear:
 * If something is not in this list it should almost definitely be handled by a subsystem Initialize()ing
 * If whatever it is that needs doing doesn't fit in a subsystem you probably aren't trying hard enough tbhfam
 *
 * GOT IT MEMORIZED?
 * - Dominion/Cyberboss
 */

/**
 * THIS !!!SINGLE!!! PROC IS WHERE ANY FORM OF INIITIALIZATION THAT CAN'T BE PERFORMED IN MASTER/NEW() IS DONE
 * NOWHERE THE FUCK ELSE
 * I DON'T CARE HOW MANY LAYERS OF DEBUG/PROFILE/TRACE WE HAVE, YOU JUST HAVE TO DEAL WITH THIS PROC EXISTING
 * I'M NOT EVEN GOING TO TELL YOU WHERE IT'S CALLED FROM BECAUSE I'M DECLARING THAT FORBIDDEN KNOWLEDGE
 * SO HELP ME GOD IF I FIND ABSTRACTION LAYERS OVER THIS!
 */
/world/proc/Genesis()
	#ifdef USE_BYOND_TRACY
	#warn USE_BYOND_TRACY is enabled
	init_byond_tracy()
	#endif
	// Anything else that needs to happen before /world/New() goes here.
	// On TG this includes debugger init and intializing Master, but for now we'll leave that as a BYOND global.

//This happens after the Master subsystem new(s) (it's a global datum)
//So subsystems globals exist, but are not initialised
/world/New()
	log_world("World loaded at [time_stamp()]!")
	SSmetrics.world_init_time = REALTIMEOFDAY // Important

	make_datum_references_lists()	//initialises global lists for referencing frequently used datums (so that we only ever do it once)

	GLOB.config_error_log = GLOB.world_manifest_log = GLOB.world_pda_log = GLOB.world_job_debug_log = GLOB.sql_error_log = GLOB.world_href_log = GLOB.world_runtime_log = GLOB.world_attack_log = GLOB.world_game_log = GLOB.world_econ_log = "data/logs/config_error.[GUID()].log" //temporary file used to record errors with loading config, moved to log directory once logging is set bl

	config.Load(params[OVERRIDE_CONFIG_DIRECTORY_PARAMETER])

	generate_selectable_species() // This needs to happen early on to avoid the debugger crying. It needs to be after config load but before you login.
	make_datum_references_lists_late_setup() // late setup

	#ifdef REFERENCE_DOING_IT_LIVE
	GLOB.harddel_log = GLOB.world_game_log
	#endif

	GLOB.revdata = new

	InitTgs()

	config.LoadMOTD()

	load_admins()
	load_mentors()
	load_badge_ranks()

	//SetupLogs depends on the RoundID, so lets check
	//DB schema and set RoundID if we can
	SSdbcore.CheckSchemaVersion()
	SSdbcore.SetRoundID()
	SetupLogs()
	load_poll_data()

	populate_gear_list()

#ifndef USE_CUSTOM_ERROR_HANDLER
	world.log = file("[GLOB.log_directory]/dd.log")
#else
	if (TgsAvailable())
		world.log = file("[GLOB.log_directory]/dd.log") //not all runtimes trigger world/Error, so this is the only way to ensure we can see all of them.
#endif
	if(CONFIG_GET(flag/usewhitelist))
		load_whitelist()

#ifdef DISABLE_BYOND_AUTH
	CONFIG_SET(flag/guest_ban, FALSE) // no point in banning guests if BYOND auth doesn't exist
	if(!CONFIG_GET(flag/enable_guest_external_auth))
		log_world("DANGER: External authorization is disabled while DISABLE_BYOND_AUTH is set. This means connecting CKEYs are blindly trusted and susceptible to spoofing!")
#endif

	if(fexists(RESTART_COUNTER_PATH))
		GLOB.restart_counter = text2num(trim(rustg_file_read(RESTART_COUNTER_PATH)))
		fdel(RESTART_COUNTER_PATH)

	if(NO_INIT_PARAMETER in params)
		return

	Master.Initialize(10, FALSE, TRUE)

	#ifdef UNIT_TESTS
	HandleTestRun()
	#endif

	#ifdef AUTOWIKI
	setup_autowiki()
	#endif

/world/proc/InitTgs()
	TgsNew(new /datum/tgs_event_handler/impl, TGS_SECURITY_TRUSTED)
	GLOB.revdata.load_tgs_info()

/world/proc/HandleTestRun()
	//trigger things to run the whole process
	Master.sleep_offline_after_initializations = FALSE
	SSticker.start_immediately = TRUE
	CONFIG_SET(number/round_end_countdown, 0)
	var/datum/callback/cb
#ifdef UNIT_TESTS
	cb = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(RunUnitTests))
#else
	cb = VARSET_CALLBACK(SSticker, force_ending, ADMIN_FORCE_END_ROUND)
#endif
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_addtimer), cb, 10 SECONDS))

/world/proc/SetupLogs()
	var/override_dir = params[OVERRIDE_LOG_DIRECTORY_PARAMETER]
	if(!override_dir)
		var/realtime = world.realtime
		var/texttime = time2text(realtime, "YYYY/MM/DD")
		GLOB.log_directory = "data/logs/[texttime]/round-"
		GLOB.picture_logging_prefix = "L_[time2text(realtime, "YYYYMMDD")]_"
		GLOB.picture_log_directory = "data/picture_logs/[texttime]/round-"
		if(GLOB.round_id)
			GLOB.log_directory += "[GLOB.round_id]"
			GLOB.picture_logging_prefix += "R_[GLOB.round_id]_"
			GLOB.picture_log_directory += "[GLOB.round_id]"
		else
			var/timestamp = replacetext(time_stamp(), ":", ".")
			GLOB.log_directory += "[timestamp]"
			GLOB.picture_log_directory += "[timestamp]"
			GLOB.picture_logging_prefix += "T_[timestamp]_"
	else
		GLOB.log_directory = "data/logs/[override_dir]"
		GLOB.picture_logging_prefix = "O_[override_dir]_"
		GLOB.picture_log_directory = "data/picture_logs/[override_dir]"

	GLOB.world_game_log = "[GLOB.log_directory]/game.log"
	GLOB.world_dynamic_log = "[GLOB.log_directory]/dynamic.log"
	GLOB.world_objective_log = "[GLOB.log_directory]/objectives.log"
	GLOB.world_mecha_log = "[GLOB.log_directory]/mecha.log"
	GLOB.world_virus_log = "[GLOB.log_directory]/virus.log"
	GLOB.world_cloning_log = "[GLOB.log_directory]/cloning.log"
	GLOB.world_econ_log = "[GLOB.log_directory]/econ.log"
	GLOB.world_id_log = "[GLOB.log_directory]/id.log"
	GLOB.world_asset_log = "[GLOB.log_directory]/asset.log"
	GLOB.world_attack_log = "[GLOB.log_directory]/attack.log"
	GLOB.world_pda_log = "[GLOB.log_directory]/pda.log"
	GLOB.world_telecomms_log = "[GLOB.log_directory]/telecomms.log"
	GLOB.world_speech_indicators_log = "[GLOB.log_directory]/speech_indicators.log"
	GLOB.world_manifest_log = "[GLOB.log_directory]/manifest.log"
	GLOB.world_href_log = "[GLOB.log_directory]/hrefs.log"
	GLOB.sql_error_log = "[GLOB.log_directory]/sql.log"
	GLOB.world_qdel_log = "[GLOB.log_directory]/qdel.log"
	GLOB.world_map_error_log = "[GLOB.log_directory]/map_errors.log"
	GLOB.world_runtime_log = "[GLOB.log_directory]/runtime.log"
	GLOB.query_debug_log = "[GLOB.log_directory]/query_debug.log"
	GLOB.world_job_debug_log = "[GLOB.log_directory]/job_debug.log"
	GLOB.world_paper_log = "[GLOB.log_directory]/paper.log"
	GLOB.tgui_log = "[GLOB.log_directory]/tgui.log"
	GLOB.prefs_log = "[GLOB.log_directory]/preferences.log"

#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)
	GLOB.test_log = file("[GLOB.log_directory]/tests.log")
	start_log(GLOB.test_log)
#endif
#ifdef REFERENCE_DOING_IT_LIVE
	GLOB.harddel_log = "[GLOB.log_directory]/harddels.log"
	start_log(GLOB.harddel_log)
#endif
	start_log(GLOB.world_game_log)
	start_log(GLOB.world_attack_log)
	start_log(GLOB.world_econ_log)
	start_log(GLOB.world_pda_log)
	start_log(GLOB.world_telecomms_log)
	start_log(GLOB.world_manifest_log)
	start_log(GLOB.world_href_log)
	start_log(GLOB.world_qdel_log)
	start_log(GLOB.world_runtime_log)
	start_log(GLOB.world_job_debug_log)
	start_log(GLOB.world_id_log)
	start_log(GLOB.tgui_log)
	start_log(GLOB.prefs_log)

	var/latest_changelog = file("[global.config.directory]/../html/changelogs/archive/" + time2text(world.timeofday, "YYYY-MM") + ".yml")
	GLOB.changelog_hash = fexists(latest_changelog) ? md5(latest_changelog) : 0 //for telling if the changelog has changed recently
	if(fexists(GLOB.config_error_log))
		fcopy(GLOB.config_error_log, "[GLOB.log_directory]/config_error.log")
		fdel(GLOB.config_error_log)

	if(GLOB.round_id)
		log_game("Round ID: [GLOB.round_id]")

	// This was printed early in startup to the world log and config_error.log,
	// but those are both private, so let's put the commit info in the runtime
	// log which is ultimately public.
	log_runtime(GLOB.revdata.get_log_message())

/world/Topic(T, addr, master, key)
	TGS_TOPIC	//*THIS NEEDS TO BE AT THE TOP OF /world/Topic()* - Redirect to server tools if necessary


	var/list/response[] = list()

	if(length(T) > CONFIG_GET(number/topic_max_size))
		response["statuscode"] = 413
		response["response"] = "Payload too large"
		return json_encode(response)

	if(SSfail2topic?.IsRateLimited(addr))
		response["statuscode"] = 429
		response["response"] = "Rate limited"
		return json_encode(response)

	var/logging = CONFIG_GET(flag/log_world_topic)
	var/topic_decoded = rustg_url_decode(T)
	if(!rustg_json_is_valid(topic_decoded))
		if(logging)
			log_topic("(NON-JSON) \"[topic_decoded]\", from:[addr], master:[master], key:[key]")
		// Fallback check for spacestation13.com requests
		if(topic_decoded == "ping")
			return length(GLOB.clients_unsafe)
		response["statuscode"] = 400
		response["response"] = "Bad Request - Invalid JSON format"
		return json_encode(response)

	var/list/params[] = json_decode(topic_decoded)
	params["addr"] = addr
	var/query = params["query"]
	var/auth = params["auth"]
	var/source = params["source"]

	if(logging)
		var/list/censored_params = params.Copy()
		censored_params["auth"] = "***[copytext(params["auth"], -4)]"
		log_topic("\"[json_encode(censored_params)]\", from:[addr], master:[master], auth:[censored_params["auth"]], key:[key], source:[source]")

	if(!source)
		response["statuscode"] = 400
		response["response"] = "Bad Request - No source specified"
		return json_encode(response)

	if(!query)
		response["statuscode"] = 400
		response["response"] = "Bad Request - No endpoint specified"
		return json_encode(response)

	if(!LAZYACCESS(GLOB.topic_tokens["[auth]"], "[query]"))
		response["statuscode"] = 401
		response["response"] = "Unauthorized - Bad auth"
		return json_encode(response)

	var/datum/world_topic/command = GLOB.topic_commands["[query]"]
	if(!command)
		response["statuscode"] = 501
		response["response"] = "Not Implemented"
		return json_encode(response)

	if(command.CheckParams(params))
		response["statuscode"] = command.statuscode
		response["response"] = command.response
		response["data"] = command.data
		return json_encode(response)
	else
		command.Run(params)
		response["statuscode"] = command.statuscode
		response["response"] = command.response
		response["data"] = command.data
		return json_encode(response)

/world/proc/AnnouncePR(announcement, list/payload)
	var/static/list/PRcounts = list()	//PR id -> number of times announced this round
	var/id = "[payload["pull_request"]["id"]]"
	if(!PRcounts[id])
		PRcounts[id] = 1
	else
		++PRcounts[id]
		if(PRcounts[id] > PR_ANNOUNCEMENTS_PER_ROUND)
			return

	var/final_composed = span_announce("PR: [announcement]")
	for(var/client/C in GLOB.clients)
		C.AnnouncePR(final_composed)

/world/proc/FinishTestRun()
	set waitfor = FALSE
	var/list/fail_reasons
	if(GLOB)
		if(GLOB.total_runtimes != 0)
			fail_reasons = list("Total runtimes: [GLOB.total_runtimes]")
#ifdef UNIT_TESTS
		if(GLOB.failed_any_test)
			LAZYADD(fail_reasons, "Unit Tests failed!")
#endif
		if(!GLOB.log_directory)
			LAZYADD(fail_reasons, "Missing GLOB.log_directory!")
	else
		fail_reasons = list("Missing GLOB!")
	if(!fail_reasons)
		rustg_file_append("Success!", "[GLOB.log_directory]/clean_run.lk")
	else
		log_world("Test run failed!\n[fail_reasons.Join("\n")]")
	sleep(0)	//yes, 0, this'll let Reboot finish and prevent byond memes
	qdel(src)	//shut it down

/world/Reboot(reason = 0, fast_track = FALSE)
	if (reason || fast_track) //special reboot, do none of the normal stuff
		SSdbcore.Disconnect()
		if (usr)
			log_admin("[key_name(usr)] Has requested an immediate world restart via client side debugging tools")
			message_admins("[key_name_admin(usr)] Has requested an immediate world restart via client side debugging tools")
		to_chat(world, span_boldannounce("Rebooting World immediately due to host request."))
	else
		to_chat(world, span_boldannounce("Rebooting world..."))
		Master.Shutdown()	//run SS shutdowns

	TgsReboot()

	#ifdef UNIT_TESTS
	FinishTestRun()
	return
	#else

	if(TgsAvailable())
		var/do_hard_reboot
		// check the hard reboot counter
		var/ruhr = CONFIG_GET(number/rounds_until_hard_restart)
		switch(ruhr)
			if(-1)
				do_hard_reboot = FALSE
			if(0)
				do_hard_reboot = TRUE
			else
				if(GLOB.restart_counter >= ruhr)
					do_hard_reboot = TRUE
				else
					rustg_file_append("[++GLOB.restart_counter]", RESTART_COUNTER_PATH)
					do_hard_reboot = FALSE

		if(do_hard_reboot)
			log_world("World hard rebooted at [time_stamp()]")
			shutdown_logging() // See comment below.
			TgsEndProcess()

	log_world("World rebooted at [time_stamp()]")
	shutdown_logging() // Past this point, no logging procs can be used, at risk of data loss.
	..()
	#endif

/world/Del()
	shutdown_logging() // makes sure the thread is closed before end, else we terminate
	var/debug_server = world.GetConfig("env", "AUXTOOLS_DEBUG_DLL")
	if (debug_server)
		call_ext(debug_server, "auxtools_shutdown")()
	..()

/world/proc/update_status()
	var/s = ""

	// Remove the https: since // is good enough
	var/discordurl = replacetext(CONFIG_GET(string/discordurl), "https:", "")
	var/server_name = CONFIG_GET(string/servername)
	var/server_tag = CONFIG_GET(string/servertag)
	var/station_name = station_name()
	var/players = GLOB.clients_unsafe.len
	var/popcaptext = ""
	var/popcap = max(CONFIG_GET(number/extreme_popcap), CONFIG_GET(number/hard_popcap), CONFIG_GET(number/soft_popcap))
	if (popcap)
		popcaptext = "/[popcap]"

	// Determine our character usage
	var/character_usage = 92	// Base character usage
	// Discord URL is needed
	if (discordurl)
		character_usage += length(discordurl)
	// Server name is needed
	if (server_name)
		character_usage += length(server_name)
	// We also need this stuff
	character_usage += length("[players][popcaptext][SSmapping.current_map?.map_name || "Loading..."][server_tag]")
	var/station_name_limit = 255 - character_usage

	if (station_name_limit <= 10)
		// Too few characters to display the station name
		if (discordurl)
			if (server_name)
				s += "<a href='[discordurl]'><b>[server_name]</b></a><br>"
			else
				s += "<a href='[discordurl]'><b></b></a><br>"
		else
			if (server_name)
				s += "<b>[server_name]</b><br>"
			else
				s += "<b>Space Station 13</b><br>"
	if (station_name_limit < length(station_name))
		// Station name is going to be truncated with ...
		if (discordurl)
			if (server_name)
				s += "<a href='[discordurl]'><b>[server_name]</b> - <b>[copytext(station_name, 1, station_name_limit - 3)]...</b></a><br>"
			else
				s += "<a href='[discordurl]'><b>[copytext(station_name, 1, station_name_limit - 3)]...</b></a><br>"
		else
			if (server_name)
				s += "<b>[server_name]</b> - <b>[copytext(station_name, 1, station_name_limit - 3)]...</b><br>"
			else
				s += "<b>[copytext(station_name, 1, station_name_limit - 3)]...</b><br>"
	else
		// Station name can be displayed in full
		if (discordurl)
			if (server_name)
				s += "<a href='[discordurl]'><b>[server_name]</b> - <b>[station_name]</b></a><br>"
			else
				s += "<a href='[discordurl]'><b>[station_name]</b></a><br>"
		else
			if (server_name)
				s += "<b>[server_name]</b> - <b>[station_name]</b><br>"
			else
				s += "<b>[station_name]</b><br>"

	if (server_tag)
		s += "[server_tag]<p>"

	s += "Time: <b>[gameTimestamp("hh:mm:ss")]</b><br>"
	s += "Players: <b>[players][popcaptext]</b><br>"
	s += "Map: <b>[SSmapping.current_map?.map_name || "Loading..."]"

	status = s

/world/proc/update_hub_visibility(new_visibility)
	if(new_visibility == GLOB.hub_visibility)
		return
	GLOB.hub_visibility = new_visibility
	if(GLOB.hub_visibility)
		hub_password = "kMZy3U5jJHSiBQjr"
	else
		hub_password = "SORRYNOPASSWORD"

/world/proc/incrementMaxZ()
	maxz++
	SSmobs.MaxZChanged()
	SSidlenpcpool.MaxZChanged()
	world.refresh_atmos_grid()

/world/proc/refresh_atmos_grid()

/world/proc/change_fps(new_value = 20)
	if(new_value <= 0)
		CRASH("change_fps() called with [new_value] new_value.")
	if(fps == new_value)
		return //No change required.

	fps = new_value
	on_tickrate_change()

/* UNUSED. uncomment if using
/world/proc/change_tick_lag(new_value = 0.5)
	if(new_value <= 0)
		CRASH("change_tick_lag() called with [new_value] new_value.")
	if(tick_lag == new_value)
		return //No change required.

	tick_lag = new_value
	on_tickrate_change()
*/

/world/proc/on_tickrate_change()
	SStimer?.reset_buckets()

/world/proc/init_byond_tracy()
	var/library

	switch (system_type)
		if (MS_WINDOWS)
			library = "prof.dll"
		if (UNIX)
			library = "libprof.so"
		else
			CRASH("Unsupported platform: [system_type]")

	var/init_result = call_ext(library, "init")("block")
	if (init_result != "0")
		CRASH("Error initializing byond-tracy: [init_result]")

#undef RESTART_COUNTER_PATH
