#define SIPHONING	0
#define SCRUBBING	1
///filtered gases at or below this amount automatically get removed from the mix
#define MINIMUM_MOLES_TO_SCRUB MOLAR_ACCURACY*100

/obj/machinery/atmospherics/components/unary/vent_scrubber
	icon_state = "scrub_map-3"

	name = "air scrubber"
	desc = "Has a valve and pump attached to it."
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 60
	can_unwrench = TRUE
	welded = FALSE
	layer = GAS_SCRUBBER_LAYER
	shift_underlay_only = FALSE
	hide = TRUE
	processing_flags = NONE

	interacts_with_air = TRUE

	var/scrubbing = SCRUBBING //0 = siphoning, 1 = scrubbing

	var/list/filter_types = list(/datum/gas/carbon_dioxide, /datum/gas/bz)
	var/volume_rate = 200
	var/widenet = 0 //is this scrubber acting on the 3x3 area around it.
	var/list/turf/adjacent_turfs = list()

	var/frequency = FREQ_ATMOS_CONTROL
	var/datum/radio_frequency/radio_connection
	var/radio_filter_out
	var/radio_filter_in

	pipe_state = "scrubber"
	COOLDOWN_DECLARE(check_turfs_cooldown)

/obj/machinery/atmospherics/components/unary/vent_scrubber/New()
	if(!id_tag)
		id_tag = SSnetworks.assign_random_name()
	. = ..()

/obj/machinery/atmospherics/components/unary/vent_scrubber/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/atmos_sensitive, mapload)

/obj/machinery/atmospherics/components/unary/vent_scrubber/Destroy()
	var/area/A = get_area(src)
	if (A)
		A.air_scrub_names -= id_tag
		A.air_scrub_info -= id_tag

	SSradio.remove_object(src,frequency)
	radio_connection = null
	adjacent_turfs.Cut()
	return ..()

///adds a gas or list of gases to our filter_types. used so that the scrubber can check if its supposed to be processing after each change
/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/add_filters(filter_or_filters)
	if(!islist(filter_or_filters))
		filter_or_filters = list(filter_or_filters)

	for(var/gas_to_filter in filter_or_filters)
		var/translated_gas = istext(gas_to_filter) ? gas_id2path(gas_to_filter) : gas_to_filter

		if(ispath(translated_gas, /datum/gas))
			filter_types |= translated_gas
			continue

	var/turf/open/our_turf = get_turf(src)

	if(!isopenturf(our_turf))
		return FALSE

	var/datum/gas_mixture/turf_gas = our_turf.air
	if(!turf_gas)
		return FALSE

	check_atmos_process(our_turf, turf_gas, turf_gas.temperature)
	return TRUE

///remove a gas or list of gases from our filter_types.used so that the scrubber can check if its supposed to be processing after each change
/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/remove_filters(filter_or_filters)
	if(!islist(filter_or_filters))
		filter_or_filters = list(filter_or_filters)

	for(var/gas_to_filter in filter_or_filters)
		var/translated_gas = istext(gas_to_filter) ? gas_id2path(gas_to_filter) : gas_to_filter

		if(ispath(translated_gas, /datum/gas))
			filter_types -= translated_gas
			continue

	var/turf/open/our_turf = get_turf(src)
	var/datum/gas_mixture/turf_gas

	if(isopenturf(our_turf))
		turf_gas = our_turf.air

	if(!turf_gas)
		return FALSE

	check_atmos_process(our_turf, turf_gas, turf_gas.temperature)
	return TRUE

/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/toggle_filters(filter_or_filters)
	if(!islist(filter_or_filters))
		filter_or_filters = list(filter_or_filters)

	for(var/gas_to_filter in filter_or_filters)
		var/translated_gas = istext(gas_to_filter) ? gas_id2path(gas_to_filter) : gas_to_filter

		if(ispath(translated_gas, /datum/gas))
			if(translated_gas in filter_types)
				filter_types -= translated_gas
			else
				filter_types |= translated_gas

	var/turf/open/our_turf = get_turf(src)

	if(!isopenturf(our_turf))
		return FALSE

	var/datum/gas_mixture/turf_gas = our_turf.air

	if(!turf_gas)
		return FALSE

	check_atmos_process(our_turf, turf_gas, turf_gas.temperature)
	return TRUE

/obj/machinery/atmospherics/components/unary/vent_scrubber/auto_use_power()
	if(!on || welded || !is_operational || !powered(power_channel))
		return FALSE

	var/amount = idle_power_usage

	if(scrubbing & SCRUBBING)
		amount += idle_power_usage * length(filter_types)
	else //scrubbing == SIPHONING
		amount = active_power_usage

	if(widenet)
		amount += amount * (adjacent_turfs.len * (adjacent_turfs.len / 2))
	use_power(amount, power_channel)
	return TRUE

/obj/machinery/atmospherics/components/unary/vent_scrubber/update_icon_nopipes()
	cut_overlays()
	if(showpipe)
		var/image/cap = get_pipe_image(icon, "scrub_cap", initialize_directions)
		add_overlay(cap)
	else
		PIPING_LAYER_SHIFT(src, PIPING_LAYER_DEFAULT)

	if(welded)
		icon_state = "scrub_welded"
		return

	if(!nodes[1] || !on || !is_operational)
		icon_state = "scrub_off"
		return

	if(scrubbing & SCRUBBING)
		if(widenet)
			icon_state = "scrub_wide"
		else
			icon_state = "scrub_on"
	else //scrubbing == SIPHONING
		icon_state = "scrub_purge"

/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, radio_filter_in)

/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/broadcast_status()
	if(!radio_connection)
		return FALSE

	var/list/f_types = list()
	for(var/id in subtypesof(/datum/gas))
		f_types += list(list("gas_id" = id, "gas_name" = GLOB.meta_gas_info[id][META_GAS_NAME], "enabled" = (id in filter_types)))

	var/datum/signal/signal = new(list(
		"tag" = id_tag,
		"frequency" = frequency,
		"device" = "VS",
		"timestamp" = world.time,
		"power" = on,
		"scrubbing" = scrubbing,
		"widenet" = widenet,
		"filter_types" = f_types,
		"sigtype" = "status"
	))

	var/area/A = get_area(src)
	if(!A.air_scrub_names[id_tag])
		name = "\improper [A.name] air scrubber #[A.air_scrub_names.len + 1]"
		A.air_scrub_names[id_tag] = name

	A.air_scrub_info[id_tag] = signal.data
	radio_connection.post_signal(src, signal, radio_filter_out)

	return TRUE

/obj/machinery/atmospherics/components/unary/vent_scrubber/atmos_init()
	radio_filter_in = frequency==initial(frequency)?(RADIO_FROM_AIRALARM):null
	radio_filter_out = frequency==initial(frequency)?(RADIO_TO_AIRALARM):null
	if(frequency)
		set_frequency(frequency)
	broadcast_status()
	check_turfs()
	..()

/obj/machinery/atmospherics/components/unary/vent_scrubber/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	if(welded || !is_operational)
		return FALSE
	if(!nodes[1] || !on || (!filter_types && scrubbing != SIPHONING))
		on = FALSE
		return FALSE

	var/list/changed_gas = air.gases

	if(!changed_gas)
		return FALSE

	if(scrubbing == SIPHONING || length(filter_types & changed_gas))
		return TRUE

	return FALSE

/obj/machinery/atmospherics/components/unary/vent_scrubber/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	..()
	if(welded || !is_operational)
		return FALSE
	if(!nodes[1] || !on)
		on = FALSE
		return FALSE
	scrub(loc)
	if(widenet)
		if(COOLDOWN_FINISHED(src, check_turfs_cooldown))
			check_turfs()
			COOLDOWN_START(src, check_turfs_cooldown, 2 SECONDS)
		for(var/turf/tile in adjacent_turfs)
			scrub(tile)
	return TRUE

/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/scrub(var/turf/tile)
	if(!istype(tile))
		return FALSE
	var/datum/gas_mixture/environment = tile.return_air()
	var/datum/gas_mixture/air_contents = airs[1]
	var/list/env_gases = environment.gases

	if(air_contents.return_pressure() >= 50 * ONE_ATMOSPHERE || !islist(filter_types))
		return FALSE

	if(scrubbing & SCRUBBING)
		///contains all of the gas we're sucking out of the tile, gets put into our parent pipenet
		var/datum/gas_mixture/filtered_out = new
		var/list/filtered_gases = filtered_out.gases
		filtered_out.temperature = environment.temperature
		///maximum percentage of the turfs gas we can filter
		var/removal_ratio =  min(1, volume_rate / environment.volume)
		var/total_moles_to_remove = 0
		for(var/gas in filter_types & env_gases)
			total_moles_to_remove += env_gases[gas][MOLES]
		if(total_moles_to_remove == 0)//sometimes this gets non gc'd values
			environment.garbage_collect()
			return FALSE
		for(var/gas in filter_types & env_gases)
			filtered_out.add_gas(gas)
			//take this gases portion of removal_ratio of the turfs air, or all of that gas if less than or equal to MINIMUM_MOLES_TO_SCRUB
			var/transfered_moles = max(QUANTIZE(env_gases[gas][MOLES] * removal_ratio * (env_gases[gas][MOLES] / total_moles_to_remove)), min(MINIMUM_MOLES_TO_SCRUB, env_gases[gas][MOLES]))
			filtered_gases[gas][MOLES] = transfered_moles
			env_gases[gas][MOLES] -= transfered_moles
		environment.garbage_collect()
		air_contents.merge(filtered_out)

	else //Just siphoning all air
		var/transfer_moles = environment.total_moles() * (volume_rate / environment.volume)
		var/datum/gas_mixture/removed = tile.remove_air(transfer_moles)
		air_contents.merge(removed)
	update_parents()
	return TRUE

//There is no easy way for an object to be notified of changes to atmos can pass flags
//	So we check every machinery process (2 seconds)
/obj/machinery/atmospherics/components/unary/vent_scrubber/process()
	if(widenet)
		check_turfs()

//we populate a list of turfs with nonatmos-blocked cardinal turfs AND
//	diagonal turfs that can share atmos with *both* of the cardinal turfs

/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/check_turfs()
	adjacent_turfs.Cut()
	var/turf/T = get_turf(src)
	if(istype(T))
		adjacent_turfs = T.get_atmos_adjacent_turfs(alldir = 1)

/obj/machinery/atmospherics/components/unary/vent_scrubber/receive_signal(datum/signal/signal)
	if(!is_operational || !signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command"))
		return 0

	///whether we should attempt to start processing due to settings allowing us to take gas out of our environment
	var/try_start_processing = FALSE

	var/turf/open/our_turf = get_turf(src)
	var/datum/gas_mixture/turf_gas = our_turf?.air

	var/atom/signal_sender = signal.data["user"]

	if("power" in signal.data)
		on = text2num(signal.data["power"])
		try_start_processing = TRUE
	if("power_toggle" in signal.data)
		on = !on
		try_start_processing = TRUE

	if("widenet" in signal.data)
		widenet = text2num(signal.data["widenet"])
	if("toggle_widenet" in signal.data)
		widenet = !widenet

	var/old_scrubbing = scrubbing
	if("scrubbing" in signal.data)
		scrubbing = text2num(signal.data["scrubbing"])
		try_start_processing = TRUE
	if("toggle_scrubbing" in signal.data)
		scrubbing = !scrubbing
		try_start_processing = TRUE

	if(scrubbing != old_scrubbing)
		investigate_log(" was toggled to [scrubbing ? "scrubbing" : "siphon"] mode by [key_name(signal_sender)]",INVESTIGATE_ATMOS)

	if("toggle_filter" in signal.data)
		toggle_filters(signal.data["toggle_filter"])

	if("set_filters" in signal.data)
		filter_types = list()
		add_filters(signal.data["set_filters"])

	if("init" in signal.data)
		name = signal.data["init"]
		return

	if("status" in signal.data)
		broadcast_status()
		return //do not update_icon

	broadcast_status()
	update_icon()

	if(!our_turf || !turf_gas)
		try_start_processing = FALSE

	if(try_start_processing)//check if our changes should make us start processing
		check_atmos_process(our_turf, turf_gas, turf_gas.temperature)

	return

/obj/machinery/atmospherics/components/unary/vent_scrubber/power_change()
	. = ..()
	update_icon_nopipes()

/obj/machinery/atmospherics/components/unary/vent_scrubber/welder_act(mob/living/user, obj/item/I)
	if(!I.tool_start_check(user, amount=0))
		return TRUE
	to_chat(user, "<span class='notice'>Now welding the scrubber.</span>")
	if(I.use_tool(src, user, 20, volume=50))
		if(!welded)
			user.visible_message("[user] welds the scrubber shut.","You weld the scrubber shut.", "You hear welding.")
			welded = TRUE
		else
			user.visible_message("[user] unwelds the scrubber.", "You unweld the scrubber.", "You hear welding.")
			welded = FALSE
		update_icon()
		pipe_vision_img = image(src, loc, dir = dir)
		pipe_vision_img.plane = ABOVE_HUD_PLANE
	return TRUE

/obj/machinery/atmospherics/components/unary/vent_scrubber/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational)
		to_chat(user, "<span class='warning'>You cannot unwrench [src], turn it off first!</span>")
		return FALSE

/obj/machinery/atmospherics/components/unary/vent_scrubber/examine(mob/user)
	. = ..()
	if(welded)
		. += "It seems welded shut."

/obj/machinery/atmospherics/components/unary/vent_scrubber/can_crawl_through()
	return !(machine_stat & BROKEN) && !welded

/obj/machinery/atmospherics/components/unary/vent_scrubber/attack_alien(mob/user)
	if(!welded || !(do_after(user, 20, target = src)))
		return
	user.visible_message("<span class='warning'>[user] furiously claws at [src]!</span>", "<span class='notice'>You manage to clear away the stuff blocking the scrubber.</span>", "<span class='warning'>You hear loud scraping noises.</span>")
	welded = FALSE
	update_icon()
	pipe_vision_img = image(src, loc, dir = dir)
	pipe_vision_img.plane = ABOVE_HUD_PLANE
	playsound(loc, 'sound/weapons/bladeslice.ogg', 100, 1)


/obj/machinery/atmospherics/components/unary/vent_scrubber/layer2
	piping_layer = 2
	icon_state = "scrub_map-2"

/obj/machinery/atmospherics/components/unary/vent_scrubber/layer4
	piping_layer = 4
	icon_state = "scrub_map-4"

/obj/machinery/atmospherics/components/unary/vent_scrubber/on
	on = TRUE
	icon_state = "scrub_map_on-3"

/obj/machinery/atmospherics/components/unary/vent_scrubber/on/layer2
	piping_layer = 2
	icon_state = "scrub_map_on-2"

/obj/machinery/atmospherics/components/unary/vent_scrubber/on/layer4
	piping_layer = 4
	icon_state = "scrub_map_on-4"

/obj/machinery/atmospherics/components/unary/vent_scrubber/on/lavaland
	filter_types = list(/datum/gas/carbon_dioxide, /datum/gas/plasma, /datum/gas/water_vapor, /datum/gas/bz)

/obj/machinery/atmospherics/components/unary/vent_scrubber/on/layer4/lavaland
	filter_types = list(/datum/gas/carbon_dioxide, /datum/gas/plasma, /datum/gas/water_vapor, /datum/gas/bz)

#undef SIPHONING
#undef SCRUBBING
#undef MINIMUM_MOLES_TO_SCRUB
