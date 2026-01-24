/datum/round_event_control/operative
	name = "Lone Operative"
	typepath = /datum/round_event/ghost_role/operative
	weight = 0 //its weight is relative to how much stationary and neglected the nuke disk is. See nuclearbomb.dm. Shouldn't be dynamic hijackable.
	max_occurrences = 1
	cannot_spawn_after_shuttlecall = TRUE

/datum/round_event/ghost_role/operative
	minimum_required = 1
	role_name = "lone operative"
	fakeable = FALSE

/datum/round_event/ghost_role/operative/spawn_role()
	var/list/spawn_locs = list()
	if(!spawn_locs.len) //try the new lone_ops spawner first
		for(var/obj/effect/landmark/loneops/L in GLOB.landmarks_list)
			if(isturf(L.loc))
				spawn_locs += L.loc
	if(!spawn_locs.len) //If we can't find any valid spawnpoints, try the carp spawns
		for(var/obj/effect/landmark/carpspawn/L in GLOB.landmarks_list)
			if(isturf(L.loc))
				spawn_locs += L.loc
	if(!spawn_locs.len)
		return MAP_ERROR

	var/datum/poll_config/config = new()
	config.check_jobban = ROLE_OPERATIVE
	config.poll_time = 30 SECONDS
	config.role_name_text = "lone operative"
	config.alert_pic = /obj/machinery/nuclearbomb/selfdestruct
	var/mob/dead/observer/candidate = SSpolling.poll_ghosts_one_choice(config)
	if(!candidate)
		return NOT_ENOUGH_PLAYERS

	var/mob/living/carbon/human/operative = new(pick(spawn_locs))
	operative.randomize_human_appearance(~RANDOMIZE_SPECIES)
	operative.dna.update_dna_identity()

	var/datum/mind/new_mind = new /datum/mind(candidate.key)
	new_mind.assigned_role = "Lone Operative"
	new_mind.special_role = "Lone Operative"
	new_mind.active = TRUE
	new_mind.transfer_to(operative)
	new_mind.add_antag_datum(/datum/antagonist/nukeop/lone)

	message_admins("[ADMIN_LOOKUPFLW(operative)] has been made into lone operative by an event.")
	log_game("[key_name(operative)] was spawned as a lone operative by an event.")
	spawned_mobs += operative
	return SUCCESSFUL_SPAWN
