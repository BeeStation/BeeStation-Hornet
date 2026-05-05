/mob/living/basic/synapse_leech/Life(delta_time, times_fired)
	. = ..()

	// We very, VERY slowly generate saturation over time. This is purely to make sure the lil guys aren't softlocked.
	adjust_saturation(SATURATION_GENERATION_SPEED * delta_time)

	// We use saturation to fill substrate.
	// Each point of saturation consumed produces SUBSTRATE_CONVERSION_RATIO points of substrate.
	// Cap by: how much saturation we have, and how much substrate space is left (converted back to saturation units).
	if(saturation > 0 && substrate < max_substrate)
		var/substrate_space = max_substrate - substrate
		var/saturation_to_spend = min(saturation, substrate_space / SUBSTRATE_CONVERSION_RATIO, SUBSTRATE_CONVERSION_SPEED * delta_time)
		if(saturation_to_spend <= 0)
			return

		adjust_saturation(-saturation_to_spend)
		adjust_substrate(saturation_to_spend * SUBSTRATE_CONVERSION_RATIO)
