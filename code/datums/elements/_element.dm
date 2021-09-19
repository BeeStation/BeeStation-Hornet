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
		/** The override = TRUE here is to suppress runtimes happening because of the blood decal element
		  * being applied multiple times to a same thing every time there is some bloody attacks,
		  * which happens due to ludicrous use of check_blood() in forensics.dm,
		  * and how elements system is design and coded; there isn't exactly a not-hacky
		  * way to determine whether a datum has this particular element before adding it...
		  */
		RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/Detach, override = TRUE)

/datum/element/proc/Detach(datum/source, force)
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
	ele.Detach(src)
