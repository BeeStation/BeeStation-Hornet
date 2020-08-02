/datum/game_mode
	var/list/datum/mind/incursionists = list()
	var/datum/team/incursion/incursion_team

/datum/game_mode/incursion
	name = "incursion"
	config_tag = "incursion"
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Brig Physician")
	antag_flag = ROLE_INCURSION
	false_report_weight = 10
	enemy_minimum_age = 0

	announce_span = "danger"
	announce_text = "A large force of syndicate operatives have infiltrated the ranks of the station and wish to take it by force!\n\
	<span class='danger'>Incursionists</span>: Accomplish your objectives.\n\
	<span class='notice'>Crew</span>: Find and prevent the operatives from completing their goals!"

	required_enemies = 1

	title_icon = "traitor"

	var/datum/team/incursion/pre_incursionist_team
	var/const/team_amount = 1 //hard limit on brother teams if scaling is turned off
	var/const/min_team_size = 2

/datum/game_mode/incursion/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	var/list/datum/mind/possible_traitors = get_players_for_role(ROLE_INCURSION)

	var/datum/team/incursion/team = new
	var/cost_base = CONFIG_GET(number/incursion_cost_base)
	var/cost_increment = CONFIG_GET(number/incursion_cost_increment)
	var/pop = GLOB.player_details.len
	var/team_size = (2 * pop) / ((2 * cost_base) + ((pop - 1) * cost_increment))
	log_game("Spawning [team_size] incursionists.")
	team_size = CLAMP(team_size, CONFIG_GET(number/incursion_count_min), CONFIG_GET(number/incursion_count_max))

	for(var/k = 1 to team_size)
		var/datum/mind/incursion = antag_pick(possible_traitors, ROLE_INCURSION)
		if(!incursion)
			message_admins("Ran out of people to put in an incursion team, wanted [team_size] but only got [k-1]")
			break
		possible_traitors -= incursion
		antag_candidates -= incursion
		team.add_member(incursion)
		incursion.special_role = "incursionist"
		incursion.restricted_roles = restricted_jobs
		log_game("[key_name(incursion)] has been selected as a member of the incursion")
	pre_incursionist_team = team
	gamemode_ready = TRUE
	return TRUE

/datum/game_mode/incursion/post_setup()
	var/datum/team/incursion/team = pre_incursionist_team
	team.forge_team_objectives()
	for(var/datum/mind/M in team.members)
		M.add_antag_datum(/datum/antagonist/incursion, team)
	incursion_team = pre_incursionist_team
	return ..()

/datum/game_mode/incursion/generate_report()
	return "Intel suggests that the Syndicate have recently had high level meetings discussing your station, and are disgruntled due to recent classified events. A large terrorist force may wish to take the station by force."

//===please merge heretics so these can be made not terrible===
/datum/game_mode/proc/update_incursion_icons_added(datum/mind/incursion_mind)
	var/datum/atom_hud/antag/incursionhud = GLOB.huds[ANTAG_HUD_INCURSION]
	incursionhud.join_hud(incursion_mind.current)
	set_antag_hud(incursion_mind.current, "traitor")

/datum/game_mode/proc/update_incursion_icons_removed(datum/mind/incursion_mind)
	var/datum/atom_hud/antag/incursionhud = GLOB.huds[ANTAG_HUD_INCURSION]
	incursionhud.leave_hud(incursion_mind.current)
	set_antag_hud(incursion_mind.current, null)
