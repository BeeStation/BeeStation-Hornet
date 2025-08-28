/datum/round_event_control/blob //god, we really need a "latest start" var, because blobs spawning an hour in is cringe
	name = "Blob"
	typepath = /datum/round_event/ghost_role/blob
	weight = 5
	max_occurrences = 1

	min_players = 20

	dynamic_should_hijack = TRUE

	gamemode_blacklist = list("blob") //Just in case a blob survives that long
	can_malf_fake_alert = TRUE

/datum/round_event/ghost_role/blob
	announceChance	= 0
	role_name = "blob overmind"
	fakeable = TRUE

/datum/round_event/ghost_role/blob/announce(fake)
	priority_announce("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", ANNOUNCER_OUTBREAK5)

/datum/round_event/ghost_role/blob/spawn_role()
	if(!length(GLOB.blobstart))
		return MAP_ERROR

	var/icon/blob_icon = icon('icons/mob/blob.dmi', icon_state = "blob_core")
	blob_icon.Blend("#9ACD32", ICON_MULTIPLY)
	blob_icon.Blend(icon('icons/mob/blob.dmi', "blob_core_overlay"), ICON_OVERLAY)

	var/mob/dead/observer/candidate = SSpolling.poll_ghosts_one_choice(
		role = /datum/role_preference/midround_ghost/blob,
		check_jobban = ROLE_BLOB,
		poll_time = 30 SECONDS,
		role_name_text = "blob",
		alert_pic = blob_icon,
	)
	if(!candidate)
		return NOT_ENOUGH_PLAYERS

	var/mob/camera/blob/blob = candidate.become_overmind()
	spawned_mobs += blob
	message_admins("[ADMIN_LOOKUPFLW(blob)] has been made into a blob overmind by an event.")
	log_game("[key_name(blob)] was spawned as a blob overmind by an event.")
	return SUCCESSFUL_SPAWN
