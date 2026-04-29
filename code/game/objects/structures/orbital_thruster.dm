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

/// Generate a unique thruster name based on x-coordinate. Appends -A, -B, etc. if multiple thrusters share the same x.
/obj/machinery/atmospherics/components/unary/orbital_thruster/proc/generate_unique_name()
	var/base_name = "OT-[x]"
	// Check for other thrusters at the same x-coordinate
	var/list/same_x_thrusters = list()
	for(var/obj/machinery/atmospherics/components/unary/orbital_thruster/other in SSorbital_altitude.orbital_thrusters)
		if(other == src)
			continue
		if(other.x == x)
			same_x_thrusters += other
	if(length(same_x_thrusters))
		// There are other thrusters at this x, assign suffixes
		// First, rename existing ones if they haven't been suffixed yet
		var/suffix_index = 1
		for(var/obj/machinery/atmospherics/components/unary/orbital_thruster/other in same_x_thrusters)
			// Only rename if they still have the unsuffixed base name
			if(other.name == base_name)
				var/suffix_letter = ascii2text(64 + suffix_index) // A, B, C...
				other.name = "[base_name]-[suffix_letter]"
				suffix_index++
			else
				// Already suffixed, find the highest suffix index
				suffix_index = max(suffix_index, length(same_x_thrusters) + 1)
		// Now assign our own suffix
		var/our_suffix = ascii2text(64 + length(same_x_thrusters) + 1)
		name = "[base_name]-[our_suffix]"
	else
		name = base_name
	// Prevent the atmospherics base type from overwriting our name via update_name()
	override_naming = TRUE

/obj/machinery/atmospherics/components/unary/orbital_thruster/process()
	// Gradually step thrust_level toward requested_thrust (one level per tick)
	// But only if we have fuel
	if(!has_fuel)
		// No fuel, ramp down immediately to zero
		thrust_level = 0
	else if(thrust_level < requested_thrust)
		thrust_level++
	else if(thrust_level > requested_thrust)
		thrust_level--

	// Track fuel fault state
	update_fuel_fault()

/// Update fuel fault state. Enters fault if no fuel for over 1 minute. Reports on engineering radio every 10 minutes.
/obj/machinery/atmospherics/components/unary/orbital_thruster/proc/update_fuel_fault()
	if(has_fuel)
		last_fuel_time = world.time
		if(fuel_fault)
			fuel_fault = FALSE
			// Notify engineering that the fault has cleared
			radio.talk_into(src, "Fuel supply restored. Fault condition cleared.", RADIO_CHANNEL_ENGINEERING)
		return

	// No fuel, check if we've exceeded the fault threshold
	if(!fuel_fault && (world.time - last_fuel_time >= fuel_fault_threshold))
		fuel_fault = TRUE
		// Immediate warning when first entering fault state
		radio.talk_into(src, "WARNING: No fuel supply detected for over 1 minute. Entering fault state. Restore fuel supply to clear.", RADIO_CHANNEL_ENGINEERING)
		COOLDOWN_START(src, fuel_fault_report_cooldown, 10 MINUTES)

	// Periodic fault reports every 10 minutes
	if(fuel_fault && COOLDOWN_FINISHED(src, fuel_fault_report_cooldown))
		var/time_without_fuel = round((world.time - last_fuel_time) / (1 MINUTES), 0.1)
		radio.talk_into(src, "FAULT: No fuel supply for [time_without_fuel] minutes. Fuel line inspection required.", RADIO_CHANNEL_ENGINEERING)
		COOLDOWN_START(src, fuel_fault_report_cooldown, 10 MINUTES)

/obj/machinery/atmospherics/components/unary/orbital_thruster/process_atmos()
	// Use our isolated fuel buffer instead of airs[1]
	if(!fuel_buffer)
		has_fuel = FALSE
		update_appearance()
		return

	// Ensure the gas type exists in our internal buffer
	ASSERT_GAS(/datum/gas/hydrogen_fuel, fuel_buffer)

	// Calculate required propellant. Ramp smoothly from 0.5 moles at thrust 0 to 1.0 moles at thrust 20
	var/required_moles = 0.5 + (abs(thrust_level) * propellant_per_thrust)

	// Now check if we have enough fuel in our internal buffer
	var/available_fuel = fuel_buffer.gases[/datum/gas/hydrogen_fuel][MOLES]

	// Check if we have enough fuel to maintain thrust
	if(available_fuel >= required_moles)
		// Consume the propellant from our internal buffer
		var/datum/gas_mixture/removed = fuel_buffer.remove_specific(/datum/gas/hydrogen_fuel, required_moles)
		qdel(removed)

	// Re-assert gas entry exists in buffer after potential removal
	ASSERT_GAS(/datum/gas/hydrogen_fuel, fuel_buffer)

	// We have used, or may have used, fuel. Now we pull to keep the buffer up.
	// Get whatever net we are connected to
	var/datum/pipenet/parent_net = parents[1]

	// If it exists and has contents, proceed
	if(parent_net && parent_net.air)

		// Ensure the gas type exists in the network
		ASSERT_GAS(/datum/gas/hydrogen_fuel, parent_net.air)

		// Check how much we have to work with inside the network
		var/available_in_network = parent_net.air.gases[/datum/gas/hydrogen_fuel][MOLES]

		// Check how much is inside our buffer.
		var/current_fuel = fuel_buffer.gases[/datum/gas/hydrogen_fuel][MOLES]

		// Calculate the deficit.
		var/fuel_deficit = buffer_target - current_fuel

		// Take what is required from the net and add it to our buffer.
		if(fuel_deficit > 0 && available_in_network > 0)
			// Pump in fuel to fill the deficit
			var/fuel_to_pump = min(fuel_deficit, available_in_network)
			var/datum/gas_mixture/fuel_removed = parent_net.air.remove_specific(/datum/gas/hydrogen_fuel, fuel_to_pump)
			fuel_buffer.merge(fuel_removed)
			qdel(fuel_removed)

	// Now we set the has_fuel flag.
	// If our buffer is less than half our target, we do not have fuel.
	if(fuel_buffer.gases[/datum/gas/hydrogen_fuel][MOLES] < (buffer_target / 2))
		has_fuel = FALSE
	else
		has_fuel = TRUE

	// Update the pipe network once at the end if we modified anything
	update_parents()
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

	/// Current visual thrust level
	var/visual_thrust = 0
	/// Sound loop for the thruster
	var/datum/looping_sound/orbital_thruster/soundloop

	/// The backend thruster piece this nozzle is linked to
	var/obj/machinery/atmospherics/components/unary/orbital_thruster/back_end_piece

/obj/machinery/orbital_thruster_nozzle/Initialize(mapload)
	. = ..()

	back_end_piece = find_backend()
	if(!back_end_piece)
		message_admins("Orbital Thruster Nozzle could not find backend piece! Please inform the mappers.")
		return

	if(!back_end_piece)
		return

	begin_processing()
	soundloop = new(src, FALSE)

/obj/machinery/orbital_thruster_nozzle/Destroy()
	if(visual_thrust > 0)
		remove_emitter("thruster")
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/orbital_thruster_nozzle/process()
	// Get the thrust level
	var/target_thrust = 0

	// Only show thrust if backend exists and has fuel
	if(back_end_piece && back_end_piece.has_fuel)
		target_thrust = abs(back_end_piece.thrust_level) * 2 // Scale from -20 to +20 range to -40 to +40 for visuals

	// Update particles based on thrust level
	if(target_thrust > 0 && target_thrust != visual_thrust)
		update_thruster_effect(target_thrust)
	else if(target_thrust == 0 && visual_thrust > 0)
		stop_thruster_effect()

	// Update sound loop based on thrust level
	if(target_thrust > 0)
		if(!soundloop.loop_started)
			soundloop.start()
		// Calculate volume based on thrust percentage (0-40 range maps to 5-100 volume)
		soundloop.volume = clamp(5 + ((target_thrust / 40) * 95), 5, 100)
	else if(soundloop.loop_started)
		soundloop.stop()

	visual_thrust = target_thrust

	// Update appearance for glow overlay
	update_appearance()

	// Apply damage to anything in the thrust direction
	if(visual_thrust > 0)
		apply_thrust_damage()

/obj/machinery/orbital_thruster_nozzle/update_overlays()
	. = ..()
	if(visual_thrust > 0)
		var/mutable_appearance/glow = mutable_appearance('icons/obj/orbital_thrust_effect.dmi', "glow")
		// Calculate alpha based on thrust level (0-40 range from subsystem)
		// Scale from 0 to 255 alpha
		glow.alpha = clamp((visual_thrust / 40) * 255, 0, 255)
		glow.pixel_x = -32
		glow.pixel_y = -8
		glow.layer = ABOVE_OBJ_LAYER
		. += glow

/obj/machinery/orbital_thruster_nozzle/proc/update_thruster_effect(thrust)
	// Add or update the thruster effect
	if(!master_holder || !master_holder.emitters["thruster"])
		add_emitter(/obj/emitter/thruster_jet, "thruster")

	// Update particle intensity based on thrust level (0-40 range from subsystem)
	if(master_holder && master_holder.emitters["thruster"])
		var/obj/emitter/thruster_jet/emitter = master_holder.emitters["thruster"]
		if(emitter && emitter.particles)
			// Scale count from 0 to 1000 based on thrust (0-40)
			emitter.particles.count = clamp(thrust * 25, 0, 1000)
			// Scale spawning from 1 to 10 based on thrust
			emitter.particles.spawning = clamp(thrust * 0.25, 1, 10)

/obj/machinery/orbital_thruster_nozzle/proc/stop_thruster_effect()
	remove_emitter("thruster")

/obj/machinery/orbital_thruster_nozzle/proc/apply_thrust_damage()
	// Cast a ray 5 tiles in the direction of the thruster
	var/turf/current_turf = get_turf(src)
	if(!current_turf)
		return

	// Calculate base damage based on thrust level
	var/base_damage = abs(SSorbital_altitude.thrust * 2)

	// Cast ray for 5 tiles
	for(var/distance = 1 to 5)
		current_turf = get_step(current_turf, dir)
		if(!current_turf)
			break

		// Get the current turf and its adjacent turfs
		var/list/affected_turfs = list(current_turf)
		affected_turfs += get_adjacent_open_turfs(current_turf)

		// Calculate damage falloff based on distance (100% at tile 1, 20% at tile 5)
		var/distance_multiplier = 1 - ((distance - 1) * 0.2)
		var/damage = base_damage * distance_multiplier

		// Track if we played sound this tick for this turf to avoid spam
		var/played_sound = FALSE

		// Apply damage to all affected turfs
		for(var/turf/affected_turf in affected_turfs)
			// Damage turfs themselves
			affected_turf.take_damage(damage)

			// Apply damage to all mobs in the turf
			for(var/mob/living/living_mob in affected_turf)
				living_mob.adjustFireLoss(damage)
				if(!played_sound)
					playsound(affected_turf, 'sound/effects/wounds/sizzle1.ogg', 50, vary = TRUE)
					played_sound = TRUE

			// Also damage objects
			for(var/obj/damaged_obj in affected_turf)
				if(damaged_obj.resistance_flags & INDESTRUCTIBLE)
					continue
				damaged_obj.take_damage(damage)

				if(!played_sound)
					playsound(affected_turf, 'sound/effects/wounds/sizzle1.ogg', 50, vary = TRUE)
					played_sound = TRUE

/obj/machinery/orbital_thruster_nozzle/proc/find_backend()
	// Step 6 tiles north to find the backend piece
	var/turf/target_turf = get_turf(src)
	if(!target_turf)
		return null

	// Step 4 times in the NORTH direction
	for(var/step_count = 1 to 4)
		target_turf = get_step(target_turf, NORTH)
		if(!target_turf)
			return null

	// Find the backend piece in the target turf
	for(var/obj/machinery/atmospherics/components/unary/orbital_thruster/thruster in target_turf)
		return thruster

	return null

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
