/datum/controller/subsystem/job/proc/give_crew_objective(datum/mind/crewMind, mob/M)
	if(CONFIG_GET(flag/allow_crew_objectives) && (M?.client?.prefs.read_player_preference(/datum/preference/toggle/crew_objectives) || crewMind?.current?.client?.prefs.read_player_preference(/datum/preference/toggle/crew_objectives)))
		generate_individual_objectives(crewMind)
	return

/datum/controller/subsystem/job/proc/generate_individual_objectives(datum/mind/crewMind)
	if(!(CONFIG_GET(flag/allow_crew_objectives)))
		return
	if(!crewMind)
		return
	if(!crewMind.current || crewMind.special_role)
		return
	if(!crewMind.assigned_role)
		return
	var/list/valid_objs = crew_obj_jobs["[crewMind.assigned_role]"]
	if(!length(valid_objs))
		return
	var/selectedObj = pick(valid_objs)
	crewMind.add_crew_objective(selectedObj)

/// Adds a new crew objective of objective_type and informs the player (should be a subtype of /datum/objective/crew)
/datum/mind/proc/add_crew_objective(objective_type, silent = FALSE)
	var/datum/objective/crew/newObjective = new objective_type
	if(!newObjective)
		return
	newObjective.owner = src
	src.crew_objectives += newObjective
	if(!silent)
		to_chat(src, "<B>As a part of Nanotrasen's anti-tide efforts, you have been assigned an optional objective. It will be checked at the end of the shift. [span_warning("Performing traitorous acts in pursuit of your objective may result in termination of your employment.")]</B>")
		to_chat(src, "<B>Your objective:</B> [newObjective.explanation_text]")

/datum/objective/crew
	// Used for showing the roundend report again, instead of checking complete every time it's opened.
	var/declared_complete = FALSE
	// List or string of JOB_NAME defines that this applies to.
	var/jobs
	explanation_text = "Yell at people on github if this ever shows up. Something involving crew objectives is broken."
