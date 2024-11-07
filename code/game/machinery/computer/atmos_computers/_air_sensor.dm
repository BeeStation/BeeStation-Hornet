/// Gas tank air sensor.
/// These always hook to monitors, be mindful of them
/obj/machinery/air_sensor
	name = "gas sensor"
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "gsensor1"
	resistance_flags = FIRE_PROOF
	power_channel = AREA_USAGE_ENVIRON
	active_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 1.5
	var/on = TRUE

	/// The unique string that represents which atmos chamber to associate with.
	var/chamber_id

/obj/machinery/air_sensor/Initialize(mapload)
	id_tag = assign_random_name()
	return ..()

/obj/machinery/air_sensor/update_icon_state()
	icon_state = "gsensor[on]"
	return ..()
