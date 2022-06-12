/// Solar Control Computer
/obj/machinery/power/solar_control
	name = "solar panel control"
	desc = "A controller for solar panel arrays."
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 250
	max_integrity = 200
	integrity_failure = 100
	var/icon_screen = "solar"
	var/icon_keyboard = "power_key"
	var/id = 0
	var/currentdir = 0
	var/targetdir = 0		// target angle in manual tracking (since it updates every game minute)
	var/gen = 0
	var/lastgen = 0
	var/azimuth_target = 0
	var/azimuth_rate = 1 ///degree change per minute

	var/track = SOLAR_TRACK_OFF ///SOLAR_TRACK_OFF, SOLAR_TRACK_TIMED, SOLAR_TRACK_AUTO

	var/obj/machinery/power/tracker/connected_tracker = null
	var/list/connected_panels = list()

/obj/machinery/power/solar_control/Initialize(mapload)
	. = ..()
	azimuth_rate = SSsun.base_rotation
	RegisterSignal(SSsun, COMSIG_SUN_MOVED, .proc/timed_track)
	connect_to_network()
	if(powernet)
		set_panels(azimuth_target)

/obj/machinery/power/solar_control/Destroy()
	for(var/obj/machinery/power/solar/machinery_solar in connected_panels)
		machinery_solar.unset_control()
	if(connected_tracker)
		connected_tracker.unset_control()
	return ..()

//search for unconnected panels and trackers in the computer powernet and connect them
/obj/machinery/power/solar_control/proc/search_for_connected()
	if(powernet)
		for(var/obj/machinery/power/machinery_power in powernet.nodes)
			if(istype(machinery_power, /obj/machinery/power/solar))
				var/obj/machinery/power/solar/machinery_solar = machinery_power
				if(!machinery_solar.control) //i.e unconnected
					machinery_solar.set_control(src)
			else if(istype(machinery_power, /obj/machinery/power/tracker))
				if(!connected_tracker) //if there's already a tracker connected to the computer don't add another
					var/obj/machinery/power/tracker/machinery_tracker = machinery_power
					if(!machinery_tracker.control) //i.e unconnected
						machinery_tracker.set_control(src)

/obj/machinery/power/solar_control/update_overlays()
	. = ..()

	if(machine_stat & NOPOWER)
		. += mutable_appearance(icon, "[icon_keyboard]_off")
		return

	. += mutable_appearance(icon, icon_keyboard)
	if(machine_stat & BROKEN)
		. += mutable_appearance(icon, "[icon_state]_broken")
		return
	. += mutable_appearance(icon, icon_screen)

/obj/machinery/power/solar_control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SolarControl")
		ui.open()
		ui.set_autoupdate(TRUE) // Power output, solar panel direction

/obj/machinery/power/solar_control/ui_data()
	var/data = list()
	data["generated"] = round(lastgen)
	data["generated_ratio"] = data["generated"] / round(max(connected_panels.len, 1) * SOLAR_GEN_RATE)
	data["azimuth_current"] = azimuth_target
	data["azimuth_rate"] = azimuth_rate
	data["max_rotation_rate"] = SSsun.base_rotation * 2
	data["tracking_state"] = track
	data["connected_panels"] = connected_panels.len
	data["connected_tracker"] = (connected_tracker ? TRUE : FALSE)
	return data

/obj/machinery/power/solar_control/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(action == "azimuth")
		var/adjust = text2num(params["adjust"])
		var/value = text2num(params["value"])
		if(adjust)
			value = azimuth_target + adjust
		if(value != null)
			set_panels(value)
			return TRUE
		return FALSE
	if(action == "azimuth_rate")
		var/adjust = text2num(params["adjust"])
		var/value = text2num(params["value"])
		if(adjust)
			value = azimuth_rate + adjust
		if(value != null)
			azimuth_rate = round(clamp(value, -2 * SSsun.base_rotation, 2 * SSsun.base_rotation), 0.01)
			return TRUE
		return FALSE
	if(action == "tracking")
		var/mode = text2num(params["mode"])
		track = mode
		if(mode == SOLAR_TRACK_AUTO)
			if(connected_tracker)
				connected_tracker.sun_update(SSsun, SSsun.azimuth)
			else
				track = SOLAR_TRACK_OFF
		return TRUE
	if(action == "refresh")
		search_for_connected()
		return TRUE
	return FALSE

/obj/machinery/power/solar_control/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(I.use_tool(src, user, 20, volume=50))
			if (src.machine_stat & BROKEN)
				to_chat(user, "<span class='notice'>The broken glass falls out.</span>")
				var/obj/structure/frame/computer/computer_frame = new /obj/structure/frame/computer( src.loc )
				new /obj/item/shard( src.loc )
				var/obj/item/circuitboard/computer/solar_control/circuit_solar_control = new /obj/item/circuitboard/computer/solar_control(computer_frame)
				for (var/obj/computer in src)
					computer.forceMove(drop_location())
				computer_frame.circuit = circuit_solar_control
				computer_frame.state = 3
				computer_frame.icon_state = "3"
				computer_frame.anchored = TRUE
				qdel(src)
			else
				to_chat(user, "<span class='notice'>You disconnect the monitor.</span>")
				var/obj/structure/frame/computer/computer_frame = new /obj/structure/frame/computer( src.loc )
				var/obj/item/circuitboard/computer/solar_control/circuit_solar_control = new /obj/item/circuitboard/computer/solar_control(computer_frame)
				for (var/obj/computer in src)
					computer.forceMove(drop_location())
				computer_frame.circuit = circuit_solar_control
				computer_frame.state = 4
				computer_frame.icon_state = "4"
				computer_frame.anchored = TRUE
				qdel(src)
	else if(user.a_intent != INTENT_HARM && !(I.item_flags & NOBLUDGEON))
		attack_hand(user)
	else
		return ..()

/obj/machinery/power/solar_control/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(machine_stat & BROKEN)
				playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
			else
				playsound(src.loc, 'sound/effects/glasshit.ogg', 75, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)

/obj/machinery/power/solar_control/obj_break(damage_flag)
	if(!(machine_stat & BROKEN) && !(flags_1 & NODECONSTRUCT_1))
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, 1)
		machine_stat |= BROKEN
		update_icon()

/obj/machinery/power/solar_control/process()
	lastgen = gen
	gen = 0

	if(connected_tracker && (!powernet || connected_tracker.powernet != powernet))
		connected_tracker.unset_control()

///Ran every time the sun updates.
/obj/machinery/power/solar_control/proc/timed_track()
	SIGNAL_HANDLER

	if(track == SOLAR_TRACK_TIMED)
		azimuth_target += azimuth_rate
		set_panels(azimuth_target)

///Rotates the panel to the passed angles
/obj/machinery/power/solar_control/proc/set_panels(azimuth)
	azimuth = clamp(round(azimuth, 0.01), -360, 719.99)
	if(azimuth >= 360)
		azimuth -= 360
	if(azimuth < 0)
		azimuth += 360
	azimuth_target = azimuth

	for(var/obj/machinery/power/solar/machinery_solar in connected_panels)
		machinery_solar.queue_turn(azimuth)

	update_icon()
