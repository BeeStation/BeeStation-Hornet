/**
 * allow players to easily use items such as iron rods, rcds on open space without
 * having to pixelhunt for portions not occupied by object or mob visuals.
 */
/datum/element/openspace_item_click_handler
	element_flags = ELEMENT_DETACH

/datum/element/openspace_item_click_handler/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_afterattack))

/datum/element/openspace_item_click_handler/Detach(datum/source)
	UnregisterSignal(source, COMSIG_ITEM_AFTERATTACK)
	return ..()

//Invokes the proctype with a turf above as target.
/datum/element/openspace_item_click_handler/proc/on_afterattack(obj/item/source, mob/user, atom/target, click_parameters)
	SIGNAL_HANDLER
	if((target.z == 0) || (user.z == 0) || target.z == user.z)
		return
	var/turf/target_turf = parse_caught_click_modifiers(click_parameters, get_turf(user.client?.eye || user), user.client)
	if(target_turf?.z == user.z && target_turf.IsReachableBy(user, source?.reach))
		INVOKE_ASYNC(source, TYPE_PROC_REF(/obj/item, handle_openspace_click), target_turf, user, click_parameters)
		return
	return
