/proc/generate_values_for_underwear(list/accessory_list, list/icons, color)
	var/datum/universal_icon/lower_half = uni_icon('icons/effects/effects.dmi', "nothing")

	for (var/icon in icons)
		lower_half.blend_icon(uni_icon('icons/mob/species/human/bodyparts_greyscale.dmi', icon), ICON_OVERLAY)

	var/list/values = list()

	for (var/accessory_name in accessory_list)
		var/datum/universal_icon/icon_with_socks = lower_half.copy()

		var/datum/sprite_accessory/accessory = accessory_list[accessory_name]
		if (accessory.icon_state != null)
			var/datum/universal_icon/accessory_icon = uni_icon('icons/mob/clothing/underwear.dmi', accessory.icon_state)
			if (color && !accessory.use_static)
				accessory_icon.blend_color(color, ICON_MULTIPLY)
			icon_with_socks.blend_icon(accessory_icon, ICON_OVERLAY)

		icon_with_socks.crop(10, 1, 22, 13)
		icon_with_socks.scale(32, 32)

		values[accessory_name] = icon_with_socks

	return values

/// Backpack preference
/datum/preference/choiced/backpack
	db_key = "backbag"
	preference_type = PREFERENCE_CHARACTER
	main_feature_name = "Backpack"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE

/datum/preference/choiced/backpack/init_possible_values()
	var/list/values = list()

	values[GBACKPACK] = /obj/item/storage/backpack
	values[GSATCHEL] = /obj/item/storage/backpack/satchel
	values[LSATCHEL] = /obj/item/storage/backpack/satchel/leather
	values[GDUFFELBAG] = /obj/item/storage/backpack/duffelbag

	// In a perfect world, these would be your department's backpack.
	// However, this doesn't factor in assistants, or no high slot, and would
	// also increase the spritesheet size a lot.
	// I play medical doctor, and so medical doctor you get.
	values[DBACKPACK] = /obj/item/storage/backpack/medic
	values[DSATCHEL] = /obj/item/storage/backpack/satchel/med
	values[DDUFFELBAG] = /obj/item/storage/backpack/duffelbag/med

	return values

/datum/preference/choiced/backpack/apply_to_human(mob/living/carbon/human/target, value)
	target.backbag = value

/datum/preference/choiced/backpack/create_default_value()
	return DBACKPACK

/// Jumpsuit preference
/datum/preference/choiced/jumpsuit_style
	db_key = "jumpsuit_style"
	preference_type = PREFERENCE_CHARACTER
	main_feature_name = "Jumpsuit"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE
	informed = TRUE
	priority = PREFERENCE_PRIORITY_JUMPSUIT

/datum/preference/choiced/jumpsuit_style/init_possible_values()
	var/list/values = list()

	values[PREF_SUIT] = /obj/item/clothing/under/color/grey
	values[PREF_SKIRT] = /obj/item/clothing/under/color/jumpskirt/grey

	return values

/datum/preference/choiced/jumpsuit_style/apply_to_human(mob/living/carbon/human/target, value)
	target.jumpsuit_style = value

/datum/preference/choiced/jumpsuit_style/create_informed_default_value(datum/preferences/preferences)
	var/gender = preferences.read_character_preference(/datum/preference/choiced/gender)
	if (gender == MALE)
		return PREF_SUIT
	return pick(PREF_SUIT, PREF_SKIRT)

/// Socks preference
/datum/preference/choiced/socks
	db_key = "socks"
	preference_type = PREFERENCE_CHARACTER
	main_feature_name = "Socks"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE
	preference_spritesheet = PREFERENCE_SHEET_LARGE
	informed = TRUE
	priority = PREFERENCE_PRIORITY_SOCKS

/datum/preference/choiced/socks/init_possible_values()
	return generate_values_for_underwear(GLOB.socks_list, list("human_r_leg", "human_l_leg"))

/datum/preference/choiced/socks/apply_to_human(mob/living/carbon/human/target, value)
	target.socks = value

/datum/preference/choiced/socks/create_informed_default_value(datum/preferences/preferences)
	var/gender = preferences.read_character_preference(/datum/preference/choiced/gender)
	return random_socks(gender)

/// Undershirt preference
/datum/preference/choiced/undershirt
	db_key = "undershirt"
	preference_type = PREFERENCE_CHARACTER
	main_feature_name = "Undershirt"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE
	preference_spritesheet = PREFERENCE_SHEET_LARGE
	informed = TRUE
	priority = PREFERENCE_PRIORITY_UNDERSHIRT

/datum/preference/choiced/undershirt/init_possible_values()
	var/datum/universal_icon/body = uni_icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_r_leg")
	body.blend_icon(uni_icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_l_leg"), ICON_OVERLAY)
	body.blend_icon(uni_icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_r_arm"), ICON_OVERLAY)
	body.blend_icon(uni_icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_l_arm"), ICON_OVERLAY)
	body.blend_icon(uni_icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_r_hand"), ICON_OVERLAY)
	body.blend_icon(uni_icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_l_hand"), ICON_OVERLAY)
	body.blend_icon(uni_icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_chest_m"), ICON_OVERLAY)

	var/list/values = list()

	for (var/accessory_name in GLOB.undershirt_list)
		var/datum/universal_icon/icon_with_undershirt = body.copy()

		var/datum/sprite_accessory/accessory = GLOB.undershirt_list[accessory_name]
		if (accessory.icon_state != null)
			icon_with_undershirt.blend_icon(uni_icon('icons/mob/clothing/underwear.dmi', accessory.icon_state), ICON_OVERLAY)

		icon_with_undershirt.crop(9, 9, 23, 23)
		icon_with_undershirt.scale(32, 32)
		values[accessory_name] = icon_with_undershirt

	return values

/datum/preference/choiced/undershirt/apply_to_human(mob/living/carbon/human/target, value)
	target.undershirt = value

/datum/preference/choiced/undershirt/create_informed_default_value(datum/preferences/preferences)
	var/gender = preferences.read_character_preference(/datum/preference/choiced/gender)
	return random_undershirt(gender)

/// Underwear preference
/datum/preference/choiced/underwear
	db_key = "underwear"
	preference_type = PREFERENCE_CHARACTER
	main_feature_name = "Underwear"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE
	preference_spritesheet = PREFERENCE_SHEET_LARGE
	informed = TRUE
	priority = PREFERENCE_PRIORITY_UNDERWEAR

/datum/preference/choiced/underwear/init_possible_values()
	return generate_values_for_underwear(GLOB.underwear_list, list("human_chest_m", "human_r_leg", "human_l_leg"), COLOR_ALMOST_BLACK)

/datum/preference/choiced/underwear/apply_to_human(mob/living/carbon/human/target, value)
	target.underwear = value

/datum/preference/choiced/underwear/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if (!..())
		return FALSE

	var/species_type = preferences.read_character_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type
	return !(NO_UNDERWEAR in species.species_traits)

/datum/preference/choiced/underwear/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "underwear_color"

	return data

/datum/preference/choiced/underwear/create_informed_default_value(datum/preferences/preferences)
	var/gender = preferences.read_character_preference(/datum/preference/choiced/gender)
	return random_underwear(gender)
