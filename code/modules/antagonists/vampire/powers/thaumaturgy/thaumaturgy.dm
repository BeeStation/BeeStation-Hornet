/datum/discipline/thaumaturgy
	name = "Thaumaturgy"
	discipline_explanation = "Thaumaturgy is the closely guarded form of blood magic practiced by the vampiric clan Tremere."
	icon_state = "thaumaturgy"

	// Lists of abilities granted per level
	level_1 = list(/datum/action/vampire/targeted/bloodboil)
	level_2 = list(/datum/action/vampire/targeted/bloodboil/two, /datum/action/vampire/targeted/blooddrain)
	level_3 = list(/datum/action/vampire/targeted/bloodboil/three, /datum/action/vampire/targeted/blooddrain, /datum/action/vampire/bloodshield)
	level_4 = list(/datum/action/vampire/targeted/bloodboil/four, /datum/action/vampire/targeted/blooddrain, /datum/action/vampire/bloodshield, /datum/action/vampire/targeted/bloodbolt)
//	level_5 = null
