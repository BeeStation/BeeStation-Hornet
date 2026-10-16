/// getter for ethereal color. needs an electric stomach and an ethereal core to work
/obj/item/bodypart/proc/get_ethereal_color(mob/living/carbon/carbon)
	var/obj/item/organ/heart/ethereal/core = carbon.get_organ_slot(ORGAN_SLOT_HEART)
	return istype(core) ? core.get_body_color() : COLOR_GRAY

/obj/item/bodypart/head/ethereal
	icon_greyscale = 'icons/mob/human/species/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL
	is_dimorphic = FALSE
	dmg_overlay_type = null
	attack_type = BURN // bish buzz
	unarmed_attack_sound = 'sound/weapons/etherealhit.ogg'
	unarmed_miss_sound = 'sound/weapons/etherealmiss.ogg'
	brute_modifier = 1.25 //ethereal are weak to brute damage
	head_flags = HEAD_HAIR|HEAD_FACIAL_HAIR|HEAD_EYESPRITES|HEAD_EYEHOLES|HEAD_DEBRAIN

/obj/item/bodypart/head/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(owner)
		species_color = get_ethereal_color(owner)

/obj/item/bodypart/chest/ethereal
	icon_greyscale = 'icons/mob/human/species/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL
	is_dimorphic = FALSE
	dmg_overlay_type = null
	brute_modifier = 1.25 //ethereal are weak to brute damage
	bodypart_traits = list(TRAIT_NO_UNDERWEAR)

/obj/item/bodypart/chest/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(owner)
		species_color = get_ethereal_color(owner)

/obj/item/bodypart/arm/left/ethereal
	icon_greyscale = 'icons/mob/human/species/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL
	dmg_overlay_type = null
	attack_type = BURN //burn bish
	unarmed_attack_verb = "burn"
	unarmed_attack_sound = 'sound/weapons/etherealhit.ogg'
	unarmed_miss_sound = 'sound/weapons/etherealmiss.ogg'
	brute_modifier = 1.25 //ethereal are weak to brute damage

/obj/item/bodypart/arm/left/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(owner)
		species_color = get_ethereal_color(owner)

/obj/item/bodypart/arm/right/ethereal
	icon_greyscale = 'icons/mob/human/species/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL
	dmg_overlay_type = null
	attack_type = BURN // bish buzz
	unarmed_attack_verb = "burn"
	unarmed_attack_sound = 'sound/weapons/etherealhit.ogg'
	unarmed_miss_sound = 'sound/weapons/etherealmiss.ogg'
	brute_modifier = 1.25 //ethereal are weak to brute damage

/obj/item/bodypart/arm/right/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(owner)
		species_color = get_ethereal_color(owner)

/obj/item/bodypart/leg/left/ethereal
	icon_greyscale = 'icons/mob/human/species/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL
	dmg_overlay_type = null
	attack_type = BURN // bish buzz
	unarmed_attack_sound = 'sound/weapons/etherealhit.ogg'
	unarmed_miss_sound = 'sound/weapons/etherealmiss.ogg'
	brute_modifier = 1.25 //ethereal are weak to brute damage

/obj/item/bodypart/leg/left/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(owner)
		species_color = get_ethereal_color(owner)

/obj/item/bodypart/leg/right/ethereal
	icon_greyscale = 'icons/mob/human/species/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL
	dmg_overlay_type = null
	attack_type = BURN // bish buzz
	unarmed_attack_sound = 'sound/weapons/etherealhit.ogg'
	unarmed_miss_sound = 'sound/weapons/etherealmiss.ogg'
	brute_modifier = 1.25 //ethereal are weak to brute damage

/obj/item/bodypart/leg/right/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(owner)
		species_color = get_ethereal_color(owner)
