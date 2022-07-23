#define FOLLOW_TOLERANCE 19

///Better than traditional follow, for our needs
/datum/ai_behavior/tamed_follow
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/tamed_follow/perform(delta_time, datum/ai_controller/controller)
	var/mob/living/simple_animal/pawn = controller.pawn
	//If pawn can't access target, finish
	if(get_dist(pawn, controller.blackboard[BB_FOLLOW_TARGET]) > FOLLOW_TOLERANCE)
		finish_action(controller, TRUE)
	..()

/datum/ai_behavior/tamed_follow/finish_action(datum/ai_controller/controller, succeeded, ...)
	var/mob/living/simple_animal/pawn = controller.pawn
	pawn.visible_message("[pawn] stops following [controller.blackboard[BB_FOLLOW_TARGET]]!")
	..()

//Agressive >:)
/datum/ai_behavior/tamed_follow/attack
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	COOLDOWN_DECLARE(attack_cooldown)

/datum/ai_behavior/tamed_follow/attack/perform(delta_time, datum/ai_controller/controller)
	var/mob/living/simple_animal/pawn = controller.pawn
	//If pawn can't access target, finish
	if(get_dist(pawn, controller.blackboard[BB_ATTACK_TARGET]) > FOLLOW_TOLERANCE)
		finish_action(controller, TRUE)
	else if(get_dist(pawn, controller.blackboard[BB_ATTACK_TARGET]) <= 1 && COOLDOWN_FINISHED(src, attack_cooldown))
		var/mob/living/target = controller.blackboard[BB_ATTACK_TARGET]
		if(istype(target) && IS_DEAD_OR_INCAP(target))
			finish_action(controller, TRUE)
		target.attack_animal(pawn)
		COOLDOWN_START(src, attack_cooldown, 1.3 SECONDS)
	..()

/// This trys to lock the pawn to a position
/datum/ai_behavior/tamed_sit/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/simple_animal/simple_pawn = controller.pawn
	if(!istype(simple_pawn))
		return

	if(DT_PROB(0.5, delta_time))
		finish_action(controller, TRUE)

/datum/ai_behavior/slime_sit/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/simple_animal/simple_pawn = controller.pawn
	if(!istype(simple_pawn) || simple_pawn.stat)
		return
