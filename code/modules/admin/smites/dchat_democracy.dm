/// Gives dchat the ability to move a mob or object, determined by user voting
/datum/smite/dchat_democracy
	name = "Deadchat Control (Democracy)"

/datum/smite/dchat_democracy/effect(client/user, mob/living/target)
	. = ..()
	target._AddComponent(list(/datum/component/deadchat_control, DEMOCRACY_MODE, list(
		"up" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), target, NORTH),
		"down" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), target, SOUTH),
		"left" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), target, WEST),
		"right" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), target, EAST)), 40))
