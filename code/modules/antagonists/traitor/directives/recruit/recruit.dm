/datum/priority_directive/recruit
	name = "Recruitment"
	objective_explanation = "Recruit a blood-brother."
	details = "Being a member of the Syndicate requires swearing an oath; that oath requires you to prove \
		the you will not betray the lives of your fellow operatives in the field. Prove your worth, use the implant \
		stored in the stash provided to you, and recruit a co-conspirator."
	reputation_loss = REPUTATION_LOSS_SOLO_DIRECTIVE
	shared = FALSE
	last_for = INFINITY
	/// Flags that get assigned to the owner's uplink upon objective completion
	var/flags_to_assign = BROTHER_DIRECTIVE_FLAGS
	var/obj/item/implanter/bloodbrother/implanter_to_track = null

/datum/priority_directive/recruit/_allocate_teams(list/uplinks, list/player_minds, force)
	// Never automatically run this directive
	reject()

/datum/priority_directive/recruit/_generate(list/teams)
	return 0

/datum/priority_directive/recruit/get_track_atom()
	if (implanter_to_track?.loc)
		return implanter_to_track
	var/datum/directive_team/team = teams[1]
	if (!team)
		CRASH("Recruitment directive has no team assigned.")
	var/datum/component/uplink/uplink = team.uplinks[1]
	if (!uplink)
		CRASH("Recruitment directive has no uplink in its team.")
	for (var/datum/component/stash/stash in uplink.owner.antag_stashes)
		if (!stash.stash_item)
			continue
		if (locate(/obj/item/implanter/bloodbrother) in stash.stash_item)
			return stash.parent
	return null

/datum/priority_directive/recruit/finish()
	var/datum/directive_team/team = teams[1]
	if (!team)
		return ..()
	var/datum/component/uplink/uplink = team.uplinks[1]
	if (!uplink)
		return ..()
	uplink.directive_flags = flags_to_assign
	// If we were allowed personal objectives, get one right
	// away.
	uplink.next_personal_objective_time = 0
	return ..()

/// If the implanter gets destroyed or used, win
/datum/priority_directive/recruit/proc/track_implanter(obj/item/implanter/bloodbrother/implanter)
	if (!implanter || !implanter.imp)
		grant_universal_victory()
		finish()
		return
	implanter_to_track = implanter
	RegisterSignal(implanter, COMSIG_QDELETING, PROC_REF(implanter_used))
	RegisterSignal(implanter.imp, COMSIG_IMPLANT_IMPLANTING, PROC_REF(implanter_used))

/datum/priority_directive/recruit/proc/implanter_used()
	SIGNAL_HANDLER
	implanter_to_track = null
	grant_universal_victory()
	finish()
