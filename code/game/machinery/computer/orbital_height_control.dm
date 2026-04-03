/obj/machinery/computer/orbital_height_control
	name = "orbital height control console"
	desc = "A console used to monitor and control the station's orbital height and positioning systems."
	icon_screen = "comm_logs"
	icon_keyboard = "tech_key"
	circuit = /obj/item/circuitboard/computer/orbital_height_control
	light_color = LIGHT_COLOR_BLUE

	var/altitude_hold_enabled = TRUE
	var/altitude_hold_target = 110000  // in meters

	var/set_thrust = 0

/obj/machinery/computer/orbital_height_control/Initialize(mapload)
	. = ..()
	begin_processing()
	if(mapload)
		var/obj/item/sticker/sticky_note/orbital_tutorial/label = new(loc)
		label.afterattack(src, src, TRUE)
		label.pixel_y = rand(-8, 8)
		label.pixel_x = rand(-8, 8)

/obj/machinery/computer/orbital_height_control/process()
	if(altitude_hold_enabled)
		// Simple altitude hold logic
		if(SSorbital_altitude.orbital_altitude < altitude_hold_target)
			set_thrust = 20
		else if(SSorbital_altitude.orbital_altitude > altitude_hold_target + 500) // Add buffer to prevent oscillation
			set_thrust = -20
		else
			set_thrust = 0

	// Send thrust commands to all thrusters
	for(var/obj/machinery/atmospherics/components/unary/orbital_thruster/T in SSorbital_altitude.orbital_thrusters)
		if(!QDELETED(T))
			T.set_thrust(set_thrust)

/obj/machinery/computer/orbital_height_control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OrbitalHeightControl", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/orbital_height_control/ui_data(mob/user)
	var/list/data = list()

	// Fetch data from the orbital altitude subsystem
	data["current_altitude"] = SSorbital_altitude.orbital_altitude / 1000  // Convert meters to kilometers
	data["orbital_decay"] = SSorbital_altitude.decay_rate || 0
	data["orbital_velocity_index"] = SSorbital_altitude.velocity_index || 0

	// Calculate normalized atmospheric resistance (0-100%)
	var/resistance_normalized = clamp((1 - SSorbital_altitude.resistance) * 100 + rand(-10, 10), 0, 100)
	data["normalized_resistance"] = round(resistance_normalized, 0.1)

	data["thrust_level"] = set_thrust
	data["actual_thrust"] = SSorbital_altitude.thrust / 2 // It uses -40 to +40 range, we only want to display -20 to +20
	data["altitude_hold_enabled"] = altitude_hold_enabled || FALSE
	data["altitude_hold_target"] = altitude_hold_target || SSorbital_altitude.orbital_altitude

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

	// Thruster status data
	var/list/thrusters = list()
	for(var/obj/machinery/atmospherics/components/unary/orbital_thruster/T in SSorbital_altitude.orbital_thrusters)
		if(QDELETED(T))
			continue
		var/fuel_moles = 0
		if(T.fuel_buffer)
			ASSERT_GAS(/datum/gas/hydrogen_fuel, T.fuel_buffer)
			fuel_moles = T.fuel_buffer.gases[/datum/gas/hydrogen_fuel][MOLES]
		thrusters += list(list(
			"name" = T.name,
			"ref" = REF(T),
			"has_fuel" = T.has_fuel,
			"fuel_amount" = round(fuel_moles, 0.1),
			"fuel_target" = T.buffer_target,
			"thrust_level" = T.thrust_level,
			"requested_thrust" = T.requested_thrust,
		))
	data["thrusters"] = thrusters

	return data

/obj/machinery/computer/orbital_height_control/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("increase_thrust")
			// Increase thrust by 1, max 20
			set_thrust = clamp(set_thrust + 1, -20, 20)
			. = TRUE
		if("decrease_thrust")
			// Decrease thrust by 1, min -20
			set_thrust = clamp(set_thrust - 1, -20, 20)
			. = TRUE
		if("set_altitude_hold_target")
			// Set the target altitude for altitude hold system
			var/target = text2num(params["target"])
			if(isnull(target))
				return FALSE
			altitude_hold_target = clamp(target, 80000, 140000)  // 80km to 140km in meters
			. = TRUE
		if("toggle_altitude_hold")
			// Toggle altitude hold system on/off
			altitude_hold_enabled = !altitude_hold_enabled
			. = TRUE

	return TRUE

/obj/machinery/computer/orbital_height_control/ui_state(mob/user)
	return GLOB.default_state

/*
	We love these notes.
*/
/obj/item/sticker/sticky_note/orbital_tutorial
	custom_text = "To the captain or anyone operating this console: \n\n\
	The eggheads will tell you to 'Stay within orbital parameters', but won't say what those are beyond giving you some shitty placard. So I'll be nice, here's the deal:\n\
	\n\
	1. **Lots of rads**: 130-140 km\n\
	2. **Small rads**: 120-130 km\n\
	3. **Safe 100%**: 100-120 km\n\
	4. **Mining Regime**: 95-100 km\n\
	5. **Burn-up**: 80-95 km\n\
	\n\
	The further up you go, you'll edge into the radiation belts. Too low, and the atmosphere will start to eat at the station. Try to keep us in the Safe Zone as much as possible.\n\n\
	Gonna be honest with you here too, I reckon the station can probably handle dipping below 95km. It'll scratch the paint and give you a light show, but it should be fiiiine.\n\n\
	Ah another thing. See the thruster panel? **CHECK THAT RELIGIOUSLY.** You never know why the thrusters might not be giving you full power but you won't want to find out in-atmo.\n\n\
	- Engineer J."

// Roughly tell them what they're gonna get out of a can of fuel:
/obj/item/sticker/sticky_note/orbital_fuel_tutorial
	custom_text = "Quick heads up on this:\n\n\
	- One canister has 3750ish moles of fuel.\n\
	- Gonna last approximately 5 minutes of sustained thrust at full power.\n\
	- If you set it to cruise at 110km, it's gonna last you like 15 minutes.\n\
	- Can last a whole lot longer if you go higher, a whole lot shorter if you go lower.\n\
	Just remember, 5 min of full thrust, 15 min at 110km, and longer if you go higher. That should serve you well. There's a spare canister in engineering storage, they didn't know I put it in your budget, so be quiet about it yeah?\n\n\
	- Engineer J."
