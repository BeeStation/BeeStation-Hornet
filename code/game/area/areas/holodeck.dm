/area/station/holodeck
	name = "Holodeck"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "Holodeck"
	static_lighting = FALSE
	base_lighting_alpha = 255
	flags_1 = NONE
	area_flags = HIDDEN_STASH_LOCATION | VALID_TERRITORY | UNIQUE_AREA | HIDDEN_AREA | REMOTE_APC
	sound_environment = SOUND_ENVIRONMENT_PADDED_CELL
	camera_networks = list(CAMERA_NETWORK_STATION)

	var/obj/machinery/computer/holodeck/linked

/*
	Power tracking: Use the holodeck computer's power grid
	Asserts are to avoid the inevitable infinite loops
*/

/area/station/holodeck/powered(chan)
	if(!requires_power)
		return TRUE
	if(always_unpowered)
		return FALSE
	if(!linked)
		return FALSE
	var/area/A = get_area(linked)
	ASSERT(!istype(A, /area/station/holodeck))
	return A.powered(chan)

/area/station/holodeck/addStaticPower(value, powerchannel)
	if(!linked)
		return
	var/area/A = get_area(linked)
	ASSERT(!istype(A, /area/station/holodeck))
	return ..()

/area/station/holodeck/use_power(amount, chan)
	if(!linked)
		return 0
	var/area/A = get_area(linked)
	ASSERT(!istype(A, /area/station/holodeck))
	return ..()


/*
	This is the standard holodeck.  It is intended to allow you to
	blow off steam by doing stupid things like laying down, throwing
	spheres at holes, or bludgeoning people.
*/
/area/station/holodeck/rec_center
	name = "\improper Recreational Holodeck"

/area/station/holodeck/rec_center/offstation_one
	name = "\improper Recreational Holodeck"
//Prison holodeck will be 4x7
/area/station/holodeck/prison
	name = "\improper Workshop"

/area/station/holodeck/small //7x7
	name = "\improper Small Recreational Holodeck"

// DEBUG only
/area/station/holodeck/debug // 12x12
	requires_power = FALSE
	name = "\improper Debug Holodeck"
