/obj/machinery/computer/orbital_height_control
	name = "orbital height control console"
	desc = "A console used to monitor and control the station's orbital height and positioning systems."
	icon_screen = "comm_logs"
	icon_keyboard = "tech_key"
	circuit = /obj/item/circuitboard/computer/orbital_height_control
	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/orbital_height_control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OrbitalHeightControl", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/orbital_height_control/ui_data(mob/user)
	var/list/data = list()

	// Fetch data from the orbital altitude subsystem
	data["orbiting_body"] = "Cinis (Auri-Gemina I)"
	data["current_altitude"] = SSorbital_altitude.orbital_altitude / 1000  // Convert meters to kilometers
	data["orbital_decay"] = SSorbital_altitude.decay_rate || 0
	data["orbital_velocity_index"] = SSorbital_altitude.velocity_index || 0

	// Calculate normalized atmospheric resistance (0-100%)
	var/resistance_normalized = clamp((1 - SSorbital_altitude.resistance) * 100, 0, 100)
	data["normalized_resistance"] = resistance_normalized

	data["thrust_level"] = SSorbital_altitude.thrust || 0

	// Define orbital bands for visualization
	var/list/orbital_bands = list()
	orbital_bands += list(list(
		"name" = "High Critical",
		"max_altitude" = 140,
		"min_altitude" = 130,
		"color" = "#B22222"
	))
	orbital_bands += list(list(
		"name" = "High Warning",
		"max_altitude" = ORBITAL_ALTITUDE_HIGH_CRITICAL / 1000,
		"min_altitude" = ORBITAL_ALTITUDE_HIGH / 1000,
		"color" = "#DAA520"
	))
	orbital_bands += list(list(
		"name" = "Safe Zone",
		"max_altitude" = ORBITAL_ALTITUDE_HIGH / 1000,
		"min_altitude" = (ORBITAL_ALTITUDE_LOW + 10000) / 1000,
		"color" = "#3CB371"
	))
	orbital_bands += list(list(
		"name" = "Mining Regime",
		"max_altitude" = (ORBITAL_ALTITUDE_LOW + 10000) / 1000,
		"min_altitude" = ORBITAL_ALTITUDE_LOW / 1000,
		"color" = "#D7A44A",
		"is_mining_regime" = TRUE
	))
	orbital_bands += list(list(
		"name" = "Critical",
		"max_altitude" = ORBITAL_ALTITUDE_LOW / 1000,
		"min_altitude" = 0,
		"color" = "#8B0000"
	))
	data["orbital_bands"] = orbital_bands

	return data

/obj/machinery/computer/orbital_height_control/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("increase_thrust")
			// Increase thrust by 1, max 30
			SSorbital_altitude.thrust = clamp(SSorbital_altitude.thrust + 1, 0, 30)
			. = TRUE
		if("decrease_thrust")
			// Decrease thrust by 1, min 0
			SSorbital_altitude.thrust = clamp(SSorbital_altitude.thrust - 1, 0, 30)
			. = TRUE

	return TRUE

/obj/machinery/computer/orbital_height_control/ui_state(mob/user)
	return GLOB.default_state
