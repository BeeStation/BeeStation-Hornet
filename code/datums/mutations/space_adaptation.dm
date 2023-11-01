//Cold Resistance gives your entire body an orange halo, and makes you immune to the effects of vacuum and cold.
/datum/mutation/space_adaptation
	name = "Space Adaptation"
	desc = "A strange mutation that renders the host's skin, muscuoskeletal system and sensory organs immune to the vacuum of space. The mutation is ineffective toward lung tissue, which will remain vulnerable without an air tank."
	quality = POSITIVE
	difficulty = 16
	instability = 30
	traits = list(TRAIT_RESISTCOLD, TRAIT_RESISTLOWPRESSURE)

/datum/mutation/space_adaptation/New(class_ = MUT_OTHER, timer, datum/mutation/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "fire"))

/datum/mutation/space_adaptation/get_visual_indicator()
	return visual_indicators[type][1]
