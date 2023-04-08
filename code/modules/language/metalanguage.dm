/datum/language/metalanguage
	name = "Metalanguage"
	desc = "Metalanguage that everyone understands."
	flags = TONGUELESS_SPEECH | LANGUAGE_HIDE_ICON_IF_YOU_UNDERSTAND | LANGUAGE_HIDE_ICON_IF_YOU_SHOULD_NOT_RECOGNISE_WITH_LINGUIST_TRAIT | LANGUAGE_ALWAYS_SHOW_ICON_TO_GHOSTS
	key = "`"
	sentence_chance = 0
	space_chance = 0
	default_priority = 1
	icon_state = "omniomega"

// this language is made to display runechat for telepathic chats. Everyone knows this language, but none of them will be possible to talk in this language.
