/// Proc that handles adding multiple traits to a target via a list. Must have a common source and target.
/datum/proc/add_traits(list/list_of_traits, source)
	for(var/trait in list_of_traits)
		ADD_TRAIT(src, trait, source)

/// Proc that handles removing multiple traits from a target via a list. Must have a common source and target.
/datum/proc/remove_traits(list/list_of_traits, source)
	for(var/trait in list_of_traits)
		REMOVE_TRAIT(src, trait, source)
