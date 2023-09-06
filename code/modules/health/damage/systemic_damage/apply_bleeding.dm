
/**
 * Causes the atom to start bleeding
 */
/atom/proc/apply_bleeding(bleed_amount, max_intensity)
	return

/mob/living/apply_bleeding(bleed_amount, max_intensity)
	target.bleed_rate = max(target.bleed_rate + bleed_amount, max_intensity)
