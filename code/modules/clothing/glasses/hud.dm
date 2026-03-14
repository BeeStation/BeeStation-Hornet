/obj/item/clothing/glasses/hud
	name = "HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags_1 = null //doesn't protect eyes because it's a monocle, duh
	var/atom/movable/screen/plane_master/data_hud/glitching_hud

/obj/item/clothing/glasses/hud/equipped(mob/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_EYES)
		return
	if(obj_flags & (OBJ_EMPED | EMAGGED))
		start_glitch()

/obj/item/clothing/glasses/hud/dropped(mob/user)
	. = ..()
	stop_glitch()

/obj/item/clothing/glasses/hud/emp_act(severity)
	. = ..()
	if(obj_flags & OBJ_EMPED || . & EMP_PROTECT_SELF)
		return
	obj_flags |= OBJ_EMPED
	desc = "[desc] The display is flickering slightly."
	addtimer(CALLBACK(src, PROC_REF(reset_emp)), rand(1200 / severity, 600 / severity))
	//If we aren't glitching out already, start glitching
	if(!(obj_flags & EMAGGED))
		start_glitch()

/obj/item/clothing/glasses/hud/proc/reset_emp()
	obj_flags &= ~OBJ_EMPED
	//If we aren't emagged, stop glitching
	if(obj_flags & EMAGGED)
		return
	desc = initial(desc)
	stop_glitch()

/obj/item/clothing/glasses/hud/on_emag(mob/user)
	..()
	to_chat(user, span_warning("PZZTTPFFFT"))
	desc = "[desc] The display is flickering slightly."
	//If we aren't already glitching out, start glitching
	if(!(obj_flags & OBJ_EMPED))
		start_glitch()

/obj/item/clothing/glasses/hud/proc/start_glitch()
	if(ismob(loc))
		var/mob/M = loc
		//Remove old glitching hud
		if(glitching_hud)
			glitching_hud.transform = matrix()
			glitching_hud.filters = null
			glitching_hud.color = null
			glitching_hud = null
		//Get a new glitching hud
		glitching_hud = locate(/atom/movable/screen/plane_master/data_hud) in M.client?.screen

	START_PROCESSING(SSobj, src)

/obj/item/clothing/glasses/hud/proc/stop_glitch()
	if(glitching_hud)
		glitching_hud.transform = matrix()
		glitching_hud.filters = null
		glitching_hud.color = null
		glitching_hud = null

	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/glasses/hud/process(delta_time)
	if(!glitching_hud)
		return
	//Invert colours
	if(prob(35))
		var/colour_amount = -1
		glitching_hud.color = list(
			colour_amount, 0, 0,
			0, colour_amount, 0,
			0, 0, colour_amount,
			1, 1, 1
		)
	else if(prob(70))
		glitching_hud.color = null

	var/matrix/M = matrix()
	M.Translate(rand(-5, 5), rand(-1, 1))
	glitching_hud.transform = M
	glitching_hud.filters = filter(type="motion_blur", x=rand(1, 3))

/obj/item/clothing/glasses/hud/health
	name = "health scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	icon_state = "healthhud"
	emissive_state = "hud_emissive"
	clothing_traits = list(TRAIT_MEDICAL_HUD)
	glass_colour_type = /datum/client_colour/glass_colour/lightblue

/obj/item/clothing/glasses/hud/health/night
	name = "night vision health scanner HUD"
	desc = "An advanced medical head-up display that allows doctors to find patients in complete darkness."
	icon_state = "healthhudnight"
	emissive_state = "nvg_emissive"
	inhand_icon_state = "glasses"
	darkness_view = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	glass_colour_type = /datum/client_colour/glass_colour/green

/obj/item/clothing/glasses/hud/health/sunglasses
	gender = PLURAL
	name = "medical HUDSunglasses"
	desc = "Sunglasses with a medical HUD."
	icon_state = "sunhudmed"
	emissive_state = "sun_emissive"
	darkness_view = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1
	glass_colour_type = /datum/client_colour/glass_colour/blue

/obj/item/clothing/glasses/hud/health/prescription
	name = "prescription medical HUDglasses"
	desc = "Prescription glasses with a built-in medical HUD."
	icon_state = "prescmedhud"
	emissive_state = "prehud_emissive"
	vision_correction = 1

/obj/item/clothing/glasses/hud/health/sunglasses/degraded
	name = "degraded medical HUDSunglasses"
	desc = "Sunglasses with a medical HUD. They do not provide flash protection."
	flash_protect = FLASH_PROTECTION_NONE

/obj/item/clothing/glasses/hud/diagnostic
	name = "diagnostic HUD"
	desc = "A heads-up display capable of analyzing the integrity and status of robotics and exosuits."
	icon_state = "diagnostichud"
	emissive_state = "hud_emissive"
	clothing_traits = list(TRAIT_DIAGNOSTIC_HUD)
	glass_colour_type = /datum/client_colour/glass_colour/lightorange

/obj/item/clothing/glasses/hud/diagnostic/night
	name = "night vision diagnostic HUD"
	desc = "A robotics diagnostic HUD fitted with a light amplifier."
	icon_state = "diagnostichudnight"
	emissive_state = "nvg_emissive"
	inhand_icon_state = "glasses"
	darkness_view = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	glass_colour_type = /datum/client_colour/glass_colour/green

/obj/item/clothing/glasses/hud/diagnostic/sunglasses
	gender = PLURAL
	name = "diagnostic sunglasses"
	desc = "Sunglasses with a diagnostic HUD."
	icon_state = "sunhuddiag"
	emissive_state = "sun_emissive"
	inhand_icon_state = "glasses"
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1

/obj/item/clothing/glasses/hud/diagnostic/sunglasses/degraded
	name = "degraded diagnostic sunglasses"
	desc = "Sunglasses with a diagnostic HUD. They do not provide flash protection."
	flash_protect = FLASH_PROTECTION_NONE

/obj/item/clothing/glasses/hud/diagnostic/prescription
	name = "prescription diagnostic HUDglasses"
	desc = "Prescription glasses with a built-in diagnostic HUD."
	icon_state = "prescdiaghud"
	emissive_state = "prehud_emissive"
	vision_correction = 1

/obj/item/clothing/glasses/hud/security
	name = "security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"
	emissive_state = "hud_emissive"
	clothing_traits = list(TRAIT_SECURITY_HUD)
	glass_colour_type = /datum/client_colour/glass_colour/red

/obj/item/clothing/glasses/hud/security/deputy
	name = "deputy security HUD"
	icon_state = "sunhudtoggle"
	emissive_state = "sechud_emissive"

/obj/item/clothing/glasses/hud/medsec
	name = "health scanner security HUD"
	desc = "A combination HUD, providing the user the use of a Medical and Security HUD."
	icon_state = "medsechud"
	clothing_traits = list(TRAIT_SECURITY_HUD, TRAIT_MEDICAL_HUD)

	glass_colour_type = /datum/client_colour/glass_colour/red

/obj/item/clothing/glasses/hud/security/chameleon
	name = "chameleon security HUD"
	desc = "A stolen security HUD integrated with Syndicate chameleon technology. Provides flash protection."
	flash_protect = FLASH_PROTECTION_FLASH

	// Yes this code is the same as normal chameleon glasses, but we don't
	// have multiple inheritance, okay?
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/glasses/hud/security/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/glasses
	chameleon_action.chameleon_name = "Glasses"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/glasses/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/glasses/hud/security/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()


/obj/item/clothing/glasses/hud/security/sunglasses/eyepatch
	name = "eyepatch HUD"
	desc = "A heads-up display that connects directly to the optical nerve of the user, replacing the need for that useless eyeball."
	icon_state = "hudpatch"
	emissive_state = "hudpatch_emissive"

/obj/item/clothing/glasses/hud/security/sunglasses
	gender = PLURAL
	name = "security HUDSunglasses"
	desc = "Sunglasses with a security HUD."
	icon_state = "sunhudsec"
	emissive_state = "sechud_emissive"
	darkness_view = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1
	glass_colour_type = /datum/client_colour/glass_colour/darkred

/obj/item/clothing/glasses/hud/security/sunglasses/degraded
	name = "degraded security HUDSunglasses"
	desc = "Sunglasses with a security HUD. They do not provide flash protection."
	flash_protect = FLASH_PROTECTION_NONE

/obj/item/clothing/glasses/hud/security/night
	name = "night vision security HUD"
	desc = "An advanced heads-up display which provides id data and vision in complete darkness."
	icon_state = "securityhudnight"
	emissive_state = "nvg_emissive"
	darkness_view = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	glass_colour_type = /datum/client_colour/glass_colour/green

/obj/item/clothing/glasses/hud/security/prescription
	name = "prescription security HUDglasses"
	desc = "Prescription glasses with a built-in security HUD. They do not provide flash protection."
	icon_state = "prescsechud"
	emissive_state = "prehud_emissive"
	vision_correction = 1

/obj/item/clothing/glasses/hud/security/sunglasses/gars
	name = "\improper HUD gar glasses"
	desc = "GAR glasses with a HUD."
	icon_state = "gars"
	inhand_icon_state = "garb"
	force = 10
	throwforce = 10
	throw_speed = 4
	attack_verb_continuous = list("slices")
	attack_verb_simple = list("slice")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP
	bleed_force = BLEED_SURFACE

/obj/item/clothing/glasses/hud/security/sunglasses/gars/supergars
	name = "giga HUD gar glasses"
	desc = "GIGA GAR glasses with a HUD."
	icon_state = "supergars"
	inhand_icon_state = "garb"
	force = 12
	throwforce = 12

/obj/item/clothing/glasses/hud/toggle
	name = "Toggle HUD"
	desc = "A hud with multiple functions."
	icon_state = "togglehud"
	emissive_state = "hud_emissive"
	actions_types = list(/datum/action/item_action/switch_hud)

/obj/item/clothing/glasses/hud/toggle/attack_self(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/wearer = user
	if (wearer.glasses != src)
		return

	if (TRAIT_MEDICAL_HUD in clothing_traits)
		detach_clothing_traits(TRAIT_MEDICAL_HUD)
	else if (TRAIT_SECURITY_HUD in clothing_traits)
		detach_clothing_traits(TRAIT_MEDICAL_HUD)
		attach_clothing_traits(TRAIT_SECURITY_HUD)
	else
		detach_clothing_traits(TRAIT_MEDICAL_HUD)
		attach_clothing_traits(TRAIT_SECURITY_HUD)

/datum/action/item_action/switch_hud
	name = "Switch HUD"

/obj/item/clothing/glasses/hud/toggle/sunglasses
	name = "Toggle HUDSunglasses"
	desc = "Sunglasses with a Toggle HUD."
	icon_state = "sunhudtoggle"
	emissive_state = "sechud_emissive"

/obj/item/clothing/glasses/hud/toggle/thermal
	name = "thermal HUD scanner"
	desc = "Thermal imaging HUD in the shape of glasses."
	icon_state = "thermal"
	emissive_state = "meson_emissive"
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	glass_colour_type = /datum/client_colour/glass_colour/red
	clothing_traits = list(TRAIT_SECURITY_HUD)

/obj/item/clothing/glasses/hud/toggle/thermal/attack_self(mob/user)
	..()
	var/hud_type
	if (LAZYLEN(clothing_traits))
		hud_type = clothing_traits[1]
	switch (hud_type)
		if (TRAIT_MEDICAL_HUD)
			icon_state = "meson"
			change_glass_color(user, /datum/client_colour/glass_colour/green)
		if (TRAIT_SECURITY_HUD)
			icon_state = "thermal"
			change_glass_color(user, /datum/client_colour/glass_colour/red)
		else
			icon_state = "purple"
			change_glass_color(user, /datum/client_colour/glass_colour/purple)
	user.update_worn_glasses()

/obj/item/clothing/glasses/hud/toggle/thermal/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	thermal_overload()

/obj/item/clothing/glasses/hud/debug
	name = "Omni HUD"
	desc = "Glasses with every function."
	icon_state = "doublegodeye"
	inhand_icon_state = "doublegodeye"
	vision_flags = SEE_TURFS|SEE_MOBS|SEE_OBJS
	darkness_view = 8
	flash_protect = FLASH_PROTECTION_WELDER
	vision_correction = 1
	clothing_traits = list(TRAIT_MEDICAL_HUD, TRAIT_SECURITY_HUD, TRAIT_DIAGNOSTIC_HUD, TRAIT_BOT_PATH_HUD, TRAIT_BOOZE_SLIDER, TRAIT_REAGENT_SCANNER)
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	resistance_flags = INDESTRUCTIBLE
	actions_types = list(/datum/action/item_action/toggle,/datum/action/item_action/toggle_research_scanner)
	var/xray = TRUE

/obj/item/clothing/glasses/hud/debug/attack_self(mob/user)
	if(!ishuman(user))
		return
	if(xray)
		vision_flags -= SEE_MOBS|SEE_OBJS
		detach_clothing_traits(TRAIT_XRAY_VISION)
	else
		vision_flags += SEE_MOBS|SEE_OBJS
		attach_clothing_traits(TRAIT_XRAY_VISION)
	xray = !xray
	var/mob/living/carbon/human/wearer = user
	wearer.update_sight()
