/**
 * Two Handed Component
 *
 * When applied to an item it will make it two handed
 *
 */
/datum/component/two_handed
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS 		// Only one of the component can exist on an item
	var/mob/wielder							/// The mob that is wielding us
	var/wielded = FALSE 							/// Are we holding the two handed item properly
	var/force_multiplier = 0						/// The multiplier applied to force when wielded, does not work with force_wielded, and force_unwielded
	var/force_wielded = 0	 						/// The force of the item when wielded
	var/force_unwielded = 0		 					/// The force of the item when unwielded
	var/block_power_wielded = 0						/// The block power of the item when wielded
	var/block_power_unwielded = 0					/// The block power of the item when unwielded
	var/wieldsound = FALSE 							/// Play sound when wielded
	var/unwieldsound = FALSE 						/// Play sound when unwielded
	var/attacksound = FALSE							/// Play sound on attack when wielded
	var/require_twohands = FALSE					/// Does it have to be held in both hands
	var/icon_wielded = FALSE						/// The icon that will be used when wielded
	var/obj/item/offhand/offhand_item		/// Reference to the offhand created for the item
	var/sharpened_increase = 0						/// The amount of increase recived from sharpening the item
	var/unwield_on_swap								/// Allow swapping, unwield on swap
	var/auto_wield									/// If true wielding will be performed when picked up
	var/ignore_attack_self							/// If true will not unwield when attacking self.

/**
 * Two Handed component
 *
 * vars:
 * * require_twohands (optional) Does the item need both hands to be carried
 * * wieldsound (optional) The sound to play when wielded
 * * unwieldsound (optional) The sound to play when unwielded
 * * attacksound (optional) The sound to play when wielded and attacking
 * * force_multiplier (optional) The force multiplier when wielded, do not use with force_wielded, and force_unwielded
 * * force_wielded (optional) The force setting when the item is wielded, do not use with force_multiplier
 * * force_unwielded (optional) The force setting when the item is unwielded, do not use with force_multiplier
 * * icon_wielded (optional) The icon to be used when wielded
 * * unwield_on_swap (optional) Allow swapping, unwield on swap
 * * auto_wield (optional) If true wielding will be performed when picked up
 */
/datum/component/two_handed/Initialize(require_twohands=FALSE, wieldsound=FALSE, unwieldsound=FALSE, attacksound=FALSE, \
		force_multiplier=0, force_wielded=0, force_unwielded=0, block_power_wielded=0, \
		block_power_unwielded=0, icon_wielded=FALSE, \
		unwield_on_swap = FALSE, auto_wield = FALSE, ignore_attack_self = FALSE)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.require_twohands = require_twohands
	src.wieldsound = wieldsound
	src.unwieldsound = unwieldsound
	src.attacksound = attacksound
	src.force_multiplier = force_multiplier
	src.force_wielded = force_wielded
	src.force_unwielded = force_unwielded
	src.block_power_wielded = block_power_wielded
	src.block_power_unwielded = block_power_unwielded
	src.icon_wielded = icon_wielded
	src.unwield_on_swap = unwield_on_swap
	src.auto_wield = auto_wield
	src.ignore_attack_self = ignore_attack_self

	if(require_twohands)
		ADD_TRAIT(parent, TRAIT_NEEDS_TWO_HANDS, ABSTRACT_ITEM_TRAIT)

// Inherit the new values passed to the component
#define ISWIELDED(O) (SEND_SIGNAL(O, COMSIG_ITEM_CHECK_WIELDED) & COMPONENT_IS_WIELDED)

/datum/component/two_handed/InheritComponent(datum/component/two_handed/new_comp, original, require_twohands, wieldsound, unwieldsound, \
		force_multiplier, force_wielded, force_unwielded, block_power_wielded, block_power_unwielded, icon_wielded, \
		unwield_on_swap, auto_wield, ignore_attack_self)
	if(!original)
		return
	if(require_twohands)
		src.require_twohands = require_twohands
	if(wieldsound)
		src.wieldsound = wieldsound
	if(unwieldsound)
		src.unwieldsound = unwieldsound
	if(attacksound)
		src.attacksound = attacksound
	if(force_multiplier)
		src.force_multiplier = force_multiplier
	if(force_wielded)
		src.force_wielded = force_wielded
	if(force_unwielded)
		src.force_unwielded = force_unwielded
	if(block_power_wielded)
		src.block_power_wielded = block_power_wielded
	if(block_power_unwielded)
		src.block_power_unwielded = block_power_unwielded
	if(icon_wielded)
		src.icon_wielded = icon_wielded
	if(unwield_on_swap)
		src.unwield_on_swap = unwield_on_swap
	if(auto_wield)
		src.auto_wield = auto_wield
	if(ignore_attack_self)
		src.ignore_attack_self = ignore_attack_self

// register signals withthe parent item
/datum/component/two_handed/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(on_attack))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON, PROC_REF(on_update_icon))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(parent, COMSIG_ITEM_SHARPEN_ACT, PROC_REF(on_sharpen))
	RegisterSignal(parent, COMSIG_ITEM_CHECK_WIELDED, PROC_REF(get_wielded))

// Remove all siginals registered to the parent item
/datum/component/two_handed/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED,
								COMSIG_ITEM_DROPPED,
								COMSIG_ITEM_ATTACK_SELF,
								COMSIG_ITEM_ATTACK,
								COMSIG_ATOM_UPDATE_ICON,
								COMSIG_MOVABLE_MOVED,
								COMSIG_ITEM_SHARPEN_ACT,
								COMSIG_ITEM_CHECK_WIELDED))

/// Triggered on equip of the item containing the component
/datum/component/two_handed/proc/on_equip(datum/source, mob/user, slot)
	SIGNAL_HANDLER

	if(auto_wield)
		if(slot == ITEM_SLOT_HANDS)
			RegisterSignal(user, COMSIG_MOB_SWAP_HANDS, PROC_REF(on_swap_hands))
		else
			UnregisterSignal(user, COMSIG_MOB_SWAP_HANDS)
	if((auto_wield || require_twohands) && slot == ITEM_SLOT_HANDS) // force equip the item
		wield(user)
	if(!user.is_holding(parent) && wielded && !require_twohands)
		unwield()

/// Triggered on drop of item containing the component
/datum/component/two_handed/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	if(auto_wield)
		UnregisterSignal(user, COMSIG_MOB_SWAP_HANDS)
	if(require_twohands || wielded)
		unwield()

/// Triggered on attack self of the item containing the component
/datum/component/two_handed/proc/on_attack_self(datum/source, mob/user)
	SIGNAL_HANDLER

	if(ignore_attack_self)
		return

	wielded ? unwield() : wield(user)

/**
 * Wield the two handed item in both hands
 *
 * vars:
 * * user The mob/living/carbon that is wielding the item
 */
/datum/component/two_handed/proc/wield(mob/living/carbon/user, swap_hands = FALSE)
	if(wielded)
		return
	var/atom/attached_atom = parent
	if(attached_atom.loc != user)
		to_chat(user, "<span class='warning'>You attempt to wield [parent] via the power of telekenisis, but it is too much for you to handle...</span>")
		return
	if(ismonkey(user))
		to_chat(user, "<span class='warning'>It's too heavy for you to wield fully.</span>")
		return
	if(swap_hands ? user.get_active_held_item() : user.get_inactive_held_item())
		if(require_twohands)
			to_chat(user, "<span class='notice'>[parent] is too cumbersome to carry in one hand!</span>")
			user.dropItemToGround(parent, force=TRUE)
		else
			to_chat(user, "<span class='warning'>You need your other hand to be empty!</span>")
		return
	if(user.get_num_arms() < 2)
		if(require_twohands)
			user.dropItemToGround(parent, force=TRUE)
		to_chat(user, "<span class='warning'>You don't have enough intact hands.</span>")
		return

	// wield update status
	if(SEND_SIGNAL(parent, COMSIG_TWOHANDED_WIELD, user) & COMPONENT_TWOHANDED_BLOCK_WIELD)
		return // blocked wield from item

	//If wielder isn't null already, unreference the old wielder
	if(wielder != null)
		unreference_wielder()

	wielder = user
	wielded = TRUE

	RegisterSignal(user, COMSIG_PARENT_QDELETING, PROC_REF(unreference_wielder))

	if(!auto_wield)
		RegisterSignal(user, COMSIG_MOB_SWAP_HANDS, PROC_REF(on_swap_hands))

	// update item stats and name
	var/obj/item/parent_item = parent
	if(force_multiplier)
		parent_item.force *= force_multiplier
	else if(force_wielded)
		parent_item.force = force_wielded
	if(block_power_wielded)
		parent_item.block_power = block_power_wielded
	if(sharpened_increase)
		parent_item.force += sharpened_increase
	parent_item.name = "[parent_item.name] (Wielded)"
	parent_item.update_icon()

	if(iscyborg(user))
		to_chat(user, "<span class='notice'>You dedicate your module to [parent].</span>")
	else
		to_chat(user, "<span class='notice'>You grab [parent] with both hands.</span>")

	// Play sound if one is set
	if(wieldsound)
		playsound(parent_item.loc, wieldsound, 50, TRUE)

	// Let's reserve the other hand
	offhand_item = new()
	offhand_item.name = "[parent_item.name] - offhand"
	offhand_item.desc = "Your second grip on [parent_item]."
	offhand_item.wielded = TRUE
	if(swap_hands)
		user.put_in_active_hand(offhand_item)
	else
		user.put_in_inactive_hand(offhand_item)

/datum/component/two_handed/proc/unreference_wielder()
	SIGNAL_HANDLER
	UnregisterSignal(wielder, COMSIG_PARENT_QDELETING)
	wielder = null

/**
 * Unwield the two handed item
 *
 * vars:
 * * user The mob/living/carbon that is unwielding the item
 * * show_message (option) show a message to chat on unwield
 */
/datum/component/two_handed/proc/unwield(show_message=TRUE)
	if(!wielded || !wielder)
		return

	// wield update status
	wielded = FALSE
	if(!auto_wield)
		UnregisterSignal(wielder, COMSIG_MOB_SWAP_HANDS)
	SEND_SIGNAL(parent, COMSIG_TWOHANDED_UNWIELD, wielder)

	// update item stats
	var/obj/item/parent_item = parent
	if(sharpened_increase)
		parent_item.force -= sharpened_increase
	if(force_multiplier)
		parent_item.force /= force_multiplier
	else if(!isnull(force_unwielded))
		parent_item.force = force_unwielded
	if(!isnull(block_power_unwielded))
		parent_item.block_power = block_power_unwielded

	// update the items name to remove the wielded status
	var/sf = findtext(parent_item.name, " (Wielded)", -10) // 10 == length(" (Wielded)")
	if(sf)
		parent_item.name = copytext(parent_item.name, 1, sf)
	else
		parent_item.name = "[initial(parent_item.name)]"

	// Update icons
	parent_item.update_icon()
	if(wielder.get_item_by_slot(ITEM_SLOT_BACK) == parent)
		wielder.update_inv_back()
	else
		wielder.update_inv_hands()

	// if the item requires two handed drop the item on unwield
	if(require_twohands)
		wielder.dropItemToGround(parent, force=TRUE)

	// Show message if requested
	if(show_message)
		if(iscyborg(wielder))
			to_chat(wielder, "<span class='notice'>You free up your module.</span>")
		else if(require_twohands)
			to_chat(wielder, "<span class='notice'>You drop [parent].</span>")
		else
			to_chat(wielder, "<span class='notice'>You are now carrying [parent] with one hand.</span>")

	// Play sound if set
	if(unwieldsound)
		playsound(parent_item.loc, unwieldsound, 50, TRUE)

	unreference_wielder()

	// Remove the object in the offhand
	if(offhand_item)
		QDEL_NULL(offhand_item)

/**
 * on_attack triggers on attack with the parent item
 */
/datum/component/two_handed/proc/on_attack(obj/item/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER

	if(wielded && attacksound)
		var/obj/item/parent_item = parent
		playsound(parent_item.loc, attacksound, 50, TRUE)

/**
 * on_update_icon triggers on call to update parent items icon
 *
 * Updates the icon using icon_wielded if set
 */
/datum/component/two_handed/proc/on_update_icon(datum/source)
	SIGNAL_HANDLER

	if(icon_wielded && wielded)
		var/obj/item/parent_item = parent
		if(parent_item)
			parent_item.icon_state = icon_wielded
			return COMSIG_ATOM_NO_UPDATE_ICON_STATE

/**
 * on_moved Triggers on item moved
 */
/datum/component/two_handed/proc/on_moved(datum/source, atom/loc, dir)
	SIGNAL_HANDLER

	var/atom/attached_object = parent
	if(attached_object.loc != wielder)
		unwield()

/**
 * on_swap_hands Triggers on swapping hands, blocks swap if the other hand is busy
 */
/datum/component/two_handed/proc/on_swap_hands(mob/user, obj/item/held_item)
	SIGNAL_HANDLER

	if(!held_item)
		//We are swapping to our two handed object.
		if(auto_wield)
			wield(user, TRUE)
		return
	if(held_item == parent)
		if(unwield_on_swap)
			unwield(FALSE)
		else
			return COMPONENT_BLOCK_SWAP

/**
 * on_sharpen Triggers on usage of a sharpening stone on the item
 */
/datum/component/two_handed/proc/on_sharpen(obj/item/item, amount, max_amount)
	SIGNAL_HANDLER

	if(!item)
		return COMPONENT_BLOCK_SHARPEN_BLOCKED
	if(sharpened_increase)
		return COMPONENT_BLOCK_SHARPEN_ALREADY
	var/wielded_val = 0
	if(force_multiplier)
		var/obj/item/parent_item = parent
		if(wielded)
			wielded_val = parent_item.force
		else
			wielded_val = parent_item.force * force_multiplier
	else
		wielded_val = force_wielded
	if(wielded_val > max_amount)
		return COMPONENT_BLOCK_SHARPEN_MAXED
	sharpened_increase = min(amount, (max_amount - wielded_val))
	return COMPONENT_BLOCK_SHARPEN_APPLIED

/datum/component/two_handed/proc/get_wielded(obj/item/source)
	SIGNAL_HANDLER

	if(wielded)
		return COMPONENT_IS_WIELDED
	else
		return 0

/**
 * The offhand dummy item for two handed items
 *
 */
/obj/item/offhand
	name = "offhand"
	icon_state = "offhand"
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ABSTRACT | DROPDEL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// Off Hand tracking of wielded status
	var/wielded = FALSE

/obj/item/offhand/equipped(mob/user, slot)
	if(wielded && !user.is_holding(src))
		qdel(src)
