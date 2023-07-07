/// Gives dchat the ability to move a mob or object, with no delay or voting
/datum/smite/dchat_anarchy
	name = "Deadchat Control (Anarchy)"

/datum/smite/dchat_anarchy/effect(client/user, mob/living/target)
	. = ..()
	target._AddComponent(list(/datum/component/deadchat_control, ANARCHY_MODE, list(
		"up" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), target, NORTH),
		"down" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), target, SOUTH),
		"left" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), target, WEST),
		"right" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), target, EAST)), 10))
