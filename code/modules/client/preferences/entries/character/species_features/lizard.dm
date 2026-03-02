/proc/generate_lizard_side_shot(datum/sprite_accessory/sprite_accessory, key, include_snout = TRUE)
	var/static/datum/universal_icon/lizard
	var/static/datum/universal_icon/lizard_with_snout

	if (isnull(lizard))
		lizard = uni_icon('icons/mob/human/species/lizard/bodyparts.dmi', "lizard_head", EAST)
		var/datum/universal_icon/eyes = uni_icon('icons/mob/human/human_face.dmi', "eyes", EAST)
		eyes.blend_color(COLOR_GRAY, ICON_MULTIPLY)
		lizard.blend_icon(eyes, ICON_OVERLAY)

		lizard_with_snout = lizard.copy()
		lizard_with_snout.blend_icon(uni_icon('icons/mob/human/species/lizard/lizard_misc.dmi', "m_snout_round_ADJ", EAST), ICON_OVERLAY)

	var/datum/universal_icon/final_icon = include_snout ? lizard_with_snout.copy() : lizard.copy()

	if (!isnull(sprite_accessory) && sprite_accessory.icon_state != SPRITE_ACCESSORY_NONE && sprite_accessory.icon_state != "none")
		var/datum/universal_icon/accessory_icon = uni_icon(sprite_accessory.icon, "m_[key]_[sprite_accessory.icon_state]_ADJ", EAST)
		final_icon.blend_icon(accessory_icon, ICON_OVERLAY)

	final_icon.crop(11, 20, 23, 32)
	final_icon.scale(32, 32)
	final_icon.blend_color(COLOR_VIBRANT_LIME, ICON_MULTIPLY)

	return final_icon

/datum/preference/choiced/lizard_body_markings
	db_key = "feature_lizard_body_markings"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Body Markings"
	should_generate_icons = TRUE
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/lizard

/datum/preference/choiced/lizard_body_markings/init_possible_values()
	return assoc_to_keys_features(SSaccessories.lizard_markings_list)

/datum/preference/choiced/lizard_body_markings/icon_for(value)
	var/datum/sprite_accessory/sprite_accessory = SSaccessories.lizard_markings_list[value]

	var/datum/universal_icon/final_icon = uni_icon('icons/mob/human/species/lizard/bodyparts.dmi', "lizard_chest_m")

	if (sprite_accessory.icon_state != SPRITE_ACCESSORY_NONE && sprite_accessory.icon_state != "none")
		var/datum/universal_icon/body_markings_icon = uni_icon(
			sprite_accessory.icon,
			"male_[sprite_accessory.icon_state]_chest",
		)

		final_icon.blend_icon(body_markings_icon, ICON_OVERLAY)

	final_icon.blend_color(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
	final_icon.crop(10, 8, 22, 23)
	final_icon.scale(26, 32)
	final_icon.crop(-2, 1, 29, 32)

	return final_icon

/datum/preference/choiced/lizard_body_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["lizard_markings"] = value

/datum/preference/choiced/lizard_frills
	db_key = "feature_lizard_frills"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Frills"
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/frills

/datum/preference/choiced/lizard_frills/init_possible_values()
	return assoc_to_keys_features(SSaccessories.frills_list)

/datum/preference/choiced/lizard_frills/icon_for(value)
	return generate_lizard_side_shot(SSaccessories.frills_list[value], "frills")

/datum/preference/choiced/lizard_frills/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["frills"] = value

/datum/preference/choiced/lizard_horns
	db_key = "feature_lizard_horns"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Horns"
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/horns

/datum/preference/choiced/lizard_horns/init_possible_values()
	return assoc_to_keys_features(SSaccessories.horns_list)

/datum/preference/choiced/lizard_horns/icon_for(value)
	return generate_lizard_side_shot(SSaccessories.horns_list[value], "horns")

/datum/preference/choiced/lizard_horns/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["horns"] = value

/datum/preference/choiced/lizard_legs
	db_key = "feature_lizard_legs"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/choiced/lizard_legs/init_possible_values()
	return list(NORMAL_LEGS, DIGITIGRADE_LEGS)

/datum/preference/choiced/lizard_legs/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["legs"] = value
	// Hack to update the dummy in the preference menu
	// (Because digi legs are ONLY handled on species change)
	if(!isdummy(target) || target.dna.species.digitigrade_customization == DIGITIGRADE_NEVER)
		return

	var/list/correct_legs = target.dna.species.bodypart_overrides.Copy() & list(BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)

	if(value == DIGITIGRADE_LEGS)
		correct_legs[BODY_ZONE_R_LEG] = /obj/item/bodypart/leg/right/digitigrade
		correct_legs[BODY_ZONE_L_LEG] = /obj/item/bodypart/leg/left/digitigrade

	for(var/obj/item/bodypart/old_part as anything in target.bodyparts)
		if(old_part.change_exempt_flags & BP_BLOCK_CHANGE_SPECIES)
			continue

		var/path = correct_legs[old_part.body_zone]
		if(!path)
			continue
		var/obj/item/bodypart/new_part = new path()
		new_part.replace_limb(target, TRUE)
		new_part.update_limb(is_creating = TRUE)
		qdel(old_part)

/datum/preference/choiced/lizard_legs/is_accessible(datum/preferences/preferences, ignore_page = FALSE)
	if(!..())
		return FALSE
	var/datum/species/species_type = preferences.read_preference(/datum/preference/choiced/species)
	return initial(species_type.digitigrade_customization) == DIGITIGRADE_OPTIONAL

/datum/preference/choiced/lizard_snout
	db_key = "feature_lizard_snout"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Snout"
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/snout

/datum/preference/choiced/lizard_snout/init_possible_values()
	return assoc_to_keys_features(SSaccessories.snouts_list)

/datum/preference/choiced/lizard_snout/icon_for(value)
	return generate_lizard_side_shot(SSaccessories.snouts_list[value], "snout", include_snout = FALSE)

/datum/preference/choiced/lizard_snout/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["snout"] = value

/datum/preference/choiced/lizard_spines
	db_key = "feature_lizard_spines"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Spines"
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/spines

/datum/preference/choiced/lizard_spines/init_possible_values()
	return assoc_to_keys_features(SSaccessories.spines_list)

/datum/preference/choiced/lizard_spines/icon_for(value)
	return generate_lizard_body_shot(SSaccessories.spines_list[value], "spines")

/datum/preference/choiced/lizard_spines/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["spines"] = value

/datum/preference/choiced/lizard_tail
	db_key = "feature_lizard_tail"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Tail"
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/tail/lizard

/datum/preference/choiced/lizard_tail/init_possible_values()
	var/list/values = assoc_to_keys_features(SSaccessories.tails_list_lizard)
	values -= "None" // Remove "None" tails"
	return values

/datum/preference/choiced/lizard_tail/icon_for(value)
	return generate_lizard_body_shot(SSaccessories.tails_list_lizard[value], "tail")

/datum/preference/choiced/lizard_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_lizard"] = value

/datum/preference/choiced/lizard_tail/create_default_value()
	return /datum/sprite_accessory/tails/lizard/smooth::name

/proc/generate_lizard_body_shot(datum/sprite_accessory/sprite_accessory, key, show_tail = FALSE, shift_x = -8)
	var/static/datum/universal_icon/body_icon

	if (isnull(body_icon))
		var/list/body_parts = list(
			BODY_ZONE_CHEST,
			BODY_ZONE_R_ARM,
			BODY_ZONE_PRECISE_R_HAND,
			BODY_ZONE_R_LEG,
		)
		body_icon = uni_icon('icons/effects/effects.dmi', "nothing")
		for (var/body_part in body_parts)
			var/gender = body_part == BODY_ZONE_CHEST ? "_m" : ""
			body_icon.blend_icon(uni_icon('icons/mob/human/species/lizard/bodyparts.dmi', "lizard_[body_part][gender]", dir = EAST), ICON_OVERLAY)

	var/datum/universal_icon/final_icon = body_icon.copy()

	if(show_tail)
		final_icon.blend_icon(uni_icon('icons/mob/mutant_bodyparts.dmi', "m_tail_smooth_BEHIND", dir = EAST), ICON_OVERLAY)

	if (!isnull(sprite_accessory) && sprite_accessory.icon_state != SPRITE_ACCESSORY_NONE && sprite_accessory.icon_state != "none")
		var/ex = key == "spines" ? "ADJ" : "BEHIND"
		var/icon_file
		var/icon_state_name
		switch(key)
			if("tail")
				icon_file = 'icons/mob/human/species/lizard/lizard_tails.dmi'
				icon_state_name = "m_tail_lizard_[sprite_accessory.icon_state]_[ex]"
			if("spines")
				icon_file = 'icons/mob/human/species/lizard/lizard_spines.dmi'
				icon_state_name = "m_[key]_[sprite_accessory.icon_state]_[ex]"
			else
				icon_file = 'icons/mob/mutant_bodyparts.dmi'
				icon_state_name = "m_[key]_[sprite_accessory.icon_state]_[ex]"
		var/datum/universal_icon/sprite_icon = uni_icon(icon_file, icon_state_name, dir = EAST)
		final_icon.blend_icon(sprite_icon, ICON_OVERLAY)

	final_icon.blend_color(COLOR_VIBRANT_LIME, ICON_MULTIPLY)

	// Zoom in
	final_icon.scale(64, 64)
	final_icon.crop(15 + shift_x, 0, 15 + 31 + shift_x, 31)

	return final_icon
