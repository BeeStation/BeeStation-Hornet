/// Just keep following the target until the command is interrupted
/datum/ai_behavior/pet_follow_friend
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM

/datum/ai_behavior/pet_follow_friend/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	if (!target)
		return FALSE
	controller.current_movement_target = target

/datum/ai_behavior/pet_follow_friend/perform(delta_time, datum/ai_controller/controller, target_key)
	. = ..()
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	if (!target)
		finish_action(controller, FALSE, target_key)
		return
