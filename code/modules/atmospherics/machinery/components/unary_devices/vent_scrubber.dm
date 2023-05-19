#define SIPHONING	0
#define SCRUBBING	1

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

	interacts_with_air = TRUE

	var/scrubbing = SCRUBBING //0 = siphoning, 1 = scrubbing

	var/filter_types = list(GAS_CO2, GAS_BZ)
	var/volume_rate = 200
	var/widenet = 0 //is this scrubber acting on the 3x3 area around it.
	var/list/turf/adjacent_turfs = list()

	var/frequency = FREQ_ATMOS_CONTROL
	var/datum/radio_frequency/radio_connection
	var/radio_filter_out
	var/radio_filter_in

	pipe_state = "scrubber"

/obj/machinery/atmospherics/components/unary/vent_scrubber/New()
	if(!id_tag)
		id_tag = SSnetworks.assign_random_name()
	. = ..()

/obj/machinery/atmospherics/components/unary/vent_scrubber/Destroy()
	var/area/A = get_area(src)
	if (A)
		A.air_scrub_names -= id_tag
		A.air_scrub_info -= id_tag

	SSradio.remove_object(src,frequency)
	radio_connection = null
	adjacent_turfs.Cut()
	return ..()

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
		var/image/cap = getpipeimage(icon, "scrub_cap", initialize_directions)
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
	for(var/id in GLOB.gas_data.ids)
		f_types += list(list("gas_id" = id, "gas_name" = GLOB.gas_data.names[id], "enabled" = (id in filter_types)))

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

/obj/machinery/atmospherics/components/unary/vent_scrubber/atmosinit()
	radio_filter_in = frequency==initial(frequency)?(RADIO_FROM_AIRALARM):null
	radio_filter_out = frequency==initial(frequency)?(RADIO_TO_AIRALARM):null
	if(frequency)
		set_frequency(frequency)
	broadcast_status()
	check_turfs()
	..()

/obj/machinery/atmospherics/components/unary/vent_scrubber/process_atmos()
	..()
	if(welded || !is_operational)
		return FALSE
	if(!nodes[1] || !on)
		on = FALSE
		return FALSE
	scrub(loc)
	if(widenet)
		for(var/turf/tile in adjacent_turfs)
			scrub(tile)
	return TRUE

/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/scrub(var/turf/open/tile)
	if(!istype(tile))
		return FALSE
	var/datum/gas_mixture/environment = tile.return_air()
	var/datum/gas_mixture/air_contents = airs[1]

	if(air_contents.return_pressure() >= 50 * ONE_ATMOSPHERE || !islist(filter_types))
		return FALSE

	if(scrubbing & SCRUBBING)
		environment.scrub_into(air_contents, volume_rate/environment.return_volume(), filter_types)
		tile.air_update_turf()

	else //Just siphoning all air
		environment.transfer_ratio_to(air_contents, volume_rate/environment.return_volume())
		tile.air_update_turf()

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
		adjacent_turfs = T.GetAtmosAdjacentTurfs(alldir = 1)

/obj/machinery/atmospherics/components/unary/vent_scrubber/receive_signal(datum/signal/signal)
	if(!is_operational || !signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command"))
		return 0

	var/atom/signal_sender = signal.data["user"]

	if("power" in signal.data)
		on = text2num(signal.data["power"])
	if("power_toggle" in signal.data)
		on = !on

	if("widenet" in signal.data)
		widenet = text2num(signal.data["widenet"])
	if("toggle_widenet" in signal.data)
		widenet = !widenet

	var/old_scrubbing = scrubbing
	if("scrubbing" in signal.data)
		scrubbing = text2num(signal.data["scrubbing"])
	if("toggle_scrubbing" in signal.data)
		scrubbing = !scrubbing
	if(scrubbing != old_scrubbing)
		investigate_log(" was toggled to [scrubbing ? "scrubbing" : "siphon"] mode by [key_name(signal_sender)]",INVESTIGATE_ATMOS)

	if("toggle_filter" in signal.data)
		filter_types ^= signal.data["toggle_filter"]

	if("set_filters" in signal.data)
		filter_types = list()
		for(var/gas in signal.data["set_filters"])
			filter_types += gas

	if("init" in signal.data)
		name = signal.data["init"]
		return

	if("status" in signal.data)
		broadcast_status()
		return //do not update_icon

	broadcast_status()
	update_icon()
	return

/obj/machinery/atmospherics/components/unary/vent_scrubber/power_change()
	..()
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
	return !welded

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
	filter_types = list(GAS_CO2, GAS_PLASMA, GAS_H2O, GAS_BZ)

/obj/machinery/atmospherics/components/unary/vent_scrubber/on/layer4/lavaland
	filter_types = list(GAS_CO2, GAS_PLASMA, GAS_H2O, GAS_BZ)

#undef SIPHONING
#undef SCRUBBING
