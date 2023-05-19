/datum/language/metalanguage
	name = "Metalanguage"
	desc = "Metalanguage that everyone understands."
	flags = TONGUELESS_SPEECH | LANGUAGE_HIDE_ICON_IF_UNDERSTOOD | LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD__LINGUIST_ONLY | LANGUAGE_ALWAYS_SHOW_ICON_TO_GHOSTS
	key = "`"
	sentence_chance = -1 // 0% has a chance to occur
	space_chance = -1
	default_priority = 1
	icon_state = "omniomega"

// this language is made to display runechat for telepathic chats. Everyone knows this language, but none of them will be possible to talk in this language.
