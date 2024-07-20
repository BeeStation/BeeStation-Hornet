/datum/round_event_control/clownloose
	name = "Spawn Loose Clown"
	typepath = /datum/round_event/ghost_role/clownloose
	weight = 9999
	max_occurrences = 1
	min_players = 20
	cannot_spawn_after_shuttlecall = TRUE

/datum/round_event/ghost_role/clownloose/setup()
	minimum_required = 1
	role_name = ROLE_CLOWNLOOSE
	fakeable = FALSE

/datum/round_event/ghost_role/clownloose/spawn_role()
	var/list/possible_spawns = list()
	for(var/turf/L in GLOB.clownloose_spawn)
		possible_spawns += L
	if(!length(possible_spawns))
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR
	var/turf/landing_turf = pick(possible_spawns)
	var/list/candidates = get_candidates(ROLE_CLOWNLOOSE, /datum/role_preference/midround_ghost/clownloose)
	var/result = spawn_clownloose(landing_turf, candidates, spawned_mobs)
	if(result != SUCCESSFUL_SPAWN)
		return result
	priority_announce("Delta level prisoner has breached CentCom prisons and stolen a high rank officers headwear. Be weary of any potential fugitive onboard. Retrieve the prisoner and the stolen posetion back to CentCom.", "Security Alert", SSstation.announcer.get_rand_report_sound())
	sound_to_playing_players('sound/misc/honk_echo_distant.ogg', 20)
	return SUCCESSFUL_SPAWN

/proc/spawn_clownloose(turf/landing_turf, list/candidates, list/spawned_mobs)
	var/job_check = 0
	for (var/mob/H in SSticker.mode.current_players[CURRENT_LIVING_PLAYERS])
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
		var/mob/living/carbon/human/S = gear_clownloose(i, selected, landing_turf)
		spawned_mobs += S

	return SUCCESSFUL_SPAWN

/proc/gear_clownloose(index, mob/dead/selected, turf/landing_turf)
	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE
	var/mob/living/carbon/human/S = new()
	var/obj/structure/closet/supplypod/bluespacepod/pod = new()
	pod.explosionSize = list(0, 0, 0, 0)
	S.forceMove(pod)
	player_mind.transfer_to(S)
	player_mind.assigned_role = ROLE_CLOWNLOOSE
	player_mind.special_role = ROLE_CLOWNLOOSE
	var/datum/antagonist/clownloose/A = new()
	player_mind.add_antag_datum(A)
	var/outfit = /datum/outfit/clownloose
	S.equipOutfit(outfit)

	new /obj/effect/pod_landingzone(landing_turf, pod)

	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Loose Clown by an event.")
	log_game("[key_name(S)] was spawned as a Loose Clown by an event.")
	return S

