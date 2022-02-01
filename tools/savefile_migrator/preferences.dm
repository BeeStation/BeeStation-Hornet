//This is the lowest supported version, anything below this is completely obsolete and the entire savefile will be wiped.
#define SAVEFILE_VERSION_MIN	18

//This is the current version, anything below this will attempt to update (if it's not obsolete)
//	You do not need to raise this if you are adding new values that have sane defaults.
//	Only raise this value when changing the meaning/format/name/layout of an existing value
//	where you would want the updater procs below to run
#define SAVEFILE_VERSION_MAX	37

/datum/preferences
	var/ckey
	//doohickeys for savefiles
	var/path
	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used
	var/max_save_slots = 3

	//non-preference stuff
	var/muted = 0
	var/last_ip
	var/last_id
	var/db_flags

	//game-preferences
	var/lastchangelog = ""				//Saved changlog filesize to detect if there was a change
	var/ooccolor = "#c43b23"
	var/asaycolor = "#ff4500"			//This won't change the color for current admins, only incoming ones.
	var/tip_delay = 500 //tip delay in milliseconds

	//Antag preferences
	var/list/be_special = list()		//Special role selection

	var/UI_style = null
	var/outline_color = COLOR_BLUE_GRAY

	///Whether we want balloon alerts displayed alone, with chat or not displayed at all
	var/see_balloon_alerts = BALLOON_ALERT_ALWAYS

	///Bitflag var for setting boolean preference values (see __DEFINES/preferences.dm)
	var/toggles = TOGGLES_DEFAULT
	///Additional toggles var, since each bitflag var can only store 24 flags
	var/toggles_2 = TOGGLES_2_DEFAULT
	///Toggles var to group together chat settings
	var/chat_toggles = TOGGLES_DEFAULT_CHAT
	///Toggles var to group together sound settings
	var/sound_toggles = TOGGLES_DEFAULT_SOUND

	var/ghost_form = "ghost"
	var/ghost_orbit = GHOST_ORBIT_CIRCLE
	var/ghost_accs = GHOST_ACCS_DEFAULT_OPTION
	var/ghost_others = GHOST_OTHERS_DEFAULT_OPTION
	var/preferred_map = null
	var/pda_style = MONO
	var/pda_color = "#808000"

	// Custom Keybindings
	var/list/key_bindings = null

	// pAI saved personality details
	var/pai_name = null
	var/pai_description = null
	var/pai_role = null
	var/pai_comments = null

	//character preferences
	var/real_name						//our character's name
	var/be_random_name = 0				//whether we'll have a random name every round
	var/be_random_body = 0				//whether we'll have a random body every round
	var/gender = MALE					//gender of character (well duh)
	var/age = 30						//age of character
	var/underwear = "Nude"				//underwear type
	var/underwear_color = "000"			//underwear color
	var/undershirt = "Nude"				//undershirt type
	var/socks = "Nude"					//socks type
	var/helmet_style = HELMET_DEFAULT
	var/backbag = DBACKPACK				//backpack type
	var/jumpsuit_style = PREF_SUIT		//suit/skirt
	var/hair_style = "Bald"				//Hair type
	var/hair_color = "000"				//Hair color
	var/facial_hair_style = "Shaved"	//Face hair type
	var/facial_hair_color = "000"		//Facial hair color
	var/skin_tone = "caucasian1"		//Skin color
	var/eye_color = "000"				//Eye color
//	var/datum/species/pref_species = new /datum/species/human()	//Mutant race
	var/list/features = list("mcolor" = "FFF", "ethcolor" = "9c3030", "tail_lizard" = "Smooth",
							"tail_human" = "None", "snout" = "Round", "horns" = "None",
							"ears" = "None", "wings" = "None", "frills" = "None", "spines" = "None",
							"body_markings" = "None", "legs" = "Normal Legs", "moth_wings" = "Plain",
							"ipc_screen" = "Blue", "ipc_antenna" = "None", "ipc_chassis" = "Morpheus Cyberkinetics(Greyscale)",
							"insect_type" = "Common Fly")

	var/list/custom_names = list()
	var/preferred_ai_core_display = "Blue"
	var/prefered_security_department = SEC_DEPT_RANDOM

	//Quirk list
	var/list/all_quirks = list()

	//Job preferences 2.0 - indexed by job title , no key or value implies never
	var/list/job_preferences = list()

		// Want randomjob if preferences already filled - Donkie
	var/joblessrole = BERANDOMJOB  //defaults to 1 for fewer assistants

	// 0 = character settings, 1 = game preferences
	var/current_tab = 0

	var/unlock_content = 0

	var/list/ignoring = list()

	var/clientfps = 40
	var/updated_fps = 0

	var/parallax

	///What size should pixels be displayed as? 0 is strech to fit
	var/pixel_size = 0
	///What scaling method should we use?
	var/scaling_method = "normal"
	var/uplink_spawn_loc = UPLINK_PDA

	var/list/exp = list()
	var/job_exempt = 0

	//Loadout stuff
	var/list/purchased_gear = list()
	var/list/equipped_gear = list()
	var/gear_tab = "General"

	var/action_buttons_screen_locs = list()

/datum/preferences/proc/load_preferences()
	if(!path)
		return FALSE
	if(!fexists(path))
		return FALSE

	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/"

	var/needs_update = savefile_needs_update(S)
	if(needs_update == -2)		//fatal, can't load any data
		return FALSE

	//general preferences
	READ_FILE(S["asaycolor"], asaycolor)
	READ_FILE(S["ooccolor"], ooccolor)
	READ_FILE(S["lastchangelog"], lastchangelog)
	READ_FILE(S["UI_style"], UI_style)
	READ_FILE(S["outline_color"], outline_color)
	READ_FILE(S["see_balloon_alerts"], see_balloon_alerts)
	READ_FILE(S["be_special"], be_special)
	READ_FILE(S["default_slot"], default_slot)
	READ_FILE(S["chat_toggles"], chat_toggles)
	READ_FILE(S["toggles"], toggles)
	READ_FILE(S["toggles_2"], toggles_2)
	READ_FILE(S["sound_toggles"], sound_toggles)
	READ_FILE(S["ghost_form"], ghost_form)
	READ_FILE(S["ghost_orbit"], ghost_orbit)
	READ_FILE(S["ghost_accs"], ghost_accs)
	READ_FILE(S["ghost_others"], ghost_others)
	READ_FILE(S["preferred_map"], preferred_map)
	READ_FILE(S["ignoring"], ignoring)
	READ_FILE(S["clientfps"], clientfps)
	READ_FILE(S["parallax"], parallax)
	READ_FILE(S["pixel_size"], pixel_size)
	READ_FILE(S["scaling_method"], scaling_method)
	READ_FILE(S["tip_delay"], tip_delay)
	READ_FILE(S["pda_style"], pda_style)
	READ_FILE(S["pda_color"], pda_color)
	READ_FILE(S["key_bindings"], key_bindings)
	READ_FILE(S["purchased_gear"], purchased_gear)
	READ_FILE(S["equipped_gear"], equipped_gear)
	READ_FILE(S["pai_name"], pai_name)
	READ_FILE(S["pai_description"], pai_description)
	READ_FILE(S["pai_role"], pai_role)
	READ_FILE(S["pai_comments"], pai_comments)

	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_preferences(needs_update, S)		//needs_update = savefile_version if we need an update (positive integer)

	//Sanitize
	asaycolor		= sanitize_ooccolor(sanitize_hexcolor(asaycolor, 6, TRUE, initial(asaycolor)))
	ooccolor		= sanitize_ooccolor(sanitize_hexcolor(ooccolor, 6, TRUE, initial(ooccolor)))
	lastchangelog	= reject_bad_text(lastchangelog, 40, TRUE) // 40 is commit hash len
	UI_style		= sanitize_inlist(UI_style, available_ui_styles, available_ui_styles[1])
	outline_color	= sanitize_hexcolor(outline_color, 6, TRUE, initial(outline_color))
	see_balloon_alerts = sanitize_inlist(see_balloon_alerts, balloon_alerts, BALLOON_ALERT_ALWAYS)
	be_special		= SANITIZE_LIST(be_special)
	default_slot	= sanitize_integer(default_slot, TRUE, max_save_slots, initial(default_slot))
	chat_toggles	= sanitize_integer(chat_toggles, FALSE, 16777215, initial(chat_toggles))
	toggles			= sanitize_integer(toggles, FALSE, TOGGLES_MAX, initial(toggles))
	toggles_2		= sanitize_integer(toggles_2, FALSE, TOGGLES_2_MAX, initial(toggles_2))
	sound_toggles	= sanitize_integer(sound_toggles, FALSE, 16777215, initial(sound_toggles))
	ghost_form		= sanitize_inlist(ghost_form, ghost_forms, initial(ghost_form))
	ghost_orbit 	= sanitize_inlist(ghost_orbit, ghost_orbits, initial(ghost_orbit))
	ghost_accs		= sanitize_inlist(ghost_accs, ghost_accs_options, GHOST_ACCS_DEFAULT_OPTION)
	ghost_others	= sanitize_inlist(ghost_others, ghost_others_options, GHOST_OTHERS_DEFAULT_OPTION)
	preferred_map	= reject_bad_text(preferred_map, 32, TRUE)
	clientfps		= sanitize_integer(clientfps, FALSE, 1000, FALSE)
	parallax		= sanitize_integer(parallax, PARALLAX_INSANE, PARALLAX_DISABLE, initial(parallax))
	pixel_size		= sanitize_integer(pixel_size, PIXEL_SCALING_AUTO, PIXEL_SCALING_3X, initial(pixel_size))
	scaling_method  = sanitize_inlist(scaling_method, scaling_methods, SCALING_METHOD_NORMAL)
	pda_style		= sanitize_inlist(pda_style, pda_styles, initial(pda_style))
	pda_color		= sanitize_hexcolor(pda_color, 6, TRUE, initial(pda_color))
	key_bindings 	= sanitize_islist(key_bindings, deepCopyList(keybinding_list_by_key))
	purchased_gear	= SANITIZE_LIST(purchased_gear)
	equipped_gear	= SANITIZE_LIST(equipped_gear)
	pai_name		= reject_bad_name(sanitize_text(pai_name, initial(pai_name)), TRUE)
	pai_description	= reject_bad_text(pai_description, MAX_MESSAGE_LEN, TRUE)
	pai_role		= reject_bad_text(pai_role, MAX_MESSAGE_LEN, TRUE)
	pai_comments	= reject_bad_text(pai_comments, MAX_MESSAGE_LEN, TRUE)

	return TRUE

/datum/preferences/proc/savefile_needs_update(savefile/S)
	var/savefile_version
	READ_FILE(S["version"], savefile_version)

	if(savefile_version < SAVEFILE_VERSION_MIN)
		S.dir.Cut()
		return -2
	if(savefile_version < SAVEFILE_VERSION_MAX)
		return savefile_version
	return -1

/datum/preferences/proc/update_preferences(current_version, savefile/S)
	if(current_version < 30)
		outline_color = COLOR_BLUE_GRAY
	if(current_version < 32)
		//Okay this is gonna s u c k
		var/list/legacy_purchases = purchased_gear.Copy()
		purchased_gear.Cut()
		equipped_gear.Cut() //Not gonna bother.
		for(var/l_gear in legacy_purchases)
			var/n_gear = md5(l_gear)
			purchased_gear += n_gear
	if(current_version < 33)
		toggles |= TOGGLE_RUNECHAT
//		max_chat_length = CHAT_MESSAGE_MAX_LENGTH			> Depreciated as of 31/07/2021
		toggles |= TOGGLE_NON_MOB_RUNECHAT
		toggles |= TOGGLE_EMOTES_RUNECHAT
		S.dir.Remove("overhead_chat")
	if(current_version < 35)
		see_balloon_alerts = BALLOON_ALERT_ALWAYS
	if(current_version < 36)
		key_bindings = S["key_bindings"]
		//the keybindings are defined as "key" = list("action") in the savefile (for multiple actions -> 1 key)
		//so im doing that
		key_bindings += list("W" = list("move_north"), "A" = list("move_west"), "S" = list("move_south"), "D" = list("move_east"))
		//WRITE_FILE(S["key_bindings"], key_bindings) - don't edit the savefile
	if(current_version < 37)
		// this is some horrible, HORRIBLE CBT to shuffle around all the bitflags
		// first thing is to move the sound bitflags to the new variable
		sound_toggles = 0 // clear the default flags, since we're overwriting with the incoming prefs
		sound_toggles |= toggles & SOUND_ADMINHELP
		sound_toggles |= toggles & SOUND_MIDI
		sound_toggles |= toggles & SOUND_AMBIENCE
		sound_toggles |= toggles & SOUND_LOBBY
		// The rest of the sound flags are mixed up with general flags, so we need to sanitize them
		// to make sure they are written to the correct flag location
		// this is done by logically inverting twice to get 1 or 0 and then shifting by the required values
		sound_toggles |= ((!(!(toggles & (1<<7)))) << 4) // instruments
		sound_toggles |= ((!(!(toggles & (1<<8)))) << 5) // ambience
		sound_toggles |= ((!(!(toggles & (1<<9)))) << 6) // prayers
		sound_toggles |= ((!(!(toggles & (1<<11)))) << 7) // announcements

		// Now we can do some bitflag *magic* and reorganize the remaining toggle values into a cohesive set of flags
		// Shift right 4 bits to remove the first 4 former sound bits
		toggles >>= 4
		// New blank toggles var
		var/new_toggles = TOGGLES_DEFAULT
		new_toggles &= ~4095 // unset bottom 12 bits since those are getting copied
		new_toggles |= toggles & 7 // mask for bottom three bits and copy
		new_toggles |= (toggles & 64) >> 3 // move 7th bit 3 bits over
		new_toggles |= (toggles & 65280) >> 4 // move bits 9 thru 16 4 bits over
		toggles = new_toggles
		// Previous bitflags have now been converted to the new format, and we can now convert the savefile vars
		toggles &= ~16539648 // unset bit 14-15 and bit 19-24 since those are getting copied over
		toggles |= sanitize_integer(S["buttons_locked"], FALSE, TRUE, FALSE) << 13
		toggles |= sanitize_integer(S["hotkeys"], FALSE, TRUE, FALSE) << 14
		toggles |= sanitize_integer(S["crew_objectives"], FALSE, TRUE, TRUE) << 18
		toggles |= sanitize_integer(S["windowflash"], FALSE, TRUE, TRUE) << 19
		toggles |= sanitize_integer(S["tgui_fancy"], FALSE, TRUE, TRUE) << 20
		toggles |= sanitize_integer(S["tgui_lock"], FALSE, TRUE, TRUE) << 21
		toggles |= sanitize_integer(S["show_credits"], FALSE, TRUE, TRUE) << 22
		toggles |= sanitize_integer(S["ghost_hud"], FALSE, TRUE, TRUE) << 23
		toggles_2 = TOGGLES_2_DEFAULT
		toggles_2 &= ~27 // unset bits 1, 2, 4 and 5 since we're copying those
		toggles_2 |= sanitize_integer(S["inquisitive_ghost"], FALSE, TRUE, TRUE) << 0
		toggles_2 |= sanitize_integer(S["ambientocclusion"], FALSE, TRUE, TRUE) << 1
		toggles_2 |= sanitize_integer(S["enable_tips"], FALSE, TRUE, TRUE) << 3
		toggles_2 |= sanitize_integer(S["uses_glasses_colour"], FALSE, TRUE, FALSE) << 4
		// Handle some newer vars that may or may not be present with older saves
		if(current_version >= 30)
			toggles &= ~4096 // unset 13th bit to prep for copy
			toggles |= sanitize_integer(S["outline_enabled"], FALSE, TRUE, TRUE) << 12
		if(current_version >= 31)
			toggles_2 &= ~4 // unset 3rd bit
			toggles_2 |= sanitize_integer(S["auto_fit_viewport"], FALSE, TRUE, TRUE) << 2
		if(current_version >= 33)
			toggles &= ~229376 // unset bits 16-18
			toggles |= sanitize_integer(S["chat_on_map"], FALSE, TRUE, TRUE) << 15
			toggles |= sanitize_integer(S["see_chat_non_mob"], FALSE, TRUE, TRUE) << 16
			toggles |= sanitize_integer(S["see_rc_emotes"], FALSE, TRUE, TRUE) << 17

		// Next stage of the update is migrating pAI saves into the main savefile (if they exist)
		var/pai_path = SAVEFILE_DIRECTORY + "[ckey[1]]/[ckey]/pai.sav"
		if(fexists(pai_path))
			var/savefile/P = new /savefile(pai_path)
			if(P)
				if(P["name"])
					pai_name = copytext_char(P["name"], 1, MAX_NAME_LEN)
				if(P["description"])
					pai_description = copytext_char(P["description"], 1, MAX_MESSAGE_LEN)
				if(P["role"])
					pai_role = copytext_char(P["role"], 1, MAX_MESSAGE_LEN)
				if(P["comments"])
					pai_comments = copytext_char(P["comments"], 1, MAX_MESSAGE_LEN)
			//fdel(pai_path) - don't edit the savefiles

//general stuff
/// Return `number` if it is in the range `min to max`, otherwise `default`
/proc/sanitize_integer(number, min=0, max=1, default=0)
	if(isnum_safe(number))
		number = round(number)
		if(min <= number && number <= max)
			return number
	return default

/// Return `text` if it is text, otherwise `default`
/proc/sanitize_text(text, default="")
	if(istext(text))
		return text
	return default

/// Return `value` if it is a list, otherwise `default`
/proc/sanitize_islist(value, default)
	if(length(value))
		return value
	if(default)
		return default

/// Return `value` if it's in List, otherwise `default`
/proc/sanitize_inlist(value, list/List, default)
	if(value in List)
		return value
	if(default)
		return default
	if(List?.len)
		return pick(List)

/// Return `color` as a formatted ooc valid hex color
/proc/sanitize_ooccolor(color)
	if(length(color) != length_char(color))
		CRASH("Invalid characters in color '[color]'")
	var/list/HSL = rgb2hsl(hex2num(copytext(color, 2, 4)), hex2num(copytext(color, 4, 6)), hex2num(copytext(color, 6, 8)))
	HSL[3] = min(HSL[3],0.4)
	var/list/RGB = hsl2rgb(arglist(HSL))
	return "#[num2hex(RGB[1],2)][num2hex(RGB[2],2)][num2hex(RGB[3],2)]"

/// Converts an RGB color to an HSL color
/proc/rgb2hsl(red, green, blue)
	red /= 255;green /= 255;blue /= 255;
	var/max = max(red,green,blue)
	var/min = min(red,green,blue)
	var/range = max-min

	var/hue=0;var/saturation=0;var/lightness=0;
	lightness = (max + min)/2
	if(range != 0)
		if(lightness < 0.5)
			saturation = range/(max+min)
		else
			saturation = range/(2-max-min)

		var/dred = ((max-red)/(6*max)) + 0.5
		var/dgreen = ((max-green)/(6*max)) + 0.5
		var/dblue = ((max-blue)/(6*max)) + 0.5

		if(max==red)
			hue = dblue - dgreen
		else if(max==green)
			hue = dred - dblue + (1/3)
		else
			hue = dgreen - dred + (2/3)
		if(hue < 0)
			hue++
		else if(hue > 1)
			hue--

	return list(hue, saturation, lightness)

/// Converts an HSL color to an RGB color
/proc/hsl2rgb(hue, saturation, lightness)
	var/red;var/green;var/blue;
	if(saturation == 0)
		red = lightness * 255
		green = red
		blue = red
	else
		var/a;var/b;
		if(lightness < 0.5)
			b = lightness*(1+saturation)
		else
			b = (lightness+saturation) - (saturation*lightness)
		a = 2*lightness - b

		red = round(255 * hue2rgb(a, b, hue+(1/3)))
		green = round(255 * hue2rgb(a, b, hue))
		blue = round(255 * hue2rgb(a, b, hue-(1/3)))

	return list(red, green, blue)

/// Converts an ABH color to an RGB color
/proc/hue2rgb(a, b, hue)
	if(hue < 0)
		hue++
	else if(hue > 1)
		hue--
	if(6*hue < 1)
		return (a+(b-a)*6*hue)
	if(2*hue < 1)
		return b
	if(3*hue < 2)
		return (a+(b-a)*((2/3)-hue)*6)
	return a

/// Copies a list, and all lists inside it recusively. Does not copy any other reference type
/proc/deepCopyList(list/l)
	if(!islist(l))
		return l
	. = l.Copy()
	for(var/i = 1 to l.len)
		var/key = .[i]
		if(isnum_safe(key))
			// numbers cannot ever be associative keys
			continue
		var/value = .[key]
		if(islist(value))
			value = deepCopyList(value)
			.[key] = value
		if(islist(key))
			key = deepCopyList(key)
			.[i] = key
			.[key] = value

/// Return `color` if it is a valid hex color, otherwise `default`
/proc/sanitize_hexcolor(color, desired_format=3, include_crunch=0, default)
	var/crunch = include_crunch ? "#" : ""
	if(!istext(color))
		color = ""

	var/start = 1 + (text2ascii(color, 1) == 35)
	var/len = length(color)
	var/char = ""
	// RRGGBB -> RGB but awful
	var/convert_to_shorthand = desired_format == 3 && length_char(color) > 3

	. = ""
	var/i = start
	while(i <= len)
		char = color[i]
		switch(text2ascii(char))
			if(48 to 57)		//numbers 0 to 9
				. += char
			if(97 to 102)		//letters a to f
				. += char
			if(65 to 70)		//letters A to F
				. += lowertext(char)
			else
				break
		i += length(char)
		if(convert_to_shorthand && i <= len) //skip next one
			i += length(color[i])

	if(length_char(.) != desired_format)
		if(default)
			return default
		return crunch + repeat_string(desired_format, "0")

	return crunch + .

#define NO_CHARS_DETECTED 0
#define SPACES_DETECTED 1
#define SYMBOLS_DETECTED 2
#define NUMBERS_DETECTED 3
#define LETTERS_DETECTED 4

//Filters out undesirable characters from names
/proc/reject_bad_name(t_in, allow_numbers = FALSE, max_length = MAX_NAME_LEN, ascii_only = TRUE)
	if(!t_in)
		return //Rejects the input if it is null

	var/number_of_alphanumeric = 0
	var/last_char_group = NO_CHARS_DETECTED
	var/t_out = ""
	var/t_len = length(t_in)
	var/charcount = 0
	var/char = ""


	for(var/i = 1, i <= t_len, i += length(char))
		char = t_in[i]

		switch(text2ascii(char))
			// A  .. Z
			if(65 to 90)			//Uppercase Letters
				number_of_alphanumeric++
				last_char_group = LETTERS_DETECTED

			// a  .. z
			if(97 to 122)			//Lowercase Letters
				if(last_char_group == NO_CHARS_DETECTED || last_char_group == SPACES_DETECTED || last_char_group == SYMBOLS_DETECTED) //start of a word
					char = uppertext(char)
				number_of_alphanumeric++
				last_char_group = LETTERS_DETECTED

			// 0  .. 9
			if(48 to 57)			//Numbers
				if(last_char_group == NO_CHARS_DETECTED || !allow_numbers) //suppress at start of string
					continue
				number_of_alphanumeric++
				last_char_group = NUMBERS_DETECTED

			// '  -  .
			if(39,45,46)			//Common name punctuation
				if(last_char_group == NO_CHARS_DETECTED)
					continue
				last_char_group = SYMBOLS_DETECTED

			// ~   |   @  :  #  $  %  &  *  +
			if(126,124,64,58,35,36,37,38,42,43)			//Other symbols that we'll allow (mainly for AI)
				if(last_char_group == NO_CHARS_DETECTED || !allow_numbers) //suppress at start of string
					continue
				last_char_group = SYMBOLS_DETECTED

			//Space
			if(32)
				if(last_char_group == NO_CHARS_DETECTED || last_char_group == SPACES_DETECTED) //suppress double-spaces and spaces at start of string
					continue
				last_char_group = SPACES_DETECTED

			if(127 to 1e31)
				if(ascii_only)
					continue
				last_char_group = SYMBOLS_DETECTED //for now, we'll treat all non-ascii characters like symbols even though most are letters

			else
				continue

		t_out += char
		charcount++
		if(charcount >= max_length)
			break

	if(number_of_alphanumeric < 2)
		return		//protects against tiny names like "A" and also names like "' ' ' ' ' ' ' '"

	if(last_char_group == SPACES_DETECTED)
		t_out = copytext_char(t_out, 1, -1) //removes the last character (in this case a space)

	for(var/bad_name in list("space","floor","wall","r-wall","monkey","unknown","inactive ai"))	//prevents these common metagamey names
		if(cmptext(t_out,bad_name))
			return	//(not case sensitive)

	return t_out

//Returns null if there is any bad text in the string
// slightly modified to actually check if the input is text first
/proc/reject_bad_text(text, max_length = 512, ascii_only = TRUE)
	if(!istext(text))
		return
	var/char_count = 0
	var/non_whitespace = FALSE
	var/lenbytes = length(text)
	var/char = ""
	for(var/i = 1, i <= lenbytes, i += length(char))
		char = text[i]
		char_count++
		if(char_count > max_length)
			return
		switch(text2ascii(char))
			if(62, 60, 92, 47) // <, >, \, /
				return
			if(0 to 31)
				return
			if(32)
				continue
			if(127 to INFINITY)
				if(ascii_only)
					return
			else
				non_whitespace = TRUE
	if(non_whitespace)
		return text		//only accepts the text if it has some non-spaces

#undef NO_CHARS_DETECTED
#undef SPACES_DETECTED
#undef NUMBERS_DETECTED
#undef LETTERS_DETECTED

/// Returns `string` repeated `times` times
/proc/repeat_string(times, string="")
	. = ""
	for(var/i=1, i<=times, i++)
		. += string
