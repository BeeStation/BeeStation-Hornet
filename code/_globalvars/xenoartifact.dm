///Global names for science sellers
GLOBAL_LIST_INIT(xenoa_seller_names, world.file2list("strings/names/science_seller.txt") + "")
GLOBAL_LIST_INIT(xenoa_seller_dialogue, world.file2list("strings/science_dialogue.txt") + "")
GLOBAL_LIST_INIT(xenoa_artifact_names, world.file2list("strings/names/artifact_sentience.txt") + "")

///traits types, referenced for generation
GLOBAL_LIST(xenoa_activators)
GLOBAL_LIST(xenoa_minors)
GLOBAL_LIST(xenoa_majors)
GLOBAL_LIST(xenoa_malfs)
GLOBAL_LIST(xenoa_all_traits)

///Blacklist for traits
GLOBAL_LIST(xenoa_bluespace_blacklist)
GLOBAL_LIST(xenoa_plasma_blacklist)
GLOBAL_LIST(xenoa_uranium_blacklist)

///Fill globals
/proc/generate_xenoa_statics()
	GLOB.xenoa_seller_names -= ""
	GLOB.xenoa_seller_dialogue -= ""
	GLOB.xenoa_artifact_names -= ""

	GLOB.xenoa_activators = compile_artifact_weights(/datum/xenoartifact_trait/activator)
	GLOB.xenoa_minors = compile_artifact_weights(/datum/xenoartifact_trait/minor)
	GLOB.xenoa_majors = compile_artifact_weights(/datum/xenoartifact_trait/major)
	GLOB.xenoa_malfs = compile_artifact_weights(/datum/xenoartifact_trait/malfunction)
	GLOB.xenoa_all_traits = compile_artifact_weights(/datum/xenoartifact_trait)

	GLOB.xenoa_bluespace_blacklist = compile_artifact_blacklist(BLUESPACE_TRAIT)
	GLOB.xenoa_plasma_blacklist = compile_artifact_blacklist(PLASMA_TRAIT)
	GLOB.xenoa_uranium_blacklist = compile_artifact_blacklist(URANIUM_TRAIT)
