/**
 * Enumerator with overhead to handle hard-dels.
 * This will automatically add signals to the things in the list to dereference them upon
 * deletion.
 * Note that this will make nulls in the list, you are still responsible for handling nulls.
 */
/datum/enumerator/list/safe

/datum/enumerator/list/safe/New(list/source)
	. = ..()
	reference_list = source
	for (var/datum/element in reference_list)
		RegisterSignal(element, COMSIG_PARENT_PREQDELETED, PROC_REF(element_deleted))

// Assuming this won't happen super frequently
/datum/enumerator/list/safe/proc/element_deleted(datum/source)
	var/located_index = reference_list.Find(source)
	if (located_index != -1)
		reference_list[located_index] = null

///Get a list enumerator
// List derived types are not supported :(
/proc/get_safe_enumerator(list/source)
	return new /datum/enumerator/list/safe(source)
