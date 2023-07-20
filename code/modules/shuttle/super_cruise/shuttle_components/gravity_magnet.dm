/obj/machinery/gravity_magnet
	name = "gravity magnet"
	desc = "A machine which allows for the towing of orbital bodies."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_redemption"

	// Distance that the object follows behind us
	var/pull_distance = 60.1

	var/multiplier_n = 1

	/// The strength that the magnet pulls the other one towards it
	var/magnet_strength = 25

	/// Are we an active magnet?
	var/active_magnet = FALSE

	/// The gravity magnet which we are currently linked to, 2 way link
	var/obj/machinery/gravity_magnet/linked

/obj/machinery/gravity_magnet/Destroy()
	linked?.linked = null
	return ..()

/obj/machinery/gravity_magnet/process(delta_time)
	// If the z-levels are the same, then stop processing
	if (!should_process())
		return PROCESS_KILL
	// Pull the 2 objects closer together towards a point behind the direction of motion.
	// We do not want the pulled object to be moving faster than we are, so try and match the velocity with some
	// minor adjustments to get it in an optimal position

	// Get our orbital object
	var/datum/orbital_object/source_location = get_magnet_location()
	var/datum/orbital_object/pulled_object = linked.get_magnet_location()
	// Determine what we want our target velocity to be
	var/datum/orbital_vector/target_velocity = new /datum/orbital_vector(source_location.velocity.x, source_location.velocity.y)
	// Get a vector towards the location that we want to move towards
	var/datum/orbital_vector/normalised_velocity = source_location.velocity.Copy()
	normalised_velocity.NormalizeSelf()
	normalised_velocity.ScaleSelf(pull_distance)
	// Get the target position
	var/datum/orbital_vector/target_position = source_location.position.Add(normalised_velocity)
	// Get the velocity vector towards this target position
	var/datum/orbital_vector/towards_target_position = target_position.AddSelf(pulled_object.position.Scale(-1))
	//towards_target_position.NormalizeSelf()
	//towards_target_position.ScaleSelf(multiplier_n)	//Debug
	target_velocity.AddSelf(towards_target_position)
	// Try to get the object to the target velocity
	var/datum/orbital_vector/delta_v = pulled_object.velocity.Add(target_velocity.ScaleSelf(-1))
	delta_v.NormalizeSelf()
	delta_v.ScaleSelf(magnet_strength)
	pulled_object.velocity.AddSelf(delta_v)

/// When the Z changes, check if we need to start pulling our target object.
/// Just in case this is force moved to another Z-Level.
/obj/machinery/gravity_magnet/onTransitZ(old_z, new_z)
	. = ..()
	zchange_check()

/// When moved by a shuttle, needs to be here instead of onTransitZ since onTransitZ doesn't respect shuttle ordering.
/obj/machinery/gravity_magnet/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)
	. = ..()
	zchange_check()

/obj/machinery/gravity_magnet/proc/zchange_check()
	// Passive magnet (reciever) or disabled, don't do anything
	if (!active_magnet)
		return
	// If we aren't processing, start processing
	if (datum_flags & DF_ISPROCESSING)
		return
	if (!should_process())
		return
	// Fire at the same rate as orbits
	START_PROCESSING(SSorbits, src)

/// Check if we should start processing and pull the objects together
/obj/machinery/gravity_magnet/proc/should_process()
	if (!linked)
		return FALSE
	var/datum/orbital_object/source_object = get_magnet_location()
	var/datum/orbital_object/target_object = linked.get_magnet_location()
	if (!source_object || !target_object)
		return FALSE
	if (source_object == target_object)
		return FALSE
	// Check if we can move the objects
	if (source_object.static_object || target_object.static_object)
		return FALSE
	// Check if we are too far away and are forced to disconnect
	//TODO
	return TRUE

/obj/machinery/gravity_magnet/proc/get_magnet_location()
	var/turf/location = get_turf(src)
	if (!location)
		return null
	var/virtual_z = location.get_virtual_z_level()
	return SSorbits.assoc_z_levels["[virtual_z]"]
