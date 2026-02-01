/datum/priority_directive/steal
	name = "Apply Poison"
	objective_explanation = "Apply poison to the target."
	details = "The Syndicate have identified an object of interest, and would \
	like you to take some steps to hinder Nanotrasen's research. Obtain the target \
	and apply a toxin, which will incapacitate the next person to touch it. Make \
	sure you wear gloves if you intend to handle the item directly, as touching the \
	poisoned target with bare hands guarantees death."
	reputation_loss = REPUTATION_LOSS_SOLO_DIRECTIVE
	shared = FALSE
	last_for = 40 MINUTES
	var/equipment_summoned = FALSE
	var/obj/item/steal_target_path = null

/datum/priority_directive/steal/allocate_teams(list/uplinks, list/player_minds, force)
	if (!length(uplinks) && !force)
		reject()
		return
	var/list/valid_targets = list()
	if(!GLOB.possible_items.len)//Only need to fill the list when it's needed.
		for(var/I in subtypesof(/datum/objective_item/steal))
			new I
	for(var/datum/objective_item/possible_item in GLOB.possible_items)
		// Job check
		if (!possible_item.is_valid())
			continue
		// Does not have the required flag
		if (!(possible_item.objective_flags & STEAL_DIRECTIVE_TOXIN))
			continue
		var/is_valid = TRUE
		for (var/datum/component/uplink/uplink in uplinks)
			if (!uplink.owner)
				continue
			if(uplink.owner.current.mind.assigned_role in possible_item.excludefromjob)
				is_valid = FALSE
				break
		if (!is_valid)
			continue
		valid_targets += possible_item
	// Bad directive
	if (!length(valid_targets))
		reject()
		return
	// Pick the target
	var/datum/objective_item/target = pick(valid_targets)
	set_target(target)
	// Create the team
	add_antagonist_team(uplinks)

/datum/priority_directive/steal/generate(list/teams)
	return rand(4, 8)

/datum/priority_directive/steal/get_track_atom(turf/origin, datum/component/uplink/tracker)
	var/closest = INFINITY
	var/atom/tracked = null
	for (var/atom/target in get_trackables_by_type(steal_target_path, TRUE))
		var/turf/target_turf = get_turf(target)
		if (!target_turf)
			continue
		// Objectives in incorrect locations are simply not trackable
		if (!compare_z(origin.z, target_turf.z))
			continue
		// Prioritise things that are on the same z
		var/dist = get_dist(target, origin) + abs(origin.z - target_turf.z) * 1000
		if (dist > closest)
			continue
		closest = dist
		tracked = target
	return tracked

/datum/priority_directive/steal/get_special_action(datum/component/uplink)
	return new /datum/directive_special_action("Get Equipment")

/datum/priority_directive/steal/perform_special_action(datum/component/uplink, mob/living/user)
	if (equipment_summoned)
		to_chat(user, span_warning("You have already obtained the equipment for this mission."))
		return
	equipment_summoned = TRUE
	// Summon Equipment
	var/obj/item/spawned = new /obj/item/poison_paper/sarin(user.loc, src)
	user.put_in_active_hand(spawned)
	RegisterSignal(spawned, COMSIG_POISON_PAPER_APPLIED, PROC_REF(poison_applied))

/datum/priority_directive/steal/proc/set_target(datum/objective_item/target)
	steal_target_path = target.targetitem
	objective_explanation = "Apply the provided poison to \the [steal_target_path::name]"

/datum/priority_directive/steal/proc/poison_applied(datum/source, atom/target, mob/living/user)
	SIGNAL_HANDLER
	if (!istype(target, steal_target_path))
		mission_update("The posion has been applied to the wrong target, directive failed.")
		finish()
		return
	grant_universal_victory()
	finish()
