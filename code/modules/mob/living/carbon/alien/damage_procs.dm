
/mob/living/carbon/alien/getToxLoss()
	return FALSE

/mob/living/carbon/alien/adjustToxLoss(amount, forced = FALSE) //alien immune to tox damage
	return FALSE

//aliens are immune to stamina damage.
/mob/living/carbon/alien/adjustStaminaLoss(amount, forced = FALSE)
	return FALSE

/mob/living/carbon/alien/setStaminaLoss(amount)
	return FALSE
