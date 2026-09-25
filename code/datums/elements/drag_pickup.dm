/**
 * drag_pickup element
 *
 * Allowing things to be picked up or unequipped by mouse-dragging.
 * Useful for objects which have an interaction on click
 */
/datum/element/drag_pickup

/datum/element/drag_pickup/Attach(datum/target)
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOUSEDROP_ONTO, PROC_REF(pick_up))
	return ..()

/datum/element/drag_pickup/Detach(datum/source)
	UnregisterSignal(source, COMSIG_MOUSEDROP_ONTO)
	return ..()

/datum/element/drag_pickup/proc/pick_up(atom/movable/source, atom/over, mob/user)
	SIGNAL_HANDLER

	var/hand_slot = istype(over, /atom/movable/screen/inventory/hand)
	if(over != user && !hand_slot) // anything else is somebody else's drop to handle
		return NONE
	if(!isitem(source) || source.anchored)
		return NONE
	if(!user.canUseTopic(source, be_close = TRUE, no_dexterity = TRUE, no_tk = TRUE))
		return NONE

	var/obj/item/item_source = source
	var/equipped = (item_source.loc == user)
	if(equipped && !item_source.can_mob_unequip(user))
		return COMPONENT_CANCEL_MOUSEDROP_ONTO

	if(hand_slot)
		var/atom/movable/screen/inventory/hand/selected_hand = over
		user.putItemFromInventoryInHandIfPossible(item_source, selected_hand.held_index)
	else if(equipped)
		// put_in_hands would forceMove it out of the slot without unequipping
		var/free_hand = user.get_empty_held_index_for_side(LEFT_HANDS) || user.get_empty_held_index_for_side(RIGHT_HANDS)
		if(!free_hand)
			return COMPONENT_CANCEL_MOUSEDROP_ONTO
		user.putItemFromInventoryInHandIfPossible(item_source, free_hand)
	else
		INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, put_in_hands), item_source)
	item_source.add_fingerprint(user)
	return COMPONENT_CANCEL_MOUSEDROP_ONTO
