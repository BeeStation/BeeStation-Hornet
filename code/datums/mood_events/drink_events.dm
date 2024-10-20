/datum/mood_event/drunk
	mood_change = 3
	description = "<span class='nicegreen'>Everything just feels better after a drink or two.</span>"

/datum/mood_event/drunk/add_effects()
	// Display blush visual
	var/datum/component/L = owner
	var/mob/living/T = L.parent
	ADD_TRAIT(T, TRAIT_BLUSHING, "[type]")
	T.update_body()

/datum/mood_event/drunk/remove_effects()
	// Stop displaying blush visual
	var/datum/component/L = owner
	var/mob/living/T = L.parent
	REMOVE_TRAIT(T, TRAIT_BLUSHING, "[type]")
	T.update_body()

/datum/mood_event/quality_bad
	description = "<span class='warning'>That drink wasn't good at all.</span>"
	mood_change = -2
	timeout = 7 MINUTES

/datum/mood_event/quality_nice
	description = "<span class='nicegreen'>That drink wasn't bad at all.</span>"
	mood_change = 2
	timeout = 7 MINUTES

/datum/mood_event/quality_good
	description = "<span class='nicegreen'>That drink was pretty good.</span>"
	mood_change = 4
	timeout = 7 MINUTES

/datum/mood_event/quality_verygood
	description = "<span class='nicegreen'>That drink was great!</span>"
	mood_change = 6
	timeout = 7 MINUTES

/datum/mood_event/quality_fantastic
	description = "<span class='nicegreen'>That drink was amazing!</span>"
	mood_change = 8
	timeout = 7 MINUTES
