#define READ_FILE(sf, varname, fallback) var/##varname; sf >> ##varname; if(!##varname) ##varname=fallback;

#define PREFERENCE_TAG_TOGGLES			"1"
#define PREFERENCE_TAG_TOGGLES2			"2"
#define PREFERENCE_TAG_ASAY_COLOUR		"3"
#define PREFERENCE_TAG_OOC_COLOUR		"4"
#define PREFERENCE_TAG_LAST_CL			"5"
#define PREFERENCE_TAG_UI_STYLE			"6"
#define PREFERENCE_TAG_OUTLINE_COLOUR	"7"
#define PREFERENCE_TAG_BALLOON_ALERTS	"8"
#define PREFERENCE_TAG_DEFAULT_SLOT		"9"
#define PREFERENCE_TAG_CHAT_TOGGLES		"10"
#define PREFERENCE_TAG_GHOST_FORM		"11"
#define PREFERENCE_TAG_GHOST_ORBIT		"12"
#define PREFERENCE_TAG_GHOST_ACCS		"13"
#define PREFERENCE_TAG_GHOST_OTHERS		"14"
#define PREFERENCE_TAG_PREFERRED_MAP	"15"
#define PREFERENCE_TAG_IGNORING			"16"
#define PREFERENCE_TAG_CLIENTFPS		"17"
#define PREFERENCE_TAG_PARALLAX			"18"
#define PREFERENCE_TAG_PIXELSIZE		"19"
#define PREFERENCE_TAG_SCALING_METHOD	"20"
#define PREFERENCE_TAG_TIP_DELAY		"21"
#define PREFERENCE_TAG_PDA_STYLE		"22"
#define PREFERENCE_TAG_PDA_COLOUR		"23"
#define PREFERENCE_TAG_KEYBINDS			"24"
#define PREFERENCE_TAG_PURCHASED_GEAR	"25"
#define PREFERENCE_TAG_BE_SPECIAL		"26"

#define NEW_QUERY(thepkey, theckey, thevalue) queries += new_db_query("INSERT INTO SS13_preferences (ckey, preference_tag, preference_value) VALUES (:ckey, :pkey, :pval)", list("ckey" = theckey, "pkey" = thepkey, "pval" = thevalue))

/proc/parse_savefile(owning_ckey, savefile/S)
	var/list/character_dirs = list()

	for(var/cdir in GLOB.all_cdirs)
		if(cdir in S.dir)
			character_dirs += cdir

	/*
		These defines used to be vars, but are now bitflags

		#define PREFTOGGLE_OUTLINE_ENABLED				(1<<20)
		#define PREFTOGGLE_RUNECHAT_GLOBAL				(1<<21)
		#define PREFTOGGLE_RUNECHAT_NONMOBS				(1<<22)
		#define PREFTOGGLE_RUNECHAT_EMOTES				(1<<23)
	*/

	READ_FILE(S["toggles"], toggles, 3071) // This does NOT include the values of the below flags, as they can get added on
	READ_FILE(S["outline_enabled"], outline_enabled, TRUE)
	READ_FILE(S["chat_on_map"], chat_on_map, TRUE)
	READ_FILE(S["see_chat_non_mob"] , see_chat_non_mob, TRUE)
	READ_FILE(S["see_rc_emotes"] , see_rc_emotes, TRUE)

	var/toggles_out = 0
	if(toggles)
		toggles_out = toggles

	if(outline_enabled)
		toggles_out += (1<<20)
	if(chat_on_map)
		toggles_out += (1<<21)
	if(see_chat_non_mob)
		toggles_out += (1<<22)
	if(see_rc_emotes)
		toggles_out += (1<<23)

	/*
		These defines also used to be vars, but are now bitflags

		#define PREFTOGGLE_2_FANCY_TGUI					(1<<0)
		#define PREFTOGGLE_2_LOCKED_TGUI				(1<<1)
		#define PREFTOGGLE_2_LOCKED_BUTTONS				(1<<2)
		#define PREFTOGGLE_2_WINDOW_FLASHING			(1<<3)
		#define PREFTOGGLE_2_CREW_OBJECTIVES			(1<<4)
		#define PREFTOGGLE_2_GHOST_HUD					(1<<5)
		#define PREFTOGGLE_2_GHOST_INQUISITIVENESS		(1<<6)
		#define PREFTOGGLE_2_USES_GLASSES_COLOUR		(1<<7)
		#define PREFTOGGLE_2_AMBIENT_OCCLUSION			(1<<8)
		#define PREFTOGGLE_2_AUTO_FIT_VIEWPORT			(1<<9)
		#define PREFTOGGLE_2_ENABLE_TIPS				(1<<10)
		#define PREFTOGGLE_2_SHOW_CREDITS				(1<<11)
		#define PREFTOGGLE_2_HOTKEYS					(1<<12)
	*/

	// These should defalt to ON if the key doesnt exist.
	// If you disagree, tell me in the review
	READ_FILE(S["tgui_fancy"], tgui_fancy, TRUE)
	READ_FILE(S["tgui_lock"], tgui_lock, TRUE)
	READ_FILE(S["buttons_locked"], buttons_locked, FALSE)
	READ_FILE(S["windowflash"], windowflashing, TRUE)
	READ_FILE(S["crew_objectives"], crew_objectives, TRUE)
	READ_FILE(S["ghost_hud"], ghost_hud, TRUE)
	READ_FILE(S["inquisitive_ghost"], inquisitive_ghost, TRUE)
	READ_FILE(S["uses_glasses_colour"], uses_glasses_colour, TRUE)
	READ_FILE(S["ambientocclusion"], ambientocclusion, TRUE)
	READ_FILE(S["auto_fit_viewport"], auto_fit_viewport, TRUE)
	READ_FILE(S["enable_tips"], enable_tips, TRUE)
	READ_FILE(S["show_credits"], show_credits, TRUE)
	READ_FILE(S["hotkeys"], hotkeys, TRUE) // This is a boolean not a list

	var/toggles2_out = 0
	if(tgui_fancy)
		toggles2_out += (1<<0)
	if(tgui_lock)
		toggles2_out += (1<<1)
	if(buttons_locked)
		toggles2_out += (1<<2)
	if(windowflashing)
		toggles2_out += (1<<3)
	if(crew_objectives)
		toggles2_out += (1<<4)
	if(ghost_hud)
		toggles2_out += (1<<5)
	if(inquisitive_ghost)
		toggles2_out += (1<<6)
	if(uses_glasses_colour)
		toggles2_out += (1<<7)
	if(ambientocclusion)
		toggles2_out += (1<<8)
	if(auto_fit_viewport)
		toggles2_out += (1<<9)
	if(enable_tips)
		toggles2_out += (1<<10)
	if(show_credits)
		toggles2_out += (1<<11)
	if(hotkeys)
		toggles2_out += (1<<12)

	// And save these to the DB

	var/list/datum/db_query/queries = list()
	NEW_QUERY(PREFERENCE_TAG_TOGGLES, owning_ckey, toggles_out)
	NEW_QUERY(PREFERENCE_TAG_TOGGLES2, owning_ckey, toggles2_out)

	READ_FILE(S["asaycolor"], asaycolor, COLOR_MOSTLY_PURE_RED)
	NEW_QUERY(PREFERENCE_TAG_ASAY_COLOUR, owning_ckey, asaycolor)

	READ_FILE(S["ooccolor"], ooccolor, "#c43b23")
	NEW_QUERY(PREFERENCE_TAG_OOC_COLOUR, owning_ckey, ooccolor)

	READ_FILE(S["lastchangelog"], lastchangelog, null)
	NEW_QUERY(PREFERENCE_TAG_LAST_CL, owning_ckey, lastchangelog)

	READ_FILE(S["UI_style"], UI_style, "Midnight-Knox")
	NEW_QUERY(PREFERENCE_TAG_UI_STYLE, owning_ckey, UI_style)

	READ_FILE(S["outline_color"], outline_color, "#75A2BB")
	NEW_QUERY(PREFERENCE_TAG_OUTLINE_COLOUR, owning_ckey, outline_color)

	READ_FILE(S["see_balloon_alerts"], see_balloon_alerts, "Only balloon alerts")
	NEW_QUERY(PREFERENCE_TAG_BALLOON_ALERTS, owning_ckey, see_balloon_alerts)

	READ_FILE(S["default_slot"], default_slot, 1)
	NEW_QUERY(PREFERENCE_TAG_DEFAULT_SLOT, owning_ckey, default_slot)

	READ_FILE(S["chat_toggles"], chat_toggles, 4095)
	NEW_QUERY(PREFERENCE_TAG_CHAT_TOGGLES, owning_ckey, chat_toggles)

	READ_FILE(S["ghost_form"], ghost_form, "ghost")
	NEW_QUERY(PREFERENCE_TAG_GHOST_FORM, owning_ckey, ghost_form)

	READ_FILE(S["ghost_orbit"], ghost_orbit, "circle")
	NEW_QUERY(PREFERENCE_TAG_GHOST_ORBIT, owning_ckey, ghost_orbit)

	READ_FILE(S["ghost_accs"], ghost_accs, 100)
	NEW_QUERY(PREFERENCE_TAG_GHOST_ACCS, owning_ckey, ghost_accs)

	READ_FILE(S["ghost_others"], ghost_others, 100)
	NEW_QUERY(PREFERENCE_TAG_GHOST_OTHERS, owning_ckey, ghost_others)

	READ_FILE(S["preferred_map"], preferred_map, null)
	NEW_QUERY(PREFERENCE_TAG_PREFERRED_MAP, owning_ckey, preferred_map)

	READ_FILE(S["ignoring"], ignoring, list())
	// This is a list. JSON it
	var/ignoring_json = json_encode(ignoring)
	NEW_QUERY(PREFERENCE_TAG_IGNORING, owning_ckey, ignoring_json)

	READ_FILE(S["clientfps"], clientfps, 40)
	NEW_QUERY(PREFERENCE_TAG_CLIENTFPS, owning_ckey, clientfps)

	READ_FILE(S["parallax"], parallax, 0) // Equiv to "high"
	NEW_QUERY(PREFERENCE_TAG_PARALLAX, owning_ckey, parallax)

	READ_FILE(S["pixel_size"], pixel_size, 0)
	NEW_QUERY(PREFERENCE_TAG_PIXELSIZE, owning_ckey, pixel_size)

	READ_FILE(S["scaling_method"], scaling_method, "normal")
	NEW_QUERY(PREFERENCE_TAG_SCALING_METHOD, owning_ckey, scaling_method)

	READ_FILE(S["tip_delay"], tip_delay, "500")
	NEW_QUERY(PREFERENCE_TAG_TIP_DELAY, owning_ckey, tip_delay)

	READ_FILE(S["pda_style"], pda_style, "Monospaced")
	NEW_QUERY(PREFERENCE_TAG_PDA_STYLE, owning_ckey, pda_style)

	READ_FILE(S["pda_color"], pda_color, "#808000")
	NEW_QUERY(PREFERENCE_TAG_PDA_COLOUR, owning_ckey, pda_color)

	READ_FILE(S["key_bindings"], key_bindings, null)
	// Sort this out
	var/json_keybinds = json_encode(key_bindings)
	NEW_QUERY(PREFERENCE_TAG_KEYBINDS, owning_ckey, json_keybinds)

	READ_FILE(S["purchased_gear"], purchased_gear, list())
	// And this
	var/gear_json = json_encode(purchased_gear)
	NEW_QUERY(PREFERENCE_TAG_PURCHASED_GEAR, owning_ckey, gear_json)

	READ_FILE(S["be_special"], be_special, list())
	// ugh
	var/special_json = json_encode(be_special)
	NEW_QUERY(PREFERENCE_TAG_BE_SPECIAL, owning_ckey, special_json)

	for(var/datum/db_query/query in queries)
		query.Execute()
		var/em = query.ErrorMsg()
		if(em)
			log_info("Query error when processing [owning_ckey] | [em]")

	//favorite outfits
	READ_FILE(S["favorite_outfits"], favorite_outfits)

	var/list/parsed_favs = list()
	for(var/typetext in favorite_outfits)
		var/datum/outfit/path = text2path(typetext)
		if(ispath(path)) //whatever typepath fails this check probably doesn't exist anymore
			parsed_favs += path
	favorite_outfits = uniqueList(parsed_favs)

	// Now do characters
	parse_characters(owning_ckey, S, character_dirs)

#undef READ_FILE
#undef NEW_QUERY
