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
	clothing_flags = SNUG_FIT
	custom_materials = list(/datum/material/iron=1750, /datum/material/glass=400)
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	armor_type = /datum/armor/utility_welding
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	actions_types = list(/datum/action/item_action/toggle)
	visor_flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	visor_flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	resistance_flags = FIRE_PROOF


/datum/armor/utility_welding
	melee = 10
	fire = 100
	acid = 60
	stamina = 5

/obj/item/clothing/head/utility/welding/attack_self(mob/user)
	weldingvisortoggle(user)

/obj/item/clothing/head/wig
	name = "wig"
	desc = "A bunch of hair without a head attached."
	icon = 'icons/mob/species/human/human_face.dmi'	  // default icon for all hairs
	icon_state = "hair_vlong"
	item_state = "pwig"
	flags_inv = HIDEHAIR	//Instead of being handled as a clothing item, it overrides the hair values in /datum/species/proc/handle_hair
	slot_flags = ITEM_SLOT_HEAD
	worn_icon = 'icons/mob/species/human/human_face.dmi'
	worn_icon_state = "bald"
	var/hair_style = "Very Long Hair"
	var/hair_color = "#000"
	var/gradient_style = "None"
	var/gradient_color = "000"
	var/adjustablecolor = TRUE //can color be changed manually?
	strip_delay = 10 //It's fake hair, can't be too hard to just grab and pull it off
	var/obj/item/clothing/head/hat_attached_to = null

/obj/item/clothing/head/wig/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/clothing/head/wig/Destroy()
	. = ..()
	if(hat_attached_to)
		hat_attached_to.attached_wig = null

/obj/item/clothing/head/wig/dropped(mob/user)
	..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.head == src)
			H.update_worn_head()

/obj/item/clothing/head/wig/update_icon()
	cut_overlays()
	var/datum/sprite_accessory/S = GLOB.hair_styles_list[hair_style]
	if(!S)
		icon_state = "pwig"
	else
		var/mutable_appearance/M = mutable_appearance(S.icon,S.icon_state)
		M.appearance_flags |= RESET_COLOR
		M.color = hair_color
		add_overlay(M)

/obj/item/clothing/head/wig/attack_self(mob/user)
	var/new_style = input(user, "Select a hair style", "Wig Styling")  as null|anything in (GLOB.hair_styles_list - "Bald")
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(new_style && new_style != hair_style)
		hair_style = new_style
		user.visible_message(span_notice("[user] changes \the [src]'s hairstyle to [new_style]."), span_notice("You change \the [src]'s hairstyle to [new_style]."))
	if(adjustablecolor)
		hair_color = tgui_color_picker(usr,"","Choose Color",hair_color)
		var/picked_gradient_style
		picked_gradient_style = input(usr, "", "Choose Gradient")  as null|anything in GLOB.hair_gradients_list
		if(picked_gradient_style)
			gradient_style = picked_gradient_style
			if(gradient_style != "None")
				var/picked_hair_gradient = tgui_color_picker(user, "", "Choose Gradient Color", "#" + gradient_color)
				if(picked_hair_gradient)
					gradient_color = sanitize_hexcolor(picked_hair_gradient)
				else
					gradient_color = "000"
			else
				gradient_color = "000"
		else
			gradient_style = "None"
			gradient_color = "000"

	update_icon()

/obj/item/clothing/head/wig/random/Initialize(mapload)
	. = ..()

	hair_style = pick(GLOB.hair_styles_list - "Bald") //Don't want invisible wig
	hair_color = "#[random_short_color()]"

/obj/item/clothing/head/wig/natural
	name = "natural wig"
	desc = "A bunch of hair without a head attached. This one changes color to match the hair of the wearer. Nothing natural about that."
	hair_color = "#FFF"
	adjustablecolor = FALSE
	custom_price = 25

/obj/item/clothing/head/wig/natural/Initialize(mapload)
	hair_style = pick(GLOB.hair_styles_list - "Bald")
	. = ..()

/obj/item/clothing/head/wig/natural/equipped(mob/user, slot)
	if(ishuman(user) && slot == ITEM_SLOT_HEAD)
		var/mob/living/carbon/human/human_mob = user
		hair_color = "#[human_mob.hair_color]"
		update_icon()
	. = ..()

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
