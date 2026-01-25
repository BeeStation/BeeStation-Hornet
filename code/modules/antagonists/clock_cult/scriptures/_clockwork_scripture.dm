GLOBAL_LIST_EMPTY(clockcult_all_scriptures)

/**
 * Create a global list to reference scriptures by their name
 * Only needs to be called once
 */
/proc/generate_clockcult_scriptures()
	// Generate scriptures
	for(var/categorypath in subtypesof(/datum/clockcult/scripture))
		var/datum/clockcult/scripture/scripture = new categorypath
		GLOB.clockcult_all_scriptures[scripture.name] = scripture

/datum/clockcult/scripture
	/// The name of the scripture
	var/name = ""
	/// The description of the scripture
	var/desc = ""
	/// A tip on how to use the scripture
	var/tip = ""
	/// The text that is recited when invoking this scripture
	var/list/invokation_text = list()
	/// How long it takes to invoke this scripture
	var/invokation_time = 1 SECONDS
	/// How many clock cultists that must be in range of the slab to invoke this scripture
	var/invokers_required = 1
	/// The icon for the scripture's quick bind button
	var/button_icon_state = "Abscond"
	/// How much power this scripture draws from the ark
	var/power_cost = 0
	/// How much vitality this scripture draws from the ark
	var/vitality_cost = 0
	/// The amount of cogs required to invoke this scripture
	var/cogs_required = 0
	/// The category of the scripture (SPELLTYPE_ABSTRACT, SPELLTYPE_SERVITUDE, SPELLTYPE_PRESERVATION, SPELLTYPE_STRUCTURES)
	var/category = SPELLTYPE_ABSTRACT
	/// Set to FALSE if the scripture should not end after it finishes charging, for example: Kindle
	var/end_on_invokation = TRUE
	/// The person invoking the scripture
	var/mob/living/invoker
	/// Reference to the slab that is invoking this scripture
	var/obj/item/clockwork/clockwork_slab/invoking_slab
	/// The sound that plays when reciting the scripture
	var/sound/recital_sound
	/// If this is TRUE, the scripture does not have to be unlocked to be invoked
	var/should_bypass_unlock_checks = FALSE

/datum/clockcult/scripture/New(obj/item/clockwork/clockwork_slab/slab, bypass_unlock_checks = FALSE)
	invoking_slab = slab
	should_bypass_unlock_checks = bypass_unlock_checks

/datum/clockcult/scripture/proc/try_to_invoke(mob/living/user)
	invoker = user
	invoking_slab.invoking_scripture = src

	// Basic checks
	if(!can_invoke())
		dispose()
		return

	// Recite the invokation text
	if(length(invokation_text))
		var/time_between_say = invokation_time / length(invokation_text)
		recite(text_point = 1, wait_time = time_between_say, stop_at = length(invokation_text))

	if(do_after(invoker, invokation_time, target = invoker, extra_checks = CALLBACK(src, PROC_REF(can_invoke))))
		on_invoke_success()
		if(end_on_invokation)
			on_invoke_end()
	else
		dispose()

/**
 * Basic checks to see if the scripture can be invoked
 */
/datum/clockcult/scripture/proc/can_invoke()
	SHOULD_CALL_PARENT(TRUE)
	if(GLOB.clockcult_power < power_cost)
		invoker.balloon_alert(invoker, "not enough power!")
		return FALSE
	if(GLOB.clockcult_vitality < vitality_cost)
		invoker.balloon_alert(invoker, "not enough vitality!")
		return FALSE
	if(invoker.get_active_held_item() != invoking_slab && !iscyborg(invoker))
		invoker.balloon_alert(invoker, "not in hand!")
		return FALSE
	if(!should_bypass_unlock_checks && !invoking_slab.scriptures[src.type])
		stack_trace("Attempting to invoke a scripture that has not been unlocked. Either there is a bug, or [ADMIN_LOOKUP(invoker)] is using some wacky exploits.")
		invoker.balloon_alert(invoker, "not unlocked!")
		return FALSE

	var/invokers
	for(var/mob/living/potential_invoker in viewers(invoker))
		if(potential_invoker.stat != CONSCIOUS)
			continue
		if(!IS_SERVANT_OF_RATVAR(potential_invoker))
			continue

		invokers++

	if(invokers < invokers_required)
		var/invoker_delta = invokers_required - invokers
		invoker.balloon_alert(invoker, "missing [invoker_delta] invoker[invoker_delta > 1 ? "s" : null]!")
		return FALSE

	return TRUE

/**
 * Here is where you put the code that runs when the scripture is succesfully invoked
 * For example, Summon Replica Fabricator will instantiate a replica fabricator
 * Only parent call if you successfully casted your spell
 */
/datum/clockcult/scripture/proc/on_invoke_success()
	SHOULD_CALL_PARENT(TRUE)
	GLOB.clockcult_power -= power_cost
	GLOB.clockcult_vitality -= vitality_cost

/**
 * Here is where you put the code that runs when the scripture's invokation ends
 * When inhereting this, ..() should be called at the END
 */
/datum/clockcult/scripture/proc/on_invoke_end()
	SHOULD_CALL_PARENT(TRUE)
	dispose()

/*
* This isn't with on_invoke_end() because we don't want to call whatever logic we use whenever we for example, fail the do_after in try_to_invoke()
*/
/datum/clockcult/scripture/proc/dispose()
	SHOULD_CALL_PARENT(TRUE)
	invoking_slab.invoking_scripture = null

/*
* A recursive proc that calls itself until all parts of invokation_text have been recited
*/
/datum/clockcult/scripture/proc/recite(text_point, wait_time, stop_at = 0)
	if(QDELETED(src))
		return

	// Need to check this each time we invoke, as the conditions may have changed
	if(!can_invoke())
		return

	// Time to recite the message
	var/invokers_left = invokers_required
	if(invokers_required > 1)
		// This scripture requires multiple invokers, lets find them and start reciting
		for(var/mob/living/possible_invoker in viewers(invoker))
			if(!invokers_left)
				break
			if(possible_invoker.stat != CONSCIOUS)
				continue

			// Say the invokation text
			if(IS_SERVANT_OF_RATVAR(possible_invoker))
				clockwork_say(possible_invoker, text2ratvar(invokation_text[text_point]), TRUE)
				if(recital_sound)
					SEND_SOUND(possible_invoker, recital_sound)
				invokers_left--
	else
		// Just a single invoker required, lets have our invoker recite the text
		clockwork_say(invoker, text2ratvar(invokation_text[text_point]), TRUE)

		if(recital_sound)
			SEND_SOUND(invoker, recital_sound)

	// Recite the next line
	if(text_point < stop_at)
		text_point++
		addtimer(CALLBACK(src, PROC_REF(recite), text_point, wait_time, stop_at), wait_time, TIMER_STOPPABLE)
