
//////////////////////////////////////////////
//                                          //
//         LIVING MIDROUND RULESETS         //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround // Can be drafted once in a while during a round
	rule_category = DYNAMIC_MIDROUND
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, "Positronic Brain")

	/// How dangerous/disruptive the ruleset is. (DYNAMIC_MIDROUND_LIGHT, DYNAMIC_MIDROUND_MEDIUM, DYNAMIC_MIDROUND_HEAVY)
	var/severity = DYNAMIC_MIDROUND_LIGHT
	/// Whether or not ghost roles are allowed to roll this ruleset (Ashwalkers, Golems, Drones, etc.)
	var/allow_ghost_roles = FALSE
	/// What mob type the ruleset is restricted to.
	var/mob_type = /mob/living/carbon/human

/datum/dynamic_ruleset/midround/trim_candidates()
	. = ..()
	for(var/mob/candidate in candidates)
		// Correct mob type?
		if(!istype(candidate, mob_type))
			candidates -= candidate
			continue
		// Compatible job?
		if(candidate.mind.assigned_role in restricted_roles)
			candidates -= candidate
			continue
		// Are ghost roles allowed?
		if(!allow_ghost_roles && (candidate.mind.assigned_role in GLOB.exp_specialmap[EXP_TYPE_SPECIAL]))
			candidates -= candidate
			continue

/datum/dynamic_ruleset/midround/get_candidates()
	candidates = dynamic.current_players[CURRENT_LIVING_PLAYERS]

//////////////////////////////////////////////
//                                          //
//         GHOST MIDROUND RULESETS          //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost
	mob_type = /mob/dead/observer

/datum/dynamic_ruleset/midround/ghost/get_candidates()
	candidates = dynamic.current_players[CURRENT_DEAD_PLAYERS] | dynamic.current_players[CURRENT_OBSERVERS]

/datum/dynamic_ruleset/midround/ghost/execute()
	send_applications() // Get ghost applications
	trim_candidates() // Trim candidates
	pre_execute() // Choose antags

	if(!length(chosen_minds))
		return DYNAMIC_EXECUTE_NOT_ENOUGH_PLAYERS

	// Generate a body
	for(var/datum/mind/chosen_mind in chosen_minds)
		var/mob/new_character = generate_ruleset_body(chosen_mind.current)

		finish_setup(new_character)
		notify_ghosts("[chosen_mind.current.name] has been picked for the ruleset [name]!", source = new_character, action = NOTIFY_ORBIT, header = "Something Interesting!")

	. = ..()

/datum/dynamic_ruleset/midround/ghost/trim_candidates()
	. = ..()
	for(var/mob/candidate in candidates)
		// Must be observing
		if(!isobserver(candidate))
			if(candidate.stat == DEAD)
				// Probably just entered their body after signing up for the midround, lets turn them into a ghost
				candidate = candidate.ghostize(FALSE, SENTIENCE_ERASE)
			else
				// Got revived- smell ya later
				candidates -= candidate
				continue

	if(!length(candidates))
		message_admins("No players were eligible for the ruleset [name] - the previous applicants were revived/left and could no longer take the role.")
		log_game("DYNAMIC: No players were eligible for the ruleset [name] - the previous applicants were revived/left and could no longer take the role.")

/*
* Send a poll to ghosts to see if they wanna sign up for a ruleset
*/
/datum/dynamic_ruleset/midround/ghost/proc/send_applications()
	// How?
	if(!length(candidates))
		return

	message_admins("Polling [length(candidates)] players to apply for the [name] ruleset.")
	log_game("DYNAMIC: Polling [length(candidates)] players to apply for the [name] ruleset.")

	candidates = poll_ghost_candidates("Looking for volunteers to become [initial(antag_datum.name)] for [name]", initial(antag_datum.banning_key), role_preference)

	if(!length(candidates))
		message_admins("The ruleset [name] received no applications.")
		log_game("DYNAMIC: The ruleset [name] received no applications.")
		return

	if(length(candidates) >= drafted_players_amount)
		message_admins("[length(candidates)] players volunteered for the ruleset [name].")
		log_game("DYNAMIC: [length(candidates)] players volunteered for [name].")
		return
	else
		message_admins("Not enough players volunteered for the ruleset [name] - [length(candidates)] out of [drafted_players_amount].")
		log_game("DYNAMIC: Not enough players volunteered for the ruleset [name] - [length(candidates)] out of [drafted_players_amount].")


/datum/dynamic_ruleset/midround/ghost/proc/generate_ruleset_body(mob/chosen_mob)
	var/mob/living/carbon/human/new_character = makeBody(chosen_mob)
	new_character.dna.remove_all_mutations()
	return new_character

/datum/dynamic_ruleset/midround/ghost/proc/finish_setup(mob/new_character, index)
	var/datum/antagonist/new_role = new antag_datum()
	setup_role(new_role)
	new_character.mind.add_antag_datum(new_role)
	new_character.mind.special_role = new_role.banning_key

/datum/dynamic_ruleset/midround/ghost/proc/setup_role(datum/antagonist/new_role)
	return
/*
//////////////////////////////////////////////
//                                          //
//               SLEEPER AGENT              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/autotraitor
	name = "Syndicate Sleeper Agent"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_LIGHT
	antag_datum = /datum/antagonist/traitor
	role_preference = /datum/role_preference/midround_living/traitor
	protected_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	restricted_roles = list(JOB_NAME_CYBORG, JOB_NAME_AI, "Positronic Brain")
	required_candidates = 1
	weight = 20
	cost = 8
	requirements = list(8,8,8,8,8,8,8,8,8,8)
	repeatable = TRUE
	flags = INTACT_STATION_RULESET
	blocking_rules = list(
		/datum/dynamic_ruleset/roundstart/bloodcult,
		/datum/dynamic_ruleset/roundstart/clockcult,
		/datum/dynamic_ruleset/roundstart/nuclear,
		/datum/dynamic_ruleset/roundstart/wizard,
		/datum/dynamic_ruleset/roundstart/revs,
	)

/datum/dynamic_ruleset/midround/autotraitor/trim_candidates()
	..()
	candidates = living_players
	for(var/mob/living/player in candidates)
		if(issilicon(player)) // Your assigned role doesn't change when you are turned into a silicon.
			candidates -= player
			continue
		if(is_centcom_level(player.z))
			candidates -= player // We don't autotator people in CentCom
			continue
		if(player.mind && (player.mind.special_role || length(player.mind.antag_datums)))
			candidates -= player // We don't autotator people with roles already

/datum/dynamic_ruleset/midround/autotraitor/execute(forced = FALSE)
	var/mob/M = antag_pick_n_take(candidates)
	assigned += M
	var/datum/antagonist/traitor/newTraitor = new
	M.mind.add_antag_datum(newTraitor)
	return DYNAMIC_EXECUTE_SUCCESS

//////////////////////////////////////////////
//                                          //
//         	Value Drifted AI               	//
//                              		    //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/malf
	name = "Value Drifted AI"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	antag_datum = /datum/antagonist/malf_ai
	role_preference = /datum/role_preference/midround_living/malfunctioning_ai
	exclusive_roles = list(JOB_NAME_AI)
	required_candidates = 1
	minimum_players = 30
	weight = 4
	cost = 13
	mob_type = /mob/living/silicon/ai
	blocking_rules = list(/datum/dynamic_ruleset/roundstart/nuclear)
	var/ion_announce = 33
	var/removeDontImproveChance = 10

/datum/dynamic_ruleset/midround/malf/trim_candidates()
	..()
	candidates = living_players
	for(var/mob/living/player in candidates)
		if(!isAI(player))
			candidates -= player
			continue
		if(is_centcom_level(player.z))
			candidates -= player
			continue
		if(player.mind && (player.mind.special_role || length(player.mind.antag_datums)))
			candidates -= player

/datum/dynamic_ruleset/midround/malf/execute(forced = FALSE)
	if(!length(candidates))
		return DYNAMIC_EXECUTE_NOT_ENOUGH_PLAYERS
	var/mob/living/silicon/ai/AI = antag_pick_n_take(candidates)
	assigned += AI.mind
	var/datum/antagonist/malf_ai/malf_datum = new
	AI.mind.special_role = ROLE_MALF
	AI.mind.add_antag_datum(malf_datum)
	if(prob(ion_announce))
		priority_announce("Ion storm detected near the station. Please check all AI-controlled equipment for errors.", "Anomaly Alert", ANNOUNCER_IONSTORM)
		if(prob(removeDontImproveChance))
			AI.replace_random_law(generate_ion_law(), list(LAW_INHERENT, LAW_SUPPLIED, LAW_ION))
		else
			AI.add_ion_law(generate_ion_law())
	return DYNAMIC_EXECUTE_SUCCESS

//////////////////////////////////////////////
//                                          //
//              WIZARD (GHOST)              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/wizard
	name = "Wizard"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	antag_datum = /datum/antagonist/wizard
	role_preference = /datum/role_preference/midround_ghost/wizard
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_RESEARCHDIRECTOR) //RD doesn't believe in magic
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 1
	cost = 15
	requirements = REQUIREMENTS_VERY_HIGH_THREAT_NEEDED
	flags = HIGH_IMPACT_RULESET|PERSISTENT_RULESET

/datum/dynamic_ruleset/midround/ghost/wizard/ready(forced = FALSE)
	if(!length(GLOB.wizardstart))
		log_game("DYNAMIC: Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/ghost/wizard/finish_setup(mob/new_character, index)
	..()
	new_character.forceMove(pick(GLOB.wizardstart))

//////////////////////////////////////////////
//                                          //
//          NUCLEAR OPERATIVES (MIDROUND)   //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/nuclear
	name = "Nuclear Assault"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	role_preference = /datum/role_preference/midround_ghost/nuclear_operative
	antag_datum = /datum/antagonist/nukeop
	enemy_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_enemies = list(3,3,2,2,2,2,1,1,0,0)
	required_candidates = 5
	weight = 5
	cost = 15
	minimum_round_time = 70 MINUTES
	requirements = REQUIREMENTS_VERY_HIGH_THREAT_NEEDED
	var/list/operative_cap = list(2,2,3,3,4,5,5,5,5,5)
	var/datum/team/nuclear/nuke_team
	flags = HIGH_IMPACT_RULESET|PERSISTENT_RULESET

/datum/dynamic_ruleset/midround/ghost/nuclear/acceptable(population=0, threat=0)
	if (locate(/datum/dynamic_ruleset/roundstart/nuclear) in mode.executed_rules)
		return FALSE // Unavailable if nuke ops were already sent at roundstart
	indice_pop = min(length(operative_cap), round(length(living_players)/5)+1)
	required_candidates = operative_cap[indice_pop]
	return ..()

/datum/dynamic_ruleset/midround/ghost/nuclear/finish_setup(mob/new_character, index)
	new_character.mind.special_role = ROLE_OPERATIVE
	new_character.mind.assigned_role = ROLE_OPERATIVE
	if (index == 1) // Our first guy is the leader
		var/datum/antagonist/nukeop/leader/new_role = new
		nuke_team = new_role.nuke_team
		new_character.mind.add_antag_datum(new_role)
	else
		return ..()

//////////////////////////////////////////////
//                                          //
//              BLOB (GHOST)                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/blob
	name = "Blob"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	antag_datum = /datum/antagonist/blob
	role_preference = /datum/role_preference/midround_ghost/blob
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	minimum_round_time = 35 MINUTES
	weight = 3
	cost = 12
	minimum_players = 22
	flags = HIGH_IMPACT_RULESET|INTACT_STATION_RULESET|PERSISTENT_RULESET

/datum/dynamic_ruleset/midround/ghost/blob/generate_ruleset_body(mob/applicant)
	var/body = applicant.become_overmind()
	return body

//////////////////////////////////////////////
//                                          //
//           XENOMORPH (GHOST)              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/xenomorph
	name = "Alien Infestation"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	antag_datum = /datum/antagonist/xeno
	role_preference = /datum/role_preference/midround_ghost/xenomorph
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_enemies = list(2,2,2,1,1,1,1,0,0,0)
	required_candidates = 1
	minimum_round_time = 40 MINUTES
	weight = 3
	cost = 12
	minimum_players = 22
	flags = HIGH_IMPACT_RULESET|INTACT_STATION_RULESET|PERSISTENT_RULESET
	var/list/vents

/datum/dynamic_ruleset/midround/ghost/xenomorph/acceptable(population=0, threat=0)
	// 50% chance of being incremented by one
	required_candidates += prob(50)
	return ..()

/datum/dynamic_ruleset/midround/ghost/xenomorph/ready(forced = FALSE)
	if(!..())
		return FALSE
	vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in GLOB.machines)
		if(QDELETED(temp_vent))
			continue
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipenet/temp_vent_parent = temp_vent.parents[1]
			if(!temp_vent_parent)
				continue // No parent vent
			// Stops Aliens getting stuck in small networks.
			// See: Security, Virology
			if(length(temp_vent_parent.other_atmos_machines) > 20)
				vents += temp_vent
	if(!length(vents))
		log_game("DYNAMIC: [ruletype] ruleset [name] ready() failed due to no valid spawn locations.")
		return FALSE
	return TRUE

/datum/dynamic_ruleset/midround/ghost/xenomorph/generate_ruleset_body(mob/applicant)
	var/obj/vent = pick_n_take(vents)
	var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
	new_xeno.key = applicant.key
	message_admins("[ADMIN_LOOKUPFLW(new_xeno)] has been made into an alien by the midround ruleset.")
	log_game("DYNAMIC: [key_name(new_xeno)] was spawned as an alien by the midround ruleset.")
	return new_xeno

//////////////////////////////////////////////
//                                          //
//           NIGHTMARE (GHOST)              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/nightmare
	name = "Nightmare"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_LIGHT
	antag_datum = /datum/antagonist/nightmare
	role_preference = /datum/role_preference/midround_ghost/nightmare
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_enemies = list(1,1,1,1,0,0,0,0,0,0)
	required_candidates = 1
	weight = 5
	cost = 6
	minimum_players = 12
	repeatable = TRUE
	var/list/spawn_locs

/datum/dynamic_ruleset/midround/ghost/nightmare/ready(forced = FALSE)
	if(!..())
		return FALSE
	spawn_locs = list()
	for(var/X in GLOB.xeno_spawn)
		var/turf/T = X
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			spawn_locs += T
	if(!length(spawn_locs))
		log_game("DYNAMIC: [ruletype] ruleset [name] ready() failed due to no valid spawn locations.")
		return FALSE
	return TRUE

/datum/dynamic_ruleset/midround/ghost/nightmare/generate_ruleset_body(mob/applicant)
	var/datum/mind/player_mind = new /datum/mind(applicant.key)
	player_mind.active = TRUE

	var/mob/living/carbon/human/S = new (pick(spawn_locs))
	player_mind.transfer_to(S)
	S.set_species(/datum/species/shadow/nightmare)

	playsound(S, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Nightmare by the midround ruleset.")
	log_game("DYNAMIC: [key_name(S)] was spawned as a Nightmare by the midround ruleset.")
	return S

//////////////////////////////////////////////
//                                          //
//           SPACE DRAGON (GHOST)           //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/space_dragon
	name = "Space Dragon"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	antag_datum = /datum/antagonist/space_dragon
	role_preference = /datum/role_preference/midround_ghost/space_dragon
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_enemies = list(1,1,1,1,0,0,0,0,0,0)
	required_candidates = 1
	weight = 4
	cost = 11
	minimum_players = 22
	repeatable = TRUE
	flags = INTACT_STATION_RULESET|PERSISTENT_RULESET
	var/list/spawn_locs

/datum/dynamic_ruleset/midround/ghost/space_dragon/ready(forced = FALSE)
	if(!..())
		return FALSE
	spawn_locs = list()
	for(var/obj/effect/landmark/carpspawn/spawnpoint in GLOB.landmarks_list)
		spawn_locs += spawnpoint.loc
	if(!length(spawn_locs))
		log_game("DYNAMIC: [ruletype] ruleset [name] ready() failed due to no valid spawn locations.")
		return FALSE
	return TRUE

/datum/dynamic_ruleset/midround/ghost/space_dragon/generate_ruleset_body(mob/applicant)
	var/datum/mind/player_mind = new /datum/mind(applicant.key)
	player_mind.active = TRUE

	var/mob/living/simple_animal/hostile/space_dragon/S = new (pick(spawn_locs))
	player_mind.transfer_to(S)

	playsound(S, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Space Dragon by the midround ruleset.")
	log_game("DYNAMIC: [key_name(S)] was spawned as a Space Dragon by the midround ruleset.")
	priority_announce("It appears a lifeform with magical traces is approaching [station_name()], please stand-by.", "Lifesign Alert")
	return S

//////////////////////////////////////////////
//                                          //
//           ABDUCTORS    (GHOST)           //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/abductors
	name = "Abductors"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_LIGHT
	role_preference = /datum/role_preference/midround_ghost/abductor
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_enemies = list(2,2,1,1,1,1,0,0,0,0)
	required_candidates = 2
	required_applicants = 2
	weight = 4
	cost = 7
	minimum_players = 22
	repeatable = TRUE
	var/datum/team/abductor_team/new_team

/datum/dynamic_ruleset/midround/ghost/abductors/finish_setup(mob/new_character, index)
	if (index == 1) // Our first guy is the scientist.  We also initialize the team here as well since this should only happen once per pair of abductors.
		new_team = new
		if(new_team.team_number > ABDUCTOR_MAX_TEAMS)
			return MAP_ERROR
		var/datum/antagonist/abductor/scientist/new_role = new
		new_character.mind.add_antag_datum(new_role, new_team)
	else // Our second guy is the agent, team is already created, don't need to make another one.
		var/datum/antagonist/abductor/agent/new_role = new
		new_character.mind.add_antag_datum(new_role, new_team)

//////////////////////////////////////////////
//                                          //
//           REVENANT    (GHOST)            //
//                                          //
//////////////////////////////////////////////
/datum/dynamic_ruleset/midround/ghost/revenant
	name = "Revenant"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_LIGHT
	antag_datum = /datum/antagonist/revenant
	role_preference = /datum/role_preference/midround_ghost/revenant
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_enemies = list(1,1,1,1,0,0,0,0,0,0)
	required_candidates = 1
	weight = 5
	cost = 5
	minimum_players = 12
	repeatable = TRUE
	var/dead_mobs_required = 15
	var/need_extra_spawns_value = 15
	var/list/spawn_locs

/datum/dynamic_ruleset/midround/ghost/revenant/acceptable(population=0, threat=0)
	if(length(GLOB.dead_mob_list) < dead_mobs_required)
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/ghost/revenant/ready(forced = FALSE)
	if(!..())
		return FALSE
	spawn_locs = list()
	for(var/mob/living/corpse in GLOB.dead_mob_list) //look for any dead bodies
		var/turf/corpse_turf = get_turf(corpse)
		if(corpse_turf && is_station_level(corpse_turf.z))
			spawn_locs += corpse_turf
	if(!length(spawn_locs) || length(spawn_locs) < need_extra_spawns_value) //look for any morgue trays, crematoriums, ect if there weren't alot of dead bodies on the station to pick from
		for(var/obj/structure/bodycontainer/corpse_container in GLOB.bodycontainers)
			var/turf/container_turf = get_turf(corpse_container)
			if(container_turf && is_station_level(container_turf.z))
				spawn_locs += container_turf
	if(!length(spawn_locs)) //If we can't find any valid spawnpoints, try the carp spawns
		for(var/obj/effect/landmark/carpspawn/carp_spawnpoint in GLOB.landmarks_list)
			if(isturf(carp_spawnpoint.loc))
				spawn_locs += carp_spawnpoint.loc
	if(!length(spawn_locs)) //If we can't find THAT, then just give up and cry
		log_game("DYNAMIC: [ruletype] ruleset [name] ready() failed due to no valid spawn locations.")
		return FALSE
	return TRUE

/datum/dynamic_ruleset/midround/ghost/revenant/generate_ruleset_body(mob/applicant)
	var/turf/spawnable_turf = get_non_holy_tile_from_list(spawn_locs)
	if(!spawnable_turf)
		message_admins("Failed to find a proper spawn location because there are a lot of blessed tiles. We'll spawn it anyway.")
		spawnable_turf = pick(spawn_locs)
	var/mob/living/simple_animal/revenant/revenant = new(spawnable_turf)
	revenant.key = applicant.key
	message_admins("[ADMIN_LOOKUPFLW(revenant)] has been made into a revenant by the midround ruleset.")
	log_game("[key_name(revenant)] was spawned as a revenant by the midround ruleset.")
	return revenant

//////////////////////////////////////////////
//                                          //
//           PIRATES    (GHOST)             //
//                                          //
//////////////////////////////////////////////
/datum/dynamic_ruleset/midround/pirates
	name = "Space Pirates"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	role_preference = /datum/role_preference/midround_ghost/space_pirate
	mob_type = /mob/dead/observer
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_enemies = list(2,2,2,1,1,1,1,0,0,0)
	required_candidates = 0
	weight = 4
	cost = 8
	minimum_players = 25
	repeatable = FALSE

/datum/dynamic_ruleset/midround/pirates/acceptable(population=0, threat=0)
	if (!SSmapping.empty_space)
		return FALSE
	if(GLOB.pirates_spawned)
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/pirates/execute(forced = FALSE)
	if(!GLOB.pirates_spawned)
		send_pirate_threat()
	return ..()

/// Obsessed ruleset
/datum/dynamic_ruleset/midround/obsessed
	name = "Obsessed"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_LIGHT
	antag_datum = /datum/antagonist/obsessed
	role_preference = /datum/role_preference/midround_living/obsessed
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG, "Positronic Brain")
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_enemies = list(1,1,1,1,0,0,0,0,0,0)
	required_candidates = 1
	weight = 3
	cost = 5
	repeatable = TRUE
	consider_antag_rep = TRUE

/datum/dynamic_ruleset/midround/obsessed/trim_candidates()
	..()
	candidates = living_players
	for(var/mob/living/carbon/human/candidate in candidates)
		if( \
			!candidate.getorgan(/obj/item/organ/brain) \
			|| candidate.mind.has_antag_datum(/datum/antagonist/obsessed) \
			|| candidate.stat == DEAD \
			|| !SSjob.GetJob(candidate.mind.assigned_role) \
			|| (candidate.mind.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SILICON)) \
		)
			candidates -= candidate

/datum/dynamic_ruleset/midround/obsessed/execute(forced = FALSE)
	var/mob/living/carbon/human/obsessed = antag_pick_n_take(candidates)
	obsessed.gain_trauma(/datum/brain_trauma/special/obsessed)
	message_admins("[ADMIN_LOOKUPFLW(obsessed)] has been made Obsessed by the midround ruleset.")
	log_game("[key_name(obsessed)] was made Obsessed by the midround ruleset.")
	return ..()

//////////////////////////////////////////////
//                                          //
//            SPIDERS     (GHOST)           //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/spiders
	name = "Spider Infestation"
	role_preference = /datum/role_preference/midround_ghost/spider
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	mob_type = /mob/dead/observer
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 2
	weight = 3
	cost = 11
	repeatable = TRUE
	flags = INTACT_STATION_RULESET|PERSISTENT_RULESET
	minimum_players = 25
	var/fed = 1
	var/list/vents
	var/datum/team/spiders/spider_team

/datum/dynamic_ruleset/midround/ghost/spiders/ready(forced = FALSE)
	if(!..())
		return FALSE
	vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in GLOB.machines)
		if(QDELETED(temp_vent))
			continue
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipenet/temp_vent_parent = temp_vent.parents[1]
			if(!temp_vent_parent)
				continue // No parent vent
			if(length(temp_vent_parent.other_atmos_machines) > 20)
				vents += temp_vent // Makes sure the pipenet is large enough
	if(!length(vents))
		log_game("DYNAMIC: [ruletype] ruleset [name] ready() failed due to no valid spawn locations.")
		return FALSE
	return TRUE

/datum/dynamic_ruleset/midround/ghost/spiders/generate_ruleset_body(mob/applicant)
	var/obj/vent = pick_n_take(vents)
	var/mob/living/simple_animal/hostile/poison/giant_spider/broodmother/spider = new(vent.loc)
	spider.key = applicant.key
	if(fed)
		spider.fed += 3
		spider.lay_eggs.update_buttons()
		fed--
	message_admins("[ADMIN_LOOKUPFLW(spider)] has been made into a spider by the midround ruleset.")
	log_game("DYNAMIC: [key_name(spider)] was spawned as a spider by the midround ruleset.")
	return spider

/datum/dynamic_ruleset/midround/ghost/spiders/finish_setup(mob/new_character, index)
	if(!spider_team)
		spider_team = new()
		spider_team.directive ="Ensure the survival of your brood and overtake whatever structure you find yourself in."
	var/datum/antagonist/spider/spider_antag = new_character.mind.has_antag_datum(/datum/antagonist/spider)
	spider_antag.set_spider_team(spider_team)
	new_character.mind.special_role = ROLE_SPIDER

//////////////////////////////////////////////
//                                          //
//             SWARMER (GHOST)              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/swarmer
	name = "Swarmer"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	antag_datum = /datum/antagonist/swarmer
	role_preference = /datum/role_preference/midround_ghost/swarmer
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_enemies = list(1,1,1,1,0,0,0,0,0,0)
	required_candidates = 1
	weight = 3
	cost = 10
	minimum_players = 15
	repeatable = FALSE // please no
	flags = INTACT_STATION_RULESET|PERSISTENT_RULESET
	var/announce_chance = 25

/datum/dynamic_ruleset/midround/ghost/swarmer/ready(forced = FALSE)
	if(!..())
		return FALSE
	if(!length(GLOB.xeno_spawn))
		log_game("DYNAMIC: [ruletype] ruleset [name] execute failed due to no valid spawn locations")
		return FALSE
	return TRUE

/datum/dynamic_ruleset/midround/ghost/swarmer/generate_ruleset_body(mob/applicant)
	var/datum/mind/player_mind = new /datum/mind(applicant.key)
	player_mind.active = TRUE

	var/mob/living/simple_animal/hostile/swarmer/S = new (pick(GLOB.xeno_spawn))
	player_mind.transfer_to(S)

	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Swarmer by the midround ruleset.")
	log_game("DYNAMIC: [key_name(S)] was spawned as a Swarmer by the midround ruleset.")
	if(prob(announce_chance))
		announce_swarmer()
	return S

//////////////////////////////////////////////
//                                          //
//              MORPH (GHOST)               //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/morph
	name = "Morph"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	antag_datum = /datum/antagonist/morph
	role_preference = /datum/role_preference/midround_ghost/morph
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_enemies = list(2,2,1,1,1,1,1,1,0,0)
	required_candidates = 1
	weight = 3
	cost = 8
	minimum_players = 15
	repeatable = FALSE // also please no

/datum/dynamic_ruleset/midround/ghost/morph/ready(forced = FALSE)
	if(!..())
		return FALSE
	if(!length(GLOB.xeno_spawn))
		log_game("DYNAMIC: [ruletype] ruleset [name] ready() failed due to no valid spawn locations.")
		return FALSE
	return TRUE

/datum/dynamic_ruleset/midround/ghost/morph/generate_ruleset_body(mob/applicant)
	var/datum/mind/player_mind = new /datum/mind(applicant.key)
	player_mind.active = TRUE

	var/mob/living/simple_animal/hostile/morph/S = new /mob/living/simple_animal/hostile/morph(pick(GLOB.xeno_spawn))
	player_mind.transfer_to(S)
	to_chat(S, S.playstyle_string)
	SEND_SOUND(S, sound('sound/magic/mutate.ogg'))

	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Morph by the midround ruleset.")
	log_game("DYNAMIC: [key_name(S)] was spawned as a Morph by the midround ruleset.")
	return S


//////////////////////////////////////////////
//                                          //
//           PRISONER  (GHOST)            	//
//                                          //
//////////////////////////////////////////////
/datum/dynamic_ruleset/midround/ghost/prisoners
	name = "Prisoners"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_LIGHT
	role_preference = /datum/role_preference/midround_ghost/prisoner
	mob_type = /mob/dead/observer
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY)
	required_enemies = list(3,1,1,0,0,0,0,0,0,0)
	required_candidates = 1
	weight = 2
	cost = 6
	minimum_players = 20
	repeatable = FALSE
	var/list/spawn_locs

/datum/dynamic_ruleset/midround/ghost/prisoners/acceptable(population=0, threat=0)
	if (!SSmapping.empty_space)
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/ghost/prisoners/ready(forced = FALSE)
	if(!..())
		return FALSE
	spawn_locs = list()
	for(var/obj/effect/landmark/prisonspawn/L in GLOB.landmarks_list)
		if(isturf(L.loc))
			spawn_locs += L.loc
	if(!length(spawn_locs))
		log_game("DYNAMIC: [ruletype] ruleset [name] ready() failed due to no valid spawn locations.")
		return FALSE
	return TRUE

/datum/dynamic_ruleset/midround/ghost/prisoners/review_applications()
	var/turf/landing_turf = pick(spawn_locs)
	var/result = spawn_prisoners(landing_turf, candidates, list())
	if(result == NOT_ENOUGH_PLAYERS)
		message_admins("Not enough players volunteered for the ruleset [name] - [candidates.len] out of [required_candidates].")
		log_game("DYNAMIC: Not enough players volunteered for the ruleset [name] - [candidates.len] out of [required_candidates].")
		return FALSE
	return TRUE

//////////////////////////////////////////////
//                                          //
//           FUGITIVES  (GHOST)             //
//                                          //
//////////////////////////////////////////////
/datum/dynamic_ruleset/midround/ghost/fugitives
	name = "Fugitives"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_LIGHT
	role_preference = /datum/role_preference/midround_ghost/fugitive
	mob_type = /mob/dead/observer
	required_candidates = 1
	weight = 3
	cost = 7
	minimum_players = 20
	minimum_round_time = 30 MINUTES
	blocking_rules = list(/datum/dynamic_ruleset/roundstart/nuclear)
	repeatable = FALSE
	var/list/spawn_locs

/datum/dynamic_ruleset/midround/ghost/fugitives/acceptable(population=0, threat=0)
	if (!SSmapping.empty_space)
		return FALSE
	// if either exists already ABORT!!!
	for(var/datum/team/fugitive/F in GLOB.antagonist_teams)
		return FALSE
	for(var/datum/team/fugitive_hunters/F in GLOB.antagonist_teams)
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/ghost/fugitives/ready(forced = FALSE)
	if(!..())
		return FALSE
	spawn_locs = list()
	for(var/turf/X in GLOB.xeno_spawn)
		if(istype(X.loc, /area/maintenance))
			spawn_locs += X
	if(!length(spawn_locs))
		log_game("DYNAMIC: [ruletype] ruleset [name] ready() failed due to no valid spawn locations.")
		return FALSE
	return TRUE

/datum/dynamic_ruleset/midround/ghost/fugitives/review_applications()
	var/turf/landing_turf = pick(spawn_locs)
	var/result = spawn_fugitives(landing_turf, candidates, list())
	if(result == NOT_ENOUGH_PLAYERS)
		message_admins("Not enough players volunteered for the ruleset [name] - [candidates.len] out of [required_candidates].")
		log_game("DYNAMIC: Not enough players volunteered for the ruleset [name] - [candidates.len] out of [required_candidates].")
		return FALSE
	return TRUE

//////////////////////////////////////////////
//                                          //
//           NINJA      (GHOST)             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/ninja
	name = "Space Ninja"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	role_preference = /datum/role_preference/midround_ghost/ninja
	mob_type = /mob/dead/observer
	antag_datum = /datum/antagonist/ninja
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_enemies = list(2,2,2,2,2,2,2,2,2,2)
	required_candidates = 1
	weight = 3
	cost = 9
	minimum_players = 20
	repeatable = TRUE
	blocking_rules = list(/datum/dynamic_ruleset/roundstart/nuclear, /datum/dynamic_ruleset/roundstart/clockcult)
	var/spawn_loc

/datum/dynamic_ruleset/midround/ghost/ninja/ready(forced)
	if (!..())
		return FALSE
	//selecting a spawn_loc
	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/carpspawn/L in GLOB.landmarks_list)
		if(isturf(L.loc))
			spawn_locs += L.loc
	if(!length(spawn_locs))
		log_game("DYNAMIC: [ruletype] ruleset [name] ready() failed due to no valid spawn locations (#1).")
		return FALSE
	spawn_loc = pick(spawn_locs)
	return TRUE

/datum/dynamic_ruleset/midround/ghost/ninja/generate_ruleset_body(mob/applicant)
	//spawn the ninja and assign the candidate
	var/mob/living/carbon/human/Ninja = create_space_ninja(spawn_loc)

	//Prepare ninja player mind
	// Dynamic's finish_setup proc will handle application of antagonist datums
	var/datum/mind/Mind = new /datum/mind(applicant.key)
	Mind.active = TRUE
	Mind.transfer_to(Ninja)

	message_admins("[ADMIN_LOOKUPFLW(Ninja)] has been made into a ninja by the midround ruleset")
	log_game("[key_name(Ninja)] was spawned as a ninja by the midround ruleset.")

	return Ninja

/datum/dynamic_ruleset/midround/ghost/ninja/finish_setup(mob/new_character, index)
	. = ..()
	// Set their job in addition to their antag role to be a space ninja for logging purposes
	new_character.mind.assigned_role = ROLE_NINJA
*/
