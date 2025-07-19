
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
 * Randomizes everything about a human, including DNA and name
 */
/proc/randomize_human(mob/living/carbon/human/human, randomize_mutations = FALSE, update_body = TRUE)
	human.gender = human.dna.species.sexes ? pick(MALE, FEMALE, PLURAL, NEUTER) : PLURAL
	human.physique = human.gender
	human.real_name = human.dna?.species.random_name(human.gender) || random_unique_name(human.gender)
	human.name = human.get_visible_name()
	human.set_hairstyle(random_hairstyle(human.gender), update = FALSE)
	human.set_facial_hairstyle(random_facial_hairstyle(human.gender), update = FALSE)
	// No underwear generation handled here
	var/picked_color = random_hair_color()
	human.set_haircolor(picked_color, update = FALSE)
	human.set_facial_haircolor(picked_color, update = FALSE)
	human.eye_color = random_eye_color()
	human.skin_tone = random_skin_tone()

	human.dna.species.randomize_active_underwear_only(human)
	// Needs to be called towards the end to update all the UIs just set above
	human.dna.initialize_dna(newblood_type = random_blood_type(), create_mutation_blocks = randomize_mutations, randomize_features = TRUE)
	// Snowflake stuff (ethereals)

	human.dna.species.spec_updatehealth(human)
	if(update_body)
		human.updateappearance(mutcolor_update = TRUE)
