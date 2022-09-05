#define BOLD_LIMIT 5  // used for both positive and negative bolds for symmetry

/datum/mood_event
	var/description ///For descriptions, use the span classes bold nicegreen, nicegreen, none, warning and boldwarning in order from great to horrible.
	var/mood_change = 0
	var/timeout = 0
	var/timer //Timer ID for this event (if it has a timeout)
	var/hidden = FALSE//Not shown on examine
	var/category //string of what category this mood was added in as
	var/special_screen_obj //if it isn't null, it will replace or add onto the mood icon with this (same file). see happiness drug for example
	var/special_screen_replace = TRUE //if false, it will be an overlay instead
	var/mob/owner
	var/span // if null, will be generated from mood change

/datum/mood_event/New(mob/M, param)
	owner = M
	add_effects(param)

	if(!span)
		span = generate_mood_span(mood_change)

	description = "<span class='[span]'>[description]</span>"

/proc/generate_mood_span(adjust)
    switch(mood_change)
        if(-INFINITY to -BOLD_LIMIT)
            span = "boldwarning"
        if(-BOLD_LIMIT to -1)
            span = "warning"
        if(0)
            span = "emote"  // nice grey color
        if(BOLD_LIMIT to INFINITY)  // need to catch the upper bolding first
            span = "greenannounce"
        if(1 to BOLD_LIMIT)
            span = "nicegreen"

/datum/mood_event/Destroy()
	remove_effects()
	owner = null
	if(timer)
		deltimer(timer)
	return ..()

/datum/mood_event/proc/add_effects(param)
	return

/datum/mood_event/proc/remove_effects()
	return

#undef BOLD_LIMIT
