/datum/holoparasite_ability/lesser/babelfish
	name = "Babeltongue"
	desc = "The $theme gains bluespace telepathic abilities to interpret verbal dialogue, allowing it to understand and speak any language."
	ui_icon = "comment-dots"
	cost = 1

/datum/holoparasite_ability/lesser/babelfish/apply()
	..()
	owner.grant_all_languages(source = LANGUAGE_HOLOPARA)

/datum/holoparasite_ability/lesser/babelfish/remove()
	..()
	owner.remove_all_languages(LANGUAGE_HOLOPARA)
