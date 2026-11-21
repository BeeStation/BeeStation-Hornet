/**
 * drag_pickup element
 *
 * Allowing things to be picked up or unequipped by mouse-dragging.
 * Useful for objects which have an interaction on click
 */
/datum/element/drag_pickup

/datum/element/drag_pickup/Attach(datum/target)
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOUSEDROP_ONTO, PROC_REF(pick_up))
	return ..()

/datum/element/drag_pickup/Detach(datum/source)
	UnregisterSignal(source, COMSIG_MOUSEDROP_ONTO)
	return ..()

/datum/element/drag_pickup/proc/pick_up(obj/item/source, atom/over, mob/user)
	SIGNAL_HANDLER

	var/hand_slot = istype(over, /atom/movable/screen/inventory/hand)
	if(over != user && !hand_slot)
		return NONE
	if(source.anchored || source.atom_storage)
		return NONE
	if(!user.can_perform_action(source, FORBID_TELEKINESIS_REACH))
		return NONE
	if(source.loc == user && !source.can_mob_unequip(user))
		return COMPONENT_CANCEL_MOUSEDROP_ONTO

	var/hand_index
	if(hand_slot)
		var/atom/movable/screen/inventory/hand/selected_hand = over
		hand_index = selected_hand.held_index
	else if(source.loc == user)
		var/list/free_hands = user.get_empty_held_indexes()
		if(!length(free_hands))
			return COMPONENT_CANCEL_MOUSEDROP_ONTO
		hand_index = (user.active_hand_index in free_hands) ? user.active_hand_index : free_hands[1]
	else
		INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, put_in_hands), source)
		source.add_fingerprint(user)
		return COMPONENT_CANCEL_MOUSEDROP_ONTO

	if(user.putItemFromInventoryInHandIfPossible(source, hand_index))
		source.add_fingerprint(user)
	return COMPONENT_CANCEL_MOUSEDROP_ONTO
