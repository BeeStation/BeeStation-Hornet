// Functional Component.
/obj/machinery/atmospherics/components/unary/orbital_thruster
	name = "orbital thruster"
	desc = "A massive thruster used to adjust the station's orbit."
	icon = 'icons/obj/orbital_thruster.dmi'
	max_integrity = 50000000
	icon_state = "2"
	device_type = UNARY
	anchored = TRUE
	density = TRUE
	dir = NORTH
	initialize_directions = NORTH
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1

	/// Current thrust level being produced (-20 to +20). Steps one level/tick toward `requested_thrust`.
	var/thrust_level = 0
	/// Requested thrust level from control computer (-20 to +20).
	var/requested_thrust = 0
	/// Whether the buffer currently holds enough fuel to keep firing.
	var/has_fuel = FALSE

	/// Idle propellant burn (moles/tick) at thrust 0.
	var/idle_propellant = 0.5
	/// Additional propellant burn (moles/tick) per unit of |thrust_level|.
	var/propellant_per_thrust = 0.025
	/// Target moles of fuel to keep in the internal buffer.
	var/buffer_target = 10
	/// Volume (L) of the internal buffer. Independent of the pipe network volume.
	var/buffer_volume = 200
	/// Buffer fraction below which `has_fuel` flips false (multiplied by `buffer_target`).
	var/low_fuel_fraction = 0.5
	/// Internal fuel buffer, separate from the pipe-network gas mixture so that
	/// fuel we've "claimed" can't be siphoned back out by pipenet equalization.
	var/datum/gas_mixture/fuel_buffer

	/// Internal radio for broadcasting fault warnings on the engineering channel.
	var/obj/item/radio/radio
	/// Encryption key our internal radio uses.
	var/radio_key = /obj/item/encryptionkey/headset_eng

	/// Whether the thruster is currently in a fuel-fault state.
	var/fuel_fault = FALSE
	/// World time when fuel was last detected in the buffer.
	var/last_fuel_time = 0
	/// How long without fuel before entering fault state.
	var/fuel_fault_threshold = 1 MINUTES
	/// How often, while in fault, to re-broadcast the warning on radio.
	var/fuel_fault_report_interval = 10 MINUTES
	/// Cooldown for periodic fault radio reports.
	COOLDOWN_DECLARE(fuel_fault_report_cooldown)

/obj/machinery/atmospherics/components/unary/orbital_thruster/Initialize(mapload)
	. = ..()
	// Create our isolated internal fuel buffer.
	fuel_buffer = new
	fuel_buffer.volume = buffer_volume
	fuel_buffer.temperature = T20C

	// Shrink our pipe-side gas mixture to a token volume. The pipenet equalizes
	// across all connected mixtures by volume, so anything we let collect on the
	// machine side gets sucked back into the network.
	var/datum/gas_mixture/node_air = airs[1]
	node_air.volume = 0.1

	// Set up our internal radio for engineering channel warnings.
	radio = new(src)
	radio.keyslot = new radio_key
	radio.set_listening(FALSE)
	radio.recalculateChannels()

	// Assume fuel is present at spawn so we don't immediately start a fault timer.
	last_fuel_time = world.time
	has_fuel = TRUE

	SSorbital_altitude.orbital_thrusters += src

/obj/machinery/atmospherics/components/unary/orbital_thruster/Destroy()
	QDEL_NULL(fuel_buffer)
	QDEL_NULL(radio)
	SSorbital_altitude.orbital_thrusters -= src
	return ..()

/// Override LateInitialize to generate our unique name AFTER the parent's update_name() call.
/// The atmospherics base type calls update_name() in LateInitialize, which would overwrite
/// any name set during Initialize() with "[pipe_color_name] [initial(name)]" (e.g. "omni orbital thruster").
/obj/machinery/atmospherics/components/unary/orbital_thruster/LateInitialize()
	. = ..()
	generate_unique_name()

/// Generate a unique thruster name based on x-coordinate.
/// The first thruster on a column is "OT-<x>"; each subsequent thruster on the
/// same column gets a letter suffix starting at A (so the second is "OT-<x>-A",
/// the third "OT-<x>-B", and so on, rolling over to AA, AB, ... past Z).
/obj/machinery/atmospherics/components/unary/orbital_thruster/proc/generate_unique_name()
	// Prevent the atmospherics base type from clobbering this name in update_name().
	override_naming = TRUE

	var/base_name = "OT-[x]"

	// Count siblings already on this column.
	var/sibling_count = 0
	for(var/obj/machinery/atmospherics/components/unary/orbital_thruster/other in SSorbital_altitude.orbital_thrusters)
		if(other == src)
			continue
		if(other.x == x)
			sibling_count++

	if(!sibling_count)
		name = base_name
		return

	name = "[base_name]-[suffix_for_index(sibling_count)]"

/// Convert a 1-based index into a spreadsheet-style letter suffix (1 -> A, 26 -> Z, 27 -> AA, ...).
/obj/machinery/atmospherics/components/unary/orbital_thruster/proc/suffix_for_index(index)
	var/result = ""
	while(index > 0)
		var/remainder = ((index - 1) % 26)
		result = "[ascii2text(65 + remainder)][result]"
		index = round((index - 1) / 26)
	return result

/obj/machinery/atmospherics/components/unary/orbital_thruster/process()
	// Step thrust_level one unit per tick toward requested_thrust.
	if(!has_fuel)
		thrust_level = 0
	else if(thrust_level < requested_thrust)
		thrust_level++
	else if(thrust_level > requested_thrust)
		thrust_level--

	update_fuel_fault()

/// Update fuel fault state. Enters fault if no fuel for `fuel_fault_threshold`. Re-broadcasts every `fuel_fault_report_interval`.
/obj/machinery/atmospherics/components/unary/orbital_thruster/proc/update_fuel_fault()
	if(has_fuel)
		last_fuel_time = world.time
		if(fuel_fault)
			fuel_fault = FALSE
			radio.talk_into(src, "Fuel supply restored. Fault condition cleared.", RADIO_CHANNEL_ENGINEERING)
		return

	// Out of fuel: enter fault once we've been dry past the threshold.
	if(!fuel_fault && (world.time - last_fuel_time >= fuel_fault_threshold))
		fuel_fault = TRUE
		var/threshold_minutes = round(fuel_fault_threshold / (1 MINUTES), 0.1)
		radio.talk_into(src, "WARNING: No fuel supply detected for over [threshold_minutes] minute(s). Entering fault state. Restore fuel supply to clear.", RADIO_CHANNEL_ENGINEERING)
		COOLDOWN_START(src, fuel_fault_report_cooldown, fuel_fault_report_interval)
		return

	// Periodic fault reminders.
	if(fuel_fault && COOLDOWN_FINISHED(src, fuel_fault_report_cooldown))
		var/time_without_fuel = round((world.time - last_fuel_time) / (1 MINUTES), 0.1)
		radio.talk_into(src, "FAULT: No fuel supply for [time_without_fuel] minutes. Fuel line inspection required.", RADIO_CHANNEL_ENGINEERING)
		COOLDOWN_START(src, fuel_fault_report_cooldown, fuel_fault_report_interval)

/obj/machinery/atmospherics/components/unary/orbital_thruster/process_atmos()
	if(!fuel_buffer)
		has_fuel = FALSE
		update_appearance()
		return

	// 1) Burn fuel from the internal buffer.
	// Always burns at least idle_propellant; ramps up with thrust_level.
	ASSERT_GAS(/datum/gas/hydrogen_fuel, fuel_buffer)
	var/required_moles = idle_propellant + (abs(thrust_level) * propellant_per_thrust)
	if(fuel_buffer.gases[/datum/gas/hydrogen_fuel][MOLES] >= required_moles)
		qdel(fuel_buffer.remove_specific(/datum/gas/hydrogen_fuel, required_moles))

	// 2) Top the buffer back up from the connected pipenet, if any.
	var/datum/pipenet/parent_net = parents[1]
	if(parent_net?.air)
		ASSERT_GAS(/datum/gas/hydrogen_fuel, fuel_buffer)
		ASSERT_GAS(/datum/gas/hydrogen_fuel, parent_net.air)
		var/fuel_deficit = buffer_target - fuel_buffer.gases[/datum/gas/hydrogen_fuel][MOLES]
		var/available_in_network = parent_net.air.gases[/datum/gas/hydrogen_fuel][MOLES]
		if(fuel_deficit > 0 && available_in_network > 0)
			var/fuel_to_pump = min(fuel_deficit, available_in_network)
			var/datum/gas_mixture/fuel_removed = parent_net.air.remove_specific(/datum/gas/hydrogen_fuel, fuel_to_pump)
			fuel_buffer.merge(fuel_removed)
			qdel(fuel_removed)
			update_parents()

	// 3) Update the has_fuel flag based on the resulting buffer level.
	ASSERT_GAS(/datum/gas/hydrogen_fuel, fuel_buffer)
	has_fuel = fuel_buffer.gases[/datum/gas/hydrogen_fuel][MOLES] >= (buffer_target * low_fuel_fraction)

	update_appearance()

/obj/machinery/atmospherics/components/unary/orbital_thruster/update_overlays()
	. = ..()
	if(!has_fuel)
		. += "low_fuel"

/// Set target thrust level for thruster. The thruster will gradually ramp to this level over time.
/obj/machinery/atmospherics/components/unary/orbital_thruster/proc/set_thrust(new_thrust)
	requested_thrust = clamp(new_thrust, -20, 20)

/// Return our fuel buffer for gas analyzers
/obj/machinery/atmospherics/components/unary/orbital_thruster/return_analyzable_air()
	return fuel_buffer

// Effect Component.
/obj/machinery/orbital_thruster_nozzle
	name = "orbital thruster"
	desc = "A massive thruster used to adjust the station's orbit."
	icon = 'icons/obj/orbital_thruster.dmi'
	icon_state = "14"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	max_integrity = 50000000
	anchored = TRUE
	density = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 0

	/// Current thrust level being produced, copied from the linked thruster for easy access.
	var/thrust = 0
	/// How many tiles north of the nozzle the linked thruster body sits.
	var/backend_tile_offset = 4
	/// How many tiles ahead of the nozzle thrust damage extends.
	var/thrust_damage_range = 5
	/// Damage scalar applied to `linked_thruster.thrust_level` when computing per-tile damage.
	var/thrust_damage_scale = 4

	/// Sound loop for the thruster.
	var/datum/looping_sound/orbital_thruster/soundloop

	/// The backend thruster body this nozzle is linked to.
	var/obj/machinery/atmospherics/components/unary/orbital_thruster/linked_thruster

/obj/machinery/orbital_thruster_nozzle/Initialize(mapload)
	. = ..()

	linked_thruster = find_backend()
	if(!linked_thruster)
		message_admins("Orbital Thruster Nozzle at [AREACOORD(src)] could not find its backend piece! Please inform the mappers.")
		return

	begin_processing()
	soundloop = new(src, FALSE)

/obj/machinery/orbital_thruster_nozzle/Destroy()
	remove_emitter("thruster")
	QDEL_NULL(soundloop)
	return ..()

/// How hard the linked thruster is firing right now, in 0..20.
/obj/machinery/orbital_thruster_nozzle/proc/get_current_thrust()
	if(!linked_thruster?.has_fuel)
		return 0
	return abs(linked_thruster.thrust_level)

/obj/machinery/orbital_thruster_nozzle/process()
	thrust = get_current_thrust()

	if(thrust > 0)
		// Particles: spawn the emitter if it isn't already up, then size it to current thrust.
		if(!master_holder?.emitters["thruster"])
			add_emitter(/obj/emitter/thruster_jet, "thruster")
		var/obj/emitter/thruster_jet/emitter = master_holder?.emitters["thruster"]
		if(emitter?.particles)
			emitter.particles.count = thrust * 50      // 0..1000
			emitter.particles.spawning = thrust * 0.5  // 0..10

		// Sound: 0..20 -> 5..100 volume.
		if(!soundloop.loop_started)
			soundloop.start()
		soundloop.volume = round(5 + 95 * thrust / 20)

		apply_thrust_damage()
	else
		remove_emitter("thruster")
		if(soundloop.loop_started)
			soundloop.stop()

	update_appearance()

/obj/machinery/orbital_thruster_nozzle/update_overlays()
	. = ..()
	if(thrust <= 0)
		return
	var/mutable_appearance/glow = mutable_appearance('icons/obj/orbital_thrust_effect.dmi', "glow")
	glow.alpha = round(255 * thrust / 20)
	glow.pixel_x = -32
	glow.pixel_y = -8
	glow.layer = ABOVE_OBJ_LAYER
	. += glow

/obj/machinery/orbital_thruster_nozzle/proc/apply_thrust_damage()
	if(!linked_thruster)
		return

	var/turf/current_turf = get_turf(src)
	if(!current_turf)
		return

	// Damage scales with this nozzle's own thruster
	var/base_damage = abs(linked_thruster.thrust_level) * thrust_damage_scale
	if(base_damage <= 0)
		return

	for(var/distance = 1 to thrust_damage_range)
		current_turf = get_step(current_turf, dir)
		if(!current_turf)
			break

		// Damage falls off linearly: 100% at tile 1 down to 20% at tile 5.
		var/distance_multiplier = 1 - ((distance - 1) / thrust_damage_range)
		var/damage = base_damage * distance_multiplier

		var/list/affected_turfs = list(current_turf) + get_adjacent_open_turfs(current_turf)

		// Play the sizzle sound at most once per ring, not per turf or per victim.
		var/played_sound = FALSE
		for(var/turf/affected_turf in affected_turfs)
			// Don't damage space tiles
			if(!isspaceturf(affected_turf))
				affected_turf.take_damage(damage)

			for(var/mob/living/living_mob in affected_turf)
				living_mob.adjustFireLoss(damage)
				if(!played_sound)
					playsound(affected_turf, 'sound/effects/wounds/sizzle1.ogg', 50, vary = TRUE)
					played_sound = TRUE

			for(var/obj/damaged_obj in affected_turf)
				if(damaged_obj.resistance_flags & INDESTRUCTIBLE)
					continue
				damaged_obj.take_damage(damage)
				if(!played_sound)
					playsound(affected_turf, 'sound/effects/wounds/sizzle1.ogg', 50, vary = TRUE)
					played_sound = TRUE

/// Walk `backend_tile_offset` tiles north of the nozzle and return the first
/// thruster body found there. Always NORTH because the template is built that way.
/obj/machinery/orbital_thruster_nozzle/proc/find_backend()
	var/turf/target_turf = get_turf(src)
	if(!target_turf)
		return null

	for(var/i in 1 to backend_tile_offset)
		target_turf = get_step(target_turf, NORTH)
		if(!target_turf)
			return null

	return locate(/obj/machinery/atmospherics/components/unary/orbital_thruster) in target_turf

// Dummy Pieces that do nothing but look pretty. Iterate icon_states to get different parts.
/obj/structure/orbital_thruster_dummy
	name = "orbital thruster"
	desc = "A massive thruster used to adjust the station's orbit."
	icon = 'icons/obj/orbital_thruster.dmi'
	icon_state = "1"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	max_integrity = 50000000
	anchored = TRUE
	density = TRUE
