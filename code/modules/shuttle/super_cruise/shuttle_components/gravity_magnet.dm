APPLY_PLACEHOLDER_TEXT(/obj/machinery/gravity_magnet, "passive gravity anchor")

/obj/machinery/gravity_magnet
	name = "gravity anchor"
	desc = "A machine which can be attached onto asteroids in order to tow them with a gravity magnet."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_redemption"
	density = TRUE
	anchored = TRUE

	/// The gravity magnet which we are currently linked to, 2 way link
	var/obj/machinery/gravity_magnet/linked

	/// What do we get when we pick this up?
	var/pickup_type = /obj/item/deployable/gravity_magnet

/obj/machinery/gravity_magnet/Initialize(mapload)
	. = ..()
	GLOB.zclear_blockers += src

/obj/machinery/gravity_magnet/ComponentInitialize()
	. = ..()
	RegisterSignal(src, COMSIG_PARENT_RECIEVE_BUFFER, PROC_REF(handle_buffer_action))

/obj/machinery/gravity_magnet/Destroy()
	linked?.linked = null
	GLOB.zclear_blockers -= src
	return ..()

/obj/machinery/gravity_magnet/examine(mob/user)
	. = ..()
	. += "Use a multitool to link it to a gravity magnet."

/obj/machinery/gravity_magnet/attack_hand(mob/living/user)
	if (pickup_type != null)
		to_chat(user, "<span class='notice'>You begin picking up [src]...</span>")
		if (do_after(user, 5 SECONDS, src))
			var/obj/item/created = new pickup_type(loc)
			if (istype(created))
				user.put_in_active_hand(created)
			qdel(src)
	else
		return ..()

/obj/machinery/gravity_magnet/proc/handle_buffer_action(datum/source, mob/user, datum/buffer, obj/item/buffer_parent)
	if (istype(buffer, /obj/machinery/gravity_magnet))
		var/obj/machinery/gravity_magnet/other_magnet = buffer
		linked = other_magnet
		other_magnet.linked = src
		to_chat(user, "<span class='notice'>You successfully link the 2 magnets together.</span>")
		return COMPONENT_BUFFER_RECIEVED
	else if (TRY_STORE_IN_BUFFER(buffer_parent, src))
		to_chat(user, "<span class='notice'>You successfully store [src] into [buffer_parent]'s buffer.</span>")
		return COMPONENT_BUFFER_RECIEVED
	else if (linked)
		linked.linked = null
		linked = null
		to_chat(user, "<span class='notice'>You disconnect the magnets.</span>")
		return COMPONENT_BUFFER_RECIEVED

/obj/machinery/gravity_magnet/proc/get_magnet_location()
	var/turf/location = get_turf(src)
	if (!location)
		return null
	var/virtual_z = location.get_virtual_z_level()
	return SSorbits.assoc_z_levels["[virtual_z]"]

APPLY_PLACEHOLDER_TEXT(/obj/machinery/gravity_magnet/active, "active gravity anchor")

/obj/machinery/gravity_magnet/active
	name = "gravity-tow generator"
	desc = "A machine which allows for the towing of orbital bodies."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_redemption"

	circuit = /obj/item/circuitboard/machine/gravity_magnet

	pickup_type = null

	// Distance that the object follows behind us
	var/pull_distance = 60.1

	var/multiplier_n = 1

	/// The strength that the magnet pulls the other one towards it
	var/magnet_strength = 5

	/// Are we an active magnet?
	var/active_magnet = TRUE

/obj/machinery/gravity_magnet/active/process(delta_time)
	// If the z-levels are the same, then stop processing
	if (!should_process())
		return PROCESS_KILL
	// Pull the 2 objects closer together towards a point behind the direction of motion.
	// We do not want the pulled object to be moving faster than we are, so try and match the velocity with some
	// minor adjustments to get it in an optimal position

	// Get our orbital object
	var/datum/orbital_object/source_location = get_magnet_location()
	var/datum/orbital_object/pulled_object = linked.get_magnet_location()
	// We want to get our velocity to be the same as the target velocity, with a slight push towards the position that we want to be in
	var/datum/orbital_vector/desired_velocity = source_location.velocity.Copy()

	// Make our desired velocity push us towards object we are following
	var/datum/orbital_vector/towards_target = source_location.position - pulled_object.position
	towards_target /= max(sqrt(towards_target.Length()), 1)

	desired_velocity += towards_target

	// Calculate the delta
	var/datum/orbital_vector/delta = desired_velocity - pulled_object.velocity
	var/delta_length = delta.Length()
	delta.NormalizeSelf()
	delta *= min(magnet_strength * delta_time, delta_length)
	pulled_object.velocity += delta

/// When the Z changes, check if we need to start pulling our target object.
/// Just in case this is force moved to another Z-Level.
/obj/machinery/gravity_magnet/active/onTransitZ(old_z, new_z)
	. = ..()
	zchange_check()

/// When moved by a shuttle, needs to be here instead of onTransitZ since onTransitZ doesn't respect shuttle ordering.
/obj/machinery/gravity_magnet/active/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)
	. = ..()
	zchange_check()

/obj/machinery/gravity_magnet/active/proc/zchange_check()
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
/obj/machinery/gravity_magnet/active/proc/should_process()
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

/**
 * Gravity magnet deployer.
 *
 * Allows for a gravity magnet to be quickly destroyed.
 */

APPLY_PLACEHOLDER_TEXT(/obj/item/deployable/gravity_magnet, "gravity anchor")

/obj/item/deployable/gravity_magnet
	name = "gravity anchor deployer"
	desc = "A device which deploys a gravity anchor, capable of being connected to a gravity magnet."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	w_class = WEIGHT_CLASS_SMALL
	deployed_object = /obj/machinery/gravity_magnet
