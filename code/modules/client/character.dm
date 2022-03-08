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
	real_name = json["real_name"]
	be_random_name = json["be_random_name"]
	be_random_body = json["be_random_body"]
	gender = json["gender"]
	age = json["age"]
	underwear = json["underwear"]
	underwear_color = json["underwear_color"]
	undershirt = json["undershirt"]
	socks = json["socks"]
	helmet_style = json["helmet_style"]
	backbag = json["backbag"]
	jumpsuit_style = json["jumpsuit_style"]
	hair_style = json["hair_style"]
	hair_color = json["hair_color"]
	gradient_style = json["gradient_style"]
	gradient_color = json["gradient_color"]
	facial_hair_style = json["facial_hair_style"]
	facial_hair_color = json["facial_hair_color"]
	skin_tone = json["skin_tone"]
	eye_color = json["eye_color"]
	features = json["features"]
	custom_names = json["custom_names"]
	preferred_ai_core_display = json["preferred_ai_core_display"]
	prefered_security_department = json["prefered_security_department"]
	all_quirks = json["all_quirks"]
	job_preferences = json["job_preferences"]
	joblessrole = json["joblessrole"]
	uplink_spawn_loc = json["uplink_spawn_loc"]
	var/species_id = json["pref_species"]
	if(species_id)
		var/newtype = GLOB.species_list[species_id]
		if(newtype)
			character.pref_species = new newtype
