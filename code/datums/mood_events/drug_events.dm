/datum/mood_event/high
	mood_change = 6
	description = span_nicegreen("Woooow duudeeeeee...I'm tripping baaalls...")

/datum/mood_event/stoned
	mood_change = 6
	description = "I'm sooooo stooooooooooooned..."

/datum/mood_event/smoked
	description = span_nicegreen("I have had a smoke recently.")
	mood_change = 2
	timeout = 6 MINUTES

/datum/mood_event/wrong_brand
	description = span_warning("I hate that brand of cigarettes.")
	mood_change = -2
	timeout = 6 MINUTES

/datum/mood_event/overdose
	mood_change = -8
	timeout = 5 MINUTES

/datum/mood_event/overdose/add_effects(drug_name)
	description = span_warning("I think I took a bit too much of that [drug_name]")

/datum/mood_event/withdrawal_light
	mood_change = -2

/datum/mood_event/withdrawal_light/add_effects(drug_name)
	description = span_warning("I could use some [drug_name]")

/datum/mood_event/withdrawal_medium
	mood_change = -5

/datum/mood_event/withdrawal_medium/add_effects(drug_name)
	description = span_warning("I really need [drug_name]")

/datum/mood_event/withdrawal_severe
	mood_change = -8

/datum/mood_event/withdrawal_severe/add_effects(drug_name)
	description = span_boldwarning("Oh god I need some [drug_name]!")

/datum/mood_event/withdrawal_critical
	mood_change = -10

/datum/mood_event/withdrawal_critical/add_effects(drug_name)
	description = span_boldwarning("[drug_name]! [drug_name]! [drug_name]!")

/datum/mood_event/happiness_drug
	description = span_nicegreen("I can't feel anything and I never want this to end.")
	mood_change = 50

/datum/mood_event/happiness_drug_good_od
	description = span_nicegreen("YES! YES!! YES!!!")
	mood_change = 100
	timeout = 30 SECONDS
	special_screen_obj = "mood_happiness_good"

/datum/mood_event/happiness_drug_bad_od
	description = span_boldwarning("NO! NO!! NO!!!")
	mood_change = -100
	timeout = 30 SECONDS
	special_screen_obj = "mood_happiness_bad"

/datum/mood_event/nicotine_withdrawal_moderate
	description = "Haven't had a smoke in a while. Feeling a little on edge... "
	mood_change = -5

/datum/mood_event/nicotine_withdrawal_severe
	description = "Head pounding. Cold sweating. Feeling anxious. Need a smoke to calm down!"
	mood_change = -8
