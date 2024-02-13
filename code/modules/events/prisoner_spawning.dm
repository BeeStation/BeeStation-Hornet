/datum/round_event_control/prisoner
	name = "Spawn Prisoners"
	typepath = /datum/round_event/ghost_role/prisoner
	max_occurrences = 1
	min_players = 20
	cannot_spawn_after_shuttlecall = TRUE

/datum/round_event/ghost_role/prisoner/setup()
	minimum_required = 1
	role_name = ROLE_PRISONER
	fakeable = FALSE

/datum/round_event/ghost_role/prisoner/spawn_role()
	for(var/datum/team/prisoner/F in GLOB.antagonist_teams)
		return MAP_ERROR
	var/list/possible_spawns = list()
	for(var/turf/L in GLOB.prisonspawn)
		possible_spawns += L
	if(!length(possible_spawns))
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR
	var/turf/landing_turf = pick(possible_spawns)
	var/list/candidates = get_candidates(ROLE_PRISONER, /datum/role_preference/midround_ghost/prisoner)
	var/result = spawn_prisoners(landing_turf, candidates, spawned_mobs)
	if(result != SUCCESSFUL_SPAWN)
		return result
	priority_announce("A group of High-Priority prisoners has been sent to your Station, Security Personnel, please keep them safe.", "Security Alert", SSstation.announcer.get_rand_report_sound())
	return SUCCESSFUL_SPAWN

/proc/spawn_prisoners(turf/landing_turf, list/candidates, list/spawned_mobs)
    var/member_size = rand(1, 4)
    for(var/i in 1 to member_size)
        var/mob/dead/selected = pick_n_take(candidates)
        if(!selected)
            continue
        var/mob/living/carbon/human/S = gear_prisoner(i, selected, landing_turf)
        spawned_mobs += S

    // After spawning:
    playsound(landing_turf, 'sound/weapons/emitter.ogg', 50, TRUE)
    // Tools so they can actually escape maintenance

    return SUCCESSFUL_SPAWN

/proc/gear_prisoner(index, mob/dead/selected, turf/landing_turf)
	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE
	var/mob/living/carbon/human/S = new(landing_turf)
	player_mind.transfer_to(S)
	player_mind.assigned_role = ROLE_PRISONER
	player_mind.special_role = ROLE_PRISONER
	var/datum/antagonist/prisoner/A = new()
	player_mind.add_antag_datum(A)
	var/outfit = /datum/outfit/prisoner
	S.equipOutfit(outfit)

	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Prisoner by an event.")
	log_game("[key_name(S)] was spawned as a Prisoner by an event.")
	return S
