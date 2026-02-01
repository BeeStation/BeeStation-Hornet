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

	// Gear is a global preference and needs to be handled separately
	var/list/equipped_gear
	READ_FILE_EXVAR(S["equipped_gear"], equipped_gear)
	if(!equipped_gear)
		equipped_gear = list()

	for(var/character_dir in cdirs)
		S.cd = "/[character_dir]"

		READ_FILE(S["species"], species_id, "human")
		READ_FILE(S["real_name"], real_name, "Unnamed Character")
		READ_FILE(S["name_is_always_random"], be_random_name, FALSE)
		READ_FILE(S["body_is_always_random"], be_random_body, FALSE)
		READ_FILE(S["gender"], gender, MALE)
		READ_FILE(S["age"], age, 30)
		READ_FILE(S["hair_color"], hair_color, COLOR_BLACK)
		READ_FILE(S["gradient_color"], gradient_color, COLOR_BLACK)
		READ_FILE(S["facial_hair_color"], facial_hair_color, COLOR_BLACK)
		READ_FILE(S["eye_color"], eye_color, COLOR_BLACK)
		READ_FILE(S["skin_tone"], skin_tone, "caucasian1")
		READ_FILE(S["hair_style_name"], hair_style, "Bald")
		READ_FILE(S["gradient_style"], gradient_style, "None")
		READ_FILE(S["facial_style_name"], facial_hair_style, "Shaved")
		READ_FILE(S["underwear"], underwear, "Nude") // lewd
		READ_FILE(S["underwear_color"], underwear_color, COLOR_BLACK)
		READ_FILE(S["undershirt"], undershirt, "Nude")
		READ_FILE(S["socks"], socks, "Nude") // :flooshed:
		READ_FILE(S["backbag"], backbag, "Department Backpack")
		READ_FILE(S["jumpsuit_style"], jumpsuit_style, "Jumpsuit")
		READ_FILE(S["uplink_loc"], uplink_spawn_loc, "PDA")
		READ_FILE(S["helmet_style"], helmet_style, "Default")
		READ_FILE(S["preferred_ai_core_display"], preferred_ai_core_display, "Blue")
		// I will kill whoever couldnt spell this
		READ_FILE(S["preferred_security_department"], preferred_security_department, "Random")
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
		READ_FILE_EXVAR(S["feature_apid_antenna"], features["apid_antenna"])
		READ_FILE_EXVAR(S["feature_apid_stripes"], features["apid_stripes"])
		READ_FILE_EXVAR(S["feature_apid_headstripes"], features["apid_headstripes"])
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
			:slotnum,
			:ckey,
			:speciesid,
			:realname,
			:randomname,
			:randombody,
			:gender,
			:age,
			:haircolour,
			:gradientcolour,
			:facialhaircolour,
			:eyecolour,
			:skintone,
			:hairstyle,
			:gradientstyle,
			:facialhairstyle,
			:underwear,
			:underwearcolour,
			:undershirt,
			:socks,
			:backbag,
			:jumpsuitstyle,
			:uplinkloc,
			:features,
			:customnames,
			:helmetstyle,
			:aicore,
			:secdept,
			:joblessrole,
			:jobprefs,
			:allquirks,
			:gear
		)
		"}

		var/list/qargs = list(
			"slotnum" = slot_number,
			"ckey" = owning_ckey,
			"speciesid" = species_id,
			"realname" = real_name,
			"randomname" = be_random_name,
			"randombody" = be_random_body,
			"gender" = gender,
			"age" = age,
			"haircolour" = hair_color,
			"gradientcolour" = gradient_color,
			"facialhaircolour" = facial_hair_color,
			"eyecolour" = eye_color,
			"skintone" = skin_tone,
			"hairstyle" = hair_style,
			"gradientstyle" = gradient_style,
			"facialhairstyle" = facial_hair_style,
			"underwear" = underwear,
			"underwearcolour" = underwear_color,
			"undershirt" = undershirt,
			"socks" = socks,
			"backbag" = backbag,
			"jumpsuitstyle" = jumpsuit_style,
			"uplinkloc" = uplink_spawn_loc,
			"features" = json_encode(features),
			"customnames" = json_encode(custom_names),
			"helmetstyle" = helmet_style,
			"aicore" = preferred_ai_core_display,
			"secdept" = preferred_security_department,
			"joblessrole" = joblessrole,
			"jobprefs" = json_encode(job_preferences),
			"allquirks" = json_encode(all_quirks),
			"gear" = json_encode(equipped_gear)
		)

		var/datum/db_query/query = new_db_query(querytext, qargs)
		query.Execute()
		var/em = query.ErrorMsg()
		if(em)
			log_info("Query error when processing [owning_ckey] | [em]")
			log_info("RAW QUERY: [querytext]")
			log_info("Sleeping for 10 seconds")
			sleep(100)

#undef READ_FILE
#undef READ_FILE_EXVAR
