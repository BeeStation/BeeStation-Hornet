
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
	H.gender = pick(MALE, FEMALE)
	H.real_name = H.generate_random_mob_name()
	H.name = H.real_name
	H.underwear = random_underwear(H.gender)
	H.socks = random_socks(H.gender)
	H.undershirt = random_undershirt(H.undershirt)
	H.underwear_color = "#[random_color()]"
	H.skin_tone = pick(GLOB.skin_tones)
	H.eye_color = random_eye_color()
	H.dna.blood_type = random_blood_type()

	// Things that we should be more careful about to make realistic characters
	H.hair_style = random_hair_style(H.gender)
	H.facial_hair_style = random_facial_hair_style(H.gender)
	// Randomized humans get more unique hair styles than the preference editor
	// since they are usually important characters, and as we know from anime
	// important characters always have colourful hair
	if (unique)
		H.hair_color = "#[random_color()]"
		H.facial_hair_color = H.hair_color
		var/list/rgb_list = rgb2num(H.hair_color)
		var/list/hsl = rgb2hsl(rgb_list[1], rgb_list[2], rgb_list[3])
		hsl[1] = CLAMP01(hsl[1] + (rand(-6, 6)/360))
		hsl[2] = CLAMP01(hsl[2] + (rand(-4, 4)/100))
		hsl[3] = CLAMP01(hsl[3] + (rand(-2, 2)/100))
		rgb_list = hsl2rgb(hsl[1], hsl[2], hsl[3])
		H.gradient_color = copytext(rgb(rgb_list[1], rgb_list[2], rgb_list[3]), 2)
	else
		// Copy the behaviour of the preferences selection
		// Hair colour
		switch (H.gender)
			if (MALE)
				H.hair_color = pick(GLOB.natural_hair_colours)
			else
				if (prob(10))
					H.hair_color = pick(GLOB.female_dyed_hair_colours)
				else
					H.hair_color = pick(GLOB.natural_hair_colours)
		// Gradient colour
		if (prob(40))
			H.gradient_color = H.hair_color
		else
			switch (H.gender)
				if (MALE)
					H.gradient_color = pick(GLOB.secondary_dye_hair_colours)
				else
					H.gradient_color = pick(GLOB.secondary_dye_hair_colours + GLOB.secondary_dye_female_hair_colours)
		// Facial hair colour
		H.facial_hair_color = H.hair_color
	var/datum/sprite_accessory/gradient_style = pick_default_accessory(GLOB.hair_gradients_list, required_gender = H.gender)
	H.gradient_style = gradient_style.name

	// Mutant randomizing, doesn't affect the mob appearance unless it's the specific mutant.
	H.dna.features["mcolor"] = "#[random_color()]"
	H.dna.features["ethcolor"] = GLOB.color_list_ethereal[pick(GLOB.color_list_ethereal)]
	H.dna.features["tail_lizard"] = pick(GLOB.tails_list_lizard)
	H.dna.features["snout"] = pick(GLOB.snouts_list)
	H.dna.features["horns"] = pick(GLOB.horns_list)
	H.dna.features["frills"] = pick(GLOB.frills_list)
	H.dna.features["spines"] = pick(GLOB.spines_list)
	H.dna.features["body_markings"] = pick(GLOB.body_markings_list)
	H.dna.features["moth_wings"] = pick(GLOB.moth_wings_roundstart_list)
	H.dna.features["moth_antennae"] = pick(GLOB.moth_antennae_roundstart_list)
	H.dna.features["moth_markings"] = pick(GLOB.moth_markings_roundstart_list)
	H.dna.features["apid_antenna"] = pick(GLOB.apid_antenna_list)
	H.dna.features["apid_stripes"] = pick(GLOB.apid_stripes_list)
	H.dna.features["apid_headstripes"] = pick(GLOB.apid_headstripes_list)
	H.dna.features["body_model"] = H.gender
	H.dna.features["psyphoza_cap"] = pick(GLOB.psyphoza_cap_list)
	H.dna.features["diona_leaves"] = pick(GLOB.diona_leaves_list)
	H.dna.features["diona_thorns"] = pick(GLOB.diona_thorns_list)
	H.dna.features["diona_flowers"] = pick(GLOB.diona_flowers_list)
	H.dna.features["diona_moss"] = pick(GLOB.diona_moss_list)
	H.dna.features["diona_mushroom"] = pick(GLOB.diona_mushroom_list)
	H.dna.features["diona_antennae"] = pick(GLOB.diona_antennae_list)
	H.dna.features["diona_eyes"] = pick(GLOB.diona_eyes_list)
	H.dna.features["diona_pbody"] = pick(GLOB.diona_pbody_list)

	H.update_body()
	H.update_hair()
	H.dna.species.spec_updatehealth(H)

