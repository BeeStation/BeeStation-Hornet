/datum/priority_directive/assassination
	name = "Assassination"
	objective_explanation = "Activate a beacon with your team's signal at the specified location."
	details = "An opportunity has opened up for communication to be established with ground agents, you need \
		to deploy a beacon encoded our organisation's encrypion code. Hostile agents may try to swap the code \
		for their own, which you need to prevent from happening. There are friendly agents supporting you on this mission \
		but their identities are unknown."
	reputation_loss = REPUTATION_LOSS_SOLO_DIRECTIVE
	shared = FALSE
	var/mob/living/carbon/target = null

/datum/priority_directive/assassination/_allocate_teams(list/uplinks, list/player_minds, force)
	if (!length(uplinks) && !force)
		reject()
		return
	// Find the victim
	var/list/valid_targets = list()
	// Exclude owners and friends of the owner
	for (var/datum/component/uplink/uplink in uplinks)
		// Ownerless
		if (!uplink.owner)
			continue

	// Create the team
	add_antagonist_team(uplinks)

/datum/priority_directive/assassination/_generate(list/teams)
	return rand(4, 8)
