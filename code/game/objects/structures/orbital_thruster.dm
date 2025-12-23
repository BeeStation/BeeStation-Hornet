// File is a three-parter. We have the following components:
// 1) The actual functional thruster component that handles the pipe connections and all the calculations.
// 2) The piece that's still a machine and still processing, but it's more of a visual dummy that just makes the effect happen and damages people.
// 3) The dummy structure pieces that make up the visual representation of the thruster.
// To the player this is all one seamless object.



// Functional Component. Functions as follows:
// Listens for signals from the main thruster control computer to determine at what thrust level to operate at.
// Connects to a gas source via piping to draw propellant from.
// Determines the amount of propellant to draw based on the thrust level requested.
// If there is not enough propellant, it will not work at all and activate a little blinky light overlay(low_fuel) to indicate lack of propellant.
// If there is enough propellant, it will consume the propellant and set a var/thrust_level.
// Thrust is just a simple number from -20 to 20.
// Of course we also don't have it take power or anything like that, it's a mostly just a prop even with the functional bit.

// The thrust system itself is just arcadey, handled in the subsystem that keeps references to all thrusters and just checks their thrust vars and sets the internal thrust to the sum of it all.
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

/obj/machinery/atmospherics/components/unary/orbital_thruster/Initialize(mapload)
	. = ..()
	SSorbital_altitude.orbital_thrusters += src

/obj/machinery/atmospherics/components/unary/orbital_thruster/Destroy()
	SSorbital_altitude.orbital_thrusters -= src
	return ..()

/obj/machinery/atmospherics/components/unary/orbital_thruster/process()
	// Gradually step thrust_level toward requested_thrust (one level per tick)
	if(thrust_level < requested_thrust)
		thrust_level++
	else if(thrust_level > requested_thrust)
		thrust_level--

/obj/machinery/atmospherics/components/unary/orbital_thruster/process_atmos()
	..()

	// Calculate required propellant (use absolute value for consumption)
	var/required_moles = abs(thrust_level) * propellant_per_thrust

	// Check if we have enough propellant in our air network
	var/datum/gas_mixture/air_contents = airs[1]
	if(!air_contents)
		has_fuel = FALSE
		thrust_level = 0
		update_appearance()
		return

	// Check if we have sufficient gas
	if(air_contents.total_moles() >= required_moles)
		// Consume the propellant
		air_contents.remove(required_moles)
		has_fuel = TRUE
	else
		// Not enough fuel - stop the thruster
		has_fuel = FALSE
		thrust_level = 0

	update_appearance()

/obj/machinery/atmospherics/components/unary/orbital_thruster/update_overlays()
	. = ..()
	if(!has_fuel && requested_thrust > 0)
		. += "low_fuel"

/obj/machinery/atmospherics/components/unary/orbital_thruster/proc/set_thrust(new_thrust)
	requested_thrust = clamp(new_thrust, -20, 20)


// Effect Component. This is what actually does the visual effects and damage application when the thruster is active.
// It literally just takes SSorbital_altitude.thrust, spawns particles depending on the thrust level from 0 to 40.
// Notably means it has to be processing. Also applies damage to anything in front of it based on thrust level.
// Since it's more of a prop than a real machine, we make sure it takes no power or anything of the sort
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
	var/target_thrust = SSorbital_altitude.thrust

	// Update particles based on thrust level
	if(target_thrust > 0 && target_thrust != visual_thrust)
		update_thruster_effect(target_thrust)
	else if(target_thrust == 0 && visual_thrust > 0)
		stop_thruster_effect()

	// Update sound loop based on thrust level
	if(target_thrust > 0)
		if(!soundloop.loop_started)
			soundloop.start()
		// Calculate volume based on thrust percentage (0-40 range maps to 30-100 volume)
		soundloop.volume = clamp(30 + ((target_thrust / 40) * 70), 30, 100)
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
	var/base_damage = SSorbital_altitude.thrust * 2

	// Cast ray for 5 tiles
	for(var/i = 1 to 5)
		current_turf = get_step(current_turf, dir)
		if(!current_turf)
			break

		// Get the current turf and its adjacent turfs
		var/list/affected_turfs = list(current_turf)
		affected_turfs += get_adjacent_open_turfs(current_turf)

		// Calculate damage falloff based on distance (100% at tile 1, 20% at tile 5)
		var/distance_multiplier = 1 - ((i - 1) * 0.2)
		var/damage = base_damage * distance_multiplier

		// Apply damage to all affected turfs
		for(var/turf/T in affected_turfs)
			// Apply damage to all mobs in the turf
			for(var/mob/living/L in T)
				L.adjustFireLoss(damage)

			// Also damage objects
			for(var/obj/O in T)
				if(O.resistance_flags & INDESTRUCTIBLE)
					continue
				O.take_damage(damage / 2)



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
