/datum/priority_directive/acquire_funding
	name = "Bidding War"
	objective_explanation = "Acquire more funds than all other bidders to win the telecrystal auction."
	details = "A special auction has been declared. An anonymous buyer is putting up a rare and valuable stash of \
	telecrystals. If you can provide the highest bid, then the telecrystals are yours. To bid, hold any amount of \
	credits in one of your hands and push the 'bid' button available in the priority directives tab of the uplink."
	reputation_loss = 0
	shared = TRUE
	last_for = 8 MINUTES
	var/turf/highest_bid_location = null

/datum/priority_directive/acquire_funding/allocate_teams(list/uplinks, list/player_minds, force = FALSE)
	if (length(uplinks) < 2 && !force)
		reject()
		return
	for (var/datum/component/uplink/antag in uplinks)
		// Create individual teams
		add_antagonist_team(antag, list(
			"bid" = 0
		))

/datum/priority_directive/acquire_funding/late_allocate(datum/component/uplink/uplink)
	return add_antagonist_team(uplink, list(
		"bid" = 0
	))

/datum/priority_directive/acquire_funding/generate(list/teams)
	return rand(4, 8)

/datum/priority_directive/acquire_funding/get_track_atom(turf/origin, datum/component/uplink/tracker)
	return highest_bid_location

/datum/priority_directive/acquire_funding/get_special_action(datum/component/uplink)
	return new /datum/directive_special_action("Place Bid")

/datum/priority_directive/acquire_funding/perform_special_action(datum/component/uplink, mob/living/user)
	var/obj/item/target_item = null
	var/value = 0
	if (istype(user.get_active_held_item(), /obj/item/stack/spacecash))
		var/obj/item/stack/spacecash/held_cash = user.get_active_held_item()
		target_item = held_cash
		value = held_cash.value * held_cash.amount
	else if (istype(user.get_active_held_item(), /obj/item/holochip))
		var/obj/item/holochip/held_chips = user.get_active_held_item()
		target_item = held_chips
		value = held_chips.credits
	else if (istype(user.get_inactive_held_item(), /obj/item/stack/spacecash))
		var/obj/item/stack/spacecash/held_cash = user.get_inactive_held_item()
		target_item = held_cash
		value = held_cash.value * held_cash.amount
	else if (istype(user.get_inactive_held_item(), /obj/item/holochip))
		var/obj/item/holochip/held_chips = user.get_inactive_held_item()
		target_item = held_chips
		value = held_chips.credits
	// Not enough value for your bid
	if (value <= 0 || !target_item)
		to_chat(user, span_warning("You are not holding anything of value to bid!"))
		return
	var/datum/directive_team/team = get_team(uplink)
	if (!team)
		to_chat(user, span_warning("You are not participating in this mission, please report this as a bug!"))
		CRASH("[key_name(user)] called perform_special_action for a directive that they did not own.")
	qdel(target_item)
	var/datum/directive_team/current_highest = get_highest_bidder()
	team.data["bid"] += value
	var/current_bid = team.data["bid"]
	var/datum/directive_team/new_highest = get_highest_bidder()
	// Give the user some feedback
	if (new_highest == team)
		to_chat(user, span_notice("You raise your bid to [current_bid], you are currently winning!"))
	else if (new_highest)
		to_chat(user, span_notice("You raise your bid to [current_bid], the highest bid is [new_highest.data["bid"]]."))
	else
		to_chat(user, span_notice("You raise your bid to [current_bid], the auction is currently tied with nobody in the lead!"))
	// Directive update
	if (current_highest != new_highest)
		// Add one minute due to new highest bidder
		end_at = max(end_at, world.time + 1 MINUTES)
		var/time_left = end_at - world.time
		// Bid is now tied
		if (!new_highest)
			mission_update("The bid is now tied with [DisplayTimeText(time_left, 1)] left; nobody is in the lead. The bidder's location has been tracked.")
		else
			mission_update("A new highest bid has been made for [new_highest.data["bid"]] credits. The bid ends in [DisplayTimeText(time_left, 1)] left. The bidder's location has been tracked.")
	if (team == new_highest)
		highest_bid_location = get_turf(user)
		if (current_highest == new_highest)
			mission_update("The bid has been raised to [new_highest.data["bid"]] credits. The bidders location has been tracked.")

/datum/priority_directive/acquire_funding/proc/get_highest_bidder()
	RETURN_TYPE(/datum/directive_team)
	var/highest = 0
	var/datum/directive_team/highest_team = null
	var/draw = FALSE
	for (var/datum/directive_team/team in teams)
		if (team.data["bid"] == highest)
			draw = TRUE
			continue
		if (team.data["bid"] > highest)
			draw = FALSE
			highest_team = team
			highest = team.data["bid"]
	if (draw)
		return null
	return highest_team

/datum/priority_directive/acquire_funding/get_explanation(datum/component/uplink)
	return "Activate a beacon in the specified location that is broadcasting on the [uplink_beacon_channel_to_color(get_team(uplink).data["code"])] channel."

/datum/priority_directive/acquire_funding/get_details(datum/component/uplink)
	var/highest_bid = get_highest_bidder()?.data["bid"]
	if (highest_bid)
		return "[objective_explanation]. The current highest bid is [highest_bid] credits."
	return "[objective_explanation]. The bid is currently tied."

/datum/priority_directive/acquire_funding/finish()
	grant_victory(get_highest_bidder())
	return ..()
