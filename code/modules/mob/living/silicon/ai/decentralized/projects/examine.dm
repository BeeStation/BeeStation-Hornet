/datum/ai_project/examine_humans
	name = "Examination Upgrade"
	description = "Using experimental image enhancing algorithms will allow you to examine humans, albeit you won't be able to point out every detail.."
	research_cost = 2500
	ram_required = 3
	research_requirements = "Advanced Security HUD & Advanced Medical & Diagnostic HUD"
	category = AI_PROJECT_CAMERAS


/datum/ai_project/examine_humans/canResearch()
	return (dashboard.has_completed_projects("Advanced Security HUD") && dashboard.has_completed_projects("Advanced Medical & Diagnostic HUD"))

/datum/ai_project/examine_humans/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	ai.canExamineHumans = TRUE

/datum/ai_project/examine_humans/stop()
	ai.canExamineHumans = FALSE
	..()
