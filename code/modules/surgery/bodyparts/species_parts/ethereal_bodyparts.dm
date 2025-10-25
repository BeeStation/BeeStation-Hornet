/obj/item/bodypart/head/ethereal
	icon_greyscale = 'icons/mob/species/ethereal/bodyparts.dmi'
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
	if(isethereal(owner))
		var/mob/living/carbon/human/potato_oc = owner
		var/datum/species/ethereal/eth_holder = potato_oc.dna.species
		species_color = eth_holder.current_color

/obj/item/bodypart/chest/ethereal
	icon_greyscale = 'icons/mob/species/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL
	is_dimorphic = FALSE
	dmg_overlay_type = null
	brute_modifier = 1.25 //ethereal are weak to brute damage
	wing_types = NONE

/obj/item/bodypart/chest/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(isethereal(owner))
		var/mob/living/carbon/human/potato_oc = owner
		var/datum/species/ethereal/eth_holder = potato_oc.dna.species
		species_color = eth_holder.current_color

/obj/item/bodypart/arm/left/ethereal
	icon_greyscale = 'icons/mob/species/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL
	dmg_overlay_type = null
	attack_type = BURN //burn bish
	unarmed_attack_verb = "burn"
	unarmed_attack_sound = 'sound/weapons/etherealhit.ogg'
	unarmed_miss_sound = 'sound/weapons/etherealmiss.ogg'
	brute_modifier = 1.25 //ethereal are weak to brute damage

/obj/item/bodypart/arm/left/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(isethereal(owner))
		var/mob/living/carbon/human/potato_oc = owner
		var/datum/species/ethereal/eth_holder = potato_oc.dna.species
		species_color = eth_holder.current_color

/obj/item/bodypart/arm/right/ethereal
	icon_greyscale = 'icons/mob/species/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL
	dmg_overlay_type = null
	attack_type = BURN // bish buzz
	unarmed_attack_verb = "burn"
	unarmed_attack_sound = 'sound/weapons/etherealhit.ogg'
	unarmed_miss_sound = 'sound/weapons/etherealmiss.ogg'
	brute_modifier = 1.25 //ethereal are weak to brute damage

/obj/item/bodypart/arm/right/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(isethereal(owner))
		var/mob/living/carbon/human/potato_oc = owner
		var/datum/species/ethereal/eth_holder = potato_oc.dna.species
		species_color = eth_holder.current_color

/obj/item/bodypart/leg/left/ethereal
	icon_greyscale = 'icons/mob/species/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL
	dmg_overlay_type = null
	attack_type = BURN // bish buzz
	unarmed_attack_sound = 'sound/weapons/etherealhit.ogg'
	unarmed_miss_sound = 'sound/weapons/etherealmiss.ogg'
	brute_modifier = 1.25 //ethereal are weak to brute damage

/obj/item/bodypart/leg/left/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(isethereal(owner))
		var/mob/living/carbon/human/potato_oc = owner
		var/datum/species/ethereal/eth_holder = potato_oc.dna.species
		species_color = eth_holder.current_color

/obj/item/bodypart/leg/right/ethereal
	icon_greyscale = 'icons/mob/species/ethereal/bodyparts.dmi'
	limb_id = SPECIES_ETHEREAL
	dmg_overlay_type = null
	attack_type = BURN // bish buzz
	unarmed_attack_sound = 'sound/weapons/etherealhit.ogg'
	unarmed_miss_sound = 'sound/weapons/etherealmiss.ogg'
	brute_modifier = 1.25 //ethereal are weak to brute damage

/obj/item/bodypart/leg/right/ethereal/update_limb(dropping_limb, is_creating)
	. = ..()
	if(isethereal(owner))
		var/mob/living/carbon/human/potato_oc = owner
		var/datum/species/ethereal/eth_holder = potato_oc.dna.species
		species_color = eth_holder.current_color
