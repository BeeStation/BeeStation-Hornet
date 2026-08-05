/datum/pet_command/perform_trick_sequence
	command_name = "Trick Sequence"
	command_desc = "A trick sequence programmable through your PDA!"

/datum/pet_command/perform_trick_sequence/find_command_in_text(spoken_text, check_verbosity = FALSE)
	var/mob/living/living_pawn = weak_parent.resolve()
	if(isnull(living_pawn?.ai_controller))
		return FALSE
	var/text_command = living_pawn.ai_controller.blackboard[BB_TRICK_NAME]
	if(isnull(text_command))
		return FALSE
	return findtext(spoken_text, text_command)

/datum/pet_command/perform_trick_sequence/execute_action(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/list/trick_sequence = controller.blackboard[BB_TRICK_SEQUENCE]
	for(var/index in 1 to length(trick_sequence))
		addtimer(CALLBACK(living_pawn, TYPE_PROC_REF(/mob, emote), trick_sequence[index], index * 0.5 SECONDS))
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	return SUBTREE_RETURN_FINISH_PLANNING
