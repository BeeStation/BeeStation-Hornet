/datum/objective/robot_army
	name = "robot army"
	explanation_text = "Have at least eight active cyborgs synced to you."
	martyr_compatible = 0

/datum/objective/robot_army/check_completion()
	var/counter = 0
	for(var/datum/mind/M as() in get_owners())
		if(!M.current || !isAI(M.current))
			continue
		var/mob/living/silicon/ai/A = M.current
		for(var/mob/living/silicon/robot/R as() in A.connected_robots)
			if(R.stat != DEAD)
				counter++
	return (counter >= 8) || ..()
