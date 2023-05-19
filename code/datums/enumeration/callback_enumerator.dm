/*
 * Class for performing basic enumeration.
 * Indexing starts at -1, so a new enumerator will call
 * next() before the first element is given.
 */
/datum/enumerator/callback
	///The callback that we are currently using
	var/datum/enumerator/enclosed
	///A weakreference to the value we got out (prevent current() calling side effects)
	var/datum/weakref/reference
	///For value types
	var/value_type = 0
	///The callback to execute
	var/datum/callback/callback

/datum/enumerator/callback/New(datum/enumerator/enclosed, datum/callback/callback)
	. = ..()
	src.enclosed = enclosed
	src.callback = callback

///Get the current method
///Returns null if there is no current element
/datum/enumerator/callback/current()
	return value_type || reference.resolve()

///Get the next element
///Returns the next element in the list and increments the enumerator.
///If the enumerator has finished, returns null.
/datum/enumerator/callback/next()
	var/result = enclosed.next()
	if (!result)
		return null
	//Perform callback operation
	result = callback.Invoke(result)
	if (isdatum(result))
		//Enclose in weakref to allow for GC
		reference = WEAKREF(result)
	else
		value_type = result
	return result

/datum/enumerator/callback/has_next()
	return enclosed.has_next()

///Reset back to the start (index -1)
/datum/enumerator/callback/reset()
	enclosed.reset()
