/**
 * This component will ensure that move calls from parent locs
 * will be relayed to the parent atom.
 */
/datum/component/moved_relay
	//List of ordered parents
	//Index 1: parent
	//Index 2: Parent's parent
	//etc.
	var/list/atom/ordered_parents = list()

/datum/component/moved_relay/Initialize(...)
	. = ..()
	//Start tracking from the parent
	//We will relay the parents move to itself for convenience
	register_parent(parent)

/datum/component/moved_relay/proc/register_parent(atom/A)
	RegisterSignal(A, COMSIG_PARENT_QDELETING, .proc/parent_deleted)
	RegisterSignal(A, COMSIG_MOVABLE_MOVED, .proc/parent_moved)
	ordered_parents += A
	//Recursively register parents
	if(!isturf(A.loc))
		register_parent(A.loc)

/datum/component/moved_relay/proc/parent_moved(atom/source, atom/oldLoc)
	//If old location wasn't a turf, then it was tracked by us
	//Stop tracking old atoms
	if(!isturf(oldLoc))
		unregister_parent(oldLoc)
	//Relay the movement signal to the parent
	SEND_SIGNAL(parent, COMSIG_PARENT_MOVED_RELAY, source, oldLoc)
	//Start tarcking new ones
	if(!isturf(source.loc))
		register_parent(source.loc)

/datum/component/moved_relay/proc/parent_deleted(datum/source, force)
	unregister_parent(source)

/datum/component/moved_relay/proc/unregister_parent(atom/A)
	UnregisterSignal(A, COMSIG_PARENT_QDELETING)
	UnregisterSignal(A, COMSIG_MOVABLE_MOVED)
	ordered_parents -= A
	//Recursively unregister parents
	if(!isturf(A.loc))
		unregister_parent(A.loc)
