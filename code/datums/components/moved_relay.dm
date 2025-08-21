/**
 * This component will ensure that move calls from parent locs
 * will be relayed to the parent atom.
 * This means that something inside of another object can
 * still know when that other object moves.
 */
/datum/component/moved_relay
	dupe_mode = COMPONENT_DUPE_SELECTIVE
	/// How many move relays were added to this object?
	var/depth = 1
	//List of ordered parents
	//Index 1: parent
	//Index 2: Parent's parent
	//etc.
	var/list/atom/ordered_parents = list()

/datum/component/moved_relay/CheckDupeComponent(datum/component/C, ...)
	depth ++
	return TRUE

/datum/component/moved_relay/RegisterWithParent()
	var/atom/A = parent
	//Start tracking from the parent
	//We will relay the parents move to itself for convenience
	//if the super parent gets deleted, everything dies
	RegisterSignal(A, COMSIG_MOVABLE_MOVED, PROC_REF(parent_moved))
	ordered_parents += A
	//Recursively register parents
	if(A.loc && !isturf(A.loc))
		register_parent(A.loc)
	return ..()

/datum/component/moved_relay/Destroy(force, silent)
	for(var/atom/A as() in ordered_parents)
		UnregisterSignal(A, COMSIG_QDELETING)
		UnregisterSignal(A, COMSIG_MOVABLE_MOVED)
	ordered_parents = null
	return ..()

/datum/component/moved_relay/UnregisterFromParent()
	if (ordered_parents)
		for(var/atom/A as() in ordered_parents)
			UnregisterSignal(A, COMSIG_QDELETING)
			UnregisterSignal(A, COMSIG_MOVABLE_MOVED)
		ordered_parents.Cut()
	return ..()

/datum/component/moved_relay/proc/register_parent(atom/A)
	RegisterSignal(A, COMSIG_QDELETING, PROC_REF(parent_deleted))
	RegisterSignal(A, COMSIG_MOVABLE_MOVED, PROC_REF(parent_moved))
	ordered_parents += A
	//Recursively register parents
	if(A.loc && !isturf(A.loc))
		register_parent(A.loc)

/datum/component/moved_relay/proc/parent_moved(atom/source, atom/oldLoc)
	SIGNAL_HANDLER
	//If old location wasn't a turf, then it was tracked by us
	//Stop tracking old atoms
	if(oldLoc && !isturf(oldLoc))
		unregister_parent(oldLoc)
	//Relay the movement signal to the parent
	SEND_SIGNAL(parent, COMSIG_PARENT_MOVED_RELAY, source, oldLoc)
	//Start tarcking new ones
	if(source.loc && !isturf(source.loc))
		register_parent(source.loc)

/datum/component/moved_relay/proc/parent_deleted(datum/source, force)
	SIGNAL_HANDLER
	unregister_parent(source)

/datum/component/moved_relay/proc/unregister_parent(atom/A)
	UnregisterSignal(A, COMSIG_QDELETING)
	UnregisterSignal(A, COMSIG_MOVABLE_MOVED)
	var/position = ordered_parents.Find(A)
	if (!position)
		return
	ordered_parents -= A
	if (position >= length(ordered_parents))
		return
	var/atom/next = ordered_parents[position + 1]
	//Recursively unregister parents
	if(!isturf(next))
		unregister_parent(next)
