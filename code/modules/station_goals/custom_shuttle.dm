/datum/station_goal/custom_shuttle
	name = "Combat Shuttle"
	var/kill_goal

/datum/station_goal/custom_shuttle/New()
	. = ..()
	kill_goal = rand(2, 6)

/datum/station_goal/custom_shuttle/get_report()
	return {"Nanotrasen's combat capability in this sector is limited, hostile activity in the surrounding area
	 is increasing. Central Command has authorised the construction of a combat-shuttle to counter the syndicate threat.

	 Operation details:
	  - Construct a shuttle with ranged shuttle weaponry.
	  - Explore unknown sectors and uncover hostile ships.
	  - Destroy [kill_goal] hostile vessels.

	 Basic shuttle parts are available for shipping via cargo."}

/datum/station_goal/custom_shuttle/check_completion()
	if(..())
		return TRUE
	if(kill_goal >= GLOB.ships_destroyed)
		return TRUE
	return FALSE
