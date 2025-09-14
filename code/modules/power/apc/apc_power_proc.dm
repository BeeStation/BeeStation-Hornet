/obj/machinery/power/apc/get_cell()
	return cell

/obj/machinery/power/apc/connect_to_network()
	//Override because the APC does not directly connect to the network; it goes through a terminal.
	//The terminal is what the power computer looks for anyway.
	if(terminal)
		terminal.connect_to_network()

/obj/machinery/power/apc/proc/make_terminal()
	// create a terminal object at the same position as original turf loc
	// wires will attach to this
	terminal = new/obj/machinery/power/terminal(loc)
	terminal.setDir(dir)
	terminal.master = src

/obj/machinery/power/apc/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null

/obj/machinery/power/apc/proc/toggle_breaker(mob/user)
	if(!is_operational || failure_timer)
		return
	operating = !operating
	add_hiddenprint(user)
	log_game("[key_name(user)] turned [operating ? "on" : "off"] the [src] in [AREACOORD(src)]")
	update()
	update_appearance()

/obj/machinery/power/apc/surplus()
	if(terminal)
		return terminal.surplus()
	else
		return 0

/obj/machinery/power/apc/add_load(amount)
	if(terminal && terminal.powernet)
		terminal.add_load(amount)

/obj/machinery/power/apc/avail(amount)
	if(terminal)
		return terminal.avail(amount)
	else
		return 0

/**
 * Returns the new status value for an APC channel.
 *
 * // val 0=off, 1=off(auto) 2=on 3=on(auto)
 * // on 0=off, 1=on, 2=autooff
 * TODO: Make this use bitflags instead. It should take at most three lines, but it's out of scope for now.
 *
 * Arguments:
 * - val: The current status of the power channel.
 *   - [APC_CHANNEL_OFF]: The APCs channel has been manually set to off. This channel will not automatically change.
 *   - [APC_CHANNEL_AUTO_OFF]: The APCs channel is running on automatic and is currently off. Can be automatically set to [APC_CHANNEL_AUTO_ON].
 *   - [APC_CHANNEL_ON]: The APCs channel has been manually set to on. This will be automatically changed only if the APC runs completely out of power or is disabled.
 *   - [APC_CHANNEL_AUTO_ON]: The APCs channel is running on automatic and is currently on. Can be automatically set to [APC_CHANNEL_AUTO_OFF].
 * - on: An enum dictating how to change the channel's status.
 *   - [AUTOSET_FORCE_OFF]: The APC forces the channel to turn off. This includes manually set channels.
 *   - [AUTOSET_ON]: The APC allows automatic channels to turn back on.
 *   - [AUTOSET_OFF]: The APC turns automatic channels off.
 */
/obj/machinery/power/apc/proc/autoset(val, on)
	switch(on)
		if(AUTOSET_FORCE_OFF)
			// Force OFF overrides everything, but manual-ON should become AUTO OFF so it can resume
			if(val == APC_CHANNEL_ON || val == APC_CHANNEL_AUTO_ON)
				playsound(src, "sound/machines/apc/PowerSwitch_Place.ogg", 20, TRUE)
				do_sparks(2, cardinal_only = FALSE, source = src)
				return APC_CHANNEL_AUTO_OFF
			// Manual OFF or AUTO OFF - stay the same
			return val

		if(AUTOSET_ON)	// APC turning the channel on automatically
			if(val == APC_CHANNEL_AUTO_OFF)
				playsound(src, "sound/machines/apc/PowerUp_001.ogg", 20, TRUE)
				return APC_CHANNEL_AUTO_ON
			return val

		if(AUTOSET_OFF)	// APC turning the channel off automatically
			if(val == APC_CHANNEL_AUTO_ON)
				playsound(src, "sound/machines/apc/PowerSwitch_Place.ogg", 20, TRUE)
				do_sparks(2, cardinal_only = FALSE, source = src)
				return APC_CHANNEL_AUTO_OFF
			return val
	return val

/**
 * Used by external forces to set the APCs channel status's.
 *
 * Arguments:
 * - val: The desired value of the subsystem:
 *   - 1: Manually sets the APCs channel to be [APC_CHANNEL_OFF].
 *   - 2: Manually sets the APCs channel to be [APC_CHANNEL_AUTO_ON]. If the APC doesn't have any power this defaults to [APC_CHANNEL_OFF] instead.
 *   - 3: Sets the APCs channel to be [APC_CHANNEL_AUTO_ON]. If the APC doesn't have enough power this defaults to [APC_CHANNEL_AUTO_OFF] instead.
 */
/obj/machinery/power/apc/proc/setsubsystem(val)
	if(cell && cell.charge > 0)
		return (val==1) ? APC_CHANNEL_OFF : val
	if(val == 3)
		return APC_CHANNEL_AUTO_OFF
	return APC_CHANNEL_OFF

/obj/machinery/power/apc/proc/reset(wire)
	switch(wire)
		if(WIRE_IDSCAN)
			locked = TRUE
		if(WIRE_POWER1, WIRE_POWER2)
			if(!wires.is_cut(WIRE_POWER1) && !wires.is_cut(WIRE_POWER2))
				shorted = FALSE
		if(WIRE_AI)
			if(!wires.is_cut(WIRE_AI))
				aidisabled = FALSE
		if(APC_RESET_EMP)
			equipment = APC_CHANNEL_AUTO_ON
			environ = APC_CHANNEL_AUTO_ON
			update_appearance()
			update()
	wires.ui_update()

// overload all the lights in this APC area
/obj/machinery/power/apc/proc/overload_lighting()
	if(!operating || shorted)
		return
	if( cell && cell.charge>=20)
		cell.use(20)
		INVOKE_ASYNC(src, PROC_REF(break_lights))

/obj/machinery/power/apc/proc/break_lights()
	for(var/obj/machinery/light/breaked_light in area)
		breaked_light.on = TRUE
		breaked_light.break_light_tube()
		breaked_light.on = FALSE
		stoplag()

/obj/machinery/power/apc/proc/energy_fail(duration)
	for(var/obj/machinery/failing_machine in area.contents)
		if(failing_machine.critical_machine)
			return

	for(var/mob/living/silicon/ai as anything in GLOB.ai_list)
		if(get_area(ai) == area)
			return

	failure_timer = max(failure_timer, round(duration))
	update()
	queue_icon_update()

/obj/machinery/power/apc/proc/togglelock(mob/living/user)
	if(obj_flags & EMAGGED)
		to_chat(user, span_warning("The interface is broken!"))
	else if(opened)
		to_chat(user, span_warning("You must close the cover to swipe an ID card!"))
	else if(panel_open)
		to_chat(user, span_warning("You must close the panel!"))
	else if(machine_stat & (BROKEN|MAINT))
		to_chat(user, span_warning("Nothing happens!"))
	else
		if(allowed(usr) && !wires.is_cut(WIRE_IDSCAN) && !malfhack)
			locked = !locked
			wires.ui_update()
			to_chat(user, span_notice("You [ locked ? "lock" : "unlock"] the APC interface."))
			update_appearance()
			updateUsrDialog()
		else
			to_chat(user, span_warning("Access denied."))

/obj/machinery/power/apc/proc/toggle_nightshift_lights(mob/living/user)
	if(last_nightshift_switch > world.time - 100) //~10 seconds between each toggle to prevent spamming
		to_chat(usr, span_warning("[src]'s night lighting circuit breaker is still cycling!"))
		return
	last_nightshift_switch = world.time
	set_nightshift(!nightshift_lights)

/obj/machinery/power/apc/proc/set_nightshift(on)
	set waitfor = FALSE
	nightshift_lights = on
	for(var/obj/machinery/light/night_light in area)
		if(night_light.nightshift_allowed)
			night_light.nightshift_enabled = nightshift_lights
			night_light.update(FALSE)
		CHECK_TICK

/obj/machinery/power/apc/proc/update()
	if(operating && !shorted && !failure_timer)
		area.power_light = (lighting > APC_CHANNEL_AUTO_OFF)
		area.power_equip = (equipment > APC_CHANNEL_AUTO_OFF)
		area.power_environ = (environ > APC_CHANNEL_AUTO_OFF)
	else
		area.power_light = FALSE
		area.power_equip = FALSE
		area.power_environ = FALSE
	area.power_change()

/obj/machinery/power/apc/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(machine_stat & BROKEN)
		return damage_amount
	. = ..()
