#define HEATER_MODE_STANDBY "standby"
#define HEATER_MODE_HEAT "heat"
#define HEATER_MODE_COOL "cool"
#define HEATER_MODE_AUTO "auto"

/obj/machinery/portable_thermomachine
	anchored = FALSE
	density = TRUE
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN
	icon = 'icons/obj/atmos.dmi'
	icon_state = "pthermomachine-off"
	base_icon_state = "pthermomachine"
	name = "portable thermomachine"
	desc = "Made by Space Amish using traditional space techniques, this thermomachine is guaranteed not to set the station on fire. Warranty void if used in engines."
	max_integrity = 250
	armor_type = /datum/armor/machinery_portable_thermomachine
	circuit = /obj/item/circuitboard/machine/portable_thermomachine
	//We don't use area power, we always use the cell
	use_power = NO_POWER_USE

	///The cell we spawn with
	var/obj/item/stock_parts/cell/cell = null
	///Is the machine on?
	var/on = FALSE
	///What is the mode we are in now?
	var/mode = HEATER_MODE_STANDBY
	///Anything other than "heat" or "cool" is considered auto.
	var/set_mode = HEATER_MODE_AUTO
	///The temperature we trying to get to
	var/target_temperature = T20C
	///How much heat/cold we can deliver
	var/heating_power = 40000
	///How efficiently we can deliver that heat/cold (higher indicates less cell consumption)
	var/efficiency = 20000
	///The amount of degrees above and below the target temperature for us to change mode to heater or cooler
	var/temperature_tolerance = 1
	///What's the middle point of our settable temperature (30 °C)
	var/settable_temperature_median = 30 + T0C
	///Range of temperatures above and below the median that we can set our target temperature (increase by upgrading the capacitors)
	var/settable_temperature_range = 30
	///Should we add an overlay for open portable thermomachines
	var/display_panel = TRUE


/datum/armor/machinery_portable_thermomachine
	rad = 100
	fire = 80
	acid = 10

/obj/machinery/portable_thermomachine/get_cell()
	return cell

/obj/machinery/portable_thermomachine/Initialize(mapload)
	. = ..()
	update_appearance()
	SSair.start_processing_machine(src)

/obj/machinery/portable_thermomachine/Destroy()
	SSair.stop_processing_machine(src)
	return..()

/obj/machinery/portable_thermomachine/on_deconstruction()
	return ..()

/obj/machinery/portable_thermomachine/examine(mob/user)
	. = ..()
	. += "\The [src] is [on ? "on" : "off"], and the hatch is [panel_open ? "open" : "closed"]."
	if(cell)
		. += "The charge meter reads [cell ? round(cell.percent(), 1) : 0]%."
	else
		. += "There is no power cell installed."
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Temperature range at <b>[settable_temperature_range]°C</b>.<br>Heating power at <b>[siunit(heating_power, "W", 1)]</b>.<br>Power consumption at <b>[(efficiency*-0.0025)+150]%</b>.") //100%, 75%, 50%, 25%
		. += "<span class='notice'><b>Right-click</b> to toggle [on ? "off" : "on"].</span>"

/obj/machinery/portable_thermomachine/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[on ? mode : "off"]"

/obj/machinery/portable_thermomachine/update_overlays()
	. = ..()
	if(panel_open && display_panel)
		. += "[base_icon_state]-open"

/obj/machinery/portable_thermomachine/process_atmos()
	if(!on || !is_operational)
		if(on) // If it's broken, turn it off too
			on = FALSE
		return PROCESS_KILL

	if(!cell || cell.charge <= 5) //so it doesn't get stuck on
		on = FALSE
		update_appearance()
		return PROCESS_KILL

	var/turf/local_turf = loc
	if(!istype(local_turf))
		if(mode != HEATER_MODE_STANDBY)
			mode = HEATER_MODE_STANDBY
			update_appearance()
		return

	var/datum/gas_mixture/environment = local_turf.return_air()

	var/new_mode = HEATER_MODE_STANDBY
	if(set_mode != HEATER_MODE_COOL && environment.return_temperature() < target_temperature - temperature_tolerance)
		new_mode = HEATER_MODE_HEAT
	else if(set_mode != HEATER_MODE_HEAT && environment.return_temperature() > target_temperature + temperature_tolerance)
		new_mode = HEATER_MODE_COOL

	if(mode != new_mode)
		mode = new_mode
		update_appearance()

	if(mode == HEATER_MODE_STANDBY)
		return

	var/heat_capacity = environment.heat_capacity()
	var/required_energy = abs(environment.return_temperature() - target_temperature) * heat_capacity
	required_energy = min(required_energy, heating_power)

	if(required_energy < 1)
		return

	var/delta_temperature = required_energy / heat_capacity
	if(mode == HEATER_MODE_COOL)
		delta_temperature *= -1
	if(delta_temperature)
		environment.temperature = environment.return_temperature() + delta_temperature
		air_update_turf(FALSE, FALSE)
	cell.use(required_energy / efficiency)

/obj/machinery/portable_thermomachine/RefreshParts()
	. = ..()
	cell = null
	var/laser = 0
	var/cap = 0
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		laser += M.rating
	for(var/obj/item/stock_parts/capacitor/M in component_parts)
		cap += M.rating
	for(var/obj/item/stock_parts/cell/M in component_parts)
		cell = M

	heating_power = (laser * 2) * 100000
	settable_temperature_range = cap * 30
	efficiency = (cap + 10) * 10000

	target_temperature = clamp(target_temperature,
		max(settable_temperature_median - settable_temperature_range, TCMB),
		settable_temperature_median + settable_temperature_range)

/obj/machinery/portable_thermomachine/emp_act(severity)
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN) || . & EMP_PROTECT_CONTENTS)
		return
	if(cell)
		cell.emp_act(severity)

/obj/machinery/portable_thermomachine/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/portable_thermomachine/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)

	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		user.visible_message(span_notice("\The [user] [panel_open ? "opens" : "closes"] the hatch on \the [src]."), span_notice("You [panel_open ? "open" : "close"] the hatch on \the [src]."))
		update_appearance()
		return TRUE

	if(default_deconstruction_crowbar(I))
		return TRUE

	if(istype(I, /obj/item/stock_parts/cell))
		if(!panel_open)
			balloon_alert(user, "Hatch must be open!")
			return
		if(cell)
			balloon_alert(user, "Already a power cell inside!")
			return
		if(!user.transferItemToLoc(I, src))
			return
		cell = I
		component_parts.Add(I)
		I.add_fingerprint(usr)
		user.visible_message(span_notice("\The [user] inserts a power cell into \the [src]."), span_notice("You insert the power cell into \the [src]."))
		SStgui.update_uis(src)
		return TRUE
	return ..()

/obj/machinery/portable_thermomachine/proc/toggle_power()
	on = !on
	mode = HEATER_MODE_STANDBY
	balloon_alert(usr, "[on ? "on" : "off"]")
	usr.visible_message(span_notice("[usr] switches [on ? "on" : "off"] \the [src]."), span_notice("You switch [on ? "on" : "off"] \the [src]."))
	update_appearance()
	if(on)
		SSair.start_processing_machine(src)
	else
		SSair.stop_processing_machine(src)

/obj/machinery/portable_thermomachine/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/portable_thermomachine/attack_hand_secondary(mob/user, list/modifiers)
	if(!can_interact(user))
		return
	toggle_power()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/portable_thermomachine/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PortableThermomachine")
		ui.set_autoupdate(TRUE) // Displays temperature
		ui.open()

/obj/machinery/portable_thermomachine/ui_data()
	var/list/data = list()
	data["open"] = panel_open
	data["on"] = on
	data["mode"] = set_mode
	data["hasPowercell"] = cell
	data["chemHacked"] = FALSE
	if(cell)
		data["powerLevel"] = round(cell.percent(), 1)
	data["targetTemp"] = round(target_temperature - T0C, 1)
	data["minTemp"] = max(settable_temperature_median - settable_temperature_range, TCMB) - T0C
	data["maxTemp"] = settable_temperature_median + settable_temperature_range - T0C

	var/turf/local_turf = get_turf(loc)
	var/current_temperature
	if(istype(local_turf))
		var/datum/gas_mixture/environment = local_turf.return_air()
		current_temperature = environment.return_temperature()
	else if(isturf(local_turf))
		current_temperature = local_turf.return_temperature()
	if(isnull(current_temperature))
		data["currentTemp"] = "N/A"
	else
		data["currentTemp"] = round(current_temperature - T0C, 1)
	return data

/obj/machinery/portable_thermomachine/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("power")
			toggle_power()
			. = TRUE
		if("mode")
			set_mode = params["mode"]
			. = TRUE
		if("target")
			if(!panel_open)
				return
			var/target = params["target"]
			if(text2num(target) != null)
				target= text2num(target) + T0C
				. = TRUE
			if(.)
				target_temperature = clamp(round(target),
					max(settable_temperature_median - settable_temperature_range, TCMB),
					settable_temperature_median + settable_temperature_range)
		if("eject")
			if(panel_open && cell)
				cell = null
				for(var/obj/item/stock_parts/cell/M in component_parts)
					M.forceMove(drop_location())
					component_parts.Remove(M)
				. = TRUE

//Portable thermomachines without a cell
/obj/machinery/portable_thermomachine/no_cell
	cell = null

/obj/machinery/portable_thermomachine/no_cell/Initialize(mapload)
	. = ..()
	panel_open = TRUE
	update_appearance()

//Atmos portable thermomachines
/obj/machinery/portable_thermomachine/atmos

/obj/machinery/portable_thermomachine/atmos/Initialize(mapload)
	for(var/obj/item/stock_parts/cell/M in component_parts)
		QDEL_NULL(M)
		component_parts.Add(/obj/item/stock_parts/cell/hyper)
	RefreshParts()
	. = ..()

#undef HEATER_MODE_STANDBY
#undef HEATER_MODE_HEAT
#undef HEATER_MODE_COOL
#undef HEATER_MODE_AUTO
