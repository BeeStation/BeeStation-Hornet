/proc/generate_icon_with_head_accessory(datum/sprite_accessory/sprite_accessory)
	var/static/datum/universal_icon/head_icon
	if (isnull(head_icon))
		head_icon = uni_icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_head_m")
		head_icon.blend_color(skintone2hex("caucasian1"), ICON_MULTIPLY)

	var/datum/universal_icon/final_icon = head_icon.copy()
	if (!isnull(sprite_accessory) && sprite_accessory.icon_state != SPRITE_ACCESSORY_NONE)
		ASSERT(istype(sprite_accessory))

		var/datum/universal_icon/head_accessory_icon = uni_icon(sprite_accessory.icon, sprite_accessory.icon_state)
		head_accessory_icon.blend_color(COLOR_DARK_BROWN, ICON_MULTIPLY)
		final_icon.blend_icon(head_accessory_icon, ICON_OVERLAY)

	final_icon.crop(10, 19, 22, 31)
	final_icon.scale(32, 32)

	return final_icon

/datum/preference/color_legacy/eye_color
	db_key = "eye_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_head_flag = HEAD_EYECOLOR
	priority = PREFERENCE_PRIORITY_EYE_COLOR

/datum/preference/color_legacy/eye_color/apply_to_human(mob/living/carbon/human/target, value)
	if(isipc(target))
		return
	target.eye_color = value

	var/obj/item/organ/internal/eyes/eyes_organ = target.get_organ_by_type(/obj/item/organ/internal/eyes)
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
	relevant_head_flag = HEAD_FACIAL_HAIR
	preference_spritesheet = PREFERENCE_SHEET_LARGE

/datum/preference/choiced/facial_hairstyle/init_possible_values()
	return assoc_to_keys_features(GLOB.facial_hairstyles_list)

/datum/preference/choiced/facial_hairstyle/icon_for(value)
	return generate_icon_with_head_accessory(GLOB.facial_hairstyles_list[value])

/datum/preference/choiced/facial_hairstyle/apply_to_human(mob/living/carbon/human/target, value)
	target.facial_hairstyle = value
	target.update_body_parts()

/datum/preference/choiced/facial_hairstyle/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "facial_hair_color"

	return data

/datum/preference/color_legacy/facial_hair_color
	db_key = "facial_hair_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_head_flag = HEAD_FACIAL_HAIR

/datum/preference/color_legacy/facial_hair_color/apply_to_human(mob/living/carbon/human/target, value)
	target.set_facial_haircolor(value, update = TRUE)

/datum/preference/color_legacy/hair_color
	db_key = "hair_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_head_flag = HEAD_HAIR
	priority = PREFERENCE_PRIORITY_HAIR_COLOR

/datum/preference/color_legacy/hair_color/apply_to_human(mob/living/carbon/human/target, value)
	if(isipc(target))
		return
	target.set_haircolor(value, update = TRUE)

/datum/preference/color_legacy/hair_color/create_default_value()
	return pick(GLOB.natural_hair_colours)

/datum/preference/choiced/hairstyle
	db_key = "hair_style_name"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Hair Style"
	should_generate_icons = TRUE
	relevant_head_flag = HEAD_HAIR
	preference_spritesheet = PREFERENCE_SHEET_HUGE

/datum/preference/choiced/hairstyle/init_possible_values()
	return assoc_to_keys_features(GLOB.hairstyles_list)

/datum/preference/choiced/hairstyle/icon_for(value)
	return generate_icon_with_head_accessory(GLOB.hairstyles_list[value])

/datum/preference/choiced/hairstyle/apply_to_human(mob/living/carbon/human/target, value)
	target.set_hairstyle(value, update = TRUE)

/datum/preference/choiced/hairstyle/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "hair_color"

	return data

/datum/preference/choiced/hair_gradient
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	db_key = "gradient_style"
	relevant_head_flag = HEAD_HAIR

/datum/preference/choiced/hair_gradient/init_possible_values()
	return assoc_to_keys_features(GLOB.hair_gradients_list)

/datum/preference/choiced/hair_gradient/apply_to_human(mob/living/carbon/human/target, value)
	target.set_hair_gradient(new_style = value, update = TRUE)

/datum/preference/color_legacy/hair_gradient
	db_key = "gradient_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_head_flag = HEAD_HAIR

/datum/preference/color_legacy/hair_gradient/apply_to_human(mob/living/carbon/human/target, value)
	target.set_hair_gradient(new_color = value, update = TRUE)

/datum/preference/choiced/hair_gradient/create_default_value()
	return /datum/sprite_accessory/gradient/none::name
