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
///All traits indexed by name
GLOBAL_LIST(xenoa_all_traits_keyed)

///Blacklist for traits
GLOBAL_LIST(xenoa_bluespace_traits)
GLOBAL_LIST(xenoa_plasma_traits)
GLOBAL_LIST(xenoa_uranium_traits)
GLOBAL_LIST(xenoa_bananium_traits)
GLOBAL_LIST(xenoa_pearl_traits)

///Fill globals
/proc/generate_xenoa_statics()
	if(length(GLOB.xenoa_all_traits))
		return

	//Bruh
	GLOB.xenoa_seller_names -= ""
	GLOB.xenoa_seller_dialogue -= ""
	GLOB.xenoa_artifact_names -= ""

	//List of weights based on trait type
	GLOB.xenoa_activators = compile_artifact_weights(/datum/xenoartifact_trait/activator)
	GLOB.xenoa_minors = compile_artifact_weights(/datum/xenoartifact_trait/minor)
	GLOB.xenoa_majors = compile_artifact_weights(/datum/xenoartifact_trait/major)
	GLOB.xenoa_malfunctions = compile_artifact_weights(/datum/xenoartifact_trait/malfunction)
	GLOB.xenoa_all_traits = compile_artifact_weights(/datum/xenoartifact_trait)
	GLOB.xenoa_all_traits_keyed = compile_artifact_weights(/datum/xenoartifact_trait, TRUE)

	//Traits divided by flavor
	GLOB.xenoa_bluespace_traits = compile_artifact_whitelist(/datum/xenoartifact_material/bluespace)
	GLOB.xenoa_plasma_traits = compile_artifact_whitelist(/datum/xenoartifact_material/plasma)
	GLOB.xenoa_uranium_traits = compile_artifact_whitelist(/datum/xenoartifact_material/uranium)
	GLOB.xenoa_bananium_traits = compile_artifact_whitelist(/datum/xenoartifact_material/bananium)
	GLOB.xenoa_pearl_traits = compile_artifact_whitelist(/datum/xenoartifact_material/pearl)

///Material weights, basically rarity
GLOBAL_LIST_INIT(xenoartifact_material_weights, list(XENOA_BLUESPACE = 10, XENOA_PLASMA = 8, XENOA_URANIUM = 5, XENOA_BANANIUM = 1))

///Trait priority list - The order is important and it represents priotity
GLOBAL_LIST_INIT(xenoartifact_trait_priorities, list(TRAIT_PRIORITY_ACTIVATOR, TRAIT_PRIORITY_MINOR, TRAIT_PRIORITY_MALFUNCTION, TRAIT_PRIORITY_MAJOR))

///List of research materials we've bought and cargo needs to ship to us
GLOBAL_LIST_INIT(needs_shipping_science_materials, list())
