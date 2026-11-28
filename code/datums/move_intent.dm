GLOBAL_LIST_INIT_TYPED(move_intents, /datum/move_intent, init_subtypes_w_path_keys(/datum/move_intent))

///A way of moving, like walking or running
/datum/move_intent
	var/name
	var/flags = NONE
	///Icon state of the move intent HUD button
	var/hud_icon_state
	var/datum/movespeed_modifier/movespeed_modifier

/datum/move_intent/proc/can_be_used_by(mob/living/user)
	if(!(type in user.move_intents))
		return FALSE
	if((flags & MOVE_INTENT_QUICK) && HAS_TRAIT(user, TRAIT_NO_SPRINT))
		return FALSE
	return TRUE

/datum/move_intent/walk
	name = "Walk"
	flags = MOVE_INTENT_DELIBERATE
	hud_icon_state = "walking"
	movespeed_modifier = /datum/movespeed_modifier/config_walk_run/walk

/datum/move_intent/run
	name = "Run"
	flags = MOVE_INTENT_EXERTIVE
	hud_icon_state = "running"
	movespeed_modifier = /datum/movespeed_modifier/config_walk_run/run

///Held with the sprint keybind, see [/datum/component/carbon_sprint]
/datum/move_intent/sprint
	name = "Sprint"
	flags = MOVE_INTENT_EXERTIVE | MOVE_INTENT_QUICK
	hud_icon_state = "running"
	movespeed_modifier = /datum/movespeed_modifier/config_walk_run/sprint
