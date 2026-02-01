/datum/clockcult/scripture/slab
	end_on_invokation = FALSE

	/// How much time to use this scripture before the invokation automatically ends
	var/max_time = 5 SECONDS
	/// The overlay applied to the slab while this scripture is invoked
	var/slab_overlay = "volt"
	/// What the invoker says after using successfully applying the effects
	var/after_use_text
	/// Internal action for this scripture
	var/datum/action/spell/pointed/slab/action
	/// Slab empowerment scriptures apply a progress bar to the slab to show how much time they have left
	var/datum/progressbar/progress_bar
	/// Some effects take time to apply. Lets keep track of whether or not we're currently apply effects so count_down() won't cut us off.
	var/currently_applying_effects = FALSE
	/// Some slab empowerment abilities, like Vanguard, don't actually have you click on a target
	var/should_set_click_ability = TRUE

/datum/clockcult/scripture/slab/New()
	. = ..()
	if(should_set_click_ability)
		action = new
		action.name = src.name
		action.parent_scripture = src
		action.deactive_msg = ""

/datum/clockcult/scripture/slab/Destroy()
	if(progress_bar)
		progress_bar.end_progress() // calling this QDELs it
		progress_bar = null

	if(!QDELETED(action))
		QDEL_NULL(action)
	return ..()

/**
 * Don't inherent the base behavior here
 * We don't want to apply the costs of this scripture until we've actually applied the effects
 */
/datum/clockcult/scripture/slab/on_invoke_success()
	SHOULD_CALL_PARENT(FALSE)
	// Start progress bar
	progress_bar = new(invoker, max_time, invoking_slab)
	count_down()

	// Apply overlay to the slab
	invoking_slab.charge_overlay = slab_overlay
	invoking_slab.update_icon()

	// Set slab's active scripture
	invoking_slab.active_scripture = src

	// Set click ability
	if(should_set_click_ability)
		action.set_click_ability(invoker)

/datum/clockcult/scripture/slab/dispose()
	. = ..()
	invoking_slab.active_scripture = null

/**
 * A recursive proc to keep counting down from max_time
 * Once max_time equals 0, we forcibly end the invokation
 */
/datum/clockcult/scripture/slab/proc/count_down()
	if(QDELETED(src))
		return

	// Decrease progress bar
	if(!currently_applying_effects)
		progress_bar?.update(max_time)
		max_time--

	// Update progress bar in one tick
	if(max_time > 0)
		addtimer(CALLBACK(src, PROC_REF(count_down)), 0.1 SECONDS, TIMER_STOPPABLE)
	else
		invoker.balloon_alert(invoker, "ran out of time!")
		end_invocation()

/**
 * Make sure we can interact with the target and then apply effects
 * Called from /datum/action/spell/pointed/slab/InterceptClickOn()
 */
/datum/clockcult/scripture/slab/proc/click_on(atom/clicked_on)
	if(!invoker.can_interact_with(clicked_on))
		return

	// No targeting multiple people
	if(currently_applying_effects)
		return

	if(!apply_effects(clicked_on))
		currently_applying_effects = FALSE
		return

	currently_applying_effects = FALSE

	// Apply cost
	GLOB.clockcult_power -= power_cost
	GLOB.clockcult_vitality -= vitality_cost

	if(after_use_text)
		clockwork_say(invoker, text2ratvar(after_use_text), TRUE)

	end_invocation()

/datum/clockcult/scripture/slab/proc/end_invocation()
	// Alert invoker
	to_chat(invoker, span_brass("You are no longer invoking <b>[name]</b>"))

	// Clear click ability
	if(should_set_click_ability)
		action.unset_click_ability(invoker)

	// Clear overlay and slab's active scripture
	invoking_slab.charge_overlay = null
	invoking_slab.update_icon()

	invoking_slab.active_scripture = null

	// Reset progress bar
	progress_bar?.end_progress()
	progress_bar = null
	max_time = initial(max_time)

	on_invoke_end()

/**
 * Apply effects to the target
 * return TRUE if it succeeds
 */
/datum/clockcult/scripture/slab/proc/apply_effects(atom/target_atom)
	currently_applying_effects = TRUE
	return TRUE

/datum/action/spell/pointed/slab
	/// The scripture that this action will invoke
	var/datum/clockcult/scripture/slab/parent_scripture

/datum/action/spell/pointed/slab/InterceptClickOn(mob/living/clicker, params, atom/target)
	INVOKE_ASYNC(parent_scripture, TYPE_PROC_REF(/datum/clockcult/scripture/slab, click_on), target)
