

/mob/living/carbon/alien/larva/Life(delta_time = SSMOBS_DT, times_fired)
	set invisibility = 0
	if (notransform)
		return
	if(!..() || IS_IN_STASIS(src) || (amount_grown >= max_grown))
		return // We're dead, in stasis, or already grown.
	// GROW!
	amount_grown = min(amount_grown + (0.5 * delta_time), max_grown)
	update_icons()

/mob/living/carbon/alien/larva/update_stat(forced = FALSE)
	. = ..()
	if(stat == UNCONSCIOUS)
		set_resting(FALSE)
	update_health_hud()
