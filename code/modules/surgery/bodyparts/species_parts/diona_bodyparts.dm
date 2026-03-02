///Dionae Body parts, used to be podpeople
/obj/item/bodypart/head/diona
	icon_static = 'icons/mob/human/species/diona/bodyparts.dmi'
	icon = 'icons/mob/human/species/diona/bodyparts.dmi'
	icon_state = "diona_head"
	limb_id = SPECIES_DIONA
	is_dimorphic = FALSE
	bodypart_flags = BODYPART_UNREMOVABLE | BODYPART_PSEUDOPART
	head_flags = HEAD_EYECOLOR|HEAD_EYEHOLES|HEAD_DEBRAIN
	burn_modifier = 1.25
	brute_modifier = 0.8
	stamina_modifier = 0.7

/obj/item/bodypart/chest/diona
	icon_static = 'icons/mob/human/species/diona/bodyparts.dmi'
	icon = 'icons/mob/human/species/diona/bodyparts.dmi'
	icon_state = "diona_chest"
	limb_id = SPECIES_DIONA
	is_dimorphic = FALSE
	bodypart_flags = BODYPART_PSEUDOPART
	burn_modifier = 1.25
	brute_modifier = 0.8
	stamina_modifier = 0.7

/obj/item/bodypart/arm/left/diona
	icon_static = 'icons/mob/human/species/diona/bodyparts.dmi'
	icon = 'icons/mob/human/species/diona/bodyparts.dmi'
	icon_state = "diona_l_arm"
	limb_id = SPECIES_DIONA
	bodypart_flags = BODYPART_PSEUDOPART
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/emotes/diona/hit.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	burn_modifier = 1.25
	brute_modifier = 0.8
	stamina_modifier = 0.7

/obj/item/bodypart/arm/right/diona
	icon_static = 'icons/mob/human/species/diona/bodyparts.dmi'
	icon = 'icons/mob/human/species/diona/bodyparts.dmi'
	icon_state = "diona_r_arm"
	limb_id = SPECIES_DIONA
	bodypart_flags = BODYPART_PSEUDOPART
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/emotes/diona/hit.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	burn_modifier = 1.25
	brute_modifier = 0.8
	stamina_modifier = 0.7

/obj/item/bodypart/leg/left/diona
	icon_static = 'icons/mob/human/species/diona/bodyparts.dmi'
	icon = 'icons/mob/human/species/diona/bodyparts.dmi'
	icon_state = "diona_l_leg"
	limb_id = SPECIES_DIONA
	bodypart_flags = BODYPART_PSEUDOPART
	movespeed_contribution = 0.6 // Dionae are slow.
	burn_modifier = 1.25
	brute_modifier = 0.8
	stamina_modifier = 0.7

/obj/item/bodypart/leg/right/diona
	icon_static = 'icons/mob/human/species/diona/bodyparts.dmi'
	icon = 'icons/mob/human/species/diona/bodyparts.dmi'
	icon_state = "diona_r_leg"
	limb_id = SPECIES_DIONA
	bodypart_flags = BODYPART_PSEUDOPART
	movespeed_contribution = 0.6 // Dionae are slow.
	burn_modifier = 1.25
	brute_modifier = 0.8
	stamina_modifier = 0.7
