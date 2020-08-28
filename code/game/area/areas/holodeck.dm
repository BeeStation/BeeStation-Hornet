/area/holodeck
	name = "Holodeck"
	icon_state = "holodeck"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	flags_1 = NONE
	area_flags = HIDDEN_STASH_LOCATION | VALID_TERRITORY | UNIQUE_AREA | HIDDEN_AREA | REMOTE_APC
	sound_environment = SOUND_ENVIRONMENT_PADDED_CELL
	camera_networks = list(CAMERA_NETWORK_STATION)

	var/obj/machinery/computer/holodeck/linked
	var/restricted = FALSE // if true, program goes on emag list

	network_root_id = "HOLODECK"
/*
	Power tracking: Use the holodeck computer's power grid
	Asserts are to avoid the inevitable infinite loops
*/

/area/holodeck/powered(var/chan)
	if(!requires_power)
		return TRUE
	if(always_unpowered)
		return FALSE
	if(!linked)
		return FALSE
	var/area/A = get_area(linked)
	ASSERT(!istype(A, /area/holodeck))
	return A.powered(chan)

/area/holodeck/addStaticPower(value, powerchannel)
	if(!linked)
		return
	var/area/A = get_area(linked)
	ASSERT(!istype(A, /area/holodeck))
	return ..()

/area/holodeck/use_power(var/amount, var/chan)
	if(!linked)
		return FALSE
	var/area/A = get_area(linked)
	ASSERT(!istype(A, /area/holodeck))
	return ..()


/*
	This is the standard holodeck.  It is intended to allow you to
	blow off steam by doing stupid things like laying down, throwing
	spheres at holes, or bludgeoning people.
*/
/area/holodeck/rec_center
	name = "\improper Recreational Holodeck"

/area/holodeck/rec_center/offstation_one
	name = "\improper Recreational Holodeck"
//Prison holodeck will be 4x7
/area/holodeck/prison
	name = "\improper Workshop"

/area/holodeck/small //7x7
	name = "\improper Small Recreational Holodeck"
