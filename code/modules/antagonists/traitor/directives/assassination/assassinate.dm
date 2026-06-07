/datum/priority_directive/assassination
	name = "Assassination"
	objective_explanation = "Assassinate the target."
	details = "A person of interest has been identified and may cause issues for the longevity \
		of your current mission. Assassinating them will either shut them up for good, but even \
		if revived, the dread from the experience should pull them out of the picture. Payout is \
		granted immediately upon the death of the target."
	reputation_loss = REPUTATION_LOSS_SOLO_DIRECTIVE
	shared = FALSE
	last_for = 40 MINUTES
	var/mob/living/target = null
	var/datum/mind/target_mind = null

/datum/priority_directive/assassination/allocate_teams(list/uplinks, list/player_minds, force)
	if (!length(uplinks) && !force)
		reject()
		return
	// Find the victim
	var/list/valid_targets = list()
	// Choose which minsd to initially include
	for(var/datum/record/locked/target in GLOB.manifest.locked)
		var/datum/mind/mind = target.weakref_mind.resolve()
		// Must exist
		if (!mind)
			continue
		// Must have a body
		if (!mind.current)
			continue
		// No people that were already victims
		if (HAS_TRAIT(mind.current, TRAIT_ASSASSINATION_VICTIM))
			continue
		// No limit on forced directives
		if (force)
			valid_targets += mind
			continue
		// Must be alive
		if (mind.current.stat != CONSCIOUS)
			continue
		// Must be on the station
		if (!is_station_level(mind.current.z))
			continue
		// Exclude anyone in the chain of command
		if (SSjob.chain_of_command[mind.assigned_role])
			continue
		// Sure, lets kill you
		valid_targets += mind
	// Exclude owners and friends of the owner
	// If it is forced, you can assassinate yourself (for testing)
	if (!force)
		for (var/datum/component/uplink/uplink in uplinks)
			// Ownerless
			if (!uplink.owner)
				continue
			// Exclude the owner
			valid_targets -= uplink.owner
			// Exclude any alies of the owner
			for (var/datum/antagonist/antagonist in uplink.owner.antag_datums)
				var/datum/team/team = antagonist.get_team()
				if (!team)
					continue
				for (var/datum/mind/member in team.members)
					if (member == uplink.owner)
						continue
					valid_targets -= member
	// Bad directive
	if (!length(valid_targets))
		reject()
		return
	// Pick the target
	var/datum/mind/selected_target = pick(valid_targets)
	set_target(selected_target.current)
	// Create the team
	add_antagonist_team(uplinks)

/datum/priority_directive/assassination/generate(list/teams)
	return rand(4, 8)

/datum/priority_directive/assassination/get_track_atom(turf/origin, datum/component/uplink/tracker)
	return target

/datum/priority_directive/assassination/finish()
	// Deregister signals
	set_target(null)
	return ..()

/datum/priority_directive/assassination/proc/set_target(mob/living/carbon/target)
	// Deregister signals
	if (target)
		UnregisterSignal(target, COMSIG_QDELETING)
		UnregisterSignal(target, COMSIG_LIVING_DEATH)
	if (target_mind)
		UnregisterSignal(target_mind, COMSIG_MIND_TRANSFER_TO)
		UnregisterSignal(target_mind, COMSIG_MIND_CRYOED)
		UnregisterSignal(target_mind, COMSIG_QDELETING)
	src.target = target
	target_mind = target?.mind
	objective_explanation = initial(objective_explanation)
	if (!target)
		return
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(target_killed))
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(target_killed))
	if (target_mind)
		RegisterSignal(target_mind, COMSIG_MIND_TRANSFER_TO, PROC_REF(target_transfer))
		RegisterSignal(target_mind, COMSIG_MIND_CRYOED, PROC_REF(target_cryod))
		RegisterSignal(target_mind, COMSIG_QDELETING, PROC_REF(target_killed))
		objective_explanation = "Assassinate [target_mind.name]"

/datum/priority_directive/assassination/proc/target_transfer(datum/source, mob/old, mob/new_mob)
	SIGNAL_HANDLER
	set_target(new_mob)

/datum/priority_directive/assassination/proc/target_cryod()
	SIGNAL_HANDLER
	mission_update("The assassination target has entered cryo-stasis and is no longer a priority target. Directive aborted.")
	finish()

/datum/priority_directive/assassination/proc/target_killed()
	SIGNAL_HANDLER
	if (target)
		ADD_TRAIT(target, TRAIT_ASSASSINATION_VICTIM, FROM_DIRECTIVE)
	grant_universal_victory()
	finish()
