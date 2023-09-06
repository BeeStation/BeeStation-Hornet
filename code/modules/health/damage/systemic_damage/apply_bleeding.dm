
/**
 * Causes the atom to start bleeding
 */
/atom/proc/apply_bleeding(bleed_amount, max_intensity)
	return

/mob/living/carbon/human/apply_bleeding(bleed_amount, max_intensity)
	bleed_rate = max(bleed_rate + bleed_amount, max_intensity)
