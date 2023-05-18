SUBSYSTEM_DEF(job)
	name = "Jobs"
	init_order = INIT_ORDER_JOBS
	flags = SS_NO_FIRE

	var/list/occupations = list()		//List of all jobs
	var/list/name_occupations = list()	//Dict of all jobs, keys are titles
	var/list/type_occupations = list()	//Dict of all jobs, keys are types
	var/list/unassigned = list()		//Players who need jobs
	var/initial_players_to_assign = 0 	//used for checking against population caps

	var/list/prioritized_jobs = list()
	var/list/latejoin_trackers = list()	//Don't read this list, use GetLateJoinTurfs() instead

	var/overflow_role = JOB_KEY_ASSISTANT // this value will be changed by `set_overflow_role()` proc later

	var/list/level_order = list(JP_HIGH,JP_MEDIUM,JP_LOW)

	var/spare_id_safe_code = ""

	var/list/chain_of_command = list(
		JOB_KEY_CAPTAIN = 1,				//Not used yet but captain is first in chain_of_command
		JOB_KEY_HEADOFPERSONNEL = 2,
		JOB_KEY_RESEARCHDIRECTOR = 3,
		JOB_KEY_CHIEFENGINEER = 4,
		JOB_KEY_CHIEFMEDICALOFFICER = 5,
		JOB_KEY_HEADOFSECURITY = 6)

	//Crew Objective stuff
	var/list/crew_obj_list = list()
	var/list/crew_obj_jobs = list()

/datum/controller/subsystem/job/Initialize(timeofday)
	SSmapping.HACK_LoadMapConfig()
	if(!occupations.len)
		SetupOccupations()
	if(CONFIG_GET(flag/load_jobs_from_txt))
		LoadJobs()

	set_overflow_role(CONFIG_GET(string/overflow_job))

	spare_id_safe_code = "[rand(0,9)][rand(0,9)][rand(0,9)][rand(0,9)][rand(0,9)]"

	crew_obj_list = subtypesof(/datum/objective/crew)
	for(var/type as() in crew_obj_list)
		// Unfortunately, this is necessary because initial() doesn't work on lists
		var/datum/objective/crew/obj = new type
		var/list/obj_jobs = obj.jobs
		if(!istype(obj_jobs))
			obj_jobs = list(obj_jobs)
		for(var/job in obj_jobs)
			crew_obj_jobs["[job]"] += list(type)
		qdel(obj)

	return ..()

/datum/controller/subsystem/job/proc/set_overflow_role(new_overflow_role)
	var/datum/job/new_overflow = GetJob(new_overflow_role)
	var/cap = CONFIG_GET(number/overflow_cap)

	new_overflow.allow_bureaucratic_error = FALSE
	new_overflow.spawn_positions = cap
	new_overflow.total_positions = cap

	if(new_overflow_role != overflow_role)
		var/datum/job/old_overflow = GetJob(overflow_role)
		old_overflow.allow_bureaucratic_error = initial(old_overflow.allow_bureaucratic_error)
		old_overflow.spawn_positions = initial(old_overflow.spawn_positions)
		old_overflow.total_positions = initial(old_overflow.total_positions)
		overflow_role = new_overflow_role
		JobDebug("Overflow role set to : [new_overflow_role]")

/datum/controller/subsystem/job/proc/SetupOccupations(faction = "station")
	occupations = list()
	var/list/all_jobs = subtypesof(/datum/job)
	if(!all_jobs.len)
		to_chat(world, "<span class='boldannounce'>Error setting up jobs, no job datums found.</span>")
		return 0

	for(var/J in all_jobs)
		var/datum/job/job = new J()
		if(!job)
			continue
		if(job.faction != faction)
			continue
		if(!job.config_check())
			continue
		if(!job.map_check())	//Even though we initialize before mapping, this is fine because the config is loaded at new
			testing("Removed [job.type] due to map config")
			continue

		if(job.job_bitflags & JOB_BITFLAG_GIMMICK) // if a gimmick job has a slot, set it to selectable
			if(job.total_positions || job.spawn_positions)
				job.job_bitflags |= JOB_BITFLAG_SELECTABLE

		occupations += job
		// Key is job path. gimmick job path is prioritised if it exists.
		name_occupations["[job.get_jkey()]"] = job
		type_occupations[J] = job

	return 1

/datum/controller/subsystem/job/proc/AnnounceGimmickJobs(target=null)
	var/list/available_gimmicks = list()
	for(var/datum/job/J in occupations)
		if((J.job_bitflags & JOB_BITFLAG_SELECTABLE) && (J.job_bitflags & JOB_BITFLAG_GIMMICK) && (J.current_positions < J.total_positions))
			available_gimmicks += J.get_title()
	if(length(available_gimmicks))
		if(target) // send the message to a single person
			to_chat(target, "<span class='boldnotice'>Available gimmick jobs: [english_list(available_gimmicks)]</span>")
		else // if target is not specified, send the message to everyone
			to_chat(world, "<span class='boldnotice'>Available gimmick jobs: [english_list(available_gimmicks)]</span>")

/datum/controller/subsystem/job/proc/GetJob(job_key)
	if(!job_key)
		CRASH("proc has taken no 'job_string'")
	if(job_key == JOB_UNASSIGNED)
		return FALSE
	if(!occupations.len)
		SetupOccupations()
	if(!name_occupations[job_key])
		CRASH("job name [job_key] is not valid")
	return name_occupations[job_key]

/datum/controller/subsystem/job/proc/GetJobType(jobtype)
	if(!jobtype)
		CRASH("proc has taken no job type")
	if(!occupations.len)
		SetupOccupations()
	if(!type_occupations[jobtype])
		CRASH("job type [jobtype] is not valid")
	return type_occupations[jobtype]

/datum/controller/subsystem/job/proc/GetJobActiveDepartment(job_key)
	if(!job_key)
		CRASH("proc has taken no 'job_string'")
	if(job_key == JOB_UNASSIGNED)
		return NONE
	if(!occupations.len)
		SetupOccupations()
	if(!name_occupations[job_key])
		CRASH("job key [job_key] is not valid")
	var/datum/job/J = name_occupations[job_key]
	return J.departments

/// returns a job's current title
/datum/controller/subsystem/job/proc/get_current_jobname(job_key, ignore_error=FALSE)
	if(!job_key)
		CRASH("The proc has taken a null value")

	var/datum/job/job = name_occupations[job_key]
	if(!job)
		if(!ignore_error)
			stack_trace("[job_key] is not a valid job key")
		return job_key

	return job.get_title()


/datum/controller/subsystem/job/proc/AssignRole(mob/dead/new_player/player, job_key, latejoin = FALSE)
	JobDebug("Running AR, Player: [player], Rank: [job_key], LJ: [latejoin]")
	if(player?.mind && job_key)
		var/datum/job/job = GetJob(job_key)
		if(!job)
			return FALSE
		if(QDELETED(player) || is_banned_from(player.ckey, job_key))
			return FALSE
		if(!job.player_old_enough(player.client))
			return FALSE
		if(job.required_playtime_remaining(player.client))
			return FALSE
		var/position_limit = job.total_positions
		if(!latejoin)
			position_limit = job.spawn_positions
		JobDebug("Player: [player] is now Rank: [job_key], JCP:[job.current_positions], JPL:[position_limit]")

		player.mind.assign_station_role(job)
		unassigned -= player
		job.current_positions++
		return TRUE
	JobDebug("AR has failed, Player: [player], Rank: [job_key]")
	return FALSE

/datum/controller/subsystem/job/proc/FreeRole(job_key)
	if(!job_key)
		return
	JobDebug("Freeing role: [job_key]")
	var/datum/job/job = GetJob(job_key)
	if(!job)
		return FALSE
	job.current_positions = max(0, job.current_positions - 1)

/datum/controller/subsystem/job/proc/FindOccupationCandidates(datum/job/job, level, flag)
	JobDebug("Running FOC, Job: [job], Level: [level], Flag: [flag]")
	var/list/candidates = list()
	for(var/mob/dead/new_player/player in unassigned)
		if(QDELETED(player) || (is_banned_from(player.ckey, job.get_jobkeys_for_bancheck())))
			JobDebug("FOC isbanned failed, Player: [player]")
			continue
		if(!job.player_old_enough(player.client))
			JobDebug("FOC player not old enough, Player: [player]")
			continue
		if(job.required_playtime_remaining(player.client))
			JobDebug("FOC player not enough xp, Player: [player]")
			continue
		if(flag && (!(flag in player.client.prefs.be_special)))
			JobDebug("FOC flag failed, Player: [player], Flag: [flag], ")
			continue
		if(player.mind && ((job.get_jkey() in player.mind.restricted_roles)))
			JobDebug("FOC incompatible with antagonist role, Player: [player]")
			continue
		if(player.client.prefs.active_character.job_preferences[job.get_jkey()] == level)
			JobDebug("FOC pass, Player: [player], Level:[level]")
			candidates += player
	return candidates

/datum/controller/subsystem/job/proc/GiveRandomJob(mob/dead/new_player/player)
	JobDebug("GRJ Giving random job, Player: [player]")
	. = FALSE
	for(var/datum/job/job in shuffle(occupations))
		if(!job)
			continue

		if(istype(job, GetJob(SSjob.overflow_role))) // We don't want to give him assistant, that's boring!
			continue

		if(job.get_jkey() in GLOB.command_positions) //If you want a command position, select it!
			continue

		if(QDELETED(player))
			JobDebug("GRJ isbanned failed, Player deleted")
			break

		if(is_banned_from(player.ckey, job.get_jobkeys_for_bancheck()))
			JobDebug("GRJ isbanned failed, Player: [player], Job:[english_list(job.get_jobkeys_for_bancheck())]")
			continue

		if(!job.player_old_enough(player.client))
			JobDebug("GRJ player not old enough, Player: [player]")
			continue

		if(job.required_playtime_remaining(player.client))
			JobDebug("GRJ player not enough xp, Player: [player]")
			continue

		if(player.mind && (job.get_jkey() in player.mind.restricted_roles))
			JobDebug("GRJ incompatible with antagonist role, Player: [player], Job: [job.get_jkey()]")
			continue

		if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
			JobDebug("GRJ Random job given, Player: [player], Job: [job]")
			if(AssignRole(player, job.get_jkey()))
				return TRUE

/datum/controller/subsystem/job/proc/ResetOccupations()
	JobDebug("Occupations reset.")
	for(var/mob/dead/new_player/player in GLOB.player_list)
		if((player) && (player.mind))
			player.mind.mind_roles = list(
				RLPK_DISPLAY_STATION_ROLE = "",
				RLPK_DISPLAY_SPECIAL_ROLE = "",
				RLPK_HOLDER_JOBS = list(),
				RLPK_HOLDER_SPECIAL_ROLES = list()
			)
			SSpersistence.antag_rep_change[player.ckey] = 0
	SetupOccupations()
	unassigned = list()
	return


//This proc is called before the level loop of DivideOccupations() and will try to select a head, ignoring ALL non-head preferences for every level until
//it locates a head or runs out of levels to check
//This is basically to ensure that there's atleast a few heads in the round
/datum/controller/subsystem/job/proc/FillHeadPosition()
	for(var/level in level_order)
		for(var/command_position in GLOB.command_positions)
			var/datum/job/job = GetJob(command_position)
			if(!job)
				continue
			if((job.current_positions >= job.total_positions) && job.total_positions != -1)
				continue
			var/list/candidates = FindOccupationCandidates(job, level)
			if(!candidates.len)
				continue
			var/mob/dead/new_player/candidate = pick(candidates)
			if(AssignRole(candidate, command_position))
				return 1
	return 0


//This proc is called at the start of the level loop of DivideOccupations() and will cause head jobs to be checked before any other jobs of the same level
//This is also to ensure we get as many heads as possible
/datum/controller/subsystem/job/proc/CheckHeadPositions(level)
	for(var/command_position in GLOB.command_positions)
		var/datum/job/job = GetJob(command_position)
		if(!job)
			continue
		if((job.current_positions >= job.total_positions) && job.total_positions != -1)
			continue
		var/list/candidates = FindOccupationCandidates(job, level)
		if(!candidates.len)
			continue
		var/mob/dead/new_player/candidate = pick(candidates)
		AssignRole(candidate, command_position)

/datum/controller/subsystem/job/proc/FillAIPosition()
	var/ai_selected = 0
	var/datum/job/job = GetJob("AI")
	if(!job)
		return 0
	for(var/i = job.total_positions, i > 0, i--)
		for(var/level in level_order)
			var/list/candidates = list()
			candidates = FindOccupationCandidates(job, level)
			if(candidates.len)
				var/mob/dead/new_player/candidate = pick(candidates)
				if(AssignRole(candidate, "AI"))
					ai_selected++
					break
	if(ai_selected)
		return 1
	return 0

// makes players unreadied so that they don't role antag
/datum/controller/subsystem/job/proc/player_readycheck_jobs()
	for(var/mob/dead/new_player/player in GLOB.player_list)
		if(!player.check_preferences()) // they should roll a job at least
			player.ready = PLAYER_NOT_READY


/** Proc DivideOccupations
 *  fills var "list/mind_roles" for all ready players.
 *  This proc must not have any side effect besides of modifying "list/mind_roles"
 **/
/datum/controller/subsystem/job/proc/DivideOccupations(list/required_jobs)
	//Setup new player list and get the jobs list
	JobDebug("Running DO")

	//Holder for Triumvirate is stored in the SSticker, this just processes it
	if(SSticker.triai)
		for(var/datum/job/ai/A in occupations)
			A.spawn_positions = 3
		for(var/obj/effect/landmark/start/ai/secondary/S in GLOB.start_landmarks_list)
			S.latejoin_active = TRUE

	//Get the players who are ready
	for(var/mob/dead/new_player/player in GLOB.player_list)
		if(player.ready == PLAYER_READY_TO_PLAY && player.mind && !player.mind.get_display_station_role())
			if(!player.check_preferences())
				player.ready = PLAYER_NOT_READY
			else
				unassigned += player

	initial_players_to_assign = unassigned.len

	JobDebug("DO, Len: [unassigned.len]")
	if(unassigned.len == 0)
		return validate_required_jobs(required_jobs)

	//Scale number of open security officer slots to population
	setup_officer_positions()

	//Jobs will have fewer access permissions if the number of players exceeds the threshold defined in game_options.txt
	var/mat = CONFIG_GET(number/minimal_access_threshold)
	if(mat)
		if(mat > unassigned.len)
			CONFIG_SET(flag/jobs_have_minimal_access, FALSE)
		else
			CONFIG_SET(flag/jobs_have_minimal_access, TRUE)

	//Shuffle players and jobs
	unassigned = shuffle(unassigned)

	HandleFeedbackGathering()

	//People who wants to be the overflow role, sure, go on.
	JobDebug("DO, Running Overflow Check 1")
	var/datum/job/overflow = GetJob(SSjob.overflow_role)
	var/list/overflow_candidates = FindOccupationCandidates(overflow, 3)
	JobDebug("AC1, Candidates: [overflow_candidates.len]")
	for(var/mob/dead/new_player/player in overflow_candidates)
		JobDebug("AC1 pass, Player: [player]")
		AssignRole(player, SSjob.overflow_role)
		overflow_candidates -= player
	JobDebug("DO, AC1 end")

	//Select one head
	JobDebug("DO, Running Head Check")
	FillHeadPosition()
	JobDebug("DO, Head Check end")

	//Check for an AI
	JobDebug("DO, Running AI Check")
	FillAIPosition()
	JobDebug("DO, AI Check end")

	//Other jobs are now checked
	JobDebug("DO, Running Standard Check")


	// New job giving system by Donkie
	// This will cause lots of more loops, but since it's only done once it shouldn't really matter much at all.
	// Hopefully this will add more randomness and fairness to job giving.

	// Loop through all levels from high to low
	var/list/shuffledoccupations = shuffle(occupations)
	for(var/level in level_order)
		//Check the head jobs first each level
		CheckHeadPositions(level)

		// Loop through all unassigned players
		for(var/mob/dead/new_player/player in unassigned)
			if(PopcapReached() && !IS_PATRON(player.ckey))
				RejectPlayer(player)

			// Loop through all jobs
			for(var/datum/job/job in shuffledoccupations) // SHUFFLE ME BABY
				if(!job)
					continue

				if(is_banned_from(player.ckey, job.get_jobkeys_for_bancheck()))
					JobDebug("DO isbanned failed, Player: [player], Job:[english_list(job.get_jobkeys_for_bancheck())]")
					continue

				if(QDELETED(player))
					JobDebug("DO player deleted during job ban check")
					break

				if(!job.player_old_enough(player.client))
					JobDebug("DO player not old enough, Player: [player], Job:[job.get_jkey()]")
					continue

				if(job.required_playtime_remaining(player.client))
					JobDebug("DO player not enough xp, Player: [player], Job:[job.get_jkey()]")
					continue

				if(player.mind && (job.get_jkey() in player.mind.restricted_roles))
					JobDebug("DO incompatible with antagonist role, Player: [player], Job:[job.get_jkey()]")
					continue

				// If the player wants that job on this level, then try give it to him.
				if(player.client.prefs.active_character.job_preferences[job.get_jkey()] == level)
					// If the job isn't filled
					if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
						JobDebug("DO pass, Player: [player], Level:[level], Job:[job.get_jkey()==job.get_title() ? job.get_jkey() : "[job.get_jkey()]/[job.get_title()]"]")
						AssignRole(player, job.get_jkey())
						unassigned -= player
						break


	JobDebug("DO, Handling unassigned.")
	// Hand out random jobs to the people who didn't get any in the last check
	// Also makes sure that they got their preference correct
	for(var/mob/dead/new_player/player in unassigned)
		HandleUnassigned(player)

	JobDebug("DO, Handling unrejectable unassigned")
	//Mop up people who can't leave.
	for(var/mob/dead/new_player/player in unassigned) //Players that wanted to back out but couldn't because they're antags (can you feel the edge case?)
		if(!GiveRandomJob(player))
			if(!AssignRole(player, SSjob.overflow_role)) //If everything is already filled, make them an assistant
				return FALSE //Living on the edge, the forced antagonist couldn't be assigned to overflow role (bans, client age) - just reroll

	return validate_required_jobs(required_jobs)

/datum/controller/subsystem/job/proc/validate_required_jobs(list/required_jobs)
	if(!required_jobs.len)
		return TRUE
	for(var/required_group in required_jobs)
		var/group_ok = TRUE
		for(var/job_key in required_group)
			var/datum/job/J = GetJob(job_key)
			if(!J)
				SSticker.mode.setup_error = "Invalid job [job_key] in gamemode required jobs."
				return FALSE
			if(J.current_positions < required_group[job_key])
				group_ok = FALSE
				break
		if(group_ok)
			return TRUE
	SSticker.mode.setup_error = "Required jobs not present."
	return FALSE

//We couldn't find a job from prefs for this guy.
/datum/controller/subsystem/job/proc/HandleUnassigned(mob/dead/new_player/player)
	if(PopcapReached() && !IS_PATRON(player.ckey))
		RejectPlayer(player)
	else if(player.client.prefs.active_character.joblessrole == BEOVERFLOW)
		var/allowed_to_be_a_loser = !is_banned_from(player.ckey, SSjob.overflow_role)
		if(QDELETED(player) || !allowed_to_be_a_loser)
			RejectPlayer(player)
		else
			if(!AssignRole(player, SSjob.overflow_role))
				RejectPlayer(player)
	else if(player.client.prefs.active_character.joblessrole == BERANDOMJOB)
		if(!GiveRandomJob(player))
			RejectPlayer(player)
	else if(player.client.prefs.active_character.joblessrole == RETURNTOLOBBY)
		RejectPlayer(player)
	else //Something gone wrong if we got here.
		var/message = "DO: [player] fell through handling unassigned"
		JobDebug(message)
		log_game(message)
		message_admins(message)
		RejectPlayer(player)

//Gives the player the stuff he should have with his rank
/datum/controller/subsystem/job/proc/EquipRank(mob/M, job_key, joined_late = FALSE)
	var/mob/dead/new_player/newplayer
	var/mob/living/living_mob

	if(!joined_late)
		newplayer = M
		living_mob = newplayer.new_character
	else
		living_mob = M

	var/datum/job/job = GetJob(job_key)
	if(living_mob.mind)
		living_mob.mind.assign_station_role(job) // stores a job string in your mind

	//If we joined at roundstart we should be positioned at our workstation
	if(!joined_late)
		var/spawning_handled = FALSE
		var/obj/S = null
		if(HAS_TRAIT(SSstation, STATION_TRAIT_LATE_ARRIVALS) && job.random_spawns_possible)
			SendToLateJoin(living_mob)
			spawning_handled = TRUE
		else if(HAS_TRAIT(SSstation, STATION_TRAIT_RANDOM_ARRIVALS) && job.random_spawns_possible)
			DropLandAtRandomHallwayPoint(living_mob)
			spawning_handled = TRUE
		else if(HAS_TRAIT(SSstation, STATION_TRAIT_HANGOVER) && job.random_spawns_possible)
			SpawnLandAtRandom(living_mob, (typesof(/area/hallway) | typesof(/area/crew_quarters/bar) | typesof(/area/crew_quarters/dorms)))
			spawning_handled = TRUE
		else if(length(GLOB.jobspawn_overrides[job_key]))
			S = pick(GLOB.jobspawn_overrides[job_key])
		else
			var/spawn_successful = FALSE
			var/attempts = 1 + job.is_gimmick() // if a job is gimmick, we'll check their spawn twice, in their job, and in their origin job
			while(attempts--)
				var/checks_original_path = ( attempts ? FALSE : TRUE )
				for(var/obj/effect/landmark/start/sloc in GLOB.start_landmarks_list)
					if(sloc.name != job.get_jkey(checks_original_path))
						S = sloc // so we can revert to spawning them on top of eachother if something goes wrong
						continue // ↑↑↑ this comment is ancient. I don't get what this means
					if(locate(/mob/living) in sloc.loc)
						continue
					S = sloc
					sloc.used = TRUE
					spawn_successful = TRUE
					break
				if(spawn_successful) // if a gimmick job finds its spawn location, no need for an additional attempt
					break
		if(S)
			S.JoinPlayerHere(living_mob, FALSE)
		if(!S && !spawning_handled) //if there isn't a spawnpoint send them to latejoin, if there's no latejoin go yell at your mapper
			log_world("Couldn't find a round start spawn point for [job_key]")
			SendToLateJoin(living_mob)

	var/displaying_job_title = living_mob.mind.get_display_station_role()
	to_chat(M, "<b>You are the [displaying_job_title].</b>")
	if(job)
		var/new_mob = job.equip(living_mob, null, null, joined_late , null, M.client)
		if(ismob(new_mob))
			living_mob = new_mob
			if(!joined_late)
				newplayer.new_character = living_mob
			else
				M = living_mob

		SSpersistence.antag_rep_change[M.client.ckey] += job.GetAntagRep()

		if(M.client.holder)
			if(CONFIG_GET(flag/auto_deadmin_players) || (M.client.prefs?.toggles & PREFTOGGLE_DEADMIN_ALWAYS))
				M.client.holder.auto_deadmin()
			else
				handle_auto_deadmin_roles(M.client, job_key)
		to_chat(M, "<b>As the [displaying_job_title] you answer directly to [job.notify_your_supervisor()]. Special circumstances may change this.</b>")
		job.radio_help_message(M)
		if(job.req_admin_notify)
			to_chat(M, "<b>You are playing a job that is important for Game Progression. If you have to disconnect, please notify the admins via adminhelp.</b>")
		if(CONFIG_GET(number/minimal_access_threshold))
			to_chat(M, "<span class='notice'><B>As this station was initially staffed with a [CONFIG_GET(flag/jobs_have_minimal_access) ? "full crew, only your job's necessities" : "skeleton crew, additional access may"] have been added to your ID card.</B></span>")
	if(ishuman(living_mob))
		var/mob/living/carbon/human/wageslave = living_mob
		if(wageslave.mind?.account_id)
			living_mob.add_memory("Your account ID is [wageslave.mind.account_id].")
	if(job && living_mob)
		job.after_spawn(living_mob, M, joined_late) // note: this happens before the mob has a key! M will always have a client, living_mob might not.

	if(living_mob.mind && !living_mob.mind.crew_objectives.len)
		give_crew_objective(living_mob.mind, M)

	return living_mob

/datum/controller/subsystem/job/proc/handle_auto_deadmin_roles(client/C, job_key)
	if(!C?.holder)
		return TRUE
	var/datum/job/job = GetJob(job_key)
	if(!job)
		return
	if((job.auto_deadmin_role_flags & PREFTOGGLE_DEADMIN_POSITION_HEAD) && (CONFIG_GET(flag/auto_deadmin_heads) || (C.prefs?.toggles & PREFTOGGLE_DEADMIN_POSITION_HEAD)))
		return C.holder.auto_deadmin()
	else if((job.auto_deadmin_role_flags & PREFTOGGLE_DEADMIN_POSITION_SECURITY) && (CONFIG_GET(flag/auto_deadmin_security) || (C.prefs?.toggles & PREFTOGGLE_DEADMIN_POSITION_SECURITY)))
		return C.holder.auto_deadmin()
	else if((job.auto_deadmin_role_flags & PREFTOGGLE_DEADMIN_POSITION_SILICON) && (CONFIG_GET(flag/auto_deadmin_silicons) || (C.prefs?.toggles & PREFTOGGLE_DEADMIN_POSITION_SILICON))) //in the event there's ever psuedo-silicon roles added, ie synths.
		return C.holder.auto_deadmin()

/datum/controller/subsystem/job/proc/setup_officer_positions()
	var/datum/job/J = SSjob.GetJob("Security Officer")
	if(!J)
		CRASH("setup_officer_positions(): Security officer job is missing")

	var/ssc = CONFIG_GET(number/security_scaling_coeff)
	if(ssc > 0)
		if(J.spawn_positions > 0)
			var/officer_positions = min(12, max(J.spawn_positions, round(unassigned.len / ssc))) //Scale between configured minimum and 12 officers
			JobDebug("Setting open security officer positions to [officer_positions]")
			J.total_positions = officer_positions
			J.spawn_positions = officer_positions

	//Spawn some extra eqipment lockers if we have more than 5 officers
	var/equip_needed = J.total_positions
	if(equip_needed < 0) // -1: infinite available slots
		equip_needed = 12
	for(var/i=equip_needed-5, i>0, i--)
		if(GLOB.secequipment.len)
			var/spawnloc = GLOB.secequipment[1]
			new /obj/structure/closet/secure_closet/security/sec(spawnloc)
			GLOB.secequipment -= spawnloc
		else //We ran out of spare locker spawns!
			break


/datum/controller/subsystem/job/proc/LoadJobs()
	var/jobstext = rustg_file_read("[global.config.directory]/jobs.txt")
	for(var/datum/job/J in occupations)
		var/regex/jobs = new("[J.get_jkey()]=(-1|\\d+),(-1|\\d+)")
		if(jobs.Find(jobstext))
			J.total_positions = text2num(jobs.group[1])
			J.spawn_positions = text2num(jobs.group[2])
		else
			log_runtime("Error in /datum/controller/subsystem/job/proc/LoadJobs: Failed to locate job of job path [J.get_jkey()] in jobs.txt")

/datum/controller/subsystem/job/proc/HandleFeedbackGathering()
	for(var/datum/job/job in occupations)
		var/high = 0 //high
		var/medium = 0 //medium
		var/low = 0 //low
		var/never = 0 //never
		var/banned = 0 //banned
		var/young = 0 //account too young
		for(var/mob/dead/new_player/player in GLOB.player_list)
			if(!(player.ready == PLAYER_READY_TO_PLAY && player.mind && !player.mind.get_job()))
				continue //This player is not ready
			if(is_banned_from(player.ckey, job.get_jkey()) || QDELETED(player))
				banned++
				continue
			if(!job.player_old_enough(player.client))
				young++
				continue
			if(job.required_playtime_remaining(player.client))
				young++
				continue
			switch(player.client.prefs.active_character.job_preferences[job.get_jkey()])
				if(JP_HIGH)
					high++
				if(JP_MEDIUM)
					medium++
				if(JP_LOW)
					low++
				else
					never++
		SSblackbox.record_feedback("nested tally", "job_preferences", high, list("[job.get_jkey()]", "high"))
		SSblackbox.record_feedback("nested tally", "job_preferences", medium, list("[job.get_jkey()]", "medium"))
		SSblackbox.record_feedback("nested tally", "job_preferences", low, list("[job.get_jkey()]", "low"))
		SSblackbox.record_feedback("nested tally", "job_preferences", never, list("[job.get_jkey()]", "never"))
		SSblackbox.record_feedback("nested tally", "job_preferences", banned, list("[job.get_jkey()]", "banned"))
		SSblackbox.record_feedback("nested tally", "job_preferences", young, list("[job.get_jkey()]", "young"))

/datum/controller/subsystem/job/proc/PopcapReached()
	var/hpc = CONFIG_GET(number/hard_popcap)
	var/epc = CONFIG_GET(number/extreme_popcap)
	if(hpc || epc)
		var/relevent_cap = max(hpc, epc)
		if((initial_players_to_assign - unassigned.len) >= relevent_cap)
			return 1
	return 0

/datum/controller/subsystem/job/proc/RejectPlayer(mob/dead/new_player/player)
	if(player.mind?.get_display_special_role())
		return
	if(PopcapReached() && !IS_PATRON(player.ckey))
		JobDebug("Popcap overflow Check observer located, Player: [player]")
	JobDebug("Player rejected :[player]")
	to_chat(player, "<b>You have failed to qualify for any job you desired.</b>")
	unassigned -= player
	SSticker.mode.antag_candidates -= player
	player.ready = PLAYER_NOT_READY


/datum/controller/subsystem/job/Recover()
	set waitfor = FALSE
	var/oldjobs = SSjob.occupations
	sleep(20)
	for (var/datum/job/J in oldjobs)
		INVOKE_ASYNC(src, PROC_REF(RecoverJob), J)

/datum/controller/subsystem/job/proc/RecoverJob(datum/job/J)
	var/datum/job/newjob = GetJob(J.get_jkey())
	if (!istype(newjob))
		return
	newjob.total_positions = J.total_positions
	newjob.spawn_positions = J.spawn_positions
	newjob.current_positions = J.current_positions

/atom/proc/JoinPlayerHere(mob/M, buckle)
	// By default, just place the mob on the same turf as the marker or whatever.
	M.forceMove(get_turf(src))

/obj/structure/chair/JoinPlayerHere(mob/M, buckle)
	// Placing a mob in a chair will attempt to buckle it, or else fall back to default.
	if (buckle && isliving(M) && buckle_mob(M, FALSE, FALSE))
		return
	..()

/datum/controller/subsystem/job/proc/SendToLateJoin(mob/M, buckle = TRUE)
	var/atom/destination
	if(M.mind && M.mind.get_job() && length(GLOB.jobspawn_overrides[M.mind.get_job()])) //We're doing something special today.
		destination = pick(GLOB.jobspawn_overrides[M.mind.get_job()])
		destination.JoinPlayerHere(M, FALSE)
		return

	if(latejoin_trackers.len)
		destination = pick(latejoin_trackers)
		destination.JoinPlayerHere(M, buckle)
		return

	//bad mojo
	var/area/shuttle/arrival/arrivals_area = GLOB.areas_by_type[/area/shuttle/arrival]
	if(arrivals_area)
		//first check if we can find a chair
		var/obj/structure/chair/C = locate() in arrivals_area
		if(C)
			C.JoinPlayerHere(M, buckle)
			return

		//last hurrah
		var/list/turf/available_turfs = list()
		for(var/turf/arrivals_turf in arrivals_area)
			if(!arrivals_turf.is_blocked_turf(TRUE))
				available_turfs += arrivals_turf
		if(available_turfs.len)
			destination = pick(available_turfs)
			destination.JoinPlayerHere(M, FALSE)
			return

	//pick an open spot on arrivals and dump em
	var/list/arrivals_turfs = shuffle(get_area_turfs(/area/shuttle/arrival))
	if(arrivals_turfs.len)
		for(var/turf/T in arrivals_turfs)
			if(!T.is_blocked_turf(TRUE))
				T.JoinPlayerHere(M, FALSE)
				return
		//last chance, pick ANY spot on arrivals and dump em
		destination = arrivals_turfs[1]
		destination.JoinPlayerHere(M, FALSE)
	else
		var/msg = "Unable to send mob [M] to late join!"
		message_admins(msg)
		CRASH(msg)

///Spawns specified mob at a random spot in the hallways
/datum/controller/subsystem/job/proc/SpawnLandAtRandom(mob/living/living_mob, areas = typesof(/area/hallway))
	var/turf/spawn_turf = get_safe_random_station_turfs(areas)

	if(!spawn_turf)
		SendToLateJoin(living_mob)
		return

	living_mob.forceMove(spawn_turf)

///Lands specified mob at a random spot in the hallways
/datum/controller/subsystem/job/proc/DropLandAtRandomHallwayPoint(mob/living/living_mob)
	var/turf/spawn_turf = get_safe_random_station_turfs(typesof(/area/hallway))

	if(!spawn_turf)
		SendToLateJoin(living_mob)
		return

	var/obj/structure/closet/supplypod/centcompod/toLaunch = new()
	living_mob.forceMove(toLaunch)
	new /obj/effect/pod_landingzone(spawn_turf, toLaunch)

///////////////////////////////////
//Keeps track of all living heads//
///////////////////////////////////
/datum/controller/subsystem/job/proc/get_living_heads()
	. = list()
	for(var/mob/living/carbon/human/player in GLOB.alive_mob_list)
		if(player.stat != DEAD && player.mind?.has_job(GLOB.command_positions))
			. |= player.mind


////////////////////////////
//Keeps track of all heads//
////////////////////////////
/datum/controller/subsystem/job/proc/get_all_heads()
	. = list()
	for(var/i in GLOB.mob_list)
		var/mob/player = i
		if(player.mind?.has_job(GLOB.command_positions))
			. |= player.mind

//////////////////////////////////////////////
//Keeps track of all living security members//
//////////////////////////////////////////////
/datum/controller/subsystem/job/proc/get_living_sec()
	. = list()
	for(var/mob/living/carbon/human/player in GLOB.carbon_list)
		if(player.stat != DEAD && player?.mind.has_job(GLOB.security_positions))
			. |= player.mind

////////////////////////////////////////
//Keeps track of all  security members//
////////////////////////////////////////
/datum/controller/subsystem/job/proc/get_all_sec()
	. = list()
	for(var/mob/living/carbon/human/player in GLOB.carbon_list)
		if(player.mind?.has_job(GLOB.security_positions))
			. |= player.mind

/datum/controller/subsystem/job/proc/JobDebug(message)
	log_job_debug(message)

/obj/item/paper/fluff/spare_id_safe_code
	name = "Nanotrasen-Approved Spare ID Safe Code"
	desc = "Proof that you have been approved for Captaincy, with all its glory and all its horror."

/obj/item/paper/fluff/spare_id_safe_code/Initialize(mapload)
	var/id_safe_code = SSjob.spare_id_safe_code
	default_raw_text = "Captain's Spare ID safe code combination: [id_safe_code ? id_safe_code : "\[REDACTED\]"]<br><br>The spare ID can be found in its dedicated safe on the bridge."
	return ..()

/datum/controller/subsystem/job/proc/promote_to_captain(var/mob/dead/new_player/new_captain, acting_captain = FALSE)
	var/mob/living/carbon/human/H = new_captain.new_character
	if(!new_captain)
		CRASH("Cannot promote [new_captain.ckey], there is no new_character attached to him.")

	if(!spare_id_safe_code)
		CRASH("Cannot promote [H.real_name] to Captain, there is no spare_id_safe_code.")

	var/paper = new /obj/item/paper/fluff/spare_id_safe_code(H.loc)
	var/list/slots = list(
		"in your left pocket" = ITEM_SLOT_LPOCKET,
		"in your right pocket" = ITEM_SLOT_RPOCKET,
		"in your backpack" = ITEM_SLOT_BACKPACK,
		"in your hands" = ITEM_SLOT_HANDS
	)
	var/where = H.equip_in_one_of_slots(paper, slots, FALSE) || "at your feet"

	if(acting_captain)
		to_chat(new_captain, "<span class='notice'>Due to your position in the chain of command, you have been granted access to captain's spare ID. You can find in important note about this [where].</span>")
	else
		to_chat(new_captain, "<span class='notice'>You can find the code to obtain your spare ID from the secure safe on the Bridge [where].</span>")

	// Force-give their ID card bridge access.
	if(H.wear_id?.GetID())
		var/obj/item/card/id/id_card = H.wear_id
		if(!(ACCESS_HEADS in id_card.access))
			LAZYADD(id_card.access, ACCESS_HEADS)
