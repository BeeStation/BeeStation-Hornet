/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/obj/clothing/masks.dmi'
	body_parts_covered = HEAD
	slot_flags = ITEM_SLOT_MASK
	strip_delay = 40
	equip_delay_other = 40
	visor_vars_to_toggle = NONE
	custom_price = 25
	var/modifies_speech = FALSE
	var/adjusted_flags = null
	var/voice_change = FALSE //Used to mask/change the user's voice, only specific masks can set this to TRUE
	var/obj/item/organ/tongue/chosen_tongue = null

/obj/item/clothing/mask/attack_self(mob/user)
	if((clothing_flags & VOICEBOX_TOGGLABLE))
		clothing_flags ^= (VOICEBOX_DISABLED)
		var/status = !(clothing_flags & VOICEBOX_DISABLED)
		to_chat(user, span_notice("You turn the voice box in [src] [status ? "on" : "off"]."))

/obj/item/clothing/mask/equipped(mob/M, slot)
	. = ..()
	if (slot == ITEM_SLOT_MASK && modifies_speech)
		RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	else
		UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/mask/dropped(mob/M)
	..()
	UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/mask/Destroy()
	chosen_tongue = null
	. = ..()

/obj/item/clothing/mask/proc/handle_speech()
	SIGNAL_HANDLER

/obj/item/clothing/mask/proc/get_name(mob/user, default_name)
	return default_name

/obj/item/clothing/mask/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file, item_layer, atom/origin)
	. = ..()
	if(!isinhands)
		if(body_parts_covered & HEAD)
			if(damaged_clothes)
				. += mutable_appearance('icons/effects/item_damage.dmi', "damagedmask", item_layer)
			if(GET_ATOM_BLOOD_DNA_LENGTH(src))
				var/mutable_appearance/bloody_mask = mutable_appearance('icons/effects/blood.dmi', "maskblood", item_layer)
				bloody_mask.color = get_blood_dna_color(GET_ATOM_BLOOD_DNA(src))
				. += bloody_mask

/obj/item/clothing/mask/update_clothes_damaged_state(damaged_state = CLOTHING_DAMAGED)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_worn_mask()

//Proc that moves gas/breath masks out of the way, disabling them and allowing pill/food consumption
/obj/item/clothing/mask/visor_toggling(mob/living/user)
	. = ..()
	if(up)
		if(adjusted_flags)
			slot_flags = adjusted_flags
	else
		slot_flags = initial(slot_flags)

/obj/item/clothing/mask/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][up ? "_up" : ""]"

/obj/item/clothing/mask/compile_monkey_icon()
	var/identity = "[type]_[icon_state]" //Allows using multiple icon states for piece of clothing
	//If the icon, for this type of item, is already made by something else, don't make it again
	if(GLOB.monkey_icon_cache[identity])
		monkey_icon = GLOB.monkey_icon_cache[identity]
		return

	//Start with two sides
	var/icon/main = icon('icons/mob/clothing/mask.dmi', icon_state) //This takes the icon and uses the worn version of the icon
	var/icon/sub = icon('icons/mob/clothing/mask.dmi', icon_state)

	//merge the sub side with the main, after masking off the middle pixel line
	var/icon/mask = new('icons/mob/monkey.dmi', "monkey_mask_right") //masking
	main.AddAlphaMask(mask)
	mask = new('icons/mob/monkey.dmi', "monkey_mask_left")
	sub.AddAlphaMask(mask)
	sub.Shift(EAST, 1)
	main.Blend(sub, ICON_OVERLAY)

	//Flip it facing west, due to a spriting quirk
	sub = icon('icons/mob/clothing/mask.dmi', icon_state, dir = EAST)
	main.Insert(sub, dir = EAST)
	sub.Flip(WEST)
	main.Insert(sub, dir = WEST)

	//Mix in GAG color
	if(greyscale_colors)
		main.Blend(greyscale_colors, ICON_MULTIPLY)

	//Finished
	monkey_icon = main
	GLOB.monkey_icon_cache[identity] = icon(monkey_icon)
