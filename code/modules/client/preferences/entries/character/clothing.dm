/proc/generate_underwear_icon(datum/sprite_accessory/accessory, datum/universal_icon/base_icon, color)
	var/datum/universal_icon/final_icon = base_icon.copy()

	if (!isnull(accessory))
		var/datum/universal_icon/accessory_icon = uni_icon('icons/mob/clothing/underwear.dmi', accessory.icon_state)
		if (color && !accessory.use_static)
			accessory_icon.blend_color(color, ICON_MULTIPLY)
		final_icon.blend_icon(accessory_icon, ICON_OVERLAY)

	final_icon.crop(10, 1, 22, 13)
	final_icon.scale(32, 32)

	return final_icon

/// Backpack preference
/datum/preference/choiced/backpack
	db_key = "backbag"
	preference_type = PREFERENCE_CHARACTER
	main_feature_name = "Backpack"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE

/datum/preference/choiced/backpack/init_possible_values()
	return list(
		GBACKPACK,
		GSATCHEL,
		LSATCHEL,
		GDUFFELBAG,
		DBACKPACK,
		DSATCHEL,
		DDUFFELBAG,
	)

/datum/preference/choiced/backpack/create_default_value()
	return GBACKPACK

/datum/preference/choiced/backpack/icon_for(value)
	switch (value)
		if (GBACKPACK)
			return /obj/item/storage/backpack
		if (GSATCHEL)
			return /obj/item/storage/backpack/satchel
		if (LSATCHEL)
			return /obj/item/storage/backpack/satchel/leather
		if (GDUFFELBAG)
			return /obj/item/storage/backpack/duffelbag

		// In a perfect world, these would be your department's backpack.
		// However, this doesn't factor in assistants, or no high slot, and would
		// also increase the spritesheet size a lot.
		// I play medical doctor, and so medical doctor you get.
		if (DBACKPACK)
			return /obj/item/storage/backpack/medic
		if (DSATCHEL)
			return /obj/item/storage/backpack/satchel/med
		if (DDUFFELBAG)
			return /obj/item/storage/backpack/duffelbag/med

/datum/preference/choiced/backpack/apply_to_human(mob/living/carbon/human/target, value)
	target.backbag = value

/datum/preference/choiced/backpack/create_default_value()
	return DBACKPACK

/// Jumpsuit preference
/datum/preference/choiced/jumpsuit_style
	db_key = "jumpsuit_style"
	preference_type = PREFERENCE_CHARACTER
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	main_feature_name = "Jumpsuit"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE
	informed = TRUE
	priority = PREFERENCE_PRIORITY_JUMPSUIT

/datum/preference/choiced/jumpsuit_style/init_possible_values()
	return list(
		PREF_SUIT,
		PREF_SKIRT,
	)

/datum/preference/choiced/jumpsuit_style/icon_for(value)
	switch (value)
		if (PREF_SUIT)
			return /obj/item/clothing/under/color/grey
		if (PREF_SKIRT)
			return /obj/item/clothing/under/color/jumpskirt/grey

/datum/preference/choiced/jumpsuit_style/apply_to_human(mob/living/carbon/human/target, value)
	target.jumpsuit_style = value

/datum/preference/choiced/jumpsuit_style/create_default_value()
	return PREF_SUIT
/*
/datum/preference/choiced/jumpsuit_style/create_informed_default_value(datum/preferences/preferences)
	var/gender = preferences.read_character_preference(/datum/preference/choiced/gender)
	if (gender == MALE)
		return PREF_SUIT
	return pick(PREF_SUIT, PREF_SKIRT)
*/
/// Socks preference
/datum/preference/choiced/socks
	db_key = "socks"
	preference_type = PREFERENCE_CHARACTER
	main_feature_name = "Socks"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE
	preference_spritesheet = PREFERENCE_SHEET_LARGE
	can_randomize = FALSE

/datum/preference/choiced/socks/init_possible_values()
	return assoc_to_keys_features(SSaccessories.socks_list)

/datum/preference/choiced/socks/create_default_value()
	return /datum/sprite_accessory/socks/nude::name

/datum/preference/choiced/socks/create_informed_default_value(datum/preferences/preferences)
	var/gender = preferences.read_character_preference(/datum/preference/choiced/gender)
	return random_socks(gender)

/datum/preference/choiced/socks/icon_for(value)
	var/static/datum/universal_icon/lower_half

	if (isnull(lower_half))
		lower_half = uni_icon('icons/blanks/32x32.dmi', "nothing")
		lower_half.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_r_leg"), ICON_OVERLAY)
		lower_half.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_l_leg"), ICON_OVERLAY)

	return generate_underwear_icon(SSaccessories.socks_list[value], lower_half)

/datum/preference/choiced/socks/apply_to_human(mob/living/carbon/human/target, value)
	target.socks = value

/// Undershirt preference
/datum/preference/choiced/undershirt
	db_key = "undershirt"
	preference_type = PREFERENCE_CHARACTER
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	main_feature_name = "Undershirt"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE
	preference_spritesheet = PREFERENCE_SHEET_LARGE
	can_randomize = FALSE

/datum/preference/choiced/undershirt/init_possible_values()
	return assoc_to_keys_features(SSaccessories.undershirt_list)

/datum/preference/choiced/undershirt/create_default_value()
	return /datum/sprite_accessory/undershirt/nude::name

/datum/preference/choiced/undershirt/create_informed_default_value(datum/preferences/preferences)
	switch(preferences.read_preference(/datum/preference/choiced/gender))
		if(MALE)
			return /datum/sprite_accessory/undershirt/nude::name
		if(FEMALE)
			return /datum/sprite_accessory/undershirt/sports_bra::name

	return ..()

/datum/preference/choiced/undershirt/icon_for(value)
	var/static/datum/universal_icon/body
	if (isnull(body))
		body = uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_r_leg")
		body.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_l_leg"), ICON_OVERLAY)
		body.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_r_arm"), ICON_OVERLAY)
		body.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_l_arm"), ICON_OVERLAY)
		body.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_r_hand"), ICON_OVERLAY)
		body.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_l_hand"), ICON_OVERLAY)
		body.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_chest_m"), ICON_OVERLAY)

	var/datum/universal_icon/icon_with_undershirt = body.copy()

	if (value != "Nude")
		var/datum/sprite_accessory/accessory = SSaccessories.undershirt_list[value]
		icon_with_undershirt.blend_icon(uni_icon('icons/mob/clothing/underwear.dmi', accessory.icon_state), ICON_OVERLAY)

	icon_with_undershirt.crop(9, 9, 23, 23)
	icon_with_undershirt.scale(32, 32)
	return icon_with_undershirt

/datum/preference/choiced/undershirt/apply_to_human(mob/living/carbon/human/target, value)
	target.undershirt = value

/datum/preference/choiced/undershirt/create_informed_default_value(datum/preferences/preferences)
	var/gender = preferences.read_character_preference(/datum/preference/choiced/gender)
	return random_undershirt(gender)

/// Underwear preference
/datum/preference/choiced/underwear
	db_key = "underwear"
	preference_type = PREFERENCE_CHARACTER
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	main_feature_name = "Underwear"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE
	preference_spritesheet = PREFERENCE_SHEET_LARGE
	can_randomize = FALSE

/datum/preference/choiced/underwear/init_possible_values()
	return assoc_to_keys_features(SSaccessories.underwear_list)

/datum/preference/choiced/underwear/create_default_value()
	return /datum/sprite_accessory/underwear/male_hearts::name

/datum/preference/choiced/underwear/create_informed_default_value(datum/preferences/preferences)
	var/species_type = preferences.read_preference(/datum/preference/choiced/species)
	// No conflict with digilegs
	if(species_type == /datum/species/lizard)
		return /datum/sprite_accessory/underwear/nude::name

	var/gender = preferences.read_preference(/datum/preference/choiced/gender)
	var/datum/sprite_accessory/picked_underwear = pick_default_accessory(SSaccessories.underwear_list, null, 0, gender)
	if(!picked_underwear)
		return ..()
	return picked_underwear?.name

/datum/preference/choiced/underwear/icon_for(value)
	var/static/datum/universal_icon/lower_half

	if (isnull(lower_half))
		lower_half = uni_icon('icons/blanks/32x32.dmi', "nothing")
		lower_half.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_chest_m"), ICON_OVERLAY)
		lower_half.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_r_leg"), ICON_OVERLAY)
		lower_half.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_l_leg"), ICON_OVERLAY)

	return generate_underwear_icon(SSaccessories.underwear_list[value], lower_half, COLOR_ALMOST_BLACK)

/datum/preference/choiced/underwear/apply_to_human(mob/living/carbon/human/target, value)
	target.underwear = value

/datum/preference/choiced/underwear/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if (!..())
		return FALSE

	var/species_type = preferences.read_character_preference(/datum/preference/choiced/species)
	var/datum/species/species = GLOB.species_prototypes[species_type]
	return !(TRAIT_NO_UNDERWEAR in species.inherent_traits)

/datum/preference/choiced/underwear/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "underwear_color"

	return data
