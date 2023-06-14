/*
 * Class for performing basic enumeration.
 * Indexing starts at 0 (element before start), so a new enumerator will call
 * next() before the first element is given.
 */
/datum/enumerator

///Get the current method
///Returns null if there is no current element
/datum/enumerator/proc/current()

///Get the next element
///Returns the next element in the list and increments the enumerator.
///If the enumerator moves out of bounds, returns null
/datum/enumerator/proc/next()

///Returns true if there is another element in the enumerator
/datum/enumerator/proc/has_next()

///Reset back to the start (index 0)
/datum/enumerator/proc/reset()
