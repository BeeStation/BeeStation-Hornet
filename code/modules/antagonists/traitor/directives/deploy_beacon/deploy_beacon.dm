/datum/priority_directive/deploy_beacon
	name = "Deploy Beacon"
	objective_explanation = "Activate a beacon with your team's signal at the specified location."
	details = "An opportunity has opened up for communication to be established with ground agents, you need \
		to deploy a beacon encoded our organisation's encrypion code. Hostile agents may try to swap the code \
		for their own, which you need to prevent from happening. There are friendly agents supporting you on this mission \
		but their identities are unknown."
	var/obj/item/uplink_beacon/deployed_beacon
	// Don't track this for deletion, since we need to maintain a track on the same position
 	// when a turf is changed.
	var/turf/center_turf
	// List of the uplinks that already took the beacon
	var/list/empty_uplinks = list()

/datum/priority_directive/deploy_beacon/_allocate_teams(list/uplinks, list/player_minds, force = FALSE)
	empty_uplinks.Cut()
	if (length(uplinks) <= 3 && !force)
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
	add_antagonist_team(a)
	add_antagonist_team(b)

/datum/priority_directive/deploy_beacon/_generate(list/teams)
	return rand(5, 9)

/datum/priority_directive/deploy_beacon/get_track_atom()
	return center_turf

/datum/priority_directive/deploy_beacon/get_special_action(datum/component/uplink)
	return new /datum/directive_special_action("Get beacon")

/datum/priority_directive/deploy_beacon/perform_special_action(datum/component/uplink, mob/living/user)
	if (uplink in empty_uplinks)
		to_chat(user, "<span class='warning'>You have already received your beacon! Pick it up or find someone aligned with your mission.</span>")
		return
	empty_uplinks += uplink
	// Give the requester a beacon
	var/obj/item/spawned = new /obj/item/uplink_beacon(user.loc)
	user.put_in_active_hand(spawned)
