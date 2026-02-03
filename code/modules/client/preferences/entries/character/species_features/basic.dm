/proc/generate_possible_values_for_sprite_accessories_on_head(accessories)
	var/list/values = possible_values_for_sprite_accessory_list(accessories)

	var/datum/universal_icon/head_icon = uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_head_m")
	head_icon.blend_color(skintone2hex("caucasian1", include_tag = TRUE), ICON_MULTIPLY)

	for (var/name in values)
		var/datum/sprite_accessory/accessory = accessories[name]
		if (accessory == null)
			continue

		var/datum/universal_icon/final_icon = head_icon.copy()

		if (accessory.icon_state == null)
			final_icon.crop(10, 19, 22, 31)
			final_icon.scale(32, 32)
			values[name] = final_icon
			continue

		var/datum/universal_icon/beard_icon = values[name]
		beard_icon.blend_color("#42250a", ICON_MULTIPLY)
		final_icon.blend_icon(beard_icon, ICON_OVERLAY)

		final_icon.crop(10, 19, 22, 31)
		final_icon.scale(32, 32)

		values[name] = final_icon

	return values

/datum/preference/color_legacy/eye_color
	db_key = "eye_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_species_trait = EYECOLOR
	priority = PREFERENCE_PRIORITY_EYE_COLOR

/datum/preference/color_legacy/eye_color/apply_to_human(mob/living/carbon/human/target, value)
	if(isipc(target))
		return
	target.eye_color = value

	var/obj/item/organ/eyes/eyes_organ = target.get_organ_by_type(/obj/item/organ/eyes)
	if (istype(eyes_organ))
		if (!initial(eyes_organ.eye_color))
			eyes_organ.eye_color = value
		eyes_organ.old_eye_color = value

/datum/preference/color_legacy/eye_color/create_default_value()
	return random_eye_color()

/datum/preference/choiced/facial_hairstyle
	db_key = "facial_style_name"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Facial Hair"
	should_generate_icons = TRUE
	relevant_species_trait = FACEHAIR
	preference_spritesheet = PREFERENCE_SHEET_LARGE
	informed = TRUE
	priority = PREFERENCE_PRIORITY_FACIAL_HAIR

/datum/preference/choiced/facial_hairstyle/init_possible_values()
	return generate_possible_values_for_sprite_accessories_on_head(GLOB.facial_hair_styles_list)

/datum/preference/choiced/facial_hairstyle/apply_to_human(mob/living/carbon/human/target, value)
	target.facial_hair_style = value

/datum/preference/choiced/facial_hairstyle/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "facial_hair_color"

	return data

/datum/preference/choiced/facial_hairstyle/create_informed_default_value(datum/preferences/preferences)
	var/gender = preferences.read_character_preference(/datum/preference/choiced/gender)
	var/datum/sprite_accessory/selected = pick_default_accessory(GLOB.facial_hair_styles_list, new /datum/sprite_accessory/facial_hair/shaved(), 30, required_gender = gender)
	return selected.name

/datum/preference/color_legacy/facial_hair_color
	db_key = "facial_hair_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_species_trait = FACEHAIR
	informed = TRUE
	priority = PREFERENCE_PRIORITY_FACIAL_COLOR

/datum/preference/color_legacy/facial_hair_color/apply_to_human(mob/living/carbon/human/target, value)
	target.facial_hair_color = value

/datum/preference/color_legacy/facial_hair_color/create_default_value()
	return pick(GLOB.natural_hair_colours)

/datum/preference/color_legacy/facial_hair_color/create_informed_default_value(datum/preferences/preferences)
	// By default, just match the hair colour
	// These are stricter than what is possible, since its a default not a restriction
	var/hair_colour = preferences.read_character_preference(/datum/preference/color_legacy/hair_color)
	return hair_colour

/datum/preference/color_legacy/hair_color
	db_key = "hair_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_species_trait = HAIR
	priority = PREFERENCE_PRIORITY_HAIR_COLOR
	informed = TRUE
	priority = PREFERENCE_PRIORITY_HAIR_COLOR

/datum/preference/color_legacy/hair_color/apply_to_human(mob/living/carbon/human/target, value)
	if(isipc(target))
		return
	target.hair_color = value

/datum/preference/color_legacy/hair_color/create_default_value()
	return pick(GLOB.natural_hair_colours)

/datum/preference/color_legacy/hair_color/create_informed_default_value(datum/preferences/preferences)
	// Create a character that looks relatively normal
	// Choose default hair colours for males, with females give a 10% chance for it to have
	// some dyed colours as the base colour.
	// All genders can get a dyed secondary hair colour for highlights
	// These are stricter than what is possible, since its a default not a restriction
	var/gender = preferences.read_character_preference(/datum/preference/choiced/gender)
	switch (gender)
		if (MALE)
			return pick(GLOB.natural_hair_colours)
		else
			if (prob(10))
				return pick(GLOB.female_dyed_hair_colours)
			return pick(GLOB.natural_hair_colours)

/datum/preference/choiced/hairstyle
	db_key = "hair_style_name"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Hair Style"
	should_generate_icons = TRUE
	relevant_species_trait = HAIR
	preference_spritesheet = PREFERENCE_SHEET_HUGE
	informed = TRUE
	priority = PREFERENCE_PRIORITY_HAIR_STYLE

/datum/preference/choiced/hairstyle/init_possible_values()
	return generate_possible_values_for_sprite_accessories_on_head(GLOB.hair_styles_list)

/datum/preference/choiced/hairstyle/apply_to_human(mob/living/carbon/human/target, value)
	target.hair_style = value

/datum/preference/choiced/hairstyle/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "hair_color"

	return data

/datum/preference/choiced/hairstyle/create_informed_default_value(datum/preferences/preferences)
	// Pick something not insane that might be considered by an average person to match the gender.
	// These are stricter than what is possible, since its a default not a restriction
	var/gender = preferences.read_character_preference(/datum/preference/choiced/gender)
	var/datum/sprite_accessory/picked = pick_default_accessory(GLOB.hair_styles_list, required_gender = gender)
	return picked.name

/datum/preference/choiced/gradient_style
	db_key = "gradient_style"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Gradient Style"
	should_generate_icons = TRUE
	relevant_species_trait = HAIR

/datum/preference/choiced/gradient_style/init_possible_values()
	var/list/values = possible_values_for_sprite_accessory_list(GLOB.hair_gradients_list)

	var/list/body_parts = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
	)
	var/datum/universal_icon/body_icon = uni_icon('icons/effects/effects.dmi', "nothing")
	for (var/body_part in body_parts)
		var/gender = body_part == BODY_ZONE_CHEST || body_part == BODY_ZONE_HEAD ? "_m" : ""
		body_icon.blend_icon(uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_[body_part][gender]", dir = NORTH), ICON_OVERLAY)
	body_icon.blend_color(skintone2hex("caucasian1", include_tag = TRUE), ICON_MULTIPLY)
	var/datum/universal_icon/jumpsuit_icon = uni_icon('icons/mob/clothing/under/color.dmi', "jumpsuit", dir = NORTH)
	jumpsuit_icon.blend_color("#b3b3b3", ICON_MULTIPLY)
	body_icon.blend_icon(jumpsuit_icon, ICON_OVERLAY)

	var/datum/sprite_accessory/hair_accessory = GLOB.hair_styles_list["Very Long Hair 2"]
	var/datum/universal_icon/hair_icon = uni_icon(hair_accessory.icon, hair_accessory.icon_state, dir = NORTH)
	hair_icon.blend_color("#080501", ICON_MULTIPLY)

	for (var/name in values)
		var/datum/sprite_accessory/accessory = GLOB.hair_gradients_list[name]
		if (accessory == null)
			if(accessory.icon_state == null || accessory.icon_state == "none")
				values[name] = uni_icon('icons/mob/landmarks.dmi', "x")
			continue

		var/datum/universal_icon/final_icon = body_icon.copy()
		var/datum/universal_icon/base_hair_icon = hair_icon.copy()
		var/datum/universal_icon/gradient_hair_icon = uni_icon(hair_accessory.icon, hair_accessory.icon_state, dir = NORTH)

		var/datum/universal_icon/gradient_icon = values[name]
		gradient_icon.blend_icon(gradient_hair_icon, ICON_ADD)
		gradient_icon.blend_color("#42250a", ICON_MULTIPLY)
		base_hair_icon.blend_icon(gradient_icon, ICON_OVERLAY)

		final_icon.blend_icon(base_hair_icon, ICON_OVERLAY)
		values[name] = final_icon

	return values

/datum/preference/choiced/gradient_style/apply_to_human(mob/living/carbon/human/target, value)
	target.gradient_style = value

/datum/preference/choiced/gradient_style/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "gradient_color"

	return data

/datum/preference/choiced/gradient_style/create_default_value()
	var/datum/sprite_accessory/accessory = pick_default_accessory(GLOB.hair_gradients_list)
	return accessory.name

/datum/preference/color_legacy/gradient_color
	db_key = "gradient_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_species_trait = HAIR
	informed = TRUE
	priority = PREFERENCE_PRIORITY_GRADIENT_COLOR

/datum/preference/color_legacy/gradient_color/apply_to_human(mob/living/carbon/human/target, value)
	target.gradient_color = value

/datum/preference/color_legacy/gradient_color/create_informed_default_value(datum/preferences/preferences)
	// Makes characters a bit more interesting if we have a lot of gradients
	if (prob(40))
		return preferences.read_character_preference(/datum/preference/color_legacy/hair_color)
	var/gender = preferences.read_character_preference(/datum/preference/choiced/gender)
	switch (gender)
		if (MALE)
			return pick(GLOB.secondary_dye_hair_colours)
		else
			return pick(GLOB.secondary_dye_hair_colours + GLOB.secondary_dye_female_hair_colours)
