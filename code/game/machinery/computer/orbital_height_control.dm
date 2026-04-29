/obj/machinery/computer/orbital_height_control
	name = "orbital height control console"
	desc = "A console used to monitor and control the station's orbital height and positioning systems."
	icon_screen = "comm_logs"
	icon_keyboard = "tech_key"
	circuit = /obj/item/circuitboard/computer/orbital_height_control
	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/orbital_height_control/Initialize(mapload)
	. = ..()
	if(mapload)
		var/obj/item/sticker/sticky_note/orbital_tutorial/label = new(loc)
		label.afterattack(src, src, TRUE)
		label.pixel_y = rand(-8, 8)
		label.pixel_x = rand(-8, 8)

/obj/machinery/computer/orbital_height_control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OrbitalHeightControl", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/orbital_height_control/ui_static_data(mob/user)
	var/list/data = list()

	// Define orbital bands for visualization (these are constant)
	var/list/orbital_bands = list()
	orbital_bands += list(list(
		"name" = "High Critical",
		"max_altitude" = 140,
		"min_altitude" = 130,
		"color" = "#B22222"
	))
	orbital_bands += list(list(
		"name" = "High Warning",
		"max_altitude" = ORBITAL_ALTITUDE_UPPER_CRITICAL / 1000,
		"min_altitude" = ORBITAL_ALTITUDE_UPPER / 1000,
		"color" = "#DAA520"
	))
	orbital_bands += list(list(
		"name" = "Safe Zone",
		"max_altitude" = ORBITAL_ALTITUDE_UPPER / 1000,
		"min_altitude" = (ORBITAL_ALTITUDE_LOWER + 10000) / 1000,
		"color" = "#3CB371"
	))
	orbital_bands += list(list(
		"name" = "Mining Regime",
		"max_altitude" = (ORBITAL_ALTITUDE_LOWER + 10000) / 1000,
		"min_altitude" = ORBITAL_ALTITUDE_LOWER / 1000,
		"color" = "#D7A44A",
		"is_mining_regime" = TRUE
	))
	orbital_bands += list(list(
		"name" = "Critical",
		"max_altitude" = ORBITAL_ALTITUDE_LOWER / 1000,
		"min_altitude" = 0,
		"color" = "#8B0000"
	))
	data["orbital_bands"] = orbital_bands

	return data

/obj/machinery/computer/orbital_height_control/ui_data(mob/user)
	var/list/data = list()

	// Fetch data from the orbital altitude subsystem
	data["current_altitude"] = SSorbital_altitude.orbital_altitude / 1000  // Convert meters to kilometers
	data["orbital_decay"] = SSorbital_altitude.decay_rate || 0
	data["orbital_velocity_index"] = SSorbital_altitude.velocity_index || 0

	// Calculate normalized atmospheric resistance (0-100%)
	var/resistance_normalized = clamp((1 - SSorbital_altitude.resistance) * 100 + rand(-10, 10), 0, 100)
	data["normalized_resistance"] = round(resistance_normalized, 0.1)

	data["thrust_level"] = SSorbital_altitude.console_set_thrust
	data["actual_thrust"] = SSorbital_altitude.thrust / 2 // It uses -40 to +40 range, we only want to display -20 to +20
	data["altitude_hold_enabled"] = SSorbital_altitude.altitude_hold_enabled || FALSE
	data["altitude_hold_target"] = SSorbital_altitude.altitude_hold_target || SSorbital_altitude.orbital_altitude

	// Thruster status data
	var/list/thrusters = list()
	for(var/obj/machinery/atmospherics/components/unary/orbital_thruster/thruster in SSorbital_altitude.orbital_thrusters)
		if(QDELETED(thruster))
			continue
		var/fuel_moles = 0
		if(thruster.fuel_buffer)
			ASSERT_GAS(/datum/gas/hydrogen_fuel, thruster.fuel_buffer)
			fuel_moles = thruster.fuel_buffer.gases[/datum/gas/hydrogen_fuel][MOLES]
		thrusters += list(list(
			"name" = thruster.name,
			"ref" = REF(thruster),
			"has_fuel" = thruster.has_fuel,
			"fuel_amount" = round(fuel_moles, 0.1),
			"fuel_target" = thruster.buffer_target,
			"thrust_level" = thruster.thrust_level,
			"requested_thrust" = thruster.requested_thrust,
			"fuel_fault" = thruster.fuel_fault,
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
			SSorbital_altitude.console_set_thrust = clamp(SSorbital_altitude.console_set_thrust + 1, -20, 20)
			. = TRUE
		if("decrease_thrust")
			// Decrease thrust by 1, min -20
			SSorbital_altitude.console_set_thrust = clamp(SSorbital_altitude.console_set_thrust - 1, -20, 20)
			. = TRUE
		if("set_altitude_hold_target")
			// Set the target altitude for altitude hold system
			var/target = text2num(params["target"])
			if(isnull(target))
				return FALSE
			SSorbital_altitude.altitude_hold_target = clamp(target, 80000, 140000)  // 80km to 140km in meters
			. = TRUE
		if("toggle_altitude_hold")
			// Toggle altitude hold system on/off
			SSorbital_altitude.altitude_hold_enabled = !SSorbital_altitude.altitude_hold_enabled
			. = TRUE

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
	custom_text = "Heads up on the fuel system: \n\n\
	**How it works:** Don't leave canisters by the port. Empty them into the station fuel tank (atmos, near this console). The console reads a sensor INSIDE that tank, and the thrusters sip from its pipes. The tank is 3 tiles, so the reading is about a THIRD of what you poured in, that's normal.\n\n\
	**Fuel use:** One canister = ~5 minutes at FULL burn on the standard 3-thruster setup. But thrust level matters a LOT. On altitude hold around **110 km** a single can easily lasts **15+ minutes**. Higher up (120+ km) it lasts even longer. \n\n\
	Don't sit on full throttle unless you're climbing. Hint: Altitude hold is stupid and sits on full throttle. A skilled helmsman can fine tune thrust to decay, and run insanely lean.\n\n\
	**Targets on the console:** \n\
	- Cruising: keep it above **1000 mol**. Just in case something happens. On altitude hold at 110km, the second the reading hits 1000, you have about 10 minutes before you lose thrusters.\n\
	- Mining or planning a big climb: Get above **4000 mol** first. Climbing out of mining can burn 15 minutes of full thrust, and running dry mid-ascent ends badly.\n\n\n\
	- Engineer J."
