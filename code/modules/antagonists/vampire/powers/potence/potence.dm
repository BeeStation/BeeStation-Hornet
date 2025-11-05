/datum/discipline/potence
	name = "Potence"
	discipline_explanation = "Potence is the Discipline that endows vampires with physical vigor and preternatural strength.\n\
		Vampires with the Potence Discipline possess physical prowess beyond mortal bounds. "
	icon_state = "presence"

	// Lists of abilities granted per level
	level_1 = list(/datum/action/vampire/targeted/brawn)
	level_2 = list(/datum/action/vampire/targeted/brawn, /datum/action/vampire/targeted/lunge)
	level_3 = null
	level_4 = null
	level_5 = null

/datum/discipline/potence/brujah
	level_3 = list(/datum/action/vampire/targeted/brawn/brash, /datum/action/vampire/targeted/lunge)
