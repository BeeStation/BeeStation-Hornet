/**
 * A general rule of thumb:
 *
 * 30 points for antagonists that are mostly harmless and will mess with a crew a bit
 * 40 points for antagonists that will actively attack the crew
 * 50 points for antagonists that that may very well end the round
 */

/datum/dynamic_ruleset/midround/ghost
	abstract_type = /datum/dynamic_ruleset/midround/ghost
	ruleset_flags = CANNOT_REPEAT | NO_TRANSFER_RULESET | REQUIRED_POP_ALLOW_UNREADY

	/// List of possible locations for this antag to spawn
	var/list/spawn_locations = list()
	/// Whether or not this ruleset should be blocked if there aren't any spawn locations
	var/use_spawn_locations = TRUE

	/// The poll that we are gathering candidates from
	var/datum/candidate_poll/persistent/poll = null

/datum/dynamic_ruleset/midround/ghost/get_candidates()
	candidates = SSdynamic.current_players[CURRENT_DEAD_PLAYERS] | SSdynamic.current_players[CURRENT_OBSERVERS]

/datum/dynamic_ruleset/midround/ghost/allowed(require_drafted = TRUE)
	// With ghost midrounds, we do not care about drafted player counts
	// as the players may come later
	. = ..()
	if(!.)
		return FALSE

	if(use_spawn_locations)
		get_spawn_locations()
		if(!length(spawn_locations))
			log_dynamic("NOT ALLOWED: [src] could not trigger due to a lack of valid spawning locations.")
			return FALSE

/datum/dynamic_ruleset/midround/ghost/select_player()
	var/mob/candidate = CHECK_BITFIELD(ruleset_flags, SHOULD_USE_ANTAG_REP) ? SSdynamic.antag_pick(candidates, role_preference) : pick(candidates)
	candidates -= candidate

	if(!isobserver(candidate))
		if(candidate.stat == DEAD)
			// Probably just entered their body after signing up for the midround, lets turn them into a ghost
			candidate = candidate.ghostize(FALSE, SENTIENCE_ERASE)
		else
			// Got revived, lets get a new candidate
			return select_player()

	return candidate

/datum/dynamic_ruleset/midround/ghost/execute()
	// Get our candidates
	set_drafted_players_amount()
	get_candidates()
	trim_candidates()

	// Don't even send applications out if we don't have enough candidates
	if(!allowed())
		make_persistent(FALSE)
		return DYNAMIC_EXECUTE_WAITING

	send_applications()
	trim_candidates()

	if(!allowed())
		make_persistent(TRUE)
		return DYNAMIC_EXECUTE_WAITING

	// Pick our candidates
	for(var/i = 1 to drafted_players_amount)
		LAZYADD(chosen_candidates, select_player())

	// Generate our candidates' bodies
	for(var/mob/dead/observer/chosen_candidate in chosen_candidates)
		var/mob/new_character = generate_ruleset_body(chosen_candidate)
		finish_setup(new_character)

		notify_ghosts("[chosen_candidate] has been picked for the [src] ruleset!", source = new_character, action = NOTIFY_ORBIT, header = "Something Interesting!")

	return DYNAMIC_EXECUTE_SUCCESS

/datum/dynamic_ruleset/midround/ghost/abort()
	. = ..()
	if (poll)
		poll.end_poll()
		poll = null
	// We did not get a chance to execute, don't report it in the round-end
	SSdynamic.midround_executed_rulesets -= src

/datum/dynamic_ruleset/midround/ghost/proc/make_persistent(silent)
	var/datum/poll_config/config = new()
	config.role_name_text = initial(antag_datum.name)
	config.alert_pic = get_poll_icon()
	config.check_candidate = CALLBACK(src, PROC_REF(is_allowed))
	config.silent = silent
	config.include_in_spawners = TRUE
	config.requires_confirmation = TRUE
	config.can_hide = TRUE
	var/datum/candidate_poll/persistent/poll = SSpolling.poll_ghost_candidates_persistently(config)
	poll.on_signup = CALLBACK(src, PROC_REF(check_ready))
	src.poll = poll

/datum/dynamic_ruleset/midround/ghost/proc/is_allowed(mob/candidate)
#ifndef TESTING_DYNAMIC
	if(!candidate.client.should_include_for_role(
		banning_key = antag_datum.banning_key,
		role_preference_key = role_preference,
		req_hours = antag_datum.required_living_playtime
	))
		return FALSE
#endif
	return TRUE

/datum/dynamic_ruleset/midround/ghost/proc/check_ready(datum/candidate_poll/persistent/source, list/candidates)
	src.candidates = candidates.Copy()
	trim_candidates()

	if(!allowed())
		return

	poll = null
	source.end_poll()

	// Pick our candidates
	for(var/i = 1 to drafted_players_amount)
		LAZYADD(chosen_candidates, select_player())

	// Generate our candidates' bodies
	for(var/mob/dead/observer/chosen_candidate in chosen_candidates)
		var/mob/new_character = generate_ruleset_body(chosen_candidate)
		finish_setup(new_character)

		notify_ghosts("[chosen_candidate] has been picked for the [src] ruleset!", source = new_character, action = NOTIFY_ORBIT, header = "Something Interesting!")


/**
 * Get a list of all possible spawn points
 */
/datum/dynamic_ruleset/midround/ghost/proc/get_spawn_locations()
	for(var/obj/effect/landmark/carpspawn/spawnpoint in GLOB.landmarks_list)
		if(isturf(spawnpoint.loc))
			spawn_locations += spawnpoint.loc

/**
 * Send a poll to ghosts to see if they wanna sign up for a ruleset
 */
/datum/dynamic_ruleset/midround/ghost/proc/send_applications()
	// How?
	if(!length(candidates))
		return

	message_admins("DYNAMIC: Polling [length(candidates)] player\s to apply for the [src] ruleset.")
	log_dynamic("MIDROUND: Polling [length(candidates)] player\s to apply for the [src] ruleset.")

	var/datum/poll_config/config = new()
	config.role_name_text = initial(antag_datum.name)
	config.alert_pic = get_poll_icon()
	candidates = SSpolling.poll_ghost_candidates(config)

	if(length(candidates) >= drafted_players_amount)
		message_admins("DYNAMIC: [length(candidates)] player\s volunteered for the ruleset [src].")
		log_dynamic("[length(candidates)] player\s volunteered for the ruleset [src].")

/**
 * Spawn a body for the chosen candidate
 */
/datum/dynamic_ruleset/midround/ghost/proc/generate_ruleset_body(mob/dead/observer/chosen_mob)
	var/mob/living/carbon/human/new_body = makeBody(chosen_mob)
	new_body.clean_dna()
	return new_body

/**
 * Finalize the candidate's body
 */
/datum/dynamic_ruleset/midround/ghost/proc/finish_setup(mob/new_character)
	new_character.mind.add_antag_datum(antag_datum, ruleset = src)
	new_character.mind.special_role = antag_datum.banning_key

//////////////////////////////////////////////
//                                          //
//              WIZARD (HEAVY)              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/wizard
	name = "Wizard"
	severity = DYNAMIC_MIDROUND_HEAVY
	antag_datum = /datum/antagonist/wizard
	points_cost = 50
	weight = 4

/datum/dynamic_ruleset/midround/ghost/wizard/get_poll_icon()
	return /obj/item/clothing/head/wizard

/datum/dynamic_ruleset/midround/ghost/wizard/get_spawn_locations()
	spawn_locations = GLOB.wizardstart
	for(var/obj/effect/landmark/start/wizard/spawnpoint in GLOB.wizardstart)
		if(isturf(spawnpoint.loc))
			spawn_locations += spawnpoint.loc

/datum/dynamic_ruleset/midround/ghost/wizard/finish_setup(mob/new_character)
	. = ..()
	new_character.forceMove(pick(spawn_locations))

//////////////////////////////////////////////
//                                          //
//         NUCLEAR ASSAULT (HEAVY)          //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/nuclear_assault
	name = "Nuclear Assault"
	severity = DYNAMIC_MIDROUND_HEAVY
	antag_datum = /datum/antagonist/nukeop
	drafted_players_amount = 3
	points_cost = 50
	minimum_players_required = 20
	weight = 4
	use_spawn_locations = FALSE

	var/datum/team/nuclear/team
	var/has_made_leader = FALSE

/datum/dynamic_ruleset/midround/ghost/nuclear_assault/get_poll_icon()
	return /obj/machinery/nuclearbomb

/datum/dynamic_ruleset/midround/ghost/nuclear_assault/finish_setup(mob/new_character)
	new_character.mind.special_role = ROLE_OPERATIVE
	new_character.mind.assigned_role = ROLE_OPERATIVE

	if(has_made_leader)
		return ..()

	has_made_leader = TRUE

	var/datum/antagonist/nukeop/leader/leader_datum = new
	team = leader_datum.nuke_team
	new_character.mind.add_antag_datum(leader_datum, ruleset = src)

//////////////////////////////////////////////
//                                          //
//               BLOB (HEAVY)               //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/blob
	name = "Blob"
	severity = DYNAMIC_MIDROUND_HEAVY
	antag_datum = /datum/antagonist/blob
	points_cost = 50
	minimum_players_required = 13
	weight = 4
	use_spawn_locations = FALSE

/datum/dynamic_ruleset/midround/ghost/blob/get_poll_icon()
	var/icon/blob_icon = icon('icons/mob/blob.dmi', icon_state = "blob_core")
	blob_icon.Blend("#9ACD32", ICON_MULTIPLY)
	blob_icon.Blend(icon('icons/mob/blob.dmi', "blob_core_overlay"), ICON_OVERLAY)
	return blob_icon

/datum/dynamic_ruleset/midround/ghost/blob/generate_ruleset_body(mob/dead/observer/chosen_ghost)
	var/mob/camera/blob/body = chosen_ghost.become_overmind()
	return body

//////////////////////////////////////////////
//                                          //
//      XENOMORPH INFESTATION (HEAVY)       //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/xenomorph_infestation
	name = "Xenomorph Infestation"
	severity = DYNAMIC_MIDROUND_HEAVY
	antag_datum = /datum/antagonist/xeno
	points_cost = 50
	minimum_players_required = 20
	weight = 4

/datum/dynamic_ruleset/midround/ghost/xenomorph_infestation/get_poll_icon()
	return /mob/living/carbon/alien/larva

/datum/dynamic_ruleset/midround/ghost/xenomorph_infestation/generate_ruleset_body(mob/dead/observer/chosen_mob)
	var/obj/vent = pick_n_take(spawn_locations)

	var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
	new_xeno.forceMove(vent)
	new_xeno.key = chosen_mob.key

	return new_xeno

/datum/dynamic_ruleset/midround/ghost/xenomorph_infestation/get_spawn_locations()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent in GLOB.machines)
		if(QDELETED(vent))
			continue

		if(is_station_level(vent.loc.z) && !vent.welded)
			var/datum/pipenet/vent_parent = vent.parents[1]

			// Nothing is connected to the vent
			if(!vent_parent)
				continue
			// Stop xenos from getting stuck in small networks
			if(length(vent_parent.other_atmos_machines) < 20)
				continue

			spawn_locations += vent

//////////////////////////////////////////////
//                                          //
//           SPACE DRAGON (HEAVY)           //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/space_dragon
	name = "Space Dragon"
	severity = DYNAMIC_MIDROUND_HEAVY
	antag_datum = /datum/antagonist/space_dragon
	points_cost = 40
	weight = 4
	minimum_players_required = 10

/datum/dynamic_ruleset/midround/ghost/space_dragon/get_poll_icon()
	return /mob/living/simple_animal/hostile/space_dragon

/datum/dynamic_ruleset/midround/ghost/space_dragon/generate_ruleset_body(mob/dead/observer/chosen_mob)
	var/datum/mind/player_mind = new /datum/mind(chosen_mob.key)
	player_mind.active = TRUE

	var/mob/living/simple_animal/hostile/space_dragon/dragon_body = new(pick(spawn_locations))
	player_mind.transfer_to(dragon_body)

	playsound(dragon_body, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
	priority_announce("It appears a lifeform with magical traces is approaching [station_name()], please stand-by.", "Lifesign Alert")

	return dragon_body

//////////////////////////////////////////////
//                                          //
//              NINJA (MEDIUM)              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/ninja
	name = "Space Ninja"
	severity = DYNAMIC_MIDROUND_MEDIUM | DYNAMIC_MIDROUND_HEAVY
	antag_datum = /datum/antagonist/ninja
	points_cost = 40
	weight = 4

/datum/dynamic_ruleset/midround/ghost/ninja/get_poll_icon()
	return /obj/item/energy_katana

/datum/dynamic_ruleset/midround/ghost/ninja/generate_ruleset_body(mob/dead/observer/chosen_mob)
	var/datum/mind/player_mind = new /datum/mind(chosen_mob.key)
	player_mind.active = TRUE

	var/mob/living/carbon/human/ninja_body = new(pick(spawn_locations))
	ninja_body.real_name = "[pick(GLOB.ninja_titles)] [pick(GLOB.ninja_names)]"
	ninja_body.name = "[pick(GLOB.ninja_titles)] [pick(GLOB.ninja_names)]"
	ninja_body.dna.update_dna_identity()
	player_mind.transfer_to(ninja_body)

	return ninja_body

//////////////////////////////////////////////
//                                          //
//            NIGHTMARE (MEDIUM)            //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/nightmare
	name = "Nightmare"
	severity = DYNAMIC_MIDROUND_LIGHT | DYNAMIC_MIDROUND_MEDIUM
	antag_datum = /datum/antagonist/nightmare
	points_cost = 40
	weight = 4

/datum/dynamic_ruleset/midround/ghost/nightmare/get_poll_icon()
	return /obj/item/light_eater

/datum/dynamic_ruleset/midround/ghost/nightmare/get_spawn_locations()
	for(var/turf/potential_spawn in GLOB.xeno_spawn)
		if(potential_spawn.get_lumcount() < SHADOW_SPECIES_LIGHT_THRESHOLD)
			spawn_locations += potential_spawn

/datum/dynamic_ruleset/midround/ghost/nightmare/generate_ruleset_body(mob/dead/observer/chosen_mob)
	var/datum/mind/player_mind = new /datum/mind(chosen_mob.key)
	player_mind.active = TRUE

	var/mob/living/carbon/human/nightmare_body = new(pick(spawn_locations))
	nightmare_body.set_species(/datum/species/shadow/nightmare)
	player_mind.transfer_to(nightmare_body)

	playsound(nightmare_body, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)

	return nightmare_body

//////////////////////////////////////////////
//                                          //
//            ABDUCTORS (MEDIUM)            //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/abductors
	name = "Abductors"
	severity = DYNAMIC_MIDROUND_MEDIUM
	antag_datum = /datum/antagonist/abductor/agent
	drafted_players_amount = 2
	points_cost = 30
	weight = 4
	use_spawn_locations = FALSE

	var/has_made_leader = FALSE
	var/datum/team/abductor_team/team

/datum/dynamic_ruleset/midround/ghost/abductors/get_poll_icon()
	return /obj/item/melee/baton/abductor

/datum/dynamic_ruleset/midround/ghost/abductors/finish_setup(mob/new_character)
	new_character.mind.special_role = ROLE_ABDUCTOR
	new_character.mind.assigned_role = ROLE_ABDUCTOR

	if(!has_made_leader)
		has_made_leader = TRUE
		team = new

		new_character.mind.add_antag_datum(/datum/antagonist/abductor/scientist, team, ruleset = src)
	else
		new_character.mind.add_antag_datum(antag_datum, team, ruleset = src)

//////////////////////////////////////////////
//                                          //
//          LONE ABDUCTOR (MEDIUM)          //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/lone_abductor
	name = "Lone Abductor"
	severity = DYNAMIC_MIDROUND_MEDIUM
	antag_datum = /datum/antagonist/abductor/scientist/solo
	points_cost = 30
	weight = 4
	use_spawn_locations = FALSE

	var/datum/team/abductor_team/team

/datum/dynamic_ruleset/midround/ghost/lone_abductor/get_poll_icon()
	return /obj/item/melee/baton/abductor

/datum/dynamic_ruleset/midround/ghost/lone_abductor/finish_setup(mob/new_character)
	new_character.mind.special_role = ROLE_ABDUCTOR
	new_character.mind.assigned_role = ROLE_ABDUCTOR

	team = new
	new_character.mind.add_antag_datum(antag_datum, team, ruleset = src)

//////////////////////////////////////////////
//                                          //
//            REVENANT (MEDIUM)             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/revenant
	name = "Revenant"
	severity = DYNAMIC_MIDROUND_LIGHT | DYNAMIC_MIDROUND_MEDIUM
	antag_datum = /datum/antagonist/revenant
	points_cost = 30
	weight = 4

/datum/dynamic_ruleset/midround/ghost/revenant/get_poll_icon()
	return /mob/living/simple_animal/revenant

/datum/dynamic_ruleset/midround/ghost/revenant/get_spawn_locations()
	// Corpses
	for(var/mob/living/corpse in GLOB.dead_mob_list)
		var/turf/corpse_turf = get_turf(corpse)
		if(corpse_turf && is_station_level(corpse_turf.z))
			spawn_locations += corpse_turf

	// Morgue trays and crematoriums
	for(var/obj/structure/bodycontainer/corpse_container in GLOB.bodycontainers)
		var/turf/container_turf = get_turf(corpse_container)
		if(container_turf && is_station_level(container_turf.z))
			spawn_locations += container_turf
	// Carp spawnpoints
	if(!length(spawn_locations))
		return ..()

/datum/dynamic_ruleset/midround/ghost/revenant/generate_ruleset_body(mob/dead/observer/chosen_mob)
	var/datum/mind/player_mind = new /datum/mind(chosen_mob.key)
	player_mind.active = TRUE

	var/turf/spawnable_turf = get_non_holy_tile_from_list(spawn_locations)
	if(!spawnable_turf)
		spawnable_turf = pick(spawn_locations)

	var/mob/living/simple_animal/revenant/revenant_body = new(spawnable_turf)
	player_mind.transfer_to(revenant_body)

	return revenant_body

//////////////////////////////////////////////
//                                          //
//       SPIDER INFESTATION (MEDIUM)        //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/spiders
	name = "Spider Infestation"
	severity = DYNAMIC_MIDROUND_MEDIUM | DYNAMIC_MIDROUND_HEAVY
	antag_datum = /datum/antagonist/spider
	drafted_players_amount = 2
	points_cost = 40
	weight = 4

	var/datum/team/spiders/team

/datum/dynamic_ruleset/midround/ghost/spiders/get_poll_icon()
	return /mob/living/simple_animal/hostile/poison/giant_spider/broodmother

/datum/dynamic_ruleset/midround/ghost/spiders/generate_ruleset_body(mob/dead/observer/chosen_mob)
	var/datum/mind/player_mind = new /datum/mind(chosen_mob.key)
	player_mind.active = TRUE

	var/obj/vent = pick(spawn_locations)
	var/mob/living/simple_animal/hostile/poison/giant_spider/broodmother/broodmother_body = new(vent.loc)
	broodmother_body.forceMove(vent)
	player_mind.transfer_to(broodmother_body)
	broodmother_body.fed += 3
	broodmother_body.lay_eggs.update_buttons()

	return broodmother_body

/datum/dynamic_ruleset/midround/ghost/spiders/finish_setup(mob/new_character)
	. = ..()
	if(!team)
		team = new
		team.directive = "Ensure the survival of your brood and overtake whatever structure you find yourself in."

	var/datum/antagonist/spider/spider_antag = new_character.mind.has_antag_datum(/datum/antagonist/spider)
	spider_antag.set_spider_team(team)

/datum/dynamic_ruleset/midround/ghost/spiders/get_spawn_locations()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent in GLOB.machines)
		if(QDELETED(vent))
			continue

		if(is_station_level(vent.loc.z) && !vent.welded)
			var/datum/pipenet/vent_parent = vent.parents[1]

			// Nothing is connected to the vent
			if(!vent_parent)
				continue
			// Stop xenos from getting stuck in small networks
			if(length(vent_parent.other_atmos_machines) < 20)
				continue

			spawn_locations += vent

//////////////////////////////////////////////
//                                          //
//             SWARMER (MEDIUM)             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/swarmer
	name = "Swarmer"
	severity = DYNAMIC_MIDROUND_MEDIUM | DYNAMIC_MIDROUND_HEAVY
	antag_datum = /datum/antagonist/swarmer
	points_cost = 40
	weight = 4

	var/announce_probability = 25

/datum/dynamic_ruleset/midround/ghost/swarmer/get_poll_icon()
	return /mob/living/simple_animal/hostile/swarmer

/datum/dynamic_ruleset/midround/ghost/swarmer/generate_ruleset_body(mob/dead/observer/chosen_mob)
	var/datum/mind/player_mind = new /datum/mind(chosen_mob.key)
	player_mind.active = TRUE

	var/mob/living/simple_animal/hostile/swarmer/swarmer_body = new(pick(spawn_locations))
	player_mind.transfer_to(swarmer_body)

	return swarmer_body

/datum/dynamic_ruleset/midround/ghost/swarmer/execute(mob/applicant)
	. = ..()
	if(. == DYNAMIC_EXECUTE_SUCCESS && prob(announce_probability))
		var/swarmer_report = span_bigbold("[command_name()] High-Priority Update")
		swarmer_report += "<br><br>Our long-range sensors have detected an odd signal emanating from your station. We recommend immediate investigation, as something foreign may have infiltrated the station."
		print_command_report(swarmer_report, announce=TRUE)

/datum/dynamic_ruleset/midround/ghost/swarmer/get_spawn_locations()
	spawn_locations = GLOB.xeno_spawn

//////////////////////////////////////////////
//                                          //
//              MORPH (MEDIUM)              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/morph
	name = "Morph"
	severity = DYNAMIC_MIDROUND_MEDIUM
	antag_datum = /datum/antagonist/morph
	points_cost = 30
	weight = 4

/datum/dynamic_ruleset/midround/ghost/morph/get_poll_icon()
	return /mob/living/simple_animal/hostile/morph

/datum/dynamic_ruleset/midround/ghost/morph/generate_ruleset_body(mob/dead/observer/chosen_mob)
	var/datum/mind/player_mind = new /datum/mind(chosen_mob.key)
	player_mind.active = TRUE

	var/mob/living/simple_animal/hostile/morph/morph_body = new(pick(spawn_locations))
	player_mind.transfer_to(morph_body)

	SEND_SOUND(morph_body, sound('sound/magic/mutate.ogg'))

	return morph_body

/datum/dynamic_ruleset/midround/ghost/morph/get_spawn_locations()
	spawn_locations = GLOB.xeno_spawn

//////////////////////////////////////////////
//                                          //
//            PRISONERS (LIGHT)             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/prisoners
	name = "Prisoners"
	severity = DYNAMIC_MIDROUND_LIGHT
	antag_datum = /datum/antagonist/prisoner
	points_cost = 30
	weight = 4

/datum/dynamic_ruleset/midround/ghost/prisoners/get_poll_icon()
	return /obj/item/card/id/prisoner

/datum/dynamic_ruleset/midround/ghost/prisoners/get_spawn_locations()
	for(var/obj/effect/landmark/prisonspawn/spawnpoint in GLOB.landmarks_list)
		if(isturf(spawnpoint.loc))
			spawn_locations += spawnpoint.loc

/datum/dynamic_ruleset/midround/ghost/prisoners/execute()
	if(!allowed())
		return DYNAMIC_EXECUTE_FAILURE

	// Get ghost candidates
	send_applications()
	// Trim candidates
	trim_candidates()

	// Spawn prisoners
	var/turf/landing_turf = pick(spawn_locations)
	if(spawn_prisoners(landing_turf, candidates, list()) == NOT_ENOUGH_PLAYERS)
		message_admins("DYNAMIC: Not enough players volunteered for the [src] rulset - [length(candidates)] out of [drafted_players_amount].")
		log_dynamic("NOT ALLOWED: Not enough players volunteered for the [src] ruleset - [length(candidates)] out of [drafted_players_amount].")
		return DYNAMIC_EXECUTE_FAILURE

	return DYNAMIC_EXECUTE_SUCCESS

//////////////////////////////////////////////
//                                          //
//            FUGITIVES (LIGHT)             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/ghost/fugitives
	name = "Fugitives"
	severity = DYNAMIC_MIDROUND_LIGHT
	antag_datum = /datum/antagonist/fugitive
	points_cost = 30
	weight = 4

/datum/dynamic_ruleset/midround/ghost/fugitives/get_poll_icon()
	return /obj/item/clothing/mask/gas/tiki_mask

/datum/dynamic_ruleset/midround/ghost/fugitives/allowed(require_drafted = TRUE)
	. = ..()
	if(!.)
		return FALSE

	if(!SSmapping.empty_space)
		return FALSE

	// There cannot already be fugitives or hunters
	for(var/datum/team/fugitive/fugitive_team in GLOB.antagonist_teams)
		return FALSE
	for(var/datum/team/fugitive_hunters/hunter_team in GLOB.antagonist_teams)
		return FALSE

/datum/dynamic_ruleset/midround/ghost/fugitives/get_spawn_locations()
	for(var/turf/turf in GLOB.xeno_spawn)
		if(istype(turf.loc, /area/maintenance))
			spawn_locations += turf

/datum/dynamic_ruleset/midround/ghost/fugitives/execute()
	if(!allowed())
		return DYNAMIC_EXECUTE_FAILURE

	// Get ghost candidates
	send_applications()
	// Trim candidates
	trim_candidates()

	// Spawn prisoners
	var/turf/landing_turf = pick(spawn_locations)
	if(spawn_fugitives(landing_turf, candidates, list()) == NOT_ENOUGH_PLAYERS)
		message_admins("DYNAMIC: Not enough players volunteered for the [src] rulset - [length(candidates)] out of [drafted_players_amount].")
		log_dynamic("NOT ALLOWED: Not enough players volunteered for the [src] ruleset - [length(candidates)] out of [drafted_players_amount].")
		return DYNAMIC_EXECUTE_FAILURE

	return DYNAMIC_EXECUTE_SUCCESS
