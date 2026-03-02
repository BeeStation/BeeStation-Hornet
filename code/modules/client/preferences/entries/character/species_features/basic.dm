/proc/generate_icon_with_head_accessory(datum/sprite_accessory/sprite_accessory)
	var/static/datum/universal_icon/head_icon
	if (isnull(head_icon))
		head_icon = uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_head_m")
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

/datum/preference/color/eye_color
	db_key = "eye_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_head_flag = HEAD_EYECOLOR
	priority = PREFERENCE_PRIORITY_EYE_COLOR

/datum/preference/color/eye_color/apply_to_human(mob/living/carbon/human/target, value)
	if(isipc(target))
		return
	target.eye_color = value

	var/obj/item/organ/eyes/eyes_organ = target.get_organ_by_type(/obj/item/organ/eyes)
	if (istype(eyes_organ))
		if (!initial(eyes_organ.eye_color))
			eyes_organ.eye_color = value
		eyes_organ.old_eye_color = value

/datum/preference/color/eye_color/create_default_value()
	return random_eye_color()

/datum/preference/choiced/facial_hairstyle
	priority = PREFERENCE_PRIORITY_LATE_BODY_TYPE
	db_key = "facial_style_name"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Facial Hair"
	should_generate_icons = TRUE
	relevant_head_flag = HEAD_FACIAL_HAIR
	preference_spritesheet = PREFERENCE_SHEET_LARGE

/datum/preference/choiced/facial_hairstyle/init_possible_values()
	return assoc_to_keys_features(SSaccessories.facial_hairstyles_list)

/datum/preference/choiced/facial_hairstyle/icon_for(value)
	return generate_icon_with_head_accessory(SSaccessories.facial_hairstyles_list[value])

/datum/preference/choiced/facial_hairstyle/apply_to_human(mob/living/carbon/human/target, value)
	target.set_facial_hairstyle(value, update = FALSE)

/datum/preference/choiced/facial_hairstyle/create_default_value()
	return /datum/sprite_accessory/facial_hair/shaved::name

/datum/preference/choiced/facial_hairstyle/create_informed_default_value(datum/preferences/preferences)
	var/gender = preferences.read_preference(/datum/preference/choiced/gender)
	var/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/datum/species/species_real = GLOB.species_prototypes[species_type]
	if(!gender || !species_real || !species_real.sexes)
		return ..()

	var/datum/sprite_accessory/picked_beard = pick_default_accessory(SSaccessories.facial_hairstyles_list, null, 0, gender)
	if(!picked_beard)
		return ..()
	if(picked_beard?.locked) // Invalid, go with god(bald)
		return ..()

	return picked_beard?.name

/datum/preference/choiced/facial_hairstyle/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/color/facial_hair_color::db_key

	return data

/datum/preference/color/facial_hair_color
	priority = PREFERENCE_PRIORITY_FACIAL_COLOR // Need to happen after hair color is set so we can match by default
	db_key = "facial_hair_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_head_flag = HEAD_FACIAL_HAIR

/datum/preference/color/facial_hair_color/apply_to_human(mob/living/carbon/human/target, value)
	target.set_facial_haircolor(value, update = TRUE)

/datum/preference/color/facial_hair_color/create_informed_default_value(datum/preferences/preferences)
	return preferences.read_preference(/datum/preference/color/hair_color) || random_hair_color()

/*
/datum/preference/choiced/facial_hair_gradient
	priority = PREFERENCE_PRIORITY_LATE_BODY_TYPE
	category = PREFERENCE_CATEGORY_FEATURES
	preference_type = PREFERENCE_CHARACTER
	db_key = "facial_hair_gradient"
	main_feature_name = "Facial Hair Gradient"
	relevant_head_flag = HEAD_FACIAL_HAIR
	can_randomize = FALSE
	should_generate_icons = TRUE
	//temporary fix
	disable_serialization = TRUE

/datum/preference/choiced/facial_hair_gradient/init_possible_values()
	return assoc_to_keys_features(SSaccessories.facial_hair_gradients_list)

/datum/preference/choiced/facial_hair_gradient/apply_to_human(mob/living/carbon/human/target, value)
	target.set_facial_hair_gradient_style(new_style = value, update = FALSE)

/datum/preference/choiced/facial_hair_gradient/icon_for(value)
	var/datum/sprite_accessory/gradient_accessory = SSaccessories.facial_hair_gradients_list[value]
	if (!gradient_accessory || gradient_accessory.icon_state == "none")
		return uni_icon('icons/mob/landmarks.dmi', "x")

	// Create base head
	var/datum/universal_icon/final_icon = uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_head_m")
	final_icon.blend_color(skintone2hex("caucasian1"), ICON_MULTIPLY)

	// Use a standard facial hair style for the preview
	var/datum/sprite_accessory/facial_hair_accessory = SSaccessories.facial_hairstyles_list["Beard (Full)"] || SSaccessories.facial_hairstyles_list["Beard (Cropped Fullbeard)"]
	if (facial_hair_accessory)
		var/datum/universal_icon/base_facial_hair_icon = uni_icon(facial_hair_accessory.icon, facial_hair_accessory.icon_state)
		base_facial_hair_icon.blend_color("#080501", ICON_MULTIPLY)

		// Create gradient overlay
		var/datum/universal_icon/gradient_icon = uni_icon(facial_hair_accessory.icon, facial_hair_accessory.icon_state)
		gradient_icon.blend_icon(uni_icon(gradient_accessory.icon, gradient_accessory.icon_state), ICON_ADD)
		gradient_icon.blend_color("#42250a", ICON_MULTIPLY)

		// Combine base facial hair with gradient
		base_facial_hair_icon.blend_icon(gradient_icon, ICON_OVERLAY)
		final_icon.blend_icon(base_facial_hair_icon, ICON_OVERLAY)

	final_icon.crop(10, 19, 22, 31)
	final_icon.scale(32, 32)

	return final_icon

/datum/preference/choiced/facial_hair_gradient/create_default_value()
	return /datum/sprite_accessory/gradient/none::name

/datum/preference/choiced/facial_hair_gradient/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "facial_hair_gradient_color"

	return data

/datum/preference/color/facial_hair_gradient
	priority = PREFERENCE_PRIORITY_LATE_BODY_TYPE
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	preference_type = PREFERENCE_CHARACTER
	db_key = "facial_hair_gradient_color"
	relevant_head_flag = HEAD_FACIAL_HAIR
	//temporary fix
	disable_serialization = TRUE

/datum/preference/color/facial_hair_gradient/apply_to_human(mob/living/carbon/human/target, value)
	target.set_facial_hair_gradient_color(new_color = value, update = FALSE)

/datum/preference/color/facial_hair_gradient/create_default_value()
	return random_hair_color()

/datum/preference/color/facial_hair_gradient/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/facial_hair_gradient) != /datum/sprite_accessory/gradient/none::name
*/

/datum/preference/color/hair_color
	db_key = "hair_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_head_flag = HEAD_HAIR
	priority = PREFERENCE_PRIORITY_HAIR_COLOR

/datum/preference/color/hair_color/has_relevant_feature(datum/preferences/preferences)
	return ..() || (/datum/quirk/item_quirk/bald::name in preferences.all_quirks)

/datum/preference/color/hair_color/apply_to_human(mob/living/carbon/human/target, value)
	if(isipc(target))
		return
	target.set_haircolor(value, update = TRUE)

/datum/preference/color/hair_color/create_informed_default_value(datum/preferences/preferences)
	return random_hair_color()

/datum/preference/choiced/hairstyle
	priority = PREFERENCE_PRIORITY_BODY_TYPE // Happens after gender so we can picka hairstyle based on that
	db_key = "hair_style_name"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Hair Style"
	should_generate_icons = TRUE
	relevant_head_flag = HEAD_HAIR
	preference_spritesheet = PREFERENCE_SHEET_HUGE

/datum/preference/choiced/hairstyle/has_relevant_feature(datum/preferences/preferences)
	return ..() || (/datum/quirk/item_quirk/bald::name in preferences.all_quirks)

/datum/preference/choiced/hairstyle/init_possible_values()
	return assoc_to_keys_features(SSaccessories.hairstyles_list)

/datum/preference/choiced/hairstyle/icon_for(value)
	return generate_icon_with_head_accessory(SSaccessories.hairstyles_list[value])

/datum/preference/choiced/hairstyle/apply_to_human(mob/living/carbon/human/target, value)
	target.set_hairstyle(value, update = FALSE)

/datum/preference/choiced/hairstyle/create_default_value()
	return /datum/sprite_accessory/hair/bald::name

/datum/preference/choiced/hairstyle/create_informed_default_value(datum/preferences/preferences)
	var/gender = preferences.read_preference(/datum/preference/choiced/gender)
	var/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/datum/species/species_real = GLOB.species_prototypes[species_type]
	if(!gender || !species_real || !species_real.sexes)
		return ..()

	var/datum/sprite_accessory/picked_hair = pick_default_accessory(SSaccessories.hairstyles_list, null, 0, gender)
	if(!picked_hair)
		return ..()
	if(picked_hair?.locked) // Invalid, go with god(bald)
		return ..()

	return picked_hair?.name

/datum/preference/choiced/hairstyle/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/color/hair_color::db_key

	return data

/datum/preference/choiced/hair_gradient
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	db_key = "gradient_style"
	main_feature_name = "Hair Gradient"
	relevant_head_flag = HEAD_HAIR
	can_randomize = FALSE
	should_generate_icons = TRUE

/datum/preference/choiced/hair_gradient/init_possible_values()
	return assoc_to_keys_features(SSaccessories.hair_gradients_list)

/datum/preference/choiced/hair_gradient/apply_to_human(mob/living/carbon/human/target, value)
	target.set_hair_gradient_style(new_style = value, update = FALSE)

/datum/preference/choiced/hair_gradient/icon_for(value)
	var/datum/sprite_accessory/gradient_accessory = SSaccessories.hair_gradients_list[value]
	if (!gradient_accessory || gradient_accessory.icon_state == "none")
		return uni_icon('icons/mob/landmarks.dmi', "x")

	// Create base head
	var/datum/universal_icon/final_icon = uni_icon('icons/mob/human/bodyparts_greyscale.dmi', "human_head_m")
	final_icon.blend_color(skintone2hex("caucasian1"), ICON_MULTIPLY)

	// Use a standard hair style for the preview
	var/datum/sprite_accessory/hair_accessory = SSaccessories.hairstyles_list["Very Long Hair 2"] || SSaccessories.hairstyles_list["Short Hair"]
	if (hair_accessory)
		var/datum/universal_icon/base_hair_icon = uni_icon(hair_accessory.icon, hair_accessory.icon_state)
		base_hair_icon.blend_color("#080501", ICON_MULTIPLY)

		// Create gradient overlay
		var/datum/universal_icon/gradient_icon = uni_icon(hair_accessory.icon, hair_accessory.icon_state)
		gradient_icon.blend_icon(uni_icon(gradient_accessory.icon, gradient_accessory.icon_state), ICON_ADD)
		gradient_icon.blend_color("#42250a", ICON_MULTIPLY)

		// Combine base hair with gradient
		base_hair_icon.blend_icon(gradient_icon, ICON_OVERLAY)
		final_icon.blend_icon(base_hair_icon, ICON_OVERLAY)

	final_icon.crop(10, 19, 22, 31)
	final_icon.scale(32, 32)

	return final_icon

/datum/preference/choiced/hair_gradient/create_default_value()
	return /datum/sprite_accessory/gradient/none::name

/datum/preference/choiced/hair_gradient/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "gradient_color"

	return data

/datum/preference/color/hair_gradient
	priority = PREFERENCE_PRIORITY_GRADIENT_COLOR
	db_key = "gradient_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_head_flag = HEAD_HAIR

/datum/preference/color/hair_gradient/apply_to_human(mob/living/carbon/human/target, value)
	target.set_hair_gradient_color(new_color = value, update = FALSE)

/datum/preference/color/hair_gradient/create_default_value()
	return random_hair_color()

/datum/preference/color/hair_gradient/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/hair_gradient) != /datum/sprite_accessory/gradient/none::name
