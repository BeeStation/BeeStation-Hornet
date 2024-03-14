/datum/mood_event/poolparty
	description = "<span class='nicegreen'>I love swimming!.</span>"
	mood_change = 2
	timeout = 2 MINUTES

/datum/mood_event/robotpool
	description = "<span class='warning'>I really wasn't built with water resistance in mind...</span>"
	mood_change = -3
	timeout = 2 MINUTES

/datum/mood_event/poolwet
	description = "<span class='warning'>Eugh! my clothes are soaking wet from that swim.</span>"
	mood_change = -4
	timeout = 4 MINUTES

/datum/mood_event/stuck_in_pool
	description = "<span class='boldwarning'>I'M STUCK IN THE POOL!</span>\n"
	mood_change = -5 //felinids really hate water

/datum/mood_event/was_stuck_in_pool
	description = "<span class='warning'>I was stuck in the pool, I never thought I'd get out.</span>\n"
	mood_change = -2 //felinids really hate water
	timeout = 4 MINUTES

