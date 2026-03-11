/datum/species/koa
	name = "\improper Koa"
	plural_form = "Koa"
	id = SPECIES_KOA
	meat = /obj/item/food/meat/slab/monkey
	species_language_holder = /datum/language_holder/koa
	allow_numbers_in_name = TRUE

	offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,-1), OFFSET_EARS = list(0,0), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,0), OFFSET_HEAD = list(0,0), OFFSET_FACE = list(0,0), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0), OFFSET_RIGHT_HAND = list(0,0), OFFSET_LEFT_HAND = list(0,0))


	forced_features = list("ears" = "Koala")
	species_traits = list(
		NO_UNDERWEAR,
		NOEYESPRITES,
		EYECOLOR,
		LIPS,
		NOSOCKS,
		MUTCOLORS,
	)

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/koa,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/koa,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/koa,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/koa,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/koa,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/koa
	)

	mutant_organs = list(/obj/item/organ/ears/koala)

	species_height = SPECIES_HEIGHTS(8, 8, 8)
	height_icon_state = "height_displacement_koa"

	var/mob/living/carbon/holder

/datum/species/koa/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.pass_flags = PASSTABLE
	C.dna.features["ears"] = "Koala" //Defaults to Cat otherwise
	holder = C
	//TODO: See proc below - Racc
	//RegisterSignal(C, COMSIG_MOB_ITEM_AFTERATTACK_SECONDARY, PROC_REF(catch_secondary_attack))

/datum/species/koa/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	holder = null

/datum/species/koa/get_item_offsets_for_index(obj/item/I)
	var/index = holder?.get_held_index_of_item(I)
	switch(index)
		if(3)
			return list(0, 0)
		if(4)
			return list(0, 0)
		else
			return

//TODO: Remove after TM - Racc
/datum/species/koa/check_roundstart_eligible()
	. = ..()
	return TRUE

/datum/species/koa/get_species_description()
	return "Koa are a race of intelligent quadribrachials, four armed beings. Koa use their lower arms to 'walk', but they can also hold and manipulate items while doing so."

//TODO: Write some up - Racc
/datum/species/koa/get_species_lore()
	return list(
		"Awful, big eyes.",
	)

/datum/species/koa/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "hand",
			SPECIES_PERK_NAME = "Hand Feet",
			SPECIES_PERK_DESC = "Koa feet are unlike any other species'. Resembling a pair of hands, siminian feet don't comfortably fit into most shoes.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "hand",
			SPECIES_PERK_NAME = "Flexible Feet",
			SPECIES_PERK_DESC = "Koa feet are flexible like hands. This allows them to hold and use items.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "Nimble",
			SPECIES_PERK_DESC = "Koa are small and nimble. They can leap over tables with ease.",
		),
	)

	return to_add

/* TODO: This probably isn't cool - Racc
//TODO: Attack damage is halved, but both arm sets attack at once - Racc
/datum/species/koa/proc/catch_secondary_attack(datum/source, atom/target, obj/item/weapon, proximity_flag, click_parameters)
//Go through the motions to acquire a secondary item
	var/mob/living/carbon/user = source
	var/index = user.get_held_index_of_item(weapon)
	index = index <= 2 ? index+2 : index-2
	var/obj/item/secondary_item = user.get_item_for_held_index(index)
//Flight checks
	//Don't let them do weird hand shit
	if(!secondary_item)
		return
	var/obj/item/gun/gun = secondary_item
	if(istype(gun) || !gun.can_shoot()) //Guns are restricted to your gun length
		gun.pull_trigger(target, user)
		return
	else if(!user.CanReach(target, secondary_item)) //Knives are restricted to your arm length
		return
//Dew it
	secondary_item.melee_attack_chain(user, target)
*/
