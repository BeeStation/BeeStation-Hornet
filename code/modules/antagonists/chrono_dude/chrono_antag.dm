/*
	- TIMELINE CORRECTION AGENT -

	CONTENTS
		TCA antag datum
		Objectives
		Pinpointer
		TA antag datum (the sucker that got targeted)
*/


/datum/antagonist/tca
	name = "Timeline Correction Agent"
	show_in_roundend = TRUE
	can_coexist_with_others = FALSE
	give_objectives = TRUE
	replace_banned = TRUE
	antag_moodlet = /datum/mood_event/focused
	delay_roundend = FALSE

	show_in_antagpanel = TRUE
	antagpanel_category = "Timeline Correction Agent"
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	var/datum/antagonist/ta/prey

/datum/antagonist/tca/on_gain()
	. = ..()
	var/mob/living/carbon/human/H = owner.current
	H.set_species(/datum/species/human/supersoldier)
	H.equipOutfit(/datum/outfit/chrono_agent)

/datum/antagonist/tca/proc/assign_prey(datum/antagonist/ta/target)
	if (target)
		prey = target

		var/datum/objective/correct_timeline/obj = new()	// and an objective to go with that
		obj.owner = owner
		obj.update_explanation_text()
		objectives += obj
		log_objective(owner, obj.explanation_text)

/datum/antagonist/tca/apply_innate_effects()
	.=..()
	if(owner?.current)
		owner.current.apply_status_effect(/datum/status_effect/agent_pinpointer/chrono_correction)

/datum/antagonist/tca/remove_innate_effects()
	.=..()
	if(owner?.current)
		owner.current.remove_status_effect(/datum/status_effect/agent_pinpointer/chrono_correction)

/datum/antagonist/tca/greet()
	to_chat(owner, "<span class='warning'>Something went wrong in the timeline, and they sent you to correct the mistakes!</span>")
	owner.announce_objectives()

/datum/antagonist/tca/proc/mission_concluded()
	if (prey?.owner && (!prey.owner.current || !prey.owner.current.stat))
		return FALSE
	return TRUE

/datum/objective/correct_timeline
	name = "timeline correction"

/datum/objective/correct_timeline/update_explanation_text()
	. = ..()
	var/datum/antagonist/tca/agent = owner.has_antag_datum(/datum/antagonist/tca)
	if (agent?.prey?.owner?.current)
		explanation_text = "Correct the timeline by permanently removing [agent.prey.owner.current.real_name]."

/datum/objective/correct_timeline/check_completion()
	if(!owner)
		return FALSE
	var/datum/antagonist/tca/agent = owner.has_antag_datum(/datum/antagonist/tca)
	if (agent)
		return agent.mission_concluded()
	return FALSE

/datum/status_effect/agent_pinpointer/chrono_correction
	alert_type = /atom/movable/screen/alert/status_effect/agent_pinpointer/chrono_correction
	minimum_range = 0
	tick_interval = 40	//this is REALLY expensive tho
	range_fuzz_factor = 0

/datum/status_effect/agent_pinpointer/chrono_correction/scan_for_target()
	var/datum/antagonist/tca/hunter = owner.mind?.has_antag_datum(/datum/antagonist/tca)
	if (hunter.prey?.owner)
		scan_target = hunter.prey.owner
	else
		scan_target = null	//your mission is complete, go home!

/atom/movable/screen/alert/status_effect/agent_pinpointer/chrono_correction
	name = "Target Locator"
	desc = "Reminder; shoot first, ask questions later."

/datum/antagonist/ta
	name = "Timeline Anomaly"
	show_in_roundend = TRUE
	give_objectives = FALSE
	replace_banned = FALSE
	delay_roundend = FALSE

	show_in_antagpanel = TRUE
	antagpanel_category = "Timeline Correction Agent"
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = FALSE

/datum/antagonist/ta/greet()
	to_chat(owner, "<span class='userdanger'>A timeline correction agent has been dispatched to eradicate you from the timeline!</span>")


/datum/antagonist/tca/on_gain()
	. = ..()
	var/mob/living/carbon/human/sucker = owner
	if (sucker)
		sucker.hellbound = TRUE
