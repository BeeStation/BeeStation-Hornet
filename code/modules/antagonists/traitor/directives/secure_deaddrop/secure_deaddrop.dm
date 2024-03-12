/datum/priority_directive/deaddrop
	name = "Secure Deaddrop"
	desc = "We have identified a deaddrop that has been placed by a rival spy agency and have maintained an accurate track on the box. \
		You have the option to track and secure the valuable items before anyone else gets to them. The items are stored in a trackable \
		box which will automatically unlock after a set period of time."
	var/obj/item/storage/deaddrop_box/target

/datum/priority_directive/deaddrop/allocate_teams(list/antag_datums, list/player_minds)
	if (length(antag_datums) <= 1)
		reject()
		return
	for (var/datum/antagonist/antag in antag_datums)
		// Create individual teams
		add_antagonist_team(antag)

/datum/priority_directive/deaddrop/generate(list/antag_datums, list/player_minds)
	// Spawn the deaddrop package
	target = new()
	var/tc_count = tc_curve(get_independent_difficulty())
	new /obj/item/stack/sheet/telecrystal(target, tc_count)
	// Put the deaddrop somewhere
	var/list/antag_minds = list()
	for (var/datum/antagonist/antag in antag_datums)
		antag_minds += antag.owner
	new /datum/component/stash(antag_minds, target)
	// Return the reward generated
	return list(
		/obj/item/stack/sheet/telecrystal = tc_count,
	)

/datum/priority_directive/deaddrop/finish(list/antag_datums, list/player_minds)
	. = ..()
	target.unlock()
