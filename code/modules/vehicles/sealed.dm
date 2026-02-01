/obj/vehicle/sealed
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1 | NO_DIRECT_ACCESS_FROM_CONTENTS_1
	var/enter_delay = 2 SECONDS
	var/mouse_pointer
	/// Is combat indicator on for this vehicle? Boolean.
	var/combat_indicator_vehicle = FALSE

/obj/vehicle/sealed/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(mover in buckled_mobs)
		return TRUE

/obj/vehicle/sealed/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/climb_out)

/obj/vehicle/sealed/generate_action_type()
	var/datum/action/vehicle/sealed/E = ..()
	. = E
	if(istype(E))
		E.vehicle_entered_target = src

/obj/vehicle/sealed/update_overlays()
	. = ..()
	if(combat_indicator_vehicle)
		. += GLOB.combat_indicator_overlay

/**
 * Called whenever a mob inside a vehicle/sealed/ toggles CI status.
 *
 * Tied to the COMSIG_MOB_CI_TOGGLED signal, said signal is assigned when a mob enters a vehicle and unassigned when the mob exits, and is sent whenever set_combat_indicator is called.
 *
 * Arguments:
 * * source -- The mob in question that toggled CI status.
 */

/obj/vehicle/sealed/proc/mob_toggled_ci(mob/living/source)
	SIGNAL_HANDLER
	if ((src.max_occupants > src.max_drivers) && (!(source in return_drivers())) && (src.driver_amount() > 0)) // Only returms true if the mob in question has the driver control flags and/or there are drivers.
		return
	combat_indicator_vehicle = source.combat_indicator	// Sync CI between mob and vehicle.
	if (combat_indicator_vehicle)
		playsound(src, 'sound/machines/chime.ogg', vol = 10, vary = FALSE, extrarange = -6, falloff_exponent = 4, frequency = null, channel = 0, pressure_affected = FALSE, ignore_walls = FALSE, falloff_distance = 1)
		flick_emote_popup_on_obj("combat", 20)
		visible_message(span_boldwarning("[src] prepares for combat!"))
		combat_indicator_vehicle = TRUE
	else
		combat_indicator_vehicle = FALSE
	update_appearance(UPDATE_ICON|UPDATE_OVERLAYS)

//Register the signal to the mob and mechs will listen for when CI is toggled, then call the parent proc, then turn on CI if the mob had CI on.
/obj/vehicle/sealed/add_occupant(mob/occupant_entering, control_flags)
	RegisterSignal(occupant_entering, COMSIG_MOB_CI_TOGGLED, PROC_REF(mob_toggled_ci))
	. = ..()
	handle_ci_migration(occupant_entering)

//Unregister the signal then disable CI if the vehicle has no other drivers within it.
/obj/vehicle/sealed/remove_occupant(mob/occupant_exiting)
	UnregisterSignal(occupant_exiting, COMSIG_MOB_CI_TOGGLED)
	. = ..()
	disable_ci(occupant_exiting)

/obj/vehicle/sealed/MouseDrop_T(atom/dropping, mob/M)
	if(!istype(dropping) || !istype(M))
		return ..()
	if(M != dropping)
		return ..()
	if(occupant_amount() >= max_occupants)
		LoadComponent(/datum/component/leanable, dropping)
		return ..()
	mob_try_enter(M)
	return ..()

/obj/vehicle/sealed/Exited(atom/movable/gone, direction)
	. = ..()
	if(ismob(gone))
		remove_occupant(gone)

// so that we can check the access of the vehicle's occupants. Ridden vehicles do this in the riding component, but these don't have that
/obj/vehicle/sealed/Bump(atom/A)
	. = ..()
	if(istype(A, /obj/machinery/door))
		var/obj/machinery/door/conditionalwall = A
		for(var/m in occupants)
			conditionalwall.bumpopen(m)

/obj/vehicle/sealed/after_add_occupant(mob/M)
	. = ..()
	ADD_TRAIT(M, TRAIT_HANDS_BLOCKED, VEHICLE_TRAIT)

/obj/vehicle/sealed/after_remove_occupant(mob/M)
	. = ..()
	REMOVE_TRAIT(M, TRAIT_HANDS_BLOCKED, VEHICLE_TRAIT)

/obj/vehicle/sealed/proc/mob_try_enter(mob/M)
	if(!istype(M))
		return FALSE
	if(occupant_amount() >= max_occupants)
		return FALSE
	if(do_after(M, get_enter_delay(M), src, progress = TRUE, timed_action_flags = IGNORE_HELD_ITEM))
		mob_enter(M)
		return TRUE
	return FALSE

/obj/vehicle/sealed/proc/get_enter_delay(mob/M)
	return enter_delay

/obj/vehicle/sealed/proc/mob_enter(mob/M, silent = FALSE)
	if(!istype(M))
		return FALSE
	if(!silent)
		M.visible_message(span_notice("[M] climbs into \the [src]!"))
	M.forceMove(src)
	add_occupant(M)
	return TRUE

/obj/vehicle/sealed/proc/mob_try_exit(mob/M, mob/user, silent = FALSE, randomstep = FALSE)
	mob_exit(M, silent, randomstep)

/obj/vehicle/sealed/proc/mob_exit(mob/M, silent = FALSE, randomstep = FALSE)
	SIGNAL_HANDLER
	if(!istype(M))
		return FALSE
	remove_occupant(M)
	if(!isAI(M))//This is the ONE mob we dont want to be moved to the vehicle that should be handeled when used
		M.forceMove(exit_location(M))
	if(randomstep)
		var/turf/target_turf = get_step(exit_location(M), pick(GLOB.cardinals))
		M.throw_at(target_turf, 5, 10)

	if(!silent)
		M.visible_message(span_notice("[M] drops out of \the [src]!"))
	return TRUE

/obj/vehicle/sealed/proc/exit_location(M)
	return drop_location()

/obj/vehicle/sealed/attackby(obj/item/I, mob/user, params)
	if(key_type && !is_key(inserted_key) && is_key(I))
		if(user.transferItemToLoc(I, src))
			to_chat(user, span_notice("You insert [I] into [src]."))
			if(inserted_key)	//just in case there's an invalid key
				inserted_key.forceMove(drop_location())
			inserted_key = I
		else
			to_chat(user, span_notice("[I] seems to be stuck to your hand!"))
		return
	return ..()

/obj/vehicle/sealed/proc/remove_key(mob/user)
	if(!inserted_key)
		to_chat(user, span_notice("There is no key in [src]!"))
		return
	if(!is_occupant(user) || !(occupants[user] & VEHICLE_CONTROL_DRIVE))
		to_chat(user, span_notice("You must be driving [src] to remove [src]'s key!"))
		return
	to_chat(user, span_notice("You remove [inserted_key] from [src]."))
	inserted_key.forceMove(drop_location())
	if(!HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		user.put_in_hands(inserted_key)
	else
		inserted_key.equip_to_best_slot(user, check_hand = FALSE)
	inserted_key = null

/obj/vehicle/sealed/Destroy()
	DumpMobs()
	return ..()

/obj/vehicle/sealed/proc/DumpMobs(randomstep = TRUE)
	for(var/i in occupants)
		mob_exit(i, null, randomstep)
		if(iscarbon(i))
			var/mob/living/carbon/Carbon = i
			Carbon.Paralyze(40)
			Carbon.uncuff()

/obj/vehicle/sealed/proc/DumpSpecificMobs(flag, randomstep = TRUE)
	for(var/i in occupants)
		if(!(occupants[i] & flag))
			continue
		mob_exit(i, null, randomstep)
		if(iscarbon(i))
			var/mob/living/carbon/C = i
			C.Paralyze(40)
			C.uncuff()


/obj/vehicle/sealed/AllowDrop()
	return FALSE

/obj/vehicle/sealed/relaymove(mob/living/user, direction)
	if(canmove)
		vehicle_move(direction)
	return TRUE

/// Sinced sealed vehicles (cars and mechs) don't have riding components, the actual movement is handled here from [/obj/vehicle/sealed/proc/relaymove]
/obj/vehicle/sealed/proc/vehicle_move(direction)
	return FALSE
