/*
	You look around.
	There is nothing but naught about you.
	You've come to the end of the world.
	You get a feeling that you really shouldn't be here.
	Ever.
	But with all ends come beginnings.
	As you turn to leave, you spot it out of the corner of your eye.
	Your eye widen in wonder as you look upon the the legendary treasure.
	After all these years of pouring through shitcode
	your endevours have brought you to...
*/

/**
 * THE GENESIS CALL
 *
 * THE VERY FIRST LINE OF DM CODE TO EXECUTE
 * Ong this must be done after !!!EVERYTHING!!! else
 * NO IFS ANDS OR BUTS
 * it's a hack, not an example of any sort, and DEFINITELY should NOT be emulated
 * IT JUST HAS TO BE LAST!!!!!!
 * If you want to do something in the initialization pipeline
 * FIRST RTFM IN /code/game/world.dm
 * AND THEN NEVER RETURN TO THIS PLACE
 *
 *
 *
 * If you're still here, here's an explanation:
 * BYOND loves to tell you about its loving spouse /global
 * But it's actually having a sexy an affair with /static
 * Specifically statics in procs
 * Priority is given to these lines of code in REVERSE order of declaration in the .dme
 * Which is why this file has a funky name
 * So this is what we use to call world.Genesis()
 * It's a nameless, no-op function, because it does absolutely nothing
 * It exists to hold a static var which is initialized to null
 * It's on /world to hide it from reflection
 * Painful right? Good, now you share my suffering
 * Please lock the door on your way out
 */
/world/proc/_()
	var/static/_ = world.Genesis()
