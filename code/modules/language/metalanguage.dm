/datum/language/metalanguage
	name = "Metalanguage"
	desc = "Metalanguage that everyone understands."
	flags = TONGUELESS_SPEECH | LANGUAGE_HIDE_ICON_IF_UNDERSTOOD | LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD__LINGUIST_ONLY | LANGUAGE_ALWAYS_SHOW_ICON_TO_GHOSTS
	key = "`"
	default_priority = -1 // language auto-update will not choose this
	icon_state = "omniomega"

/* Note:
 	This language is made to display runechat for telepathic chats. Everyone knows this language, but none of them will be possible to talk in this language.
	This is also used to animal mobs like dog barking, cat meowing, rat squeaking, instead they say those in Galactic Common

	This language is also a bit hardcoded because of its special usage.
*/

// this makes metalanguage is not understandable if they don't have the language for some reason
/datum/language/metalanguage/scramble(input)
	return Gibberish(stars(input)) // this will be simple enough to be a curse
