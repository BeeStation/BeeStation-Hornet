SUBSYSTEM_DEF(job)
	name = "Jobs"
	flags = SS_NO_FIRE
	dependencies = list(
		/datum/controller/subsystem/department,
		/datum/controller/subsystem/processing/station,
	)

	/// List of all jobs.
	var/list/datum/job/all_occupations = list()
	/// List of jobs that can be joined through the starting menu.
	var/list/datum/job/joinable_occupations = list()
	/// Dictionary of all jobs, keys are titles.
	var/list/name_occupations = list()
	/// Dictionary of all jobs, keys are types.
	var/list/datum/job/type_occupations = list()

	/// Dictionary of jobs indexed by the experience type they grant.
	var/list/experience_jobs_map = list()

	/// List of all departments with joinable jobs.
	var/list/datum/department_group/joinable_departments = list()
	/// List of all joinable departments indexed by their typepath, sorted by their own display order.
	var/list/datum/department_group/joinable_departments_by_type = list()

	var/list/unassigned = list() //Players who need jobs
	var/initial_players_to_assign = 0 //used for checking against population caps
	// Whether to run DivideOccupations pure so that there are no side-effects from calling it other than
	// a player's assigned_role being set to some value.
	var/run_divide_occupation_pure = FALSE

	var/list/prioritized_jobs = list()
	var/list/latejoin_trackers = list()

	var/overflow_role = /datum/job/assistant

	var/list/level_order = list(JP_HIGH,JP_MEDIUM,JP_LOW)
	/// Lazylist of mob:occupation_string pairs.
	var/list/dynamic_forced_occupations

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

	/// list of jobs that aren't part of standard jobs - used for job manager
	var/list/all_job_exceptions = list(
		JOB_NAME_VIP,
		JOB_NAME_GIMMICK,
		JOB_NAME_PRISONER,
	)

	/// If TRUE, some player has been assigned Captaincy or Acting Captaincy at some point during the shift and has been given the spare ID safe code.
	var/assigned_captain = FALSE
	/// Whether the emergency safe code has been requested via a comms console on shifts with no Captain or Acting Captain.
	var/safe_code_requested = FALSE
	/// Timer ID for the emergency safe code request.
	var/safe_code_timer_id
	/// The loc to which the emergency safe code has been requested for delivery.
	var/turf/safe_code_request_loc

	/// Dictionary that maps job priorities to low/medium/high. Keys have to be number-strings as assoc lists cannot be indexed by integers. Set in setup_job_lists.
	var/list/job_priorities_to_strings

/datum/controller/subsystem/job/Initialize()
	if(!length(all_occupations))
		setup_occupations()
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
	all_occupations = SSjob.all_occupations
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

/// Returns a list of jobs that we are allowed to fuck with during random events
/datum/controller/subsystem/job/proc/get_valid_overflow_jobs()
	var/static/list/overflow_jobs
	if (!isnull(overflow_jobs))
		return overflow_jobs

	overflow_jobs = list()
	for (var/datum/job/check_job in joinable_occupations)
		if (!check_job.allow_bureaucratic_error)
			continue
		overflow_jobs += check_job
	return overflow_jobs

/datum/controller/subsystem/job/proc/set_overflow_role(new_overflow_role)
	var/datum/job/new_overflow = ispath(new_overflow_role) ? get_job_type(new_overflow_role) : get_job(new_overflow_role)
	if(!new_overflow)
		job_debug("SET_OVRFLW: Failed to set new overflow role: [new_overflow_role]")
		CRASH("set_overflow_role failed | new_overflow_role: [isnull(new_overflow_role) ? "null" : new_overflow_role]")
	var/cap = CONFIG_GET(number/overflow_cap)

	new_overflow.allow_bureaucratic_error = FALSE
	new_overflow.total_positions = cap
	new_overflow.job_flags |= JOB_CANNOT_OPEN_SLOTS

	if(new_overflow.type == overflow_role)
		return
	var/datum/job/old_overflow = get_job_type(overflow_role)
	old_overflow.allow_bureaucratic_error = initial(old_overflow.allow_bureaucratic_error)
	old_overflow.total_positions = initial(old_overflow.total_positions)
	if(!(initial(old_overflow.job_flags) & JOB_CANNOT_OPEN_SLOTS))
		old_overflow.job_flags &= ~JOB_CANNOT_OPEN_SLOTS
	overflow_role = new_overflow.type
	job_debug("SET_OVRFLW: Overflow role set to: [new_overflow.type]")

/datum/controller/subsystem/job/proc/setup_occupations()
	name_occupations = list()
	type_occupations = list()

	var/list/all_jobs = subtypesof(/datum/job)
	if(!length(all_jobs))
		all_occupations = list()
		joinable_occupations = list()
		joinable_departments = list()
		joinable_departments_by_type = list()
		experience_jobs_map = list()
		to_chat(world, span_boldannounce("Error setting up jobs, no job datums found."))
		return FALSE

	var/list/new_all_occupations = list()
	var/list/new_joinable_occupations = list()
	var/list/new_joinable_departments = list()
	var/list/new_joinable_departments_by_type = list()
	var/list/new_experience_jobs_map = list()

	for(var/job_type in all_jobs)
		var/datum/job/job = new job_type()
		new_all_occupations += job
		name_occupations[job.title] = job
		for(var/alt_title in job.alternate_titles)
			name_occupations[alt_title] = job
		type_occupations[job_type] = job

		if(job.job_flags & JOB_NEW_PLAYER_JOINABLE)
			new_joinable_occupations += job
			if(!LAZYLEN(job.departments_list))
				var/datum/department_group/department = new_joinable_departments_by_type[/datum/department_group/undefined]
				if(!department)
					department = SSdepartment.department_datums_by_type[/datum/department_group/undefined] || new /datum/department_group/undefined()
					new_joinable_departments_by_type[/datum/department_group/undefined] = department
				department.add_job(job)
				continue
			for(var/department_type in job.departments_list)
				var/datum/department_group/department = new_joinable_departments_by_type[department_type]
				if(!department)
					department = SSdepartment.department_datums_by_type[department_type] || new department_type()
					new_joinable_departments_by_type[department_type] = department
				department.add_job(job)

	sortTim(new_all_occupations, GLOBAL_PROC_REF(cmp_job_display_asc))
	for(var/datum/job/job as anything in new_all_occupations)
		if(!job.exp_granted_type)
			continue
		new_experience_jobs_map[job.exp_granted_type] += list(job)

	sortTim(new_joinable_departments_by_type, GLOBAL_PROC_REF(cmp_department_display_asc), associative = TRUE)
	for(var/department_type in new_joinable_departments_by_type)
		var/datum/department_group/department = new_joinable_departments_by_type[department_type]
		sortTim(department.department_jobs, GLOBAL_PROC_REF(cmp_job_display_asc))
		new_joinable_departments += department
		if(department.department_experience_type)
			new_experience_jobs_map[department.department_experience_type] = department.department_jobs.Copy()

	all_occupations = new_all_occupations
	joinable_occupations = sortTim(new_joinable_occupations, GLOBAL_PROC_REF(cmp_job_display_asc))
	joinable_departments = new_joinable_departments
	joinable_departments_by_type = new_joinable_departments_by_type
	experience_jobs_map = new_experience_jobs_map

	//TODO: move to all_jobs forloop above
	if(SSmapping.map_adjustment)
		SSmapping.map_adjustment.job_change()
		log_world("Applied '[SSmapping.map_adjustment.map_file_name]' map adjustment: job_change()")

	SEND_SIGNAL(src, COMSIG_OCCUPATIONS_SETUP)

	return TRUE

/datum/controller/subsystem/job/proc/is_job_empty(rank)
	return get_job(rank)?.current_positions == 0

/datum/controller/subsystem/job/proc/get_job(rank)
	RETURN_TYPE(/datum/job)
	if(!length(all_occupations))
		setup_occupations()
	return name_occupations[rank]

/datum/controller/subsystem/job/proc/get_job_type(jobtype)
	RETURN_TYPE(/datum/job)
	if(!length(all_occupations))
		setup_occupations()
	return type_occupations[jobtype]

/datum/controller/subsystem/job/proc/get_department_type(department_type)
	if(!length(all_occupations))
		setup_occupations()
	return joinable_departments_by_type[department_type]

/**
 * Assigns the given job role to the player.
 *
 * Arguments:
 * * player - The player to assign the job to
 * * job - The job to assign
 * * latejoin - Set to TRUE if this is a latejoin role assignment.
 * * do_eligibility_checks - Set to TRUE to conduct all job eligibility tests and reject on failure. Set to FALSE if job eligibility has been tested elsewhere and they can be safely skipped.
 */
/datum/controller/subsystem/job/proc/assign_role(mob/dead/new_player/authenticated/player, datum/job/job, latejoin = FALSE, do_eligibility_checks = TRUE)
	job_debug("AR: Running, Player: [player], Job: [isnull(job) ? "null" : job], LateJoin: [latejoin]")
	if(!player?.mind || !job)
		job_debug("AR: Failed, player has no mind or job is null. Player: [player], Rank: [isnull(job) ? "null" : job.type]")
		return FALSE

	if(do_eligibility_checks && (check_job_eligibility(player, job, "AR", add_job_to_log = TRUE) != JOB_AVAILABLE))
		return FALSE

	// Unassign our previous job, to prevent double counts
	if(!is_unassigned_job(player.mind.assigned_role))
		var/datum/job/current_job = player.mind.assigned_role
		current_job.current_positions--
		player.mind.set_assigned_role(get_job_type(/datum/job/unassigned))
	job_debug("AR: Role now set and assigned - [player] is [job.title], JCP:[job.current_positions], JPL:[job.get_spawn_position_count()]. Group size: [job.count_players_in_group()]")
	player.mind.set_assigned_role(job)
	unassigned -= player
	job.current_positions++
	if(!latejoin)
		player.client.inc_metabalance(METACOIN_READY_UP_REWARD, reason = "Joined the station as a roundstart crew member.")
	return TRUE

/datum/controller/subsystem/job/proc/FreeRole(rank)
	if(!rank)
		return
	job_debug("Freeing role: [rank]")
	var/datum/job/job = get_job_type(rank)
	if(!job)
		return FALSE
	job.current_positions = max(0, job.current_positions - 1)

/datum/controller/subsystem/job/proc/find_occupation_candidates(datum/job/job, level)
	job_debug("FOC: Now running, Job: [job], Level: [job_priority_level_to_string(level)]")
	var/list/candidates = list()
	for(var/mob/dead/new_player/authenticated/player in unassigned)
		if(!player)
			job_debug("FOC: Player no longer exists.")
			continue

		if(!player.client)
			job_debug("FOC: Player client no longer exists, Player: [player]")
			continue

		// Initial screening check. Does the player even have the job enabled, if they do - Is it at the correct priority level?
		var/player_job_level = player.client.prefs.job_preferences[job.title]
		if(isnull(player_job_level))
			job_debug("FOC: Player job not enabled, Player: [player]")
			continue

		if(level && (player_job_level != level))
			job_debug("FOC: Player job enabled at wrong level, Player: [player], TheirLevel: [job_priority_level_to_string(player_job_level)], ReqLevel: [job_priority_level_to_string(level)]")
			continue

		// This check handles its own output to JobDebug.
		if(check_job_eligibility(player, job, "FOC", add_job_to_log = FALSE) != JOB_AVAILABLE)
			continue

		// They have the job enabled, at this priority level, with no restrictions applying to them.
		job_debug("FOC: Player eligible, Player: [player], Level: [job_priority_level_to_string(level)]")
		candidates += player
	return candidates

/datum/controller/subsystem/job/proc/give_random_job(mob/dead/new_player/authenticated/player)
	job_debug("GRJ: Giving random job, Player: [player]")
	. = FALSE
	for(var/datum/job/job as anything in shuffle(joinable_occupations))
		if(QDELETED(player))
			job_debug("GRJ: Player is deleted, aborting")
			break

		var/spawn_position_count = job.get_spawn_position_count()
		if(job.current_positions >= spawn_position_count && spawn_position_count != -1)
			job_debug("GRJ: Job lacks spawn positions to be eligible, Player: [player], Job: [job]")
			continue

		if(istype(job, get_job_type(overflow_role))) // We don't want to give him assistant, that's boring!
			job_debug("GRJ: Skipping overflow role, Player: [player], Job: [job]")
			continue

		if(job.departments_bitflags & DEPT_BITFLAG_COM) //If you want a command position, select it!
			job_debug("GRJ: Skipping command role, Player: [player], Job: [job]")
			continue

		// This check handles its own output to job_debug.
		if(check_job_eligibility(player, job, "GRJ", add_job_to_log = TRUE) != JOB_AVAILABLE)
			continue

		if(assign_role(player, job, do_eligibility_checks = FALSE))
			job_debug("GRJ: Random job given, Player: [player], Job: [job]")
			return TRUE

		job_debug("GRJ: Player eligible but assign_role failed, Player: [player], Job: [job]")

/datum/controller/subsystem/job/proc/reset_occupations()
	job_debug("RO: Occupations reset.")
	for(var/mob/dead/new_player/authenticated/player as anything in GLOB.auth_new_player_list)
		if(!player?.mind)
			continue
		player.mind.set_assigned_role(get_job_type(/datum/job/unassigned))
		player.mind.special_role = null
		SSpersistence.antag_rep_change[player.ckey] = 0
	setup_occupations()
	unassigned = list()
	set_overflow_role(overflow_role)
	return

/** Proc DivideOccupations
 *  fills var "assigned_role" for all ready players.
 *  This proc must not have any side effect besides of modifying "assigned_role".
 **/
/datum/controller/subsystem/job/proc/DivideOccupations(pure = FALSE, allow_all = FALSE)
	//Setup new player list and get the jobs list
	job_debug("DO: Running, allow_all = [allow_all], pure = [pure]")
	run_divide_occupation_pure = pure
	SEND_SIGNAL(src, COMSIG_OCCUPATIONS_DIVIDED, pure, allow_all)

	//Holder for Triumvirate is stored in the SSticker, this just processes it
	if(SSticker.triai)
		for(var/datum/job/ai/A in joinable_occupations)
			A.total_positions = 3
		for(var/obj/effect/landmark/start/ai/secondary/S in GLOB.start_landmarks_list)
			S.latejoin_active = TRUE

	//Get the players who are ready
	for(var/mob/dead/new_player/authenticated/player in GLOB.auth_new_player_list)
		if(player.ready == PLAYER_READY_TO_PLAY && player.mind && is_unassigned_job(player.mind.assigned_role))
			if(!player.check_preferences())
				player.ready = PLAYER_NOT_READY
			else
				unassigned += player

	initial_players_to_assign = length(unassigned)

	job_debug("DO: Player count to assign roles to: [initial_players_to_assign]")
	if(unassigned.len == 0)
		return TRUE

	//Shuffle players and jobs
	unassigned = shuffle(unassigned)

	HandleFeedbackGathering()

	//Other jobs are now checked
	job_debug("DO: Running standard job assignment")

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
		if(!allow_all)
			if(PopcapReached() && !IS_PATRON(player.ckey))
				RejectPlayer(player)

	assign_roles(JP_MEDIUM)
	assign_roles(JP_LOW)

	job_debug("DO: Handle unassigned")
	// Hand out random jobs to the people who didn't get any in the last check
	// Also makes sure that they got their preference correct
	for(var/mob/dead/new_player/authenticated/player in unassigned)
		HandleUnassigned(player, allow_all)
	job_debug("DO: Ending handle unassigned")

	job_debug("DO: Handle unrejectable unassigned")
	//Mop up people who can't leave.
	for(var/mob/dead/new_player/authenticated/player in unassigned) //Players that wanted to back out but couldn't because they're antags (can you feel the edge case?)
		if(!give_random_job(player))
			if(!assign_role(player, get_job_type(overflow_role))) //If everything is already filled, make them an assistant
				job_debug("DO: Forced antagonist could not be assigned any random job or the overflow role. divide_occupations failed.")
				job_debug("---------------------------------------------------")
				return FALSE //Living on the edge, the forced antagonist couldn't be assigned to overflow role (bans, client age) - just reroll
	job_debug("DO: Ending handle unrejectable unassigned")

	//Scale number of open security officer slots to population
	setup_officer_positions()
	job_debug("All divide occupations tasks completed.")
	job_debug("---------------------------------------------------")
	run_divide_occupation_pure = FALSE
	return TRUE

/datum/controller/subsystem/job/proc/assign_roles(priority = JP_MEDIUM)
	// Create random orderings for all players
	var/list/sorted_orderings = list()
	var/list/random_orderings = list()
	// Step 1: Generate random orderings for the players medium jobs
	for(var/mob/dead/new_player/authenticated/player in unassigned)
		var/list/available_jobs = list()
		// Find all jobs that we are actually able to be
		for(var/datum/job/job in joinable_occupations)
			if (!is_valid_job(player, job, priority))
				continue
			job_debug("Preparing, Player: [player], Job:[job.title]")
			available_jobs += job
		// Create random orderings
		shuffle_inplace(available_jobs)
		// Use the same reference, so that we only have to update one
		sorted_orderings[player] = available_jobs
		random_orderings[player] = available_jobs
		job_debug("DO [player.ckey] was given the job priority list [jointext(available_jobs, ",")]")
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
			player.mind.set_assigned_role(job)
			job_debug("DO [player.ckey] was assigned the provisional job [job.title]")
			break
	// Step 4: Create a random ordering of players
	// The player list is already shuffled, so we will re-use that for player preference
	// Step 5: Assign high priority job roles
	if (priority == JP_MEDIUM)
		for(var/mob/dead/new_player/authenticated/player in sorted_orderings)
			// Assign high priority jobs
			for(var/datum/job/job in joinable_occupations)
				if (!is_valid_job(player, job, JP_HIGH))
					continue
				var/list/player_job_list = sorted_orderings[player]
				// Add this job to the start of the player's preferences list
				player_job_list.Insert(1, job)
				job_debug("DO [player.ckey] requested [job.title] as a high priority job. Updated assignment list: [jointext(player_job_list, ",")]")
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
				if (player.mind.assigned_role == job)
					break
				// This job is full, skip
				var/job_position_count = job.get_spawn_position_count()
				if (job.current_positions >= job_position_count && job_position_count != -1)
					continue
				job_debug("DO [player.ckey] switched from job [player.mind.assigned_role?.title] to job [job.title]")
				// Unassign our previous job
				if (!is_unassigned_job(player.mind.assigned_role))
					var/datum/job/current_job = player.mind.assigned_role
					current_job.current_positions--
					player.mind.set_assigned_role(get_job_type(/datum/job/unassigned))
				// Provisional assignment
				job.current_positions++
				player.mind.set_assigned_role(job)
				changed = TRUE
				break
	// Step 5: Assign job roles that we have so far
	for(var/mob/dead/new_player/authenticated/player in sorted_orderings)
		if (is_unassigned_job(player.mind.assigned_role))
			job_debug("DO [player.ckey] has no medium or high priority jobs assigned")
			continue
		assign_role(player, player.mind.assigned_role)
		unassigned -= player

/datum/controller/subsystem/job/proc/is_valid_job(mob/dead/new_player/authenticated/player, datum/job/job, required_priority)
	if(!job || !(job.job_flags & JOB_NEW_PLAYER_JOINABLE))
		return FALSE
	if(is_banned_from(player.ckey, job.title))
		job_debug("DO isbanned failed, Player: [player], Job:[job.title]")
		return FALSE
	if(QDELETED(player))
		job_debug("DO player deleted during job ban check")
		return FALSE
	if(!job.player_old_enough(player.client))
		job_debug("DO player not old enough, Player: [player], Job:[job.title]")
		return FALSE
	if(job.required_playtime_remaining(player.client))
		job_debug("DO player not enough xp, Player: [player], Job:[job.title]")
		return FALSE
	if(player.mind && (job.title in player.mind.restricted_roles))
		job_debug("DO incompatible with antagonist role, Player: [player], Job:[job.title]")
		return FALSE
	if(player.client.prefs.job_preferences[job.title] != required_priority && !(job.gimmick && player.client.prefs.job_preferences["Gimmick"] == required_priority))
		return FALSE
	return TRUE

//We couldn't find a job from prefs for this guy.
/datum/controller/subsystem/job/proc/HandleUnassigned(mob/dead/new_player/authenticated/player, allow_all = FALSE)
	var/jobless_role = player.client.prefs.read_character_preference(/datum/preference/choiced/jobless_role)

	if(!allow_all)
		if(PopcapReached() && !IS_PATRON(player.ckey))
			RejectPlayer(player)
			return

	switch (jobless_role)
		if (BEOVERFLOW)
			var/datum/job/overflow_role_datum = get_job_type(overflow_role)

			if(check_job_eligibility(player, overflow_role_datum, debug_prefix = "HU", add_job_to_log = TRUE) != JOB_AVAILABLE)
				job_debug("HU: Player cannot be overflow, trying to reject: [player]")
				RejectPlayer(player)
				return

			if(!assign_role(player, overflow_role_datum, do_eligibility_checks = FALSE))
				job_debug("HU: Player could not be assigned overflow role, trying to reject: [player]")
				RejectPlayer(player)
				return
		if (BERANDOMJOB)
			if(!give_random_job(player))
				job_debug("HU: Player cannot be given a random job, trying to reject: [player]")
				RejectPlayer(player)
		if (RETURNTOLOBBY)
			job_debug("HU: Player unable to be assigned job, return to lobby enabled: [player]")
			RejectPlayer(player)
			return
		else //Something gone wrong if we got here.
			job_debug("HU: [player] has an invalid jobless_role var: [jobless_role]")
			log_game("[player] has an invalid jobless_role var: [jobless_role]")
			message_admins("[player] has an invalid jobless_role, this shouldn't happen.")
			RejectPlayer(player)

//Gives the player the stuff he should have with his rank
/datum/controller/subsystem/job/proc/EquipRank(mob/living/equipping, datum/job/job, client/player_client)
	equipping.job = job.title

	SEND_SIGNAL(equipping, COMSIG_JOB_RECEIVED, job)

	equipping.mind?.set_assigned_role_with_greeting(job, player_client)
	equipping.on_job_equipping(job, null, player_client)
	job.announce_job(equipping)
	SSpersistence.antag_rep_change[player_client.ckey] += job.GetAntagRep()

	if(player_client?.holder)
		if(CONFIG_GET(flag/auto_deadmin_players) || player_client.prefs?.read_player_preference(/datum/preference/toggle/deadmin_always))
			player_client.holder.auto_deadmin()
		else
			handle_auto_deadmin_roles(player_client, job.title)

	job.after_spawn(equipping, player_client)

	if(equipping.mind && !equipping.mind.crew_objectives.len)
		give_crew_objective(equipping.mind, equipping)

/datum/controller/subsystem/job/proc/handle_auto_deadmin_roles(client/C, rank)
	if(!C?.holder)
		return TRUE
	var/datum/job/job = get_job(rank)

	if(!job)
		return
	if((job.auto_deadmin_role_flags & DEADMIN_POSITION_HEAD) && (CONFIG_GET(flag/auto_deadmin_heads) || C.prefs?.read_player_preference(/datum/preference/toggle/deadmin_position_head)))
		return C.holder.auto_deadmin()
	else if((job.auto_deadmin_role_flags & DEADMIN_POSITION_SECURITY) && (CONFIG_GET(flag/auto_deadmin_security) || C.prefs?.read_player_preference(/datum/preference/toggle/deadmin_position_security)))
		return C.holder.auto_deadmin()
	else if((job.auto_deadmin_role_flags & DEADMIN_POSITION_SILICON) && (CONFIG_GET(flag/auto_deadmin_silicons) || C.prefs?.read_player_preference(/datum/preference/toggle/deadmin_position_silicon))) //in the event there's ever psuedo-silicon roles added, ie synths.
		return C.holder.auto_deadmin()

/datum/controller/subsystem/job/proc/setup_officer_positions()
	var/datum/job/J = SSjob.get_job(JOB_NAME_SECURITYOFFICER)
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
	for(var/datum/job/job as anything in joinable_occupations)
		if(job.gimmick) //gimmick job slots are dependant on random maint
			continue
		var/regex/jobs = new("[job.title]=(-1|\\d+)")
		if(jobs.Find(jobstext))
			job.total_positions = text2num(jobs.group[1])
		else
			log_runtime("Error in /datum/controller/subsystem/job/proc/LoadJobs: Failed to locate job of title [job.title] in jobs.txt")

/datum/controller/subsystem/job/proc/HandleFeedbackGathering()
	for(var/datum/job/job as anything in joinable_occupations)
		var/high = 0 //high
		var/medium = 0 //medium
		var/low = 0 //low
		var/never = 0 //never
		var/banned = 0 //banned
		var/young = 0 //account too young
		for(var/i in GLOB.auth_new_player_list)
			var/mob/dead/new_player/authenticated/player = i
			if(!(job.job_flags & JOB_NEW_PLAYER_JOINABLE))
				continue
			if(!(player.ready == PLAYER_READY_TO_PLAY && player.mind && is_unassigned_job(player.mind.assigned_role)))
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
		job_debug("Popcap overflow Check observer located, Player: [player]")
	job_debug("Player rejected :[player]")
	unassigned -= player
	if(!run_divide_occupation_pure)
		to_chat(player, span_infoplain("<b>You have failed to qualify for any job you desired.</b>"))
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
	if(M.mind && !is_unassigned_job(M.mind.assigned_role) && length(GLOB.jobspawn_overrides[M.mind.assigned_role.title])) //We're doing something special today.
		destination = pick(GLOB.jobspawn_overrides[M.mind.assigned_role.title])
		destination.JoinPlayerHere(M, FALSE)
		return TRUE

	if(latejoin_trackers.len)
		destination = pick(latejoin_trackers)
		destination.JoinPlayerHere(M, buckle)
		return TRUE

	destination = get_last_resort_spawn_points()
	destination.JoinPlayerHere(M, buckle)

/datum/controller/subsystem/job/proc/get_last_resort_spawn_points()
	var/area/shuttle/arrival/arrivals_area = GLOB.areas_by_type[/area/shuttle/arrival]
	if(!isnull(arrivals_area))
		var/list/turf/available_turfs = list()
		for (var/list/zlevel_turfs as anything in arrivals_area.get_zlevel_turf_lists())
			for (var/turf/arrivals_turf as anything in zlevel_turfs)
				var/obj/structure/chair/shuttle_chair = locate() in arrivals_turf
				if(!isnull(shuttle_chair))
					return shuttle_chair
				if(arrivals_turf.is_blocked_turf(TRUE))
					continue
				available_turfs += arrivals_turf

		if(length(available_turfs))
			return pick(available_turfs)

	stack_trace("Unable to find last resort spawn point.")
	return GET_ERROR_ROOM

///Lands specified mob at a random spot in the hallways
/datum/controller/subsystem/job/proc/DropLandAtRandomHallwayPoint(mob/living/living_mob)
	var/turf/spawn_turf = get_safe_random_station_turfs(typesof(/area/station/hallway))

	if(!spawn_turf)
		SendToLateJoin(living_mob)
		return

	var/obj/structure/closet/supplypod/centcompod/toLaunch = new()
	living_mob.forceMove(toLaunch)
	new /obj/effect/pod_landingzone(spawn_turf, toLaunch)

/// Blindly assigns the required roles to every player in the dynamic_forced_occupations list.
/datum/controller/subsystem/job/proc/assign_priority_positions()
	for(var/mob/new_player in dynamic_forced_occupations)
		// Eligibility checks already carried out as part of the dynamic ruleset trim_candidates proc.area
		// However no guarantee of game state between then and now, so don't skip eligibility checks on AssignRole.
		assign_role(new_player, get_job(dynamic_forced_occupations[new_player]))

/// Takes a job priority #define such as JP_LOW and gets its string representation for logging.
/datum/controller/subsystem/job/proc/job_priority_level_to_string(priority)
	return job_priorities_to_strings["[priority]"] || "Undefined Priority \[[priority]\]"

/**
 * Runs a standard suite of eligibility checks to make sure the player can take the reqeusted job.
 *
 * Checks:
 * * Role bans
 * * How many days old the player account is
 * * Whether the player has the required hours in other jobs to take that role
 * * If the job is in the mind's restricted roles, for example if they have an antag datum that's incompatible with certain roles.
 *
 * Arguments:
 * * player - The player to check for job eligibility.
 * * possible_job - The job to check for eligibility against.
 * * debug_prefix - Logging prefix for the JobDebug log entries. For example, GRJ during GiveRandomJob or DO during DivideOccupations.
 * * add_job_to_log - If TRUE, appends the job type to the log entry. If FALSE, does not. Set to FALSE when check is part of iterating over players for a specific job, set to TRUE when check is part of iterating over jobs for a specific player and you don't want extra log entry spam.
 */
/datum/controller/subsystem/job/proc/check_job_eligibility(mob/dead/new_player/player, datum/job/possible_job, debug_prefix = "", add_job_to_log = FALSE)
	if(!player.mind)
		job_debug("[debug_prefix]: Player has no mind, Player: [player][add_job_to_log ? ", Job: [possible_job]" : ""]")
		return JOB_UNAVAILABLE_GENERIC

	if(possible_job.title in player.mind.restricted_roles)
		job_debug("[debug_prefix] Error: [get_job_unavailable_error_message(JOB_UNAVAILABLE_ANTAG_INCOMPAT, possible_job.title)], Player: [player][add_job_to_log ? ", Job: [possible_job]" : ""]")
		return JOB_UNAVAILABLE_ANTAG_INCOMPAT

	if(!possible_job.player_old_enough(player.client))
		job_debug("[debug_prefix] Error: [get_job_unavailable_error_message(JOB_UNAVAILABLE_ACCOUNTAGE, possible_job.title)], Player: [player][add_job_to_log ? ", Job: [possible_job]" : ""]")
		return JOB_UNAVAILABLE_ACCOUNTAGE

	var/required_playtime_remaining = possible_job.required_playtime_remaining(player.client)
	if(required_playtime_remaining)
		job_debug("[debug_prefix] Error: [get_job_unavailable_error_message(JOB_UNAVAILABLE_PLAYTIME, possible_job.title)], Player: [player], MissingTime: [required_playtime_remaining][add_job_to_log ? ", Job: [possible_job]" : ""]")
		return JOB_UNAVAILABLE_PLAYTIME

	// Run the banned check last since it should be the rarest check to fail and can access the database.
	if(is_banned_from(player.ckey, possible_job.title))
		job_debug("[debug_prefix] Error: [get_job_unavailable_error_message(JOB_UNAVAILABLE_BANNED, possible_job.title)], Player: [player][add_job_to_log ? ", Job: [possible_job]" : ""]")
		return JOB_UNAVAILABLE_BANNED

	// Need to recheck the player exists after is_banned_from since it can query the DB which may sleep.
	if(QDELETED(player))
		job_debug("[debug_prefix]: Player is qdeleted, Player: [player][add_job_to_log ? ", Job: [possible_job]" : ""]")
		return JOB_UNAVAILABLE_GENERIC

	return JOB_AVAILABLE

/// Returns a list of minds of all heads of staff who are alive
/datum/controller/subsystem/job/proc/get_living_heads()
	. = list()
	for(var/datum/mind/head as anything in get_crewmember_minds())
		if(!(head.assigned_role.job_flags & JOB_HEAD_OF_STAFF))
			continue
		if(isnull(head.current) || head.current.stat == DEAD)
			continue
		. += head

/// Returns a list of minds of all heads of staff
/datum/controller/subsystem/job/proc/get_all_heads()
	. = list()
	for(var/datum/mind/head as anything in get_crewmember_minds())
		if(head.assigned_role.job_flags & JOB_HEAD_OF_STAFF)
			. += head

/// Returns a list of minds of all security members who are alive
/datum/controller/subsystem/job/proc/get_living_sec()
	. = list()
	for(var/datum/mind/sec as anything in get_crewmember_minds())
		if(!(sec.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY))
			continue
		if(isnull(sec.current) || sec.current.stat == DEAD)
			continue
		. += sec

/// Returns a list of minds of all security members
/datum/controller/subsystem/job/proc/get_all_sec()
	. = list()
	for(var/datum/mind/sec as anything in get_crewmember_minds())
		if(sec.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY)
			. += sec

/datum/controller/subsystem/job/proc/job_debug(message)
	log_job_debug(message)

/// Builds various lists of jobs based on station, centcom and additional jobs with icons associated with them.
/datum/controller/subsystem/job/proc/setup_job_lists()
	job_priorities_to_strings = list(
		"[JP_LOW]" = "Low Priority",
		"[JP_MEDIUM]" = "Medium Priority",
		"[JP_HIGH]" = "High Priority",
	)

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

/datum/controller/subsystem/job/proc/promote_to_captain(mob/living/carbon/human/H, acting_captain = FALSE)
	if(!H)
		CRASH("Cannot promote to captain: null mob passed.")

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
		to_chat(H, span_notice("Due to your position in the chain of command, you have been granted access to captain's spare ID. You can find in important note about this [where]."))
	else
		to_chat(H, span_notice("You can find the code to obtain your spare ID from the secure safe on the Bridge [where]."))

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

/**
 * Check if the station manifest has at least a certain amount of this staff type.
 * If a matching head of staff is on the manifest, automatically passes (returns TRUE)
 *
 * Arguments:
 * * crew_threshold - amount of crew to meet the requirement
 * * jobs - a list of jobs that qualify the requirement
 * * head_jobs - a list of head jobs that qualify the requirement
 *
*/
/datum/controller/subsystem/job/proc/has_minimum_jobs(crew_threshold, list/jobs = list(), list/head_jobs = list())
	var/employees = 0
	for(var/datum/record/crew/target in GLOB.manifest.general)
		if(target.rank in head_jobs)
			return TRUE
		if(target.rank in jobs)
			employees++

	if(employees >= crew_threshold)
		return TRUE

	return FALSE
