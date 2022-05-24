/datum/game_mode
	var/gamemode_status = 0
	var/list/datum/mind/besiegers = list()

/datum/game_mode/siege
	name = "siege"
	config_tag = "siege"
	report_type = "nuclear"
	antag_flag = ROLE_BESIEGER
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Head of Personnel", "Captain")
	required_players = 0
	required_enemies = 1
	recommended_enemies = 1
	enemy_minimum_age = 0
	title_icon = "nuclear"
	announce_span = "danger"
	announce_text = "The syndicate has united and is launching an all out war on NanoTrasen!\n\
	<span class='danger'>Besieger</span>: Kill all of the crew and/or destroy the station.\n\
	<span class='danger'>Crew</span>: Protect the station for as long as possible, until you can be relieved!"
	var/datum/team/brother_team/siege/team

/datum/game_mode/siege/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"
	if(CONFIG_GET(flag/protect_heads_from_antagonist))
		restricted_jobs += GLOB.command_positions

	var/list/datum/mind/possible_besiegers = get_players_for_role(ROLE_BESIEGER)
	var/team_size = 1//required_enemies + round(num_players() * CONFIG_GET(number/traitor_scaling_coeff) / 2)
	team = new
	for(var/k = 1 to team_size)
		if (!antag_candidates.len)
			break
		var/datum/mind/b = antag_pick(possible_besiegers, ROLE_BESIEGER)
		possible_besiegers -= b
		antag_candidates -= b
		team.add_member(b)
		b.special_role = "besieger"
		log_game("[key_name(b)] has been selected as a besieger")
	team.pick_meeting_area()
	return TRUE


/datum/game_mode/siege/post_setup()
	for(var/datum/mind/M in team.members)
		M.add_antag_datum(/datum/antagonist/siege, team)
	..()
	gamemode_ready = TRUE
	return TRUE

/datum/game_mode/siege/generate_report()
	return "The syndicate has united and is launching an all out war on NanoTrasen! Protect the station for as long as possible, until you can be relieved."

/datum/game_mode/siege/generate_credit_text()
	var/list/round_credits = list()

	round_credits += "<center><h1>Siege: </h1>"
	round_credits += "The Station lasted until [station_time_timestamp()]!"
	round_credits += ..()
	return round_credits
