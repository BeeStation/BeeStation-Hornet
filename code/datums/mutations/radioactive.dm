/datum/mutation/radioactive
	name = "Radioactivity"
	desc = "A volatile mutation that causes the host to sent out deadly beta radiation. This affects both the hosts and their surroundings."
	quality = NEGATIVE
	instability = 5
	difficulty = 8
	power_coeff = 1

/datum/mutation/radioactive/New(class_ = MUT_OTHER, timer, datum/mutation/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "radiation"))

/datum/mutation/radioactive/on_life(delta_time, times_fired)
	radiation_pulse(owner, 10 * GET_MUTATION_POWER(src) * delta_time)

/datum/mutation/radioactive/get_visual_indicator()
	return visual_indicators[type][1]
