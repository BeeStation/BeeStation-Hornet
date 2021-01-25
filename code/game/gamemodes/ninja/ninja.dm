/datum/game_mode
	var/list/datum/mind/ninjas = list()

/datum/game_mode/ninja
	name = "ninja_incursion"
	config_tag = "ninja_incursion"
	false_report_weight = 5
	required_players = 20
	required_enemies = 2
	recommended_enemies = 2
	antag_flag = ROLE_NINJA
	enemy_minimum_age = 14

	announce_span = "danger"
	announce_text = "The station is being infiltrated by spider clan operatives!\n\
	<span class='danger'>Ninjas</span>: Remain undetected and complete your objectives!\n\
	<span class='notice'>Crew</span>: Locate and kill the ninjas!"

/datum/game_mode/ninja/pre_setup()
	recommended_enemies = round(num_players() / 10) // How many ninjas?
	if(recommended_enemies < 1)
		recommended_enemies = 1 // In the event that this is run on extreme lowpop it won't break
	for(var/i = 0, i < recommended_enemies, ++i)
		var/datum/mind/ninja = antag_pick(antag_candidates, ROLE_NINJA)
		ninja.assigned_role = ROLE_NINJA
		ninja.special_role = ROLE_NINJA
		log_game("[key_name(ninja)] has been selected as a Space Ninja")
		ninjas += ninja
		
	return TRUE

/datum/game_mode/ninja/post_setup()
	for(var/datum/mind/ninja in ninjas)
		ninja.add_antag_datum(/datum/antagonist/ninja)
	return ..() 
