/datum/priority_directive/deploy_beacon
	name = "Deploy Beacon"
	objective_explanation = "Secure a trackable lockbox which will unlock after 10 minutes."
	details = "We have identified a deaddrop that has been placed by a rival spy agency and have maintained an accurate track on the box. \
		You have the option to track and secure the valuable items before anyone else gets to them. The items are stored in a trackable \
		box which will automatically unlock after a set period of time."

/datum/priority_directive/deploy_beacon/_allocate_teams(list/uplinks, list/player_minds)
	if (length(uplinks) <= 3)
		reject()
		return
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

/datum/priority_directive/deploy_beacon/_generate(list/uplinks, list/player_minds)
	return

/datum/priority_directive/deploy_beacon/get_track_atom()
	return target
