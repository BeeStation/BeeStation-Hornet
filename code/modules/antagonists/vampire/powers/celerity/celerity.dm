/datum/discipline/celerity
	name = "Celerity"
	discipline_explanation = "Celerity is a Discipline that grants vampires supernatural quickness and reflexes."
	icon_state = "celerity"

	// Lists of abilities granted per level
	level_1 = list(/datum/action/vampire/targeted/haste)
	level_2 = list(/datum/action/vampire/targeted/haste/two)
	level_3 = list(/datum/action/vampire/targeted/haste/three)
	level_4 = list(/datum/action/vampire/targeted/haste/three, /datum/action/vampire/exactitude)
	level_5 = null
