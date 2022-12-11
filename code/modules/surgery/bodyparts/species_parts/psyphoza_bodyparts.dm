/obj/item/bodypart/head/psyphoza
	//static_icon = 'icons/mob/species/psyphoza/bodyparts.dmi'
	limb_id = SPECIES_PSYPHOZA
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

//Use this and the proc below to avoid rendering the head while it's attached to the body. Otherwise it renders above the cap.
/obj/item/bodypart/head/psyphoza/update_icon_dropped()
	. = ..()
	static_icon = 'icons/mob/species/psyphoza/bodyparts.dmi'

/obj/item/bodypart/head/psyphoza/update_limb(dropping_limb, mob/living/carbon/source, is_creating)
	. = ..()
	if(!dropping_limb)
		static_icon = null

/obj/item/bodypart/chest/psyphoza
	static_icon = 'icons/mob/species/psyphoza/bodyparts.dmi'
	limb_id = SPECIES_PSYPHOZA
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/l_arm/psyphoza
	static_icon = 'icons/mob/species/psyphoza/bodyparts.dmi'
	limb_id = SPECIES_PSYPHOZA
	should_draw_greyscale = FALSE

/obj/item/bodypart/r_arm/psyphoza
	static_icon = 'icons/mob/species/psyphoza/bodyparts.dmi'
	limb_id = SPECIES_PSYPHOZA
	should_draw_greyscale = FALSE

/obj/item/bodypart/l_leg/psyphoza
	static_icon = 'icons/mob/species/psyphoza/bodyparts.dmi'
	limb_id = SPECIES_PSYPHOZA
	should_draw_greyscale = FALSE

/obj/item/bodypart/r_leg/psyphoza
	static_icon = 'icons/mob/species/psyphoza/bodyparts.dmi'
	limb_id = SPECIES_PSYPHOZA
	should_draw_greyscale = FALSE
