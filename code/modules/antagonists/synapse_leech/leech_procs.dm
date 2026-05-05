/// Adjusts saturation by an amount and updates the HUD display.
/mob/living/basic/synapse_leech/proc/adjust_saturation(amount)
	saturation = clamp(saturation + amount, 0, LEECH_MAX_SATURATION)
	update_saturation_display()

/// Adjusts substrate by an amount and updates the HUD display.
/mob/living/basic/synapse_leech/proc/adjust_substrate(amount)
	substrate = clamp(substrate + amount, 0, max_substrate)
	update_substrate_display()

// Leech toxin proc, called on the leech mob after a successful attack to apply toxin to the target.
/mob/living/basic/synapse_leech/proc/do_leech_toxin(mob/living/element_owner, atom/target, success)
	SIGNAL_HANDLER

	if(!success || !isliving(target))
		return

	var/mob/living/living_target = target
	if(living_target.stat == DEAD)
		return

	if(!living_target.reagents)
		return

	if(HAS_TRAIT(living_target, TRAIT_PIERCEIMMUNE))
		return

	if(substrate <= 0)
		return

	// If we are over 5 substrate, we just apply as normal.
	if(substrate > 5)
		living_target.reagents.add_reagent(toxin_type, LEECH_TOXIN_PER_ATTACK)
		adjust_substrate(-LEECH_TOXIN_PER_ATTACK)
	else
		// We have more than 0 substrate, but less than 5.
		living_target.reagents.add_reagent(toxin_type, substrate)
		adjust_substrate(-substrate)

/mob/living/basic/synapse_leech/proc/toggle_nightvision()
	if(lighting_alpha == LIGHTING_PLANE_ALPHA_VISIBLE)
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		to_chat(src, "<span class='notice'>You sharpen your senses to the dark.</span>")
	else
		lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
		to_chat(src, "<span class='notice'>You let your eyes relax.</span>")
	update_sight()

/mob/living/basic/synapse_leech/proc/toggle_hide_layer()
	if(hidden)
		stop_hiding()
	else
		start_hiding()

/// Attempt to enter hiding. Refuses if saturation is at or below the minimum threshold.
/mob/living/basic/synapse_leech/proc/start_hiding()
	if(hidden)
		return FALSE
	if(saturation <= LEECH_MIN_SATURATION)
		to_chat(src, "<span class='warning'>You are too exhausted to hide.</span>")
		return FALSE
	hidden = TRUE
	layer = ABOVE_NORMAL_TURF_LAYER
	to_chat(src, "<span class='notice'>You press yourself low against the floor.</span>")
	refresh_hide_button()
	return TRUE

/// Leave hiding. forced toggles a different message for auto-unhide due to starvation.
/mob/living/basic/synapse_leech/proc/stop_hiding(forced = FALSE)
	if(!hidden)
		return FALSE
	hidden = FALSE
	layer = initial(layer)
	if(forced)
		to_chat(src, "<span class='warning'>You are too exhausted to keep hiding, and slump back into view!</span>")
	else
		to_chat(src, "<span class='notice'>You crawl back into plain view.</span>")
	refresh_hide_button()
	return TRUE

/// Updates the hide HUD button icon to match current state.
/mob/living/basic/synapse_leech/proc/refresh_hide_button()
	if(!hud_used)
		return
	for(var/atom/movable/screen/leech/hide_toggle/button in hud_used.static_inventory)
		button.update_appearance()
