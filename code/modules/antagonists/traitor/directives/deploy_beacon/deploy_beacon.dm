/datum/priority_directive/deploy_beacon
	name = "Deploy Beacon"
	objective_explanation = "Activate a beacon with your team's signal at the specified location."
	details = "An opportunity has opened up for communication to be established with ground agents, you need \
		to deploy a beacon encoded our organisation's encrypion code. Hostile agents may try to swap the code \
		for their own, which you need to prevent from happening. There are friendly agents supporting you on this mission \
		but their identities are unknown."
	reputation_loss = REPUTATION_LOSS_TEAM_DIRECTIVE
	shared = TRUE
	var/obj/structure/uplink_beacon/deployed_beacon
	// Don't track this for deletion, since we need to maintain a track on the same position
	// when a turf is changed.
	var/turf/center_turf
	// List of the uplinks that already took the beacon
	var/list/empty_uplinks = list()
	var/last_time_update = INFINITY

/datum/priority_directive/deploy_beacon/allocate_teams(list/uplinks, list/player_minds, force = FALSE)
	empty_uplinks.Cut()
	if (length(uplinks) < 2 && !force)
		reject()
		return
	// Pick a location that the beacon needs to be deployed at, somewhere out of prying eyes
	var/area_types = list()
	area_types += typesof(/area/maintenance)
	center_turf = null
	while (!isturf(center_turf) && length(area_types))
		var/target_type = pick(area_types)
		var/area/area = GLOB.areas_by_type[target_type]
		if (!area)
			area_types -= target_type
			continue
		center_turf = pick(area.contained_turfs)
	if (!center_turf)
		reject()
		return
	var/list/valid_codes = list(0, 1, 2, 3, 4, 5, 6, 7, 8)
	// Generate the teams
	var/list/a = list()
	var/list/b = list()
	var/i = 0
	for (var/datum/component/uplink/antag in uplinks)
		if ((i++ % 2) == 0)
			a += antag
		else
			b += antag
	// Create 2 teams
	add_antagonist_team(a, list(
		"code" = pick_n_take(valid_codes)
	))
	add_antagonist_team(b, list(
		"code" = pick_n_take(valid_codes)
	))
	last_time_update = INFINITY

/datum/priority_directive/deploy_beacon/late_allocate(datum/component/uplink/uplink)
	var/smallest_team_size = INFINITY
	var/datum/directive_team/smallest_team
	for (var/datum/directive_team/team in teams)
		if (length(team.uplinks) > smallest_team_size)
			continue
		smallest_team = team
		smallest_team_size = length(team.uplinks)
	smallest_team.uplinks += uplink
	return smallest_team

/datum/priority_directive/deploy_beacon/generate(list/teams)
	return rand(2, 4)

/datum/priority_directive/deploy_beacon/get_track_atom(turf/origin, datum/component/uplink/tracker)
	return center_turf

/datum/priority_directive/deploy_beacon/get_special_action(datum/component/uplink)
	return new /datum/directive_special_action("Get beacon")

/datum/priority_directive/deploy_beacon/perform_special_action(datum/component/uplink, mob/living/user)
	if (uplink in empty_uplinks)
		to_chat(user, "<span class='warning'>You have already received your beacon! Pick it up or find someone aligned with your mission.</span>")
		return
	empty_uplinks += uplink
	RegisterSignal(uplink, COMSIG_QDELETING, PROC_REF(component_destroyed))
	// Give the requester a beacon
	var/obj/item/spawned = new /obj/item/uplink_beacon(user.loc, src)
	user.put_in_active_hand(spawned)

/datum/priority_directive/deploy_beacon/proc/component_destroyed(datum/component/uplink)
	SIGNAL_HANDLER
	empty_uplinks -= uplink

/datum/priority_directive/deploy_beacon/get_explanation(datum/component/uplink)
	return "Activate a beacon in the specified location that is broadcasting on the [uplink_beacon_channel_to_color(get_team(uplink).data["code"])] channel."

/datum/priority_directive/deploy_beacon/get_details(datum/component/uplink)
	return deployed_beacon || objective_explanation

/datum/priority_directive/deploy_beacon/proc/update_time(time_left)
	end_at = world.time + time_left
	var/time_update = FLOOR(time_left / (30 SECONDS), 1)
	if (time_update < last_time_update)
		mission_update("Beacon activation in [DisplayTimeText(time_left)].")
		last_time_update = time_update

/datum/priority_directive/deploy_beacon/proc/beacon_broken()
	if (deployed_beacon.time_left <= 0)
		deployed_beacon = null
		return
	deployed_beacon = null
	end_at = world.time + 2 MINUTES
	can_timeout = TRUE
	mission_update("Beacon destroyed. Two minutes on the mission remain to re-establish connection.")

/datum/priority_directive/deploy_beacon/proc/on_beacon_planted(channel)
	can_timeout = FALSE
	for (var/datum/directive_team/team in teams)
		if (team.data["code"] == channel)
			team.send_message("The beacon is now broadcasting on your team's channel.")
		else
			team.send_message("Warning, a beacon has been planted on an opposing team's channel.<br /><font color='red'>You will fail if you don't change the beacon's frequency to [uplink_beacon_channel_to_color(team.data["code"])]!</font>")

/datum/priority_directive/deploy_beacon/proc/beacon_colour_update(old_channel, channel, time_left)
	if (old_channel == channel)
		return
	for (var/datum/directive_team/team in teams)
		if (team.data["code"] == channel)
			team.send_message("The beacon is now broadcasting on your team's channel. Maintain the beacon for [DisplayTimeText(time_left)] to succeed.")
		else if (old_channel == team.data["code"])
			team.send_message("Warning, the beacon is now broadcasting on another team's channel.<br /><font color='red'>You will fail if you don't change the beacon's frequency to [uplink_beacon_channel_to_color(team.data["code"])] in [DisplayTimeText(time_left)]!</font>")

/datum/priority_directive/deploy_beacon/proc/complete(channel)
	deployed_beacon = null
	finish()
	var/datum/directive_team/winner = null
	for (var/datum/directive_team/team in teams)
		if (team.data["code"] == channel)
			winner = team
			team.send_message("Beacon communication successfully established on the [uplink_beacon_channel_to_color(channel)] channel.")
		else
			team.send_message("You have failed to deploy the beacon on your allocated channel. Mission failed.")
	grant_victory(winner)
