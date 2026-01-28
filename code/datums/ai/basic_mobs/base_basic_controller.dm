/datum/ai_controller/basic_controller
	movement_delay = 0.4 SECONDS

/datum/ai_controller/basic_controller/TryPossessPawn(atom/new_pawn)
	if(!isbasicmob(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
	var/mob/living/basic/basic_mob = new_pawn

	update_speed(basic_mob)

	RegisterSignals(basic_mob, list(POST_BASIC_MOB_UPDATE_VARSPEED, COMSIG_MOB_MOVESPEED_UPDATED), PROC_REF(update_speed))

	return ..() //Run parent at end


/datum/ai_controller/basic_controller/get_able_to_run()
	. = ..()
	if(. & AI_UNABLE_TO_RUN)
		return .
	var/mob/living/living_pawn = pawn
	if (living_pawn.stat && !(ai_traits & CAN_ACT_WHILE_DEAD))
		return AI_UNABLE_TO_RUN

	if(ai_traits & PAUSE_DURING_DO_AFTER && LAZYLEN(living_pawn.do_afters))
		return AI_UNABLE_TO_RUN | AI_PREVENT_CANCEL_ACTIONS //dont erase targets post a do_after

/datum/ai_controller/basic_controller/proc/update_speed(mob/living/basic/basic_mob)
	SIGNAL_HANDLER
	movement_delay = basic_mob.cached_multiplicative_slowdown
