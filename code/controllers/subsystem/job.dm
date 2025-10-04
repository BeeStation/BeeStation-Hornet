SUBSYSTEM_DEF(job)
	name = "Jobs"
	init_order = INIT_ORDER_JOBS
	flags = SS_NO_FIRE

	var/list/occupations = list()		//List of all jobs
	var/list/datum/job/name_occupations = list()	//Dict of all jobs, keys are titles
	var/list/type_occupations = list()	//Dict of all jobs, keys are types
	var/list/unassigned = list()		//Players who need jobs
	var/initial_players_to_assign = 0 	//used for checking against population caps

	var/list/prioritized_jobs = list()
	var/list/latejoin_trackers = list()	//Don't read this list, use GetLateJoinTurfs() instead

	var/overflow_role = JOB_NAME_ASSISTANT

	var/list/level_order = list(JP_HIGH,JP_MEDIUM,JP_LOW)

	var/spare_id_safe_code = ""

	var/list/chain_of_command = list(
		"Captain" = 1,				//Not used yet but captain is first in chain_of_command
		"Head of Personnel" = 2,
		"Research Director" = 3,
		"Chief Engineer" = 4,
		"Chief Medical Officer" = 5,
		"Head of Security" = 6)

	//Crew Objective stuff
	var/list/crew_obj_list = list()
	var/list/crew_obj_jobs = list()

	/// jobs that are not allowed in HoP job manager
	var/list/job_manager_blacklisted = list(
		JOB_NAME_AI,
		JOB_NAME_ASSISTANT,
		JOB_NAME_CYBORG,
		JOB_NAME_POSIBRAIN,
		JOB_NAME_CAPTAIN,
		JOB_NAME_HEADOFPERSONNEL,
		JOB_NAME_HEADOFSECURITY,
		JOB_NAME_CHIEFENGINEER,
		JOB_NAME_RESEARCHDIRECTOR,
		JOB_NAME_CHIEFMEDICALOFFICER,
		JOB_NAME_DEPUTY,
		JOB_NAME_GIMMICK,
		JOB_NAME_PRISONER)

	/// If TRUE, some player has been assigned Captaincy or Acting Captaincy at some point during the shift and has been given the spare ID safe code.
	var/assigned_captain = FALSE
	/// Whether the emergency safe code has been requested via a comms console on shifts with no Captain or Acting Captain.
	var/safe_code_requested = FALSE
	/// Timer ID for the emergency safe code request.
	var/safe_code_timer_id
	/// The loc to which the emergency safe code has been requested for delivery.
	var/turf/safe_code_request_loc

/datum/controller/subsystem/job/Initialize()
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

	return SS_INIT_SUCCESS

/datum/controller/subsystem/job/Recover()
	occupations = SSjob.occupations
	name_occupations = SSjob.name_occupations
	type_occupations = SSjob.type_occupations
	unassigned = SSjob.unassigned
	initial_players_to_assign = SSjob.initial_players_to_assign

	prioritized_jobs = SSjob.prioritized_jobs
	latejoin_trackers = SSjob.latejoin_trackers

	overflow_role = SSjob.overflow_role

	spare_id_safe_code = SSjob.spare_id_safe_code
	crew_obj_list = SSjob.crew_obj_list
	crew_obj_jobs = SSjob.crew_obj_jobs

	job_manager_blacklisted = SSjob.job_manager_blacklisted

/datum/controller/subsystem/job/proc/set_overflow_role(new_overflow_role)
	var/datum/job/new_overflow = GetJob(new_overflow_role)
	if(!new_overflow || new_overflow.lock_flags)
		CRASH("[new_overflow_role] was used for an overflow role, but it's not allowed. BITFLAG: [new_overflow?.lock_flags]")
	var/cap = CONFIG_GET(number/overflow_cap)

	new_overflow.allow_bureaucratic_error = FALSE
	new_overflow.total_positions = cap

	if(new_overflow_role != overflow_role)
		var/datum/job/old_overflow = GetJob(overflow_role)
		old_overflow.allow_bureaucratic_error = initial(old_overflow.allow_bureaucratic_error)
		old_overflow.total_positions = initial(old_overflow.total_positions)
		overflow_role = new_overflow_role
		JobDebug("Overflow role set to : [new_overflow_role]")

/datum/controller/subsystem/job/proc/SetupOccupations(faction = "Station")
	occupations = list()
	var/list/all_jobs = subtypesof(/datum/job)
	if(!all_jobs.len)
		to_chat(world, span_boldannounce("Error setting up jobs, no job datums found."))
		return 0

	for(var/datum/job/each_job as anything in all_jobs)
		each_job = new each_job()
		if(each_job.faction != faction)
			continue
		occupations += each_job
		name_occupations[each_job.title] = each_job
		type_occupations[each_job.type] = each_job
	if(SSmapping.map_adjustment)
		SSmapping.map_adjustment.job_change()
		log_world("Applied '[SSmapping.map_adjustment.map_file_name]' map adjustment: job_change()")

	return 1

/datum/controller/subsystem/job/proc/is_job_empty(rank)
	return GetJob(rank).current_positions == 0

/datum/controller/subsystem/job/proc/GetJob(rank)
	RETURN_TYPE(/datum/job)
	if(!rank)
		CRASH("proc has taken no job name")
	if(!occupations.len)
		SetupOccupations()
	if(!name_occupations[rank])
		CRASH("job name [rank] is not valid")
	return name_occupations[rank]

/datum/controller/subsystem/job/proc/GetJobType(jobtype)
	RETURN_TYPE(/datum/job)
	if(!jobtype)
		CRASH("proc has taken no job type")
	if(!occupations.len)
		SetupOccupations()
	if(!type_occupations[jobtype])
		CRASH("job type [jobtype] is not valid")
	return type_occupations[jobtype]

/datum/controller/subsystem/job/proc/GetJobActiveDepartment(rank)
	if(!rank)
		CRASH("proc has taken no job name")
	if(!occupations.len)
		SetupOccupations()
	if(!name_occupations[rank])
		CRASH("job name [rank] is not valid")
	var/datum/job/J = name_occupations[rank]
	return J.departments

/datum/controller/subsystem/job/proc/AssignRole(mob/dead/new_player/authenticated/player, rank, latejoin = FALSE)
	JobDebug("Running AR, Player: [player], Rank: [rank], LJ: [latejoin]")
	if(player?.mind && rank)
		var/datum/job/job = GetJob(rank)
		if(!job || job.lock_flags)
			return FALSE
		if(QDELETED(player) || is_banned_from(player.ckey, rank))
			return FALSE
		if(!job.player_old_enough(player.client))
			return FALSE
		if(job.required_playtime_remaining(player.client))
			return FALSE
		var/position_limit = job.get_spawn_position_count()
		// Unassign our previous job, to prevent double counts
		if(player.mind.assigned_role)
			var/datum/job/current_job = SSjob.GetJob(player.mind.assigned_role)
			current_job.current_positions--
			player.mind.assigned_role = null
		player.mind.assigned_role = rank
		unassigned -= player
		job.current_positions++
		if(!latejoin)
			player.client.inc_metabalance(METACOIN_READY_UP_REWARD, reason = "Joined the station as a roundstart crew member.")
		JobDebug("Player: [player] is now Rank: [rank], JCP:[job.current_positions], JPL:[position_limit]. Group size: [job.count_players_in_group()]")
		return TRUE
	JobDebug("AR has failed, Player: [player], Rank: [rank]")
	return FALSE

/datum/controller/subsystem/job/proc/FreeRole(rank)
	if(!rank)
		return
	JobDebug("Freeing role: [rank]")
	var/datum/job/job = GetJob(rank)
	if(!job)
		return FALSE
	job.current_positions = max(0, job.current_positions - 1)

/datum/controller/subsystem/job/proc/FindOccupationCandidates(datum/job/job, level)
	JobDebug("Running FOC, Job: [job], Level: [level]")
	var/list/candidates = list()
	for(var/mob/dead/new_player/authenticated/player in unassigned)
		if(QDELETED(player) || is_banned_from(player.ckey, job.title))
			JobDebug("FOC isbanned failed, Player: [player]")
			continue
		if(!job.player_old_enough(player.client))
			JobDebug("FOC player not old enough, Player: [player]")
			continue
		if(job.required_playtime_remaining(player.client))
			JobDebug("FOC player not enough xp, Player: [player]")
			continue
		if(player.mind && (job.title in player.mind.restricted_roles))
			JobDebug("FOC incompatible with antagonist role, Player: [player]")
			continue
		if(player.client.prefs.job_preferences[job.title] == level)
			JobDebug("FOC pass, Player: [player], Level:[level]")
			candidates += player
	return candidates

/datum/controller/subsystem/job/proc/GiveRandomJob(mob/dead/new_player/authenticated/player)
	JobDebug("GRJ Giving random job, Player: [player]")
	. = FALSE
	for(var/datum/job/job in shuffle(occupations))
		if(!job || job.lock_flags)
			continue

		if(istype(job, GetJob(SSjob.overflow_role))) // We don't want to give him assistant, that's boring!
			continue

		if(job.title in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND)) //If you want a command position, select it!
			continue

		if(QDELETED(player))
			JobDebug("GRJ isbanned failed, Player deleted")
			break

		if(is_banned_from(player.ckey, job.title))
			JobDebug("GRJ isbanned failed, Player: [player], Job: [job.title]")
			continue

		if(!job.player_old_enough(player.client))
			JobDebug("GRJ player not old enough, Player: [player]")
			continue

		if(job.required_playtime_remaining(player.client))
			JobDebug("GRJ player not enough xp, Player: [player]")
			continue

		if(player.mind && (job.title in player.mind.restricted_roles))
			JobDebug("GRJ incompatible with antagonist role, Player: [player], Job: [job.title]")
			continue

		var/spawn_position_count = job.get_spawn_position_count()
		if((job.current_positions < spawn_position_count) || (spawn_position_count == -1))
			JobDebug("GRJ Random job given, Player: [player], Job: [job]")
			if(AssignRole(player, job.title))
				return TRUE

/datum/controller/subsystem/job/proc/ResetOccupations()
	JobDebug("Occupations reset.")
	for(var/mob/dead/new_player/authenticated/player in GLOB.player_list)
		if((player) && (player.mind))
			player.mind.assigned_role = null
			player.mind.special_role = null
			SSpersistence.antag_rep_change[player.ckey] = 0
	SetupOccupations()
	unassigned = list()
	return

/** Proc DivideOccupations
 *  fills var "assigned_role" for all ready players.
 *  This proc must not have any side effect besides of modifying "assigned_role".
 **/
/datum/controller/subsystem/job/proc/DivideOccupations()
	//Setup new player list and get the jobs list
	JobDebug("Running DO")

	//Holder for Triumvirate is stored in the SSticker, this just processes it
	if(SSticker.triai)
		for(var/datum/job/ai/A in occupations)
			A.total_positions = 3
		for(var/obj/effect/landmark/start/ai/secondary/S in GLOB.start_landmarks_list)
			S.latejoin_active = TRUE

	//Get the players who are ready
	for(var/mob/dead/new_player/authenticated/player in GLOB.player_list)
		if(player.ready == PLAYER_READY_TO_PLAY && player.mind && !player.mind.assigned_role)
			if(!player.check_preferences())
				player.ready = PLAYER_NOT_READY
			else
				unassigned += player

	initial_players_to_assign = unassigned.len

	JobDebug("DO, Len: [unassigned.len]")
	if(unassigned.len == 0)
		return TRUE

	//Shuffle players and jobs
	unassigned = shuffle(unassigned)

	HandleFeedbackGathering()

	//Other jobs are now checked
	JobDebug("DO, Running Standard Check")

	// New job giving system by PowerfulBacon
	// Attempting to create perfect configurations leads to players often getting the same
	// jobs over and over, since if they have 1 job that nobody else has picked then it will
	// try to take them (especially with command roles).
	// This system favours giving out jobs to players who have highly random job selections
	// first, so that players asking for a random experience aren't given only the jobs that
	// nobody else wants to do, which you would get with stable-marriage style algorithms
	//
	// In these steps, we ignore high priority jobs and instead create a random ordering of
	// the medium jobs that the player has selected.
	// Example:
	// Player A: Job C, Job B, (High priority: E)
	// Player B: Job A, Job C, Job D (High priority: E)
	// Player C: Job B, Job D
	// Player D: Job A, Job E
	// Step 1: Create random orderings
	// A: [B, C]
	// B: [C, D, A]
	// C: [D, B]
	// D: [A, E]
	// Step 2: Sort these by the number of items in the list, sorting it randomly when
	// the values are equal. The player will get the first job in the array that has not
	// already been selected by someone previously. This is represented by the *
	// B: [C*, D, A] (Gets job C because it is untaken)
	// D: [A*, E] (Gets job A because it is untaken)
	// A: [C, B*] (Gets job B because C is taken by person B)
	// C: [D*, B] (Gets job D because it is untaken
	// Step 3: Find all of the jobs that have additional spaces to allocate
	// Additional spaces: E
	// Step 4: Create a random ordering of all players
	// D, C, B, A
	// Step 5: Assign any high priority job roles that haven't been taken yet, and recalculate
	// the random job ordering list.
	// D: [A*, E]
	// B: E* -> [C, D, A] (Gets E because it has not been taken yet, which frees up job C)
	// C: E -> [D*, B] (Keeps job D because job E was taken by B)
	// A: [C*, B] (Since player B changed from job C to job E, our highest priority job (Job C) is now available, so we switch to that instead)
	// Step 6: Find all players that do not have a job, and repeat step 1 by including only their low priority job roles (ignoring high priority).
	//
	// High popularity jobs will still be less likely to be selected, so it isn't perfectly balanced, however
	// this system balances the probabilities as much as possible.
	// High priority jobs are done at the end so that it doesn't disrupt the probability selection for other
	// players. If a job has a low demand, you will always switch to that if you select it as high priority
	// but if a job has a high demand, you will only get it if the players who had more job roles selected
	// wasn't assigned it first (even if you are the only one with it set to high priority, and everyone else
	// had it set to medium).

	// Shuffle the unassigned player list for fairness
	shuffle_inplace(unassigned)

	// Firstly, remove any players over the pop-cap
	for(var/mob/dead/new_player/authenticated/player in unassigned)
		if(PopcapReached() && !IS_PATRON(player.ckey))
			RejectPlayer(player)

	assign_roles(JP_MEDIUM)
	assign_roles(JP_LOW)

	JobDebug("DO, Handling unassigned.")
	// Hand out random jobs to the people who didn't get any in the last check
	// Also makes sure that they got their preference correct
	for(var/mob/dead/new_player/authenticated/player in unassigned)
		HandleUnassigned(player)

	JobDebug("DO, Handling unrejectable unassigned")
	//Mop up people who can't leave.
	for(var/mob/dead/new_player/authenticated/player in unassigned) //Players that wanted to back out but couldn't because they're antags (can you feel the edge case?)
		if(!GiveRandomJob(player))
			if(!AssignRole(player, SSjob.overflow_role)) //If everything is already filled, make them an assistant
				return FALSE //Living on the edge, the forced antagonist couldn't be assigned to overflow role (bans, client age) - just reroll

	//Scale number of open security officer slots to population
	setup_officer_positions()

	return TRUE

/datum/controller/subsystem/job/proc/assign_roles(priority = JP_MEDIUM)
	// Create random orderings for all players
	var/list/sorted_orderings = list()
	var/list/random_orderings = list()
	// Step 1: Generate random orderings for the players medium jobs
	for(var/mob/dead/new_player/authenticated/player in unassigned)
		var/list/available_jobs = list()
		// Find all jobs that we are actually able to be
		for(var/datum/job/job in occupations)
			if (!is_valid_job(player, job, priority))
				continue
			JobDebug("Preparing, Player: [player], Job:[job.title]")
			available_jobs += job
		// Create random orderings
		shuffle_inplace(available_jobs)
		// Use the same reference, so that we only have to update one
		sorted_orderings[player] = available_jobs
		random_orderings[player] = available_jobs
		JobDebug("DO [player.ckey] was given the job priority list [jointext(available_jobs, ",")]")
	// Step 2: Sort the list by the number of availble jobs that each person has, keeping it
	// random when the amount is the same
	shuffle_inplace(sorted_orderings)
	shuffle_inplace(random_orderings)
	sorted_orderings = sortTim(sorted_orderings, GLOBAL_PROC_REF(cmp_list_size_dsc), TRUE)
	// Step 3: Assign provisional jobs
	for(var/mob/dead/new_player/authenticated/player in sorted_orderings)
		// Get the first available job for this player
		for (var/datum/job/job in sorted_orderings[player])
			var/job_position_count = job.get_spawn_position_count()
			if (job.current_positions >= job_position_count && job_position_count != -1)
				continue
			// Provisional assignment
			job.current_positions++
			player.mind.assigned_role = job.title
			JobDebug("DO [player.ckey] was assigned the provisional job [job.title]")
			break
	// Step 4: Create a random ordering of players
	// The player list is already shuffled, so we will re-use that for player preference
	// Step 5: Assign high priority job roles
	if (priority == JP_MEDIUM)
		for(var/mob/dead/new_player/authenticated/player in sorted_orderings)
			// Assign high priority jobs
			for(var/datum/job/job in occupations)
				if (!is_valid_job(player, job, JP_HIGH))
					continue
				var/list/player_job_list = sorted_orderings[player]
				// Add this job to the start of the player's preferences list
				player_job_list.Insert(1, job)
				JobDebug("DO [player.ckey] requested [job.title] as a high priority job. Updated assignment list: [jointext(player_job_list, ",")]")
	// Until we reach a stable state or the upper bound is reached, repeatedly
	// try to get a higher priority role
	var/iteration_limit = 10
	var/changed = TRUE
	while (changed && iteration_limit-- > 0)
		changed = FALSE
		for(var/mob/dead/new_player/authenticated/player in random_orderings)
			var/list/player_preferences = random_orderings[player]
			// Reassign to a new job
			for (var/datum/job/job in player_preferences)
				// We already have this job, so don't need to reassign
				if (player.mind.assigned_role == job.title)
					break
				// This job is full, skip
				var/job_position_count = job.get_spawn_position_count()
				if (job.current_positions >= job_position_count && job_position_count != -1)
					continue
				JobDebug("DO [player.ckey] switched from job [player.mind.assigned_role] to job [job.title]")
				// Unassign our previous job
				if (player.mind.assigned_role)
					var/datum/job/current_job = SSjob.GetJob(player.mind.assigned_role)
					current_job.current_positions--
					player.mind.assigned_role = null
				// Provisional assignment
				job.current_positions++
				player.mind.assigned_role = job.title
				changed = TRUE
				break
	// Step 5: Assign job roles that we have so far
	for(var/mob/dead/new_player/authenticated/player in sorted_orderings)
		if (!player.mind.assigned_role)
			JobDebug("DO [player.ckey] has no medium or high priority jobs assigned")
			continue
		AssignRole(player, player.mind.assigned_role)
		unassigned -= player

/datum/controller/subsystem/job/proc/is_valid_job(mob/dead/new_player/authenticated/player, datum/job/job, required_priority)
	if(!job || job.lock_flags)
		return FALSE
	if(is_banned_from(player.ckey, job.title))
		JobDebug("DO isbanned failed, Player: [player], Job:[job.title]")
		return FALSE
	if(QDELETED(player))
		JobDebug("DO player deleted during job ban check")
		return FALSE
	if(!job.player_old_enough(player.client))
		JobDebug("DO player not old enough, Player: [player], Job:[job.title]")
		return FALSE
	if(job.required_playtime_remaining(player.client))
		JobDebug("DO player not enough xp, Player: [player], Job:[job.title]")
		return FALSE
	if(player.mind && (job.title in player.mind.restricted_roles))
		JobDebug("DO incompatible with antagonist role, Player: [player], Job:[job.title]")
		return FALSE
	if(player.client.prefs.job_preferences[job.title] != required_priority && !(job.gimmick && player.client.prefs.job_preferences["Gimmick"] == required_priority))
		return FALSE
	return TRUE

//We couldn't find a job from prefs for this guy.
/datum/controller/subsystem/job/proc/HandleUnassigned(mob/dead/new_player/authenticated/player)
	var/jobless_role = player.client.prefs.read_character_preference(/datum/preference/choiced/jobless_role)

	if(PopcapReached() && !IS_PATRON(player.ckey))
		RejectPlayer(player)
		return

	switch (jobless_role)
		if (BEOVERFLOW)
			var/datum/job/overflow_role_datum = GetJob(overflow_role)
			if(!istype(overflow_role_datum))
				stack_trace("Invalid overflow_role set ([overflow_role]), please make sure it matches a valid job datum.")
				RejectPlayer(player)
			else
				var/allowed_to_be_a_loser = !is_banned_from(player.ckey, overflow_role_datum.title)
				if(QDELETED(player) || !allowed_to_be_a_loser)
					RejectPlayer(player)
				else
					if(!AssignRole(player, overflow_role_datum.title))
						RejectPlayer(player)
		if (BERANDOMJOB)
			if(!GiveRandomJob(player))
				RejectPlayer(player)
		if (RETURNTOLOBBY)
			RejectPlayer(player)
		else //Something gone wrong if we got here.
			var/message = "DO: [player] fell through handling unassigned"
			JobDebug(message)
			log_game(message)
			message_admins(message)
			RejectPlayer(player)


//Gives the player the stuff he should have with his rank
/datum/controller/subsystem/job/proc/EquipRank(mob/M, rank, joined_late = FALSE)
	var/mob/dead/new_player/authenticated/newplayer
	var/mob/living/living_mob

	if(!joined_late)
		newplayer = M
		living_mob = newplayer.new_character
	else
		living_mob = M

	var/datum/job/job = GetJob(rank)

	living_mob.job = rank

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
		else if(length(GLOB.jobspawn_overrides[rank]))
			S = pick(GLOB.jobspawn_overrides[rank])
		else
			for(var/obj/effect/landmark/start/sloc in GLOB.start_landmarks_list)
				if(sloc.name != rank)
					S = sloc //so we can revert to spawning them on top of eachother if something goes wrong
					continue
				if(locate(/mob/living) in sloc.loc)
					continue
				S = sloc
				sloc.used = TRUE
				break
		if(S)
			S.JoinPlayerHere(living_mob, FALSE)
		if(!S && !spawning_handled) //if there isn't a spawnpoint send them to latejoin, if there's no latejoin go yell at your mapper
			log_world("Couldn't find a round start spawn point for [rank]")
			SendToLateJoin(living_mob)


	if(living_mob.mind)
		living_mob.mind.assigned_role = rank
	to_chat(M, "<b>You are the [rank].</b>")
	if(job)
		var/new_mob = job.equip(living_mob, null, null, joined_late , null, M.client)
		if(ismob(new_mob))
			living_mob = new_mob
			if(!joined_late)
				newplayer.new_character = living_mob
			else
				M = living_mob
		else
			if(!isnull(new_mob)) //Detect fail condition on equip
			//if equip() is somehow able to fail, send them back to lobby
				var/mob/dead/new_player/authenticated/NP = new()
				NP.ckey = M.client.ckey
				qdel(M)
				to_chat(M, "Error equipping [rank]. Returning to lobby.</b>")
				return null
		SSpersistence.antag_rep_change[M.client.ckey] += job.GetAntagRep()

		if(M.client.holder)
			if(CONFIG_GET(flag/auto_deadmin_players) || M.client?.prefs.read_player_preference(/datum/preference/toggle/deadmin_always))
				M.client.holder.auto_deadmin()
			else
				handle_auto_deadmin_roles(M.client, rank)
		to_chat(M, "<b>As the [rank] you answer directly to [job.supervisors]. Special circumstances may change this.</b>")
		job.radio_help_message(M)
		if(job.req_admin_notify)
			to_chat(M, "<b>You are playing a job that is important for Game Progression. If you have to disconnect, please notify the admins via adminhelp.</b>")
		var/obj/item/id_card = living_mob?.get_idcard()
		if (SSjob.initial_players_to_assign < job.min_pop && job.min_pop_redirect)
			to_chat(M, span_noticebig("<b>Due to a lack of station personnel, you additionally have the responsibilities and access of \a [job.min_pop_redirect::title]!</b>"))
		else if (id_card && length(id_card.GetAccess()) != length(job.base_access))
			to_chat(M, span_notice("<B>You have been granted with additional access and responsibilities due to a lack of station personnel.</B>"))
	if(ishuman(living_mob))
		var/mob/living/carbon/human/wageslave = living_mob
		if(wageslave.mind?.account_id)
			living_mob.add_memory("Your account ID is [wageslave.mind.account_id].")
	if(job && living_mob)
		job.after_spawn(living_mob, M, joined_late, M.client) // note: this happens before the mob has a key! M will always have a client, living_mob might not.

	if(living_mob.mind && !living_mob.mind.crew_objectives.len)
		give_crew_objective(living_mob.mind, M)

	return living_mob

/datum/controller/subsystem/job/proc/handle_auto_deadmin_roles(client/C, rank)
	if(!C?.holder)
		return TRUE
	var/datum/job/job = GetJob(rank)
	if(!job)
		return
	if((job.auto_deadmin_role_flags & DEADMIN_POSITION_HEAD) && (CONFIG_GET(flag/auto_deadmin_heads) || C.prefs?.read_player_preference(/datum/preference/toggle/deadmin_position_head)))
		return C.holder.auto_deadmin()
	else if((job.auto_deadmin_role_flags & DEADMIN_POSITION_SECURITY) && (CONFIG_GET(flag/auto_deadmin_security) || C.prefs?.read_player_preference(/datum/preference/toggle/deadmin_position_security)))
		return C.holder.auto_deadmin()
	else if((job.auto_deadmin_role_flags & DEADMIN_POSITION_SILICON) && (CONFIG_GET(flag/auto_deadmin_silicons) || C.prefs?.read_player_preference(/datum/preference/toggle/deadmin_position_silicon))) //in the event there's ever psuedo-silicon roles added, ie synths.
		return C.holder.auto_deadmin()

/datum/controller/subsystem/job/proc/setup_officer_positions()
	var/datum/job/J = SSjob.GetJob("Security Officer")
	if(!J)
		CRASH("setup_officer_positions(): Security officer job is missing")

	//Spawn some extra eqipment lockers if we have more than 5 officers
	var/equip_needed = J.get_spawn_position_count()
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
		if(J.gimmick) //gimmick job slots are dependant on random maint
			continue
		var/regex/jobs = new("[J.title]=(-1|\\d+)")
		if(jobs.Find(jobstext))
			J.total_positions = text2num(jobs.group[1])
		else
			log_runtime("Error in /datum/controller/subsystem/job/proc/LoadJobs: Failed to locate job of title [J.title] in jobs.txt")

/datum/controller/subsystem/job/proc/HandleFeedbackGathering()
	for(var/datum/job/job in occupations)
		var/high = 0 //high
		var/medium = 0 //medium
		var/low = 0 //low
		var/never = 0 //never
		var/banned = 0 //banned
		var/young = 0 //account too young
		for(var/mob/dead/new_player/authenticated/player in GLOB.player_list)
			if(job.lock_flags)
				continue
			if(!(player.ready == PLAYER_READY_TO_PLAY && player.mind && !player.mind.assigned_role))
				continue //This player is not ready
			if(is_banned_from(player.ckey, job.title) || QDELETED(player))
				banned++
				continue
			if(!job.player_old_enough(player.client))
				young++
				continue
			if(job.required_playtime_remaining(player.client))
				young++
				continue
			switch(player.client.prefs.job_preferences[job.title])
				if(JP_HIGH)
					high++
				if(JP_MEDIUM)
					medium++
				if(JP_LOW)
					low++
				else
					never++
		SSblackbox.record_feedback("nested tally", "job_preferences", high, list("[job.title]", "high"))
		SSblackbox.record_feedback("nested tally", "job_preferences", medium, list("[job.title]", "medium"))
		SSblackbox.record_feedback("nested tally", "job_preferences", low, list("[job.title]", "low"))
		SSblackbox.record_feedback("nested tally", "job_preferences", never, list("[job.title]", "never"))
		SSblackbox.record_feedback("nested tally", "job_preferences", banned, list("[job.title]", "banned"))
		SSblackbox.record_feedback("nested tally", "job_preferences", young, list("[job.title]", "young"))

/datum/controller/subsystem/job/proc/PopcapReached()
	var/hpc = CONFIG_GET(number/hard_popcap)
	var/epc = CONFIG_GET(number/extreme_popcap)
	if(hpc || epc)
		var/relevent_cap = max(hpc, epc)
		if((initial_players_to_assign - unassigned.len) >= relevent_cap)
			return 1
	return 0

/datum/controller/subsystem/job/proc/RejectPlayer(mob/dead/new_player/authenticated/player)
	if(player.mind && player.mind.special_role)
		return
	if(PopcapReached() && !IS_PATRON(player.ckey))
		JobDebug("Popcap overflow Check observer located, Player: [player]")
	JobDebug("Player rejected :[player]")
	to_chat(player, "<b>You have failed to qualify for any job you desired.</b>")
	unassigned -= player
	player.ready = PLAYER_NOT_READY


/atom/proc/JoinPlayerHere(mob/M, buckle)
	// By default, just place the mob on the same turf as the marker or whatever.
	M.forceMove(get_turf(src))

/obj/structure/chair/JoinPlayerHere(mob/M, buckle)
	// Placing a mob in a chair will attempt to buckle it if buckle is set
	..()
	if (buckle)
		buckle_mob(M, FALSE, FALSE)

/datum/controller/subsystem/job/proc/SendToLateJoin(mob/M, buckle = TRUE)
	var/atom/destination
	if(M.mind && M.mind.assigned_role && length(GLOB.jobspawn_overrides[M.mind.assigned_role])) //We're doing something special today.
		destination = pick(GLOB.jobspawn_overrides[M.mind.assigned_role])
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
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND)))
			. |= player.mind


////////////////////////////
//Keeps track of all heads//
////////////////////////////
/datum/controller/subsystem/job/proc/get_all_heads()
	. = list()
	for(var/i in GLOB.mob_list)
		var/mob/player = i
		if(player.mind && (player.mind.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND)))
			. |= player.mind

//////////////////////////////////////////////
//Keeps track of all living security members//
//////////////////////////////////////////////
/datum/controller/subsystem/job/proc/get_living_sec()
	. = list()
	for(var/mob/living/carbon/human/player in GLOB.carbon_list)
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SECURITY)))
			. |= player.mind

////////////////////////////////////////
//Keeps track of all  security members//
////////////////////////////////////////
/datum/controller/subsystem/job/proc/get_all_sec()
	. = list()
	for(var/mob/living/carbon/human/player in GLOB.carbon_list)
		if(player.mind && (player.mind.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SECURITY)))
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

/obj/item/paper/fluff/spare_id_safe_code/emergency_spare_id_safe_code
	name = "Emergency Spare ID Safe Code Requisition"
	desc = "Proof that nobody has been approved for Captaincy. A skeleton key for a skeleton shift."

/datum/controller/subsystem/job/proc/promote_to_captain(mob/dead/new_player/authenticated/new_captain, acting_captain = FALSE)
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
		to_chat(new_captain, span_notice("Due to your position in the chain of command, you have been granted access to captain's spare ID. You can find in important note about this [where]."))
	else
		to_chat(new_captain, span_notice("You can find the code to obtain your spare ID from the secure safe on the Bridge [where]."))

	// Force-give their ID card bridge access.
	if(H.wear_id?.GetID())
		var/obj/item/card/id/id_card = H.wear_id
		if(!(ACCESS_HEADS in id_card.access))
			LAZYADD(id_card.access, ACCESS_HEADS)

	assigned_captain = TRUE

/// Send a drop pod containing a piece of paper with the spare ID safe code to loc
/datum/controller/subsystem/job/proc/send_spare_id_safe_code(loc)
	new /obj/effect/pod_landingzone(loc, /obj/structure/closet/supplypod/centcompod, new /obj/item/paper/fluff/spare_id_safe_code/emergency_spare_id_safe_code())
	safe_code_timer_id = null
	safe_code_request_loc = null
