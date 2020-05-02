//This is the lowest supported version, anything below this is completely obsolete and the entire savefile will be wiped.
#define SAVEFILE_VERSION_MIN	18

//This is the current version, anything below this will attempt to update (if it's not obsolete)
//	You do not need to raise this if you are adding new values that have sane defaults.
//	Only raise this value when changing the meaning/format/name/layout of an existing value
//	where you would want the updater procs below to run
#define SAVEFILE_VERSION_MAX	29

/*
SAVEFILE UPDATING/VERSIONING - 'Simplified', or rather, more coder-friendly ~Carn
	This proc checks if the current directory of the savefile S needs updating
	It is to be used by the load_character and load_preferences procs.
	(S.cd=="/" is preferences, S.cd=="/character[integer]" is a character slot, etc)

	if the current directory's version is below SAVEFILE_VERSION_MIN it will simply wipe everything in that directory
	(if we're at root "/" then it'll just wipe the entire savefile, for instance.)

	if its version is below SAVEFILE_VERSION_MAX but above the minimum, it will load data but later call the
	respective update_preferences() or update_character() proc.
	Those procs allow coders to specify format changes so users do not lose their setups and have to redo them again.

	Failing all that, the standard sanity checks are performed. They simply check the data is suitable, reverting to
	initial() values if necessary.
*/
/datum/preferences/proc/savefile_needs_update(savefile/S)
	var/savefile_version
	S["version"] >> savefile_version

	if(savefile_version < SAVEFILE_VERSION_MIN)
		S.dir.Cut()
		return -2
	if(savefile_version < SAVEFILE_VERSION_MAX)
		return savefile_version
	return -1

//should these procs get fairly long
//just increase SAVEFILE_VERSION_MIN so it's not as far behind
//SAVEFILE_VERSION_MAX and then delete any obsolete if clauses
//from these procs.
//This only really meant to avoid annoying frequent players
//if your savefile is 3 months out of date, then 'tough shit'.

/datum/preferences/proc/update_preferences(current_version, savefile/S)
	if(current_version < 29)
		overhead_chat = TRUE
	return

/datum/preferences/proc/update_character(current_version, savefile/S)
	if(current_version < 19)
		pda_style = "mono"
	if(current_version < 20)
		pda_color = "#808000"
	if((current_version < 21) && features["ethcolor"] && (features["ethcolor"] == "#9c3030"))
		features["ethcolor"] = "9c3030"
	if(current_version < 22)
		job_preferences = list() //It loaded null from nonexistant savefile field.
		var/job_civilian_high = 0
		var/job_civilian_med = 0
		var/job_civilian_low = 0

		var/job_medsci_high = 0
		var/job_medsci_med = 0
		var/job_medsci_low = 0

		var/job_engsec_high = 0
		var/job_engsec_med = 0
		var/job_engsec_low = 0




		S["job_civilian_high"]	>> job_civilian_high
		S["job_civilian_med"]	>> job_civilian_med
		S["job_civilian_low"]	>> job_civilian_low
		S["job_medsci_high"]	>> job_medsci_high
		S["job_medsci_med"]		>> job_medsci_med
		S["job_medsci_low"]		>> job_medsci_low
		S["job_engsec_high"]	>> job_engsec_high
		S["job_engsec_med"]		>> job_engsec_med
		S["job_engsec_low"]		>> job_engsec_low

		//Can't use SSjob here since this happens right away on login
		for(var/job in subtypesof(/datum/job))
			var/datum/job/J = job
			var/new_value
			var/fval = initial(J.flag)
			switch(initial(J.department_flag))
				if(CIVILIAN)
					if(job_civilian_high & fval)
						new_value = JP_HIGH
					else if(job_civilian_med & fval)
						new_value = JP_MEDIUM
					else if(job_civilian_low & fval)
						new_value = JP_LOW
				if(MEDSCI)
					if(job_medsci_high & fval)
						new_value = JP_HIGH
					else if(job_medsci_med & fval)
						new_value = JP_MEDIUM
					else if(job_medsci_low & fval)
						new_value = JP_LOW
				if(ENGSEC)
					if(job_engsec_high & fval)
						new_value = JP_HIGH
					else if(job_engsec_med & fval)
						new_value = JP_MEDIUM
					else if(job_engsec_low & fval)
						new_value = JP_LOW
			if(new_value)
				job_preferences[initial(J.title)] = new_value

	if(current_version < 25)
		key_bindings = deepCopyList(GLOB.keybinding_list_by_key)
		WRITE_FILE(S["key_bindings"], key_bindings)
	if(current_version < 27)
		if (!(underwear in GLOB.underwear_list))
			underwear = "Nude"

/datum/preferences/proc/load_path(ckey,filename="preferences.sav")
	if(!ckey)
		return
	path = "data/player_saves/[copytext(ckey,1,2)]/[ckey]/[filename]"

/datum/preferences/proc/load_preferences()
	if(!path)
		return 0
	if(!fexists(path))
		return 0

	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	S.cd = "/"

	var/needs_update = savefile_needs_update(S)
	if(needs_update == -2)		//fatal, can't load any data
		return 0

	//general preferences
	S["asaycolor"]			>> asaycolor
	S["ooccolor"]			>> ooccolor
	S["lastchangelog"]		>> lastchangelog
	S["UI_style"]			>> UI_style
	S["overhead_chat"]		>> overhead_chat
	S["hotkeys"]			>> hotkeys
	S["tgui_fancy"]			>> tgui_fancy
	S["tgui_lock"]			>> tgui_lock
	S["buttons_locked"]		>> buttons_locked
	S["windowflash"]		>> windowflashing
	S["be_special"] 		>> be_special

	S["crew_objectives"]	>> crew_objectives


	S["default_slot"]		>> default_slot
	S["chat_toggles"]		>> chat_toggles
	S["toggles"]			>> toggles
	S["ghost_form"]			>> ghost_form
	S["ghost_orbit"]		>> ghost_orbit
	S["ghost_accs"]			>> ghost_accs
	S["ghost_others"]		>> ghost_others
	S["preferred_map"]		>> preferred_map
	S["ignoring"]			>> ignoring
	S["ghost_hud"]			>> ghost_hud
	S["inquisitive_ghost"]	>> inquisitive_ghost
	S["uses_glasses_colour"]>> uses_glasses_colour
	S["clientfps"]			>> clientfps
	S["parallax"]			>> parallax
	S["ambientocclusion"]	>> ambientocclusion
	S["auto_fit_viewport"]	>> auto_fit_viewport
	S["menuoptions"]		>> menuoptions
	S["enable_tips"]		>> enable_tips
	S["tip_delay"]			>> tip_delay
	S["pda_style"]			>> pda_style
	S["pda_color"]			>> pda_color
	S["show_credits"] >> show_credits

	S["key_bindings"]		>> key_bindings

	S["purchased_gear"]					>> purchased_gear
	S["equipped_gear"]					>> equipped_gear

	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_preferences(needs_update, S)		//needs_update = savefile_version if we need an update (positive integer)

	//Sanitize
	asaycolor		= sanitize_ooccolor(sanitize_hexcolor(asaycolor, 6, 1, initial(asaycolor)))
	ooccolor		= sanitize_ooccolor(sanitize_hexcolor(ooccolor, 6, 1, initial(ooccolor)))
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	UI_style		= sanitize_inlist(UI_style, GLOB.available_ui_styles, GLOB.available_ui_styles[1])
	hotkeys			= sanitize_integer(hotkeys, 0, 1, initial(hotkeys))
	tgui_fancy		= sanitize_integer(tgui_fancy, 0, 1, initial(tgui_fancy))
	tgui_lock		= sanitize_integer(tgui_lock, 0, 1, initial(tgui_lock))
	buttons_locked	= sanitize_integer(buttons_locked, 0, 1, initial(buttons_locked))
	windowflashing		= sanitize_integer(windowflashing, 0, 1, initial(windowflashing))
	default_slot	= sanitize_integer(default_slot, 1, max_save_slots, initial(default_slot))
	toggles			= sanitize_integer(toggles, 0, 65535, initial(toggles))
	clientfps		= sanitize_integer(clientfps, 0, 1000, 0)
	parallax		= sanitize_integer(parallax, PARALLAX_INSANE, PARALLAX_DISABLE, null)
	ambientocclusion	= sanitize_integer(ambientocclusion, 0, 1, initial(ambientocclusion))
	auto_fit_viewport	= sanitize_integer(auto_fit_viewport, 0, 1, initial(auto_fit_viewport))
	ghost_form		= sanitize_inlist(ghost_form, GLOB.ghost_forms, initial(ghost_form))
	ghost_orbit 	= sanitize_inlist(ghost_orbit, GLOB.ghost_orbits, initial(ghost_orbit))
	ghost_accs		= sanitize_inlist(ghost_accs, GLOB.ghost_accs_options, GHOST_ACCS_DEFAULT_OPTION)
	ghost_others	= sanitize_inlist(ghost_others, GLOB.ghost_others_options, GHOST_OTHERS_DEFAULT_OPTION)
	menuoptions		= SANITIZE_LIST(menuoptions)
	be_special		= SANITIZE_LIST(be_special)
	crew_objectives		= sanitize_integer(crew_objectives, 0, 1, initial(crew_objectives))
	pda_style		= sanitize_inlist(pda_style, GLOB.pda_styles, initial(pda_style))
	pda_color		= sanitize_hexcolor(pda_color, 6, 1, initial(pda_color))
	show_credits		= sanitize_integer(show_credits, 0, 1, initial(show_credits))

	key_bindings 	= sanitize_islist(key_bindings, deepCopyList(GLOB.keybinding_list_by_key))
	if (!key_bindings)
		key_bindings = deepCopyList(GLOB.keybinding_list_by_key)

	if(!purchased_gear)
		purchased_gear = list()
	if(!equipped_gear)
		equipped_gear = list()

	return 1

/datum/preferences/proc/save_preferences()
	if(!path)
		return 0
	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	S.cd = "/"

	WRITE_FILE(S["version"] , SAVEFILE_VERSION_MAX)		//updates (or failing that the sanity checks) will ensure data is not invalid at load. Assume up-to-date

	//general preferences
	WRITE_FILE(S["asaycolor"], asaycolor)
	WRITE_FILE(S["ooccolor"], ooccolor)
	WRITE_FILE(S["lastchangelog"], lastchangelog)
	WRITE_FILE(S["UI_style"], UI_style)
	WRITE_FILE(S["overhead_chat"], overhead_chat)
	WRITE_FILE(S["hotkeys"], hotkeys)
	WRITE_FILE(S["tgui_fancy"], tgui_fancy)
	WRITE_FILE(S["tgui_lock"], tgui_lock)
	WRITE_FILE(S["buttons_locked"], buttons_locked)
	WRITE_FILE(S["windowflash"], windowflashing)
	WRITE_FILE(S["be_special"], be_special)
	WRITE_FILE(S["crew_objectives"], crew_objectives)
	WRITE_FILE(S["default_slot"], default_slot)
	WRITE_FILE(S["toggles"], toggles)
	WRITE_FILE(S["chat_toggles"], chat_toggles)
	WRITE_FILE(S["ghost_form"], ghost_form)
	WRITE_FILE(S["ghost_orbit"], ghost_orbit)
	WRITE_FILE(S["ghost_accs"], ghost_accs)
	WRITE_FILE(S["ghost_others"], ghost_others)
	WRITE_FILE(S["preferred_map"], preferred_map)
	WRITE_FILE(S["ignoring"], ignoring)
	WRITE_FILE(S["ghost_hud"], ghost_hud)
	WRITE_FILE(S["inquisitive_ghost"], inquisitive_ghost)
	WRITE_FILE(S["uses_glasses_colour"], uses_glasses_colour)
	WRITE_FILE(S["clientfps"], clientfps)
	WRITE_FILE(S["parallax"], parallax)
	WRITE_FILE(S["ambientocclusion"], ambientocclusion)
	WRITE_FILE(S["auto_fit_viewport"], auto_fit_viewport)
	WRITE_FILE(S["menuoptions"], menuoptions)
	WRITE_FILE(S["enable_tips"], enable_tips)
	WRITE_FILE(S["tip_delay"], tip_delay)
	WRITE_FILE(S["pda_style"], pda_style)
	WRITE_FILE(S["pda_color"], pda_color)
	WRITE_FILE(S["show_credits"], show_credits)
	WRITE_FILE(S["purchased_gear"], purchased_gear)
	WRITE_FILE(S["equipped_gear"], equipped_gear)

	if (!key_bindings)
		key_bindings = deepCopyList(GLOB.keybinding_list_by_key)
	WRITE_FILE(S["key_bindings"], key_bindings)
	return 1

/datum/preferences/proc/load_character(slot)
	if(!path)
		return 0
	if(!fexists(path))
		return 0
	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	S.cd = "/"
	if(!slot)
		slot = default_slot
	slot = sanitize_integer(slot, 1, max_save_slots, initial(default_slot))
	if(slot != default_slot)
		default_slot = slot
		WRITE_FILE(S["default_slot"] , slot)

	S.cd = "/character[slot]"
	var/needs_update = savefile_needs_update(S)
	if(needs_update == -2)		//fatal, can't load any data
		return 0

	//Species
	var/species_id
	S["species"]			>> species_id
	if(species_id)
		var/newtype = GLOB.species_list[species_id]
		if(newtype)
			pref_species = new newtype

	if(!S["features["mcolor"]"] || S["features["mcolor"]"] == "#000")
		WRITE_FILE(S["features["mcolor"]"]	, "#FFF")

	if(!S["feature_ethcolor"] || S["feature_ethcolor"] == "#000")
		WRITE_FILE(S["feature_ethcolor"]	, "9c3030")

	//Character
	S["real_name"]			>> real_name
	S["name_is_always_random"] >> be_random_name
	S["body_is_always_random"] >> be_random_body
	S["gender"]				>> gender
	S["age"]				>> age
	S["hair_color"]			>> hair_color
	S["facial_hair_color"]	>> facial_hair_color
	S["eye_color"]			>> eye_color
	S["skin_tone"]			>> skin_tone
	S["hair_style_name"]	>> hair_style
	S["facial_style_name"]	>> facial_hair_style
	S["underwear"]			>> underwear
	S["underwear_color"]	>> underwear_color
	S["undershirt"]			>> undershirt
	S["socks"]				>> socks
	S["backbag"]			>> backbag
	S["uplink_loc"]			>> uplink_spawn_loc
	S["feature_mcolor"]					>> features["mcolor"]
	S["feature_ethcolor"]					>> features["ethcolor"]
	S["feature_lizard_tail"]			>> features["tail_lizard"]
	S["feature_lizard_snout"]			>> features["snout"]
	S["feature_lizard_horns"]			>> features["horns"]
	S["feature_lizard_frills"]			>> features["frills"]
	S["feature_lizard_spines"]			>> features["spines"]
	S["feature_lizard_body_markings"]	>> features["body_markings"]
	S["feature_lizard_legs"]			>> features["legs"]
	S["feature_moth_wings"]				>> features["moth_wings"]
	S["feature_ipc_screen"]			>> features["ipc_screen"]
	S["feature_ipc_antenna"]				>> features["ipc_antenna"]
	S["feature_ipc_chassis"]				>> features["ipc_chassis"]
	S["feature_insect_type"]				>> features["insect_type"]
	if(!CONFIG_GET(flag/join_with_mutant_humans)  && !species_id != "felinid") // felinids arent mutant humans anymore i guess
		features["tail_human"] = "none"
		features["ears"] = "none"
	else
		S["feature_human_tail"]				>> features["tail_human"]
		S["feature_human_ears"]				>> features["ears"]

	//Custom names
	for(var/custom_name_id in GLOB.preferences_custom_names)
		var/savefile_slot_name = custom_name_id + "_name" //TODO remove this
		S[savefile_slot_name] >> custom_names[custom_name_id]

	S["preferred_ai_core_display"] >> preferred_ai_core_display
	S["prefered_security_department"] >> prefered_security_department

	//Jobs
	S["joblessrole"]		>> joblessrole
	//Load prefs
	S["job_preferences"] >> job_preferences

	//Quirks
	S["all_quirks"]			>> all_quirks

	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_character(needs_update, S)		//needs_update == savefile_version if we need an update (positive integer)

	//Sanitize

	real_name = reject_bad_name(real_name, pref_species.allow_numbers_in_name)
	gender = sanitize_gender(gender)
	if(!real_name)
		real_name = random_unique_name(gender)

	for(var/custom_name_id in GLOB.preferences_custom_names)
		var/namedata = GLOB.preferences_custom_names[custom_name_id]
		custom_names[custom_name_id] = reject_bad_name(custom_names[custom_name_id],namedata["allow_numbers"])
		if(!custom_names[custom_name_id])
			custom_names[custom_name_id] = get_default_name(custom_name_id)

	if(!features["mcolor"] || features["mcolor"] == "#000")
		features["mcolor"] = pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F")

	if(!features["ethcolor"] || features["ethcolor"] == "#000")
		features["ethcolor"] = GLOB.color_list_ethereal[pick(GLOB.color_list_ethereal)]

	be_random_name	= sanitize_integer(be_random_name, 0, 1, initial(be_random_name))
	be_random_body	= sanitize_integer(be_random_body, 0, 1, initial(be_random_body))

	if(gender == MALE)
		hair_style			= sanitize_inlist(hair_style, GLOB.hair_styles_male_list)
		facial_hair_style			= sanitize_inlist(facial_hair_style, GLOB.facial_hair_styles_male_list)
		underwear		= sanitize_inlist(underwear, GLOB.underwear_m)
		undershirt 		= sanitize_inlist(undershirt, GLOB.undershirt_m)
	else
		hair_style			= sanitize_inlist(hair_style, GLOB.hair_styles_female_list)
		facial_hair_style			= sanitize_inlist(facial_hair_style, GLOB.facial_hair_styles_female_list)
		underwear		= sanitize_inlist(underwear, GLOB.underwear_f)
		undershirt		= sanitize_inlist(undershirt, GLOB.undershirt_f)
	socks			= sanitize_inlist(socks, GLOB.socks_list)
	age				= sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	hair_color			= sanitize_hexcolor(hair_color, 3, 0)
	facial_hair_color			= sanitize_hexcolor(facial_hair_color, 3, 0)
	underwear_color			= sanitize_hexcolor(underwear_color, 3, 0)
	eye_color		= sanitize_hexcolor(eye_color, 3, 0)
	skin_tone		= sanitize_inlist(skin_tone, GLOB.skin_tones)
	backbag			= sanitize_inlist(backbag, GLOB.backbaglist, initial(backbag))
	uplink_spawn_loc = sanitize_inlist(uplink_spawn_loc, GLOB.uplink_spawn_loc_list, initial(uplink_spawn_loc))
	features["mcolor"]	= sanitize_hexcolor(features["mcolor"], 3, 0)
	features["ethcolor"]	= copytext(features["ethcolor"],1,7)
	features["tail_lizard"]	= sanitize_inlist(features["tail_lizard"], GLOB.tails_list_lizard)
	features["tail_human"] 	= sanitize_inlist(features["tail_human"], GLOB.tails_list_human, "None")
	features["snout"]	= sanitize_inlist(features["snout"], GLOB.snouts_list)
	features["horns"] 	= sanitize_inlist(features["horns"], GLOB.horns_list)
	features["ears"]	= sanitize_inlist(features["ears"], GLOB.ears_list, "None")
	features["frills"] 	= sanitize_inlist(features["frills"], GLOB.frills_list)
	features["spines"] 	= sanitize_inlist(features["spines"], GLOB.spines_list)
	features["body_markings"] 	= sanitize_inlist(features["body_markings"], GLOB.body_markings_list)
	features["feature_lizard_legs"]	= sanitize_inlist(features["legs"], GLOB.legs_list, "Normal Legs")
	features["moth_wings"] 	= sanitize_inlist(features["moth_wings"], GLOB.moth_wings_list, "Plain")
	features["ipc_screen"]	= sanitize_inlist(features["ipc_screen"], GLOB.ipc_screens_list)
	features["ipc_antenna"]	 = sanitize_inlist(features["ipc_antenna"], GLOB.ipc_antennas_list)
	features["ipc_chassis"]	 = sanitize_inlist(features["ipc_chassis"], GLOB.ipc_chassis_list)
	features["insect_type"]	 = sanitize_inlist(features["insect_type"], GLOB.insect_type_list)

	joblessrole	= sanitize_integer(joblessrole, 1, 3, initial(joblessrole))
	//Validate job prefs
	for(var/j in job_preferences)
		if(job_preferences[j] != JP_LOW && job_preferences[j] != JP_MEDIUM && job_preferences[j] != JP_HIGH)
			job_preferences -= j

	all_quirks = SANITIZE_LIST(all_quirks)

	return 1

/datum/preferences/proc/save_character()
	if(!path)
		return 0
	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	S.cd = "/character[default_slot]"

	WRITE_FILE(S["version"]			, SAVEFILE_VERSION_MAX)	//load_character will sanitize any bad data, so assume up-to-date.)

	//Character
	WRITE_FILE(S["feature_ipc_screen"], features["ipc_screen"])
	WRITE_FILE(S["feature_ipc_antenna"], features["ipc_antenna"])
	WRITE_FILE(S["real_name"]			, real_name)
	WRITE_FILE(S["name_is_always_random"] , be_random_name)
	WRITE_FILE(S["body_is_always_random"] , be_random_body)
	WRITE_FILE(S["gender"]				, gender)
	WRITE_FILE(S["age"]				, age)
	WRITE_FILE(S["hair_color"]			, hair_color)
	WRITE_FILE(S["facial_hair_color"]	, facial_hair_color)
	WRITE_FILE(S["eye_color"]			, eye_color)
	WRITE_FILE(S["skin_tone"]			, skin_tone)
	WRITE_FILE(S["hair_style_name"]	, hair_style)
	WRITE_FILE(S["facial_style_name"]	, facial_hair_style)
	WRITE_FILE(S["underwear"]			, underwear)
	WRITE_FILE(S["underwear_color"]		, underwear_color)
	WRITE_FILE(S["undershirt"]			, undershirt)
	WRITE_FILE(S["socks"]				, socks)
	WRITE_FILE(S["backbag"]			, backbag)
	WRITE_FILE(S["uplink_loc"]			, uplink_spawn_loc)
	WRITE_FILE(S["species"]			, pref_species.id)
	WRITE_FILE(S["feature_mcolor"]					, features["mcolor"])
	WRITE_FILE(S["feature_ethcolor"]					, features["ethcolor"])
	WRITE_FILE(S["feature_lizard_tail"]			, features["tail_lizard"])
	WRITE_FILE(S["feature_human_tail"]				, features["tail_human"])
	WRITE_FILE(S["feature_lizard_snout"]			, features["snout"])
	WRITE_FILE(S["feature_lizard_horns"]			, features["horns"])
	WRITE_FILE(S["feature_human_ears"]				, features["ears"])
	WRITE_FILE(S["feature_lizard_frills"]			, features["frills"])
	WRITE_FILE(S["feature_lizard_spines"]			, features["spines"])
	WRITE_FILE(S["feature_lizard_body_markings"]	, features["body_markings"])
	WRITE_FILE(S["feature_lizard_legs"]			, features["legs"])
	WRITE_FILE(S["feature_moth_wings"]			, features["moth_wings"])
	WRITE_FILE(S["feature_ipc_screen"]			, features["ipc_screen"])
	WRITE_FILE(S["feature_ipc_antenna"]			, features["ipc_antenna"])
	WRITE_FILE(S["feature_ipc_chassis"]			, features["ipc_chassis"])
	WRITE_FILE(S["feature_insect_type"]			, features["insect_type"])

	//Custom names
	for(var/custom_name_id in GLOB.preferences_custom_names)
		var/savefile_slot_name = custom_name_id + "_name" //TODO remove this
		WRITE_FILE(S[savefile_slot_name],custom_names[custom_name_id])

	WRITE_FILE(S["preferred_ai_core_display"] ,  preferred_ai_core_display)
	WRITE_FILE(S["prefered_security_department"] , prefered_security_department)

	//Jobs
	WRITE_FILE(S["joblessrole"]		, joblessrole)
	//Write prefs
	WRITE_FILE(S["job_preferences"] , job_preferences)

	//Quirks
	WRITE_FILE(S["all_quirks"]			, all_quirks)

	return 1


#undef SAVEFILE_VERSION_MAX
#undef SAVEFILE_VERSION_MIN

#ifdef TESTING
//DEBUG
//Some crude tools for testing savefiles
//path is the savefile path
/client/verb/savefile_export(path as text)
	var/savefile/S = new /savefile(path)
	S.ExportText("/",file("[path].txt"))
//path is the savefile path
/client/verb/savefile_import(path as text)
	var/savefile/S = new /savefile(path)
	S.ImportText("/",file("[path].txt"))

#endif
