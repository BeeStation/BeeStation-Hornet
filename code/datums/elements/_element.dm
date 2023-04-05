/datum/element
	var/element_flags = NONE
	/**
	  * The index of the first attach argument to consider for duplicate elements
	  * Is only used when flags contains ELEMENT_BESPOKE
	  * This is infinity so you must explicitly set this
	  */
	var/id_arg_index = INFINITY

/datum/element/proc/Attach(datum/target)
	if(type == /datum/element)
		return ELEMENT_INCOMPATIBLE
	SEND_SIGNAL(target, COMSIG_ELEMENT_ATTACH, src)
	if(element_flags & ELEMENT_DETACH)
		RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(OnTargetDelete), override = TRUE)

/datum/element/proc/OnTargetDelete(datum/source, force)
	SIGNAL_HANDLER
	Detach(source)

/// Deactivates the functionality defines by the element on the given datum
/datum/element/proc/Detach(datum/source, ...)
	SIGNAL_HANDLER

	SEND_SIGNAL(source, COMSIG_ELEMENT_DETACH, src)
	SHOULD_CALL_PARENT(TRUE)
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)

/datum/element/Destroy(force)
	if(!force)
		return QDEL_HINT_LETMELIVE
	SSdcs.elements_by_type -= type
	return ..()

//DATUM PROCS

/// Finds the singleton for the element type given and attaches it to src
/datum/proc/_AddElement(list/arguments)
	if(QDELING(src))
		CRASH("We just tried to add an element to a qdeleted datum, something is fucked")
	var/datum/element/ele = SSdcs.GetElement(arguments)
	arguments[1] = src
	if(ele.Attach(arglist(arguments)) == ELEMENT_INCOMPATIBLE)
		CRASH("Incompatible [arguments[1]] assigned to a [type]! args: [json_encode(args)]")

/**
  * Finds the singleton for the element type given and detaches it from src
  * You only need additional arguments beyond the type if you're using ELEMENT_BESPOKE
  */
/datum/proc/_RemoveElement(list/arguments)
	var/datum/element/ele = SSdcs.GetElement(arguments)
	if(ele.element_flags & ELEMENT_COMPLEX_DETACH)
		arguments[1] = src
		ele.Detach(arglist(arguments))
	else
		ele.Detach(src)
