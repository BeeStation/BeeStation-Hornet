// For any /obj/vehicle's that can be ridden
/datum/component/riding/vehicle
	var/empable = FALSE
	var/emped = FALSE

	// All this stuff is distinct from Mobs and vehicles are roughly like 2x as fast

	var/accelerates = TRUE
	var/base_move_delay
	var/max_speed_delay = 0.4
	var/acceleration_per_tile = 0.05
	var/current_move_delay
	var/last_direction = NONE
	var/tiles_in_direction = 0

/datum/component/riding/vehicle/Initialize(mob/living/riding_mob, force = FALSE, ride_check_flags = (RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS), potion_boost = FALSE)
	if(!isvehicle(parent))
		return COMPONENT_INCOMPATIBLE
	. = ..()
	base_move_delay = vehicle_move_delay
	current_move_delay = vehicle_move_delay
	monitor_idle()

/datum/component/riding/vehicle/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_RIDDEN_DRIVER_MOVE, PROC_REF(driver_move))
	RegisterSignal(parent, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp_act))

/datum/component/riding/vehicle/driver_move(atom/movable/movable_parent, mob/living/user, direction)
	if(!COOLDOWN_FINISHED(src, vehicle_move_cooldown))
		return COMPONENT_DRIVER_BLOCK_MOVE
	var/obj/vehicle/vehicle_parent = parent

	if(!keycheck(user))
		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, span_warning("[vehicle_parent] has no key inserted!"))
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	if(HAS_TRAIT(user, TRAIT_INCAPACITATED))
		if(ride_check_flags & UNBUCKLE_DISABLED_RIDER)
			vehicle_parent.unbuckle_mob(user, TRUE)
			user.visible_message(span_danger("[user] falls off \the [vehicle_parent]."),\
			span_danger("You slip off \the [vehicle_parent] as your body slumps!"))
			user.Stun(3 SECONDS)
		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, span_warning("You cannot operate \the [vehicle_parent] right now!"))
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	if(ride_check_flags & RIDER_NEEDS_LEGS && HAS_TRAIT(user, TRAIT_FLOORED))
		if(ride_check_flags & UNBUCKLE_DISABLED_RIDER)
			vehicle_parent.unbuckle_mob(user, TRUE)
			user.visible_message(span_danger("[user] falls off \the [vehicle_parent]."),\
			span_danger("You fall off \the [vehicle_parent] while trying to operate it while unable to stand!"))
			user.Stun(3 SECONDS)
		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, span_warning("You can't seem to manage that while unable to stand up enough to move \the [vehicle_parent]..."))
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	if(ride_check_flags & RIDER_NEEDS_ARMS && !check_rider_holding_on(user))
		if(ride_check_flags & UNBUCKLE_DISABLED_RIDER)
			vehicle_parent.unbuckle_mob(user, TRUE)
			user.visible_message(span_danger("[user] falls off \the [vehicle_parent]."),\
			span_danger("You fall off \the [vehicle_parent] while trying to operate it without being able to hold on!"))
			user.Stun(2 SECONDS)
		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, span_warning("You can't seem to hold onto \the [vehicle_parent] to move it..."))
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	handle_ride(user, direction)
	return ..()

/datum/component/riding/vehicle/proc/monitor_idle()
	set waitfor = FALSE
	var/atom/movable/movable_parent = parent
	var/turf/last_loc = get_turf(movable_parent)
	while(!QDELETED(src) && !QDELETED(movable_parent))
		sleep(2 SECONDS)
		var/turf/current_loc = get_turf(movable_parent)
		if(current_loc == last_loc)
			if(accelerates)
				tiles_in_direction = 0
				current_move_delay = base_move_delay
				last_direction = NONE
		last_loc = current_loc

/datum/component/riding/vehicle/proc/check_rider_holding_on(mob/living/user)
	var/holding_on = FALSE
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		var/obj/item/bodypart/left_arm = carbon_user.get_bodypart(BODY_ZONE_L_ARM)
		var/obj/item/bodypart/right_arm = carbon_user.get_bodypart(BODY_ZONE_R_ARM)
		if(HAS_TRAIT(carbon_user, TRAIT_HANDS_BLOCKED) || INCAPACITATED_IGNORING(carbon_user, INCAPABLE_RESTRAINTS|INCAPABLE_GRAB))
			holding_on = FALSE
		else if((!left_arm || left_arm.bodypart_disabled) && (!right_arm || right_arm.bodypart_disabled))
			holding_on = FALSE
		else if(carbon_user.get_active_held_item() && carbon_user.get_inactive_held_item())
			holding_on = FALSE
		else
			holding_on = TRUE
	return holding_on

/datum/component/riding/vehicle/proc/handle_ride(mob/user, direction)
	var/atom/movable/movable_parent = parent
	var/turf/next = get_step(movable_parent, direction)
	var/turf/current = get_turf(movable_parent)
	if(!istype(next) || !istype(current))
		return
	if(!turf_check(next, current))
		to_chat(user, span_warning("\The [movable_parent] can not go onto [next]!"))
		return
	if(!Process_Spacemove(direction) || !isturf(movable_parent.loc))
		return
	if(emped && empable)
		to_chat(user, span_warning("\The [movable_parent]'s controls aren't responding!"))
		return

	if(accelerates)
		if(direction == NONE)
			tiles_in_direction = 0
			current_move_delay = base_move_delay
			last_direction = NONE
		else if(direction != last_direction)
			tiles_in_direction = 0
			current_move_delay = max(current_move_delay - 0.15, base_move_delay)
			last_direction = direction
		else
			tiles_in_direction++

		if(base_move_delay <= 0)
			current_move_delay = 0
		else if(tiles_in_direction <= 6)
			current_move_delay = base_move_delay
		else
			current_move_delay = max((max_speed_delay ? max_speed_delay : base_move_delay), base_move_delay - ((tiles_in_direction - 6) * acceleration_per_tile))

		vehicle_move_delay = current_move_delay

	step(movable_parent, direction)
	COOLDOWN_START(src, vehicle_move_cooldown, vehicle_move_delay * vehicle_move_multiplier)
	if(QDELETED(src))
		return
	handle_vehicle_layer(movable_parent.dir)
	handle_vehicle_offsets(movable_parent.dir)
	return TRUE

/datum/component/riding/vehicle/atv
	keytype = /obj/item/key/atv
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS | UNBUCKLE_DISABLED_RIDER
	vehicle_move_delay = 1.5
	empable = TRUE

/datum/component/riding/vehicle/atv/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)

/datum/component/riding/vehicle/bicycle
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS | UNBUCKLE_DISABLED_RIDER
	vehicle_move_delay = 0

/datum/component/riding/vehicle/bicycle/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))

/datum/component/riding/vehicle/lavaboat
	ride_check_flags = NONE
	keytype = /obj/item/oar
	var/allowed_turf = /turf/open/lava

/datum/component/riding/vehicle/lavaboat/handle_specials()
	. = ..()
	allowed_turf_typecache = typecacheof(allowed_turf)

/datum/component/riding/vehicle/lavaboat/dragonboat/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(1, 2), TEXT_SOUTH = list(1, 2), TEXT_EAST = list(1, 2), TEXT_WEST = list( 1, 2)))

/datum/component/riding/vehicle/lavaboat/dragonboat
	vehicle_move_delay = 1.5
	keytype = null

/datum/component/riding/vehicle/janicart
	keytype = /obj/item/key/janitor
	empable = TRUE

/datum/component/riding/vehicle/janicart/keyless
	keytype = null

/datum/component/riding/vehicle/janicart/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 7), TEXT_EAST = list(-12, 7), TEXT_WEST = list( 12, 7)))

/datum/component/riding/vehicle/scooter
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS | UNBUCKLE_DISABLED_RIDER

/datum/component/riding/vehicle/scooter/handle_specials(mob/living/riding_mob)
	. = ..()
	if(iscyborg(riding_mob))
		set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0), TEXT_SOUTH = list(0), TEXT_EAST = list(0), TEXT_WEST = list(2)))
	else
		set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(2), TEXT_SOUTH = list(-2), TEXT_EAST = list(0), TEXT_WEST = list(2)))

/datum/component/riding/vehicle/scooter/skateboard
	vehicle_move_delay = 1.5
	ride_check_flags = RIDER_NEEDS_LEGS | UNBUCKLE_DISABLED_RIDER

/datum/component/riding/vehicle/scooter/skateboard/handle_specials()
	. = ..()
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)

/datum/component/riding/vehicle/scooter/skateboard/wheelys
	vehicle_move_delay = 1.75

/datum/component/riding/vehicle/scooter/skateboard/wheelys/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0), TEXT_SOUTH = list(0), TEXT_EAST = list(0), TEXT_WEST = list(0)))

/datum/component/riding/vehicle/secway
	keytype = /obj/item/key/security
	vehicle_move_delay = 1.5
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS | UNBUCKLE_DISABLED_RIDER
	empable = TRUE

/datum/component/riding/vehicle/secway/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)

/datum/component/riding/vehicle/speedbike
	vehicle_move_delay = 0
	override_allow_spacemove = TRUE
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS | UNBUCKLE_DISABLED_RIDER
	empable = TRUE

/datum/component/riding/vehicle/speedbike/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, -8), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(-10, 5), TEXT_WEST = list( 10, 5)))
	set_vehicle_dir_offsets(NORTH, -16, -16)
	set_vehicle_dir_offsets(SOUTH, -16, -16)
	set_vehicle_dir_offsets(EAST, -18, 0)
	set_vehicle_dir_offsets(WEST, -18, 0)

/datum/component/riding/vehicle/speedwagon
	vehicle_move_delay = 0

/datum/component/riding/vehicle/speedwagon/handle_specials()
	. = ..()
	set_riding_offsets(1, list(TEXT_NORTH = list(-10, -4), TEXT_SOUTH = list(16, 3), TEXT_EAST = list(-4, 30), TEXT_WEST = list(4, -3)))
	set_riding_offsets(2, list(TEXT_NORTH = list(19, -5, 4), TEXT_SOUTH = list(-13, 3, 4), TEXT_EAST = list(-4, -3, 4.1), TEXT_WEST = list(4, 28, 3.9)))
	set_riding_offsets(3, list(TEXT_NORTH = list(-10, -18, 4.2), TEXT_SOUTH = list(16, 25, 3.9), TEXT_EAST = list(-22, 30), TEXT_WEST = list(22, -3, 4.1)))
	set_riding_offsets(4, list(TEXT_NORTH = list(19, -18, 4.2), TEXT_SOUTH = list(-13, 25, 3.9), TEXT_EAST = list(-22, 3, 3.9), TEXT_WEST = list(22, 28)))
	set_vehicle_dir_offsets(NORTH, -48, -48)
	set_vehicle_dir_offsets(SOUTH, -48, -48)
	set_vehicle_dir_offsets(EAST, -48, -48)
	set_vehicle_dir_offsets(WEST, -48, -48)
	for(var/i in GLOB.cardinals)
		set_vehicle_dir_layer(i, BELOW_MOB_LAYER)

/datum/component/riding/vehicle/speedwagon/vehicle_bump(atom/movable/movable_parent, obj/machinery/door/possible_bumped_door)
	return

/datum/component/riding/vehicle/wheelchair
	vehicle_move_delay = 2.5
	ride_check_flags = RIDER_NEEDS_ARMS

/datum/component/riding/vehicle/wheelchair/handle_specials()
	. = ..()
	base_move_delay = 2.5
	max_speed_delay = 0.8
	current_move_delay = 2.5
	set_vehicle_dir_layer(SOUTH, OBJ_LAYER)
	set_vehicle_dir_layer(NORTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)

/datum/component/riding/vehicle/wheelchair/hand/driver_move(obj/vehicle/vehicle_parent, mob/living/user, direction)
	var/delay_multiplier = 4.7
	vehicle_move_delay = round(CONFIG_GET(number/movedelay/run_delay) * delay_multiplier) / clamp(user.usable_hands, 1, 2)
	return ..()

/datum/component/riding/vehicle/wheelchair/motorized
	ride_check_flags = NONE
	empable = TRUE
	accelerates = TRUE
	max_speed_delay = 0.4

/datum/component/riding/vehicle/wheelchair/motorized/Initialize(mob/living/riding_mob, force = FALSE, ride_check_flags = NONE, potion_boost = FALSE)
	. = ..()
	var/obj/vehicle/ridden/wheelchair/motorized/our_chair = parent
	if(istype(our_chair))
		base_move_delay = round(CONFIG_GET(number/movedelay/run_delay) * our_chair.speed)
		current_move_delay = base_move_delay
		vehicle_move_delay = base_move_delay

/datum/component/riding/vehicle/wheelchair/motorized/handle_ride(mob/user, direction)
	var/obj/vehicle/ridden/wheelchair/motorized/our_chair = parent
	if(istype(our_chair))
		// Refresh base speed from chair in case parts changed
		base_move_delay = round(CONFIG_GET(number/movedelay/run_delay) * our_chair.speed)
		if(tiles_in_direction == 0)
			current_move_delay = base_move_delay

	. = ..()

	if(!istype(our_chair))
		return
	if(our_chair.power_cell)
		our_chair.power_cell.use(our_chair.power_usage)
	if(!our_chair.low_power_alerted && our_chair.power_cell.charge <= (our_chair.power_cell.maxcharge / 4))
		playsound(src, 'sound/machines/twobeep.ogg', 30, 1)
		our_chair.say("Warning: Power low!")
		our_chair.low_power_alerted = TRUE

/datum/component/riding/vehicle/proc/on_emp_act(datum/source, severity, protection)
	SIGNAL_HANDLER
	if(!empable)
		return
	emped = TRUE
	var/atom/movable/AM = parent
	AM.add_emitter(/obj/emitter/fire_smoke, "smoke")
	addtimer(CALLBACK(src, PROC_REF(reboot)), 300 / severity, TIMER_UNIQUE|TIMER_OVERRIDE)

/datum/component/riding/vehicle/proc/reboot()
	emped = FALSE
	var/atom/movable/AM = parent
	AM.remove_emitter("smoke")

/datum/component/riding/vehicle/lawnmower
	vehicle_move_delay = 2.0
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS | UNBUCKLE_DISABLED_RIDER

/datum/component/riding/vehicle/lawnmower/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 7), TEXT_EAST = list(-5, 2), TEXT_WEST = list(5, 2)))

/datum/component/riding/vehicle/lawnmower/nukie
	vehicle_move_delay = 1.5
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS | UNBUCKLE_DISABLED_RIDER
