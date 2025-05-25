/*
	Sometimes you need to anchor one thing to another, and adding it to vis contents just ain't right

	This is used for stuff like species height maps, which break the context menu when vis contents is used
*/

/datum/component/anchor
	///Do the copy their position
	var/copy_position = TRUE
	///Do we copy the target's direction
	var/copy_direction = TRUE

/datum/component/anchor/Initialize(atom/movable/anchor_target)
	. = ..()
	if(!ismovable(parent) || !ismovable(anchor_target))
		return
	//Setup signals to catch movement and direction stuff
	RegisterSignal(anchor_target, COMSIG_MOVABLE_MOVED, PROC_REF(catch_move))
	RegisterSignal(anchor_target, COMSIG_ATOM_DIR_CHANGE, PROC_REF(catch_dir))
	//Initial respects
	catch_move(anchor_target)
	catch_dir(anchor_target, 0, anchor_target.dir)

/datum/component/anchor/proc/catch_move(datum/source)
	SIGNAL_HANDLER

	if(!copy_position)
		return
	var/atom/movable/movable_parent = parent
	movable_parent.forceMove(get_turf(source))

/datum/component/anchor/proc/catch_dir(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if(!copy_direction)
		return
	var/atom/movable/movable_parent = parent
	movable_parent.dir = new_dir
