//nutrition
/datum/mood_event/fat
	description = "<span class='warning'><B>I'm so fat.</B></span>\n" //muh fatshaming
	mood_change = -6

/datum/mood_event/wellfed
	description = "<span class='nicegreen'>I'm stuffed!</span>\n"
	mood_change = 8

/datum/mood_event/fed
	description = "<span class='nicegreen'>I have recently had some food.</span>\n"
	mood_change = 5

/datum/mood_event/hungry
	description = "<span class='warning'>I'm getting a bit hungry.</span>\n"
	mood_change = -10

/datum/mood_event/starving
	description = "<span class='boldwarning'>I'm starving!</span>\n"
	mood_change = -16

//charge
/datum/mood_event/charged
	description = "<span class='nicegreen'>I feel the power in my veins!</span>\n"
	mood_change = 6

/datum/mood_event/lowpower
	description = "<span class='warning'>My power is running low, I should go charge up somewhere.</span>\n"
	mood_change = -10

/datum/mood_event/decharged
	description = "<span class='boldwarning'>I'm in desperate need of some electricity!</span>\n"
	mood_change = -15

//Disgust
/datum/mood_event/gross
	description = "<span class='warning'>I saw something gross.</span>\n"
	mood_change = -4

/datum/mood_event/verygross
	description = "<span class='warning'>I think I'm going to puke.</span>\n"
	mood_change = -6

/datum/mood_event/disgusted
	description = "<span class='boldwarning'>Oh god, that's disgusting.</span>\n"
	mood_change = -8

/datum/mood_event/disgust/bad_smell
	description = "<span class='warning'>I can smell something horribly decayed inside this room.</span>\n"
	mood_change = -6

/datum/mood_event/disgust/nauseating_stench
	description = "<span class='warning'>The stench of rotting carcasses is unbearable!</span>\n"
	mood_change = -12

//Hygiene Events
/datum/mood_event/neat
	description = "<span class='nicegreen'>I'm so clean, I love it.</span>\n"
	mood_change = 3

/datum/mood_event/dirty
	description = "<span class='warning'>I smell horrid.</span>\n"
	mood_change = -3

/datum/mood_event/disgusting
	description = "<span class='warning'>I smell <i>DISGUSTING!</i></span>\n"
	mood_change = -5

/datum/mood_event/happy_neet
	description = "<span class='nicegreen'>I smell horrid.</span>\n"
	mood_change = 2

//Generic needs events
/datum/mood_event/favorite_food
	description = "<span class='nicegreen'>I really enjoyed eating that.</span>\n"
	mood_change = 5
	timeout = 4 MINUTES

/datum/mood_event/gross_food
	description = "<span class='warning'>I really didn't like that food.</span>\n"
	mood_change = -2
	timeout = 4 MINUTES

/datum/mood_event/disgusting_food
	description = "<span class='warning'>That food was disgusting!</span>\n"
	mood_change = -6
	timeout = 4 MINUTES

/datum/mood_event/breakfast
	description = "<span class='nicegreen'>Nothing like a hearty breakfast to start the shift.</span>\n"
	mood_change = 2
	timeout = 10 MINUTES

/datum/mood_event/nice_shower
	description = "<span class='nicegreen'>I have recently had a nice shower.</span>\n"
	mood_change = 4
	timeout = 5 MINUTES

/datum/mood_event/fresh_laundry
	description = "<span class='nicegreen'>There's nothing like the feeling of a freshly laundered jumpsuit.</span>\n"
	mood_change = 2
	timeout = 10 MINUTES
