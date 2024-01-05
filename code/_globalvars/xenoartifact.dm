///Global names for science sellers
GLOBAL_LIST_INIT(xenoa_seller_names, world.file2list("strings/names/science_seller.txt"))
GLOBAL_LIST_INIT(xenoa_seller_dialogue, world.file2list("strings/science_dialogue.txt"))
GLOBAL_LIST_INIT(xenoa_artifact_names, world.file2list("strings/names/artifact_sentience.txt"))

///traits types, referenced for generation
GLOBAL_LIST(xenoa_activators)
GLOBAL_LIST(xenoa_minors)
GLOBAL_LIST(xenoa_majors)
GLOBAL_LIST(xenoa_malfunctions)
GLOBAL_LIST(xenoa_all_traits)

///Blacklist for traits
GLOBAL_LIST(xenoa_bluespace_blacklist)
GLOBAL_LIST(xenoa_plasma_blacklist)
GLOBAL_LIST(xenoa_uranium_blacklist)
GLOBAL_LIST(xenoa_bananium_blacklist)

///List of emotes for emote-trait
GLOBAL_LIST_INIT(xenoa_emote, list(/datum/emote/flip, /datum/emote/spin, /datum/emote/living/laugh, 
	/datum/emote/living/scream, /datum/emote/living/tremble, /datum/emote/living/whimper,
	/datum/emote/living/smile, /datum/emote/living/pout, /datum/emote/living/gag,
	/datum/emote/living/deathgasp, /datum/emote/living/dance, /datum/emote/living/blush))

///Fill globals
/proc/generate_xenoa_statics()
	GLOB.xenoa_seller_names -= ""
	GLOB.xenoa_seller_dialogue -= ""
	GLOB.xenoa_artifact_names -= ""

	GLOB.xenoa_activators = compile_artifact_weights(/datum/xenoartifact_trait/activator)
	GLOB.xenoa_minors = compile_artifact_weights(/datum/xenoartifact_trait/minor)
	GLOB.xenoa_majors = compile_artifact_weights(/datum/xenoartifact_trait/major)
	GLOB.xenoa_malfunctions = compile_artifact_weights(/datum/xenoartifact_trait/malfunction)
	GLOB.xenoa_all_traits = compile_artifact_weights(/datum/xenoartifact_trait)

	GLOB.xenoa_bluespace_blacklist = compile_artifact_blacklist(BLUESPACE_TRAIT)
	GLOB.xenoa_plasma_blacklist = compile_artifact_blacklist(PLASMA_TRAIT)
	GLOB.xenoa_uranium_blacklist = compile_artifact_blacklist(URANIUM_TRAIT)
	GLOB.xenoa_uranium_blacklist = compile_artifact_blacklist(BANANIUM_TRAIT)

/*
New content
*/

///Material weights, basically rarity
GLOBAL_LIST_INIT(xenoartifact_material_weights, list(XENOA_BLUESPACE = 10, XENOA_PLASMA = 5, XENOA_URANIUM = 3, XENOA_BANANIUM = 1))

///Trait priority list
GLOBAL_LIST_INIT(xenoartifact_trait_priorities, list(TRAIT_PRIORITY_ACTIVATOR, TRAIT_PRIORITY_MINOR, TRAIT_PRIORITY_MAJOR, TRAIT_PRIORITY_MALFUNCTION))
