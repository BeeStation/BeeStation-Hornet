/// Will hunt down ships that are not in the same faction
/datum/shuttle_ai_pilot/npc/hostile

/datum/shuttle_ai_pilot/npc/hostile/handle_ai_flight_action(datum/orbital_object/shuttle/shuttle)
	//Get our shuttle data
	var/datum/shuttle_data/shuttle_data = SSorbits.get_shuttle_data(shuttle.shuttle_port_id)
	//Locate a hostile ship and fly towards it
	if(!shuttleTarget && length(shuttle_data.shuttle_weapons))
		for (var/shuttle_id as() in SSorbits.assoc_shuttles)
			var/datum/orbital_object/shuttle/other_shuttle = SSorbits.assoc_shuttles[shuttle_id]
			//Check faction
			var/datum/shuttle_data/target_data = SSorbits.get_shuttle_data(shuttle_id)
			if(check_faction_alignment(shuttle_data.faction, target_data.faction) == FACTION_STATUS_HOSTILE || (shuttle_data.faction.type in target_data.rogue_factions))
				set_target_location(other_shuttle)
				break
	//Interdict if within range
	if(shuttleTarget && shuttleTarget.position.DistanceTo(shuttle.position) < shuttle_data.interdiction_range)
		if(shuttle.perform_interdiction())
			return
	//Do the flight action
	. = ..()
