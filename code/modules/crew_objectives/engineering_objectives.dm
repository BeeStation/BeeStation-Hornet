/*				ENGINEERING OBJECTIVES				*/

/datum/objective/crew/integrity //ported from old Hippie
	explanation_text = "Ensure the station's integrity rating is at least (Something broke, yell on GitHub)% when the shift ends."
	jobs = list(
		JOB_NAME_CHIEFENGINEER,
		JOB_NAME_STATIONENGINEER,
	)

/datum/objective/crew/integrity/New()
	. = ..()
	target_amount = rand(60,95)
	update_explanation_text()

/datum/objective/crew/integrity/update_explanation_text()
	. = ..()
	explanation_text = "Ensure the station's integrity rating is at least [target_amount]% when the shift ends."

/datum/objective/crew/integrity/check_completion()
	if(..())
		return TRUE
	var/datum/station_state/end_state = new /datum/station_state()
	end_state.count()
	var/station_integrity = min(PERCENT(GLOB.start_state.score(end_state)), 100)
	return !GLOB.station_was_nuked && station_integrity >= target_amount

/datum/objective/crew/poly
	explanation_text = "Make sure Poly keeps his headset, and stays alive until the end of the shift."
	jobs = JOB_NAME_CHIEFENGINEER

/datum/objective/crew/poly/check_completion()
	if(..())
		return TRUE
	for(var/mob/living/simple_animal/parrot/Poly/dumbbird in GLOB.mob_list)
		if(dumbbird.stat != DEAD && istype(dumbbird.ears, /obj/item/radio/headset))
			return TRUE
	return FALSE
