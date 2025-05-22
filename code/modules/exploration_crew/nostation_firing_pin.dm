/obj/item/firing_pin/off_station
	name = "off-station firing pin"
	desc = "Allows the firing of weapons while not on the station."
	fail_message = span_warning("STATION SAFETY ENABLED.")
	pin_removeable = TRUE

/obj/item/firing_pin/off_station/pin_auth(mob/living/user)
	if(!istype(user))
		return FALSE
	var/turf/T = get_turf(user)
	if(!T)
		return FALSE
	if(is_station_level(T.z))
		return FALSE
	return TRUE
