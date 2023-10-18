
///Kinda wish we had static classes here

/**
 * Allows performing some operation over each element of another enumerator.
 * At every step of the enumeration, the callback will be called with the input as the result
 * and then the result of that callback will be returned instead of the initial value passed
 * from the original enumerator.
 * Returns an enumerator.
 */
/datum/enumerator/proc/foreach(datum/callback/callback)
	return new /datum/enumerator/callback(src, callback)

//These do the same thing
/datum/enumerator/proc/select(datum/callback/callback)
	return new /datum/enumerator/callback(src, callback)
