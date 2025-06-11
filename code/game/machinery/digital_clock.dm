/obj/machinery/digital_clock
	name = "digital clock"
	desc = "A next-gen normal digital clock that tells the local time. <i>Do not mistake it with shift time!</i>"
	icon_state = "digital_clock_base"
	icon = 'icons/obj/digital_clock.dmi'
	verb_say = "beeps"
	verb_ask = "bloops"
	verb_exclaim = "blares"
	max_integrity = 250
	density = FALSE
	layer = ABOVE_WINDOW_LAYER
	var/station_minutes
	var/station_hours

/obj/item/wallframe/digital_clock
	name = "digital clock frame"
	desc = "Used to build digital clocks, just secure to the wall."
	icon_state = "digital_clock"
	icon = 'icons/obj/wallframe.dmi'
	custom_materials = list(/datum/material/iron = 700, /datum/material/glass = 400)
	result_path = /obj/machinery/digital_clock
	pixel_shift = -28

/obj/machinery/digital_clock/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(user.combat_mode)
		return
	to_chat(user, span_notice("You start unsecuring [name]..."))
	tool.play_tool_sound(src)
	if(tool.use_tool(src, user, 6 SECONDS))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, vary = TRUE)
		to_chat(user, span_notice("You unsecure [name]."))
		deconstruct()
	return ..()

/obj/machinery/digital_clock/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	if(user.combat_mode)
		return
	if(atom_integrity >= max_integrity)
		balloon_alert(user, "it doesn't need repairs!")
		return TRUE
	to_chat(user, span_notice("You start to repair [name]..."))
	if(!tool.use_tool(src, user, 4 SECONDS, amount = 0, volume=50))
		return TRUE
	to_chat(user, span_notice("You finish to repair [name]..."))
	atom_integrity = max_integrity
	set_machine_stat(machine_stat & ~BROKEN)
	update_appearance()
	return TRUE

/obj/machinery/digital_clock/multitool_act(mob/living/user, obj/item/tool)
	. = ..()
	if(user.combat_mode)
		return
	if(!(obj_flags & EMAGGED))
		return
	to_chat(user, span_notice("You start resetting [name]..."))
	tool.play_tool_sound(src)
	if(tool.use_tool(src, user, 6 SECONDS))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, vary = TRUE)
		to_chat(user, span_notice("You finish to reset [name]..."))
		obj_flags &= ~EMAGGED
		return TRUE

/obj/machinery/digital_clock/on_emag(mob/user)
	..()
	to_chat(user, span_notice("You short the clock's timer!"))
	playsound(src, "sparks", 100, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	do_sparks(3, cardinal_only = FALSE, source = src)
	obj_flags |= EMAGGED

/obj/machinery/digital_clock/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			new /obj/item/wallframe/digital_clock(loc)
		else
			new /obj/item/stack/sheet/iron(loc, 2)
			new /obj/item/shard(loc)
			new /obj/item/shard(loc)
	qdel(src)

/obj/machinery/digital_clock/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSdigital_clock, src)

/obj/machinery/digital_clock/Destroy()
	STOP_PROCESSING(SSdigital_clock, src)
	return ..()

/obj/machinery/digital_clock/process()
	if(machine_stat & NOPOWER)
		return
	update_time()
	if((station_hours == 0 || station_hours == 12) && station_minutes == 0)
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_CLOCK_WMCHIMES))
			playsound(src.loc, 'sound/machines/westminister_chimes.ogg', 75)
			TIMER_COOLDOWN_START(src, COOLDOWN_CLOCK_WMCHIMES, 10 SECONDS)
	update_appearance()

/obj/machinery/digital_clock/update_appearance(updates=ALL)
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		set_light(0)
		return
	set_light(l_range = 1.5, l_power = 0.7, l_color = LIGHT_COLOR_BLUE) // blue light

/obj/machinery/digital_clock/update_overlays()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	. += update_time()
	return .

/obj/machinery/digital_clock/examine(mob/user)
	. = ..()
	var/live_time = station_time_timestamp(format = "hh:mm")

	if(obj_flags & EMAGGED)
		. += span_warning("The time doesn't seem quite right!")
	else
		. += span_notice("The current station time is [live_time].")

/obj/machinery/digital_clock/proc/update_time()
	if(obj_flags & EMAGGED)
		station_hours = rand(0, 99)
		station_minutes = rand(0, 99)
	else
		station_hours = text2num(station_time_timestamp(format = "hh"))
		station_minutes = text2num(station_time_timestamp(format = "mm"))

	// tenth / the '3' in '31' / 31 -> 3.1 -> 3
	var/station_minute_tenth = station_minutes >= 10 ? round(station_minutes * 0.1) : 0
	// one / the '1' in '31' / 31 -> 31 - (3 * 10) -> 31 - 30 -> 1
	var/station_minute_one = station_minutes - (station_minute_tenth * 10)

	// one / the '1' in '12' / 12 -> 1.2 -> 1
	var/station_hours_tenth = station_hours >= 10 ? round(station_hours * 0.1) : 0
	// tenth / the '2' in '12' / 12 -> 12 - (1 * 10) -> 12 - 10 -> 2
	var/station_hours_one = station_hours - (station_hours_tenth * 10)

	var/return_overlays = list()

	var/mutable_appearance/minute_one_overlay = mutable_appearance('icons/obj/digital_clock.dmi', "+[station_minute_one]")
	minute_one_overlay.pixel_w = 0
	return_overlays += minute_one_overlay

	var/mutable_appearance/minute_tenth_overlay = mutable_appearance('icons/obj/digital_clock.dmi', "+[station_minute_tenth]")
	minute_tenth_overlay.pixel_w = -4
	return_overlays += minute_tenth_overlay

	var/mutable_appearance/separator = mutable_appearance('icons/obj/digital_clock.dmi', "+separator")
	return_overlays += separator

	var/mutable_appearance/hour_one_overlay = mutable_appearance('icons/obj/digital_clock.dmi', "+[station_hours_one]")
	hour_one_overlay.pixel_w = -10
	return_overlays += hour_one_overlay

	var/mutable_appearance/hour_tenth_overlay = mutable_appearance('icons/obj/digital_clock.dmi', "+[station_hours_tenth]")
	hour_tenth_overlay.pixel_w = -14
	return_overlays += hour_tenth_overlay

	return return_overlays


/obj/machinery/digital_clock/directional/north
	dir = SOUTH
	pixel_y = 28

/obj/machinery/digital_clock/directional/south
	dir = NORTH
	pixel_y = -28

/obj/machinery/digital_clock/directional/east
	dir = WEST
	pixel_x = 28

/obj/machinery/digital_clock/directional/west
	dir = EAST
	pixel_x = -28
