/datum/mood_event/drunk
	mood_change = 3
	description = span_nicegreen("Everything just feels better after a drink or two.") 

/datum/mood_event/quality_bad
	description = span_warning("That drink wasn't good at all.") 
	mood_change = -2
	timeout = 7 MINUTES

/datum/mood_event/quality_nice
	description = span_nicegreen("That drink wasn't bad at all.") 
	mood_change = 2
	timeout = 7 MINUTES

/datum/mood_event/quality_good
	description = span_nicegreen("That drink was pretty good.") 
	mood_change = 4
	timeout = 7 MINUTES

/datum/mood_event/quality_verygood
	description = span_nicegreen("That drink was great!") 
	mood_change = 6
	timeout = 7 MINUTES

/datum/mood_event/quality_fantastic
	description = span_nicegreen("That drink was amazing!") 
	mood_change = 8
	timeout = 7 MINUTES
