/// Will hunt down ships that are not in the same faction
/datum/shuttle_ai_pilot/npc/hostile

/datum/shuttle_ai_pilot/npc/hostile/handle_ai_flight_action(datum/orbital_object/shuttle/shuttle)
	//Locate a hostile ship and fly towards it
	//Interdict if within range
	//Do the flight action
	. = ..()
