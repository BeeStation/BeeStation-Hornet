/datum/status_datum
	var/name = "default datum"
	var/key = "default datum"

	/// if sharable TRUE, multiple type of this status will be generated. if FALSE, duration is increased to maximum if it's added again.
	var/type_sharable = TRUE

	/// stackable size of the same status - 1 default
	var/max_stack_size = 1

	var/starting_duration = 10
	var/maximum_duration = 5 MINUTES
	var/tick_per_time = 2 SECONDS


	var/apply_text = "You feel something."
	var/removal_text = "You feel no longer something."

	var/status_flags = NONE

/// NOTE: This must be called at the top of each inherted proc
/datum/status_datum/proc/on_add(atom/A, list/data)
	/* important note:
		While all of these status_datum share the basic type,
		`data` list has individual data for each atom,
		and can accept more custom data that it needs.
		check the healing example (omni_regeneration).
	*/
	if(status_flags & STATUS_FLAG_CHECK_PULSE)
		data["current_pulse"] = 0
	return

/// NOTE: This must be called at the ***END*** of each inherted proc
/datum/status_datum/proc/on_remove(atom/A, list/data)
	return

/// NOTE: This is not recommended to use in general. use `trigger_effect()`
/datum/status_datum/proc/on_progress(atom/A, list/data)
	if(status_flags & STATUS_FLAG_CHECK_PULSE)
		data["current_pulse"] += 1
	trigger_effect(A, data)
	return


/datum/status_datum/proc/trigger_effect(atom/A, list/data)
	return



// This is a sample datum
/datum/status_datum/omni_regeneration
	name = "Omni-regeneration"
	key = "NATURAL_HEAL"
	tick_per_time = 1 SECONDS
	status_flags = STATUS_FLAG_CHECK_PULSE

/datum/status_datum/omni_regeneration/on_add(atom/A, list/data)
	..()
	data["power"] = 1
	data["chance"] = 100

/datum/status_datum/omni_regeneration/trigger_effect(atom/A, list/data)
	..()
	var/mob/living/carbon/M = A
	if(!iscarbon(A))
		return
	if(prob(data["chance"]))
		M.adjustBruteLoss(-data["power"])
		M.adjustFireLoss(-data["power"])
		if(data["activate_tox_heal"])
			M.adjustToxLoss(-data["power"])

	if(data["activated_pulses"] == 10)
		data["power"] = 2
		data["chance"] = 33
		data["activate_tox_heal"] = TRUE

// sample code for omni_regeneration
/datum/reagent/medicine/bicarine
	name = "bicarine"
	taste_description = "bitterness"

/datum/reagent/medicine/bicarine/on_mob_life(mob/living/carbon/M)
	SSstatus.add_status(M, /datum/status_datum/omni_regeneration, 15)
	..()

/*
-----------------------------------------------------------------------------
	// Summary //
		bicarine gives you "Omni-regeneration" status for 15 seconds
		Omni-regeneration heals you for 1 brute/burn damage every a 1 second at a 100% chance.
		If it pulsed 10 times, it activates toxin healing as well as power is increased to 2, but chance is decreased to 33%
		This is not stackable, so it will increase duration to 5 minutes (default) if applied again.
		so, 8u of bicarine is capable of giving 300 seconds of healing.
-----------------------------------------------------------------------------
*/
