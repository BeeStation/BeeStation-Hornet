/datum/game_mode
	var/list/datum/mind/ninjas = list()

/datum/game_mode/ninja
	name = "ninja_incursion"
	config_tag = "ninja_incursion"
	false_report_weight = 5
	required_players = 0 // Set to 20 when it's debugged
	required_enemies = 1
	recommended_enemies = 3
	antag_flag = ROLE_NINJA
	enemy_minimum_age = 14

	announce_span = "danger"
	announce_text = "The station is being infiltrated by spider clan operatives!\n\
	<span class='danger'>Ninjas</span>: Remain undetected and complete your objectives!\n\
	<span class='notice'>Crew</span>: Locate and kill the ninjas!"


/datum/game_mode/ninja/post_setup()
	for(var/datum/mind/ninja in ninjas)
		ninja.add_antag_datum(/datum/antagonist/ninja)
	return ..()

/datum/game_mode/ninja/pre_setup()
	var/datum/mind/ninja = antag_pick(antag_candidates, ROLE_NINJA)
	ninjas += ninja
	ninja.assigned_role = ROLE_NINJA
	ninja.special_role = ROLE_NINJA
	log_game("[key_name(ninja)] has been selected as a Space Ninja")
	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/carpspawn/S in GLOB.landmarks_list)
		if(isturf(S.loc))
			spawn_locs += S.loc
		if(!spawn_locs.len)
			return
	var/spawn_loc = pick(spawn_locs)
	if(!spawn_loc)
		return MAP_ERROR
	for(var/datum/mind/ninjanew in ninjas)
		ninjanew.current.forceMove(spawn_loc)
	return TRUE