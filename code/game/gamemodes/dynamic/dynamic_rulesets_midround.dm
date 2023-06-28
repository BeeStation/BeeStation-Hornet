//////////////////////////////////////////////
//                                          //
//            MIDROUND RULESETS             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround // Can be drafted once in a while during a round
	ruletype = "Midround"
	var/midround_ruleset_style
	/// If the ruleset should be restricted from ghost roles.
	var/restrict_ghost_roles = TRUE
	/// What mob type the ruleset is restricted to.
	var/required_type = /mob/living/carbon/human
	var/list/living_players = list()
	var/list/living_antags = list()
	var/list/dead_players = list()
	var/list/list_observers = list()

	/// The minimum round time before this ruleset will show up
	var/minimum_round_time = 0

/datum/dynamic_ruleset/midround/from_ghosts
	weight = 0
	required_type = /mob/dead/observer
	/// Whether the ruleset should call generate_ruleset_body or not.
	var/makeBody = TRUE
	/// The rule needs this many applicants to be properly executed.
	var/required_applicants = 1

/datum/dynamic_ruleset/midround/from_ghosts/trim_candidates()
	..()
	candidates = dead_players | list_observers

/datum/dynamic_ruleset/midround/trim_candidates()
	living_players = trim_list(mode.current_players[CURRENT_LIVING_PLAYERS])
	living_antags = trim_list(mode.current_players[CURRENT_LIVING_ANTAGS])
	dead_players = trim_list(mode.current_players[CURRENT_DEAD_PLAYERS])
	list_observers = trim_list(mode.current_players[CURRENT_OBSERVERS])

/datum/dynamic_ruleset/midround/proc/trim_list(list/L = list())
	var/list/trimmed_list = L.Copy()
	for(var/mob/M in trimmed_list)
		if (!istype(M, required_type))
			trimmed_list.Remove(M)
			continue
		if (!M.client) // Are they connected?
			trimmed_list.Remove(M)
			continue
		if(!mode.check_age(M.client, minimum_required_age))
			trimmed_list.Remove(M)
			continue
		if(antag_flag_override)
			if(!(antag_flag_override in M.client.prefs.be_special) || is_banned_from(M.ckey, list(antag_flag_override, ROLE_SYNDICATE)))
				trimmed_list.Remove(M)
				continue
		else
			if(!(antag_flag in M.client.prefs.be_special) || is_banned_from(M.ckey, list(antag_flag, ROLE_SYNDICATE)))
				trimmed_list.Remove(M)
				continue
		if (M.mind)
			if (restrict_ghost_roles && (M.mind.assigned_role in GLOB.exp_specialmap[EXP_TYPE_SPECIAL])) // Are they playing a ghost role?
				trimmed_list.Remove(M)
				continue
			if (M.mind.assigned_role in restricted_roles) // Does their job allow it?
				trimmed_list.Remove(M)
				continue
			if ((length(exclusive_roles) > 0) && !(M.mind.assigned_role in exclusive_roles)) // Is the rule exclusive to their job?
				trimmed_list.Remove(M)
				continue
	return trimmed_list

// You can then for example prompt dead players in execute() to join as strike teams or whatever
// Or autotator someone

// IMPORTANT, since /datum/dynamic_ruleset/midround may accept candidates from both living, dead, and even antag players, you must alter check_candidates to check accordingly
/datum/dynamic_ruleset/midround/ready(forced = FALSE)
	if (forced)
		return TRUE

	if (!..()) // calls check_candidates()
		return FALSE

	var/job_check = 0
	if (length(enemy_roles))
		for (var/mob/M in mode.current_players[CURRENT_LIVING_PLAYERS])
			if (M.stat == DEAD || !M.client)
				continue // Dead/disconnected players cannot count as opponents
			if (M.mind && (M.mind.assigned_role in enemy_roles) && (!(M in candidates) || (M.mind.assigned_role in restricted_roles)))
				job_check++ // Checking for "enemies" (such as sec officers). To be counters, they must either not be candidates to that rule, or have a job that restricts them from it

	var/threat = round(mode.threat_level/10)

	if (job_check < required_enemies[threat])
		log_game("DYNAMIC: FAIL: [src] is not ready, because there are not enough enemies: [required_enemies[threat]] needed, [job_check] found")
		return FALSE

	if (mode.check_lowpop_lowimpact_injection())
		return FALSE

	return TRUE

/datum/dynamic_ruleset/midround/from_ghosts/execute(forced = FALSE)
	var/list/possible_candidates = list()
	possible_candidates.Add(dead_players)
	possible_candidates.Add(list_observers)
	send_applications(possible_candidates, forced)
	return length(assigned) ? DYNAMIC_EXECUTE_SUCCESS : DYNAMIC_EXECUTE_NOT_ENOUGH_PLAYERS

/// This sends a poll to ghosts if they want to be a ghost spawn from a ruleset.
/datum/dynamic_ruleset/midround/from_ghosts/proc/send_applications(list/possible_volunteers = list(), forced = FALSE)
	if (!length(possible_volunteers)) // This shouldn't happen, as ready() should return FALSE if there is not a single valid candidate
		if(!forced)
			message_admins("Possible volunteers was 0. This shouldn't appear, because of ready()!")
			log_game("DYNAMIC: Possible volunteers was 0. This shouldn't appear, because of ready()!")
			CRASH("The ruleset [name] execute()d with no candidates. This should have been caught by ready(), so something is wrong.")
		else
			message_admins("The dynamic ruleset could not be forced, as there are no potential candidates (0 dead players/observers)")
		return
	message_admins("Polling [possible_volunteers.len] players to apply for the [name] ruleset.")
	log_game("DYNAMIC: Polling [possible_volunteers.len] players to apply for the [name] ruleset.")

	candidates = pollGhostCandidates("The mode is looking for volunteers to become [antag_flag] for [name]", antag_flag, SSticker.mode, antag_flag_override ? antag_flag_override : antag_flag, poll_time = 300)

	if(!length(candidates))
		message_admins("The ruleset [name] received no applications.")
		log_game("DYNAMIC: The ruleset [name] received no applications.")
		return

	message_admins("[candidates.len] players volunteered for the ruleset [name].")
	log_game("DYNAMIC: [candidates.len] players volunteered for [name].")
	review_applications()

/// Here is where you can check if your ghost applicants are valid for the ruleset.
/// Called by send_applications().
/datum/dynamic_ruleset/midround/from_ghosts/proc/review_applications()
	if(length(candidates) < required_applicants)
		message_admins("Not enough players volunteered for the ruleset [name] - [candidates.len] out of [required_applicants].")
		log_game("DYNAMIC: Not enough players volunteered for the ruleset [name] - [candidates.len] out of [required_applicants].")
		return
	for (var/i = 1, i <= required_candidates, i++)
		if(!length(candidates))
			break
		var/mob/applicant = pick(candidates)
		candidates -= applicant
		if(!isobserver(applicant))
			if(applicant.stat == DEAD) // Not an observer? If they're dead, make them one.
				applicant = applicant.ghostize(FALSE,SENTIENCE_ERASE)
			else // Not dead? Disregard them, pick a new applicant
				i--
				continue

		if(!applicant)
			i--
			continue

		var/mob/new_character = applicant

		if (makeBody)
			new_character = generate_ruleset_body(applicant)

		finish_setup(new_character, i)
		assigned += applicant
		notify_ghosts("[applicant.name] has been picked for the ruleset [name]!", source = new_character, action = NOTIFY_ORBIT, header="Something Interesting!")
	// No one got the role
	if(!length(assigned))
		message_admins("No players were eligible for the ruleset [name] - the previous applicants were revived/left and could no longer take the role.")
		log_game("DYNAMIC: No players were eligible for the ruleset [name] - the previous applicants were revived/left and could no longer take the role.")

/datum/dynamic_ruleset/midround/from_ghosts/proc/generate_ruleset_body(mob/applicant)
	var/mob/living/carbon/human/new_character = makeBody(applicant)
	new_character.dna.remove_all_mutations()
	return new_character

/datum/dynamic_ruleset/midround/from_ghosts/proc/finish_setup(mob/new_character, index)
	var/datum/antagonist/new_role = new antag_datum()
	setup_role(new_role)
	new_character.mind.add_antag_datum(new_role)
	new_character.mind.special_role = antag_flag

/datum/dynamic_ruleset/midround/from_ghosts/proc/setup_role(datum/antagonist/new_role)
	return

//////////////////////////////////////////////
//                                          //
//           SYNDICATE TRAITORS             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/autotraitor
	name = "Syndicate Sleeper Agent"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_LIGHT
	antag_datum = /datum/antagonist/traitor
	antag_flag = ROLE_TRAITOR
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
		/datum/dynamic_ruleset/roundstart/hivemind
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
//         Malfunctioning AI                //
//                              		    //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/malf
	name = "Malfunctioning AI"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	antag_datum = /datum/antagonist/traitor
	antag_flag = ROLE_MALF
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_SCIENTIST, JOB_NAME_CHEMIST, JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_CHIEFENGINEER)
	exclusive_roles = list(JOB_NAME_AI)
	required_enemies = list(3,3,2,2,2,1,1,1,1,0)
	required_candidates = 1
	minimum_players = 0 // Handled by /datum/dynamic_ruleset/proc/acceptable override
	weight = 2
	cost = 13
	required_type = /mob/living/silicon/ai
	blocking_rules = list(/datum/dynamic_ruleset/roundstart/nuclear)
	flags = HIGH_IMPACT_RULESET|INTACT_STATION_RULESET|PERSISTENT_RULESET
	var/ion_announce = 33
	var/removeDontImproveChance = 10

/datum/dynamic_ruleset/midround/malf/acceptable(population = 0, threat_level = 0)
	. = ..()
	if(population < CONFIG_GET(number/malf_ai_minimum_pop))
		return FALSE

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
	var/mob/living/silicon/ai/M = antag_pick_n_take(candidates)
	assigned += M.mind
	var/datum/antagonist/traitor/AI = new
	M.mind.special_role = antag_flag
	M.mind.add_antag_datum(AI)
	if(prob(ion_announce))
		priority_announce("Ion storm detected near the station. Please check all AI-controlled equipment for errors.", "Anomaly Alert", ANNOUNCER_IONSTORM)
		if(prob(removeDontImproveChance))
			M.replace_random_law(generate_ion_law(), list(LAW_INHERENT, LAW_SUPPLIED, LAW_ION))
		else
			M.add_ion_law(generate_ion_law())
	return DYNAMIC_EXECUTE_SUCCESS

//////////////////////////////////////////////
//                                          //
//              WIZARD (GHOST)              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/wizard
	name = "Wizard"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	antag_datum = /datum/antagonist/wizard
	antag_flag = ROLE_WIZARD
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_RESEARCHDIRECTOR) //RD doesn't believe in magic
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 1
	cost = 15
	requirements = REQUIREMENTS_VERY_HIGH_THREAT_NEEDED
	flags = HIGH_IMPACT_RULESET|PERSISTENT_RULESET

/datum/dynamic_ruleset/midround/from_ghosts/wizard/ready(forced = FALSE)
	if(!length(GLOB.wizardstart))
		log_game("DYNAMIC: Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/wizard/finish_setup(mob/new_character, index)
	..()
	new_character.forceMove(pick(GLOB.wizardstart))

//////////////////////////////////////////////
//                                          //
//          NUCLEAR OPERATIVES (MIDROUND)   //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/nuclear
	name = "Nuclear Assault"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	antag_flag = ROLE_OPERATIVE
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

/datum/dynamic_ruleset/midround/from_ghosts/nuclear/acceptable(population=0, threat=0)
	if (locate(/datum/dynamic_ruleset/roundstart/nuclear) in mode.executed_rules)
		return FALSE // Unavailable if nuke ops were already sent at roundstart
	indice_pop = min(length(operative_cap), round(length(living_players)/5)+1)
	required_candidates = operative_cap[indice_pop]
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/nuclear/finish_setup(mob/new_character, index)
	new_character.mind.special_role = "Nuclear Operative"
	new_character.mind.assigned_role = "Nuclear Operative"
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

/datum/dynamic_ruleset/midround/from_ghosts/blob
	name = "Blob"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	antag_datum = /datum/antagonist/blob
	antag_flag = ROLE_BLOB
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	minimum_round_time = 35 MINUTES
	weight = 3
	cost = 12
	minimum_players = 25
	flags = HIGH_IMPACT_RULESET|INTACT_STATION_RULESET|PERSISTENT_RULESET

/datum/dynamic_ruleset/midround/from_ghosts/blob/generate_ruleset_body(mob/applicant)
	var/body = applicant.become_overmind()
	return body

//////////////////////////////////////////////
//                                          //
//           XENOMORPH (GHOST)              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph
	name = "Alien Infestation"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	antag_datum = /datum/antagonist/xeno
	antag_flag = ROLE_ALIEN
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_enemies = list(2,2,2,1,1,1,1,0,0,0)
	required_candidates = 1
	minimum_round_time = 40 MINUTES
	weight = 3
	cost = 12
	minimum_players = 25
	flags = HIGH_IMPACT_RULESET|INTACT_STATION_RULESET|PERSISTENT_RULESET
	var/list/vents

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/acceptable(population=0, threat=0)
	// 50% chance of being incremented by one
	required_candidates += prob(50)
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/ready(forced = FALSE)
	if(!..())
		return FALSE
	vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in GLOB.machines)
		if(QDELETED(temp_vent))
			continue
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
			if(!temp_vent_parent)
				continue // No parent vent
			// Stops Aliens getting stuck in small networks.
			// See: Security, Virology
			if(length(temp_vent_parent.other_atmosmch) > 20)
				vents += temp_vent
	if(!length(vents))
		log_game("DYNAMIC: [ruletype] ruleset [name] ready() failed due to no valid spawn locations.")
		return FALSE
	return TRUE

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/generate_ruleset_body(mob/applicant)
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

/datum/dynamic_ruleset/midround/from_ghosts/nightmare
	name = "Nightmare"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_LIGHT
	antag_datum = /datum/antagonist/nightmare
	antag_flag = ROLE_NIGHTMARE
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_enemies = list(1,1,1,1,0,0,0,0,0,0)
	required_candidates = 1
	weight = 5
	cost = 6
	minimum_players = 12
	repeatable = TRUE
	var/list/spawn_locs

/datum/dynamic_ruleset/midround/from_ghosts/nightmare/ready(forced = FALSE)
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

/datum/dynamic_ruleset/midround/from_ghosts/nightmare/generate_ruleset_body(mob/applicant)
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

/datum/dynamic_ruleset/midround/from_ghosts/space_dragon
	name = "Space Dragon"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	antag_datum = /datum/antagonist/space_dragon
	antag_flag = ROLE_SPACE_DRAGON
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_enemies = list(1,1,1,1,0,0,0,0,0,0)
	required_candidates = 1
	weight = 4
	cost = 11
	minimum_players = 25
	repeatable = TRUE
	flags = INTACT_STATION_RULESET|PERSISTENT_RULESET
	var/list/spawn_locs

/datum/dynamic_ruleset/midround/from_ghosts/space_dragon/ready(forced = FALSE)
	if(!..())
		return FALSE
	spawn_locs = list()
	for(var/obj/effect/landmark/carpspawn/spawnpoint in GLOB.landmarks_list)
		spawn_locs += spawnpoint.loc
	if(!length(spawn_locs))
		log_game("DYNAMIC: [ruletype] ruleset [name] ready() failed due to no valid spawn locations.")
		return FALSE
	return TRUE

/datum/dynamic_ruleset/midround/from_ghosts/space_dragon/generate_ruleset_body(mob/applicant)
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
#define ABDUCTOR_MAX_TEAMS 4

/datum/dynamic_ruleset/midround/from_ghosts/abductors
	name = "Abductors"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_LIGHT
	antag_flag = ROLE_ABDUCTOR
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_enemies = list(2,2,1,1,1,1,0,0,0,0)
	required_candidates = 2
	required_applicants = 2
	weight = 4
	cost = 7
	minimum_players = 25
	repeatable = TRUE
	var/datum/team/abductor_team/new_team

/datum/dynamic_ruleset/midround/from_ghosts/abductors/finish_setup(mob/new_character, index)
	if (index == 1) // Our first guy is the scientist.  We also initialize the team here as well since this should only happen once per pair of abductors.
		new_team = new
		if(new_team.team_number > ABDUCTOR_MAX_TEAMS)
			return MAP_ERROR
		var/datum/antagonist/abductor/scientist/new_role = new
		new_character.mind.add_antag_datum(new_role, new_team)
	else // Our second guy is the agent, team is already created, don't need to make another one.
		var/datum/antagonist/abductor/agent/new_role = new
		new_character.mind.add_antag_datum(new_role, new_team)

#undef ABDUCTOR_MAX_TEAMS

//////////////////////////////////////////////
//                                          //
//           REVENANT    (GHOST)            //
//                                          //
//////////////////////////////////////////////
/datum/dynamic_ruleset/midround/from_ghosts/revenant
	name = "Revenant"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_LIGHT
	antag_datum = /datum/antagonist/revenant
	antag_flag = ROLE_REVENANT
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

/datum/dynamic_ruleset/midround/from_ghosts/revenant/acceptable(population=0, threat=0)
	if(length(GLOB.dead_mob_list) < dead_mobs_required)
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/revenant/ready(forced = FALSE)
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

/datum/dynamic_ruleset/midround/from_ghosts/revenant/generate_ruleset_body(mob/applicant)
	var/mob/living/simple_animal/revenant/revenant = new(pick(spawn_locs))
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
	antag_flag = ROLE_SPACE_PIRATE
	required_type = /mob/dead/observer
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_enemies = list(2,2,2,1,1,1,1,0,0,0)
	required_candidates = 0
	weight = 4
	cost = 8
	minimum_players = 27
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
	antag_flag = ROLE_OBSESSED
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
			|| !(ROLE_OBSESSED in candidate.client?.prefs?.be_special) \
			|| !SSjob.GetJob(candidate.mind.assigned_role) \
			|| (candidate.mind.assigned_role in GLOB.nonhuman_positions) \
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

/datum/dynamic_ruleset/midround/from_ghosts/spiders
	name = "Spider Infestation"
	antag_flag = ROLE_SPIDER
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	required_type = /mob/dead/observer
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 2
	weight = 3
	cost = 11
	repeatable = TRUE
	flags = INTACT_STATION_RULESET|PERSISTENT_RULESET
	minimum_players = 27
	var/fed = 1
	var/list/vents
	var/datum/team/spiders/spider_team

/datum/dynamic_ruleset/midround/from_ghosts/spiders/ready(forced = FALSE)
	if(!..())
		return FALSE
	vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in GLOB.machines)
		if(QDELETED(temp_vent))
			continue
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
			if(!temp_vent_parent)
				continue // No parent vent
			if(length(temp_vent_parent.other_atmosmch) > 20)
				vents += temp_vent // Makes sure the pipeline is large enough
	if(!length(vents))
		log_game("DYNAMIC: [ruletype] ruleset [name] ready() failed due to no valid spawn locations.")
		return FALSE
	return TRUE

/datum/dynamic_ruleset/midround/from_ghosts/spiders/generate_ruleset_body(mob/applicant)
	var/obj/vent = pick_n_take(vents)
	var/mob/living/simple_animal/hostile/poison/giant_spider/broodmother/spider = new(vent.loc)
	spider.key = applicant.key
	if(fed)
		spider.fed += 3
		spider.lay_eggs.UpdateButtonIcon()
		fed--
	message_admins("[ADMIN_LOOKUPFLW(spider)] has been made into a spider by the midround ruleset.")
	log_game("DYNAMIC: [key_name(spider)] was spawned as a spider by the midround ruleset.")
	return spider

/datum/dynamic_ruleset/midround/from_ghosts/spiders/finish_setup(mob/new_character, index)
	if(!spider_team)
		spider_team = new()
		spider_team.directive ="Ensure the survival of your brood and overtake whatever structure you find yourself in."
	var/datum/antagonist/spider/spider_antag = new_character.mind.has_antag_datum(/datum/antagonist/spider)
	spider_antag.set_spider_team(spider_team)
	new_character.mind.special_role = antag_flag

//////////////////////////////////////////////
//                                          //
//             SWARMER (GHOST)              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/swarmer
	name = "Swarmer"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	antag_datum = /datum/antagonist/swarmer
	antag_flag = ROLE_SWARMER
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_enemies = list(1,1,1,1,0,0,0,0,0,0)
	required_candidates = 1
	weight = 3
	cost = 10
	minimum_players = 15
	repeatable = FALSE // please no
	flags = INTACT_STATION_RULESET|PERSISTENT_RULESET
	var/announce_chance = 25

/datum/dynamic_ruleset/midround/from_ghosts/swarmer/ready(forced = FALSE)
	if(!..())
		return FALSE
	if(!GLOB.the_gateway)
		log_game("DYNAMIC: [ruletype] ruleset [name] execute failed due to no valid spawn locations (no gateway on map).")
		return FALSE
	return TRUE

/datum/dynamic_ruleset/midround/from_ghosts/swarmer/generate_ruleset_body(mob/applicant)
	var/datum/mind/player_mind = new /datum/mind(applicant.key)
	player_mind.active = TRUE

	var/mob/living/simple_animal/hostile/swarmer/S = new (get_turf(GLOB.the_gateway))
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

/datum/dynamic_ruleset/midround/from_ghosts/morph
	name = "Morph"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	antag_datum = /datum/antagonist/morph
	antag_flag = ROLE_MORPH
	enemy_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_enemies = list(2,2,1,1,1,1,1,1,0,0)
	required_candidates = 1
	weight = 3
	cost = 8
	minimum_players = 15
	repeatable = FALSE // also please no

/datum/dynamic_ruleset/midround/from_ghosts/morph/ready(forced = FALSE)
	if(!..())
		return FALSE
	if(!length(GLOB.xeno_spawn))
		log_game("DYNAMIC: [ruletype] ruleset [name] ready() failed due to no valid spawn locations.")
		return FALSE
	return TRUE

/datum/dynamic_ruleset/midround/from_ghosts/morph/generate_ruleset_body(mob/applicant)
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
//           FUGITIVES  (GHOST)             //
//                                          //
//////////////////////////////////////////////
/datum/dynamic_ruleset/midround/from_ghosts/fugitives
	name = "Fugitives"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_LIGHT
	antag_flag = ROLE_FUGITIVE
	required_type = /mob/dead/observer
	required_candidates = 1
	weight = 3
	cost = 7
	minimum_players = 20
	minimum_round_time = 30 MINUTES
	blocking_rules = list(/datum/dynamic_ruleset/roundstart/nuclear)
	repeatable = FALSE
	var/list/spawn_locs

/datum/dynamic_ruleset/midround/from_ghosts/fugitives/acceptable(population=0, threat=0)
	if (!SSmapping.empty_space)
		return FALSE
	// if either exists already ABORT!!!
	for(var/datum/team/fugitive/F in GLOB.antagonist_teams)
		return FALSE
	for(var/datum/team/fugitive_hunters/F in GLOB.antagonist_teams)
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/fugitives/ready(forced = FALSE)
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

/datum/dynamic_ruleset/midround/from_ghosts/fugitives/review_applications()
	var/turf/landing_turf = pick(spawn_locs)
	var/result = spawn_fugitives(landing_turf, candidates, list())
	if(result == NOT_ENOUGH_PLAYERS)
		message_admins("Not enough players volunteered for the ruleset [name] - [candidates.len] out of [required_candidates].")
		log_game("DYNAMIC: Not enough players volunteered for the ruleset [name] - [candidates.len] out of [required_candidates].")
		return FALSE
	return TRUE
