/datum/component/magnetic_catch
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_exited),
	)

/datum/component/magnetic_catch/Initialize()
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examine))
	if(ismovable(parent))
		AddElement(/datum/element/connect_loc, parent, loc_connections)
		for(var/i in get_turf(parent))
			if(i == parent)
				continue
			RegisterSignal(i, COMSIG_MOVABLE_PRE_THROW, PROC_REF(throw_react))
	else
		RegisterSignal(parent, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
		RegisterSignal(parent, COMSIG_ATOM_EXITED, PROC_REF(on_exited))
		for(var/i in parent)
			RegisterSignal(i, COMSIG_MOVABLE_PRE_THROW, PROC_REF(throw_react))

/datum/component/magnetic_catch/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += "It has been installed with inertia dampening to prevent coffee spills."

/datum/component/magnetic_catch/proc/on_entered(datum/source, atom/movable/thing, atom/oldloc)
	SIGNAL_HANDLER

	RegisterSignal(thing, COMSIG_MOVABLE_PRE_THROW, PROC_REF(throw_react), TRUE)

/datum/component/magnetic_catch/proc/on_exited(datum/source, atom/movable/thing, atom/newloc)
	SIGNAL_HANDLER

	UnregisterSignal(thing, COMSIG_MOVABLE_PRE_THROW)

/datum/component/magnetic_catch/proc/throw_react(datum/source, list/arguments)
	SIGNAL_HANDLER

	return COMPONENT_CANCEL_THROW

/datum/component/magnetic_catch/UnregisterFromParent()
	. = ..()
	RemoveElement(/datum/element/connect_loc, parent, loc_connections)
