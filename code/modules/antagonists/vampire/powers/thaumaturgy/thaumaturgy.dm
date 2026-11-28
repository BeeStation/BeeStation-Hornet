/datum/discipline/thaumaturgy
	name = "Thaumaturgy"
	discipline_explanation = "Thaumaturgy is the closely guarded form of blood magic practiced by the vampiric clan Tremere."
	icon_state = "thaumaturgy"

	// Lists of abilities granted per level
	level_1 = list(/datum/action/cooldown/vampire/targeted/bloodboil)
	level_2 = list(/datum/action/cooldown/vampire/targeted/bloodboil/two, /datum/action/cooldown/vampire/targeted/blooddrain)
	level_3 = list(/datum/action/cooldown/vampire/targeted/bloodboil/three, /datum/action/cooldown/vampire/targeted/blooddrain, /datum/action/cooldown/vampire/bloodshield)
	level_4 = list(/datum/action/cooldown/vampire/targeted/bloodboil/four, /datum/action/cooldown/vampire/targeted/blooddrain, /datum/action/cooldown/vampire/bloodshield, /datum/action/cooldown/vampire/targeted/bloodbolt)
//	level_5 = null
