/datum/round_event_control/cat_surgeon
	name = "Spawn Deranged Surgeon"
	typepath = /datum/round_event/ghost_role/cat_surgeon
	max_occurrences = 1

/datum/round_event/ghost_role/cat_surgeon
	minimum_required = 1
	role_name = "Deranged Surgeon"

/datum/round_event/ghost_role/cat_surgeon/spawn_role()
	var/list/candidates = get_candidates(ROLE_TERATOMA, null, ROLE_TERATOMA)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick_n_take(candidates)

	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = 1
	if(!GLOB.blobstart)
		return MAP_ERROR
	var/mob/living/simple_animal/hostile/cat_butcherer/S = new /mob/living/simple_animal/hostile/cat_butcherer(pick(GLOB.blobstart))
	player_mind.transfer_to(S)
	player_mind.assigned_role = "Deranged Surgeon"
	player_mind.special_role = "Deranged Surgeon"
	player_mind.add_antag_datum(/datum/antagonist/cat_surgeon)
	to_chat(S, S.playstyle_string)
	SEND_SOUND(S, sound('sound/magic/mutate.ogg'))
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Deranged Surgeon by an event.")
	log_game("[key_name(S)] was spawned as a Deranged Surgeon by an event.")
	spawned_mobs += S
	return SUCCESSFUL_SPAWN