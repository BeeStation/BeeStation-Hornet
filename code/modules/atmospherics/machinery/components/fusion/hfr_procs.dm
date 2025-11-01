/**
 * This section contain all procs that helps building, destroy and control the hfr
 */

/**
 * Called by multitool_act() in hfr_parts.dm, by atmos_process() in hfr_main_processes.dm and by fusion_process() in the same file
 * This proc checks the surrounding of the core to ensure that the machine has been build correctly, returns false if there is a missing piece/wrong placed one
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/check_part_connectivity()
	. = TRUE
	if(!anchored || panel_open)
		return FALSE

	for(var/obj/machinery/hypertorus/object in orange(1,src))
		if(. == FALSE)
			break

		if(object.panel_open)
			. = FALSE

		if(istype(object,/obj/machinery/hypertorus/corner))
			var/dir = get_dir(src,object)
			if(dir in GLOB.cardinals)
				. = FALSE
			switch(dir)
				if(SOUTHEAST)
					if(object.dir != SOUTH)
						. = FALSE
				if(SOUTHWEST)
					if(object.dir != WEST)
						. = FALSE
				if(NORTHEAST)
					if(object.dir != EAST)
						. = FALSE
				if(NORTHWEST)
					if(object.dir != NORTH)
						. = FALSE
			corners |= object
			continue

		if(get_step(object,REVERSE_DIR(object.dir)) != loc)
			. = FALSE

		if(istype(object,/obj/machinery/hypertorus/interface))
			if(linked_interface && linked_interface != object)
				. = FALSE
			linked_interface = object

	for(var/obj/machinery/atmospherics/components/unary/hypertorus/object in orange(1,src))
		if(. == FALSE)
			break

		if(object.panel_open)
			. = FALSE

		if(get_step(object,REVERSE_DIR(object.dir)) != loc)
			. = FALSE

		if(istype(object,/obj/machinery/atmospherics/components/unary/hypertorus/fuel_input))
			if(linked_input && linked_input != object)
				. = FALSE
			linked_input = object
			machine_parts |= object

		if(istype(object,/obj/machinery/atmospherics/components/unary/hypertorus/waste_output))
			if(linked_output && linked_output != object)
				. = FALSE
			linked_output = object
			machine_parts |= object

		if(istype(object,/obj/machinery/atmospherics/components/unary/hypertorus/moderator_input))
			if(linked_moderator && linked_moderator != object)
				. = FALSE
			linked_moderator = object
			machine_parts |= object

	if(!linked_interface || !linked_input || !linked_moderator || !linked_output || corners.len != 4)
		. = FALSE

/**
 * Called by multitool_act() in hfr_parts.dm
 * It sets the pieces to active, allowing the player to start the main reaction
 * Arguments:
 * * -user: the player doing the action
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/activate(mob/living/user)
	if(active)
		to_chat(user, span_notice("You already activated the machine."))
		return
	to_chat(user, span_notice("You link all parts toghether."))
	active = TRUE
	update_appearance(UPDATE_ICON)
	linked_interface.active = TRUE
	linked_interface.update_appearance(UPDATE_ICON)
	RegisterSignal(linked_interface, COMSIG_QDELETING, PROC_REF(unregister_signals))
	linked_input.active = TRUE
	linked_input.update_appearance(UPDATE_ICON)
	RegisterSignal(linked_input, COMSIG_QDELETING, PROC_REF(unregister_signals))
	linked_output.active = TRUE
	linked_output.update_appearance(UPDATE_ICON)
	RegisterSignal(linked_output, COMSIG_QDELETING, PROC_REF(unregister_signals))
	linked_moderator.active = TRUE
	linked_moderator.update_appearance(UPDATE_ICON)
	RegisterSignal(linked_moderator, COMSIG_QDELETING, PROC_REF(unregister_signals))
	for(var/obj/machinery/hypertorus/corner/corner in corners)
		corner.active = TRUE
		corner.update_appearance(UPDATE_ICON)
		RegisterSignal(corner, COMSIG_QDELETING, PROC_REF(unregister_signals))
	soundloop = new(src, TRUE)
	soundloop.volume = 5

/**
 * Called when a part gets deleted around the hfr, called on Destroy() of the hfr core in hfr_core.dm
 * Unregister the signals attached to the core from the various machines, if only_signals is false it will also call deactivate()
 * Arguments:
 * * only_signals: default FALSE, if true the proc will not call the deactivate() proc
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/unregister_signals(only_signals = FALSE)
	SIGNAL_HANDLER
	if(linked_interface)
		UnregisterSignal(linked_interface, COMSIG_QDELETING)
	if(linked_input)
		UnregisterSignal(linked_input, COMSIG_QDELETING)
	if(linked_output)
		UnregisterSignal(linked_output, COMSIG_QDELETING)
	if(linked_moderator)
		UnregisterSignal(linked_moderator, COMSIG_QDELETING)
	for(var/obj/machinery/hypertorus/corner/corner in corners)
		UnregisterSignal(corner, COMSIG_QDELETING)
	if(!only_signals)
		deactivate()

/**
 * Called by unregister_signals() in this file, called when the main fusion processes check_part_connectivity() returns false
 * Deactivate the various machines by setting the active var to false, updates the machines icon and set the linked machine vars to null
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/deactivate()
	if(!active)
		return
	active = FALSE
	update_appearance(UPDATE_ICON)
	if(linked_interface)
		linked_interface.active = FALSE
		linked_interface.update_appearance(UPDATE_ICON)
		linked_interface = null
	if(linked_input)
		linked_input.active = FALSE
		linked_input.update_appearance(UPDATE_ICON)
		linked_input = null
	if(linked_output)
		linked_output.active = FALSE
		linked_output.update_appearance(UPDATE_ICON)
		linked_output = null
	if(linked_moderator)
		linked_moderator.active = FALSE
		linked_moderator.update_appearance(UPDATE_ICON)
		linked_moderator = null
	if(corners.len)
		for(var/obj/machinery/hypertorus/corner/corner in corners)
			corner.active = FALSE
			corner.update_appearance(UPDATE_ICON)
		corners = list()
	QDEL_NULL(soundloop)

/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/assert_gases()
	//Assert the gases that will be used/created during the process

	internal_fusion.assert_gas(/datum/gas/antinoblium)

	moderator_internal.assert_gases(arglist(GLOB.meta_gas_info))

	if(!selected_fuel)
		return

	internal_fusion.assert_gases(arglist(selected_fuel.requirements | selected_fuel.primary_products))

/**
 * Updates all related pipenets from all connected components
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/update_pipenets()
	update_parents()
	linked_input.update_parents()
	linked_output.update_parents()
	linked_moderator.update_parents()

/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/update_temperature_status(seconds_per_tick)
	fusion_temperature_archived = fusion_temperature
	fusion_temperature = internal_fusion.temperature
	moderator_temperature_archived = moderator_temperature
	moderator_temperature = moderator_internal.temperature
	coolant_temperature_archived = coolant_temperature
	coolant_temperature = airs[1].temperature
	output_temperature_archived = output_temperature
	output_temperature = linked_output.airs[1].temperature
	temperature_period = seconds_per_tick

	//Set the power level of the fusion process
	switch(fusion_temperature)
		if(-INFINITY to 500)
			power_level = 0
		if(500 to 1e3)
			power_level = 1
		if(1e3 to 1e4)
			power_level = 2
		if(1e4 to 1e5)
			power_level = 3
		if(1e5 to 1e6)
			power_level = 4
		if(1e6 to 1e7)
			power_level = 5
		else
			power_level = 6

/**
 * Infrequently plays accent sounds, and adjusts main loop parameters
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/play_ambience()
	// We play delam/neutral sounds at a rate determined by power and critical_threshold_proximity
	if(last_accent_sound < world.time && prob(20))
		var/aggression = min(((critical_threshold_proximity / 800) * ((power_level) / 5)), 1.0) * 100
		if(critical_threshold_proximity >= 300)
			playsound(src, "hypertorus_melting", max(50, aggression), FALSE, 40, 30, falloff_distance = 10)
		else
			playsound(src, "hypertorus_calm", max(50, aggression), FALSE, 25, 25, falloff_distance = 10)
		var/next_sound = round((100 - aggression) * 5) + 5
		last_accent_sound = world.time + max(HYPERTORUS_ACCENT_SOUND_MIN_COOLDOWN, next_sound)

	var/ambient_hum = 1
	if(check_fuel())
		ambient_hum = power_level + 1
	soundloop.volume = clamp(ambient_hum * 8, 0, 50)

/**
 * Called by the main fusion processes in hfr_main_processes.dm
 * Getter for fusion fuel moles
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/check_fuel()
	if(!selected_fuel)
		return FALSE
	if(!internal_fusion.total_moles())
		return FALSE
	for(var/gas_type in selected_fuel.requirements)
		internal_fusion.assert_gas(gas_type)
		if(internal_fusion.gases[gas_type][MOLES] < FUSION_MOLE_THRESHOLD)
			return FALSE
	return TRUE

/**
 * Called by the main fusion processes in hfr_main_processes.dm
 * Check the power use of the machine, return TRUE if there is enough power in the powernet
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/check_power_use()
	if(machine_stat & (NOPOWER|BROKEN))
		return FALSE
	if(use_power == ACTIVE_POWER_USE)
		update_mode_power_usage(ACTIVE_POWER_USE, (power_level + 1) * MIN_POWER_USAGE) //Max around 350 KW

	return TRUE

///Checks if the gases in the input are the ones needed by the recipe
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/check_gas_requirements()
	var/datum/gas_mixture/contents = linked_input.airs[1]
	for(var/gas_type in selected_fuel.requirements)
		if(!contents.gases[gas_type] || !contents.gases[gas_type][MOLES])
			return FALSE
	return TRUE

///Removes the gases from the internal gasmix when the recipe is changed
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/dump_gases()
	var/datum/gas_mixture/remove = internal_fusion.remove(internal_fusion.total_moles())
	linked_output.airs[1].merge(remove)
	internal_fusion.garbage_collect()
	linked_input.airs[1].garbage_collect()

/**
 * Called by alarm() in this file
 * Check the integrity level and returns the status of the machine
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/get_status()
	var/integrity = get_integrity_percent()
	if(integrity < HYPERTORUS_MELTING_PERCENT)
		return HYPERTORUS_MELTING

	if(integrity < HYPERTORUS_EMERGENCY_PERCENT)
		return HYPERTORUS_EMERGENCY

	if(integrity < HYPERTORUS_DANGER_PERCENT)
		return HYPERTORUS_DANGER

	if(integrity < HYPERTORUS_WARNING_PERCENT)
		return HYPERTORUS_WARNING

	if(power_level > 0)
		return HYPERTORUS_NOMINAL
	return HYPERTORUS_INACTIVE

/**
 * Called by check_alert() in this file
 * Play a sound from the machine, the type depends on the status of the hfr
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/alarm()
	switch(get_status())
		if(HYPERTORUS_MELTING)
			playsound(src, 'sound/misc/bloblarm.ogg', 100, FALSE, 40, 30, falloff_distance = 10)
		if(HYPERTORUS_EMERGENCY)
			playsound(src, 'sound/machines/engine_alert1.ogg', 100, FALSE, 30, 30, falloff_distance = 10)
		if(HYPERTORUS_DANGER)
			playsound(src, 'sound/machines/engine_alert2.ogg', 100, FALSE, 30, 30, falloff_distance = 10)
		if(HYPERTORUS_WARNING)
			playsound(src, 'sound/machines/terminal_alert.ogg', 75)

/**
 * Getter for the machine integrity
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/get_integrity_percent()
	var/integrity = critical_threshold_proximity / melting_point
	integrity = round(100 - integrity * 100, 0.01)
	integrity = integrity < 0 ? 0 : integrity
	return integrity

/**
 * Get how charged the area's APC is
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/get_area_cell_percent()
	// Make sure to get APC levels from the same area the core draws from
	// Just in case people build an HFR across boundaries
	var/area/area = get_area(src)
	if(!area)
		return 0
	var/obj/machinery/power/apc/apc = area.apc
	if(!apc)
		return 0
	var/obj/item/stock_parts/cell/cell = apc.cell
	if(!cell)
		return 0
	return cell.percent()

/**
 * Called by process_atmos() in hfr_main_processes.dm
 * Called after checking the damage of the machine, calls alarm() and countdown()
 * Broadcast messages into engi and common radio
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/check_alert()
	if(critical_threshold_proximity < warning_point)
		return
	if((REALTIMEOFDAY - lastwarning) / 10 >= WARNING_TIME_DELAY)
		alarm()

		if(critical_threshold_proximity > emergency_point)
			radio.talk_into(src, "[emergency_alert] Integrity: [get_integrity_percent()]%", common_channel)
			lastwarning = REALTIMEOFDAY
			if(!has_reached_emergency)
				investigate_log("has reached the emergency point for the first time.", INVESTIGATE_HYPERTORUS)
				message_admins("[src] has reached the emergency point [ADMIN_JMP(src)].")
				has_reached_emergency = TRUE
			send_radio_explanation()
		else if(critical_threshold_proximity >= critical_threshold_proximity_archived) // The damage is still going up
			radio.talk_into(src, "[warning_alert] Integrity: [get_integrity_percent()]%", engineering_channel)
			lastwarning = REALTIMEOFDAY - (WARNING_TIME_DELAY * 5)
			send_radio_explanation()
		else // Phew, we're safe
			radio.talk_into(src, "[safe_alert] Integrity: [get_integrity_percent()]%", engineering_channel)
			lastwarning = REALTIMEOFDAY

	//Melt
	if(critical_threshold_proximity > melting_point)
		countdown()

/obj/machinery/atmospherics/components/unary/hypertorus/core/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	warning_damage_flags |= HYPERTORUS_FLAG_EMPED


/**
 * Called by check_alert() in this file
 * Called to explain in radio what the issues are with the HFR
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/send_radio_explanation()

	if(warning_damage_flags & HYPERTORUS_FLAG_EMPED)
		var/list/characters = list()
		characters += GLOB.alphabet
		characters += GLOB.alphabet_upper
		characters += GLOB.numerals
		characters += " "
		characters += " "
		var/message = random_string(rand(50,70), characters)
		radio.talk_into(src, "[message]", engineering_channel)
		return

	if(warning_damage_flags & HYPERTORUS_FLAG_HIGH_POWER_DAMAGE)
		radio.talk_into(src, "Warning! Shield destabilizing due to excessive power!", engineering_channel)
	if(warning_damage_flags & HYPERTORUS_FLAG_IRON_CONTENT_DAMAGE)
		radio.talk_into(src, "Warning! Iron shards are damaging the internal core shielding!", engineering_channel)
	if(warning_damage_flags & HYPERTORUS_FLAG_HIGH_FUEL_MIX_MOLE)
		radio.talk_into(src, "Warning! Fuel mix moles reaching critical levels!", engineering_channel)
	if(warning_damage_flags & HYPERTORUS_FLAG_IRON_CONTENT_INCREASE)
		radio.talk_into(src, "Warning! Iron amount inside the core is increasing!", engineering_channel)

/**
 * Called by check_alert() in this file
 * Called when the damage has reached critical levels, start the countdown before the destruction, calls meltdown()
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/countdown()
	set waitfor = FALSE

	if(final_countdown) // We're already doing it go away
		return
	final_countdown = TRUE

	var/critical = selected_fuel.meltdown_flags & HYPERTORUS_FLAG_CRITICAL_MELTDOWN
	if(critical)
		priority_announce("WARNING - The explosion will likely cover a big part of the station and the coming EMP will wipe out most of the electronics. \
				Get as far away as possible from the reactor or find a way to shut it down.", "Alert", 'sound/misc/notice3.ogg')
	var/speaking = "[emergency_alert] The Hypertorus fusion reactor has reached critical integrity failure. Emergency magnetic dampeners online."
	radio.talk_into(src, speaking, common_channel)

	notify_ghosts(
		"The [src] has begun melting down!",
		source = src,
		header = "Meltdown Incoming",
		ghost_sound = 'sound/machines/warning-buzzer.ogg',
		notify_volume = 75,
	)

	for(var/i in HYPERTORUS_COUNTDOWN_TIME to 0 step -10)
		if(critical_threshold_proximity < melting_point) // Cutting it a bit close there engineers
			radio.talk_into(src, "[safe_alert] Failsafe has been disengaged.", common_channel)
			final_countdown = FALSE
			return
		else if((i % 50) != 0 && i > 50) // A message once every 5 seconds until the final 5 seconds which count down individually
			sleep(1 SECONDS)
			continue
		else if(i > 50)
			if(i == 10 SECONDS && critical)
				sound_to_playing_players('sound/machines/hypertorus/HFR_critical_explosion.ogg')
			speaking = "[DisplayTimeText(i, TRUE)] remain before total integrity failure."
		else
			speaking = "[i*0.1]..."
		radio.talk_into(src, speaking, common_channel)
		sleep(1 SECONDS)

	meltdown()

/**
 * Called by countdown() in this file
 * Create the explosion + the gas emission before deleting the machine core.
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/meltdown()
	var/flash_explosion = 0
	var/light_impact_explosion = 0
	var/heavy_impact_explosion = 0
	var/devastating_explosion = 0
	var/em_pulse = selected_fuel.meltdown_flags & HYPERTORUS_FLAG_EMP
	var/rad_pulse = selected_fuel.meltdown_flags & HYPERTORUS_FLAG_RADIATION_PULSE
	var/emp_light_size = 0
	var/emp_heavy_size = 0
	var/rad_pulse_size = 0
	var/gas_spread = 0
	var/gas_pockets = 0
	var/critical = selected_fuel.meltdown_flags & HYPERTORUS_FLAG_CRITICAL_MELTDOWN

	if(selected_fuel.meltdown_flags & HYPERTORUS_FLAG_BASE_EXPLOSION)
		flash_explosion = power_level * 3
		light_impact_explosion = power_level * 2

	if(selected_fuel.meltdown_flags & HYPERTORUS_FLAG_MEDIUM_EXPLOSION)
		flash_explosion = power_level * 6
		light_impact_explosion = power_level * 5
		heavy_impact_explosion = power_level * 0.5

	if(selected_fuel.meltdown_flags & HYPERTORUS_FLAG_DEVASTATING_EXPLOSION)
		flash_explosion = power_level * 8
		light_impact_explosion = power_level * 7
		heavy_impact_explosion = power_level * 2
		devastating_explosion = power_level

	if(selected_fuel.meltdown_flags & HYPERTORUS_FLAG_MINIMUM_SPREAD)
		if(em_pulse)
			emp_light_size = power_level * 3
			emp_heavy_size = power_level * 1
		if(rad_pulse)
			rad_pulse_size = 2 * power_level + 8
		gas_pockets = 5
		gas_spread = power_level * 2

	if(selected_fuel.meltdown_flags & HYPERTORUS_FLAG_MEDIUM_SPREAD)
		if(em_pulse)
			emp_light_size = power_level * 5
			emp_heavy_size = power_level * 3
		if(rad_pulse)
			rad_pulse_size = power_level + 24
		gas_pockets = 7
		gas_spread = power_level * 4

	if(selected_fuel.meltdown_flags & HYPERTORUS_FLAG_BIG_SPREAD)
		if(em_pulse)
			emp_light_size = power_level * 7
			emp_heavy_size = power_level * 5
		if(rad_pulse)
			rad_pulse_size = power_level + 34
		gas_pockets = 10
		gas_spread = power_level * 6

	if(selected_fuel.meltdown_flags & HYPERTORUS_FLAG_MASSIVE_SPREAD)
		if(em_pulse)
			emp_light_size = power_level * 9
			emp_heavy_size = power_level * 7
		if(rad_pulse)
			rad_pulse_size = power_level + 44
		gas_pockets = 15
		gas_spread = power_level * 8

	var/list/around_turfs = circle_range_turfs(src, gas_spread)
	for(var/turf/turf as anything in around_turfs)
		if(isclosedturf(turf) || isspaceturf(turf))
			around_turfs -= turf
			continue
	var/datum/gas_mixture/remove_fusion
	if(internal_fusion.total_moles() > 0)
		remove_fusion = internal_fusion.remove_ratio(0.2)
		var/datum/gas_mixture/remove
		for(var/i in 1 to gas_pockets)
			remove = remove_fusion.remove_ratio(1/gas_pockets)
			var/turf/local = pick(around_turfs)
			local.assume_air(remove)
		loc.assume_air(internal_fusion)
	var/datum/gas_mixture/remove_moderator
	if(moderator_internal.total_moles() > 0)
		remove_moderator = moderator_internal.remove_ratio(0.2)
		var/datum/gas_mixture/remove
		for(var/i in 1 to gas_pockets)
			remove = remove_moderator.remove_ratio(1/gas_pockets)
			var/turf/local = pick(around_turfs)
			local.assume_air(remove)
		loc.assume_air(moderator_internal)

	//Max explosion ranges: devastation = 12, heavy = 24, light = 42
	explosion(
		epicenter = src,
		devastation_range = critical ? devastating_explosion * 2 : devastating_explosion,
		heavy_impact_range = critical ?  heavy_impact_explosion * 2 : heavy_impact_explosion,
		light_impact_range = light_impact_explosion,
		flash_range = flash_explosion,
		adminlog = TRUE,
		ignorecap = TRUE
		)

	if(rad_pulse)
		radiation_pulse(
			source = loc,
			max_range = rad_pulse_size,
			threshold = 0.05,
		)

	if(em_pulse)
		empulse(
			epicenter = loc,
			heavy_range = critical ? emp_heavy_size * 2 : emp_heavy_size,
			light_range = critical ? emp_light_size * 2 : emp_heavy_size,
			log = TRUE
		)

	qdel(src)

/*
 * HFR cracking related procs
 */

/**
 * Checks for any hypertorus part that is cracked and returns it if found, otherwise returns null.
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/check_cracked_parts()
	for(var/obj/machinery/atmospherics/components/unary/hypertorus/part in machine_parts)
		if(part.cracked)
			return part

/**
 * Causes a random hypertorus part in machine_parts to become cracked and update their appearance.
 * Returns the hypertorus part.
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/create_crack() as /obj/machinery/atmospherics/components/unary/hypertorus
	var/obj/machinery/atmospherics/components/unary/hypertorus/part = pick(machine_parts)
	part.cracked = TRUE
	part.update_appearance(UPDATE_ICON)
	return part

/**
 * Takes a ratio portion of target_mix and moves it to the origin's location's air.
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/spill_gases(obj/origin, datum/gas_mixture/target_mix, ratio)
	var/datum/gas_mixture/remove_mixture = target_mix.remove_ratio(ratio)
	var/turf/origin_turf = origin.loc
	if(!origin_turf)
		return
	origin_turf.assume_air(remove_mixture)

/**
 * Processes leaking from moderator hypercriticality.
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/process_moderator_overflow(seconds_per_tick)
	var/obj/machinery/atmospherics/components/unary/hypertorus/cracked_part = check_cracked_parts()
	// Processing of a preexisting crack if any.
	if(cracked_part)
		// We have an existing crack
		var/leak_rate
		if(moderator_internal.return_pressure() < HYPERTORUS_MEDIUM_SPILL_PRESSURE)
			// Not high pressure, but can still leak
			if(!prob(HYPERTORUS_WEAK_SPILL_CHANCE))
				return
			leak_rate = HYPERTORUS_WEAK_SPILL_RATE
		else if(moderator_internal.return_pressure() < HYPERTORUS_STRONG_SPILL_PRESSURE)
			// Lots of gas in here, out we go
			leak_rate = HYPERTORUS_MEDIUM_SPILL_RATE
		else
			// Gotta go fast
			leak_rate = HYPERTORUS_STRONG_SPILL_RATE
		spill_gases(cracked_part, moderator_internal, ratio = 1 - (1 - leak_rate) ** seconds_per_tick)
		return

	// No crack. Check for conditions to cause a leak and create a crack if possible.
	if(moderator_internal.total_moles() < HYPERTORUS_HYPERCRITICAL_MOLES)
		return
	cracked_part = create_crack()
	// See if we do anything in the initial rupture
	if(moderator_internal.return_pressure() < HYPERTORUS_MEDIUM_SPILL_PRESSURE)
		return
	if(moderator_internal.return_pressure() < HYPERTORUS_STRONG_SPILL_PRESSURE)
		// Medium explosion on initial rupture
		explosion(
			epicenter = cracked_part,
			devastation_range = 0,
			heavy_impact_range = 0,
			light_impact_range = 1,
			flame_range = 3,
			flash_range = 3
			)
		spill_gases(cracked_part, moderator_internal, ratio = HYPERTORUS_MEDIUM_SPILL_INITIAL)
		return
	// Enough pressure for a strong explosion. Oh dear, oh dear.
	explosion(
		epicenter = cracked_part,
		devastation_range = 0,
		heavy_impact_range = 1,
		light_impact_range = 3,
		flame_range = 5,
		flash_range = 5
		)
	spill_gases(cracked_part, moderator_internal, ratio = HYPERTORUS_STRONG_SPILL_INITIAL)
	return
