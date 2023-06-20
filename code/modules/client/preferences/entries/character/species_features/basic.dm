/proc/generate_possible_values_for_sprite_accessories_on_head(accessories)
	var/list/values = possible_values_for_sprite_accessory_list(accessories)

	var/icon/head_icon = icon('icons/mob/human_parts_greyscale.dmi', "human_head_m")
	head_icon.Blend(skintone2hex("caucasian1", include_tag = TRUE), ICON_MULTIPLY)

	for (var/name in values)
		var/datum/sprite_accessory/accessory = accessories[name]
		if (accessory == null || accessory.icon_state == null)
			continue

		var/icon/final_icon = new(head_icon)

		var/icon/beard_icon = values[name]
		beard_icon.Blend("#42250a", ICON_MULTIPLY)
		final_icon.Blend(beard_icon, ICON_OVERLAY)

		final_icon.Crop(10, 19, 22, 31)
		final_icon.Scale(32, 32)

		values[name] = final_icon

	return values

/datum/preference/color_legacy/eye_color
	db_key = "eye_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_species_trait = EYECOLOR

/datum/preference/color_legacy/eye_color/apply_to_human(mob/living/carbon/human/target, value)
	target.eye_color = value

	var/obj/item/organ/eyes/eyes_organ = target.getorgan(/obj/item/organ/eyes)
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
	main_feature_name = "Facial hair"
	should_generate_icons = TRUE
	relevant_species_trait = FACEHAIR

/datum/preference/choiced/facial_hairstyle/init_possible_values()
	return generate_possible_values_for_sprite_accessories_on_head(GLOB.facial_hair_styles_list)

/datum/preference/choiced/facial_hairstyle/apply_to_human(mob/living/carbon/human/target, value)
	target.facial_hair_style = value

/datum/preference/choiced/facial_hairstyle/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "facial_hair_color"

	return data

/datum/preference/color_legacy/facial_hair_color
	db_key = "facial_hair_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_species_trait = FACEHAIR

/datum/preference/color_legacy/facial_hair_color/apply_to_human(mob/living/carbon/human/target, value)
	target.facial_hair_color = value

/datum/preference/color_legacy/hair_color
	db_key = "hair_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_species_trait = HAIR

/datum/preference/color_legacy/hair_color/apply_to_human(mob/living/carbon/human/target, value)
	target.hair_color = value

/datum/preference/color_legacy/hair_color/is_accessible(datum/preferences/preferences, ignore_page)
	if (!ignore_page && !should_show_on_page(preferences.current_window))
		return FALSE
	return ..() || ispath(preferences.read_character_preference(/datum/preference/choiced/species), /datum/species/ipc)

/datum/preference/choiced/hairstyle
	db_key = "hair_style_name"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Hairstyle"
	should_generate_icons = TRUE
	relevant_species_trait = HAIR

/datum/preference/choiced/hairstyle/init_possible_values()
	return generate_possible_values_for_sprite_accessories_on_head(GLOB.hair_styles_list)

/datum/preference/choiced/hairstyle/apply_to_human(mob/living/carbon/human/target, value)
	target.hair_style = value

/datum/preference/choiced/hairstyle/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "hair_color"

	return data

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
	var/icon/body_icon = icon('icons/effects/effects.dmi', "nothing")
	for (var/body_part in body_parts)
		var/gender = body_part == BODY_ZONE_CHEST || body_part == BODY_ZONE_HEAD ? "_m" : ""
		body_icon.Blend(icon('icons/mob/human_parts_greyscale.dmi', "human_[body_part][gender]", dir = NORTH), ICON_OVERLAY)
	body_icon.Blend(skintone2hex("caucasian1", include_tag = TRUE), ICON_MULTIPLY)
	var/icon/jumpsuit_icon = icon('icons/mob/clothing/uniform.dmi', "jumpsuit", dir = NORTH)
	jumpsuit_icon.Blend("#b3b3b3", ICON_MULTIPLY)
	body_icon.Blend(jumpsuit_icon, ICON_OVERLAY)

	var/datum/sprite_accessory/hair_accessory = GLOB.hair_styles_list["Very Long Hair 2"]
	var/icon/hair_icon = icon(hair_accessory.icon, hair_accessory.icon_state, dir = NORTH)
	hair_icon.Blend("#080501", ICON_MULTIPLY)

	for (var/name in values)
		var/datum/sprite_accessory/accessory = GLOB.hair_gradients_list[name]
		if (accessory == null || accessory.icon_state == null)
			continue

		var/icon/final_icon = new(body_icon)
		var/icon/base_hair_icon = new(hair_icon)
		var/icon/gradient_hair_icon = icon(hair_accessory.icon, hair_accessory.icon_state, dir = NORTH)

		var/icon/gradient_icon = values[name]
		gradient_icon.Blend(gradient_hair_icon, ICON_ADD)
		gradient_icon.Blend("#42250a", ICON_MULTIPLY)
		base_hair_icon.Blend(gradient_icon, ICON_OVERLAY)

		final_icon.Blend(base_hair_icon, ICON_OVERLAY)
		values[name] = final_icon

	return values

/datum/preference/choiced/gradient_style/apply_to_human(mob/living/carbon/human/target, value)
	target.gradient_style = value

/datum/preference/choiced/gradient_style/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "gradient_color"

	return data

/datum/preference/color_legacy/gradient_color
	db_key = "gradient_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_species_trait = HAIR

/datum/preference/color_legacy/gradient_color/apply_to_human(mob/living/carbon/human/target, value)
	target.gradient_color = value
