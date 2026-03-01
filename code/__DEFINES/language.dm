///Currently not used?
#define NO_STUTTER 1
///Language will be speakable even if you don't have a tongue - although you'll murmur. non-carbon that doesn't have a tongue will not murmur.
#define TONGUELESS_SPEECH (1<<1)

// --- NOTE:
// 		language icon is basically hidden if not understood in the current language code. It was originally visible to everyone before, but they no longer know which language you're talking even.

// HIDE_ICON flags: icons will be usually visible because you know, but these flags will not show the icon to you.
///Language icon will be hidden if you understand it (i.e. Galactic Common)
#define LANGUAGE_HIDE_ICON_IF_UNDERSTOOD (1<<2)
///Language icon will be hidden even if you have the linguist trait. remove __LINGUIST_ONLY part if it's no longer specific. (i.e. Aphasia, Codepeak)
#define LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD__LINGUIST_ONLY (1<<3)
///Language icon will always be hidden to yourself. This is necessary to Aphasia, because you shouldn't diagnose yourself. (i.e. Aphasia)
#define LANGUAGE_HIDE_ICON_TO_YOURSELF (1<<4)

// ALWAYS_SHOW_ICON flags
///Language icon will always be visible if you don't understand it. typically, should go with LANGUAGE_HIDE_ICON_IF_UNDERSTOOD define (i.e. Galactic Common)
#define LANGUAGE_ALWAYS_SHOW_ICON_IF_NOT_UNDERSTOOD (1<<5)
///Language icon will always be visible to ghosts even if it is set hidden to people. This is because people shouldn't know they talk in a specific language, meanwhile ghosts are supposed to know. (i.e. Metalanguage)
#define LANGUAGE_ALWAYS_SHOW_ICON_TO_GHOSTS (1<<6)


// LANGUAGE SOURCE DEFINES
/// For use in full removal only.
#define LANGUAGE_ALL "all"

// Generic language sources.
/// Language is linked to the movable directly.
#define LANGUAGE_ATOM "atom"
/// Language is linked to the mob's mind.
/// If a mind transfer happens, language follows.
#define LANGUAGE_MIND "mind"
/// Language is linked to the mob's species.
/// If a species change happens, language goes away.
/// If applied to a non-human (no species) atom, this is effectively the same as [LANGUAGE_ATOM].
#define LANGUAGE_SPECIES "species"

// More specific language sources.
// Only ever goes away when dismissed directly.
#define LANGUAGE_FRIEND	"friend"
#define LANGUAGE_ABSORB	"absorb"
#define LANGUAGE_APHASIA "aphasia"
#define LANGUAGE_CULTIST "cultist"
#define LANGUAGE_CURATOR "curator"
#define LANGUAGE_REVENANT "revenant"
#define LANGUAGE_GLAND "gland"
#define LANGUAGE_HAT "hat"
#define LANGUAGE_HIGH "high"
#define LANGUAGE_MALF "malf"
#define LANGUAGE_PIRATE "pirate"
#define LANGUAGE_MASTER	"master"
#define LANGUAGE_SOFTWARE "software"
#define LANGUAGE_STONER	"stoner"
#define LANGUAGE_DRUGGY	"druggy"
#define LANGUAGE_VOICECHANGE "voicechange"
#define LANGUAGE_REAGENT "reagent"
#define LANGUAGE_MULTILINGUAL "multilingual"
#define LANGUAGE_EMP "emp"
#define LANGUAGE_HOLOPARA "holoparasite"
#define LANGUAGE_BABEL "babel"
#define LANGUAGE_VAMPIRE "vampire"
#define LANGUAGE_CHANGELING "changeling"

// Language flags. Used in granting and removing languages.
/// This language can be spoken.
#define SPOKEN_LANGUAGE (1<<0)
/// This language can be understood.
#define UNDERSTOOD_LANGUAGE (1<<1)

// Languages available from Multilingual
GLOBAL_LIST_INIT(multilingual_language_list, typecacheof(list(
	/datum/language/apidite,
	/datum/language/beachbum,
	/datum/language/buzzwords,
	/datum/language/calcic,
	/datum/language/draconic,
	/datum/language/moffic,
	/datum/language/monkey,
	/datum/language/piratespeak,
	/datum/language/shadowtongue,
	/datum/language/slime,
	/datum/language/sylvan,
	/datum/language/terrum,
	/datum/language/uncommon,
	/datum/language/voltaic,
	/datum/language/vampiric,
)))
