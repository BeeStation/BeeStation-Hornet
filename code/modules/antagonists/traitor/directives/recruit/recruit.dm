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
	var/equipment_granted = FALSE

/datum/priority_directive/recruit/allocate_teams(list/uplinks, list/player_minds, force)
	// Never automatically run this directive
	reject()

/datum/priority_directive/recruit/generate(list/teams)
	return 0

/datum/priority_directive/recruit/get_track_atom(turf/origin, datum/component/uplink/tracker)
	// Track the implanter if it is not in nullspace
	if (implanter_to_track?.loc)
		// Track the implanter
		if (!tracker || get_dist(origin, implanter_to_track) >= 1)
			return implanter_to_track
		// Return the nearest conversion target
		var/closest_distance = INFINITY
		var/closet_target = implanter_to_track
		var/obj/item/implant/bloodbrother/implant = implanter_to_track.imp
		// Implanter has no implant in it, track it anyway
		if (!istype(implant))
			return closet_target
		// Find the things that the implanter is looking for and track them
		for(var/datum/mind/victim in implant.linked_team?.valid_converts)
			if (!victim.current)
				continue
			var/distance = get_dist(victim.current, origin)
			if (distance < closest_distance)
				closest_distance = distance
				closet_target = victim.current
		return closet_target
	// Track the location of the stash component
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
	RegisterSignal(implanter, COMSIG_QDELETING, PROC_REF(implanter_lost))
	RegisterSignal(implanter.imp, COMSIG_IMPLANT_IMPLANTING, PROC_REF(implanter_used))

/datum/priority_directive/recruit/proc/implanter_lost()
	SIGNAL_HANDLER
	implanter_to_track = null
	grant_universal_victory()
	finish()

/datum/priority_directive/recruit/proc/implanter_used(datum/source, mob/living/user, mob/living/target)
	SIGNAL_HANDLER
	var/obj/item/implant/bloodbrother/implant = implanter_to_track.imp
	// Lost track of the mission, whatever, you can have it
	if (!istype(implant))
		implanter_to_track = null
		grant_universal_victory()
		finish()
		return
	if (!target.mind)
		return
	if (!(target.mind in implant.linked_team.valid_converts))
		return
	// Successful implant
	implanter_to_track = null
	grant_universal_victory()
	finish()

/datum/priority_directive/recruit/proc/update_details()
	var/list/targets = list()
	var/obj/item/implant/bloodbrother/implant = implanter_to_track.imp
	// Implanter has no implant in it, track it anyway
	if (!istype(implant))
		return
	// Find the things that the implanter is looking for and track them
	for(var/datum/mind/victim in implant.linked_team?.valid_converts)
		targets += victim.name
	details = "[initial(details)] The following subjects are suitable for conversion: [jointext(targets, ", ")]."


/datum/priority_directive/recruit/get_special_action(datum/component/uplink)
	return new /datum/directive_special_action("Get equipment")

/datum/priority_directive/recruit/perform_special_action(datum/component/uplink, mob/living/user)
	if (equipment_granted)
		to_chat(user, "<span class='warning'>You have already received your special equipment.</span>")
		return
	equipment_granted = TRUE
	switch (rand(1, 3))
		if (1)
			var/obj/item/spawned = new /obj/item/pen/paralytic(user.loc)
			user.put_in_active_hand(spawned)
		if (2)
			var/obj/item/spawned = new /obj/item/storage/box/syndie_kit/chemical(user.loc)
			user.put_in_active_hand(spawned)
			spawned = new /obj/item/gun/syringe(user.loc)
			user.put_in_inactive_hand(spawned)
		if (3)
			var/obj/item/spawned = new /obj/item/jammer(user.loc)
			user.put_in_active_hand(spawned)
			spawned = new /obj/item/melee/baton/security/loaded(user.loc)
			user.put_in_inactive_hand(spawned)
