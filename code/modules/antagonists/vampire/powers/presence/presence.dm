/datum/discipline/presence
	name = "Presence"
	discipline_explanation = "Presence is the Discipline of supernatural presence and subtle manipulation which allows Kindred to dominate the attention of those around them."
	icon_state = "presence"
	level_1 = list(/datum/action/cooldown/vampire/targeted/entrance)
	level_2 = list(/datum/action/cooldown/vampire/targeted/entrance, /datum/action/cooldown/vampire/targeted/summon)
	level_3 = list(/datum/action/cooldown/vampire/awe, /datum/action/cooldown/vampire/targeted/entrance, /datum/action/cooldown/vampire/targeted/summon)
	level_4 = list(/datum/action/cooldown/vampire/awe, /datum/action/cooldown/vampire/targeted/entrance, /datum/action/cooldown/vampire/targeted/summon, /datum/action/cooldown/vampire/force_of_personality)
	level_5 = null
