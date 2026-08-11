/datum/priority_directive/deaddrop
	name = "Secure Deaddrop"
	objective_explanation = "Secure a trackable lockbox which will unlock after 10 minutes."
	details = "We have identified a deaddrop that has been placed by a rival spy agency and have maintained an accurate track on the box. \
		You have the option to track and secure the valuable items before anyone else gets to them. The items are stored in a trackable \
		box which will automatically unlock after a set period of time. The items have been hidden in a bag underneath the floor tiles."
	last_for = 6 MINUTES
	shared = TRUE
	var/obj/item/storage/deaddrop_box/target

/datum/priority_directive/deaddrop/allocate_teams(list/uplinks, list/player_minds, force = FALSE)
	if (length(uplinks) <= 1 && !force)
		reject()
		return
	for (var/datum/component/uplink/antag in uplinks)
		// Create individual teams
		add_antagonist_team(antag)

/datum/priority_directive/deaddrop/late_allocate(datum/component/uplink/uplink)
	return add_antagonist_team(uplink)

/datum/priority_directive/deaddrop/generate(list/teams)
	// Spawn the deaddrop package
	var/tc_count = rand(2, 4)
	// Put the deaddrop somewhere
	var/turf/selected = get_random_station_turf()
	while (!istype(selected, /turf/open/floor/iron) || selected.is_blocked_turf(TRUE))
		selected = get_random_station_turf()
	var/atom/secret_bag = new /obj/item/storage/backpack/satchel/flat/empty(selected)
	target = new(secret_bag)
	new /obj/item/stack/sheet/telecrystal(target, tc_count)
	SEND_SIGNAL(secret_bag, COMSIG_OBJ_HIDE, selected.underfloor_accessibility < UNDERFLOOR_VISIBLE)
	// Return the reward generated
	return tc_count

/datum/priority_directive/deaddrop/finish()
	. = ..()
	target.unlock()
	var/atom/current = target
	while (!ismob(current) && !isturf(current) && current)
		current = current.loc
	// Hack so you don't get extra TC
	tc_reward = 0
	if (ismob(current))
		var/mob/living/living_holder = current
		var/datum/component/uplink/uplink = living_holder.mind.find_syndicate_uplink()
		grant_victory(uplink != null ? get_team(uplink) : null)
	else
		grant_victory(null)

/datum/priority_directive/deaddrop/get_track_atom(turf/origin, datum/component/uplink/tracker)
	return target
