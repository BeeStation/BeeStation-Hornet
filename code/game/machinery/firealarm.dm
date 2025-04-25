/obj/item/electronics/firealarm
	name = "fire alarm electronics"
	custom_price = 5
	desc = "A fire alarm circuit. Can handle heat levels up to 40 degrees celsius."

/obj/item/wallframe/firealarm
	name = "fire alarm frame"
	desc = "Used for building fire alarms."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire_bitem"
	result_path = /obj/machinery/firealarm
	pixel_shift = 26

/obj/machinery/firealarm
	name = "fire alarm"
	desc = "<i>\"Pull this in case of emergency\"</i>. Thus, keep pulling it forever."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire0"
	max_integrity = 250
	integrity_failure = 0.4
	armor_type = /datum/armor/machinery_firealarm
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = AREA_USAGE_ENVIRON
	resistance_flags = FIRE_PROOF
	layer = ABOVE_WINDOW_LAYER
	zmm_flags = ZMM_MANGLE_PLANES
	req_access = list(ACCESS_ATMOSPHERICS)

	light_power = 0
	light_range = 7
	light_color = "#ff3232"

	//Trick to get the glowing overlay visible from a distance
	luminosity = 1

	//We want to use area sensitivity, let us
	always_area_sensitive = TRUE
	///Buildstate for contruction steps
	var/buildstage = FIRE_ALARM_BUILD_SECURED
	///Our home area, set in Init. Due to loading step order, this seems to be null very early in the server setup process, which is why some procs use `my_area?` for var or list checks.
	var/area/my_area = null
	///looping sound datum for our fire alarm siren.
	var/datum/looping_sound/firealarm/soundloop
	//Is the fire alarm locked?
	var/locked = FALSE

CREATION_TEST_IGNORE_SUBTYPES(/obj/machinery/firealarm)


/datum/armor/machinery_firealarm
	rad = 100
	fire = 90
	acid = 30

/obj/machinery/firealarm/Initialize(mapload, dir, building)
	. = ..()
	id_tag = assign_random_name()
	if(building)
		buildstage = FIRE_ALARM_BUILD_NO_CIRCUIT
		panel_open = TRUE
	if(name == initial(name))
		update_name()
	my_area = get_area(src)
	LAZYADD(my_area.firealarms, src)

	AddElement(/datum/element/atmos_sensitive, mapload)
	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(check_security_level))
	soundloop = new(src, FALSE)

	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/firealarm))
	update_appearance()

/obj/machinery/firealarm/Destroy()
	if(my_area)
		LAZYREMOVE(my_area.firealarms, src)
		my_area = null
	QDEL_NULL(soundloop)
	return ..()

// Area sensitivity is traditionally tied directly to power use, as an optimization
// But since we want it for fire reacting, we disregard that
/obj/machinery/firealarm/setup_area_power_relationship()
	. = ..()
	if(!.)
		return
	var/area/our_area = get_area(src)
	RegisterSignal(our_area, COMSIG_AREA_FIRE_CHANGED, PROC_REF(handle_fire))
	handle_fire(our_area, our_area.fire)

/obj/machinery/firealarm/on_enter_area(datum/source, area/area_to_register)
	//were already registered to an area. exit from here first before entering into an new area
	if(!isnull(my_area))
		return
	. = ..()

	my_area = area_to_register
	LAZYADD(my_area.firealarms, src)

	RegisterSignal(area_to_register, COMSIG_AREA_FIRE_CHANGED, PROC_REF(handle_fire))
	handle_fire(area_to_register, area_to_register.fire)
	update_appearance()

/obj/machinery/firealarm/update_name(updates)
	. = ..()
	name = "[get_area_name(my_area)] [initial(name)] [id_tag]"

/obj/machinery/firealarm/on_exit_area(datum/source, area/area_to_unregister)
	//we cannot unregister from an area we never registered to in the first place
	if(my_area != area_to_unregister)
		return
	. = ..()

	UnregisterSignal(area_to_unregister, COMSIG_AREA_FIRE_CHANGED)
	LAZYREMOVE(my_area.firealarms, src)
	my_area = null

/obj/machinery/firealarm/proc/handle_fire(area/source, new_fire)
	SIGNAL_HANDLER
	set_status()

/**
 * Sets the sound state, and then calls update_icon()
 *
 * This proc exists to be called by areas and firelocks
 * so that it may update its icon and start or stop playing
 * the alarm sound based on the state of an area variable.
 */
/obj/machinery/firealarm/proc/set_status()
	if(!(my_area.fire || LAZYLEN(my_area.active_firelocks)) || (obj_flags & EMAGGED))
		soundloop.stop()
	update_appearance()

/obj/machinery/firealarm/update_appearance(updates)
	. = ..()
	if((my_area?.fire || LAZYLEN(my_area?.active_firelocks)) && !(obj_flags & EMAGGED) && !(machine_stat & (BROKEN|NOPOWER)))
		set_light(l_range = 2.5, l_power = 1.5)
	else
		set_light(l_range = 1.6, l_power = 0)

/obj/machinery/firealarm/update_icon_state()
	if(panel_open)
		icon_state = "fire_b[buildstage]"
		return ..()
	if(machine_stat & BROKEN)
		icon_state = "firex"
		return ..()
	icon_state = "fire0"
	return ..()

/obj/machinery/firealarm/update_overlays()
	. = ..()
	if(machine_stat & NOPOWER)
		return

	if(panel_open)
		return

	if(obj_flags & EMAGGED)
		. += "fire_emagged"
		. += mutable_appearance(icon, "fire_emagged")
		. += emissive_appearance(icon, "fire_emagged", layer, alpha = 255)
		ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)
		return //If it's emagged, don't do anything else for overlays.

	if(my_area?.fire_detect) //If this is false, someone disabled it. Leave the light missing, a good hint to anyone paying attention.
		if(is_station_level(z))
			. += "fire_[SSsecurity_level.get_current_level_as_number()]"
			. += mutable_appearance(icon, "fire_[SSsecurity_level.get_current_level_as_number()]")
			. += emissive_appearance(icon, "fire_[SSsecurity_level.get_current_level_as_number()]", layer, alpha = 255)
			ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)
		else
			. += "fire_[SEC_LEVEL_GREEN]"
			. += mutable_appearance(icon, "fire_[SEC_LEVEL_GREEN]")
			. += emissive_appearance(icon, "fire_[SEC_LEVEL_GREEN]", layer, alpha = 255)
			ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)
	else
		. += mutable_appearance(icon, "fire_off")
		. += emissive_appearance(icon, "fire_off", layer, alpha = src.alpha)
		ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)

	if(my_area?.fire_detect && my_area?.fire)
		. += "fire_on"
		. += mutable_appearance(icon, "fire_on", layer + 2) //If we are locked and there is a fire, overlay the fire detection overlay ontop of the locked one.
		. += emissive_appearance(icon, "fire_on", layer, alpha = 255)
		ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)
	else
		. += "fire_off"
		. += mutable_appearance(icon, "fire_off")
		. += emissive_appearance(icon, "fire_off", layer, alpha = 255)
		ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)

	if(locked)
		. += "fire_locked"
		. += mutable_appearance(icon, "fire_locked", layer + 1) //If we are locked, overlay that over the fire_off
		. += emissive_appearance(icon, "fire_locked", layer, alpha = 255)
		ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)


/obj/machinery/firealarm/emp_act(severity)
	. = ..()

	if (. & EMP_PROTECT_SELF)
		return

	if(prob(50 / severity))
		alarm()

/obj/machinery/firealarm/on_emag(mob/user)
	. = ..()
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	update_appearance()
	user?.visible_message(
		span_warning("Sparks fly out of [src]!"),
		span_notice("You override [src], disabling the speaker.")
	)
	if(user)
		balloon_alert(user, "speaker disabled")
		user.log_message("emagged [src].", LOG_ATTACK)
	playsound(src, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	set_status()
	return TRUE

/obj/machinery/firealarm/eminence_act(mob/living/simple_animal/eminence/eminence)
	. = ..()
	to_chat(usr, span_brass("You begin manipulating [src]!"))
	if(do_after(eminence, 20, target=get_turf(eminence)))
		attack_hand(eminence)

/**
 * Signal handler for checking if we should update fire alarm appearance accordingly to a newly set security level
 *
 * Arguments:
 * * source The datum source of the signal
 * * new_level The new security level that is in effect
 */
/obj/machinery/firealarm/proc/check_security_level(datum/source, new_level)
	SIGNAL_HANDLER

	if(is_station_level(z))
		update_appearance()

/**
 * Sounds the fire alarm and closes all firelocks in the area. Also tells the area to color the lights red.
 *
 * Arguments:
 * * mob/user is the user that pulled the alarm.
 */
/obj/machinery/firealarm/proc/alarm(mob/user)
	if(!is_operational)
		return

	if(my_area.fire)
		return //area alarm already active
	my_area.alarm_manager.send_alarm(ALARM_FIRE, my_area)
	// This'll setup our visual effects, so we only need to worry about the alarm
	for(var/obj/machinery/door/firedoor/firelock in my_area.firedoors)
		firelock.activate(FIRELOCK_ALARM_TYPE_GENERIC)
	if(user)
		balloon_alert(user, "triggered alarm!")
		user.log_message("triggered a fire alarm.", LOG_GAME)
	my_area.fault_status = AREA_FAULT_MANUAL
	my_area.fault_location = name
	soundloop.start() //Manually pulled fire alarms will make the sound, rather than the doors.
	SEND_SIGNAL(src, COMSIG_FIREALARM_ON_TRIGGER)
	use_power = active_power_usage

/**
 * Resets all firelocks in the area. Also tells the area to disable alarm lighting, if it was enabled.
 *
 * Arguments:
 * * mob/user is the user that reset the alarm.
 */
/obj/machinery/firealarm/proc/reset(mob/user)
	if(!is_operational)
		return
	my_area.alarm_manager.clear_alarm(ALARM_FIRE, my_area)
	// Clears all fire doors and their effects for now
	// They'll reclose if there's a problem
	for(var/obj/machinery/door/firedoor/firelock in my_area.firedoors)
		firelock.crack_open()
	if(user)
		balloon_alert(user, "reset alarm")
		user.log_message("reset a fire alarm.", LOG_GAME)
	soundloop.stop()
	SEND_SIGNAL(src, COMSIG_FIREALARM_ON_RESET)
	use_power = idle_power_usage

/obj/machinery/firealarm/proc/try_lock(mob/user, force_lock = FALSE)
	if(allowed(user) || !user || force_lock)
		if(!locked || force_lock)
			locked = TRUE
			balloon_alert(user, "Locked")
		else
			locked = FALSE
			balloon_alert(user, "Unlocked")
		playsound(src, 'sound/machines/beep.ogg', 50, 1)
	else
		balloon_alert(user, "Access Denied!")
		playsound(src, 'sound/machines/terminal_error.ogg', 50, 1)
	update_appearance()

/obj/machinery/firealarm/AltClick(mob/user)
	if(can_interact(user))
		try_lock(user)

/obj/machinery/firealarm/attack_hand(mob/user, list/modifiers)
	if(buildstage != 2)
		return ..()
	add_fingerprint(user)
	play_click_sound("button")
	var/area/A = get_area(src)
	if(A.fire)
		if(locked)
			balloon_alert(user, "Cover is locked!")
			playsound(loc, 'sound/effects/glassknock.ogg', 10, FALSE, frequency = 32000)
			return
		reset(user)
	else
		alarm(user)
	update_appearance()

/obj/machinery/firealarm/attack_silicon(mob/user)
	return attack_hand(user)

/obj/machinery/firealarm/attackby(obj/item/W, mob/living/user, params)
	add_fingerprint(user)

	if(istype(W, /obj/item/card/id)||istype(W, /obj/item/modular_computer/tablet/pda)) // trying to unlock the cover with an ID card
		try_lock(user)
	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		W.play_tool_sound(src)
		panel_open = !panel_open
		to_chat(user, span_notice("The wires have been [panel_open ? "exposed" : "unexposed"]."))
		update_appearance()
		return

	if(panel_open)
		if(W.tool_behaviour == TOOL_WELDER && !user.combat_mode)
			if(atom_integrity < max_integrity)
				if(!W.tool_start_check(user, amount=0))
					return

				to_chat(user, span_notice("You begin repairing [src]..."))
				if(W.use_tool(src, user, 40, volume=50))
					atom_integrity = max_integrity
					to_chat(user, span_notice("You repair [src]."))
			else
				to_chat(user, span_warning("[src] is already in good condition!"))
			return

		switch(buildstage)
			if(FIRE_ALARM_BUILD_SECURED)
				if(W.tool_behaviour == TOOL_MULTITOOL)
					toggle_fire_detect(user)
					return

				else if(W.tool_behaviour == TOOL_WIRECUTTER)
					buildstage = AIR_ALARM_BUILD_NO_WIRES
					W.play_tool_sound(src)
					new /obj/item/stack/cable_coil(user.loc, 5)
					to_chat(user, span_notice("You cut the wires from  the [src]."))
					update_appearance()
					return

				else if(W.force) //hit and turn it on
					..()
					var/area/A = get_area(src)
					if(!A.fire)
						alarm()
					return

			if(FIRE_ALARM_BUILD_NO_WIRES)
				if(istype(W, /obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/coil = W
					if(coil.get_amount() < 5)
						to_chat(user, span_warning("You need more cable for this!"))
					else
						coil.use(5)
						buildstage = AIR_ALARM_BUILD_COMPLETE
						to_chat(user, span_notice("You wire  the [src]."))
						update_appearance()
					return

				else if(W.tool_behaviour == TOOL_CROWBAR)
					user.visible_message("[user.name] removes the electronics from [src.name].", \
										span_notice("You start prying out the circuit..."))
					if(W.use_tool(src, user, 20, volume=50))
						if(buildstage == 1)
							if(machine_stat & BROKEN)
								to_chat(user, span_notice("You remove the destroyed circuit."))
								set_machine_stat(machine_stat & ~BROKEN)
							else
								to_chat(user, span_notice("You pry out the circuit."))
								new /obj/item/electronics/firealarm(user.loc)
							buildstage = FIRE_ALARM_BUILD_NO_CIRCUIT
							update_appearance()
					return
			if(FIRE_ALARM_BUILD_NO_CIRCUIT)
				if(istype(W, /obj/item/electronics/firealarm))
					to_chat(user, span_notice("You insert the circuit."))
					qdel(W)
					buildstage = FIRE_ALARM_BUILD_NO_WIRES
					update_appearance()
					return

				else if(istype(W, /obj/item/electroadaptive_pseudocircuit))
					var/obj/item/electroadaptive_pseudocircuit/P = W
					if(!P.adapt_circuit(user, 15))
						return
					user.visible_message(span_notice("[user] fabricates a circuit and places it into [src]."), \
					span_notice("You adapt a fire alarm circuit and slot it into the assembly."))
					buildstage = AIR_ALARM_BUILD_NO_WIRES
					update_appearance()
					return

				else if(W.tool_behaviour == TOOL_WRENCH)
					user.visible_message("[user] removes the fire alarm assembly from the wall.", \
										span_notice("You remove the fire alarm assembly from the wall."))
					var/obj/item/wallframe/firealarm/frame = new /obj/item/wallframe/firealarm()
					frame.forceMove(user.drop_location())
					W.play_tool_sound(src)
					qdel(src)
					return

	return ..()

/obj/machinery/firealarm/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if((buildstage == FIRE_ALARM_BUILD_NO_CIRCUIT) && (the_rcd.upgrade & RCD_UPGRADE_SIMPLE_CIRCUITS))
		return list("mode" = RCD_UPGRADE_SIMPLE_CIRCUITS, "delay" = 20, "cost" = 1)
	return FALSE

/obj/machinery/firealarm/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_UPGRADE_SIMPLE_CIRCUITS)
			user.visible_message(span_notice("[user] fabricates a circuit and places it into [src]."), \
			span_notice("You adapt a fire alarm circuit and slot it into the assembly."))
			buildstage = FIRE_ALARM_BUILD_NO_WIRES
			update_appearance()
			return TRUE
	return FALSE

/obj/machinery/firealarm/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	if(.) //damage received
		if(atom_integrity > 0 && !(machine_stat & BROKEN) && buildstage != FIRE_ALARM_BUILD_NO_CIRCUIT)
			if(prob(33))
				alarm()

/obj/machinery/firealarm/singularity_pull(S, current_size)
	if (current_size >= STAGE_FIVE) // If the singulo is strong enough to pull anchored objects, the fire alarm experiences integrity failure
		deconstruct()
	..()

/obj/machinery/firealarm/atom_break(damage_flag)
	if(buildstage == FIRE_ALARM_BUILD_NO_CIRCUIT) //can't break the electronics if there isn't any inside.
		return
	return ..()


/obj/machinery/firealarm/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc, 1)
		if(buildstage > FIRE_ALARM_BUILD_NO_CIRCUIT)
			var/obj/item/item = new /obj/item/electronics/firealarm(loc)
			if(!disassembled)
				item.update_integrity(item.max_integrity * 0.5)
		if(buildstage > FIRE_ALARM_BUILD_NO_WIRES)
			new /obj/item/stack/cable_coil(loc, 3)
	qdel(src)


// Allows users to examine the state of the thermal sensor
/obj/machinery/firealarm/examine(mob/user)
	. = ..()
	if((my_area?.fire || LAZYLEN(my_area?.active_firelocks)))
		. += "The local area hazard light is flashing."
		. += "The fault location display is [my_area.fault_location] ([my_area.fault_status == AREA_FAULT_AUTOMATIC ? "Automatic Detection" : "Manual Trigger"])."
	else
		. += "The local area thermal detection light is [my_area.fire_detect ? "lit" : "unlit"]."
	if(is_station_level(z))
		. += "The station security alert level is [SSsecurity_level.get_current_level_as_text()]."
	. += "<b>Activate</b> to activate/reset all firelocks in this area."

/obj/machinery/firealarm/proc/toggle_fire_detect(mob/user)
	my_area.fire_detect = !my_area.fire_detect
	for(var/obj/machinery/firealarm/fire_panel in my_area.firealarms)
		fire_panel.update_appearance()
	// Used to force all the firelocks to update, if the zone is not manually activated
	if (my_area.fault_status != AREA_FAULT_MANUAL)
		reset() // Don't send user to prevent double balloon_alert() and the action is already logged in this proc.
	if (user)
		balloon_alert(user, "thermal sensors [my_area.fire_detect ? "enabled" : "disabled"]")
		user.log_message("[ my_area.fire_detect ? "enabled" : "disabled" ] firelock sensors using [src].", LOG_GAME)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/firealarm, 26)

/*
 * Return of Party button
 */

/area
	var/party = FALSE

/obj/machinery/firealarm/partyalarm
	name = "\improper PARTY BUTTON"
	desc = "Cuban Pete is in the house!"
	var/static/party_overlay

/obj/machinery/firealarm/partyalarm/reset()
	if (machine_stat & (NOPOWER|BROKEN))
		return
	var/area/area = get_area(src)
	if (!area || !area.party)
		return
	area.party = FALSE
	area.cut_overlay(party_overlay)

/obj/machinery/firealarm/partyalarm/alarm()
	if (machine_stat & (NOPOWER|BROKEN))
		return
	var/area/area = get_area(src)
	if (!area || area.party || area.name == "Space")
		return
	area.party = TRUE
	if (!party_overlay)
		party_overlay = iconstate2appearance('icons/turf/areas.dmi', "party")
	area.add_overlay(party_overlay)

/////////////////////// CIRCUITS //////////////////////////////////////

/obj/item/circuit_component/firealarm
	display_name = "Fire Alarm"
	desc = "Allows you to interface with the Fire Alarm."

	var/datum/port/input/alarm_trigger
	var/datum/port/input/reset_trigger

	/// Returns a boolean value of 0 or 1 if the fire alarm is on or not.
	var/datum/port/output/is_on
	/// Returns when the alarm is turned on
	var/datum/port/output/triggered
	/// Returns when the alarm is turned off
	var/datum/port/output/reset

	var/obj/machinery/firealarm/attached_alarm

/obj/item/circuit_component/firealarm/populate_ports()
	alarm_trigger = add_input_port("Set", PORT_TYPE_SIGNAL)
	reset_trigger = add_input_port("Reset", PORT_TYPE_SIGNAL)

	is_on = add_output_port("Is On", PORT_TYPE_NUMBER)
	triggered = add_output_port("Triggered", PORT_TYPE_SIGNAL)
	reset = add_output_port("Reset", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/firealarm/register_usb_parent(atom/movable/parent)
	. = ..()
	if(istype(parent, /obj/machinery/firealarm))
		attached_alarm = parent
		RegisterSignal(parent, COMSIG_FIREALARM_ON_TRIGGER, PROC_REF(on_firealarm_triggered))
		RegisterSignal(parent, COMSIG_FIREALARM_ON_RESET, PROC_REF(on_firealarm_reset))

/obj/item/circuit_component/firealarm/unregister_usb_parent(atom/movable/parent)
	attached_alarm = null
	UnregisterSignal(parent, COMSIG_FIREALARM_ON_TRIGGER)
	UnregisterSignal(parent, COMSIG_FIREALARM_ON_RESET)
	return ..()

/obj/item/circuit_component/firealarm/proc/on_firealarm_triggered(datum/source)
	SIGNAL_HANDLER
	is_on.set_output(1)
	triggered.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/firealarm/proc/on_firealarm_reset(datum/source)
	SIGNAL_HANDLER
	is_on.set_output(0)
	reset.set_output(COMPONENT_SIGNAL)


/obj/item/circuit_component/firealarm/input_received(datum/port/input/port)
	if(COMPONENT_TRIGGERED_BY(alarm_trigger, port))
		attached_alarm?.alarm()

	if(COMPONENT_TRIGGERED_BY(reset_trigger, port))
		attached_alarm?.reset()

