/datum/dna_block/identity/gender

/datum/dna_block/identity/gender/create_unique_block(mob/living/carbon/human/target)
	//ignores TRAIT_AGENDER so that a "real" gender can be stored in the DNA if later use is needed
	switch(target.gender)
		if(MALE)
			. = construct_block(G_MALE, GENDERS)
		if(FEMALE)
			. = construct_block(G_FEMALE, GENDERS)
		else
			. = construct_block(G_PLURAL, GENDERS)
	return .

/datum/dna_block/identity/gender/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	//Always plural gender if agender
	if(HAS_TRAIT(target, TRAIT_AGENDER))
		target.gender = PLURAL
		return
	switch(deconstruct_block(get_block(dna_hash), GENDERS))
		if(G_MALE)
			target.gender = MALE
		if(G_FEMALE)
			target.gender = FEMALE
		else
			target.gender = PLURAL

/datum/dna_block/identity/skin_tone

/datum/dna_block/identity/skin_tone/create_unique_block(mob/living/carbon/human/target)
	return construct_block(GLOB.skin_tones.Find(target.skin_tone), GLOB.skin_tones.len)

/datum/dna_block/identity/skin_tone/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.skin_tone = GLOB.skin_tones[deconstruct_block(get_block(dna_hash), GLOB.skin_tones.len)]

/// Eye color (single value only). Heterochromia / per-eye colors removed.
/datum/dna_block/identity/eye_colors
	// Only a single color is stored in DNA now.
	block_length = DNA_BLOCK_SIZE_COLOR

/datum/dna_block/identity/eye_colors/create_unique_block(mob/living/carbon/human/target)
	return sanitize_hexcolor(target.eye_color, include_crunch = FALSE)

/datum/dna_block/identity/eye_colors/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	var/color = get_block(dna_hash)
	target.set_eye_color(sanitize_hexcolor(color))

/datum/dna_block/identity/hair_style

/datum/dna_block/identity/hair_style/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.hairstyles_list.Find(target.hairstyle), length(SSaccessories.hairstyles_list))

/datum/dna_block/identity/hair_style/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	if(HAS_TRAIT(target, TRAIT_BALD))
		target.set_hairstyle("Bald", update = FALSE)
		return
	var/style = SSaccessories.hairstyles_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.hairstyles_list))]
	target.set_hairstyle(style, update = FALSE)

/datum/dna_block/identity/hair_color
	block_length = DNA_BLOCK_SIZE_COLOR

/datum/dna_block/identity/hair_color/create_unique_block(mob/living/carbon/human/target)
	return sanitize_hexcolor(target.hair_color, include_crunch = FALSE)

/datum/dna_block/identity/hair_color/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.set_haircolor(sanitize_hexcolor(get_block(dna_hash)), update = FALSE)

/datum/dna_block/identity/facial_style

/datum/dna_block/identity/facial_style/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.facial_hairstyles_list.Find(target.facial_hairstyle), length(SSaccessories.facial_hairstyles_list))

/datum/dna_block/identity/facial_style/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	if(HAS_TRAIT(src, TRAIT_SHAVED))
		target.set_facial_hairstyle("Shaved", update = FALSE)
		return
	var/style = SSaccessories.facial_hairstyles_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.facial_hairstyles_list))]
	target.set_facial_hairstyle(style, update = FALSE)

/datum/dna_block/identity/facial_color
	block_length = DNA_BLOCK_SIZE_COLOR

/datum/dna_block/identity/facial_color/create_unique_block(mob/living/carbon/human/target)
	return sanitize_hexcolor(target.facial_hair_color, include_crunch = FALSE)

/datum/dna_block/identity/facial_color/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.set_facial_haircolor(sanitize_hexcolor(get_block(dna_hash)), update = FALSE)

/datum/dna_block/identity/hair_gradient

/datum/dna_block/identity/hair_gradient/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.hair_gradients_list.Find(target.grad_style[GRADIENT_HAIR_KEY]), length(SSaccessories.hair_gradients_list))

/datum/dna_block/identity/hair_gradient/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	var/gradient_style = SSaccessories.hair_gradients_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.hair_gradients_list))]
	target.set_hair_gradient_style(gradient_style, update = FALSE)

/datum/dna_block/identity/hair_gradient_color
	block_length = DNA_BLOCK_SIZE_COLOR

/datum/dna_block/identity/hair_gradient_color/create_unique_block(mob/living/carbon/human/target)
	return sanitize_hexcolor(target.grad_color[GRADIENT_HAIR_KEY], include_crunch = FALSE)

/datum/dna_block/identity/hair_gradient_color/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.set_hair_gradient_color(sanitize_hexcolor(get_block(dna_hash)), update = FALSE)

/datum/dna_block/identity/facial_gradient

/datum/dna_block/identity/facial_gradient/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.facial_hair_gradients_list.Find(target.grad_style[GRADIENT_FACIAL_HAIR_KEY]), length(SSaccessories.facial_hair_gradients_list))

/datum/dna_block/identity/facial_gradient/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	var/gradient_style = SSaccessories.hair_gradients_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.hair_gradients_list))]
	target.set_facial_hair_gradient_style(gradient_style, update = FALSE)

/datum/dna_block/identity/facial_gradient_color
	block_length = DNA_BLOCK_SIZE_COLOR

/datum/dna_block/identity/facial_gradient_color/create_unique_block(mob/living/carbon/human/target)
	return sanitize_hexcolor(target.grad_color[GRADIENT_FACIAL_HAIR_KEY], include_crunch = FALSE)

/datum/dna_block/identity/facial_gradient_color/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.set_facial_hair_gradient_color(sanitize_hexcolor(get_block(dna_hash)), update = FALSE)
