/datum/mood_event/high
	mood_change = 6
	description = "Woooow duudeeeeee...I'm tripping baaalls...\n"

/datum/mood_event/smoked
	description = "I have had a smoke recently.\n"
	mood_change = 2
	timeout = 6 MINUTES

/datum/mood_event/wrong_brand
	description = "I hate that brand of cigarettes.\n"
	mood_change = -2
	timeout = 6 MINUTES

/datum/mood_event/overdose
	mood_change = -8
	timeout = 5 MINUTES

/datum/mood_event/overdose/add_effects(drug_name)
	description = "I think I took a bit too much of that [drug_name]\n"

/datum/mood_event/withdrawal_light
	mood_change = -2

/datum/mood_event/withdrawal_light/add_effects(drug_name)
	description = "I could use some [drug_name]\n"

/datum/mood_event/withdrawal_medium
	mood_change = -5

/datum/mood_event/withdrawal_medium/add_effects(drug_name)
	description = "I really need [drug_name]\n"

/datum/mood_event/withdrawal_severe
	mood_change = -8

/datum/mood_event/withdrawal_severe/add_effects(drug_name)
	description = "Oh god I need some [drug_name]\n"

/datum/mood_event/withdrawal_critical
	mood_change = -10

/datum/mood_event/withdrawal_critical/add_effects(drug_name)
	description = "[drug_name]! [drug_name]! [drug_name]!\n"

/datum/mood_event/happiness_drug
	description = "I can't feel anything and I never want this to end.\n"
	mood_change = 50

/datum/mood_event/happiness_drug_good_od
	description = "YES! YES!! YES!!!\n"
	mood_change = 100
	timeout = 30 SECONDS
	special_screen_obj = "mood_happiness_good"

/datum/mood_event/happiness_drug_bad_od
	description = "NO! NO!! NO!!!\n"
	mood_change = -100
	timeout = 30 SECONDS
	special_screen_obj = "mood_happiness_bad"
