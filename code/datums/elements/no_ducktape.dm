/// element for things that should not be fixable using duct tape
/datum/element/no_ducttape
	element_flags = ELEMENT_DETACH
	/// the message that shows in the balloon alert
	var/error_message = "Only structures that can be reassembled can be repaired."

/datum/element/no_ducttape/Attach(datum/target)
    . = ..()
    var/atom/atom = target
    if (!atom?.uses_integrity)
        return ELEMENT_INCOMPATIBLE
    
    RegisterSignal(target, COMSIG_ATOM_ATTACKBY_SECONDARY, PROC_REF(cant_fix))

/datum/element/no_ducttape/Detach(datum/source)
    . = ..()
    UnregisterSignal(source, COMSIG_ATOM_ATTACKBY_SECONDARY)
    
/datum/element/no_ducttape/proc/cant_fix(obj/item/weapon, obj/item/tape)
    SIGNAL_HANDLER

    tape.balloon_alert(usr, error_message)
    return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN

// guns in general
/datum/element/no_ducttape/gun
	error_message = "Using tape would make this too flimsy to shoot!"

// clock cult structures, they should use their power through fabricators
// the ark should never be repairable
/datum/element/no_ducttape/clock_cult
	error_message = "The tape would get caught in the gears if you tried to fix this!"
