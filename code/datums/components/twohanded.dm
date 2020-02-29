/datum/component/twohanded
	can_transfer = FALSE

	var/wielded = FALSE
	var/force_unwielded = 0
	var/force_wielded = 0
	var/wieldsound = null
	var/unwieldsound = null

	var/obj/item/master

/datum/component/twohanded/Initialize(_force_unwielded, _force_wielded, _wieldsound, _unwieldsound)
	..()
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE

	master = parent
	force_unwielded = _force_unwielded
	force_wielded = _force_wielded
	wieldsound = _wieldsound
	unwieldsound = _unwieldsound

	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/attack_self)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/dropped)
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/equipped)
	RegisterSignal(parent, COMSIG_ITEM_IS_WIELDED, .proc/check_wielded)
	RegisterSignal(parent, COMSIG_ITEM_SET_WIELD_FORCE, .proc/set_force)
	RegisterSignal(parent, COMSIG_ITEM_MODIFY_WIELD_FORCE, .proc/modify_force)
	RegisterSignal(parent, COMSIG_ITEM_WIELD, .proc/wield)
	RegisterSignal(parent, COMSIG_ITEM_UNWIELD, .proc/unwield)

/datum/component/twohanded/proc/unwield(obj/item/I, mob/living/user, show_message = TRUE)
	//Can we unwield it?
	if(!wielded)
		return
	//Update stats and icon
	wielded = FALSE
	if(!isnull(force_unwielded))
		master.force = force_unwielded
	var/sf = findtext(master.name," (Wielded)")
	if(sf)
		master.name = copytext(master.name,1,sf)
	else //something wrong
		master.name = "[initial(master.name)]"
	master.update_icon()
	//User interaction
	if(!user)
		return
	if(user.get_item_by_slot(SLOT_BACK) == parent)
		user.update_inv_back()
	else
		user.update_inv_hands()
	if(show_message)
		if(iscyborg(user))
			to_chat(user, "<span class='notice'>You free up your module.</span>")
		else
			to_chat(user, "<span class='notice'>You are now carrying [parent] with one hand.</span>")
	if(unwieldsound)
		playsound(master.loc, unwieldsound, 50, 1)
	//Offhand
	var/obj/item/offhand/O = user.get_inactive_held_item()
	if(O)
		qdel(O)
	else
		message_admins("Error: wielded item [parent] had no offhand")

/datum/component/twohanded/proc/wield(obj/item/I, mob/living/user)
	//Can we wield it?
	if(wielded)
		return
	if(ismonkey(user))
		to_chat(user, "<span class='warning'>It's too heavy for you to wield fully.</span>")
		return
	if(user.get_inactive_held_item())
		to_chat(user, "<span class='warning'>You need your other hand to be empty!</span>")
		return
	if(user.get_num_arms() < 2)
		to_chat(user, "<span class='warning'>You don't have enough intact hands.</span>")
		return
	//Update stats and icon
	wielded = TRUE
	if(!isnull(force_wielded))
		master.force = force_wielded
	master.name = "[master.name] (Wielded)"
	master.update_icon()
	//User interaction
	if(iscyborg(user))
		to_chat(user, "<span class='notice'>You dedicate your module to [parent].</span>")
	else
		to_chat(user, "<span class='notice'>You grab [parent] with both hands.</span>")
	if (wieldsound)
		playsound(master.loc, wieldsound, 50, 1)
	//Offhand
	var/obj/item/offhand/O = new(user) ////Let's reserve his other hand~
	O.name = "[master.name] - offhand"
	O.desc = "Your second grip on [master]."
	user.put_in_inactive_hand(O)
	return

/datum/component/twohanded/proc/dropped(obj/item/I, mob/user)
	//handles unwielding a twohanded weapon when dropped as well as clearing up the offhand
	SEND_SIGNAL(I, COMSIG_ITEM_UNWIELD, user)

/datum/component/twohanded/proc/attack_self(obj/item/I, mob/user)
	if(wielded) //Trying to unwield it
		SEND_SIGNAL(I, COMSIG_ITEM_UNWIELD, user)
	else //Trying to wield it
		SEND_SIGNAL(I, COMSIG_ITEM_WIELD, user)

/datum/component/twohanded/proc/equip_to_best_slot(obj/item/I, mob/M)
	if(I.equip_to_best_slot(M))
		if(master.GetComponent(/datum/component/twohanded/required))
			return // unwield forces twohanded-required items to be dropped.
		SEND_SIGNAL(I, COMSIG_ITEM_UNWIELD, M)
		return

/datum/component/twohanded/proc/equipped(obj/item/I, mob/user, slot)
	if(!user.is_holding(master) && wielded && !master.GetComponent(/datum/component/twohanded/required))
		SEND_SIGNAL(I, COMSIG_ITEM_UNWIELD, user)

/datum/component/twohanded/proc/check_wielded()
	if(wielded)
		return COMPONENT_WIELDED
	return 0

/datum/component/twohanded/proc/set_force(_force_unwielded, _force_wielded)
	force_unwielded = _force_unwielded
	force_wielded = _force_wielded

/datum/component/twohanded/proc/modify_force(unwielded_increase=0, wielded_increase=0, maximum)
	force_unwielded += unwielded_increase
	force_wielded += wielded_increase
	if(maximum)
		force_unwielded = CLAMP(force_wielded, 0, maximum)
		force_wielded = CLAMP(force_wielded, 0, maximum)

///// TWO-HANDED REQUIRED /////
/datum/component/twohanded/required
	can_transfer = FALSE

/datum/component/twohanded/required/Initialize()
	..()
	master.w_class = WEIGHT_CLASS_HUGE

	RegisterSignal(parent, COMSIG_ITEM_MOB_CAN_EQUIP, .proc/mob_can_equip)
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, .proc/attack_hand)

/datum/component/twohanded/required/attack_self()
	return

/datum/component/twohanded/required/proc/mob_can_equip(obj/item/I, mob/M, mob/equipper, slot, disable_warning = 0)
	if(wielded && !master.slot_flags)
		if(!disable_warning)
			to_chat(M, "<span class='warning'>[parent] is too cumbersome to carry with anything but your hands!</span>")
		return 0

/datum/component/twohanded/required/proc/attack_hand(obj/item/I, mob/user)//Can't even pick it up without both hands empty
	var/obj/item/H = user.get_inactive_held_item()
	if(get_dist(master, user) > 1)
		return
	if(H != null)
		to_chat(user, "<span class='notice'>[parent] is too cumbersome to carry in one hand!</span>")
		return
	if(master.loc != user)
		SEND_SIGNAL(I, COMSIG_ITEM_WIELD, user)
	return

/datum/component/twohanded/required/equipped(obj/item/I, mob/user, slot)
	var/slotbit = slotdefine2slotbit(slot)
	if(master.slot_flags & slotbit)
		var/datum/O = user.is_holding_item_of_type(/obj/item/offhand)
		if(!O || QDELETED(O))
			return
		qdel(O)
		return
	if(slot == SLOT_HANDS)
		SEND_SIGNAL(I, COMSIG_ITEM_WIELD, user)
	else
		SEND_SIGNAL(I, COMSIG_ITEM_UNWIELD, user, FALSE)

/datum/component/twohanded/required/dropped(obj/item/I, mob/living/user, show_message = TRUE)
	SEND_SIGNAL(I, COMSIG_ITEM_UNWIELD, user, show_message)
	..()

/datum/component/twohanded/required/wield(obj/item/I, mob/living/user)
	..()
	if(!wielded)
		user.dropItemToGround(parent)

/datum/component/twohanded/required/unwield(obj/item/I, mob/living/user, show_message = TRUE)
	if(!wielded)
		return
	if(show_message)
		to_chat(user, "<span class='notice'>You drop [parent].</span>")
	..(I, user, FALSE)
	user.dropItemToGround(parent)
