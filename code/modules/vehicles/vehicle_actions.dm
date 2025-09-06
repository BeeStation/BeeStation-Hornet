//VEHICLE DEFAULT HANDLING
/obj/vehicle/proc/generate_actions()
	return

/obj/vehicle/proc/generate_action_type(actiontype)
	var/datum/action/vehicle/A = new actiontype
	if(!istype(A))
		return
	A.vehicle_target = src
	return A

/obj/vehicle/proc/initialize_passenger_action_type(actiontype)
	autogrant_actions_passenger += actiontype
	for(var/i in occupants)
		grant_passenger_actions(i)	//refresh

/obj/vehicle/proc/initialize_controller_action_type(actiontype, control_flag)
	LAZYINITLIST(autogrant_actions_controller["[control_flag]"])
	autogrant_actions_controller["[control_flag]"] += actiontype
	for(var/i in occupants)
		grant_controller_actions(i)	//refresh

/obj/vehicle/proc/grant_action_type_to_mob(actiontype, mob/m)
	if(isnull(LAZYACCESS(occupants, m)) || !actiontype)
		return FALSE
	LAZYINITLIST(occupant_actions[m])
	if(occupant_actions[m][actiontype])
		return TRUE
	var/datum/action/action = generate_action_type(actiontype)
	action.Grant(m)
	occupant_actions[m][action.type] = action
	return TRUE

/obj/vehicle/proc/remove_action_type_from_mob(actiontype, mob/m)
	if(isnull(LAZYACCESS(occupants, m)) || !actiontype)
		return FALSE
	LAZYINITLIST(occupant_actions[m])
	if(occupant_actions[m][actiontype])
		var/datum/action/action = occupant_actions[m][actiontype]
		// Actions don't dissipate on removal, they just sit around assuming they'll be reusued
		// Gotta qdel
		qdel(action)
		occupant_actions[m] -= actiontype
	return TRUE

/obj/vehicle/proc/grant_passenger_actions(mob/M)
	for(var/v in autogrant_actions_passenger)
		grant_action_type_to_mob(v, M)

/obj/vehicle/proc/remove_passenger_actions(mob/M)
	for(var/v in autogrant_actions_passenger)
		remove_action_type_from_mob(v, M)

/obj/vehicle/proc/grant_controller_actions(mob/M)
	if(!istype(M) || isnull(LAZYACCESS(occupants, M)))
		return FALSE
	for(var/i in GLOB.bitflags)
		if(occupants[M] & i)
			grant_controller_actions_by_flag(M, i)
	return TRUE

/obj/vehicle/proc/remove_controller_actions(mob/M)
	if(!istype(M) || isnull(LAZYACCESS(occupants, M)))
		return FALSE
	for(var/i in GLOB.bitflags)
		remove_controller_actions_by_flag(M, i)
	return TRUE

/obj/vehicle/proc/grant_controller_actions_by_flag(mob/M, flag)
	if(!istype(M))
		return FALSE
	for(var/v in autogrant_actions_controller["[flag]"])
		grant_action_type_to_mob(v, M)
	return TRUE

/obj/vehicle/proc/remove_controller_actions_by_flag(mob/M, flag)
	if(!istype(M))
		return FALSE
	for(var/v in autogrant_actions_controller["[flag]"])
		remove_action_type_from_mob(v, M)
	return TRUE

/obj/vehicle/proc/cleanup_actions_for_mob(mob/M)
	if(!istype(M))
		return FALSE
	for(var/path in occupant_actions[M])
		stack_trace("Leftover action type [path] in vehicle type [type] for mob type [M.type] - THIS SHOULD NOT BE HAPPENING!")
		var/datum/action/action = occupant_actions[M][path]
		action.Remove(M)
		occupant_actions[M] -= path
	occupant_actions -= M
	return TRUE

//ACTION DATUMS

/datum/action/vehicle
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_INCAPACITATED | AB_CHECK_CONSCIOUS
	button_icon = 'icons/hud/actions/actions_vehicle.dmi'
	button_icon_state = null
	var/obj/vehicle/vehicle_target

/datum/action/vehicle/Destroy()
	vehicle_target = null
	return ..()

/datum/action/vehicle/sealed
	check_flags = AB_CHECK_INCAPACITATED | AB_CHECK_CONSCIOUS
	var/obj/vehicle/sealed/vehicle_entered_target

/datum/action/vehicle/sealed/Destroy()
	vehicle_entered_target = null
	return ..()

/datum/action/vehicle/sealed/climb_out
	name = "Climb Out"
	desc = "Climb out of your vehicle!"
	button_icon_state = "car_eject"

/datum/action/vehicle/sealed/climb_out/on_activate(mob/user, atom/target)
	if(istype(vehicle_entered_target))
		vehicle_entered_target.mob_try_exit(owner, owner)

/datum/action/vehicle/ridden
	var/obj/vehicle/ridden/vehicle_ridden_target

/datum/action/vehicle/sealed/remove_key
	name = "Remove key"
	desc = "Take your key out of the vehicle's ignition"
	button_icon_state = "car_removekey"

/datum/action/vehicle/sealed/remove_key/on_activate(mob/user, atom/target)
	vehicle_entered_target.remove_key(owner)

//CLOWN CAR ACTION DATUMS
/datum/action/vehicle/sealed/horn
	name = "Honk Horn"
	desc = "Honk your classy horn."
	button_icon_state = "car_horn"
	var/hornsound = 'sound/items/carhorn.ogg'
	cooldown_time = 2 SECONDS

/datum/action/vehicle/sealed/horn/on_activate(mob/user, atom/target)
	vehicle_entered_target.visible_message(span_danger("[vehicle_entered_target] loudly honks!"))
	to_chat(owner, span_notice("You press the vehicle's horn."))
	playsound(vehicle_entered_target, hornsound, 75)
	start_cooldown()

/datum/action/vehicle/sealed/horn/clowncar/on_activate(mob/user, atom/target)
	vehicle_entered_target.visible_message(span_danger("[vehicle_entered_target] loudly honks!"))
	to_chat(owner, span_notice("You press the vehicle's horn."))
	start_cooldown()
	if(vehicle_target.inserted_key)
		vehicle_target.inserted_key.attack_self(owner) //The key plays a sound
	else
		playsound(vehicle_entered_target, hornsound, 75)

/datum/action/vehicle/sealed/DumpKidnappedMobs
	name = "Dump kidnapped mobs"
	desc = "Dump all objects and people in your car on the floor."
	button_icon_state = "car_dump"

/datum/action/vehicle/sealed/DumpKidnappedMobs/on_activate(mob/user, atom/target)
	vehicle_entered_target.visible_message(span_danger("[vehicle_entered_target] starts dumping the people inside of it."))
	vehicle_entered_target.DumpSpecificMobs(VEHICLE_CONTROL_KIDNAPPED)


/datum/action/vehicle/sealed/RollTheDice
	name = "Press a colorful button"
	desc = "Press one of those colorful buttons on your display panel!"
	button_icon_state = "car_rtd"

/datum/action/vehicle/sealed/RollTheDice/on_activate(mob/user, atom/target)
	if(istype(vehicle_entered_target, /obj/vehicle/sealed/car/clowncar))
		var/obj/vehicle/sealed/car/clowncar/C = vehicle_entered_target
		C.RollTheDice(owner)

/datum/action/vehicle/sealed/Cannon
	name = "Toggle siege mode"
	desc = "Destroy them with their own fodder"
	button_icon_state = "car_cannon"

/datum/action/vehicle/sealed/Cannon/on_activate(mob/user, atom/target)
	if(istype(vehicle_entered_target, /obj/vehicle/sealed/car/clowncar))
		var/obj/vehicle/sealed/car/clowncar/C = vehicle_entered_target
		if(C.cannonbusy)
			to_chat(owner, span_notice("Please wait for the vehicle to finish its current action first."))
		C.ToggleCannon()

/datum/action/vehicle/sealed/Thank
	name = "Thank the Clown car Driver"
	desc = "They're just doing their job."
	button_icon_state = "car_thanktheclown"
	cooldown_time = 6 SECONDS

/datum/action/vehicle/sealed/Thank/on_activate(mob/user, atom/target)
	if(istype(vehicle_entered_target, /obj/vehicle/sealed/car/clowncar))
		var/obj/vehicle/sealed/car/clowncar/C = vehicle_entered_target
		var/mob/living/carbon/human/clown = pick(C.return_drivers())
		owner.say("Thank you for the fun ride, [clown.name]!")
		start_cooldown()
		C.ThanksCounter()

/datum/action/vehicle/ridden/scooter/skateboard/ollie
	name = "Ollie"
	desc = "Get some air! Land on a table to do a gnarly grind."
	button_icon_state = "skateboard_ollie"
	///Cooldown to next jump
	cooldown_time = 0.5 SECONDS

/datum/action/vehicle/ridden/scooter/skateboard/ollie/on_activate(mob/user, atom/target)
	var/obj/vehicle/ridden/scooter/skateboard/V = vehicle_target
	if (V.grinding)
		return
	var/mob/living/L = owner
	var/turf/landing_turf = get_step(V.loc, V.dir)
	var/multiplier = 1
	if(HAS_TRAIT(L, TRAIT_PROSKATER))
		multiplier = 0.3 //70% reduction
	L.adjustStaminaLoss(V.instability * multiplier * 2)
	if (L.getStaminaLoss() >= 100)
		playsound(src, 'sound/effects/bang.ogg', 20, TRUE)
		V.unbuckle_mob(L)
		L.throw_at(landing_turf, 2, 2)
		L.Paralyze(multiplier * 40)
		V.visible_message(span_danger("[L] misses the landing and falls on [L.p_their()] face!"))
	else
		L.spin(4, 1)
		animate(L, pixel_y = -6, time = 4)
		animate(V, pixel_y = -6, time = 3)
		playsound(V, 'sound/vehicles/skateboard_ollie.ogg', 50, TRUE)
		passtable_on(L, VEHICLE_TRAIT)
		V.pass_flags |= PASSTABLE
		L.Move(landing_turf, vehicle_target.dir)
		passtable_off(L, VEHICLE_TRAIT)
		V.pass_flags &= ~PASSTABLE
	if(locate(/obj/structure/table) in V.loc.contents)
		V.grinding = TRUE
		V.icon_state = "[V.board_icon]-grind"
		addtimer(CALLBACK(V, TYPE_PROC_REF(/obj/vehicle/ridden/scooter/skateboard, grind)), 2)
	start_cooldown()

/datum/action/vehicle/ridden/scooter/skateboard/kflip
	name = "Kick Flip"
	desc = "Do a sweet kickflip to dismount... in style."
	button_icon_state = "skateboard_ollie"

/datum/action/vehicle/ridden/scooter/skateboard/kflip/on_activate(mob/user, atom/target)
	var/obj/vehicle/ridden/scooter/skateboard/V = vehicle_target
	var/mob/living/L = owner
	var/multiplier = 1
	if(HAS_TRAIT(L, TRAIT_PROSKATER))
		multiplier = 0.3 //70% reduction
	L.adjustStaminaLoss(V.instability * multiplier)
	if (L.getStaminaLoss() >= 100)
		playsound(src, 'sound/effects/bang.ogg', 20, TRUE)
		V.unbuckle_mob(L)
		L.Paralyze(50 * multiplier)
		if(prob(15))
			V.visible_message(span_userdanger("You smack against the board, hard."), span_danger("[L] misses the landing and falls on [L.p_their()] face!"))
			L.emote("scream")
			L.adjustBruteLoss(10)  // thats gonna leave a mark
			return
		V.visible_message(span_userdanger("You fall flat onto the board!"), span_danger("[L] misses the landing and falls on [L.p_their()] face!"))
	else
		L.visible_message(span_notice("[L] does a sick kickflip and catches [L.p_their()] board in midair."), span_notice("You do a sick kickflip, catching the board in midair! Stylish."))
		playsound(V, 'sound/vehicles/skateboard_ollie.ogg', 50, TRUE)
		L.spin(4, 1)
		animate(L, pixel_y = -6, time = 4)
		animate(V, pixel_y = -6, time = 3)
		V.unbuckle_mob(L)
		addtimer(CALLBACK(V, TYPE_PROC_REF(/obj/vehicle/ridden/scooter/skateboard, pick_up_board), L), 2)
