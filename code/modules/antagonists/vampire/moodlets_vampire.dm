/datum/mood_event/drankblood
	description = span_nicegreen("I have fed greedly from that which nourishes me.")
	mood_change = 10
	timeout = 8 MINUTES

/datum/mood_event/drankblood_bad
	description = span_boldwarning("I drank the blood of a lesser creature. Disgusting.")
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/drankblood_dead
	description = span_boldwarning("I drank dead blood. I am better than this.")
	mood_change = -7
	timeout = 8 MINUTES

/datum/mood_event/drankblood_synth
	description = span_boldwarning("I drank synthetic blood. What is wrong with me?")
	mood_change = -7
	timeout = 8 MINUTES

/datum/mood_event/drankkilled
	description = span_boldwarning("I fed off of a dead person. I feel... inhuman.")
	mood_change = -15
	timeout = 10 MINUTES

/datum/mood_event/madevamp
	description = span_boldwarning("A mortal has reached the undeath- by my own hand.")
	mood_change = 15
	timeout = 20 MINUTES

/datum/mood_event/coffinsleep
	description = span_nicegreen("I slept in a coffin during the day. I feel whole again.")
	mood_change = 10
	timeout = 6 MINUTES

///Candelabrum's mood event to non Vampire/Vassals
/datum/mood_event/vampcandle
	description = span_boldwarning("You feel something crawling in your mind...")
	mood_change = -15
	timeout = 5 MINUTES
