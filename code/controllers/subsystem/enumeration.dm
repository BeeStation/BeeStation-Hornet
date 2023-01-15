/**
 * Subsystem that allows for performing operations over
 * enumerations that involve tick checking with no risk of freezing the MC
 * as a result of TICK_CHECK waking up before the MC can wake up.
 *
 * @PowerfulBacon
 * */
SUBSYSTEM_DEF(enumeration)
	name = "Enumeration"
	wait = 1
	flags = SS_NO_INIT | SS_TICKER

	/// Enumerators we are tick check enumerating over
	var/list/datum/enumerator/tick_enumerations = list()

/datum/controller/subsystem/enumeration/fire()
	MC_SPLIT_TICK_INIT(length(tick_enumerations))
	//No need to copy the list, so use indexing enumeration isntead
	//Go backwards to prevent concurrent modification issues
	for (var/i in length(tick_enumerations) to 1 step -1)
		var/datum/enumerator/enumerator = tick_enumerations[i]
		//Run over the enumerators while we are allowed
		var/enumerator_has_next = enumerator.has_next()
		while (enumerator_has_next)
			//Enumerate the current element (This doesn't do anything with the value, but may run side-effectful actions)
			enumerator.next()
			//Check the next element
			enumerator_has_next = enumerator.has_next()
			//Tick check, if necessary
			if (MC_TICK_CHECK)
				break
		//The enumeration has finished
		if (!enumerator_has_next)
			//Disgusting O(n) removal proc. Maybe we should use dictionaries, but this should be short enough that it will be quicker than dictionaries
			//anyway.
			tick_enumerations -= enumerator
		//Split the tick for the next run
		MC_SPLIT_TICK

/datum/controller/subsystem/enumeration/proc/tickcheck(datum/enumerator/enumerator)
	tick_enumerations += enumerator
