//This section contain all procs that helps building, destroy and control the RBMK

/obj/machinery/atmospherics/components/unary/rbmk/core/attackby(obj/item/attacked_item, mob/user, params)
	if(istype(attacked_item, /obj/item/fuel_rod))
		if(power >= SAFE_POWER_LEVEL)
			to_chat(user, span_notice("You cannot insert fuel into [src] when it has been raised above [SAFE_POWER_LEVEL]% power."))
			return FALSE
		if(length(fuel_rods) >= 5)
			to_chat(user, span_warning("[src] is already at maximum fuel load."))
			return FALSE
		to_chat(user, span_notice("You start to insert [attacked_item] into [src]..."))
		radiation_pulse(src, max_range = 3, threshold = RAD_EXTREME_INSULATION)
		if(do_after(user, 5 SECONDS, target=src))
			if(length(fuel_rods) >= 5)
				to_chat(user, span_warning("[src] is already at maximum fuel load."))
				return FALSE
			else if(length(fuel_rods) == 0)
				fuel_rods += attacked_item
				attacked_item.forceMove(src)
				activate(user) //That was the first fuel rod. Let's heat it up.
			else  // Not the first fuel rod? Play the sound.
				playsound(src, pick('sound/effects/rbmk/switch1.ogg','sound/effects/rbmk/switch2.ogg','sound/effects/rbmk/switch3.ogg'), 100, FALSE)
				fuel_rods += attacked_item
				attacked_item.forceMove(src)
			update_appearance()
		return TRUE
	if(istype(attacked_item, /obj/item/sealant))
		var/obj/item/sealant/sealant = attacked_item
		if(power >= SAFE_POWER_LEVEL)
			to_chat(user, span_notice("You cannot repair [src] while it is running at above [SAFE_POWER_LEVEL]% power."))
			return FALSE
		if(critical_threshold_proximity <= REACTOR_NEW_SEALS * critical_threshold_proximity_archived)
			to_chat(user, span_notice("[src]'s seals are already in-tact, repairing them further would require a new set of seals."))
			return FALSE
		if(critical_threshold_proximity >= REACTOR_CRACKED_SEALS * critical_threshold_proximity_archived) //Heavily damaged.
			to_chat(user, span_notice("[src]'s reactor vessel is cracked and worn, you need to repair the cracks with a welder before you can repair the seals."))
			return FALSE
		if(do_after(user, 5 SECONDS, target=src))
			if(critical_threshold_proximity <= REACTOR_NEW_SEALS*critical_threshold_proximity_archived)	//They might've stacked doafters
				to_chat(user, span_notice("[src]'s seals are already in-tact, repairing them further would require a new set of seals."))
				return FALSE
			playsound(src, 'sound/effects/spray2.ogg', 50, 1, -6)
			user.visible_message(span_warning("[user] applies sealant to some of [src]'s worn out seals."), span_notice("You apply sealant to some of [src]'s worn out seals."))
			critical_threshold_proximity -= sealant.repair_power // Default is 10
			critical_threshold_proximity = clamp(critical_threshold_proximity, 0, initial(critical_threshold_proximity))
		return TRUE
	if(attacked_item.tool_behaviour == TOOL_WELDER)
		if(power >= SAFE_POWER_LEVEL)
			to_chat(user, span_notice("You can't repair [src] while it is running at above [SAFE_POWER_LEVEL]% power."))
			return FALSE
		if(critical_threshold_proximity < REACTOR_CRACKED_SEALS * critical_threshold_proximity_archived)
			to_chat(user, span_notice("[src] is free from cracks. Further repairs must be carried out with flexi-seal sealant."))
			return FALSE
		if(attacked_item.use_tool(src, user, 0, volume=40))
			if(critical_threshold_proximity < REACTOR_CRACKED_SEALS * critical_threshold_proximity_archived)
				to_chat(user, span_notice("[src] is free from cracks. Further repairs must be carried out with flexi-seal sealant."))
				return FALSE
			critical_threshold_proximity -= 20
			to_chat(user, span_notice("You weld together some of [src]'s cracks. This'll do for now."))
			return TRUE
	if(attacked_item.tool_behaviour == TOOL_SCREWDRIVER)
		if(power >= SAFE_POWER_LEVEL)
			to_chat(user, span_notice("You can't open the maintenance panel of \the [src] while it's still above [SAFE_POWER_LEVEL]% power!"))
			return FALSE
		if (length(fuel_rods) > 0)
			to_chat(user, span_notice("You can't open the maintenance panel of \the [src] while it still has fuel rods inside!"))
			return FALSE
		default_deconstruction_screwdriver(user, "reactor", "reactor_open", attacked_item)
		update_appearance()
		return TRUE
	if(attacked_item.tool_behaviour == TOOL_CROWBAR)
		if(panel_open)
			if(power >= SAFE_POWER_LEVEL)
				to_chat(user, span_notice("You can't deconstruct \the [src] while it's still above [SAFE_POWER_LEVEL]% power!"))
				return FALSE
			if (length(fuel_rods) > 0)
				to_chat(user, span_notice("You can't deconstruct \the [src] while it still has fuel rods inside!"))
				return FALSE
			disassemble(attacked_item)
			return TRUE
		else
			if(power >= SAFE_POWER_LEVEL)
				to_chat(user, span_notice("You can't remove any fuel rods while \the [src] is above [SAFE_POWER_LEVEL]% power!"))
				return FALSE
			if (length(fuel_rods) == 0)
				to_chat(user, span_notice("\the [src] is empty of fuel rods!"))
				return FALSE
			removeFuelRod(user, src)
			update_appearance()
			return TRUE
	if(attacked_item.tool_behaviour == TOOL_MULTITOOL)
		var/datum/component/buffer/heldmultitool = get_held_buffer_item(usr)
		STORE_IN_BUFFER(heldmultitool.parent, src)
		. = TRUE
		to_chat(user, span_notice("You download the link from the nuclear reactor."))
		return TRUE
	return ..()

/*
Called by multitool_act() in rbmk_parts.dm, by atmos_process() in rbmk_main_processes.dm and by atmos_process() in the same file
This proc checks the surrounding of the core to ensure that the machine has been build correctly, returns false if there is a missing piece/wrong placed one
*/
/obj/machinery/atmospherics/components/unary/rbmk/core/proc/check_part_connectivity()
	. = TRUE
	if(!anchored)
		return FALSE

	for(var/obj/machinery/rbmk/object in orange(1,src))
		if(. == FALSE)
			break

		if(object.panel_open)
			. = FALSE

		if(get_step(object,REVERSE_DIR(object.dir)) != loc)
			. = FALSE

	for(var/obj/machinery/atmospherics/components/unary/rbmk/object in orange(1,src))
		if(. == FALSE)
			break

		if(object.panel_open)
			. = FALSE

		if(get_step(object,REVERSE_DIR(object.dir)) != loc)
			. = FALSE

		if(istype(object,/obj/machinery/atmospherics/components/unary/rbmk/coolant_input))
			if(linked_input && linked_input != object)
				. = FALSE
			linked_input = object
			machine_parts |= object

		if(istype(object,/obj/machinery/atmospherics/components/unary/rbmk/waste_output))
			if(linked_output && linked_output != object)
				. = FALSE
			linked_output = object
			machine_parts |= object

		if(istype(object,/obj/machinery/atmospherics/components/unary/rbmk/moderator_input))
			if(linked_moderator && linked_moderator != object)
				. = FALSE
			linked_moderator = object
			machine_parts |= object

	if(!linked_input || !linked_moderator || !linked_output)
		. = FALSE

/*
Called by multitool_act() in rbmk_parts.dm
It sets the pieces to active, allowing the player to start the main reaction
Arguments:
* -user: the player doing the action
*/

/obj/machinery/atmospherics/components/unary/rbmk/core/proc/user_activate(mob/living/user)
	if(active)
		to_chat(user, span_notice("You already activated the machine."))
		return
	to_chat(user, span_notice("You activate the machine."))
	activate()

/obj/machinery/atmospherics/components/unary/rbmk/core/proc/activate()
	active = TRUE
	start_power = TRUE
	update_appearance()
	if (linked_interface)
		linked_interface.active = TRUE
		linked_interface.update_appearance()
		RegisterSignal(linked_interface, COMSIG_QDELETING, PROC_REF(unregister_signals))
	linked_input.active = TRUE
	linked_input.update_appearance()
	RegisterSignal(linked_input, COMSIG_QDELETING, PROC_REF(unregister_signals))
	linked_output.active = TRUE
	linked_output.update_appearance()
	RegisterSignal(linked_output, COMSIG_QDELETING, PROC_REF(unregister_signals))
	linked_moderator.active = TRUE
	linked_moderator.update_appearance()
	RegisterSignal(linked_moderator, COMSIG_QDELETING, PROC_REF(unregister_signals))
	START_PROCESSING(SSmachines, src)
	desired_reate_of_reaction = 1
	var/startup_sound = pick('sound/effects/rbmk/startup.ogg', 'sound/effects/rbmk/startup2.ogg')
	playsound(loc, startup_sound, 50)
	SSblackbox.record_feedback("tally", "engine_stats", 1, "agcnr")
	SSblackbox.record_feedback("tally", "engine_stats", 1, "started")
	soundloop.start()

/obj/machinery/atmospherics/components/unary/rbmk/proc/get_held_buffer_item(mob/user)
	if(isAI(user))
		var/mob/living/silicon/ai/ai_user = user
		return ai_user.aiMulti.GetComponent(/datum/component/buffer)

	var/obj/item/held_item = user.get_active_held_item()
	var/found_component = held_item?.GetComponent(/datum/component/buffer)
	if(found_component && in_range(user, src))
		return found_component

/*
 * Called when a part gets deleted around the rbmk, called on Destroy() of the rbmk core in rbmk_core.dm
 * Unregister the signals attached to the core from the various machines, if only_signals is false it will also call deactivate()
 * Arguments:
 * only_signals: default FALSE, if true the proc will not call the deactivate() proc
 */

/obj/machinery/atmospherics/components/unary/rbmk/core/proc/unregister_signals(only_signals = FALSE)
	SIGNAL_HANDLER
	if(linked_interface)
		UnregisterSignal(linked_interface, COMSIG_QDELETING)
	if(linked_input)
		UnregisterSignal(linked_input, COMSIG_QDELETING)
	if(linked_output)
		UnregisterSignal(linked_output, COMSIG_QDELETING)
	if(linked_moderator)
		UnregisterSignal(linked_moderator, COMSIG_QDELETING)
	if(!only_signals)
		deactivate()

/**
 * Called by unregister_signals() in this file, called when the main fusion processes check_part_connectivity() returns false
 * Deactivate the various machines by setting the active var to false, updates the machines icon and set the linked machine vars to null
 */
/obj/machinery/atmospherics/components/unary/rbmk/core/proc/deactivate()
	if(!active)
		return
	active = FALSE
	start_power = FALSE
	update_appearance()
	if(linked_interface)
		linked_interface.active = FALSE
		linked_interface.update_appearance()
	if(linked_input)
		linked_input.active = FALSE
		linked_input.update_appearance()
	if(linked_output)
		linked_output.active = FALSE
		linked_output.update_appearance()
	if(linked_moderator)
		linked_moderator.active = FALSE
		linked_moderator.update_appearance()
	STOP_PROCESSING(SSmachines, src)
	rate_of_reaction = 0
	desired_reate_of_reaction = 0
	temperature = 0
	soundloop.stop()
	update_appearance()

/obj/machinery/atmospherics/components/unary/rbmk/core/proc/disassemble(obj/item/I)
	unregister_signals()
	deactivate()
	var/parts = list(/obj/item/RBMK_box/core,
					/obj/item/RBMK_box/body/coolant_input,
					/obj/item/RBMK_box/body/moderator_input,
					/obj/item/RBMK_box/body/waste_output,
					/obj/item/RBMK_box/body,
					/obj/item/RBMK_box/body,
					/obj/item/RBMK_box/body,
					/obj/item/RBMK_box/body,
					/obj/item/RBMK_box/body)
	for(var/item in parts)
		new item(get_turf(src))
	I.play_tool_sound(src, 50)
	qdel(src)

/**
 * Updates all related pipenets from all connected components
 */
/obj/machinery/atmospherics/components/unary/rbmk/core/proc/update_pipenets()
	update_parents()
	linked_input.update_parents()
	linked_output.update_parents()
	linked_moderator.update_parents()

/**
 * Called by the main fusion processes in hfr_main_processes.dm
 * Check the power use of the machine, return TRUE if there is enough power in the powernet
 */
/obj/machinery/atmospherics/components/unary/rbmk/core/proc/check_power_use()
	if(machine_stat & (NOPOWER|BROKEN))
		return FALSE
	if(use_power == ACTIVE_POWER_USE)
		use_power((power + 1) * IDLE_POWER_USE)
	return TRUE

/obj/machinery/atmospherics/components/unary/rbmk/core/proc/has_fuel()
	return length(fuel_rods)


/obj/machinery/atmospherics/components/unary/rbmk/core/proc/removeFuelRod(mob/user, /obj/machinery/atmospherics/components/unary/rbmk/core/reactor)
	if(src.power > SAFE_POWER_LEVEL)
		to_chat(user, span_warning("You cannot remove fuel from [src] when it is above [SAFE_POWER_LEVEL]% power."))
		return FALSE
	if(length(fuel_rods) == 0)
		to_chat(user, span_warning("[src] does not have any fuel rods loaded."))
		return FALSE
	var/atom/movable/fuel_rod = input(usr, "Select a fuel rod to remove", "Fuel Rods List", null) as null|anything in src.fuel_rods
	if(!fuel_rod)
		return
	playsound(src, pick('sound/effects/rbmk/switch1.ogg','sound/effects/rbmk/switch2.ogg','sound/effects/rbmk/switch3.ogg'), 100, FALSE)
	fuel_rod.forceMove(get_turf(src))
	src.fuel_rods -= fuel_rod

/**
 * Check the integrity level and returns the status of the machine
 */
/obj/machinery/atmospherics/components/unary/rbmk/core/proc/get_status()
	switch(get_integrity_percent())
		if(0 to REACTOR_MELTING_PERCENT)
			return REACTOR_MELTING
		if(REACTOR_MELTING_PERCENT to REACTOR_EMERGENCY_PERCENT)
			return REACTOR_EMERGENCY
		if(REACTOR_EMERGENCY_PERCENT to REACTOR_DANGER_PERCENT)
			return REACTOR_DANGER
		if(REACTOR_DANGER_PERCENT to REACTOR_WARNING_PERCENT)
			return REACTOR_NOMINAL

/obj/machinery/atmospherics/components/unary/rbmk/core/proc/start_alarm()
	if(alarm == FALSE)
		alarm = TRUE
		alarmloop.start()

/obj/machinery/atmospherics/components/unary/rbmk/core/proc/end_alarm()
	alarmloop.stop()
	alarm = FALSE

/**
 * Getter for the machine integrity
 */
/obj/machinery/atmospherics/components/unary/rbmk/core/proc/get_integrity_percent()
	var/integrity = critical_threshold_proximity / melting_point
	integrity = clamp(round(100 - integrity * 100, 0.01), 0, 100)
	return integrity

/**
 * Get how charged the area's APC is
 */
/obj/machinery/atmospherics/components/unary/rbmk/core/proc/get_area_cell_percent()
	// Make sure to get APC levels from the same area the core draws from
	// Just in case people build an HFR across boundaries
	var/area/area = get_area(src)
	if (!area)
		return 0
	var/obj/machinery/power/apc/apc = area.apc
	if (!apc)
		return 0
	var/obj/item/stock_parts/cell/cell = apc.cell
	if (!cell)
		return 0
	return cell.percent()

/obj/machinery/atmospherics/components/unary/rbmk/core/proc/on_entered(datum/source, atom/movable/movable_atom, oldloc)
	SIGNAL_HANDLER
	if(istype(movable_atom, /obj/item/food))
		grilled_item = movable_atom
		grillStart(grilled_item)

/obj/machinery/atmospherics/components/unary/rbmk/core/proc/on_exited(atom/movable/gone_atom, direction)
	if(direction == grilled_item)
		finish_grill()
		grilled_item = null

/obj/machinery/atmospherics/components/unary/rbmk/core/proc/grillStart(/obj/item/food/grilled_item)
	RegisterSignal(grilled_item, COMSIG_GRILL_COMPLETED, PROC_REF(grill_complete))
	grill_loop.start()

/obj/machinery/atmospherics/components/unary/rbmk/core/proc/finish_grill()
	SEND_SIGNAL(grilled_item, COMSIG_GRILL_FOOD, grilled_item, grill_time)
	grill_time = 0
	UnregisterSignal(grilled_item, COMSIG_GRILL_COMPLETED, PROC_REF(grill_complete))
	grill_loop.stop()

///Called when a food is transformed by the grillable component
/obj/machinery/atmospherics/components/unary/rbmk/core/proc/grill_complete(obj/item/source, atom/grilled_result)
	SIGNAL_HANDLER
	grilled_item = grilled_result //use the new item!!


/obj/machinery/atmospherics/components/unary/rbmk/core/proc/damage_handler(delta_time)
	critical_threshold_proximity_archived = critical_threshold_proximity

	//First alert condition: Overheat
	var/turf/core_turf = get_turf(src)
	if(temperature >= RBMK_TEMPERATURE_CRITICAL)
		var/damagevalue = (temperature - 900)/250
		critical_threshold_proximity += (damagevalue * delta_time)
		warning_damage_flags |= RBMK_TEMPERATURE_DAMAGE
		check_alert()
		if(critical_threshold_proximity >= melting_point)
			countdown() //Oops! All meltdown
			return
	if(temperature < -200) //That's as cold as I'm letting you get it, engineering.
		temperature = -200
	if (pressure >= RBMK_PRESSURE_CRITICAL)
		playsound(src, 'sound/machines/clockcult/steam_whoosh.ogg', 100, TRUE)
		core_turf.atmos_spawn_air("water_vapor=[pressure/100];TEMP=[temperature+273.15]")
		core_turf.air_update_turf(TRUE, FALSE)
		// Warning: Pressure reaching critical thresholds!
		var/damagevalue = (pressure-10100)/1500
		critical_threshold_proximity += (damagevalue * delta_time)
		warning_damage_flags |= RBMK_PRESSURE_DAMAGE
		check_alert()
		if(critical_threshold_proximity >= melting_point)
			countdown()
			return
/**
 * Called by process_atmos() in rbmk_main_processes.dm
 * Called after checking the damage of the machine, calls alarm() and countdown()
 * Broadcast messages into engi and common radio
 */
/obj/machinery/atmospherics/components/unary/rbmk/core/proc/check_alert()
	if(critical_threshold_proximity < warning_point)
		end_alarm()
		return
	if((REALTIMEOFDAY - lastwarning) / 10 >= WARNING_TIME_DELAY)
		if(critical_threshold_proximity > emergency_point)
			radio.talk_into(src, "[emergency_alert] Integrity at: [get_integrity_percent()]%", common_channel)
			lastwarning = REALTIMEOFDAY
			if(!has_reached_emergency)
				investigate_log("has reached the emergency point for the first time.", INVESTIGATE_ENGINES)
				message_admins("[src] has reached the emergency point [ADMIN_JMP(src)].")
				has_reached_emergency = TRUE
			send_radio_explanation()
			start_alarm()
		else if(critical_threshold_proximity > critical_threshold_proximity_archived) // The damage is still going up
			lastwarning = REALTIMEOFDAY - (WARNING_TIME_DELAY * 5)
			send_radio_explanation()
			start_alarm()
		else if (critical_threshold_proximity < critical_threshold_proximity_archived)// Phew, we're safe, damage going down
			radio.talk_into(src, "[safe_alert] Integrity at: [get_integrity_percent()]%", engineering_channel)
			lastwarning = REALTIMEOFDAY
			end_alarm()

/**
 * Called by check_alert() in this file
 * Called to explain in radio what the issues are with the HFR
 */
/obj/machinery/atmospherics/components/unary/rbmk/core/proc/send_radio_explanation()
	if(warning_damage_flags & RBMK_PRESSURE_DAMAGE)
		radio.talk_into(src, "Warning: Reactor overpressurized! Integrity: [get_integrity_percent()]%", engineering_channel)
		warning_damage_flags &= RBMK_PRESSURE_DAMAGE
		warning_damage_flags &= RBMK_TEMPERATURE_DAMAGE //If it is both overpressurized and overheating, just send the more important message
	else if(warning_damage_flags & RBMK_TEMPERATURE_DAMAGE)
		radio.talk_into(src, "Warning: Reactor overheating! Integrity: [get_integrity_percent()]%", engineering_channel)
		warning_damage_flags &= RBMK_TEMPERATURE_DAMAGE

/**
 * Called by check_alert() in this file
 * Called when the damage has reached critical levels, start the countdown before the destruction, calls meltdown()
 */
/obj/machinery/atmospherics/components/unary/rbmk/core/proc/countdown()
	set waitfor = FALSE

	if(final_countdown) // We're already doing it go away
		return
	final_countdown = TRUE
	var/speaking = "[emergency_alert] The RBMK has reached critical integrity failure. Emergency control rods lowered."
	radio.talk_into(src, speaking, common_channel, language = get_selected_language())
	var/mutable_appearance/reactor_overlay = mutable_appearance('icons/obj/machines/rbmkparts.dmi', "nuclearwaste_green")
	notify_ghosts(
		"The [src] has begun melting down!",
		source = src,
		header = "Meltdown Incoming",
		ghost_sound = 'sound/machines/warning-buzzer.ogg',
		notify_volume = 75,
		alert_overlay = reactor_overlay
	)

	for(var/i in REACTOR_COUNTDOWN_TIME to 0 step -10)
		if(critical_threshold_proximity < melting_point) // Cutting it a bit close there engineers
			radio.talk_into(src, "[safe_alert] Failsafe has been disengaged.", common_channel)
			final_countdown = FALSE
			return
		else if((i % 50) != 0 && i > 50) // A message once every 5 seconds until the final 5 seconds which count down individualy
			sleep(1 SECONDS)
			continue
		else if(i > 50)
			if(i == 5 SECONDS)
				sound_to_playing_players('sound/effects/rbmk/explode.ogg')
			speaking = "[DisplayTimeText(i, TRUE)] remain before total integrity failure."
		else
			speaking = "[i*0.1]..."
		radio.talk_into(src, speaking, common_channel)
		sleep(1 SECONDS)

	if(pressure > RBMK_PRESSURE_CRITICAL)
		blowout()
	else if(temperature > RBMK_TEMPERATURE_CRITICAL)
		meltdown()
	else
		meltdown() //This is caused if neither pressure nor temperature was in critical. We still want to explode


/**
 * Called by countdown() in this file
 * Create the explosion before deleting the machine core.
 */
/obj/machinery/atmospherics/components/unary/rbmk/core/proc/meltdown()
	set waitfor = FALSE
	SSair.atmos_machinery -= src //Annd we're now just a useless brick.
	update_icon()
	STOP_PROCESSING(SSmachines, src)
	AddElement(/datum/element/radioactive, intensity = 20, threshold = RAD_EXTREME_INSULATION)
	var/turf/reactor_turf = get_turf(src)
	var/rbmkzlevel = reactor_turf.get_virtual_z_level()
	for(var/mob/player_mob in GLOB.player_list)
		if(compare_z(rbmkzlevel, player_mob.get_virtual_z_level()))
			to_chat(player_mob, span_userdanger("You hear a horrible metallic hissing."))
			SEND_SIGNAL(player_mob, COMSIG_ADD_MOOD_EVENT, "delam", /datum/mood_event/delam) //Might as well use the same moodlet since its essentialy the same thing happening

	for(var/obj/machinery/power/apc/apc in GLOB.apcs_list)
		if(prob(70) && compare_z(rbmkzlevel, apc.get_virtual_z_level()))
			apc.overload_lighting()
	var/datum/gas_mixture/coolant_input = linked_input.airs[1]
	var/datum/gas_mixture/moderator_input = linked_moderator.airs[1]
	var/datum/gas_mixture/coolant_output = linked_output.airs[1]
	moderator_input.temperature = temperature*2
	coolant_output.temperature = temperature*2
	reactor_turf.assume_air(coolant_input)
	reactor_turf.assume_air(moderator_input)
	reactor_turf.assume_air(coolant_output)
	explosion(get_turf(src), 0, 5, 10, 20, TRUE, TRUE)
	empulse(get_turf(src), 20, 30)
	SSblackbox.record_feedback("tally", "engine_stats", 1, "failed")
	SSblackbox.record_feedback("tally", "engine_stats", 1, "agcnr")

	// make a little bit of spicy mess, maximum of 4+25=29 tile radius, minimum of 4+4=8 tile radius, scaled on how far over temperature it is
	var/obj/modules/power/rbmk/nuclear_sludge_spawner/nuclear_sludge_spawner = new /obj/modules/power/rbmk/nuclear_sludge_spawner(get_turf(src))
	nuclear_sludge_spawner.range = 4 + min(25,floor(4 * max(1,(temperature-RBMK_TEMPERATURE_CRITICAL)/RBMK_TEMPERATURE_CRITICAL))) // scales by an extra 4 tile radius per 100% over maximum
	nuclear_sludge_spawner.fire()
	Destroy()

/obj/machinery/atmospherics/components/unary/rbmk/core/proc/blowout()
	explosion(get_turf(src), GLOB.MAX_EX_DEVESTATION_RANGE, GLOB.MAX_EX_HEAVY_RANGE, GLOB.MAX_EX_LIGHT_RANGE, GLOB.MAX_EX_FLASH_RANGE)
	var/turf/reactor_turf = get_turf(src)
	var/rbmkzlevel = reactor_turf.get_virtual_z_level()
	for(var/mob/player_mob in GLOB.player_list)
		if(compare_z(rbmkzlevel, player_mob.get_virtual_z_level()))
			SEND_SOUND(player_mob, 'sound/effects/rbmk/explode.ogg')
			to_chat(player_mob, span_userdanger("You hear a horrible metallic explosion."))
			SEND_SIGNAL(player_mob, COMSIG_ADD_MOOD_EVENT, "delam", /datum/mood_event/delam) //Might as well use the same moodlet since its essentialy the same thing happening
	for(var/nuclear_sludge_landmark in GLOB.landmarks_list)
		if(istype(nuclear_sludge_landmark, /obj/modules/power/rbmk/nuclear_sludge_spawner))
			var/obj/modules/power/rbmk/nuclear_sludge_spawner/nuclear_sludge_spawner = nuclear_sludge_landmark
			if(compare_z(rbmkzlevel, nuclear_sludge_spawner.get_virtual_z_level())) //Begin the SLUDGING
				nuclear_sludge_spawner.fire()
	var/obj/modules/power/rbmk/nuclear_sludge_spawner/nuclear_sludge_spawner = new /obj/modules/power/rbmk/nuclear_sludge_spawner/strong(get_turf(src))
	nuclear_sludge_spawner.fire() //This will take out engineering for a decent amount of time as they have to clean up the sludge.
	meltdown() //Double kill.

//Plutonium sludge

#define PLUTONIUM_SLUDGE_RANGE 50
#define PLUTONIUM_SLUDGE_RANGE_STRONG 80
#define PLUTONIUM_SLUDGE_RANGE_WEAK 20

#define PLUTONIUM_SLUDGE_CHANCE 15


/obj/modules/power/rbmk/nuclear_sludge_spawner //Clean way of spawning nuclear gunk after a reactor core meltdown.
	name = "nuclear waste spawner"
	var/range = PLUTONIUM_SLUDGE_RANGE //tile radius to spawn goop
	var/center_sludge = TRUE // Whether or not the center turf should spawn sludge or not.
	var/static/list/avoid_objs = typecacheof(list( // List of objs that the waste does not spawn on
		/obj/structure/stairs, // Sludge is hidden below stairs
		/obj/structure/ladder, // Going down the ladder directly on sludge bad
		/obj/effect/decal/cleanable/nuclear_waste, // No stacked sludge
		/obj/structure/girder,
		/obj/structure/grille,
		/obj/structure/window/fulltile,
		/obj/structure/window/plasma/fulltile,
		/obj/structure/window/reinforced/plasma/fulltile,
		/obj/structure/window/reinforced/plasma/plastitanium,
		/obj/structure/window/reinforced/fulltile,
		/obj/structure/window/reinforced/clockwork/fulltile,
		/obj/structure/window/reinforced/tinted/fulltile,
		/obj/structure/window,
		/obj/structure/window/shuttle,
		/obj/machinery/gateway,
		/obj/machinery/gravity_generator,
	))
/// Tries to place plutonium sludge on 'floor'. Returns TRUE if the turf has been successfully processed, FALSE otherwise.
/obj/modules/power/rbmk/nuclear_sludge_spawner/proc/place_sludge(turf/open/floor, epicenter = FALSE)
	if(!floor)
		return FALSE

	if(epicenter)
		for(var/obj/effect/decal/cleanable/nuclear_waste/waste in floor) //Replace nuclear waste with the stronger version
			qdel(waste)
		return TRUE

	if(!prob(PLUTONIUM_SLUDGE_CHANCE)) //Scatter the sludge, don't smear it everywhere
		return TRUE

	for(var/obj/object in floor)
		if(avoid_objs[object.type])
			return TRUE

	new /obj/effect/decal/cleanable/nuclear_waste (floor)
	return TRUE

/obj/modules/power/rbmk/nuclear_sludge_spawner/strong
	range = PLUTONIUM_SLUDGE_RANGE_STRONG

/obj/modules/power/rbmk/nuclear_sludge_spawner/weak
	range = PLUTONIUM_SLUDGE_RANGE_WEAK
	center_sludge = FALSE

/obj/modules/power/rbmk/nuclear_sludge_spawner/proc/fire()
	playsound(src, 'sound/effects/gib_step.ogg', 100)

	if(center_sludge)
		place_sludge(get_turf(src), TRUE)

	for(var/turf/open/floor in orange(range, get_turf(src)))
		place_sludge(floor, FALSE)

	qdel(src)

#undef PLUTONIUM_SLUDGE_RANGE
#undef PLUTONIUM_SLUDGE_RANGE_STRONG
#undef PLUTONIUM_SLUDGE_RANGE_WEAK
#undef PLUTONIUM_SLUDGE_CHANCE
