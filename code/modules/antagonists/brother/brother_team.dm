/datum/team/brother_team
	name = "brotherhood"
	member_name = "blood brother"
	var/team_id
	var/meeting_area
	var/static/meeting_areas = list("The Bar", "Dorms", "Escape Dock", "Arrivals", "Holodeck", "Primary Tool Storage", "Recreation Area", "Chapel", "Library")
	/// List of minds that we can convert
	var/list/valid_converts = list()

/datum/team/brother_team/New(starting_members)
	. = ..()
	var/static/blood_teams
	team_id = ++blood_teams

/datum/team/brother_team/is_solo()
	return FALSE

/datum/team/brother_team/proc/pick_meeting_area()
	meeting_area = pick(meeting_areas)
	meeting_areas -= meeting_area

/datum/team/brother_team/proc/update_name()
	var/list/last_names = list()
	for(var/datum/mind/M in members)
		var/list/split_name = splittext(M.name," ")
		last_names += split_name[split_name.len]

	name = last_names.Join(" & ")

/datum/team/brother_team/roundend_report()
	var/list/parts = list()

	parts += span_header("The blood brothers of [name] were:")
	for(var/datum/mind/M in members)
		parts += printplayer(M)
	var/win = TRUE
	var/objective_count = 1
	for(var/datum/objective/objective in objectives)
		if(objective.check_completion())
			parts += "<B>Objective #[objective_count]</B>: [objective.explanation_text] [span_greentext("Success!")]"
		else
			parts += "<B>Objective #[objective_count]</B>: [objective.explanation_text] [span_redtext("Fail.")]"
			win = FALSE
		objective_count++
	if(win)
		parts += span_greentext("The blood brothers were successful!")
	else
		parts += span_redtext("The blood brothers have failed!")

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/brother_team/proc/add_objective(datum/objective/O, needs_target = FALSE)
	O.team = src
	if(needs_target)
		O.find_target(dupe_search_range = list(src))
	O.update_explanation_text()
	objectives += O
	for(var/datum/mind/member in members)
		log_objective(member, O.explanation_text)

/datum/team/brother_team/proc/forge_brother_objectives()
	objectives = list()
	var/is_hijacker = prob(10)
	for(var/i = 1 to max(1, CONFIG_GET(number/brother_objectives_amount) + (members.len > 2) - is_hijacker))
		forge_single_objective()
	if(is_hijacker)
		if(!locate(/datum/objective/hijack) in objectives)
			add_objective(new /datum/objective/hijack)
	else if(!locate(/datum/objective/escape) in objectives)
		add_objective(new /datum/objective/escape)

/datum/team/brother_team/proc/forge_single_objective()
	if(prob(50))
		if(LAZYLEN(active_ais()) && prob(100 / length(GLOB.joined_player_list)))
			add_objective(new /datum/objective/destroy, TRUE)
		else if(prob(30))
			add_objective(new /datum/objective/maroon, TRUE)
		else
			add_objective(new /datum/objective/assassinate, TRUE)
	else
		add_objective(new /datum/objective/steal, TRUE)

/datum/team/brother_team/proc/listen_for_joiners()
	// Whenever a crewmember joins, check to see if we have any empty space for new
	// conversions.
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, PROC_REF(fill_conversions))

/datum/team/brother_team/proc/add_valid_conversion(datum/mind/mind)
	valid_converts += mind
	RegisterSignal(mind, COMSIG_QDELETING, PROC_REF(on_conversion_deleted))

/datum/team/brother_team/proc/on_conversion_deleted(datum/mind/mind)
	SIGNAL_HANDLER
	valid_converts -= mind
	// Get new conversions to fill the gaps
	fill_conversions()

/datum/team/brother_team/proc/fill_conversions()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(fill_conversions_async))

/datum/team/brother_team/proc/fill_conversions_async()
	// Fill up our conversion count until we have 3
	var/list/options = get_conversion_targets()
	while (length(options) > 0 && length(valid_converts) < 3)
		var/datum/mind/selected = pick_n_take(options)
		if (selected in valid_converts)
			continue
		add_valid_conversion(selected)

/datum/team/brother_team/proc/get_conversion_targets()
	var/list/candidates = list()
	var/sec_count = 0
	for (var/job in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SECURITY))
		sec_count += SSjob.GetJob(job).current_positions
	var/sec_allowed = sec_count >= 2
	for (var/datum/mind/mind in SSticker.minds)
		// Mind has no mob
		if (!mind.current)
			continue
		// Mind has no client
		if (!mind.current.client)
			continue
		// Mind is already in the team
		if (mind in members)
			continue
		// Not a human
		if (!ishuman(mind.current))
			continue
		// Banned or disabled in the preferences
		if (!mind.current.client.should_include_for_role(ROLE_BROTHER, /datum/role_preference/supplementary/brother/convert))
			continue
		// Is an antagonist already
		if (length(mind.antag_datums) || mind.special_role)
			continue
		// Are we allowed security?
		var/datum/job/job = SSjob.GetJob(mind.assigned_role)
		if (istype(job, /datum/job))
			if (!sec_allowed && CHECK_BITFIELD(job.departments, DEPT_BITFLAG_SEC))
				continue
			// Are they a head?
			if (CHECK_BITFIELD(job.departments, DEPT_BITFLAG_COM))
				continue
		// Mind is a target
		var/is_target = FALSE
		for (var/datum/objective/objective in objectives)
			if (objective.target == mind)
				is_target = TRUE
				break
		if (is_target)
			continue
		// Valid conversion
		candidates += mind
	return candidates

/datum/team/brother_team/antag_listing_name()
	return "[name] blood brothers"
