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

	/// Current thrust level being produced (-20 to +20)
	var/thrust_level = 0
	/// Requested thrust level from control computer (-20 to +20)
	var/requested_thrust = 0
	/// Whether we have sufficient fuel
	var/has_fuel = FALSE

	/// How many moles of propellant needed per thrust level per tick
	var/propellant_per_thrust = 0.1
	/// Target buffer amount for propellant
	var/buffer_target = 10
	/// Internal fuel buffer separate from the pipe connection because I cannot fucking get the pipe to stop equalizing
	var/datum/gas_mixture/fuel_buffer

/obj/machinery/atmospherics/components/unary/orbital_thruster/Initialize(mapload)
	. = ..()
	// Create our isolated internal fuel buffer
	fuel_buffer = new
	fuel_buffer.volume = 200 // Same as default airs volume
	fuel_buffer.temperature = T20C

	// If they MAKE us do this, at least make the pipe very small
	var/datum/gas_mixture/pipe_connection = airs[1]
	pipe_connection.volume = 0.1 // Tiny volume for connection only

	SSorbital_altitude.orbital_thrusters += src

/obj/machinery/atmospherics/components/unary/orbital_thruster/Destroy()
	QDEL_NULL(fuel_buffer)
	SSorbital_altitude.orbital_thrusters -= src
	return ..()

/obj/machinery/atmospherics/components/unary/orbital_thruster/process()
	// Gradually step thrust_level toward requested_thrust (one level per tick)
	// But only if we have fuel
	if(!has_fuel)
		// No fuel - ramp down immediately to zero
		thrust_level = 0
	else if(thrust_level < requested_thrust)
		thrust_level++
	else if(thrust_level > requested_thrust)
		thrust_level--

/obj/machinery/atmospherics/components/unary/orbital_thruster/process_atmos()
	..()

	// Use our isolated fuel buffer instead of airs[1]
	if(!fuel_buffer)
		has_fuel = FALSE
		update_appearance()
		return

	// Ensure the gas type exists in our internal buffer
	ASSERT_GAS(/datum/gas/hydrogen_fuel, fuel_buffer)

	// Calculate required propellant
	var/required_moles = abs(thrust_level) * propellant_per_thrust

	// Now check if we have enough fuel in our internal buffer
	var/available_fuel = fuel_buffer.gases[/datum/gas/hydrogen_fuel][MOLES]

	// Check if we have enough fuel to maintain thrust
	if(available_fuel >= required_moles)
		// Consume the propellant from our internal buffer
		var/datum/gas_mixture/removed = fuel_buffer.remove_specific(/datum/gas/hydrogen_fuel, required_moles)
		qdel(removed)

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

/obj/machinery/orbital_thruster_nozzle/Initialize(mapload)
	. = ..()
	begin_processing()
	soundloop = new(src, FALSE)

/obj/machinery/orbital_thruster_nozzle/Destroy()
	if(visual_thrust > 0)
		remove_emitter("thruster")
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/orbital_thruster_nozzle/process()
	// Get the global thrust level from the subsystem
	var/target_thrust = abs(SSorbital_altitude.thrust)

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
				damaged_obj.take_damage(damage / 2)
				if(!played_sound)
					playsound(affected_turf, 'sound/effects/wounds/sizzle1.ogg', 50, vary = TRUE)
					played_sound = TRUE

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
