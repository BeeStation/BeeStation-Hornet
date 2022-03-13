/datum/character
	var/datum/preferences/parent

	///Primary character name
	var/real_name

	///Whether name is randomized every round
	var/be_random_name = FALSE

	///Whether appearance is randomized every round
	var/be_random_body = FALSE

	///Character sex
	var/gender = MALE

	///Character age
	var/age = 30

	///Character underwear
	var/underwear = "Nude"

	///Character underwear color (only 4096 choices, since 12 bit!)
	var/underwear_color = "000"

	///Character undershirt
	var/undershirt = "Nude"

	///Character socks
	var/socks = "Nude"					//socks type

	///Character helmet type (plasmamen)
	var/helmet_style = HELMET_DEFAULT

	///Character backpack style
	var/backbag = DBACKPACK

	///Character jumpsuit style (suit/skirt)
	var/jumpsuit_style = PREF_SUIT

	///Character hairstyle
	var/hair_style = "Bald"

	///Character hair color
	var/hair_color = "000"

	///Character hair gradient style
	var/gradient_style = "None"

	///Character hair gradient color
	var/gradient_color = "000"

	///Character facial hair style
	var/facial_hair_style = "Shaved"

	///Character facial hair color
	var/facial_hair_color = "000"

	///Character skin color
	var/skin_tone = "caucasian1"

	///Character eye color
	var/eye_color = "000"

	///Species choice (id value is stored in saves, rather than the whole datum)
	var/datum/species/pref_species = new /datum/species/human()

	///Species features
	var/list/features = list(
							"body_size" = "Normal",
							"mcolor" = "FFF",
							"ethcolor" = "9c3030",
							"tail_lizard" = "Smooth",
							"tail_human" = "None",
							"snout" = "Round",
							"horns" = "None",
							"ears" = "None",
							"wings" = "None",
							"frills" = "None",
							"spines" = "None",
							"body_markings" = "None",
							"legs" = "Normal Legs",
							"moth_wings" = "Plain",
							"ipc_screen" = "Blue",
							"ipc_antenna" = "None",
							"ipc_chassis" = "Morpheus Cyberkinetics(Greyscale)",
							"insect_type" = "Common Fly"
						)

	///Names for AI, cyborg, clown etc
	var/list/custom_names = list()

	///AI core display choice
	var/preferred_ai_core_display = "Blue"

	///Preferred security spawn location (if department sec spawns are on)
	var/prefered_security_department = SEC_DEPT_RANDOM

	///Character quirks
	var/list/all_quirks = list()

	///Character job preferences
	var/list/job_preferences = list()

	///What to do if couldn't get preferred job (see "role_preferences.dm")
	var/joblessrole = BERANDOMJOB  //defaults to 1 for fewer assistants

	///Location to spawn uplink (PDA, pen, headset)
	var/uplink_spawn_loc = UPLINK_PDA

/datum/character/New(datum/preferences/P)
	parent = P

// Handles conversion of player characters to a saveable format, either for DB or .json file
/datum/character/serialize_list(list/options)
	. = list()
	.["real_name"] = real_name
	.["be_random_name"] = be_random_name
	.["be_random_body"] = be_random_body
	.["gender"] = gender
	.["age"] = age
	.["underwear"] = underwear
	.["underwear_color"] = underwear_color
	.["undershirt"] = undershirt
	.["socks"] = socks
	.["helmet_style"] = helmet_style
	.["backbag"] = backbag
	.["jumpsuit_style"] = jumpsuit_style
	.["hair_style"] = hair_style
	.["hair_color"] = hair_color
	.["gradient_style"] = gradient_style
	.["gradient_color"] = gradient_color
	.["facial_hair_style"] = facial_hair_style
	.["facial_hair_color"] = facial_hair_color
	.["skin_tone"] = skin_tone
	.["eye_color"] = eye_color
	.["pref_species"] = pref_species.id
	.["features"] = features
	.["custom_names"] = custom_names
	.["preferred_ai_core_display"] = preferred_ai_core_display
	.["prefered_security_department"] = prefered_security_department
	.["all_quirks"] = all_quirks
	.["job_preferences"] = job_preferences
	.["joblessrole"] = joblessrole
	.["uplink_spawn_loc"] = uplink_spawn_loc

/datum/character/deserialize_list(json, list/options)
	var/species_id = json["pref_species"]
	if(species_id)
		var/newtype = GLOB.species_list[species_id]
		if(newtype)
			pref_species = new newtype

	be_random_name = sanitize_integer(json["be_random_name"], FALSE, TRUE, initial(be_random_name))
	be_random_body = sanitize_integer(json["be_random_body"], FALSE, TRUE, initial(be_random_body))
	gender = sanitize_gender(json["gender"])

	real_name = reject_bad_name(json["real_name"], pref_species.allow_numbers_in_name)
	if(!real_name)
		real_name = random_unique_name(gender)

	age = sanitize_integer(json["age"], AGE_MIN, AGE_MAX, initial(age))

	if(gender == MALE)
		hair_style = sanitize_inlist(json["hair_style"], GLOB.hair_styles_male_list)
		facial_hair_style = sanitize_inlist(json["facial_hair_style"], GLOB.facial_hair_styles_male_list)
		underwear = sanitize_inlist(json["underwear"], GLOB.underwear_m)
		undershirt = sanitize_inlist(json["undershirt"], GLOB.undershirt_m)
	else
		hair_style = sanitize_inlist(json["hair_style"], GLOB.hair_styles_female_list)
		facial_hair_style = sanitize_inlist(json["facial_hair_style"], GLOB.facial_hair_styles_female_list)
		underwear = sanitize_inlist(json["underwear"], GLOB.underwear_f)
		undershirt = sanitize_inlist(json["undershirt"], GLOB.undershirt_f)

	socks = sanitize_inlist(json["socks"], GLOB.socks_list)
	helmet_style = sanitize_inlist(json["helmet_style"], GLOB.helmetstylelist, initial(helmet_style))
	backbag = sanitize_inlist(json["backbag"], GLOB.backbaglist, initial(backbag))
	jumpsuit_style = sanitize_inlist(json["jumpsuit_style"], GLOB.jumpsuitlist, initial(jumpsuit_style))
	underwear_color = sanitize_hexcolor(json["underwear_color"], 3, 0)
	hair_color = sanitize_hexcolor(json["hair_color"], 3, 0)
	gradient_style = sanitize_inlist(json["gradient_style"], GLOB.hair_gradients_list, initial(gradient_style))
	gradient_color = sanitize_hexcolor(json["gradient_color"], 3, 0)
	facial_hair_color = sanitize_hexcolor(json["facial_hair_color"], 3, 0)
	skin_tone = sanitize_inlist(json["skin_tone"], GLOB.skin_tones, initial(skin_tone))
	eye_color = sanitize_hexcolor(json["eye_color"], 3, 0)
	preferred_ai_core_display = sanitize_inlist(json["preferred_ai_core_display"], GLOB.ai_core_display_screens, initial(preferred_ai_core_display))
	prefered_security_department = sanitize_inlist(json["prefered_security_department"], GLOB.security_depts_prefs, initial(prefered_security_department))
	all_quirks = SANITIZE_LIST(json["all_quirks"])
	joblessrole = sanitize_integer(json["joblessrole"], 1, 3, initial(joblessrole))
	uplink_spawn_loc = sanitize_inlist(json["uplink_spawn_loc"], GLOB.uplink_spawn_loc_list_save, initial(uplink_spawn_loc))

	job_preferences = json["job_preferences"]
	for(var/j in job_preferences)
		if(job_preferences[j] != JP_LOW && job_preferences[j] != JP_MEDIUM && job_preferences[j] != JP_HIGH)
			job_preferences -= j

	custom_names = json["custom_names"]
	for(var/custom_name_id in GLOB.preferences_custom_names)
		var/namedata = GLOB.preferences_custom_names[custom_name_id]
		custom_names[custom_name_id] = reject_bad_name(custom_names[custom_name_id],namedata["allow_numbers"])
		if(!custom_names[custom_name_id])
			custom_names[custom_name_id] = get_default_name(custom_name_id)

	// Mutant features crap
	features = json["features"]
	features["body_size"] = sanitize_inlist(features["body_size"], GLOB.body_sizes, "Normal")
	if(!features["mcolor"] || features["mcolor"] == "000")
		features["mcolor"] = pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F") // don't worry these get formatted on the next line
	features["mcolor"]	= sanitize_hexcolor(features["mcolor"], 3, 0, "FFF")
	if(!features["ethcolor"] || features["ethcolor"] == "000000")
		features["ethcolor"] = GLOB.color_list_ethereal[pick(GLOB.color_list_ethereal)]
	features["ethcolor"]	= sanitize_hexcolor(features["ethcolor"], 6, 0, "9c3030")
	features["tail_lizard"]	= sanitize_inlist(features["tail_lizard"], GLOB.tails_list_lizard, "Smooth")
	features["tail_human"] 	= sanitize_inlist(features["tail_human"], GLOB.tails_list_human, "None")
	features["snout"] = sanitize_inlist(features["snout"], GLOB.snouts_list, "Round")
	features["horns"] = sanitize_inlist(features["horns"], GLOB.horns_list, "None")
	features["ears"] = sanitize_inlist(features["ears"], GLOB.ears_list, "None")
	features["frills"] = sanitize_inlist(features["frills"], GLOB.frills_list, "None")
	features["spines"] = sanitize_inlist(features["spines"], GLOB.spines_list, "None")
	features["body_markings"] = sanitize_inlist(features["body_markings"], GLOB.body_markings_list, "None")
	features["feature_lizard_legs"]	= sanitize_inlist(features["legs"], GLOB.legs_list, "Normal Legs")
	features["moth_wings"] = sanitize_inlist(features["moth_wings"], GLOB.moth_wings_list, "Plain")
	features["ipc_screen"] = sanitize_inlist(features["ipc_screen"], GLOB.ipc_screens_list, "Blue")
	features["ipc_antenna"]	= sanitize_inlist(features["ipc_antenna"], GLOB.ipc_antennas_list, "None")
	features["ipc_chassis"]	= sanitize_inlist(features["ipc_chassis"], GLOB.ipc_chassis_list, "Morpheus Cyberkinetics(Greyscale)")
	features["insect_type"]	= sanitize_inlist(features["insect_type"], GLOB.insect_type_list, "Common Fly")

	//Validate species forced mutant parts
	for(var/forced_part in pref_species.forced_features)
		var/forced_type = pref_species.forced_features[forced_part]
		features[forced_part] = forced_type
