/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/obj/clothing/masks.dmi'
	body_parts_covered = HEAD
	slot_flags = ITEM_SLOT_MASK
	strip_delay = 40
	equip_delay_other = 40
	var/modifies_speech = FALSE
	var/mask_adjusted = 0
	var/adjusted_flags = null

/obj/item/clothing/mask/attack_self(mob/user)
	if(CHECK_BITFIELD(clothing_flags, VOICEBOX_TOGGLABLE))
		TOGGLE_BITFIELD(clothing_flags, VOICEBOX_DISABLED)
		var/status = !CHECK_BITFIELD(clothing_flags, VOICEBOX_DISABLED)
		to_chat(user, "<span class='notice'>You turn the voice box in [src] [status ? "on" : "off"].</span>")

/obj/item/clothing/mask/equipped(mob/M, slot)
	. = ..()
	if (slot == ITEM_SLOT_MASK && modifies_speech)
		RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	else
		UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/mask/dropped(mob/M)
	..()
	UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/mask/proc/handle_speech()
	SIGNAL_HANDLER
/obj/item/clothing/mask/worn_overlays(mutable_appearance/standing, isinhands = FALSE)
	. = list()
	if(!isinhands)
		if(body_parts_covered & HEAD)
			if(damaged_clothes)
				. += mutable_appearance('icons/effects/item_damage.dmi', "damagedmask")
			if(HAS_BLOOD_DNA(src))
				. += mutable_appearance('icons/effects/blood.dmi', "maskblood")

/obj/item/clothing/mask/update_clothes_damaged_state(damaging = TRUE)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_wear_mask()

//Proc that moves gas/breath masks out of the way, disabling them and allowing pill/food consumption
/obj/item/clothing/mask/proc/adjustmask(mob/living/carbon/user)
	if(user && user.incapacitated())
		return
	mask_adjusted = !mask_adjusted
	if(!mask_adjusted)
		icon_state = initial(icon_state)
		gas_transfer_coefficient = initial(gas_transfer_coefficient)
		permeability_coefficient = initial(permeability_coefficient)
		clothing_flags |= visor_flags
		flags_inv |= visor_flags_inv
		flags_cover |= visor_flags_cover
		to_chat(user, "<span class='notice'>You push \the [src] back into place.</span>")
		slot_flags = initial(slot_flags)
	else
		icon_state += "_up"
		to_chat(user, "<span class='notice'>You push \the [src] out of the way.</span>")
		gas_transfer_coefficient = null
		permeability_coefficient = null
		clothing_flags &= ~visor_flags
		flags_inv &= ~visor_flags_inv
		flags_cover &= ~visor_flags_cover
		if(adjusted_flags)
			slot_flags = adjusted_flags
	if(!istype(user))
		return
	if(user.wear_mask == src)
		user.wear_mask_update(src, toggle_off = mask_adjusted)
	if(loc == user)
		// Update action button icon for adjusted mask, if someone is holding it.
		user.update_action_buttons_icon() //when mask is adjusted out, we update all buttons icon so the user's potential internal tank correctly shows as off.

/obj/item/clothing/mask/compile_monkey_icon()
	//If the icon, for this type of item, is already made by something else, don't make it again
	if(GLOB.monkey_icon_cache[type])
		monkey_icon = GLOB.monkey_icon_cache[type]
		return

	//Start with two sides
	var/icon/main = icon('icons/mob/mask.dmi', icon_state) //This takes the icon and uses the worn version of the icon
	var/icon/sub = icon('icons/mob/mask.dmi', icon_state)

	//merge the sub side with the main, after masking off the middle pixel line
	var/icon/mask = new('icons/mob/monkey.dmi', "monkey_mask_right") //masking
	main.AddAlphaMask(mask)
	mask = new('icons/mob/monkey.dmi', "monkey_mask_left")
	sub.AddAlphaMask(mask)
	sub.Shift(EAST, 1)
	main.Blend(sub, ICON_OVERLAY)

	//Flip it facing west, due to a spriting quirk
	sub = icon('icons/mob/mask.dmi', icon_state, dir = EAST)
	main.Insert(sub, dir = EAST)
	sub.Flip(WEST)
	main.Insert(sub, dir = WEST)

	//Mix in GAG color
	if(greyscale_colors)
		main.Blend(greyscale_colors, ICON_MULTIPLY)

	//Finished
	monkey_icon = main
	GLOB.monkey_icon_cache[type] = icon(monkey_icon)
