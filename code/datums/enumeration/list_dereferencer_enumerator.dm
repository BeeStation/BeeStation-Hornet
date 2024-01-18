/*
 * Performs unchecked list enumeration.
 * Not protected against concurrent modification.
 * Not protected against elements of the list being deleted from external sources.
 */
/datum/enumerator/list/deref

///Get the next element
/datum/enumerator/list/deref/next()
	// Dereference the previous value
	if (current_index > 0 && current_index <= length(reference_list))
		reference_list[current_index] = null
	current_index ++
	return current()

///Reset back to the start
/datum/enumerator/list/deref/reset()
	current_index = 0

///Get a list enumerator
// List derived types are not supported :(
/proc/get_dereferencing_enumerator(list/source)
	return new /datum/enumerator/list/deref(source)
