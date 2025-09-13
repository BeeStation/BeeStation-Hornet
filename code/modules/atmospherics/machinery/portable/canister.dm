///The default pressure for releasing air into an holding tank or the turf
#define CAN_DEFAULT_RELEASE_PRESSURE (ONE_ATMOSPHERE)
///The temperature resistance of this canister
#define TEMPERATURE_RESISTANCE (1000 + T0C)

/obj/machinery/portable_atmospherics/canister
	name = "canister"
	desc = "A canister for the storage of gas."
	icon = 'icons/obj/atmospherics/canisters.dmi'
	icon_state = "#mapme"
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#ffff00#000000"
	density = TRUE
	volume = 2000
	armor_type = /datum/armor/portable_atmospherics_canister
	max_integrity = 300
	integrity_failure = 0.4
	pressure_resistance = 7 * ONE_ATMOSPHERE
	req_access = list()

	var/icon/canister_overlay_file = 'icons/obj/atmospherics/canisters.dmi'

	///Is the valve open?
	var/valve_open = FALSE
	///Used to log opening and closing of the valve, available on VV
	var/release_log = ""
	///How much the canister should be filled (recommended from 0 to 1)
	var/filled = 0.5
	///Maximum pressure allowed on initialize inside the canister, multiplied by the filled var
	var/maximum_pressure = 90 * ONE_ATMOSPHERE
	///Stores the path of the gas for mapped canisters
	var/datum/gas/gas_type
	///Player controlled var that set the release pressure of the canister
	var/release_pressure = ONE_ATMOSPHERE
	///Is shielding turned on/off
	var/shielding_powered = FALSE
	///The powercell used to enable shielding
	var/obj/item/stock_parts/cell/internal_cell
	///used while processing to update appearance only when its pressure state changes
	var/current_pressure_state

/datum/armor/portable_atmospherics_canister
	melee = 50
	bullet = 50
	laser = 50
	energy = 100
	bomb = 10
	rad = 100
	fire = 80
	acid = 50


/obj/machinery/portable_atmospherics/canister/Initialize(mapload, datum/gas_mixture/existing_mixture)
	. = ..()
	if(mapload)
		internal_cell = new /obj/item/stock_parts/cell/high(src)

	if(existing_mixture)
		air_contents.copy_from(existing_mixture)
	else
		create_gas()

	if(ispath(gas_type, /datum/gas))
		desc = "[GLOB.meta_gas_info[gas_type][META_GAS_NAME]]. [GLOB.meta_gas_info[gas_type][META_GAS_DESC]]"

	var/random_quality = rand()
	pressure_limit = initial(pressure_limit) * (1 + 0.2 * random_quality)

	update_icon()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/canister_valve))
	AddElement(/datum/element/atmos_sensitive, mapload)
	AddElement(/datum/element/volatile_gas_storage)
	AddComponent(/datum/component/gas_leaker, leak_rate=0.01)

/obj/machinery/portable_atmospherics/canister/examine(user)
	. = ..()
	if(atom_integrity < max_integrity)
		. += span_danger("Integrity compromised, repair hull with a welding tool.")
	. += span_notice("A sticker on its side says <b>MAX SAFE PRESSURE: [siunit_pressure(initial(pressure_limit), 0)]; MAX SAFE TEMPERATURE: [siunit(temp_limit, "K", 0)]</b>.")
	. += span_notice("The hull is <b>welded</b> together and can be cut apart.")
	if(internal_cell)
		. += span_notice("The internal cell has [internal_cell.percent()]% of its total charge.")
	else
		. += span_notice("Warning, no cell installed, use a screwdriver to open the hatch and insert one.")
	if(panel_open)
		. += span_notice("Hatch open, close it with a screwdriver.")

/obj/machinery/portable_atmospherics/canister/interact(mob/user)
	. = ..()
	if(!allowed(user))
		to_chat(user, span_warning("Error - Unauthorized User"))
		playsound(src, 'sound/misc/compiler-failure.ogg', 50, 1)
		return

/obj/machinery/portable_atmospherics/canister/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_CANISTER_GAS, "Modify Canister Gas")

/obj/machinery/portable_atmospherics/canister/vv_do_topic(href_list)
	. = ..()
	if(href_list[VV_HK_MODIFY_CANISTER_GAS])
		usr.client.modify_canister_gas(src)

CREATION_TEST_IGNORE_SUBTYPES(/obj/machinery/portable_atmospherics/canister)

/obj/machinery/portable_atmospherics/canister/Initialize(mapload, datum/gas_mixture/existing_mixture)
	. = ..()
	if(existing_mixture)
		air_contents.copy_from(existing_mixture)
	else
		create_gas()
	update_icon()

/obj/machinery/portable_atmospherics/canister/update_icon()
	. = ..()
	update_overlays()

/obj/machinery/portable_atmospherics/canister/update_overlays()
	. = ..()

	if(shielding_powered)
		. += mutable_appearance(canister_overlay_file, "shielding")
		. += emissive_appearance(canister_overlay_file, "shielding", layer)

	if(panel_open)
		. += mutable_appearance(canister_overlay_file, "cell_hatch")

	if(machine_stat & BROKEN)
		. += mutable_appearance(canister_overlay_file, "broken")
	if(holding)
		. += mutable_appearance(canister_overlay_file, "can-open")
	if(connected_port)
		. += mutable_appearance(canister_overlay_file, "can-connector")

	var/light_state = get_pressure_state()
	if(light_state) //happens when pressure is below 10kpa which means no light
		. += mutable_appearance(canister_overlay_file, light_state)
		. += emissive_appearance(canister_overlay_file, "[light_state]-light", layer, src.alpha)

/obj/machinery/portable_atmospherics/canister/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return (exposed_temperature > TEMPERATURE_RESISTANCE && !shielding_powered)

/obj/machinery/portable_atmospherics/canister/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(5, BURN, 0)

/obj/machinery/portable_atmospherics/canister/on_deconstruction(disassembled = TRUE)
	if(!(machine_stat & BROKEN))
		canister_break()
	if(!disassembled)
		new /obj/item/stack/sheet/iron (drop_location(), 5)
		qdel(src)
		return
	new /obj/item/stack/sheet/iron (drop_location(), 10)
	if(internal_cell)
		internal_cell.forceMove(drop_location())

/obj/machinery/portable_atmospherics/canister/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/active_cell = item
		if(!panel_open)
			balloon_alert(user, "open hatch first!")
			return TRUE
		if(!user.transferItemToLoc(active_cell, src))
			return TRUE
		if(internal_cell)
			user.put_in_hands(internal_cell)
			balloon_alert(user, "you replace the cell")
		else
			balloon_alert(user, "you install the cell")
		internal_cell = active_cell
		return TRUE
	return ..()

/obj/machinery/portable_atmospherics/canister/welder_act_secondary(mob/living/user, obj/item/I)
	. = ..()
	if(!I.tool_start_check(user, amount=1))
		return TRUE
	var/pressure = air_contents.return_pressure()
	if(pressure > 300)
		to_chat(user, "<span class='alert'>The pressure gauge on [src] indicates a high pressure inside... maybe you want to reconsider?</span>")
		message_admins("[src] deconstructed by [ADMIN_LOOKUPFLW(user)]")
		log_game("[src] deconstructed by [key_name(user)]")
	to_chat(user, "<span class='notice'>You begin cutting [src] apart...</span>")
	if(I.use_tool(src, user, 3 SECONDS, volume=50))
		to_chat(user, "<span class='notice'>You cut [src] apart.</span>")
		deconstruct(TRUE)
	return TRUE

/obj/machinery/portable_atmospherics/canister/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	if(user.combat_mode)
		return FALSE
	if(atom_integrity >= max_integrity)
		return TRUE
	if(machine_stat & BROKEN)
		return TRUE
	if(!tool.tool_start_check(user, amount=1))
		return TRUE
	to_chat(user, "<span class='notice'>You begin repairing cracks in [src]...</span>")
	while(tool.use_tool(src, user, 2.5 SECONDS, volume=40))
		atom_integrity = min(atom_integrity + 25, max_integrity)
		if(atom_integrity >= max_integrity)
			to_chat(user, "<span class='notice'>You've finished repairing [src].</span>")
			return TRUE
		to_chat(user, "<span class='notice'>You repair some of the cracks in [src]...</span>")
/obj/machinery/portable_atmospherics/canister/screwdriver_act(mob/living/user, obj/item/screwdriver)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, screwdriver))
		update_appearance()
		return TRUE

/obj/machinery/portable_atmospherics/canister/crowbar_act(mob/living/user, obj/item/tool)
	if(!panel_open || !internal_cell)
		return TRUE

	internal_cell.forceMove(drop_location())
	balloon_alert(user, "cell removed")
	return TRUE

/obj/machinery/portable_atmospherics/canister/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == internal_cell)
		internal_cell = null

/obj/machinery/portable_atmospherics/canister/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	. = ..()
	if(!. || QDELETED(src))
		return
	SSair.start_processing_machine(src)

/obj/machinery/portable_atmospherics/canister/atom_break(damage_flag)
	. = ..()
	if(!.)
		return
	canister_break()

/**
 * Handle canisters disassemble, releases the gas content in the turf
 */
/obj/machinery/portable_atmospherics/canister/proc/canister_break()
	disconnect()
	var/datum/gas_mixture/expelled_gas = air_contents.remove(air_contents.total_moles())
	var/turf/T = get_turf(src)
	T.assume_air(expelled_gas)

	atom_break()

	set_density(FALSE)
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

/obj/machinery/portable_atmospherics/canister/process(delta_time)
	if(!shielding_powered)
		return

	var/our_pressure = air_contents.return_pressure()
	var/our_temperature = air_contents.return_temperature()
	var/energy_factor = round(log(10, max(our_pressure - pressure_limit, 1)) + log(10, max(our_temperature - temp_limit, 1)))
	var/energy_consumed = energy_factor * 250 * delta_time

	if(!energy_consumed)
		return

	if(powered(AREA_USAGE_EQUIP))
		use_power(energy_consumed, AREA_USAGE_EQUIP)
	else if(!internal_cell?.use(energy_consumed * 0.025))
		shielding_powered = FALSE
		SSair.start_processing_machine(src)
		investigate_log("shielding turned off due to power loss")
		update_icon()

///return the icon_state component for the canister's indicator light based on its current pressure reading
/obj/machinery/portable_atmospherics/canister/proc/get_pressure_state()
	var/air_pressure = air_contents.return_pressure()
	switch(air_pressure)
		if((40 * ONE_ATMOSPHERE) to INFINITY)
			return "can-3"
		if((10 * ONE_ATMOSPHERE) to (40 * ONE_ATMOSPHERE))
			return "can-2"
		if((5 * ONE_ATMOSPHERE) to (10 * ONE_ATMOSPHERE))
			return "can-1"
		if((10) to (5 * ONE_ATMOSPHERE))
			return "can-0"
		else
			return null

/obj/machinery/portable_atmospherics/canister/process_atmos()
	if(machine_stat & BROKEN)
		return PROCESS_KILL

	// Handle gas transfer.
	if(valve_open)
		var/turf/location = get_turf(src)
		var/datum/gas_mixture/target_air = holding?.return_air() || location.return_air()
		excited = TRUE

		if(air_contents.release_gas_to(target_air, release_pressure))
			if(!holding)
				air_update_turf(FALSE, FALSE)

	// A bit different than other atmos devices. Wont stop if currently taking damage.
	if(take_atmos_damage())
		update_icon()
		excited = TRUE
		return ..() //we have already updated appearance so dont need to update again below

	var/new_pressure_state = get_pressure_state()
	if(current_pressure_state != new_pressure_state) //update apperance only when its pressure changes significantly from its current value
		update_icon()
		current_pressure_state = new_pressure_state

	return ..()

/obj/machinery/portable_atmospherics/canister/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/portable_atmospherics/canister/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Canister")
		ui.set_autoupdate(TRUE) // Canister pressure, tank pressure
		ui.open()

/obj/machinery/portable_atmospherics/canister/ui_static_data(mob/user)
	return list(
		"defaultReleasePressure" = round(CAN_DEFAULT_RELEASE_PRESSURE),
		"minReleasePressure" = round(CAN_MIN_RELEASE_PRESSURE),
		"maxReleasePressure" = round(CAN_MAX_RELEASE_PRESSURE),
		"pressureLimit" = round(pressure_limit),
		"holdingTankLeakPressure" = round(TANK_LEAK_PRESSURE),
		"holdingTankFragPressure" = round(TANK_FRAGMENT_PRESSURE)
	)

/obj/machinery/portable_atmospherics/canister/ui_data()
	var/data = list()
	data["portConnected"] = !!connected_port
	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(release_pressure)
	data["valveOpen"] = !!valve_open
	data["hasHoldingTank"] = !!holding
	if (holding)
		var/datum/gas_mixture/holding_mix = holding.return_air()
		data["holdingTank"] = list()
		data["holdingTank"]["name"] = holding.name
		data["holdingTank"]["tankPressure"] = round(holding_mix.return_pressure())

	data["shielding"] = shielding_powered
	data["cellCharge"] = internal_cell ? internal_cell.percent() : 0
	return data

/obj/machinery/portable_atmospherics/canister/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("relabel")
			var/label = tgui_input_list(usr, "New canister label", "Canister", GLOB.gas_id_to_canister)
			if(label && !..())
				var/newtype = GLOB.gas_id_to_canister[label]
				if(isnull(newtype))
					return
				var/obj/machinery/portable_atmospherics/canister/replacement = newtype
				investigate_log("was relabelled to [initial(replacement.name)] by [key_name(usr)].", INVESTIGATE_ATMOS)
				name = initial(replacement.name)
				desc = initial(replacement.desc)
				icon_state = initial(replacement.icon_state)
				set_greyscale(initial(replacement.greyscale_colors), initial(replacement.greyscale_config))
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "reset")
				pressure = CAN_DEFAULT_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "min")
				pressure = CAN_MIN_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "max")
				pressure = CAN_MAX_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "input")
				pressure = tgui_input_number(usr, message = "New release pressure", title = "Canister Pressure", default = release_pressure, max_value = CAN_MAX_RELEASE_PRESSURE, min_value = CAN_MIN_RELEASE_PRESSURE, round_value = FALSE)
				if(!isnull(pressure))
					. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				release_pressure = clamp(pressure, CAN_MIN_RELEASE_PRESSURE, CAN_MAX_RELEASE_PRESSURE)
				investigate_log("was set to [release_pressure] kPa by [key_name(usr)].", INVESTIGATE_ATMOS)
		if("valve")
			toggle_valve(usr)
			. = TRUE
		if("eject")
			if(eject_tank(usr))
				. = TRUE
		if("shielding")
			toggle_shielding(usr)
			. = TRUE
	ui_update()
	update_icon()

/obj/machinery/portable_atmospherics/canister/proc/toggle_valve(mob/user, wire_pulsed = FALSE)
	valve_open = !valve_open
	if(!valve_open)
		var/logmsg = "valve was <b>closed</b> by [key_name(user)] [wire_pulsed ? "via wire pulse" : ""], stopping the transfer into \the [holding || "air"].<br>"
		investigate_log(logmsg, INVESTIGATE_ATMOS)
		release_log += logmsg
		return

	SSair.start_processing_machine(src)
	if(holding)
		var/logmsg = "Valve was <b>opened</b> by [key_name(user)] [wire_pulsed ? "via wire pulse" : ""], starting a transfer into \the [holding || "air"].<br>"
		investigate_log(logmsg, INVESTIGATE_ATMOS)
		release_log += logmsg
		return

	// Go over the gases in canister, pull all their info and mark the spooky ones
	var/list/output = list()
	output += "[key_name(user)] <b>opened</b> a canister [wire_pulsed ? "via wire pulse" : ""] that contains the following:"
	var/list/admin_output = list()
	admin_output += "[ADMIN_LOOKUPFLW(user)] <b>opened</b> a canister [wire_pulsed ? "via wire pulse" : ""] that contains the following at [ADMIN_VERBOSEJMP(src)]:"
	var/list/gases = air_contents.gases
	var/danger = FALSE
	for(var/gas_index in 1 to length(gases))
		var/list/gas_info = gases[gases[gas_index]]
		var/list/meta = gas_info[GAS_META]
		var/name = meta[META_GAS_NAME]
		var/moles = gas_info[MOLES]

		output += "[name]: [moles] moles."
		if(gas_index <= 5) //the first five gases added
			admin_output += "[name]: [moles] moles."
		else if(gas_index == 6) // anddd the warning
			admin_output += "Too many gases to log. Check investigate log."
		//if moles_visible is undefined, default to default visibility
		if(meta[META_GAS_DANGER] && moles > (meta[META_GAS_MOLES_VISIBLE] || MOLES_GAS_VISIBLE))
			danger = TRUE

	if(danger) //sent to admin's chat if contains dangerous gases
		message_admins(admin_output.Join("\n"))
	var/logmsg = output.Join("\n")
	investigate_log(logmsg, INVESTIGATE_ATMOS)
	release_log += logmsg

/// Turns canister shielding on or off
/obj/machinery/portable_atmospherics/canister/proc/toggle_shielding(mob/user, wire_pulsed = FALSE)
	shielding_powered = !shielding_powered
	SSair.start_processing_machine(src)
	message_admins("[ADMIN_LOOKUPFLW(user)] turned [shielding_powered ? "on" : "off"] [wire_pulsed ? "via wire pulse" : ""] the [src] powered shielding.")
	user.investigate_log("turned [shielding_powered ? "on" : "off"] [wire_pulsed ? "via wire pulse" : ""] the [src] powered shielding.")
	update_icon()

/// Ejects tank from canister, if any
/obj/machinery/portable_atmospherics/canister/proc/eject_tank(mob/user, wire_pulsed = FALSE)
	if(!holding)
		return FALSE
	if(valve_open)
		message_admins("[ADMIN_LOOKUPFLW(user)] removed [holding] from [src] with valve still open [wire_pulsed ? "via wire pulse" : ""] at [ADMIN_VERBOSEJMP(src)] releasing contents into the [span_boldannounce("air")].")
		user.investigate_log("removed the [holding] [wire_pulsed ? "via wire pulse" : ""], leaving the valve open and transferring into the [span_boldannounce("air")].", INVESTIGATE_ATMOS)
	replace_tank(user, FALSE)
	return TRUE

/obj/machinery/portable_atmospherics/canister/unregister_holding()
	valve_open = FALSE
	return ..()

/obj/machinery/portable_atmospherics/canister/take_atmos_damage()
	return shielding_powered ? FALSE : ..()

//////////// Circuit stuffs! ///////////////////////////////////////////////////

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
			var/datum/gas_mixture/attached_can_air = attached_can.return_air()
			for(var/id in attached_can_air.gases)
				if(!(GLOB.meta_gas_info[id][META_GAS_DANGER]))
					continue
				if(attached_can_air.gases[id][MOLES] > (GLOB.meta_gas_info[id][META_GAS_MOLES_VISIBLE] || MOLES_GAS_VISIBLE)) //if moles_visible is undefined, default to default visibility
					danger[GLOB.meta_gas_info[id][META_GAS_NAME]] = attached_can_air.gases[id][MOLES] //ex. "plasma" = 20

			if(danger.len && attached_can.valve_open)
				message_admins("[parent.get_creator_admin()]'s circuit opened a canister that contains the following at [ADMIN_VERBOSEJMP(attached_can)]:")
				log_admin("[parent.get_creator_admin()]'s circuit opened a canister that contains the following at [AREACOORD(attached_can)]:")
				for(var/name in danger)
					var/msg = "[name]: [danger[name]] moles."
					log_admin(msg)
					message_admins(msg)
		attached_can.toggle_valve()
		attached_can.release_log += logmsg
	if(COMPONENT_TRIGGERED_BY(pressure, port))
		attached_can.release_pressure = clamp(round(pressure), CAN_MIN_RELEASE_PRESSURE, CAN_MAX_RELEASE_PRESSURE)
		investigate_log("[attached_can.name] was set to [pressure] kPa by [parent.get_creator()]'s circuit'.", INVESTIGATE_ATMOS)

///////////////////Canister Presets////////////////////////////////////

/obj/machinery/portable_atmospherics/canister/air
	name = "air canister"
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#c6c0b5"

/obj/machinery/portable_atmospherics/canister/bz
	name = "\improper BZ canister"
	gas_type = /datum/gas/bz
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#9b5d7f#d0d2a0"

/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "co2 canister"
	gas_type = /datum/gas/carbon_dioxide
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#4e4c48"

/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "n2 canister"
	gas_type = /datum/gas/nitrogen
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#d41010"

/obj/machinery/portable_atmospherics/canister/nitrous_oxide
	name = "n2o canister"
	gas_type = /datum/gas/nitrous_oxide
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#c63e3b#f7d5d3"

/obj/machinery/portable_atmospherics/canister/nitrium
	name = "Nitrium canister"
	gas_type = /datum/gas/nitrium
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#7b4732"

/obj/machinery/portable_atmospherics/canister/nob
	name = "hyper-noblium canister"
	gas_type = /datum/gas/hypernoblium
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#6399fc#b2b2b2"

/obj/machinery/portable_atmospherics/canister/oxygen
	name = "o2 canister"
	gas_type = /datum/gas/oxygen
	greyscale_config = /datum/greyscale_config/canister/stripe
	greyscale_colors = "#2786e5#e8fefe"

/obj/machinery/portable_atmospherics/canister/pluoxium
	name = "pluoxium canister"
	gas_type = /datum/gas/pluoxium
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#2786e5"

/obj/machinery/portable_atmospherics/canister/plasma
	name = "plasma canister"
	gas_type = /datum/gas/plasma
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#f64300#000000"

/obj/machinery/portable_atmospherics/canister/tritium
	name = "tritium canister"
	gas_type = /datum/gas/tritium
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#3fcd40#000000"

/obj/machinery/portable_atmospherics/canister/water_vapor
	name = "water vapor canister"
	gas_type = /datum/gas/water_vapor
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#4c4e4d#f7d5d3"

/obj/machinery/portable_atmospherics/canister/fusion_test
	name = "fusion test canister"
	temp_limit = 1e12
	pressure_limit = 1e14

/**
 * Called on Initialize(), fill the canister with the gas_type specified up to the filled level (half if 0.5, full if 1)
 * Used for canisters spawned in maps and by admins
 */
/obj/machinery/portable_atmospherics/canister/proc/create_gas()
	if(!gas_type)
		return
	air_contents.add_gas(gas_type)
	air_contents.gases[gas_type][MOLES] = (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	SSair.start_processing_machine(src)

/obj/machinery/portable_atmospherics/canister/air/create_gas()
	air_contents.add_gases(/datum/gas/oxygen, /datum/gas/nitrogen)
	air_contents.gases[/datum/gas/oxygen][MOLES] = (O2STANDARD * maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	air_contents.gases[/datum/gas/nitrogen][MOLES] = (N2STANDARD * maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	SSair.start_processing_machine(src)

/obj/machinery/portable_atmospherics/canister/fusion_test/create_gas()
	air_contents.add_gases(/datum/gas/carbon_dioxide, /datum/gas/tritium)
	air_contents.gases[/datum/gas/carbon_dioxide][MOLES] = 300
	air_contents.gases[/datum/gas/tritium][MOLES] = 300
	air_contents.temperature = 10000
	SSair.start_processing_machine(src)


#undef CAN_DEFAULT_RELEASE_PRESSURE
#undef TEMPERATURE_RESISTANCE
