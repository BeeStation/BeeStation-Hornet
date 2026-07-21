/obj/item/bodypart/head/psyphoza
	icon_static = 'icons/mob/human/species/psyphoza/bodyparts.dmi'
	limb_id = SPECIES_PSYPHOZA
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	burn_modifier = 1.25
	head_flags = NONE

/obj/item/bodypart/head/psyphoza/Initialize(mapload)
	worn_ears_offset = new(
		attached_part = src,
		feature_key = OFFSET_EARS,
		offset_y = list("south" = -3)
	)

	worn_glasses_offset = new(
		attached_part = src,
		feature_key = OFFSET_GLASSES,
		offset_y = list("south" = -2)
	)

	worn_mask_offset = new(
		attached_part = src,
		feature_key = OFFSET_FACEMASK,
		offset_y = list("south" = -2)
	)

	worn_head_offset = new(
		attached_part = src,
		feature_key = OFFSET_HEAD,
		offset_y = list("south" = -2)
	)

	worn_face_offset = new(
		attached_part = src,
		feature_key = OFFSET_FACE,
		offset_y = list("south" = -2)
	)
	return ..()

/obj/item/bodypart/chest/psyphoza
	icon_static = 'icons/mob/human/species/psyphoza/bodyparts.dmi'
	limb_id = SPECIES_PSYPHOZA
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	burn_modifier = 1.25

/obj/item/bodypart/arm/left/psyphoza
	icon_static = 'icons/mob/human/species/psyphoza/bodyparts.dmi'
	limb_id = SPECIES_PSYPHOZA
	should_draw_greyscale = FALSE
	burn_modifier = 1.25

/obj/item/bodypart/arm/right/psyphoza
	icon_static = 'icons/mob/human/species/psyphoza/bodyparts.dmi'
	limb_id = SPECIES_PSYPHOZA
	should_draw_greyscale = FALSE
	burn_modifier = 1.25

/obj/item/bodypart/leg/left/psyphoza
	icon_static = 'icons/mob/human/species/psyphoza/bodyparts.dmi'
	limb_id = SPECIES_PSYPHOZA
	should_draw_greyscale = FALSE
	burn_modifier = 1.25

/obj/item/bodypart/leg/right/psyphoza
	icon_static = 'icons/mob/human/species/psyphoza/bodyparts.dmi'
	limb_id = SPECIES_PSYPHOZA
	should_draw_greyscale = FALSE
	burn_modifier = 1.25
