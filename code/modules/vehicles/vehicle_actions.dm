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

/datum/action/vehicle/sealed/climb_out/activate(atom/target)
	if(istype(vehicle_entered_target))
		vehicle_entered_target.mob_try_exit(owner, owner)

/datum/action/vehicle/ridden
	var/obj/vehicle/ridden/vehicle_ridden_target

/datum/action/vehicle/sealed/remove_key
	name = "Remove key"
	desc = "Take your key out of the vehicle's ignition"
	button_icon_state = "car_removekey"

/datum/action/vehicle/sealed/remove_key/activate(atom/target)
	vehicle_entered_target.remove_key(owner)

//CLOWN CAR ACTION DATUMS
/datum/action/vehicle/sealed/horn
	name = "Honk Horn"
	desc = "Honk your classy horn."
	button_icon_state = "car_horn"
	var/hornsound = 'sound/items/carhorn.ogg'

/datum/action/vehicle/sealed/horn/trigger(trigger_flags)
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_CAR_HONK))
		return
	TIMER_COOLDOWN_START(src, COOLDOWN_CAR_HONK, 2 SECONDS)
	vehicle_entered_target.visible_message(span_danger("[vehicle_entered_target] loudly honks!"))
	to_chat(owner, span_notice("You press [vehicle_entered_target]'s horn."))
	if(istype(vehicle_target.inserted_key, /obj/item/bikehorn))
		vehicle_target.inserted_key.attack_self(owner) //The bikehorn plays a sound instead
		return
	playsound(vehicle_entered_target, hornsound, 75)

/datum/action/vehicle/sealed/dump_kidnapped_mobs
	name = "Dump kidnapped mobs"
	desc = "Dump all objects and people in your car on the floor."
	button_icon_state = "car_dump"

/datum/action/vehicle/sealed/dump_kidnapped_mobs/trigger(trigger_flags)
	vehicle_entered_target.visible_message(span_danger("[vehicle_entered_target] starts dumping the people inside of it."))
	vehicle_entered_target.dump_specific_mobs(VEHICLE_CONTROL_KIDNAPPED)


/datum/action/vehicle/sealed/RollTheDice
	name = "Press a colorful button"
	desc = "Press one of those colorful buttons on your display panel!"
	button_icon_state = "car_rtd"

/datum/action/vehicle/sealed/roll_the_dice/trigger(trigger_flags)
	if(!istype(vehicle_entered_target, /obj/vehicle/sealed/car/clowncar))
		return
	var/obj/vehicle/sealed/car/clowncar/C = vehicle_entered_target
	C.roll_the_dice(owner)

/datum/action/vehicle/sealed/cannon
	name = "Toggle siege mode"
	desc = "Destroy them with their own fodder"
	button_icon_state = "car_cannon"

/datum/action/vehicle/sealed/cannon/trigger(trigger_flags)
	if(!istype(vehicle_entered_target, /obj/vehicle/sealed/car/clowncar))
		return
	var/obj/vehicle/sealed/car/clowncar/C = vehicle_entered_target
	C.toggle_cannon(owner)

/datum/action/vehicle/sealed/thank
	name = "Thank the Clown car Driver"
	desc = "They're just doing their job."
	button_icon_state = "car_thanktheclown"
	COOLDOWN_DECLARE(thank_time_cooldown)

/datum/action/vehicle/sealed/thank/trigger(trigger_flags)
	if(!istype(vehicle_entered_target, /obj/vehicle/sealed/car/clowncar))
		return
	if(!COOLDOWN_FINISHED(src, thank_time_cooldown))
		return
	COOLDOWN_START(src, thank_time_cooldown, 6 SECONDS)
	var/obj/vehicle/sealed/car/clowncar/clown_car = vehicle_entered_target
	var/list/mob/drivers = clown_car.return_drivers()
	if(!length(drivers))
		to_chat(owner, span_danger("You prepare to thank the driver, only to realize that they don't exist."))
		return
	var/mob/clown = pick(drivers)
	owner.say("Thank you for the fun ride, [clown.name]!")
	clown_car.increment_thanks_counter()

/datum/action/vehicle/ridden/scooter/skateboard/ollie
	name = "Ollie"
	desc = "Get some air! Land on a table to do a gnarly grind."
	button_icon_state = "skateboard_ollie"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/vehicle/ridden/scooter/skateboard/ollie/trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/obj/vehicle/ridden/scooter/skateboard/vehicle = vehicle_target
	if (vehicle.grinding)
		return
	var/mob/living/rider = owner
	var/turf/landing_turf = get_step(vehicle.loc, vehicle.dir)
	var/multiplier = 1
	if(HAS_TRAIT(rider, TRAIT_PROSKATER))
		multiplier = 0.3 //70% reduction
	rider.adjustStaminaLoss(vehicle.instability * multiplier * 2)
	if (rider.getStaminaLoss() >= 100)
		playsound(src, 'sound/effects/bang.ogg', 20, TRUE)
		vehicle.unbuckle_mob(rider)
		rider.throw_at(landing_turf, 2, 2)
		rider.Paralyze(multiplier * 40)
		vehicle.visible_message(span_danger("[rider] misses the landing and falls on [rider.p_their()] face!"))
		return
	if(locate(/obj/structure/table) in vehicle.loc.contents)
		vehicle.grinding = TRUE
		vehicle.icon_state = "[vehicle.board_icon]-grind"
		addtimer(CALLBACK(vehicle, TYPE_PROC_REF(/obj/vehicle/ridden/scooter/skateboard, grind)), 0.2 SECONDS)
	rider.spin(spintime = 4, speed = 1)
	animate(rider, pixel_y = -6, time = 4)
	animate(vehicle, pixel_y = -6, time = 3)
	playsound(vehicle, 'sound/vehicles/skateboard_ollie.ogg', 50, TRUE)
	passtable_on(rider, VEHICLE_TRAIT)
	passtable_on(vehicle, VEHICLE_TRAIT)
	rider.Move(landing_turf, vehicle_target.dir)
	passtable_off(rider, VEHICLE_TRAIT)
	passtable_off(vehicle, VEHICLE_TRAIT)

/datum/action/vehicle/ridden/scooter/skateboard/kickflip
	name = "Kick Flip"
	desc = "Do a sweet kickflip to dismount... in style."
	button_icon_state = "skateboard_ollie"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/vehicle/ridden/scooter/skateboard/kickflip/trigger(trigger_flags)
	var/obj/vehicle/ridden/scooter/skateboard/board = vehicle_target
	var/mob/living/rider = owner

	var/multiplier = 1
	if(HAS_TRAIT(rider, TRAIT_PROSKATER))
		multiplier = 0.3 //70% reduction
	rider.adjustStaminaLoss(board.instability * multiplier)
	if (rider.getStaminaLoss() >= 100)
		playsound(src, 'sound/effects/bang.ogg', 20, TRUE)
		board.unbuckle_mob(rider)
		rider.Paralyze(50 * multiplier)
		if(prob(15))
			board.visible_message(
				span_userdanger("You smack against the board, hard."),
				span_danger("[rider] misses the landing and falls on [rider.p_their()] face!")
			)
			rider.emote("scream")
			rider.adjustBruteLoss(10)  // thats gonna leave a mark
			return
		board.visible_message(
			span_userdanger("You fall flat onto the board!"),
			span_danger("[rider] misses the landing and falls on [rider.p_their()] face!")
		)
		return

	rider.visible_message(
		span_notice("[rider] does a sick kickflip and catches [rider.p_their()] board in midair."),
		span_notice("You do a sick kickflip, catching the board in midair! Stylish.")
	)
	playsound(board, 'sound/vehicles/skateboard_ollie.ogg', 50, TRUE)
	rider.spin(spintime = 4, speed = 1)
	animate(rider, pixel_y = -6, time = 0.4 SECONDS)
	animate(board, pixel_y = -6, time = 0.3 SECONDS)
	board.unbuckle_mob(rider)
	addtimer(CALLBACK(board, TYPE_PROC_REF(/obj/vehicle/ridden/scooter/skateboard, pick_up_board), rider), 1 SECONDS)
