/mob/living/carbon/alien/Life(delta_time = SSMOBS_DT, times_fired)
	findQueen()
	return ..()

/mob/living/carbon/alien/check_breath(datum/gas_mixture/breath)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return

	var/total_moles = breath?.total_moles()
	if(!total_moles)
		//Aliens breathe in vaccuum
		return 0

	var/toxins_used = 0
	var/tox_detect_threshold = 0.02
	var/breath_pressure = (total_moles * R_IDEAL_GAS_EQUATION*breath.return_temperature())/BREATH_VOLUME
	var/list/cached_moles = breath.moles

	//Partial pressure of the toxins in our breath
	var/toxins_pp = (cached_moles[/datum/gas/plasma] / total_moles) * breath_pressure

	if(toxins_pp > tox_detect_threshold) // Detect toxins in air
		adjustPlasma(cached_moles[/datum/gas/plasma] * 250)
		throw_alert("alien_tox", /atom/movable/screen/alert/alien_tox)

		toxins_used = cached_moles[/datum/gas/plasma]
	else
		clear_alert("alien_tox")

	//Breathe in toxins and out oxygen
	breath.adjust_multiple_gases(list(
		/datum/gas/plasma = -toxins_used,
		/datum/gas/oxygen = toxins_used,
	))

	//BREATH TEMPERATURE
	handle_breath_temperature(breath)
