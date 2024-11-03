/obj/machinery/portable_atmospherics/scrubber
	name = "portable air scrubber"
	desc = "It's a small portable scrubber, capable of siphoning selected gasses from its surroundings. It has an internal tank, and a slot for inserting an external tank. It can be wrenched to connection ports to pump and withdraw gasses from the internal tank."
	icon_state = "pscrubber:0"
	density = TRUE



	var/on = FALSE
	var/volume_rate = 500
	var/overpressure_m = 80
	volume = 1000

	var/list/scrubbing = list(/datum/gas/plasma, /datum/gas/carbon_dioxide, /datum/gas/nitrous_oxide, /datum/gas/bz, /datum/gas/nitryl, /datum/gas/tritium, /datum/gas/hypernoblium, /datum/gas/water_vapor)

/obj/machinery/portable_atmospherics/scrubber/Destroy()
	var/turf/T = get_turf(src)
	T.assume_air(air_contents)
	air_update_turf(FALSE, FALSE)
	return ..()

/obj/machinery/portable_atmospherics/scrubber/update_icon()
	icon_state = "pscrubber:[on]"

	cut_overlays()
	if(holding)
		add_overlay("scrubber-open")
	if(connected_port)
		add_overlay("scrubber-connector")

/obj/machinery/portable_atmospherics/scrubber/process_atmos()
	. = ..()
	if(!on)
		return

	if(holding)
		scrub(holding.return_air())
	else
		var/turf/T = get_turf(src)
		scrub(T.return_air())


/obj/machinery/portable_atmospherics/scrubber/proc/scrub(var/datum/gas_mixture/mixture)
	if(air_contents.return_pressure() >= overpressure_m * ONE_ATMOSPHERE)
		return

	mixture.scrub_into(air_contents, volume_rate / mixture.return_volume(), scrubbing)
	if(!holding)
		air_update_turf(FALSE, FALSE)

/obj/machinery/portable_atmospherics/scrubber/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(is_operational)
		if(prob(50 / severity))
			on = !on
			if(on)
				SSair.start_processing_machine(src)
		update_appearance()


/obj/machinery/portable_atmospherics/scrubber/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/portable_atmospherics/scrubber/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PortableScrubber")
		ui.open()
		ui.set_autoupdate(TRUE) // Air pressure, tank pressure

/obj/machinery/portable_atmospherics/scrubber/ui_data()
	var/data = list()
	data["on"] = on
	data["connected"] = connected_port ? 1 : 0
	data["pressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)

	data["id_tag"] = -1 //must be defined in order to reuse code between portable and vent scrubbers
	data["filter_types"] = list()
	for(var/gas_type in subtypesof(/datum/gas))
		data["filter_types"] += list(list("gas_id" = GLOB.meta_gas_info[gas_type][META_GAS_ID], "gas_name" = GLOB.meta_gas_info[gas_type][META_GAS_NAME], "enabled" = (gas_type in scrubbing)))

	if(holding)
		data["holding"] = list()
		data["holding"]["name"] = holding.name
		var/datum/gas_mixture/holding_mix = holding.return_air()
		data["holding"]["pressure"] = round(holding_mix.return_pressure())
	else
		data["holding"] = null
	return data

/obj/machinery/portable_atmospherics/scrubber/replace_tank(mob/living/user, close_valve)
	. = ..()
	if(.)
		if(close_valve)
			if(on)
				on = FALSE
				update_icon()
		else if(on && holding)
			user.investigate_log("started a transfer into [holding].", INVESTIGATE_ATMOS)

/obj/machinery/portable_atmospherics/scrubber/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("power")
			on = !on
			if(on)
				SSair.start_processing_machine(src)
			. = TRUE
		if("eject")
			if(holding)
				replace_tank(usr, FALSE)
				. = TRUE
		if("toggle_filter")
			scrubbing ^= params["val"]
			. = TRUE
	if(.)
		update_appearance()

/obj/machinery/portable_atmospherics/pump/unregister_holding()
	on = FALSE
	return ..()

/obj/machinery/portable_atmospherics/scrubber/huge
	name = "huge air scrubber"
	icon_state = "scrubber:0"
	anchored = TRUE
	active_power_usage = 500
	idle_power_usage = 10

	overpressure_m = 200
	volume_rate = 1500
	volume = 50000

	var/movable = FALSE

/obj/machinery/portable_atmospherics/scrubber/huge/movable
	movable = TRUE

/obj/machinery/portable_atmospherics/scrubber/huge/update_icon()
	icon_state = "scrubber:[on]"

/obj/machinery/portable_atmospherics/scrubber/huge/process_atmos()
	if((!anchored && !movable) || !is_operational)
		on = FALSE
		update_icon()
	use_power = on ? ACTIVE_POWER_USE : IDLE_POWER_USE

	if(!on)
		return ..()

	excited = TRUE

	if(!holding)
		var/turf/T = get_turf(src)
		for(var/turf/AT in T.get_atmos_adjacent_turfs(alldir = TRUE))
			scrub(AT.return_air())

	return ..()

/obj/machinery/portable_atmospherics/scrubber/huge/attackby(obj/item/W, mob/user)
	if(default_unfasten_wrench(user, W))
		if(!movable)
			on = FALSE
	else
		return ..()
