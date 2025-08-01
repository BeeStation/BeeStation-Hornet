/// Support unit gets its own very basic antag datum for admin logging.
/datum/antagonist/contractor_support
	name = "Contractor Support Unit"
	banning_key = ROLE_TRAITOR
	antag_moodlet = /datum/mood_event/focused

	show_in_roundend = FALSE /// We're already adding them in to the contractor's roundend.
	give_objectives = TRUE /// We give them their own custom objective.
	show_in_antagpanel = FALSE /// Not a proper/full antag.

	var/datum/team/contractor_team/contractor_team

/// Team for storing both the contractor and their support unit - only really for the HUD and admin logging.
/datum/team/contractor_team
	name = "Contractors"
	show_roundend_report = FALSE

/datum/antagonist/contractor_support/on_gain()
	owner.special_role = ROLE_TRAITOR
	if(give_objectives)
		forge_objectives()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	..()

/datum/antagonist/contractor_support/greet()
	to_chat(owner.current, span_alertsyndie("You are the Contractor Support Unit."))
	owner.announce_objectives()
	if(owner.current)
		if(owner.current.client)
			owner.current.client.tgui_panel?.give_antagonist_popup("Contractor Support Unit", "Follow your contractor's orders.")

/datum/antagonist/contractor_support/proc/forge_objectives()
	var/datum/objective/generic_objective = new

	generic_objective.name = "Follow Contractor's Orders"
	generic_objective.explanation_text = "Follow your orders. Assist agents in this mission area."

	generic_objective.completed = TRUE

	objectives += generic_objective
	log_objective(owner, generic_objective.explanation_text)

/datum/contractor_hub
	var/contract_rep = 0
	var/list/hub_items = list()
	var/list/purchased_items = list()
	var/static/list/contractor_items = typecacheof(/datum/contractor_item/, TRUE)

	var/datum/syndicate_contract/current_contract
	var/list/datum/syndicate_contract/assigned_contracts = list()

	var/list/assigned_targets = list() // used as a blacklist to make sure we're not assigning targets already assigned

	var/contracts_completed = 0
	var/contract_TC_payed_out = 0 // Keeping track for roundend reporting
	var/contract_TC_to_redeem = 0 // Used internally and roundend reporting - what TC we have available to cashout.

/datum/contractor_hub/proc/create_hub_items()
	for(var/path in contractor_items)
		var/datum/contractor_item/contractor_item = new path

		hub_items.Add(contractor_item)

/datum/contractor_hub/proc/create_contracts(datum/mind/owner)

	// 6 initial contracts
	var/list/to_generate = list(
		CONTRACT_PAYOUT_LARGE,
		CONTRACT_PAYOUT_MEDIUM,
		CONTRACT_PAYOUT_SMALL,
		CONTRACT_PAYOUT_SMALL,
		CONTRACT_PAYOUT_SMALL,
		CONTRACT_PAYOUT_SMALL
	)

	//What the fuck
	if(length(to_generate) > length(GLOB.manifest.locked))
		to_generate.Cut(1, length(GLOB.manifest.locked))

	// We don't want the sum of all the payouts to be under this amount
	var/lowest_TC_threshold = 30

	var/total = 0
	var/lowest_paying_sum = 0
	var/datum/syndicate_contract/lowest_paying_contract

	// Randomise order, so we don't have contracts always in payout order.
	to_generate = shuffle(to_generate)

	// Support contract generation happening multiple times
	var/start_index = 1
	if (assigned_contracts.len != 0)
		start_index = assigned_contracts.len + 1

	// Generate contracts, and find the lowest paying.
	for(var/i in 1 to to_generate.len)
		var/datum/syndicate_contract/contract_to_add = new(owner, assigned_targets, to_generate[i])
		var/contract_payout_total = contract_to_add.contract.payout + contract_to_add.contract.payout_bonus

		assigned_targets.Add(contract_to_add.contract.target)

		if (!lowest_paying_contract || (contract_payout_total < lowest_paying_sum))
			lowest_paying_sum = contract_payout_total
			lowest_paying_contract = contract_to_add

		total += contract_payout_total
		contract_to_add.id = start_index
		assigned_contracts.Add(contract_to_add)

		start_index++

	// If the threshold for TC payouts isn't reached, boost the lowest paying contract
	if (total < lowest_TC_threshold)
		lowest_paying_contract.contract.payout_bonus += (lowest_TC_threshold - total)

/datum/contractor_item
	var/name // Name of item
	var/desc // description of item
	var/item // item path, no item path means the purchase needs it's own handle_purchase()
	var/item_icon = "broadcast-tower" // fontawesome icon to use inside the hub - https://fontawesome.com/icons/
	var/limited = -1 // Any number above 0 for how many times it can be bought in a round for a single traitor. -1 is unlimited.
	var/cost // Cost of the item in contract rep.

/datum/contractor_item/contract_reroll
	name = "Contract Reroll"
	desc = "Request a reroll of your current contract list. Will generate a new target, payment, and dropoff for the contracts you currently have available."
	item_icon = "dice"
	limited = 2
	cost = 0

/datum/contractor_item/contract_reroll/handle_purchase(var/datum/contractor_hub/hub)
	. = ..()

	if (.)
		/// We're not regenerating already completed/aborted/extracting contracts, but we don't want to repeat their targets.
		var/list/new_target_list = list()
		for(var/datum/syndicate_contract/contract_check in hub.assigned_contracts)
			if (contract_check.status != CONTRACT_STATUS_ACTIVE && contract_check.status != CONTRACT_STATUS_INACTIVE)
				if (contract_check.contract.target)
					new_target_list.Add(contract_check.contract.target)
				continue

		/// Reroll contracts without duplicates
		for(var/datum/syndicate_contract/rerolling_contract in hub.assigned_contracts)
			if (rerolling_contract.status != CONTRACT_STATUS_ACTIVE && rerolling_contract.status != CONTRACT_STATUS_INACTIVE)
				continue

			rerolling_contract.generate(new_target_list)
			new_target_list.Add(rerolling_contract.contract.target)

		/// Set our target list with the new set we've generated.
		hub.assigned_targets = new_target_list

/datum/contractor_item/contractor_pinpointer
	name = "Contractor Pinpointer"
	desc = "A pinpointer that finds targets even without active suit sensors. Due to taking advantage of an exploit within the system, it can't pinpoint to the same accuracy as the traditional models. Becomes permanently locked to the user that first activates it."
	item = /obj/item/pinpointer/crew/contractor
	item_icon = "search-location"
	limited = 2
	cost = 1

/datum/contractor_item/fulton_extraction_kit
	name = "Fulton Extraction Kit"
	desc = "For getting your target across the station to those difficult dropoffs. Place the beacon somewhere secure, and link the pack. Activating the pack on your target in space will send them over to the beacon - make sure they're not just going to run away though!"
	item = /obj/item/storage/box/contractor/fulton_extraction
	item_icon = "parachute-box"
	limited = 1
	cost = 1

/datum/contractor_item/contractor_partner
	name = "Reinforcements"
	desc = "Upon purchase we'll contact available units in the area. Should there be an agent free, we'll send them down to assist you immediately. If no units are free, we give a full refund."
	item_icon = "user-friends"
	limited = 1
	cost = 2
	var/datum/mind/partner_mind = null

/datum/contractor_item/contractor_partner/handle_purchase(var/datum/contractor_hub/hub, mob/living/user)
	. = ..()

	if (.)
		to_chat(user, span_notice("The uplink vibrates quietly, connecting to nearby agents..."))

		var/mob/dead/observer/candidate = SSpolling.poll_ghosts_one_choice(
			check_jobban = ROLE_CONTRACTOR_SUPPORT_UNIT,
			poll_time = 10 SECONDS,
			jump_target = user,
			role_name_text = "contractor support unit for [user.real_name]",
			alert_pic = user,
		)

		if(candidate)
			spawn_contractor_partner(user, candidate.key)
		else
			to_chat(user, span_notice("No available agents at this time, please try again later."))

			// refund and add the limit back.
			limited += 1
			hub.contract_rep += cost
			hub.purchased_items -= src

/datum/outfit/contractor_partner
	name = "Contractor Support Unit"

	uniform = /obj/item/clothing/under/chameleon
	suit = /obj/item/clothing/suit/chameleon
	back = /obj/item/storage/backpack
	belt = /obj/item/modular_computer/tablet/pda/preset/chameleon
	mask = /obj/item/clothing/mask/cigarette/syndicate
	shoes = /obj/item/clothing/shoes/chameleon/noslip
	ears = /obj/item/radio/headset/chameleon
	id = /obj/item/card/id/syndicate
	r_hand = /obj/item/storage/toolbox/syndicate

	backpack_contents = list(/obj/item/storage/box/survival, /obj/item/implanter/uplink, /obj/item/clothing/mask/chameleon,
							/obj/item/storage/fancy/cigarettes/cigpack_syndicate, /obj/item/lighter)

/datum/outfit/contractor_partner/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	var/obj/item/clothing/mask/cigarette/syndicate/cig = H.get_item_by_slot(ITEM_SLOT_MASK)

	// pre-light their cig
	cig.light()

/datum/contractor_item/contractor_partner/proc/spawn_contractor_partner(mob/living/user, key)
	var/mob/living/carbon/human/partner = new()
	var/datum/outfit/contractor_partner/partner_outfit = new()

	partner_outfit.equip(partner)

	var/obj/structure/closet/supplypod/arrival_pod = new()

	arrival_pod.style = STYLE_SYNDICATE
	arrival_pod.explosionSize = list(0,0,0,1)
	arrival_pod.bluespace = TRUE

	var/turf/free_location = find_obstruction_free_location(2, user)

	// We really want to send them - if we can't find a nice location just land it on top of them.
	if (!free_location)
		free_location = get_turf(user)

	partner.forceMove(arrival_pod)
	partner.ckey = key

	/// We give a reference to the mind that'll be the support unit
	partner_mind = partner.mind
	partner_mind.add_antag_datum(/datum/antagonist/contractor_support)

	to_chat(partner_mind.current, "\n[span_alertwarning("[user.real_name] is your superior. Follow any, and all orders given by them. You're here to support their mission only.")]")
	to_chat(partner_mind.current, "[span_alertwarning("Should they perish, or be otherwise unavailable, you're to assist other active agents in this mission area to the best of your ability.")]\n\n")

	new /obj/effect/pod_landingzone(free_location, arrival_pod)

/datum/contractor_item/blackout
	name = "Blackout"
	desc = "Request Syndicate Command to distrupt the station's powernet. Disables power across the station for a short duration."
	item_icon = "bolt"
	limited = 2
	cost = 3

/datum/contractor_item/blackout/handle_purchase(var/datum/contractor_hub/hub)
	. = ..()

	if (.)
		power_fail(35, 50)
		priority_announce("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Critical Power Failure", ANNOUNCER_POWEROFF)

// Subtract cost, and spawn if it's an item.
/datum/contractor_item/proc/handle_purchase(var/datum/contractor_hub/hub, mob/living/user)

	if (hub.contract_rep >= cost)
		hub.contract_rep -= cost
	else
		return FALSE

	if (limited >= 1)
		limited -= 1
	else if (limited == 0)
		return FALSE

	hub.purchased_items.Add(src)

	user.playsound_local(user, 'sound/machines/uplinkpurchase.ogg', 100)

	if (item && ispath(item))
		var/atom/item_to_create = new item(get_turf(user))

		if(user.put_in_hands(item_to_create))
			to_chat(user, span_notice("Your purchase materializes into your hands!"))
		else
			to_chat(user, span_notice("Your purchase materializes onto the floor."))
		log_uplink_purchase(user, item_to_create, "\improper contractor tablet")
		return item_to_create
	return TRUE

/obj/item/pinpointer/crew/contractor
	name = "contractor pinpointer"
	desc = "A handheld tracking device that locks onto certain signals. Ignores suit sensors, but is much less accurate."
	icon_state = "pinpointer_syndicate"
	worn_icon_state = "pinpointer_black"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	minimum_range = 25
	has_owner = TRUE
	ignore_suit_sensor_level = TRUE
	tracks_grand_z = TRUE

/obj/item/storage/box/contractor/fulton_extraction
	name = "Fulton Extraction Kit"
	icon_state = "syndiebox"
	illustration = "writing_syndie"

/obj/item/storage/box/contractor/fulton_extraction/PopulateContents()
	new /obj/item/extraction_pack(src)
	new /obj/item/fulton_core(src)

