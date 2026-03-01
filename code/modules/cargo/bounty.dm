GLOBAL_LIST_EMPTY(bounties_list)

/datum/bounty
	var/name
	var/description
	var/reward = 1000 // In credits. Modified by a bunch of outside variables, so this is not the real amount of credits awarded.
	var/claimed = FALSE
	var/high_priority = FALSE

// Displayed on bounty UI screen.
/datum/bounty/proc/completion_string()
	return ""

// Displayed on bounty UI screen.
/datum/bounty/proc/reward_string()
	// Simulates claiming the bounty (SSeconomy.distribute_funds) to get the actual reward amount
	// As of april 2025, this returns (reward * 1.5)
	var/amount_shared = reward * SSeconomy.bounty_modifier // We get the amount to distribute among the departments
	var/part = round(amount_shared / SSeconomy.distribution_sum()) // We get the value of a share of the amount to distribute
	var/datum/bank_account/department/cargo_account = SSeconomy.get_budget_account(ACCOUNT_CAR_ID) // We get the cargo department budget account
	var/actual_reward = part * cargo_account.budget_ratio // We get the share of the cargo department

	return "[actual_reward] Credits"

/datum/bounty/proc/can_claim()
	return !claimed

// Called when the claim button is clicked. Override to provide fancy rewards.
/datum/bounty/proc/claim()
	if(can_claim())
		SSeconomy.distribute_funds(reward * SSeconomy.bounty_modifier)
		claimed = TRUE

// If an item sent in the cargo shuttle can satisfy the bounty.
/datum/bounty/proc/applies_to(obj/O)
	return FALSE

// Called when an object is shipped on the cargo shuttle.
/datum/bounty/proc/ship(obj/O)
	return

// When randomly generating the bounty list, duplicate bounties must be avoided.
// This proc is used to determine if two bounties are duplicates, or incompatible in general.
/datum/bounty/proc/compatible_with(other_bounty)
	return TRUE

/datum/bounty/proc/mark_high_priority(scale_reward = 2)
	if(high_priority)
		return
	high_priority = TRUE
	reward = round(reward * scale_reward)

// This proc is called when the shuttle docks at CentCom.
// It handles items shipped for bounties.
/proc/bounty_ship_item_and_contents(atom/movable/AM, dry_run=FALSE)
	if(!GLOB.bounties_list.len)
		setup_bounties()

	var/list/matched_one = FALSE
	for(var/thing in reverse_range(AM.GetAllContents()))
		var/matched_this = FALSE
		for(var/datum/bounty/B in GLOB.bounties_list)
			if(B.applies_to(thing))
				matched_one = TRUE
				matched_this = TRUE
				if(!dry_run)
					B.ship(thing)
		if(!dry_run && matched_this)
			qdel(thing)
	return matched_one

// Returns FALSE if the bounty is incompatible with the current bounties.
/proc/try_add_bounty(datum/bounty/new_bounty)
	if(!new_bounty || !new_bounty.name || !new_bounty.description)
		return FALSE
	for(var/i in GLOB.bounties_list)
		var/datum/bounty/B = i
		if(!B.compatible_with(new_bounty) || !new_bounty.compatible_with(B))
			return FALSE
	GLOB.bounties_list += new_bounty
	return TRUE

// Returns a new bounty of random type, but does not add it to GLOB.bounties_list.
/proc/random_bounty()
	switch(rand(1, 14))
		if(1)
			var/subtype = pick(subtypesof(/datum/bounty/item/assistant))
			return new subtype
		if(2)
			var/subtype = pick(subtypesof(/datum/bounty/item/mech))
			return new subtype
		if(3)
			var/subtype = pick(subtypesof(/datum/bounty/item/chef))
			return new subtype
		if(4)
			var/subtype = pick(subtypesof(/datum/bounty/item/security))
			return new subtype
		if(5)
			if(rand(2) == 1)
				return new /datum/bounty/reagent/simple_drink
			return new /datum/bounty/reagent/complex_drink
		if(6)
			if(rand(2) == 1)
				return new /datum/bounty/reagent/chemical_simple
			return new /datum/bounty/reagent/chemical_complex
		if(7)
			var/subtype = pick(subtypesof(/datum/bounty/virus))
			return new subtype
		if(8)
			var/subtype = pick(subtypesof(/datum/bounty/item/science))
			return new subtype
		if(9)
			var/subtype = pick(subtypesof(/datum/bounty/item/slime))
			return new subtype
		if(10)
			var/subtype = pick(subtypesof(/datum/bounty/item/engineering))
			return new subtype
		if(11)
			var/subtype = pick(subtypesof(/datum/bounty/item/mining))
			return new subtype
		if(12)
			var/subtype = pick(subtypesof(/datum/bounty/item/medical))
			return new subtype
		if(13)
			var/subtype = pick(subtypesof(/datum/bounty/item/botany))
			return new subtype
		if(14)
			var/subtype = pick(subtypesof(/datum/bounty/manuscript))
			return new subtype

// Called lazily at startup to populate GLOB.bounties_list with random bounties.
/proc/setup_bounties()

	var/pick // instead of creating it a bunch let's go ahead and toss it here, we know we're going to use it for dynamics and subtypes!

	/********************************Subtype Gens********************************/
	var/list/easy_add_list_subtypes = list(/datum/bounty/item/assistant = 2,
											/datum/bounty/item/mech = 1,
											/datum/bounty/item/core = 2,
											/datum/bounty/item/chef = 2,
											/datum/bounty/item/security = 1,
											/datum/bounty/virus = 1,
											/datum/bounty/item/engineering = 1,
											/datum/bounty/item/mining = 2,
											/datum/bounty/item/medical = 2,
											/datum/bounty/item/botany = 2)

	for(var/the_type in easy_add_list_subtypes)
		for(var/i in 1 to easy_add_list_subtypes[the_type])
			pick = pick(subtypesof(the_type))
			try_add_bounty(new pick)

	/********************************Strict Type Gens********************************/
	var/list/easy_add_list_strict_types = list(/datum/bounty/reagent/simple_drink = 1,
											/datum/bounty/reagent/complex_drink = 1,
											/datum/bounty/reagent/chemical_simple = 1,
											/datum/bounty/reagent/chemical_complex = 1,
											/datum/bounty/manuscript/assistant = 1,
											/datum/bounty/manuscript = 3)

	for(var/the_strict_type in easy_add_list_strict_types)
		for(var/i in 1 to easy_add_list_strict_types[the_strict_type])
			try_add_bounty(new the_strict_type)

	/********************************Dynamic Gens********************************/

	for(var/i in 0 to 1)
		if(prob(50))
			pick = pick(subtypesof(/datum/bounty/item/slime))
		else
			pick = pick(subtypesof(/datum/bounty/item/science))
		try_add_bounty(new pick)

	/********************************Cutoff for Non-Low Priority Bounties********************************/
	var/datum/bounty/B = pick(GLOB.bounties_list)
	B.mark_high_priority()

	/********************************Low Priority Gens********************************/
	var/list/low_priority_strict_type_list = list( /datum/bounty/item/alien_organs,
													/datum/bounty/item/syndicate_documents,
													/datum/bounty/item/adamantine,
													/datum/bounty/item/trash,
													/datum/bounty/more_bounties)

	for(var/low_priority_bounty in low_priority_strict_type_list)
		try_add_bounty(new low_priority_bounty)

/proc/completed_bounty_count()
	var/count = 0
	for(var/i in GLOB.bounties_list)
		var/datum/bounty/B = i
		if(B.claimed)
			++count
	return count

