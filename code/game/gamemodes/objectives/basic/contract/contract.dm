/datum/objective/contract
	var/payout = 0
	var/payout_bonus = 0
	var/area/dropoff = null

/datum/objective/contract/on_target_cryo()
	set_target(null)
	var/datum/antagonist/traitor/affected_traitor = owner.has_antag_datum(/datum/antagonist/traitor)
	if(!affected_traitor?.contractor_hub)
		return
	var/datum/contractor_hub/hub = affected_traitor.contractor_hub
	for(var/datum/syndicate_contract/affected_contract as() in hub.assigned_contracts)
		if(affected_contract.contract == src)
			affected_contract.generate(hub.assigned_targets)
			hub.assigned_targets.Add(affected_contract.contract.target)
			to_chat(owner.current, span_userdanger("<BR>Contract target out of reach. Contract rerolled."))
			break

// Generate a random valid area on the station that the dropoff will happen.
/datum/objective/contract/proc/generate_dropoff()
	var/found = FALSE
	while (!found)
		var/area/dropoff_area = pick(GLOB.areas)
		if(dropoff_area && is_station_level(dropoff_area.z) && !dropoff_area.outdoors)
			dropoff = dropoff_area
			found = TRUE

// Check if both the contractor and contract target are at the dropoff point.
/datum/objective/contract/proc/dropoff_check(mob/user, mob/target)
	var/area/user_area = get_area(user)
	var/area/target_area = get_area(target)

	return (istype(user_area, dropoff) && istype(target_area, dropoff))
