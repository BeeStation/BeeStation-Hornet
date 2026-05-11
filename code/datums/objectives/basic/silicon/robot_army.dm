/datum/objective/robot_army
	name = "robot army"
	explanation_text = "Have at least eight active cyborgs synced to you."

	var/cyborgs_synced = 0

/datum/objective/robot_army/check_completion()
	cyborgs_synced = 0
	for(var/datum/mind/objective_owner as anything in get_owners())
		if(!isAI(objective_owner.current))
			continue

		var/mob/living/silicon/ai/ai = objective_owner.current
		for(var/mob/living/silicon/robot/connected_borg as anything in ai.connected_robots)
			if(connected_borg.stat != DEAD)
				cyborgs_synced++

	return (cyborgs_synced >= 8) || ..()

/datum/objective/robot_army/get_completion_message()
	var/span = check_completion() ? "greentext" : "redtext"
	return "[explanation_text] <span class='[span]'>[cyborgs_synced] cyborgs synced!</span>"
