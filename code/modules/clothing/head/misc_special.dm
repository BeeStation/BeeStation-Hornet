/*
 * Contents:
 *		Welding mask
 *		Cakehat
 *		Ushanka
 *		Pumpkin head
 *		Kitty ears
 *		Cardborg disguise
 *		Wig
 *		Bronze hat
 */

/obj/item/clothing/head/utility/welding
	name = "welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye."
	icon_state = "welding"
	item_state = "welding"
	custom_materials = list(/datum/material/iron=1750, /datum/material/glass=400)
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	armor_type = /datum/armor/utility_welding
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	actions_types = list(/datum/action/item_action/toggle)
	visor_flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	visor_flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	resistance_flags = FIRE_PROOF
	clothing_flags = SNUG_FIT | STACKABLE_HELMET_EXEMPT


/datum/armor/utility_welding
	melee = 10
	fire = 100
	acid = 60
	stamina = 5

/obj/item/clothing/head/utility/welding/attack_self(mob/user)
	adjust_visor(user)

/obj/item/clothing/head/utility/welding/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][up ? "up" : ""]"
	item_state = "[initial(item_state)][up ? "off" : ""]"

/obj/item/clothing/head/kitty/visual_equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(ishuman(user) && (slot == ITEM_SLOT_HEAD || slot == ITEM_SLOT_NECK))
		update_icon(ALL, user)
		user.update_worn_head() //Color might have been changed by update_appearance.
	..()

/obj/item/clothing/head/kitty/update_icon(updates=ALL, mob/living/carbon/human/user)
	. = ..()
	if(ishuman(user))
		add_atom_colour(user.hair_color, FIXED_COLOUR_PRIORITY)

/obj/item/clothing/head/costume/speedwagon
	name = "hat of ultimate masculinity"
	desc = "Even the mere act of wearing this makes you want to pose menacingly."
	icon_state = "speedwagon"
	item_state = "speedwagon"
	worn_y_offset = 4

/obj/item/clothing/head/costume/speedwagon/cursed
	name = "ULTIMATE HAT"
	desc = "You feel weak and pathetic in comparison to this exceptionally beautiful hat."
	icon_state = "speedwagon"
	item_state = "speedwagon"
	worn_y_offset = 6

/obj/item/clothing/head/franks_hat
	name = "Frank's Hat"
	desc = "You feel ashamed about what you had to do to get this hat"
	icon = 'icons/obj/clothing/head/cowboy.dmi'
	worn_icon = 'icons/mob/clothing/head/cowboy.dmi'
	icon_state = "cowboy"
	item_state = "cowboy"
