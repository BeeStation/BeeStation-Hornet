/datum/atom_status
	var/name = "default datum"
	var/key = "default datum"

	/// stackable size of the same status - 1 default
	var/max_stack_size = 1
	/// if duration variable is not given, starting duration will be set
	var/starting_duration = 10
	/// even if duration is stacked, it will not go over its maximum duration
	var/maximum_duration = 5 MINUTES
	/// on_progress() will be activated for every 2 ticks (=a mob tick). only integer valid.
	var/pulse_per_tick = 2


	var/apply_text = "You feel something."
	var/removal_text = "You feel no longer something."

/// This must be called at the top of each inherited proc
/datum/atom_status/proc/on_add(atom/A, list/data)
	/* important note:
		While all of these atom_status share the basic type,
		`data` list has individual data for each atom,
		and can accept more custom data that it needs.
		check the healing example (omni_regeneration).
	*/
	return

/// This must be called at the ***END*** of each inherited proc
/datum/atom_status/proc/on_remove(atom/A, list/data)
	return

/// This must be called at the ***TOP*** of each inherited proc, Also, this is not recommended to use in general. use `trigger_effect()`
/datum/atom_status/proc/on_progress(atom/A, list/data)
	trigger_effect(A, data)
	return

/// This must be generally used to trigger effect
/datum/atom_status/proc/trigger_effect(atom/A, list/data)
	return

// This is a sample datum
/datum/atom_status/omni_regeneration
	name = "Omni-regeneration"
	key = "NATURAL_HEAL"
	pulse_per_tick = 1

/datum/atom_status/omni_regeneration/on_add(atom/A, list/data)
	..()
	data["power"] = 1
	data["chance"] = 100

/datum/atom_status/omni_regeneration/trigger_effect(atom/A, list/data)
	..()
	var/mob/living/carbon/M = A
	if(!iscarbon(A))
		return
	if(prob(data["chance"]))
		M.adjustBruteLoss(-data["power"])
		M.adjustFireLoss(-data["power"])
		if(data["activate_tox_heal"])
			M.adjustToxLoss(-data["power"])

	if(data["current_pulse"] == 10)
		data["power"] = 2
		data["chance"] = 33
		data["activate_tox_heal"] = TRUE

// sample code for omni_regeneration
/datum/reagent/medicine/bicarine
	name = "bicarine"
	taste_description = "bitterness"

/datum/reagent/medicine/bicarine/on_mob_life(mob/living/carbon/M)
	SSstatus.add_status(M, /datum/atom_status/omni_regeneration, 15)
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
