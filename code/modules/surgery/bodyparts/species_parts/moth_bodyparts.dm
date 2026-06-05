/obj/item/bodypart/head/moth
	icon = 'icons/mob/human/species/moth/bodyparts.dmi'
	icon_greyscale = 'icons/mob/human/species/moth/bodyparts.dmi'
	icon_state = "moth_head"
	limb_id = SPECIES_MOTH
	is_dimorphic = FALSE
	should_draw_greyscale = TRUE

/obj/item/bodypart/chest/moth
	icon = 'icons/mob/human/species/moth/bodyparts.dmi'
	icon_greyscale = 'icons/mob/human/species/moth/bodyparts.dmi'
	icon_state = "moth_chest_m"
	limb_id = SPECIES_MOTH
	is_dimorphic = TRUE
	should_draw_greyscale = TRUE

/obj/item/bodypart/arm/left/moth
	icon = 'icons/mob/human/species/moth/bodyparts.dmi'
	icon_greyscale = 'icons/mob/human/species/moth/bodyparts.dmi'
	icon_state = "moth_l_arm"
	limb_id = SPECIES_MOTH
	should_draw_greyscale = TRUE

/obj/item/bodypart/arm/right/moth
	icon = 'icons/mob/human/species/moth/bodyparts.dmi'
	icon_greyscale = 'icons/mob/human/species/moth/bodyparts.dmi'
	icon_state = "moth_r_arm"
	limb_id = SPECIES_MOTH
	should_draw_greyscale = TRUE

/obj/item/bodypart/leg/left/moth
	icon = 'icons/mob/human/species/moth/bodyparts.dmi'
	icon_greyscale = 'icons/mob/human/species/moth/bodyparts.dmi'
	icon_state = "moth_l_leg"
	limb_id = SPECIES_MOTH
	should_draw_greyscale = TRUE

/obj/item/bodypart/leg/right/moth
	icon = 'icons/mob/human/species/moth/bodyparts.dmi'
	icon_greyscale = 'icons/mob/human/species/moth/bodyparts.dmi'
	icon_state = "moth_r_leg"
	limb_id = SPECIES_MOTH
	should_draw_greyscale = TRUE

// Alternative pointed moth head : used in head shape moth preference
/obj/item/bodypart/head/moth/pointed
	icon_state = "moth_head_alt"

/obj/item/bodypart/head/moth/pointed/get_limb_icon(dropped)
	. = ..()

	var/default_state = "[limb_id]_[body_zone]"
	for(var/image/part_image as anything in .)
		if(part_image.icon == icon_greyscale && part_image.icon_state == default_state)
			part_image.icon_state = initial(icon_state)
