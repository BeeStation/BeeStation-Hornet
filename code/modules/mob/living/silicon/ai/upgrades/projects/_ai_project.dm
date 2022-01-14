GLOBAL_LIST_EMPTY(ai_projects)

/datum/ai_project
	///Name of the project. This is used as an ID so please keep all names unique (Or refactor it to use an ID like you should)
	var/name = "DEBUG"
	var/description = "DEBUG"
	var/research_progress = 0
	var/category = AI_PROJECT_MISC
	///Research cost of project in seconds of CPU time.
	var/research_cost = 0
	var/ram_required = 0
	var/running = FALSE
	//Text for canResearch()
	var/research_requirements = "None"

	var/mob/living/silicon/ai/ai
	var/datum/ai_dashboard/dashboard

/datum/ai_project/New(new_ai, new_dash)
	ai = new_ai
	dashboard = new_dash
	if(!ai || !dashboard)
		qdel(src)
	..()

/datum/ai_project/proc/canResearch()
	return TRUE

/datum/ai_project/proc/run_project(force_run = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	if(!force_run)
		if(!canRun())
			return FALSE
	running = TRUE
	return TRUE

/datum/ai_project/proc/stop()
	SHOULD_CALL_PARENT(TRUE)
	running = FALSE
	return TRUE

/datum/ai_project/proc/canRun() //Important! This isn't for checking processing requirements. That is checked on the AI for ease of references (See ai_dashboard.dm). This is just for special cases (Like uhh, not wanting the program to run while X runs or similar)
	SHOULD_CALL_PARENT(TRUE)
	return !running
