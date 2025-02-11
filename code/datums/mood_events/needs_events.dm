//nutrition
/datum/mood_event/fat
	description = span_warning("<B>I'm so fat.</B>") //muh fatshaming
	mood_change = -6

/datum/mood_event/wellfed
	description = span_nicegreen("I'm stuffed!")
	mood_change = 8

/datum/mood_event/fed
	description = span_nicegreen("I have recently had some food.")
	mood_change = 5

/datum/mood_event/hungry
	description = span_warning("I'm getting a bit hungry.")
	mood_change = -10

/datum/mood_event/starving
	description = span_boldwarning("I'm starving!")
	mood_change = -16

//charge
/datum/mood_event/charged
	description = span_nicegreen("I feel the power in my veins!")
	mood_change = 6

/datum/mood_event/lowpower
	description = span_warning("My power is running low, I should go charge up somewhere.")
	mood_change = -10

/datum/mood_event/decharged
	description = span_boldwarning("I'm in desperate need of some electricity!")
	mood_change = -15

//Disgust
/datum/mood_event/gross
	description = span_warning("I saw something gross.")
	mood_change = -4

/datum/mood_event/verygross
	description = span_warning("I think I'm going to puke.")
	mood_change = -6

/datum/mood_event/disgusted
	description = span_boldwarning("Oh god, that's disgusting.")
	mood_change = -8

/datum/mood_event/disgust/bad_smell
	description = span_warning("I can smell something horribly decayed inside this room.")
	mood_change = -6

/datum/mood_event/disgust/nauseating_stench
	description = span_warning("The stench of rotting carcasses is unbearable!")
	mood_change = -12

//Generic needs events
/datum/mood_event/nice_shower
	description = span_nicegreen("I have recently had a nice shower.")
	mood_change = 4
	timeout = 5 MINUTES

/datum/mood_event/fresh_laundry
	description = span_nicegreen("There's nothing like the feeling of a freshly laundered jumpsuit.")
	mood_change = 2
	timeout = 10 MINUTES
