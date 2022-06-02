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
#define READPREF_RAW(target, tag) if(num2text(tag) in prefmap) target = prefmap[num2text(tag)]
#define READPREF_INT(target, tag) if(num2text(tag) in prefmap) target = text2num(prefmap[num2text(tag)])

// Did you know byond has try/catch? We use it here so malformed JSON doesnt break the entire loading system
#define READPREF_JSONDEC(target, tag) \
	try {\
		if(num2text(tag) in prefmap) {\
			target = json_decode(prefmap[num2text(tag)]);\
		};\
	} catch {\
		pass();\
	} // we dont need error handling where were going

/datum/preferences/proc/load_from_database()
	. = FALSE
	if(!SSdbcore.IsConnected())
		// TODO - Loading of sane defaults
		return

	var/datum/DBQuery/read_player_data = SSdbcore.NewQuery(
		"SELECT preference_tag, preference_value FROM [format_table_name("preferences")] WHERE ckey=:ckey",
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
	READPREF_RAW(asaycolor, PREFERENCE_TAG_ASAY_COLOUR)
	READPREF_RAW(ooccolor, PREFERENCE_TAG_OOC_COLOUR)
	READPREF_RAW(lastchangelog, PREFERENCE_TAG_LAST_CL)
	READPREF_RAW(UI_style, PREFERENCE_TAG_UI_STYLE)
	READPREF_RAW(outline_color, PREFERENCE_TAG_OUTLINE_COLOUR)

	// Do special list stuff here
	READPREF_RAW(see_balloon_alerts, PREFERENCE_TAG_BALLOON_ALERTS)

	READPREF_INT(default_slot, PREFERENCE_TAG_DEFAULT_SLOT)
	READPREF_INT(chat_toggles, PREFERENCE_TAG_CHAT_TOGGLES)

	READPREF_INT(toggles, PREFERENCE_TAG_TOGGLES)
	READPREF_INT(toggles2, PREFERENCE_TAG_TOGGLES2)

	READPREF_RAW(ghost_form, PREFERENCE_TAG_GHOST_FORM)
	READPREF_RAW(ghost_orbit, PREFERENCE_TAG_GHOST_ORBIT)
	READPREF_RAW(ghost_accs, PREFERENCE_TAG_GHOST_ACCS)
	READPREF_RAW(ghost_others, PREFERENCE_TAG_GHOST_OTHERS)

	READPREF_JSONDEC(ignoring, PREFERENCE_TAG_IGNORING)

	//READ_FILE(S["ghost_hud"], ghost_hud)
	//READ_FILE(S["inquisitive_ghost"], inquisitive_ghost)
	//READ_FILE(S["uses_glasses_colour"], uses_glasses_colour)
	READPREF_INT(clientfps, PREFERENCE_TAG_CLIENTFPS)
	READPREF_INT(parallax, PREFERENCE_TAG_PARALLAX)

	//READ_FILE(S["ambientocclusion"], ambientocclusion)
	//READ_FILE(S["auto_fit_viewport"], auto_fit_viewport)
	READPREF_INT(pixel_size, PREFERENCE_TAG_PIXELSIZE)
	READPREF_RAW(scaling_method, PREFERENCE_TAG_SCALING_METHOD)

	//READ_FILE(S["enable_tips"], enable_tips)
	READPREF_INT(tip_delay, PREFERENCE_TAG_TIP_DELAY)
	READPREF_INT(pda_style, PREFERENCE_TAG_PDA_STYLE)
	READPREF_INT(pda_color, PREFERENCE_TAG_PDA_COLOUR)

	READPREF_JSONDEC(key_bindings, PREFERENCE_TAG_KEYBINDS)
	READPREF_JSONDEC(purchased_gear, PREFERENCE_TAG_PURCHASED_GEAR)

	//Sanitize
	asaycolor		= sanitize_ooccolor(sanitize_hexcolor(asaycolor, 6, TRUE, initial(asaycolor)))
	ooccolor		= sanitize_ooccolor(sanitize_hexcolor(ooccolor, 6, TRUE, initial(ooccolor)))
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	UI_style		= sanitize_inlist(UI_style, GLOB.available_ui_styles, GLOB.available_ui_styles[1])

	default_slot	= sanitize_integer(default_slot, TRUE, max_save_slots, initial(default_slot))
	toggles			= sanitize_integer(toggles, FALSE, 65535, initial(toggles))
	clientfps		= sanitize_integer(clientfps, FALSE, 1000, FALSE)
	parallax		= sanitize_integer(parallax, PARALLAX_INSANE, PARALLAX_DISABLE, null)

	pixel_size		= sanitize_float(pixel_size, PIXEL_SCALING_AUTO, PIXEL_SCALING_3X, 0.5, initial(pixel_size))
	scaling_method  = sanitize_text(scaling_method, initial(scaling_method))
	ghost_form		= sanitize_inlist(ghost_form, GLOB.ghost_forms, initial(ghost_form))
	ghost_orbit 	= sanitize_inlist(ghost_orbit, GLOB.ghost_orbits, initial(ghost_orbit))
	ghost_accs		= sanitize_inlist(ghost_accs, GLOB.ghost_accs_options, GHOST_ACCS_DEFAULT_OPTION)
	ghost_others	= sanitize_inlist(ghost_others, GLOB.ghost_others_options, GHOST_OTHERS_DEFAULT_OPTION)
	be_special		= SANITIZE_LIST(be_special)

	pda_style		= sanitize_inlist(pda_style, GLOB.pda_styles, initial(pda_style))
	pda_color		= sanitize_hexcolor(pda_color, 6, TRUE, initial(pda_color))
	show_credits		= sanitize_integer(show_credits, FALSE, TRUE, initial(show_credits))

	key_bindings 	= sanitize_islist(key_bindings, deepCopyList(GLOB.keybinding_list_by_key))
	if (!key_bindings)
		key_bindings = deepCopyList(GLOB.keybinding_list_by_key)

	if(!purchased_gear)
		purchased_gear = list()
	if(!equipped_gear)
		equipped_gear = list()

	return TRUE
