#define CHOICE_SHUTTLE "Call the shuttle"
#define CHOICE_CONTINUE "Continue playing"

/datum/vote/shuttle_vote
	name = "Evacuation shuttle"
	default_choices = list(
		CHOICE_SHUTTLE,
		CHOICE_CONTINUE,
	)
	default_message = "Vote to wrap up the ongoing round with a shuttle departure."

/datum/vote/shuttle_vote/can_be_initiated(forced)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return .

	if(!SSshuttle.canEvac() && SSshuttle.emergency.mode != SHUTTLE_RECALL)
		return "The shuttle has already been called"

/datum/vote/shuttle_vote/finalize_vote(winning_option)
	if(winning_option == CHOICE_SHUTTLE)
		if(SSshuttle.emergency.mode == SHUTTLE_RECALL)
			SSshuttle.emergency.mode = SHUTTLE_IDLE
			//This is slightly hacky, but shuttles cannot be called while in recall
			//All other modes prevent calling as well, but this is because the shuttle is already doing its thing and emergencyNoRecall ensures it succeeds

		SSshuttle.requestEvac(null, "Crew Transfer Requested.")
		SSshuttle.emergencyNoRecall = TRUE
		SSautotransfer.can_fire = FALSE
		return

/datum/vote/shuttle_vote/tiebreaker(list/winners)
	if(!length(get_living_connected_crew())) //No Players? Shuttle
		return CHOICE_SHUTTLE

	return length(choices_by_ckey) ? CHOICE_SHUTTLE : CHOICE_CONTINUE  //If there are no votes, continue, otherwise, prefer shuttle.

#undef CHOICE_SHUTTLE
#undef CHOICE_CONTINUE
