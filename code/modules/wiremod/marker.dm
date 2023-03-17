/obj/item/multitool/circuit
	name = "circuit multitool"
	desc = "A circuit multitool. Used to mark entities which can then be uploaded to components by pressing the upload button on a port. \
	Acts as a normal multitool otherwise. Use in hand to clear marked entity so that you can mark another entity."
	icon_state = "multitool_circuit"
	item_state = "multitool_circuit"
	/// The marked atom of this multitool
	var/atom/marked_atom

/obj/item/multitool/circuit/Destroy()
	marked_atom = null
	return ..()

/obj/item/multitool/circuit/on_examine(datum/source, mob/user, list/examine_list)
	. = ..()
	examine_list += "<span class='notice'>It has [marked_atom? "a" : "no"] marked entity registered.</span>"

/obj/item/multitool/circuit/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return
	if(!marked_atom)
		return

	say("Cleared marked targets.")
	clear_marked_atom()
	return TRUE

/obj/item/multitool/circuit/melee_attack_chain(mob/user, atom/target, params)
	if(marked_atom || !user.Adjacent(target))
		return ..()

	say("Marked [target].")
	marked_atom = target
	RegisterSignal(marked_atom, COMSIG_PARENT_QDELETING, PROC_REF(cleanup_marked_atom))
	return TRUE

/// Clears the current marked atom
/obj/item/multitool/circuit/proc/clear_marked_atom()
	if(!marked_atom)
		return
	UnregisterSignal(marked_atom, COMSIG_PARENT_QDELETING)
	marked_atom = null

/obj/item/multitool/circuit/proc/cleanup_marked_atom(datum/source)
	SIGNAL_HANDLER
	if(source == marked_atom)
		clear_marked_atom()
