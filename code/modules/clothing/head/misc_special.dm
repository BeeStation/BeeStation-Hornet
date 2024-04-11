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
	flash_protect = 2
	tint = 2
	armor = list(MELEE = 10,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 60, STAMINA = 5)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	actions_types = list(/datum/action/item_action/toggle)
	visor_flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	visor_flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	resistance_flags = FIRE_PROOF

/obj/item/clothing/head/utility/welding/attack_self(mob/user)
	weldingvisortoggle(user)

/obj/item/clothing/head/wig
	name = "wig"
	desc = "A bunch of hair without a head attached."
	icon = 'icons/mob/human_face.dmi'	  // default icon for all hairs
	icon_state = "hair_vlong"
	item_state = "pwig"
	flags_inv = HIDEHAIR	//Instead of being handled as a clothing item, it overrides the hair values in /datum/species/proc/handle_hair
	slot_flags = ITEM_SLOT_HEAD
	worn_icon = 'icons/mob/human_face.dmi'
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
			H.update_inv_head()

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
		user.visible_message("<span class='notice'>[user] changes \the [src]'s hairstyle to [new_style].</span>", "<span class='notice'>You change \the [src]'s hairstyle to [new_style].</span>")
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

/obj/item/clothing/head/wig/natural/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(ishuman(user) && (slot == ITEM_SLOT_HEAD || slot == ITEM_SLOT_NECK))
		hair_color = "#[user.hair_color]"
		gradient_style = user.gradient_style
		gradient_color = "#[user.gradient_color]"
		update_icon()

/obj/item/clothing/head/costume/speedwagon
	name = "hat of ultimate masculinity"
	desc = "Even the mere act of wearing this makes you want to pose menacingly."
	worn_icon = 'icons/mob/large-worn-icons/64x64/head.dmi'
	icon_state = "speedwagon"
	item_state = "speedwagon"
	worn_x_dimension = 64
	worn_y_dimension = 64

/obj/item/clothing/head/costume/speedwagon/cursed
	name = "ULTIMATE HAT"
	desc = "You feel weak and pathetic in comparison to this exceptionally beautiful hat."
	icon_state = "speedwagon_cursed"
	item_state = "speedwagon_cursed"

/obj/item/clothing/head/franks_hat
	name = "Frank's Hat"
	desc = "You feel ashamed about what you had to do to get this hat"
	icon = 'icons/obj/clothing/head/cowboy.dmi'
	worn_icon = 'icons/mob/clothing/head/cowboy.dmi'
	icon_state = "cowboy"
	item_state = "cowboy"
