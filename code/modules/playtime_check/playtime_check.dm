/datum/playtime_check
	var/list/denies_by_any_qualify
	var/list/accepts_by_single_qualify
	var/list/accepts_by_full_qualify



/datum/playtime_check/proc/check_playtime(client/C, returns_details=FALSE)
	// I know these look stupid, but you need to get the information why you can't play this job
	if(!C)
		return returns_details ? list(EXP_CHECK_PASS=TRUE) : TRUE
	if(!CONFIG_GET(flag/use_exp_tracking)) // why the fuck did you flag playtime check but not this?
		return returns_details ? list(EXP_CHECK_PASS=TRUE) : TRUE
	if(!SSdbcore.Connect())
		return returns_details ? list(EXP_CHECK_PASS=TRUE) : TRUE
	//if(CONFIG_GET(flag/use_exp_restrictions_admin_bypass) && check_rights_for(C,R_ADMIN))
	//	return returns_details ? list(EXP_CHECK_PASS=TRUE) : TRUE
	var/isexempt = C.prefs.db_flags & DB_FLAG_EXEMPT
	if(isexempt)
		return returns_details ? list(EXP_CHECK_PASS=TRUE) : TRUE
	if(C.prefs.job_exempt)
		return returns_details ? list(EXP_CHECK_PASS=TRUE) : TRUE

	var/list/exp_result = INIT_EXP_LIST

	// basically, you're considered to be qualified, but if you failed to meet a requirement, qualifying will be removed.
	for(var/datum/job_playtime_req/each_req in denies_by_any_qualify)
		var/list/check_result = each_req.check_eligibility(C, returns_details)
		if(check_result[EXP_CHECK_PASS])
			exp_result[EXP_CHECK_PASS] = FALSE
			if(returns_details)
				exp_result[EXP_CHECK_DESC] += check_result[EXP_CHECK_DESC] // don't use |= because some strings are the same in specific situations
			else
				return FALSE // early return FALSE - you can't play this

	for(var/datum/job_playtime_req/each_req in accepts_by_single_qualify)
		var/list/check_result = each_req.check_eligibility(C, returns_details)
		if(!check_result[EXP_CHECK_PASS])
			exp_result[EXP_CHECK_PASS] = FALSE
			if(returns_details)
				exp_result[EXP_CHECK_DESC] += check_result[EXP_CHECK_DESC]
			else
				return TRUE // early return TRUE - you met an ultimate requirement for this!

	for(var/datum/job_playtime_req/each_req in accepts_by_full_qualify)
		var/list/check_result = each_req.check_eligibility(C, returns_details)
		if(!check_result[EXP_CHECK_PASS])
			exp_result[EXP_CHECK_PASS] = FALSE
			if(returns_details)
				exp_result[EXP_CHECK_DESC] += check_result[EXP_CHECK_DESC]
	if(!returns_details)
		return exp_result[EXP_CHECK_PASS]

	return exp_result


/datum/playtime_check/proc/insert_playtime_req(qualify_type, eligibility_count, job_playtime_requirement, combined_playtime_req=0, reversed_timecheck=null, group_display_name=null)
	switch(qualify_type)
		if(QUALIFY_TYPE_DENY_ANY)
			LAZYINITLIST(denies_by_any_qualify)
			ADD_EXP_REQ_FORMAT(denies_by_any_qualify, eligibility_count, job_playtime_requirement, combined_playtime_req, reversed_timecheck, group_display_name)
		if(QUALIFY_TYPE_ACCEPT_SINGLE)
			LAZYINITLIST(accepts_by_single_qualify)
			ADD_EXP_REQ_FORMAT(accepts_by_single_qualify, eligibility_count, job_playtime_requirement, combined_playtime_req, reversed_timecheck, group_display_name, ultimate=TRUE)
		if(QUALIFY_TYPE_ACCEPT_FULL)
			LAZYINITLIST(accepts_by_full_qualify)
			ADD_EXP_REQ_FORMAT(accepts_by_full_qualify, eligibility_count, job_playtime_requirement, combined_playtime_req, reversed_timecheck, group_display_name)


/datum/job_playtime_req
	/// Number of jobs with minimum playtime required for eligibility. 2 means you need 2 jobs with minimum playtime.
	var/stored_eligibility_count_requirement
	/// List of jobs, or roles. If each key has a value, that value represents the minimum required playtime for that role, and contributes to 'eligibility count'
	var/list/stored_job_playtime_requirement
	/// [Optional] Required combined playtime from all jobs/roles listed in job_playtime_requirement
	var/stored_playtime_requirement
	/// [Optional] Displays this group name instead of long job name (combined_playtime_requirement is needed)
	var/stored_group_display_name
	/// if TRUE, playtime should be lower than requirement to return TRUE
	var/reversed_timecheck
	/// it exists for different flavour text
	var/ultimate_req
	/// automatically set to FALSE when stored_eligibility_count_requirement is different. This var is used to make HTML style better.
	var/boxing_flag = TRUE

/// use `ADD_EXP_REQ_FORMAT` macro for using this
/datum/job_playtime_req/New(eligibility_count, job_playtime_requirement, combined_playtime_req=0, reversed_check=null, group_display_name=null, ultimate=null)
	stored_eligibility_count_requirement = eligibility_count
	stored_job_playtime_requirement = job_playtime_requirement
	stored_playtime_requirement = combined_playtime_req
	reversed_timecheck = reversed_check
	if(group_display_name)
		stored_group_display_name = group_display_name

	var/checakble_jobs = 0
	for(var/each_job in stored_job_playtime_requirement)
		if(stored_job_playtime_requirement[each_job])
			checakble_jobs++
	if(stored_eligibility_count_requirement > checakble_jobs)
		stack_trace("Jobs that have timecheck are [checakble_jobs], but the required number is [stored_eligibility_count_requirement]")
		stored_eligibility_count_requirement = checakble_jobs

	if(!stored_eligibility_count_requirement && checakble_jobs > 0)
		stack_trace("Eligibility count is 0, but playtime checkable jobs are [checakble_jobs] - setting to 1.")
		stored_eligibility_count_requirement = 1

	if(checakble_jobs == stored_eligibility_count_requirement)
		boxing_flag = FALSE

	if(ultimate)
		ultimate_req = TRUE



/datum/job_playtime_req/proc/check_eligibility(client/cli, returns_details=FALSE)
	var/list/playrecord = cli.prefs.exp
	var/list/result_description = INIT_EXP_LIST
	var/calculated_playtime_requirement = stored_playtime_requirement
	var/calculated_count = stored_eligibility_count_requirement

	var/list/result_jobs = list()
	for(var/each_job in stored_job_playtime_requirement)
		calculated_playtime_requirement -= playrecord[each_job]

		// standard playtime check
		if(!reversed_timecheck)
			if(!stored_job_playtime_requirement[each_job])
				continue
			var/playtime_result = stored_job_playtime_requirement[each_job] - playrecord[each_job]
			if(playtime_result <= 0) // Negative: You played this job enough
				calculated_count--
				if(returns_details && boxing_flag) // line-through style to tell you're qualified
					result_jobs += "-- <span style='text-decoration:line-through;'>Play [get_exp_format(playtime_result)] more as [each_job]</span>."
				if(!calculated_count)
					break
			else if(returns_details) // Positive + detail flag: Builds what you need to play
				result_jobs += "[boxing_flag ? "-- " : ""]Play [get_exp_format(playtime_result)] more as [each_job]."

		// playtime reversed check: play less time then the requirement
		else
			var/playtime_result = playrecord[each_job] - stored_job_playtime_requirement[each_job] // reversed
			if(playtime_result <= 0) // Negative: You didn't play much
				calculated_count--
				if(returns_details && boxing_flag)
					result_jobs += "-- <span style='text-decoration:line-through;'>Play less than [get_exp_format(playtime_result)] as [each_job]</span>."
				if(!calculated_count)
					break
			else if(returns_details) // Positive + detail flag: Builds what you need to play
				result_jobs += "[boxing_flag ? "-- " : ""]Play less than [get_exp_format(playtime_result)] as [each_job]."

	if(calculated_count)
		result_description[EXP_CHECK_PASS] = FALSE
		if(returns_details)
			if(boxing_flag)
				result_description[EXP_CHECK_DESC] += "< Meet [calculated_count] more conditions below >"
				if(ultimate_req)
					result_description[EXP_CHECK_DESC] += "If you make the requirement, you don't have to qualify other requirement."
					ultimate_req = FALSE
			result_description[EXP_CHECK_DESC] += result_jobs

	if(calculated_playtime_requirement > 0)
		result_description[EXP_CHECK_PASS] = FALSE
		if(returns_details)
			if(!reversed_timecheck)
				result_description[EXP_CHECK_DESC] += "Play [get_exp_format(calculated_playtime_requirement)] more [stored_group_display_name ? stored_group_display_name : "as any of [english_list(stored_job_playtime_requirement, and_text=", or ")]"].[ultimate_req ? " (If you make this requirement, you don't have to qualify other requirement.)" : ""]"
			else
				result_description[EXP_CHECK_DESC] += "Play less than [get_exp_format(calculated_playtime_requirement)] [stored_group_display_name ? stored_group_display_name : "as any of [english_list(stored_job_playtime_requirement, and_text=", or ")]"].[ultimate_req ? " (If you make this requirement, you don't have to qualify other requirement.)" : ""]"

	return result_description
