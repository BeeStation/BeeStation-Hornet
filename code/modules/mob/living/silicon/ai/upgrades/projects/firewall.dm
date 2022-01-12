/datum/ai_project/firewall
	name = "Download Firewall"
	description = "By hiding your various functions you should be able to prolong the time it takes to download your consciousness by 2x."
	research_cost = 1000
	ram_required = 2
	research_requirements = "None"
	category = AI_PROJECT_MISC

/datum/ai_project/firewall/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	ai.downloadSpeedModifier *= 0.5


/datum/ai_project/firewall/stop()
	ai.downloadSpeedModifier *= 2
	..()
