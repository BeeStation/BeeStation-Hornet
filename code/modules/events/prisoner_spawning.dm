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
	var/list/possible_spawns = list()
	for(var/turf/L in GLOB.prisonspawn)
		possible_spawns += L
	if(!length(possible_spawns))
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR
	var/turf/landing_turf = pick(possible_spawns)
	var/datum/poll_config/config = new()
	config.check_jobban = ROLE_PRISONER
	config.role_name_text = "prisoner"
	config.alert_pic = /obj/item/card/id/prisoner
	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(config)
	var/result = spawn_prisoners(landing_turf, candidates, spawned_mobs)
	if(result != SUCCESSFUL_SPAWN)
		return result
	priority_announce("Due to overcrowding in a nearby security facility, a group of maximum security prisoners have been sent to your Station. Please ensure they are well taken care of and secured until the end of the shift.", "Security Alert", SSstation.announcer.get_rand_report_sound())
	return SUCCESSFUL_SPAWN

/proc/spawn_prisoners(turf/landing_turf, list/candidates, list/spawned_mobs)
	var/job_check = 0
	for (var/mob/H in SSdynamic.current_players[CURRENT_LIVING_PLAYERS])
		if(H.mind)
			var/datum/mind/M = H.mind
			if (M.assigned_role == JOB_NAME_SECURITYOFFICER || M.assigned_role == JOB_NAME_HEADOFSECURITY)
				job_check += 1
			if (M.assigned_role == JOB_NAME_WARDEN)
				job_check += 2

	var/member_size = rand(1, round(job_check/2) + 1)
	for(var/i in 1 to member_size)
		var/mob/dead/selected = pick_n_take(candidates)
		if(!selected)
			continue
		var/mob/living/carbon/human/S = gear_prisoner(i, selected, landing_turf)
		spawned_mobs += S

	return SUCCESSFUL_SPAWN

/proc/gear_prisoner(index, mob/dead/selected, turf/landing_turf)
	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE
	var/mob/living/carbon/human/S = new()
	var/obj/structure/closet/supplypod/bluespacepod/pod = new()
	pod.explosionSize = list(0, 0, 0, 0)
	S.forceMove(pod)
	player_mind.transfer_to(S)
	player_mind.assigned_role = ROLE_PRISONER
	player_mind.special_role = ROLE_PRISONER
	var/datum/antagonist/prisoner/A = new()
	player_mind.add_antag_datum(A)
	var/outfit = /datum/outfit/escapedprisoner
	S.equipOutfit(outfit)

	new /obj/effect/pod_landingzone(landing_turf, pod)

	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Prisoner by an event.")
	log_game("[key_name(S)] was spawned as a Prisoner by an event.")
	return S
