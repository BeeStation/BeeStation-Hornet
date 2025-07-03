/datum/round_event_control/nightmare
	name = "Spawn Nightmare"
	typepath = /datum/round_event/ghost_role/nightmare
	max_occurrences = 1
	min_players = 20
	dynamic_should_hijack = TRUE
	cannot_spawn_after_shuttlecall = TRUE

/datum/round_event/ghost_role/nightmare
	minimum_required = 1
	role_name = "nightmare"
	fakeable = FALSE

/datum/round_event/ghost_role/nightmare/spawn_role()
	var/list/spawn_locs = list()
	for(var/X in GLOB.xeno_spawn)
		var/turf/T = X
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			spawn_locs += T

	if(!spawn_locs.len)
		return MAP_ERROR

	var/mob/dead/observer/candidate = SSpolling.poll_ghosts_one_choice(
		role = /datum/role_preference/midround_ghost/nightmare,
		check_jobban = ROLE_NIGHTMARE,
		poll_time = 30 SECONDS,
		role_name_text = "nightmare",
		alert_pic = /obj/item/light_eater,
	)
	if(!candidate)
		return NOT_ENOUGH_PLAYERS

	var/mob/living/carbon/human/nightmare = new(pick(spawn_locs))
	nightmare.set_species(/datum/species/shadow/nightmare)

	var/datum/mind/player_mind = new /datum/mind(candidate.key)
	player_mind.active = TRUE
	player_mind.assigned_role = ROLE_NIGHTMARE
	player_mind.special_role = ROLE_NIGHTMARE
	player_mind.transfer_to(nightmare)
	player_mind.add_antag_datum(/datum/antagonist/nightmare)

	playsound(nightmare, 'sound/magic/ethereal_exit.ogg', 50, 1, -1)
	message_admins("[ADMIN_LOOKUPFLW(nightmare)] has been made into a Nightmare by an event.")
	log_game("[key_name(nightmare)] was spawned as a Nightmare by an event.")
	spawned_mobs += nightmare

	return SUCCESSFUL_SPAWN
