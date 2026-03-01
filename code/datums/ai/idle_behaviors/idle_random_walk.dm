/datum/idle_behavior/idle_random_walk
	///Chance that the mob random walks per second
	var/walk_chance = 25

/datum/idle_behavior/idle_random_walk/perform_idle_behavior(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	if(LAZYLEN(living_pawn.do_afters))
		return

	if(DT_PROB(walk_chance, delta_time) && (living_pawn.mobility_flags & MOBILITY_MOVE) && isturf(living_pawn.loc) && !living_pawn.pulledby)
		var/move_dir = pick(GLOB.alldirs)
		var/turf/destination_turf = get_step(living_pawn, move_dir)
		if(!destination_turf?.can_cross_safely(living_pawn))
			return
		living_pawn.Move(destination_turf, move_dir)

/datum/idle_behavior/idle_random_walk/less_walking
	walk_chance = 10

/// Only walk if we don't have a target
/datum/idle_behavior/idle_random_walk/no_target
	/// Where do we look for a target?
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET

/datum/idle_behavior/idle_random_walk/no_target/perform_idle_behavior(seconds_per_tick, datum/ai_controller/controller)
	if (!controller.blackboard_key_exists(target_key))
		return
	return ..()
