
/datum/admins/proc/create_mob(mob/user)
	var/static/create_mob_html
	if (!create_mob_html)
		var/mobjs = null
		mobjs = jointext(typesof(/mob), ";")
		create_mob_html = rustg_file_read('html/create_object.html')
		create_mob_html = replacetext(create_mob_html, "Create Object", "Create Mob")
		create_mob_html = replacetext(create_mob_html, "null /* object types */", "\"[mobjs]\"")

	user << browse(create_panel_helper(create_mob_html), "window=create_mob;size=425x475")

/proc/randomize_human(mob/living/carbon/human/H, unique = FALSE)
	if(H.dna.species.sexes)
		H.gender = pick(MALE, FEMALE, PLURAL)
	else
		H.gender = PLURAL
	H.real_name = H.dna?.species.random_name(H.gender) || random_unique_name(H.gender)
	H.name = H.real_name
	H.hair_style = random_hair_style(H.gender)
	H.facial_hair_style = random_facial_hair_style(H.gender)
	H.hair_color = random_short_color()
	H.facial_hair_color = H.hair_color
	H.eye_color = random_eye_color()

	H.dna.blood_type = random_blood_type()
	H.dna.features["mcolor"] = random_short_color()
	H.dna.species.randomize_active_underwear_only(H)

	for(var/datum/species/species_path as anything in subtypesof(/datum/species))
		var/datum/species/new_species = new species_path
		new_species.randomize_features(H)
	H.dna.species.spec_updatehealth(H)
	H.dna.update_dna_identity(H)
	H.updateappearance(H)
	H.update_body(is_creating = TRUE)
