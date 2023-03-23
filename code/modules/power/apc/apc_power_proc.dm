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
	terminal.setDir(tdir)
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

// val 0=off, 1=off(auto) 2=on 3=on(auto)
// on 0=off, 1=on, 2=autooff

/obj/machinery/power/apc/proc/autoset(val, on)
	if(on==0)
		if(val==2)			// if on, return off
			return 0
		else if(val==3)		// if auto-on, return auto-off
			return 1
	else if(on==1)
		if(val==1)			// if auto-off, return auto-on
			return 3
	else if(on==2)
		if(val==3)			// if auto-on, return auto-off
			return 1
	return val

/obj/machinery/power/apc/proc/setsubsystem(val)
	if(cell && cell.charge > 0)
		return (val==1) ? 0 : val
	else if(val == 3)
		return 1
	else
		return 0

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
			equipment = 3
			environ = 3
			update_appearance()
			update()
	wires.ui_update()

// overload all the lights in this APC area

/obj/machinery/power/apc/proc/overload_lighting()
	if(/* !get_connection() || */ !operating || shorted)
		return
	if( cell && cell.charge>=20)
		cell.use(20)
		INVOKE_ASYNC(src, PROC_REF(break_lights))

/obj/machinery/power/apc/proc/break_lights()
	for(var/obj/machinery/light/L in area)
		L.on = TRUE
		L.break_light_tube()
		L.on = FALSE
		stoplag()

/obj/machinery/power/apc/proc/energy_fail(duration)
	for(var/obj/machinery/M in area.contents)
		if(M.critical_machine)
			return
	for(var/A in GLOB.ai_list)
		var/mob/living/silicon/ai/I = A
		if(get_area(I) == area)
			return

	failure_timer = max(failure_timer, round(duration))

/obj/machinery/power/apc/proc/togglelock(mob/living/user)
	if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>The interface is broken!</span>")
	else if(opened)
		to_chat(user, "<span class='warning'>You must close the cover to swipe an ID card!</span>")
	else if(panel_open)
		to_chat(user, "<span class='warning'>You must close the panel!</span>")
	else if(machine_stat & (BROKEN|MAINT))
		to_chat(user, "<span class='warning'>Nothing happens!</span>")
	else
		if(allowed(usr) && !wires.is_cut(WIRE_IDSCAN) && !malfhack)
			locked = !locked
			wires.ui_update()
			to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] the APC interface.</span>")
			update_appearance()
			updateUsrDialog()
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

/obj/machinery/power/apc/proc/toggle_nightshift_lights(mob/living/user)
	if(last_nightshift_switch > world.time - 100) //~10 seconds between each toggle to prevent spamming
		to_chat(usr, "<span class='warning'>[src]'s night lighting circuit breaker is still cycling!</span>")
		return
	last_nightshift_switch = world.time
	set_nightshift(!nightshift_lights)

/obj/machinery/power/apc/proc/set_nightshift(on)
	set waitfor = FALSE
	nightshift_lights = on
	for(var/obj/machinery/light/L in area)
		if(L.nightshift_allowed)
			L.nightshift_enabled = nightshift_lights
			L.update(FALSE)
		CHECK_TICK

/obj/machinery/power/apc/proc/update()
	if(operating && !shorted && !failure_timer)
		area.power_light = (lighting > 1)
		area.power_equip = (equipment > 1)
		area.power_environ = (environ > 1)
	else
		area.power_light = FALSE
		area.power_equip = FALSE
		area.power_environ = FALSE
	area.power_change()

/obj/machinery/power/apc/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == "melee" && damage_amount < 10 && (!(machine_stat & BROKEN) || malfai))
		return 0
	. = ..()
