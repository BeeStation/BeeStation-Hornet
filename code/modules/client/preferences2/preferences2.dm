/*

	Preferences 2 - Now with 100% more database

	This system evicts savefiles and uses the database for all playerdata storage.

	All "user" preferences must be stored as tags in the `SS13_preferences` table.
	Any boolean toggle preference (Show/Hide Deadchat for example) **MUST** be a bitflag toggle stored as a single toggles integer.
	This is to cut down on the amount of useless columns when you can pack up to 24 binary toggles into a single integer.
	NOTE: You cant go above 24. BYOND loses precision and you then break everything.

	All character customisation preferences must be saved in the `SS13_characters` table.
	All properties for character customisation must be tacked onto a [/datum/character_save], not the main prefs datum

	Failure to comply with this will result in being screamed at.
	- AA07

*/

// Defines for list sanity
#define READPREF_RAW(target, tag) if(prefmap[tag]) target = prefmap[tag]
#define READPREF_INT(target, tag) if(prefmap[tag]) target = text2num(prefmap[tag])

// Did you know byond has try/catch? We use it here so malformed JSON doesnt break the entire loading system
#define READPREF_JSONDEC(target, tag) \
	try {\
		if(prefmap[tag]) {\
			target = json_decode(prefmap[tag]);\
		};\
	} catch {\
		pass();\
	} // we dont need error handling where were going

/datum/preferences/proc/load_from_database()
	. = FALSE
	if(!SSdbcore.IsConnected())
		// TODO - Loading of sane defaults
		if (!length(key_bindings))
			key_bindings = deep_copy_list(GLOB.keybinding_list_by_key)
		if(Debugger?.enabled)
			toggles &= ~(PREFTOGGLE_SOUND_AMBIENCE | PREFTOGGLE_SOUND_SHIP_AMBIENCE | PREFTOGGLE_SOUND_LOBBY)
		return

	var/datum/DBQuery/read_player_data = SSdbcore.NewQuery(
		"SELECT CAST(preference_tag AS CHAR) AS ptag, preference_value FROM [format_table_name("preferences")] WHERE ckey=:ckey",
		list("ckey" = parent.ckey)
	)

	// K:pref tag | V:pref value
	var/list/prefmap = list() // dont rename this. trust me.

	if(!read_player_data.Execute())
		qdel(read_player_data)
		return
	else
		while(read_player_data.NextRow())
			prefmap[read_player_data.item[1]] = read_player_data.item[2]
		qdel(read_player_data)

	//general preferences
	READPREF_INT(default_slot, PREFERENCE_TAG_DEFAULT_SLOT)
	READPREF_INT(chat_toggles, PREFERENCE_TAG_CHAT_TOGGLES)
	READPREF_INT(toggles, PREFERENCE_TAG_TOGGLES)
	READPREF_INT(toggles2, PREFERENCE_TAG_TOGGLES2)
	READPREF_INT(clientfps, PREFERENCE_TAG_CLIENTFPS)
	READPREF_INT(parallax, PREFERENCE_TAG_PARALLAX)
	READPREF_INT(pixel_size, PREFERENCE_TAG_PIXELSIZE)
	READPREF_INT(tip_delay, PREFERENCE_TAG_TIP_DELAY)

	READPREF_RAW(asaycolor, PREFERENCE_TAG_ASAY_COLOUR)
	READPREF_RAW(ooccolor, PREFERENCE_TAG_OOC_COLOUR)
	READPREF_RAW(lastchangelog, PREFERENCE_TAG_LAST_CL)
	READPREF_RAW(UI_style, PREFERENCE_TAG_UI_STYLE)
	READPREF_RAW(outline_color, PREFERENCE_TAG_OUTLINE_COLOUR)
	READPREF_RAW(see_balloon_alerts, PREFERENCE_TAG_BALLOON_ALERTS)
	READPREF_RAW(scaling_method, PREFERENCE_TAG_SCALING_METHOD)
	READPREF_RAW(ghost_form, PREFERENCE_TAG_GHOST_FORM)
	READPREF_RAW(ghost_orbit, PREFERENCE_TAG_GHOST_ORBIT)
	READPREF_RAW(ghost_accs, PREFERENCE_TAG_GHOST_ACCS)
	READPREF_RAW(ghost_others, PREFERENCE_TAG_GHOST_OTHERS)
	READPREF_RAW(pda_theme, PREFERENCE_TAG_PDA_THEME)
	READPREF_RAW(pda_color, PREFERENCE_TAG_PDA_COLOUR)
	READPREF_RAW(pai_name, PREFERENCE_TAG_PAI_NAME)
	READPREF_RAW(pai_description, PREFERENCE_TAG_PAI_DESCRIPTION)
	READPREF_RAW(pai_comment, PREFERENCE_TAG_PAI_COMMENT)

	READPREF_JSONDEC(ignoring, PREFERENCE_TAG_IGNORING)
	READPREF_JSONDEC(key_bindings, PREFERENCE_TAG_KEYBINDS)
	READPREF_JSONDEC(purchased_gear, PREFERENCE_TAG_PURCHASED_GEAR)
	READPREF_JSONDEC(be_special, PREFERENCE_TAG_BE_SPECIAL)

	//Sanitize
	asaycolor		= sanitize_ooccolor(sanitize_hexcolor(asaycolor, 6, TRUE, initial(asaycolor)))
	ooccolor		= sanitize_ooccolor(sanitize_hexcolor(ooccolor, 6, TRUE, initial(ooccolor)))
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	UI_style		= sanitize_inlist(UI_style, GLOB.available_ui_styles, GLOB.available_ui_styles[1])

	default_slot	= sanitize_integer(default_slot, TRUE, TRUE_MAX_SAVE_SLOTS, initial(default_slot))
	toggles			= sanitize_integer(toggles, FALSE, INFINITY, initial(toggles)) // yes
	toggles2		= sanitize_integer(toggles2, FALSE, INFINITY, initial(toggles2))
	clientfps		= sanitize_integer(clientfps, FALSE, 1000, FALSE)
	parallax		= sanitize_integer(parallax, PARALLAX_INSANE, PARALLAX_DISABLE, null)

	pixel_size		= sanitize_float(pixel_size, PIXEL_SCALING_AUTO, PIXEL_SCALING_3X, 0.5, initial(pixel_size))
	scaling_method  = sanitize_text(scaling_method, initial(scaling_method))
	ghost_form		= sanitize_inlist(ghost_form, GLOB.ghost_forms, initial(ghost_form))
	ghost_orbit 	= sanitize_inlist(ghost_orbit, GLOB.ghost_orbits, initial(ghost_orbit))
	ghost_accs		= sanitize_inlist(ghost_accs, GLOB.ghost_accs_options, GHOST_ACCS_DEFAULT_OPTION)
	ghost_others	= sanitize_inlist(ghost_others, GLOB.ghost_others_options, GHOST_OTHERS_DEFAULT_OPTION)
	be_special		= SANITIZE_LIST(be_special)

	pda_theme		= sanitize_inlist(pda_theme, GLOB.ntos_device_themes_default_content, initial(pda_theme))
	pda_color		= sanitize_hexcolor(pda_color, 6, TRUE, initial(pda_color))

	pai_name		= sanitize_text(pai_name, initial(pai_name))
	pai_description	= sanitize_text(pai_description, initial(pai_description))
	pai_comment		= sanitize_text(pai_comment, initial(pai_comment))

	key_bindings 	= sanitize_islist(key_bindings, deep_copy_list(GLOB.keybinding_list_by_key))
	if (!length(key_bindings))
		key_bindings = deep_copy_list(GLOB.keybinding_list_by_key)
	else
		var/any_changed = FALSE
		for(var/key_name in GLOB.keybindings_by_name)
			var/datum/keybinding/keybind = GLOB.keybindings_by_name[key_name]
			var/in_binds = FALSE
			for(var/bind in key_bindings)
				if(key_name in key_bindings[bind])
					in_binds = TRUE
					break
			if(in_binds)
				continue
			any_changed = TRUE
			if(!islist(key_bindings[keybind.key]))
				key_bindings[keybind.key] = list(key_name)
			else
				key_bindings[keybind.key] += key_name
		if(any_changed)
			save_keybinds()

	if(!purchased_gear)
		purchased_gear = list()

	return TRUE

#undef READPREF_RAW
#undef READPREF_INT
#undef READPREF_JSONDEC

// OH BOY MORE MACRO ABUSE
#define PREP_WRITEPREF_RAW(value, tag) write_queries += SSdbcore.NewQuery("INSERT INTO [format_table_name("preferences")] (ckey, preference_tag, preference_value) VALUES (:ckey, :ptag, :pvalue) ON DUPLICATE KEY UPDATE preference_value=:pvalue2", list("ckey" = parent.ckey, "ptag" = tag, "pvalue" = value, "pvalue2" = value))
#define PREP_WRITEPREF_JSONENC(value, tag) PREP_WRITEPREF_RAW(json_encode(value), tag)

/datum/preferences/proc/save_keybinds()
	var/list/datum/DBQuery/write_queries = list()
	PREP_WRITEPREF_JSONENC(key_bindings, PREFERENCE_TAG_KEYBINDS)
	SSdbcore.QuerySelect(write_queries, TRUE, TRUE)

// Writes all prefs to the DB
/datum/preferences/proc/save_preferences()
	if(!SSdbcore.IsConnected())
		return

	if(IS_GUEST_KEY(parent.ckey))
		return

	var/list/datum/DBQuery/write_queries = list() // do not rename this you muppet

	//general preferences
	PREP_WRITEPREF_RAW(default_slot, PREFERENCE_TAG_DEFAULT_SLOT)
	PREP_WRITEPREF_RAW(chat_toggles, PREFERENCE_TAG_CHAT_TOGGLES)
	PREP_WRITEPREF_RAW(toggles, PREFERENCE_TAG_TOGGLES)
	PREP_WRITEPREF_RAW(toggles2, PREFERENCE_TAG_TOGGLES2)
	PREP_WRITEPREF_RAW(clientfps, PREFERENCE_TAG_CLIENTFPS)
	PREP_WRITEPREF_RAW(parallax, PREFERENCE_TAG_PARALLAX)
	PREP_WRITEPREF_RAW(pixel_size, PREFERENCE_TAG_PIXELSIZE)
	PREP_WRITEPREF_RAW(tip_delay, PREFERENCE_TAG_TIP_DELAY)
	PREP_WRITEPREF_RAW(pda_theme, PREFERENCE_TAG_PDA_THEME)
	PREP_WRITEPREF_RAW(pda_color, PREFERENCE_TAG_PDA_COLOUR)

	PREP_WRITEPREF_RAW(asaycolor, PREFERENCE_TAG_ASAY_COLOUR)
	PREP_WRITEPREF_RAW(ooccolor, PREFERENCE_TAG_OOC_COLOUR)
	PREP_WRITEPREF_RAW(lastchangelog, PREFERENCE_TAG_LAST_CL)
	PREP_WRITEPREF_RAW(UI_style, PREFERENCE_TAG_UI_STYLE)
	PREP_WRITEPREF_RAW(outline_color, PREFERENCE_TAG_OUTLINE_COLOUR)
	PREP_WRITEPREF_RAW(see_balloon_alerts, PREFERENCE_TAG_BALLOON_ALERTS)
	PREP_WRITEPREF_RAW(scaling_method, PREFERENCE_TAG_SCALING_METHOD)
	PREP_WRITEPREF_RAW(ghost_form, PREFERENCE_TAG_GHOST_FORM)
	PREP_WRITEPREF_RAW(ghost_orbit, PREFERENCE_TAG_GHOST_ORBIT)
	PREP_WRITEPREF_RAW(ghost_accs, PREFERENCE_TAG_GHOST_ACCS)
	PREP_WRITEPREF_RAW(ghost_others, PREFERENCE_TAG_GHOST_OTHERS)
	PREP_WRITEPREF_RAW(pai_name, PREFERENCE_TAG_PAI_NAME)
	PREP_WRITEPREF_RAW(pai_description, PREFERENCE_TAG_PAI_DESCRIPTION)
	PREP_WRITEPREF_RAW(pai_comment, PREFERENCE_TAG_PAI_COMMENT)

	PREP_WRITEPREF_JSONENC(ignoring, PREFERENCE_TAG_IGNORING)
	PREP_WRITEPREF_JSONENC(key_bindings, PREFERENCE_TAG_KEYBINDS)
	PREP_WRITEPREF_JSONENC(purchased_gear, PREFERENCE_TAG_PURCHASED_GEAR)
	PREP_WRITEPREF_JSONENC(be_special, PREFERENCE_TAG_BE_SPECIAL)

	// QuerySelect can execute many queries at once. That name is dumb but w/e
	SSdbcore.QuerySelect(write_queries, TRUE, TRUE)

#undef PREP_WRITEPREF_RAW
#undef PREP_WRITEPREF_JSONENC


// Get ready for a disgusting SQL query
/datum/preferences/proc/load_characters()
	// Do NOT remove stuff from the start of this query. Only append to the end.
	// If you delete an entry, god help you as you have to update all the indexes
	var/datum/DBQuery/read_chars = SSdbcore.NewQuery({"
		SELECT
			slot,
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
		FROM [format_table_name("characters")] WHERE
			ckey=:ckey
	"}, list("ckey" = parent.ckey))

	if(!read_chars.warn_execute())
		qdel(read_chars)
		return

	var/char_loaded = FALSE
	while(read_chars.NextRow())
		var/idx = read_chars.item[1]
		var/datum/character_save/CS = character_saves[idx]
		CS.handle_query(read_chars)
		char_loaded = TRUE

	qdel(read_chars)
	check_usable_slots()
	return char_loaded


/datum/preferences/proc/check_usable_slots()
	for(var/datum/character_save/CS as anything in character_saves)
		CS.slot_locked = (CS.slot_number > max_usable_slots)
