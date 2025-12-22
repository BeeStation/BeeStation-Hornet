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

/obj/machinery/atmospherics/components/unary/orbital_thruster/process_atmos()
	..()

	// Calculate required propellant (use absolute value for consumption)
	var/required_moles = abs(requested_thrust) * propellant_per_thrust

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
		thrust_level = requested_thrust
	else
		// Not enough fuel
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
	/// Particle effect holder
	var/obj/effect/abstract/particle_holder/particle_effect

/obj/machinery/orbital_thruster_nozzle/Initialize(mapload)
	. = ..()
	begin_processing()

/obj/machinery/orbital_thruster_nozzle/Destroy()
	QDEL_NULL(particle_effect)
	return ..()

/obj/machinery/orbital_thruster_nozzle/process()
	// Get the global thrust level from the subsystem
	var/target_thrust = SSorbital_altitude.thrust

	// Update particles based on thrust level
	if(target_thrust > 0 && target_thrust != visual_thrust)
		update_thruster_effect(target_thrust)
	else if(target_thrust == 0 && visual_thrust > 0)
		stop_thruster_effect()

	visual_thrust = target_thrust

	// Apply damage to anything in the thrust direction
	if(visual_thrust > 0)
		apply_thrust_damage()

/obj/machinery/orbital_thruster_nozzle/proc/update_thruster_effect(thrust)
	// Create particle effect if it doesn't exist
	if(!particle_effect)
		particle_effect = new(src)
		particle_effect.add_emitter(/obj/emitter/thruster_jet, "thruster")
		vis_contents += particle_effect

/obj/machinery/orbital_thruster_nozzle/proc/stop_thruster_effect()
	if(particle_effect)
		vis_contents -= particle_effect
		QDEL_NULL(particle_effect)

/obj/machinery/orbital_thruster_nozzle/proc/apply_thrust_damage()
	// Find the turf in front of the thruster based on direction
	var/turf/target_turf = get_step(src, dir)
	if(!target_turf)
		return

	// Calculate damage based on thrust level
	var/damage = visual_thrust * 5 // 0-100 damage based on thrust level

	// Apply damage to all mobs in the target turf
	for(var/mob/living/L in target_turf)
		L.adjustFireLoss(damage)
		if(damage > 20)
			L.throw_at(get_edge_target_turf(target_turf, dir), 5, 1)

	// Also damage objects
	for(var/obj/O in target_turf)
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
