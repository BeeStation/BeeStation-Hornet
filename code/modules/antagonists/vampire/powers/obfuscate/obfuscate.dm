/datum/discipline/obfuscate
	name = "Obfuscate"
	discipline_explanation = "Obfuscate is a Discipline that allows vampires to conceal themselves, deceive the mind of others, or make them ignore what the user does not want to be seen."
	icon_state = "obfuscate"

	// Lists of abilities granted per level
	level_1 = list(/datum/action/vampire/cloak)
	level_2 = list(/datum/action/vampire/cloak, /datum/action/vampire/targeted/trespass)
	level_3 = null
	level_4 = null
	level_5 = null
