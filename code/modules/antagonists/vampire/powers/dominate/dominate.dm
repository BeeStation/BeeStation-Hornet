/datum/discipline/dominate
	name = "Dominate"
	discipline_explanation = "Dominate is a Discipline that overwhelms another person's mind with the vampire's will, forcing victims to think or act according to the vampire's decree."
	icon_state = "dominate"

	// Base only has mez, ventrue get command earlier and can upgrade it
	level_1 = list(/datum/action/vampire/targeted/mesmerize)
	level_2 = list(/datum/action/vampire/targeted/mesmerize/two)
	level_3 = list(/datum/action/vampire/targeted/mesmerize/three)
	level_4 = list(/datum/action/vampire/targeted/mesmerize/four, /datum/action/vampire/targeted/command)
	level_5 = null

/datum/discipline/dominate/ventrue
	level_3 = list(/datum/action/vampire/targeted/mesmerize/three, /datum/action/vampire/targeted/command)
	level_4 = list(/datum/action/vampire/targeted/mesmerize/four, /datum/action/vampire/targeted/command/two)
