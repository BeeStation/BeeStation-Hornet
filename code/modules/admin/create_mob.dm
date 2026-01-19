
/datum/admins/proc/create_mob(mob/user)
	var/static/create_mob_html
	if (!create_mob_html)
		var/mobjs = null
		mobjs = jointext(typesof(/mob), ";")
		create_mob_html = rustg_file_read('html/create_object.html')
		create_mob_html = replacetext(create_mob_html, "Create Object", "Create Mob")
		create_mob_html = replacetext(create_mob_html, "null /* object types */", "\"[mobjs]\"")

	user << browse(create_panel_helper(create_mob_html), "window=create_mob;size=425x475")

/**
 * Fully randomizes everything about a human, including DNA and name.
 */
/proc/randomize_human(mob/living/carbon/human/human, randomize_mutations = FALSE)
	human.gender = human.dna.species.sexes ? pick(MALE, FEMALE, PLURAL) : PLURAL
	human.physique = human.gender
	human.real_name = human.generate_random_mob_name()
	human.name = human.get_visible_name()
	human.set_hairstyle(random_hairstyle(human.gender), update = FALSE)
	human.set_facial_hairstyle(random_facial_hairstyle(human.gender), update = FALSE)
	human.set_haircolor("#[random_color()]", update = FALSE)
	human.set_facial_haircolor(human.hair_color, update = FALSE)
	human.eye_color = random_eye_color()
	human.skin_tone = pick(GLOB.skin_tones)
	human.dna.species.randomize_active_underwear_only(human)
	// Needs to be called towards the end to update all the UIs just set above
	human.dna.initialize_dna(newblood_type = random_blood_type(), create_mutation_blocks = randomize_mutations, randomize_features = TRUE)
	// Snowflake stuff (ethereals)
	human.dna.species.spec_updatehealth(human)
	human.updateappearance(mutcolor_update = TRUE)

/**
 * Randomizes a human, but produces someone who looks exceedingly average (by most standards).
 *
 * (IE, no wacky hair styles / colors)
 */
/proc/randomize_human_normie(mob/living/carbon/human/human, randomize_mutations = FALSE, update_body = TRUE)
	// Sorry enbys but statistically you are not average enough
	human.gender = human.dna.species.sexes ? pick(MALE, FEMALE) : PLURAL
	human.physique = human.gender
	human.real_name = human.generate_random_mob_name()
	human.name = human.get_visible_name()
	human.eye_color= random_eye_color()
	human.skin_tone = pick(GLOB.skin_tones)
	// No underwear generation handled here
	var/picked_color = random_hair_color()
	human.set_haircolor(picked_color, update = FALSE)
	human.set_facial_haircolor(picked_color, update = FALSE)
	var/datum/sprite_accessory/hairstyle = SSaccessories.hairstyles_list[random_hairstyle(human.gender)]
	if(hairstyle && hairstyle.natural_spawn && !hairstyle.locked)
		human.set_hairstyle(hairstyle.name, update = FALSE)
	var/datum/sprite_accessory/facial_hair = SSaccessories.facial_hairstyles_list[random_facial_hairstyle(human.gender)]
	if(facial_hair && facial_hair.natural_spawn && !facial_hair.locked)
		human.set_facial_hairstyle(facial_hair.name, update = FALSE)

	// Gradient colour - initialize as list
	if(!human.grad_color)
		human.grad_color = list()
	if(!human.grad_style)
		human.grad_style = list()

	// Gradient colour
	if (prob(40))
		human.grad_color[GRADIENT_HAIR_KEY] = human.hair_color
	else
		switch (human.gender)
			if (MALE)
				human.grad_color[GRADIENT_HAIR_KEY] = pick(GLOB.secondary_dye_hair_colours)
			else
				human.grad_color[GRADIENT_HAIR_KEY] = pick(GLOB.secondary_dye_hair_colours + GLOB.secondary_dye_female_hair_colours)
	var/datum/sprite_accessory/gradient_style = pick_default_accessory(SSaccessories.hair_gradients_list, required_gender = human.gender)
	human.grad_style[GRADIENT_HAIR_KEY] = gradient_style.name

	// Normal DNA init stuff, these can generally be wacky but we care less, they're aliens after all
	human.dna.initialize_dna(newblood_type = random_blood_type(), create_mutation_blocks = randomize_mutations, randomize_features = TRUE)
	human.dna.species.spec_updatehealth(human)
	if(update_body)
		human.updateappearance(mutcolor_update = TRUE)
