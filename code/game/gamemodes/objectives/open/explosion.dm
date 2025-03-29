/datum/objective/open/explosion
	name = "detonate explosive"
	explanation_text = "Obtain and detonate an explosive device within %DEPARTMENT%."
	weight = 6
	var/selected_area
	var/list/valid_areas = list(
		"medical" = list(/area/medical),
		"engineering" = list(/area/engineering, /area/engine),
		"security" = list(/area/security),
		"the cargo bay" = list(/area/quartermaster, /area/cargo),
		"the bridge" = list(/area/bridge),
		"the communications relay" = list(/area/comms, /area/server, /area/tcommsat),
		"the science lab" = list(/area/science),
		"the research division server room" = list(/area/science/server),
		// Anywhere monitored by the AI will do
		"the AI's facilities" = list(/area/aisat, /area/ai_monitored),
		"the Captain's office" = list(/area/crew_quarters/heads/captain),
		"the Head of Personnel's office" = list(/area/crew_quarters/heads/hop)
	)
	var/success = FALSE
	var/devistation = 0
	var/heavy = 0
	var/light = 0

/datum/objective/open/explosion/New(text)
	. = ..()
	//Register for the signals
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION, PROC_REF(on_explosion))

/datum/objective/open/explosion/Destroy(force, ...)
	UnregisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION)
	. = ..()

/datum/objective/open/explosion/proc/on_explosion(datum/source, turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
	if(!light_impact_range && !heavy_impact_range && !devastation_range)
		return
	// Get all the areas that we effect
	var/list/affected_areas = list()
	var/area/A = get_area(epicenter)
	affected_areas += A
	for (var/turf/location in range(heavy_impact_range, epicenter))
		affected_areas |= location.loc
	var/list/target_area_types = valid_areas[selected_area]
	// Check for success
	for(var/target_type in target_area_types)
		for (var/located_area in affected_areas)
			if(istype(located_area, target_type))
				success = TRUE
				devistation = max(devistation, devastation_range)
				heavy = max(heavy, light_impact_range)
				light = max(light, light_impact_range)
				return

/datum/objective/open/explosion/update_explanation_text()
	var/objective_text = pick(\
		"Obtain and detonate an explosive device within %DEPARTMENT%.",\
		"Get your hands on any form of explosive device and detonate it inside of %DEPARTMENT%.",\
		"Deploy and activate an explosive inside of %DEPARTMENT%.",\
		"Cause fear and panic by detonating an explosive originating within %DEPARTMENT%.",\
		"Destroy a part of %DEPARTMENT% with an explosive device.")
	explanation_text = replacetext(objective_text, "%DEPARTMENT%", selected_area)

/datum/objective/open/explosion/check_completion()
	return success || ..()

/datum/objective/open/explosion/get_completion_message()
	if(!success)
		return "[explanation_text] [span_redtext("Fail!")]"
	return "[explanation_text] [span_infotext("Largest Bomb: ([devistation], [heavy], [light])")]"

/datum/objective/open/explosion/get_target()
	return selected_area

/datum/objective/open/explosion/find_target(list/dupe_search_range, list/blacklist)
	if(!dupe_search_range)
		dupe_search_range = get_owners()
	var/approved_targets = list()
	for(var/target_zone in valid_areas)
		if(!is_unique_objective(target_zone, dupe_search_range))
			continue
		approved_targets += target_zone
	set_target_zone(safepick(approved_targets))
	return selected_area

/datum/objective/open/explosion/proc/set_target_zone(target_zone)
	selected_area = target_zone
	//Update the explanation text
	update_explanation_text()
