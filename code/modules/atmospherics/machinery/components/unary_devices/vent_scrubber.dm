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

	///The mode of the scrubber (ATMOS_DIRECTION_SCRUBBING or ATMOS_DIRECTION_SIPHONING)
	var/scrubbing = ATMOS_DIRECTION_SCRUBBING
	///The list of gases we are filtering
	var/list/filter_types = list(/datum/gas/carbon_dioxide, /datum/gas/bz)
	///Rate of the scrubber to remove gases from the air
	var/volume_rate = 200
	///is this scrubber acting on the 3x3 area around it.
	var/widenet = 0
	///List of the turfs near the scrubber, used for widenet
	var/list/turf/adjacent_turfs = list()

	pipe_state = "scrubber"
	COOLDOWN_DECLARE(check_turfs_cooldown)

/obj/machinery/atmospherics/components/unary/vent_scrubber/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/atmos_sensitive, mapload)

/obj/machinery/atmospherics/components/unary/vent_scrubber/Destroy()
	disconnect_from_area()
	adjacent_turfs.Cut()
	return ..()

/obj/machinery/atmospherics/components/unary/vent_scrubber/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()

	var/area/old_area = get_area(old_loc)
	var/area/new_area = get_area(src)

	if (old_area == new_area)
		return

	disconnect_from_area()
	assign_to_area()

/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/assign_to_area()
	var/area/area = get_area(src)
	area?.air_scrubbers += src

/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/disconnect_from_area()
	var/area/area = get_area(src)
	area?.air_scrubbers -= src

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

// WARNING: This proc takes untrusted user input from toggle_filter in air alarm's ui_act
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

	if(scrubbing == ATMOS_DIRECTION_SCRUBBING)
		amount += idle_power_usage * length(filter_types)
	else
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

	if(scrubbing == ATMOS_DIRECTION_SCRUBBING)
		if(widenet)
			icon_state = "scrub_wide"
		else
			icon_state = "scrub_on"
	else
		icon_state = "scrub_purge"

/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/try_update_atmos_process()
	var/turf/open/turf = get_turf(src)
	if (!istype(turf))
		return
	var/datum/gas_mixture/turf_gas = turf.air
	if (isnull(turf_gas))
		return
	check_atmos_process(turf, turf_gas, turf_gas.temperature)

/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/update_power_usage()
	idle_power_usage = initial(idle_power_usage)
	active_power_usage = initial(idle_power_usage)
	var/new_power_usage = 0
	if(scrubbing == ATMOS_DIRECTION_SCRUBBING)
		new_power_usage = idle_power_usage + idle_power_usage * length(filter_types)
		active_power_usage = IDLE_POWER_USE
	else
		new_power_usage = active_power_usage
		active_power_usage = ACTIVE_POWER_USE
	if(widenet)
		new_power_usage += new_power_usage * (length(adjacent_turfs) * (length(adjacent_turfs) / 2))
	update_mode_power_usage(scrubbing == ATMOS_DIRECTION_SCRUBBING ? IDLE_POWER_USE : ACTIVE_POWER_USE, new_power_usage)


/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/set_scrubbing(scrubbing, mob/user)
	src.scrubbing = scrubbing
	investigate_log(" was toggled to [scrubbing ? "scrubbing" : "siphon"] mode by [isnull(user) ? "the game" : key_name(user)]", INVESTIGATE_ATMOS)
	update_appearance(UPDATE_ICON)
	try_update_atmos_process()
	update_power_usage()

/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/set_widenet(widenet)
	src.widenet = widenet
	update_appearance(UPDATE_ICON)
	update_power_usage()

/obj/machinery/atmospherics/components/unary/vent_scrubber/update_name()
	. = ..()
	if(override_naming)
		return
	var/area/scrub_area = get_area(src)
	name = "\proper [scrub_area.name] [name] [id_tag]"

/obj/machinery/atmospherics/components/unary/vent_scrubber/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	if(welded || !is_operational)
		return FALSE
	if(!nodes[1] || !on || (!filter_types && scrubbing != ATMOS_DIRECTION_SIPHONING))
		on = FALSE
		return FALSE

	var/list/changed_gas = air.gases

	if(!changed_gas)
		return FALSE

	if(scrubbing == ATMOS_DIRECTION_SIPHONING || length(filter_types & changed_gas))
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

//we populate a list of turfs with nonatmos-blocked cardinal turfs AND
//	diagonal turfs that can share atmos with *both* of the cardinal turfs

/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/check_turfs()
	adjacent_turfs.Cut()
	var/turf/local_turf = get_turf(src)
	adjacent_turfs = local_turf.get_atmos_adjacent_turfs(alldir = TRUE)

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

#undef MINIMUM_MOLES_TO_SCRUB
