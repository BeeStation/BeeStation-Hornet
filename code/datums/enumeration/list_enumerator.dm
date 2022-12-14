/*
 * Performs unchecked list enumeration.
 * Not protected against concurrent modification.
 */
/datum/enumerator/list
	///The list we are enumerating over
	var/list/reference_list
	///The current index
	var/current_index = 0

/datum/enumerator/list/New(list/source)
	. = ..()
	reference_list = source

///Get the current method
/datum/enumerator/list/current()
	if (current_index < 1 || current_index > length(reference_list))
		return null
	return reference_list[current_index]

/datum/enumerator/list/has_next()
	return (current_index + 1) <= length(reference_list)

///Get the next element
/datum/enumerator/list/next()
	current_index ++
	return current()

///Reset back to the start
/datum/enumerator/list/reset()
	current_index = 0

///Get a list enumerator
// List derived types are not supported :(
/proc/get_list_enumerator(list/source)
	return new /datum/enumerator/list(source)
