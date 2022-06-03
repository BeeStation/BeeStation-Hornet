// -- Added during grod revival --
#define GROD_LIMB_UPPER "_u"
#define GROD_LIMB_LOWER "_l"

/obj/item/bodypart/head/grod
	static_icon = 'icons/mob/species/grod/bodyparts.dmi'
	icon = 'icons/mob/species/grod/bodyparts.dmi'
	limb_id = "grod"
	is_dimorphic = FALSE
	should_draw_greyscale = TRUE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC | BODYTYPE_BOXHEAD
	light_brute_msg = "scratched"
	medium_brute_msg = "dented"
	heavy_brute_msg = "sheared"

	light_burn_msg = "burned"
	medium_burn_msg = "scorched"
	heavy_burn_msg = "seared"

/obj/item/bodypart/chest/grod
	static_icon = 'icons/mob/species/grod/bodyparts.dmi'
	icon = 'icons/mob/species/grod/bodyparts.dmi'
	limb_id = "grod"
	is_dimorphic = FALSE
	should_draw_greyscale = TRUE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC

	light_brute_msg = "scratched"
	medium_brute_msg = "dented"
	heavy_brute_msg = "sheared"

	light_burn_msg = "burned"
	medium_burn_msg = "scorched"
	heavy_burn_msg = "seared"

/obj/item/bodypart/l_arm/grod_upper //upper left arm
	static_icon = 'icons/mob/species/grod/bodyparts.dmi'
	icon = 'icons/mob/species/grod/bodyparts.dmi'
	limb_id = "grod"
	should_draw_greyscale = TRUE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC

	light_brute_msg = "scratched"
	medium_brute_msg = "dented"
	heavy_brute_msg = "sheared"

	light_burn_msg = "burned"
	medium_burn_msg = "scorched"
	heavy_burn_msg = "seared"

	body_zone = BODY_ZONE_L_ARM

/obj/item/bodypart/r_arm/grod_upper //upper right arm
	static_icon = 'icons/mob/species/grod/bodyparts.dmi'
	icon = 'icons/mob/species/grod/bodyparts.dmi'
	limb_id = "grod"
	should_draw_greyscale = TRUE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC

	light_brute_msg = "scratched"
	medium_brute_msg = "dented"
	heavy_brute_msg = "sheared"

	light_burn_msg = "burned"
	medium_burn_msg = "scorched"
	heavy_burn_msg = "seared"

	body_zone = BODY_ZONE_R_ARM

/obj/item/bodypart/l_arm/grod_lower //lower left arm
	static_icon = 'icons/mob/species/grod/bodyparts.dmi'
	icon = 'icons/mob/species/grod/bodyparts.dmi'
	limb_id = "grod"
	should_draw_greyscale = TRUE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC

	light_brute_msg = "scratched"
	medium_brute_msg = "dented"
	heavy_brute_msg = "sheared"

	light_burn_msg = "burned"
	medium_burn_msg = "scorched"
	heavy_burn_msg = "seared"

	body_zone = BODY_ZONE_L_ARM+GROD_LIMB_LOWER


/obj/item/bodypart/r_arm/grod_lower //lower right arm
	static_icon = 'icons/mob/species/grod/bodyparts.dmi'
	icon = 'icons/mob/species/grod/bodyparts.dmi'
	limb_id = "grod"
	should_draw_greyscale = TRUE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC

	light_brute_msg = "scratched"
	medium_brute_msg = "dented"
	heavy_brute_msg = "sheared"

	light_burn_msg = "burned"
	medium_burn_msg = "scorched"
	heavy_burn_msg = "seared"

	body_zone = BODY_ZONE_R_ARM+GROD_LIMB_LOWER

/obj/item/bodypart/l_leg/grod
	static_icon = 'icons/mob/species/grod/bodyparts.dmi'
	icon = 'icons/mob/species/grod/bodyparts.dmi'
	limb_id = "grod"
	should_draw_greyscale = TRUE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC

	light_brute_msg = "scratched"
	medium_brute_msg = "dented"
	heavy_brute_msg = "sheared"

	light_burn_msg = "burned"
	medium_burn_msg = "scorched"
	heavy_burn_msg = "seared"

/obj/item/bodypart/r_leg/grod
	static_icon = 'icons/mob/species/grod/bodyparts.dmi'
	icon = 'icons/mob/species/grod/bodyparts.dmi'
	limb_id = "grod"
	should_draw_greyscale = TRUE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC

	light_brute_msg = "scratched"
	medium_brute_msg = "dented"
	heavy_brute_msg = "sheared"

	light_burn_msg = "burned"
	medium_burn_msg = "scorched"
	heavy_burn_msg = "seared"
