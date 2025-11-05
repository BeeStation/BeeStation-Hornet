/datum/discipline/caitiff
	name = "Caitiff Mixblood"
	discipline_explanation = "The thinned blood of a caitiff. Though still potent enough to scrabble together a modicum of undefined powers."
	icon_state = "serpentis" // Ankh, so close enough

	// Lists of abilities granted per level
	level_1 = list(/datum/action/vampire/targeted/brawn)
	level_2 = list(/datum/action/vampire/fortitude, /datum/action/vampire/targeted/brawn)
	level_3 = list(/datum/action/vampire/targeted/mesmerize, /datum/action/vampire/fortitude, /datum/action/vampire/targeted/brawn)
	level_4 = null
	level_5 = null
