#define CAN_DEFAULT_RELEASE_PRESSURE (ONE_ATMOSPHERE)

/obj/machinery/portable_atmospherics/canister
	name = "canister"
	desc = "A canister for the storage of gas."
	icon = 'icons/obj/atmospherics/canisters.dmi'
	icon_state = "#mapme"
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#ffff00#000000"
	density = TRUE
	volume = 1000
	armor = list(MELEE = 50,  BULLET = 50, LASER = 50, ENERGY = 100, BOMB = 10, BIO = 100, RAD = 100, FIRE = 80, ACID = 50, STAMINA = 0)
	max_integrity = 250
	integrity_failure = 0.4
	pressure_resistance = 7 * ONE_ATMOSPHERE
	req_access = list()

	var/icon/canister_overlay_file = 'icons/obj/atmospherics/canisters.dmi'

	var/valve_open = FALSE
	var/release_log = ""
	var/filled = 0.5
	var/gas_type
	var/release_pressure = ONE_ATMOSPHERE
	var/can_max_release_pressure = (ONE_ATMOSPHERE * 10)
	var/can_min_release_pressure = (ONE_ATMOSPHERE / 10)
	var/temperature_resistance = 1000 + T0C
	var/starter_temp = T20C
	// Prototype vars
	var/prototype = FALSE
	var/valve_timer = null
	var/timer_set = 30
	var/default_timer_set = 30
	var/minimum_timer_set = 1
	var/maximum_timer_set = 300
	var/timing = FALSE
	var/restricted = FALSE

	var/update = 0
	var/static/list/label2types = list(
		"n2" = /obj/machinery/portable_atmospherics/canister/nitrogen,
		"o2" = /obj/machinery/portable_atmospherics/canister/oxygen,
		"co2" = /obj/machinery/portable_atmospherics/canister/carbon_dioxide,
		"plasma" = /obj/machinery/portable_atmospherics/canister/plasma,
		"n2o" = /obj/machinery/portable_atmospherics/canister/nitrous_oxide,
		"no2" = /obj/machinery/portable_atmospherics/canister/nitryl,
		"bz" = /obj/machinery/portable_atmospherics/canister/bz,
		"air" = /obj/machinery/portable_atmospherics/canister/air,
		"water vapor" = /obj/machinery/portable_atmospherics/canister/water_vapor,
		"tritium" = /obj/machinery/portable_atmospherics/canister/tritium,
		"hyper-noblium" = /obj/machinery/portable_atmospherics/canister/nob,
		"stimulum" = /obj/machinery/portable_atmospherics/canister/stimulum,
		"pluoxium" = /obj/machinery/portable_atmospherics/canister/pluoxium,
		"caution" = /obj/machinery/portable_atmospherics/canister,
	)

/obj/machinery/portable_atmospherics/canister/Initialize()
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/canister_valve))

/obj/item/circuit_component/canister_valve
	display_name = "Canister Valve"
	desc = "The interface for communicating with a canister's valve."

	var/obj/machinery/portable_atmospherics/canister/attached_can

	/// Toggles the canister's valve
	var/datum/port/input/toggle
	/// Set's the can's target pressure value
	var/datum/port/input/pressure

/obj/item/circuit_component/canister_valve/populate_ports()
	toggle = add_input_port("Toggle", PORT_TYPE_SIGNAL)
	pressure = add_input_port("Target Pressure", PORT_TYPE_NUMBER)

/obj/item/circuit_component/canister_valve/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/portable_atmospherics/canister))
		attached_can = shell

/obj/item/circuit_component/canister_valve/unregister_usb_parent(atom/movable/shell)
	attached_can = null
	return ..()

/obj/item/circuit_component/canister_valve/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	if(!attached_can)
		return

	var/logmsg

	if(COMPONENT_TRIGGERED_BY(toggle, port))
		logmsg = "Valve was <b>toggled</b> by [parent.get_creator_admin()]'s circuit, starting a transfer into \the [attached_can.holding || "air"].<br>"
		if(!attached_can.holding)
			var/list/danger = list()
			for(var/id in attached_can.air_contents.get_gases())
				if(!(GLOB.gas_data.flags[id] & GAS_FLAG_DANGEROUS))
					continue
				if(attached_can.air_contents.get_moles(id) > (GLOB.gas_data.visibility[id] || MOLES_GAS_VISIBLE)) //if moles_visible is undefined, default to default visibility
					danger[GLOB.gas_data.names[id]] = attached_can.air_contents.get_moles(id) //ex. "plasma" = 20

			if(danger.len && attached_can.valve_open)
				message_admins("[parent.get_creator_admin()]'s circuit opened a canister that contains the following at [ADMIN_VERBOSEJMP(attached_can)]:")
				log_admin("[parent.get_creator_admin()]'s circuit opened a canister that contains the following at [AREACOORD(attached_can)]:")
				for(var/name in danger)
					var/msg = "[name]: [danger[name]] moles."
					log_admin(msg)
					message_admins(msg)
		attached_can.set_valve()
		attached_can.release_log += logmsg
	if(COMPONENT_TRIGGERED_BY(pressure, port))
		attached_can.release_pressure = clamp(round(pressure), attached_can.can_min_release_pressure, attached_can.can_max_release_pressure)
		investigate_log("[attached_can.name] was set to [pressure] kPa by [parent.get_creator()]'s circuit'.", INVESTIGATE_ATMOS)

/obj/machinery/portable_atmospherics/canister/interact(mob/user)
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Error - Unauthorized User</span>")
		playsound(src, 'sound/misc/compiler-failure.ogg', 50, 1)
		return
	..()

/obj/machinery/portable_atmospherics/canister/air
	name = "air canister"
	desc = "Pre-mixed air."
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#c6c0b5"

/obj/machinery/portable_atmospherics/canister/bz
	name = "\improper BZ canister"
	desc = "BZ, a powerful hallucinogenic nerve agent."
	gas_type = GAS_BZ
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#9b5d7f#d0d2a0"

/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "co2 canister"
	desc = "Carbon dioxide. What the fuck is carbon dioxide?"
	gas_type = GAS_CO2
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#4e4c48"

/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "n2 canister"
	desc = "Nitrogen gas. Reportedly useful for something."
	gas_type = GAS_N2
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#d41010"

/obj/machinery/portable_atmospherics/canister/nitrous_oxide
	name = "n2o canister"
	desc = "Nitrous oxide gas. Known to cause drowsiness."
	gas_type = GAS_NITROUS
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#c63e3b#f7d5d3"

/obj/machinery/portable_atmospherics/canister/nitryl
	name = "nitryl canister"
	desc = "Nitryl gas. Feels great 'til the acid eats your lungs."
	gas_type = GAS_NITRYL
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#7b4732"

/obj/machinery/portable_atmospherics/canister/nob
	name = "hyper-noblium canister"
	desc = "Hyper-Noblium. More noble than all other gases."
	gas_type = GAS_HYPERNOB
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#6399fc#b2b2b2"

/obj/machinery/portable_atmospherics/canister/oxygen
	name = "o2 canister"
	desc = "Oxygen. Necessary for human life."
	gas_type = GAS_O2
	greyscale_config = /datum/greyscale_config/canister/stripe
	greyscale_colors = "#2786e5#e8fefe"

/obj/machinery/portable_atmospherics/canister/pluoxium
	name = "pluoxium canister"
	desc = "Pluoxium. Like oxygen, but more bang for your buck."
	gas_type = GAS_PLUOXIUM
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#2786e5"

/obj/machinery/portable_atmospherics/canister/stimulum
	name = "stimulum canister"
	desc = "Stimulum. High energy gas, high energy people."
	gas_type = GAS_STIMULUM
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#9b5d7f"

/obj/machinery/portable_atmospherics/canister/plasma
	name = "plasma canister"
	desc = "Plasma gas. The reason YOU are here. Highly toxic."
	gas_type = GAS_PLASMA
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#f64300#000000"

/obj/machinery/portable_atmospherics/canister/tritium
	name = "tritium canister"
	desc = "Tritium. Inhalation might cause irradiation."
	gas_type = GAS_TRITIUM
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#3fcd40#000000"

/obj/machinery/portable_atmospherics/canister/water_vapor
	name = "water vapor canister"
	desc = "Water Vapor. We get it, you vape."
	gas_type = GAS_H2O
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#4c4e4d#f7d5d3"


/obj/machinery/portable_atmospherics/canister/proc/get_time_left()
	if(timing)
		. = round(max(0, valve_timer - world.time) / 10, 1)
	else
		. = timer_set

/obj/machinery/portable_atmospherics/canister/proc/set_active()
	timing = !timing
	if(timing)
		valve_timer = world.time + (timer_set * 10)
	update_icon()

/obj/machinery/portable_atmospherics/canister/proto
	name = "prototype canister"
	greyscale_config = /datum/greyscale_config/prototype_canister
	greyscale_colors = "#ffffff#a50021#ffffff"

/obj/machinery/portable_atmospherics/canister/proto/default
	name = "prototype canister"
	desc = "The best way to fix an atmospheric emergency... or the best way to introduce one."
	volume = 5000
	max_integrity = 300
	temperature_resistance = 2000 + T0C
	can_max_release_pressure = (ONE_ATMOSPHERE * 30)
	can_min_release_pressure = (ONE_ATMOSPHERE / 30)
	prototype = TRUE

/obj/machinery/portable_atmospherics/canister/proto/default/oxygen
	name = "prototype canister"
	desc = "A prototype canister for a prototype bike, what could go wrong?"
	gas_type = GAS_O2
	filled = 1
	release_pressure = ONE_ATMOSPHERE*2

/obj/machinery/portable_atmospherics/canister/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_CANISTER_GAS, "Modify Canister Gas")

/obj/machinery/portable_atmospherics/canister/vv_do_topic(href_list)
	. = ..()
	if(href_list[VV_HK_MODIFY_CANISTER_GAS])
		usr.client.modify_canister_gas(src)

/obj/machinery/portable_atmospherics/canister/Initialize(mapload, datum/gas_mixture/existing_mixture)
	. = ..()
	if(existing_mixture)
		air_contents.copy_from(existing_mixture)
	else
		create_gas()
	update_icon()


/obj/machinery/portable_atmospherics/canister/proc/create_gas()
	if(gas_type)
		if(starter_temp)
			air_contents.set_temperature(starter_temp)
		if(!air_contents.return_volume())
			CRASH("Auxtools is failing somehow! Gas with pointer [air_contents._extools_pointer_gasmixture] is not valid.")
		air_contents.set_moles(gas_type, (maximum_pressure * filled) * air_contents.return_volume() / (R_IDEAL_GAS_EQUATION * air_contents.return_temperature()))

/obj/machinery/portable_atmospherics/canister/air/create_gas()
	air_contents.set_temperature(starter_temp)
	air_contents.set_moles(GAS_O2, (O2STANDARD * maximum_pressure * filled) * air_contents.return_volume() / (R_IDEAL_GAS_EQUATION * air_contents.return_temperature()))
	air_contents.set_moles(GAS_N2, (N2STANDARD * maximum_pressure * filled) * air_contents.return_volume() / (R_IDEAL_GAS_EQUATION * air_contents.return_temperature()))

/obj/machinery/portable_atmospherics/canister/update_icon()
	. = ..()
	update_overlays()

/obj/machinery/portable_atmospherics/canister/update_overlays()
	. = ..()
	if(machine_stat & BROKEN)
		. += mutable_appearance(canister_overlay_file, "broken")
		return

	var/last_update = update
	update = 0

	if(holding)
		. += mutable_appearance(canister_overlay_file, "can-open")
	if(connected_port)
		. += mutable_appearance(canister_overlay_file, "can-connector")
	var/pressure = air_contents.return_pressure()
	switch(pressure)
		if((40 * ONE_ATMOSPHERE) to INFINITY)
			. += mutable_appearance(canister_overlay_file, "can-3")
		if((10 * ONE_ATMOSPHERE) to (40 * ONE_ATMOSPHERE))
			. += mutable_appearance(canister_overlay_file, "can-2")
		if((5 * ONE_ATMOSPHERE) to (10 * ONE_ATMOSPHERE))
			. += mutable_appearance(canister_overlay_file, "can-1")
		if((10) to (5 * ONE_ATMOSPHERE))
			. += mutable_appearance(canister_overlay_file, "can-0")

	if(update == last_update)
		return

/obj/machinery/portable_atmospherics/canister/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > temperature_resistance)
		take_damage(5, BURN, 0)


/obj/machinery/portable_atmospherics/canister/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!(machine_stat & BROKEN))
			canister_break()
		if(disassembled)
			new /obj/item/stack/sheet/iron (loc, 10)
		else
			new /obj/item/stack/sheet/iron (loc, 5)
	qdel(src)

/obj/machinery/portable_atmospherics/canister/welder_act(mob/living/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return FALSE

	if(machine_stat & BROKEN)
		if(!I.tool_start_check(user, amount=0))
			return TRUE
		to_chat(user, "<span class='notice'>You begin cutting [src] apart...</span>")
		if(I.use_tool(src, user, 30, volume=50))
			deconstruct(TRUE)
	else
		to_chat(user, "<span class='notice'>You cannot slice [src] apart when it isn't broken.</span>")

	return TRUE

/obj/machinery/portable_atmospherics/canister/obj_break(damage_flag)
	. = ..()
	if(!.)
		return
	canister_break()

/obj/machinery/portable_atmospherics/canister/proc/canister_break()
	disconnect()
	var/turf/T = get_turf(src)
	T.assume_air(air_contents)
	air_update_turf()

	set_machine_stat(machine_stat | BROKEN)
	density = FALSE
	playsound(src.loc, 'sound/effects/spray.ogg', 10, 1, -3)
	update_icon()
	investigate_log("was destroyed.", INVESTIGATE_ATMOS)

	if(holding)
		holding.forceMove(T)
		holding = null

	animate(src, 0.5 SECONDS, transform=turn(transform, rand(-179, 180)), easing=BOUNCE_EASING)

/obj/machinery/portable_atmospherics/canister/replace_tank(mob/living/user, close_valve)
	. = ..()
	if(!.)
		return
	if(close_valve)
		valve_open = FALSE
		update_icon()
		investigate_log("Valve was <b>closed</b> by [key_name(user)].", INVESTIGATE_ATMOS)
	else if(valve_open && holding)
		user.investigate_log("started a transfer into [holding].", INVESTIGATE_ATMOS)

/obj/machinery/portable_atmospherics/canister/process_atmos()
	..()
	if(machine_stat & BROKEN)
		return PROCESS_KILL
	if(timing && valve_timer < world.time)
		valve_open = !valve_open
		timing = FALSE

	// Handle gas transfer.
	if(valve_open)
		var/turf/T = get_turf(src)
		var/datum/gas_mixture/target_air = holding ? holding.air_contents : T.return_air()

		if(air_contents.release_gas_to(target_air, release_pressure) && !holding)
			air_update_turf()
	update_icon()

/obj/machinery/portable_atmospherics/canister/ui_status(mob/user)
	. = ..()
	if(. > UI_UPDATE && !allowed(user))
		. = UI_UPDATE

/obj/machinery/portable_atmospherics/canister/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/portable_atmospherics/canister/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Canister")
		ui.open()
		ui.set_autoupdate(TRUE) // Canister pressure, tank pressure, prototype canister timer

/obj/machinery/portable_atmospherics/canister/ui_data()
	var/data = list()
	data["portConnected"] = connected_port ? 1 : 0
	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(release_pressure ? release_pressure : 0)
	data["defaultReleasePressure"] = round(CAN_DEFAULT_RELEASE_PRESSURE)
	data["minReleasePressure"] = round(can_min_release_pressure)
	data["maxReleasePressure"] = round(can_max_release_pressure)
	data["valveOpen"] = valve_open ? 1 : 0

	data["isPrototype"] = prototype ? 1 : 0
	if (prototype)
		data["restricted"] = restricted
		data["timing"] = timing
		data["time_left"] = get_time_left()
		data["timer_set"] = timer_set
		data["timer_is_not_default"] = timer_set != default_timer_set
		data["timer_is_not_min"] = timer_set != minimum_timer_set
		data["timer_is_not_max"] = timer_set != maximum_timer_set

	data["hasHoldingTank"] = holding ? 1 : 0
	if (holding)
		data["holdingTank"] = list()
		data["holdingTank"]["name"] = holding.name
		data["holdingTank"]["tankPressure"] = round(holding.air_contents.return_pressure())
	return data

/obj/machinery/portable_atmospherics/canister/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("relabel")
			var/label = input("New canister label:", name) as null|anything in sort_list(label2types)
			if(label && !..())
				var/newtype = label2types[label]
				if(newtype)
					var/obj/machinery/portable_atmospherics/canister/replacement = newtype
					name = initial(replacement.name)
					desc = initial(replacement.desc)
					icon_state = initial(replacement.icon_state)
					set_greyscale(initial(replacement.greyscale_colors), initial(replacement.greyscale_config))
		if("restricted")
			if(!prototype)
				return // Prototype canister only feature
			restricted = !restricted
			if(restricted)
				req_access = list(ACCESS_ENGINE)
			else
				req_access = list()
			. = TRUE
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "reset")
				pressure = CAN_DEFAULT_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "min")
				pressure = can_min_release_pressure
				. = TRUE
			else if(pressure == "max")
				pressure = can_max_release_pressure
				. = TRUE
			else if(pressure == "input")
				pressure = input("New release pressure ([can_min_release_pressure]-[can_max_release_pressure] kPa):", name, release_pressure) as num|null
				if(!isnull(pressure) && !..())
					. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				release_pressure = clamp(round(pressure), can_min_release_pressure, can_max_release_pressure)
				investigate_log("was set to [release_pressure] kPa by [key_name(usr)].", INVESTIGATE_ATMOS)
		if("valve")
			set_valve(usr)
			. = TRUE
		/* // Apparently the timer isn't present in TGUI - commenting out so it can't be used via exploits
		if("timer")
			if(!prototype)
				return
			var/change = params["change"]
			switch(change)
				if("reset")
					timer_set = default_timer_set
					. = TRUE
				if("decrease")
					timer_set = max(minimum_timer_set, timer_set - 10)
					. = TRUE
				if("increase")
					timer_set = min(maximum_timer_set, timer_set + 10)
					. = TRUE
				if("input")
					var/user_input = input(usr, "Set time to valve toggle.", name) as null|num
					if(!user_input)
						return
					var/N = text2num(user_input)
					if(!N)
						return
					timer_set = clamp(N,minimum_timer_set,maximum_timer_set)
					log_admin("[key_name(usr)] has activated a prototype valve timer")
					. = TRUE
				if("toggle_timer")
					set_active()
					. = TRUE
		*/
		if("eject")
			if(holding)
				if(valve_open)
					message_admins("[ADMIN_LOOKUPFLW(usr)] removed [holding] from [src] with valve still open at [ADMIN_VERBOSEJMP(src)] releasing contents into the <span class='boldannounce'>air</span>.")
					usr.investigate_log(" removed the [holding], leaving the valve open and transferring into the <span class='boldannounce'>air</span>.", INVESTIGATE_ATMOS)
				replace_tank(usr, FALSE)
				. = TRUE
	update_icon()

/obj/machinery/portable_atmospherics/canister/proc/set_valve(mob/user)
	var/logmsg
	valve_open = !valve_open
	if(valve_open)
		SEND_SIGNAL(src, COMSIG_VALVE_SET_OPEN, TRUE)
		if(user)
			logmsg = "Valve was <b>opened</b> by [key_name(user)], starting a transfer into \the [holding || "air"].<br>"
		if(!holding)
			var/list/danger = list()
			for(var/id in air_contents.get_gases())
				if(!(GLOB.gas_data.flags[id] & GAS_FLAG_DANGEROUS))
					continue
				if(air_contents.get_moles(id) > (GLOB.gas_data.visibility[id] || MOLES_GAS_VISIBLE)) //if moles_visible is undefined, default to default visibility
					danger[GLOB.gas_data.names[id]] = air_contents.get_moles(id) //ex. "plasma" = 20

			if(danger.len && user)
				message_admins("[ADMIN_LOOKUPFLW(user)] opened a canister that contains the following at [ADMIN_VERBOSEJMP(src)]:")
				log_admin("[key_name(user)] opened a canister that contains the following at [AREACOORD(src)]:")
				for(var/name in danger)
					var/msg = "[name]: [danger[name]] moles."
					log_admin(msg)
					message_admins(msg)
	else
		SEND_SIGNAL(src, COMSIG_VALVE_SET_OPEN, FALSE)
		if(user)
			logmsg = "Valve was <b>closed</b> by [key_name(user)], stopping the transfer into \the [holding || "air"].<br>"
	investigate_log(logmsg, INVESTIGATE_ATMOS)
	release_log += logmsg
