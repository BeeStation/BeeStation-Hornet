/datum/mood_event/drunk
	mood_change = 3
	description = span_nicegreen("Everything just feels better after a drink or two.")

/datum/mood_event/drunk/add_effects(drunkness)
	update_change(drunkness)
	// Display blush visual
	var/datum/component/L = owner
	var/mob/living/T = L.parent
	ADD_TRAIT(T, TRAIT_BLUSHING, "[type]")
	T.update_body()

/// Updates the description and value of the moodlet according to the passed drunkness value
/// (Does not add to or remove from the current level - it will sets it directly to the new value)
/datum/mood_event/drunk/proc/update_change(drunkness = 0)
	var/old_mood = mood_change
	switch(drunkness)
		if(0 to 30)
			mood_change = 3
			description = "Everything just feels better after a drink or two."
		if(30 to 45)
			mood_change = 4
			description = "Is it getting hotter, or is it just me? I need another drink to cool down."
		if(45 to 60)
			mood_change = 5
			description = "Who keeps moving the floor? I'm going to talk to them... after this drink."
		if(60 to 90)
			mood_change = 6
			description = "I'm noooot drunk, you're drunk! In fact... I need another drink!"
		if(90 to INFINITY)
			mood_change = 3 // crash out
			description = "You're my BESSST frien'... You and me agains' th' world, buddy. Le's get another drink."
	if(old_mood != mood_change)
		var/datum/component/mood/mood = owner.GetComponent(/datum/component/mood)
		if(!mood)
			return
		mood.update_mood()

/datum/mood_event/drunk/remove_effects()
	// Stop displaying blush visual
	var/datum/component/L = owner
	var/mob/living/T = L.parent
	REMOVE_TRAIT(T, TRAIT_BLUSHING, "[type]")
	T.update_body()

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
