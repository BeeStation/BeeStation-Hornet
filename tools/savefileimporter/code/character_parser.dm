#define READ_FILE(sf, varname, fallback) var/##varname; sf >> ##varname; if(!##varname) ##varname=fallback;
#define READ_FILE_EXVAR(sf, varname) sf >> ##varname;

var/global/list/custom_name_types = list(
	"human",
	"clown",
	"mime",
	"cyborg",
	"ai",
	"religion",
	"deity",
)

// In its own file because its such a mess
/proc/parse_characters(owning_ckey, savefile/S, list/cdirs)
	for(var/character_dir in cdirs)
		S.cd = character_dir

		READ_FILE(S["species"], species_id, "human")
		READ_FILE(S["real_name"], real_name, "Unnamed Character")
		READ_FILE(S["name_is_always_random"], be_random_name, FALSE)
		READ_FILE(S["body_is_always_random"], be_random_body, FALSE)
		READ_FILE(S["gender"], gender, MALE)
		READ_FILE(S["age"], age, 30)
		READ_FILE(S["hair_color"], hair_color, "000")
		READ_FILE(S["gradient_color"], gradient_color, "000")
		READ_FILE(S["facial_hair_color"], facial_hair_color, "000")
		READ_FILE(S["eye_color"], eye_color, "000")
		READ_FILE(S["skin_tone"], skin_tone, "caucasian1")
		READ_FILE(S["hair_style_name"], hair_style, "Bald")
		READ_FILE(S["gradient_style"], gradient_style, "None")
		READ_FILE(S["facial_style_name"], facial_hair_style, "Shaved")
		READ_FILE(S["underwear"], underwear, "Nude") // lewd
		READ_FILE(S["underwear_color"], underwear_color, "000")
		READ_FILE(S["undershirt"], undershirt, "Nude")
		READ_FILE(S["socks"], socks, "Nude") // :flooshed:
		READ_FILE(S["backbag"], backbag, "Department Backpack")
		READ_FILE(S["jumpsuit_style"], jumpsuit_style, "Jumpsuit")
		READ_FILE(S["uplink_loc"], uplink_spawn_loc, "PDA")
		READ_FILE(S["helmet_style"], helmet_style, "Default")
		READ_FILE(S["preferred_ai_core_display"], preferred_ai_core_display, "Blue")
		// I will kill whoever couldnt spell this
		READ_FILE(S["prefered_security_department"], prefered_security_department, "Random")
		READ_FILE(S["joblessrole"], joblessrole, 2)

		var/list/features = list()
		READ_FILE_EXVAR(S["body_size"], features["body_size"])
		READ_FILE_EXVAR(S["feature_mcolor"], features["mcolor"])
		READ_FILE_EXVAR(S["feature_ethcolor"], features["ethcolor"])
		READ_FILE_EXVAR(S["feature_lizard_tail"], features["tail_lizard"])
		READ_FILE_EXVAR(S["feature_lizard_snout"], features["snout"])
		READ_FILE_EXVAR(S["feature_lizard_horns"], features["horns"])
		READ_FILE_EXVAR(S["feature_lizard_frills"], features["frills"])
		READ_FILE_EXVAR(S["feature_lizard_spines"], features["spines"])
		READ_FILE_EXVAR(S["feature_lizard_body_markings"], features["body_markings"])
		READ_FILE_EXVAR(S["feature_lizard_legs"], features["legs"])
		READ_FILE_EXVAR(S["feature_moth_wings"], features["moth_wings"])
		READ_FILE_EXVAR(S["feature_ipc_screen"], features["ipc_screen"])
		READ_FILE_EXVAR(S["feature_ipc_antenna"], features["ipc_antenna"])
		READ_FILE_EXVAR(S["feature_ipc_chassis"], features["ipc_chassis"])
		READ_FILE_EXVAR(S["feature_insect_type"], features["insect_type"])
		READ_FILE_EXVAR(S["feature_human_tail"], features["tail_human"])
		READ_FILE_EXVAR(S["feature_human_ears"], features["ears"])

		var/list/custom_names = list()

		//Custom names
		for(var/custom_name_id in custom_name_types)
			var/savefile_slot_name = custom_name_id + "_name" //TODO remove this
			READ_FILE_EXVAR(S[savefile_slot_name], custom_names[custom_name_id])

		// Load prefs
		var/list/job_preferences = list()
		READ_FILE_EXVAR(S["job_preferences"], job_preferences)
		if(!job_preferences)
			job_preferences = list()
		// Quirks
		var/list/all_quirks = list()
		READ_FILE_EXVAR(S["all_quirks"], all_quirks)
		if(!all_quirks)
			all_quirks = list()
		// Gear
		var/list/equipped_gear
		READ_FILE_EXVAR(S["equipped_gear"], equipped_gear)
		if(!equipped_gear)
			equipped_gear = list()

		// Get the slot
		var/list/slot_list = splittext(character_dir, "character")
		var/slot_number = text2num(slot_list[2])

		var/querytext = {"
		INSERT INTO SS13_characters (
			slot,
			ckey,
			species,
			real_name,
			name_is_always_random,
			body_is_always_random,
			gender,
			age,
			hair_color,
			gradient_color,
			facial_hair_color,
			eye_color,
			skin_tone,
			hair_style_name,
			gradient_style,
			facial_style_name,
			underwear,
			underwear_color,
			undershirt,
			socks,
			backbag,
			jumpsuit_style,
			uplink_loc,
			features,
			custom_names,
			helmet_style,
			preferred_ai_core_display,
			preferred_security_department,
			joblessrole,
			job_preferences,
			all_quirks,
			equipped_gear
		) VALUES (
			[sanitizeSQL(slot_number)],
			[sanitizeSQL(owning_ckey)],
			[sanitizeSQL(species_id)],
			[sanitizeSQL(real_name)],
			[/* These cant be strings, the column type is BIT */][be_random_name ? 1 : 0],
			[be_random_body ? 1 : 0],
			[/* Back to normal */][sanitizeSQL(gender)],
			[sanitizeSQL(age)],
			[sanitizeSQL(hair_color)],
			[sanitizeSQL(gradient_color)],
			[sanitizeSQL(facial_hair_color)],
			[sanitizeSQL(eye_color)],
			[sanitizeSQL(skin_tone)],
			[sanitizeSQL(hair_style)],
			[sanitizeSQL(gradient_style)],
			[sanitizeSQL(facial_hair_style)],
			[sanitizeSQL(underwear)],
			[sanitizeSQL(underwear_color)],
			[sanitizeSQL(undershirt)],
			[sanitizeSQL(socks)],
			[sanitizeSQL(backbag)],
			[sanitizeSQL(jumpsuit_style)],
			[sanitizeSQL(uplink_spawn_loc)],
			[sanitizeSQL(json_encode(features))],
			[sanitizeSQL(json_encode(custom_names))],
			[sanitizeSQL(helmet_style)],
			[sanitizeSQL(preferred_ai_core_display)],
			[sanitizeSQL(prefered_security_department)],
			[sanitizeSQL(joblessrole)],
			[sanitizeSQL(json_encode(job_preferences))],
			[sanitizeSQL(json_encode(all_quirks))],
			[sanitizeSQL(json_encode(equipped_gear))]
		)
		"}

		var/DBQuery/query = GLOB.dbcon.NewQuery(querytext)
		query.Execute()
		var/em = query.ErrorMsg()
		if(em)
			log_info("Query error when processing [owning_ckey] | [em]")
			log_info("RAW QUERY: [querytext]")
			log_info("Sleeping for 10 seconds")
			sleep(100)
