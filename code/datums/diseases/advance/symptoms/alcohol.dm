/datum/symptom/alcohol
	name = "Autobrewery Syndrome"
	desc = "The virus causes fermentation in the stomach, leading to chronic drunkenness."
	stealth = -1
	resistance = -2
	stage_speed = 3
	transmission = -1
	level = 6
	severity = 1
	symptom_delay_min = 5
	symptom_delay_max = 10
	prefixes = list("Drunken ", "Alcoholic ")
	var/target = 30 //how drunk should the target get? by default, its *just* below enough to cause vomiting
	threshold_desc = "<b>Stealth 3:</b> The host only reaches a slight buzz.<br>\
						<b>Stage Speed 6:</b> The levels of alcohol produced can be lethal. Overriden by the stealth threshold.<br>"

/datum/symptom/alcohol/severityset(datum/disease/advance/A)
	. = ..()
	if(A.stealth >= 3)
		severity -= 1
	else if(A.stage_rate >= 6)
		severity += 3

/datum/symptom/alcohol/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= 3)
		target = 13.35 //this is the ballmer point and has no real downsides- perfect if you want this to act as a minor beneficial symptom for a mood boost
	else if(A.stage_rate >= 6)
		target = 80//lethal, but only barely (for alcohol - 1 tox/tick is quite lethal). this nets decent healing if you have drunken resilience- provided you can deal with the toxins

/datum/symptom/alcohol/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	var/list/warningstrings = list()
	if(M.stat == DEAD)
		return
	switch(A.stage + severity)
		if(6 to 7)
			warningstrings = list("You feel drunk", "You feel a bit woozy")
		if(8 to INFINITY)
			warningstrings = list("ahyguabngaghabyugbauwf", "You feel sick", "It feels like you drank too much", "You feel like doing something unwise")
		else
			warningstrings = list("You feel buzzed", "You feel a bit tipsy")
	M.adjust_timed_status_effect(M.get_drunk_amount() + target * ((A.stage - 1) * 0.1), /datum/status_effect/inebriated, target)
	if(prob(5 * A.stage))
		to_chat(M, span_warning("[pick(warningstrings)]"))
