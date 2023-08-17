/datum/holoparasite_ability/lesser/vision
	name = "Thermal Vision"
	desc = "The $theme gains thermal vision, allowing it to see living beings through walls."
	ui_icon = "fire"
	cost = 1
	traits = list(TRAIT_THERMAL_VISION)

/datum/holoparasite_ability/lesser/vision/apply()
	. = ..()
	owner.update_sight()

/datum/holoparasite_ability/lesser/vision/remove()
	. = ..()
	owner.update_sight()
