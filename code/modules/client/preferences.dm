GLOBAL_LIST_EMPTY(preferences_datums)

/datum/preferences
	var/client/parent

	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used
	// TREAT THIS VAR AS PRIVATE. USE set_max_character_slots() PLEASE
	var/max_usable_slots = 3

	//non-preference stuff
	var/muted = 0
	var/last_ip
	var/last_id

	/// List of all character saves, with list index being slot ID
	var/list/datum/character_save/character_saves = list()
	/// Active character, ref to an item in that list
	var/datum/character_save/active_character

	//game-preferences
	var/lastchangelog = ""				//Saved changlog filesize to detect if there was a change
	var/ooccolor = "#c43b23"
	var/asaycolor = "#ff4500"			//This won't change the color for current admins, only incoming ones.
	var/tip_delay = 500 //tip delay in milliseconds

	//Antag preferences
	var/list/be_special = list()		//Special role selection
	var/tmp/old_be_special = 0			//Bitflag version of be_special, used to update old savefiles and nothing more
										//If it's 0, that's good, if it's anything but 0, the owner of this prefs file's antag choices were,
										//autocorrected this round, not that you'd need to check that.

	var/UI_style = null
	var/outline_color = COLOR_BLUE_GRAY

	///Whether we want balloon alerts displayed alone, with chat or not displayed at all
	var/see_balloon_alerts = BALLOON_ALERT_ALWAYS

	var/toggles = TOGGLES_DEFAULT
	var/toggles2 = TOGGLES_2_DEFAULT
	var/db_flags
	var/chat_toggles = TOGGLES_DEFAULT_CHAT
	var/ghost_form = "ghost"
	var/ghost_orbit = GHOST_ORBIT_CIRCLE
	var/ghost_accs = GHOST_ACCS_DEFAULT_OPTION
	var/ghost_others = GHOST_OTHERS_DEFAULT_OPTION
	var/preferred_map = null
	var/pda_theme = THEME_NTOS
	var/pda_color = "#808000"

	// Custom Keybindings
	var/list/key_bindings = null

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

	var/list/exp = list()
	var/job_exempt = 0

	//Loadout stuff
	var/list/purchased_gear = list()
	var/gear_tab = "Inner Clothing"

	var/action_buttons_screen_locs = list()

	var/pai_name = ""
	var/pai_description = ""
	var/pai_comment = ""

/datum/preferences/proc/set_max_character_slots(newmax)
	max_usable_slots = min(TRUE_MAX_SAVE_SLOTS, newmax) // Make sure they dont go over
	check_usable_slots()

/datum/preferences/New(client/C)
	parent = C

	character_saves.len = TRUE_MAX_SAVE_SLOTS
	for(var/i in 1 to TRUE_MAX_SAVE_SLOTS)
		var/datum/character_save/CS = new()
		CS.slot_number = i
		character_saves[i] = CS

	UI_style = GLOB.available_ui_styles[1]
	if(istype(C))
		if(!IS_GUEST_KEY(C.key))
			unlock_content = C.IsByondMember()
			if(unlock_content)
				set_max_character_slots(8)
		else if(!length(key_bindings)) // Guests need default keybinds
			key_bindings = deepCopyList(GLOB.keybinding_list_by_key)
	var/loaded_preferences_successfully = load_from_database()
	if(loaded_preferences_successfully)
		if("6030fe461e610e2be3a2c3e75c06067e" in purchased_gear) //MD5 hash of, "extra character slot"
			set_max_character_slots(max_usable_slots + 1)
		if(load_characters()) // inside this proc is a disgusting SQL query
			var/datum/character_save/target_save = character_saves[default_slot]
			if(target_save && !target_save.slot_locked)
				active_character = target_save
			else
				active_character = character_saves[1] // Default to first if unavailable
			return

	//we couldn't load character data so just randomize the character appearance + name
	active_character = character_saves[1]
	active_character.randomise()		//let's create a random character then - rather than a fat, bald and naked man.
	active_character.real_name = active_character.pref_species.random_name(active_character.gender, TRUE)
	if(!loaded_preferences_successfully)
		save_preferences()
	active_character.save(C)		//let's save this new random character so it doesn't keep generating new ones.
	return

#define APPEARANCE_CATEGORY_COLUMN "<td valign='top' width='14%'>"
#define MAX_MUTANT_ROWS 4

/datum/preferences/proc/ShowChoices(mob/user)
	if(!user || !user.client)
		return
	active_character.update_preview_icon(user.client)
	var/list/dat = list(TOOLTIP_CSS_SETUP, "<center>")

	dat += "<a href='?_src_=prefs;preference=tab;tab=0' [current_tab == 0 ? "class='linkOn'" : ""]>Character Settings</a>"
	dat += "<a href='?_src_=prefs;preference=tab;tab=1' [current_tab == 1 ? "class='linkOn'" : ""]>Game Preferences</a>"
	var/shop_name = "[CONFIG_GET(string/metacurrency_name)] Shop"
	dat += "<a href='?_src_=prefs;preference=tab;tab=2' [current_tab == 2 ? "class='linkOn'" : ""]>[shop_name]</a>"
	dat += "<a href='?_src_=prefs;preference=tab;tab=3' [current_tab == 3 ? "class='linkOn'" : ""]>OOC Preferences</a>"

	dat += "</center>"

	dat += "<HR>"

	switch(current_tab)
		if (0) // Character Settings#
			dat += "<center>"
			var/name
			var/unspaced_slots = 0
			for(var/datum/character_save/CS as anything in character_saves)
				unspaced_slots++
				if(unspaced_slots > 4)
					dat += "<br>"
					unspaced_slots = 0
				name = CS.real_name
				if(!name)
					name = "Character [CS.slot_number]"
				if(CS.slot_locked)
					dat += "<a style='white-space:nowrap;' class='linkOff'>[name] (Locked)</a> "
				else
					dat += "<a style='white-space:nowrap;' href='?_src_=prefs;preference=changeslot;num=[CS.slot_number];' [CS.slot_number == default_slot ? "class='linkOn'" : ""]>[name]</a> "
			dat += "</center>"

			dat += "<center><h2>Occupation Choices</h2>"
			dat += "<a href='?_src_=prefs;preference=job;task=menu'>Set Occupation Preferences</a><br></center>"
			if(CONFIG_GET(flag/roundstart_traits))
				dat += "<center><h2>Quirk Setup</h2>"
				dat += "<a href='?_src_=prefs;preference=trait;task=menu'>Configure Quirks</a><br></center>"
				dat += "<center><b>Current Quirks:</b> [length(active_character.all_quirks) ? active_character.all_quirks.Join(", ") : "None"]</center>"
			dat += "<h2>Identity</h2>"
			dat += "<table width='100%'><tr><td width='75%' valign='top'>"
			if(is_banned_from(user.ckey, "Appearance"))
				dat += "<b>You are banned from using custom names and appearances. You can continue to adjust your characters, but you will be randomised once you join the game.</b><br>"
			dat += "<a href='?_src_=prefs;preference=name;task=random'>Random Name</A> "
			dat += "<a href='?_src_=prefs;preference=name'>Always Random Name: [active_character.be_random_name ? "Yes" : "No"]</a><BR>"

			dat += "<b>[TOOLTIP_CONFIG_CALLER("Name:", 400, "preferences.naming_policy")] </b>"
			dat += "<a href='?_src_=prefs;preference=name;task=input'>[active_character.real_name]</a><BR>"

			if(!(AGENDER in active_character.pref_species.species_traits))
				dat += "<b>Gender:</b> <a href='?_src_=prefs;preference=gender'>[active_character.gender == MALE ? "Male" : "Female"]</a><BR>"
			dat += "<b>Age:</b> <a href='?_src_=prefs;preference=age;task=input'>[active_character.age]</a><BR>"

			dat += "<b>Special Names:</b><BR>"
			var/old_group
			for(var/custom_name_id in GLOB.preferences_custom_names)
				var/namedata = GLOB.preferences_custom_names[custom_name_id]
				if(!old_group)
					old_group = namedata["group"]
				else if(old_group != namedata["group"])
					old_group = namedata["group"]
					dat += "<br>"
				dat += "<a href ='?_src_=prefs;preference=[custom_name_id];task=input'><b>[namedata["pref_name"]]:</b> [active_character.custom_names[custom_name_id]]</a> "
			dat += "<br><br>"

			dat += "<b>Custom Job Preferences:</b><BR>"
			dat += "<a href='?_src_=prefs;preference=ai_core_icon;task=input'><b>Preferred AI Core Display:</b> [active_character.preferred_ai_core_display]</a><br>"
			dat += "<a href='?_src_=prefs;preference=sec_dept;task=input'><b>Preferred Security Department:</b> [active_character.preferred_security_department]</a><BR></td>"

			dat += "</tr></table>"

			dat += "<h2>Body</h2>"
			dat += "<a href='?_src_=prefs;preference=all;task=random'>Random Body</A> "
			dat += "<a href='?_src_=prefs;preference=all'>Always Random Body: [active_character.be_random_body ? "Yes" : "No"]</A><br>"

			dat += "<table width='100%'><tr><td width='24%' valign='top'>"

			dat += "<b>Species:</b><BR><a href='?_src_=prefs;preference=species;task=input'>[active_character.pref_species.name]</a><BR>"

			dat += "<b>Underwear:</b><BR><a href ='?_src_=prefs;preference=underwear;task=input'>[active_character.underwear]</a><BR>"
			dat += "<b>Underwear Color:</b><BR><span style='border: 1px solid #161616; background-color: #[active_character.underwear_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=underwear_color;task=input'>Change</a><BR>"
			dat += "<b>Undershirt:</b><BR><a href ='?_src_=prefs;preference=undershirt;task=input'>[active_character.undershirt]</a><BR>"
			dat += "<b>Socks:</b><BR><a href ='?_src_=prefs;preference=socks;task=input'>[active_character.socks]</a><BR>"
			dat += "<b>Backpack:</b><BR><a href ='?_src_=prefs;preference=bag;task=input'>[active_character.backbag]</a><BR>"
			dat += "<b>Jumpsuit:</b><BR><a href ='?_src_=prefs;preference=suit;task=input'>[active_character.jumpsuit_style]</a><BR>"
			dat += "<b>Uplink Spawn Location:</b><BR><a href ='?_src_=prefs;preference=uplink_loc;task=input'>[active_character.uplink_spawn_loc == UPLINK_IMPLANT ? UPLINK_IMPLANT_WITH_PRICE : active_character.uplink_spawn_loc]</a><BR></td>"

			var/use_skintones = active_character.pref_species.use_skintones
			if(use_skintones)

				dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Skin Tone</h3>"

				dat += "<a href='?_src_=prefs;preference=s_tone;task=input'>[active_character.skin_tone]</a><BR>"

			var/mutant_colors
			if((MUTCOLORS in active_character.pref_species.species_traits) || (MUTCOLORS_PARTSONLY in active_character.pref_species.species_traits))

				if(!use_skintones)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Mutant Color</h3>"

				dat += "<span style='border: 1px solid #161616; background-color: #[active_character.features["mcolor"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=mutant_color;task=input'>Change</a><BR>"

				mutant_colors = TRUE

			if(istype(active_character.pref_species, /datum/species/ethereal)) //not the best thing to do tbf but I dont know whats better.

				if(!use_skintones)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Ethereal Color</h3>"

				dat += "<span style='border: 1px solid #161616; background-color: #[active_character.features["ethcolor"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=color_ethereal;task=input'>Change</a><BR>"

			if(istype(active_character.pref_species, /datum/species/plasmaman))

				if(!use_skintones)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Envirohelmet Type</h3>"

				dat += "<a href='?_src_=prefs;preference=helmet_style;task=input'>[active_character.helmet_style]</a><BR>"

			if((EYECOLOR in active_character.pref_species.species_traits) && !(NOEYESPRITES in active_character.pref_species.species_traits))

				if(!use_skintones && !mutant_colors)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Eye Color</h3>"

				dat += "<span style='border: 1px solid #161616; background-color: #[active_character.eye_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=eyes;task=input'>Change</a><BR>"

				dat += "</td>"
			else if(use_skintones || mutant_colors)
				dat += "</td>"

			if(HAIR in active_character.pref_species.species_traits)

				dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Hair Style</h3>"

				dat += "<a href='?_src_=prefs;preference=hair_style;task=input'>[active_character.hair_style]</a><BR>"
				dat += "<a href='?_src_=prefs;preference=previous_hair_style;task=input'>&lt;</a> <a href='?_src_=prefs;preference=next_hair_style;task=input'>&gt;</a><BR>"
				dat += "<span style='border:1px solid #161616; background-color: #[active_character.hair_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=hair_color;task=input'>Change</a><BR>"

				dat += "<h3>Gradient Style</h3>"

				dat += "<a href='?_src_=prefs;preference=gradient_style;task=input'>[active_character.gradient_style]</a><BR>"
				dat += "<a href='?_src_=prefs;preference=previous_gradient_style;task=input'>&lt;</a> <a href='?_src_=prefs;preference=next_gradient_style;task=input'>&gt;</a><BR>"
				dat += "<span style='border:1px solid #161616; background-color: #[active_character.gradient_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=gradient_color;task=input'>Change</a><BR>"

				dat += "<h3>Facial Hair Style</h3>"

				dat += "<a href='?_src_=prefs;preference=facial_hair_style;task=input'>[active_character.facial_hair_style]</a><BR>"
				dat += "<a href='?_src_=prefs;preference=previous_facehair_style;task=input'>&lt;</a> <a href='?_src_=prefs;preference=next_facehair_style;task=input'>&gt;</a><BR>"
				dat += "<span style='border: 1px solid #161616; background-color: #[active_character.facial_hair_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=facial;task=input'>Change</a><BR>"

				dat += "</td>"

			//Mutant stuff
			var/mutant_category = 0

			if("tail_lizard" in active_character.pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Tail</h3>"

				dat += "<a href='?_src_=prefs;preference=tail_lizard;task=input'>[active_character.features["tail_lizard"]]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("snout" in active_character.pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Snout</h3>"

				dat += "<a href='?_src_=prefs;preference=snout;task=input'>[active_character.features["snout"]]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("horns" in active_character.pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Horns</h3>"

				dat += "<a href='?_src_=prefs;preference=horns;task=input'>[active_character.features["horns"]]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("frills" in active_character.pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Frills</h3>"

				dat += "<a href='?_src_=prefs;preference=frills;task=input'>[active_character.features["frills"]]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("spines" in active_character.pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Spines</h3>"

				dat += "<a href='?_src_=prefs;preference=spines;task=input'>[active_character.features["spines"]]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("body_markings" in active_character.pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Body Markings</h3>"

				dat += "<a href='?_src_=prefs;preference=body_markings;task=input'>[active_character.features["body_markings"]]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("legs" in active_character.pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Legs</h3>"

				dat += "<a href='?_src_=prefs;preference=legs;task=input'>[active_character.features["legs"]]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("moth_wings" in active_character.pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Moth wings</h3>"

				dat += "<a href='?_src_=prefs;preference=moth_wings;task=input'>[active_character.features["moth_wings"]]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("moth_antennae" in active_character.pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Moth antennae</h3>"

				dat += "<a href='?_src_=prefs;preference=moth_antennae;task=input'>[active_character.features["moth_antennae"]]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("moth_markings" in active_character.pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Moth markings</h3>"

				dat += "<a href='?_src_=prefs;preference=moth_markings;task=input'>[active_character.features["moth_markings"]]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("ipc_screen" in active_character.pref_species.mutant_bodyparts)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Screen Style</h3>"

				dat += "<a href='?_src_=prefs;preference=ipc_screen;task=input'>[active_character.features["ipc_screen"]]</a><BR>"

				dat += "<span style='border: 1px solid #161616; background-color: #[active_character.eye_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=eyes;task=input'>Change</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("ipc_antenna" in active_character.pref_species.mutant_bodyparts)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Antenna Style</h3>"

				dat += "<a href='?_src_=prefs;preference=ipc_antenna;task=input'>[active_character.features["ipc_antenna"]]</a><BR>"

				dat += "<span style='border:1px solid #161616; background-color: #[active_character.hair_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=hair_color;task=input'>Change</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("ipc_chassis" in active_character.pref_species.mutant_bodyparts)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Chassis Style</h3>"

				dat += "<a href='?_src_=prefs;preference=ipc_chassis;task=input'>[active_character.features["ipc_chassis"]]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("tail_human" in active_character.pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Tail</h3>"

				dat += "<a href='?_src_=prefs;preference=tail_human;task=input'>[active_character.features["tail_human"]]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("insect_type" in active_character.pref_species.mutant_bodyparts)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Insect Type</h3>"

				dat += "<a href='?_src_=prefs;preference=insect_type;task=input'>[active_character.features["insect_type"]]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("apid_antenna" in active_character.pref_species.mutant_bodyparts)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Antenna Style</h3>"

				dat += "<a href='?_src_=prefs;preference=apid_antenna;task=input'>[active_character.features["apid_antenna"]]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("apid_stripes" in active_character.pref_species.mutant_bodyparts)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Stripe Pattern</h3>"

				dat += "<a href='?_src_=prefs;preference=apid_stripes;task=input'>[active_character.features["apid_stripes"]]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("apid_headstripes" in active_character.pref_species.mutant_bodyparts)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Headstripe Pattern</h3>"

				dat += "<a href='?_src_=prefs;preference=apid_headstripes;task=input'>[active_character.features["apid_headstripes"]]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("ears" in active_character.pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Ears</h3>"

				dat += "<a href='?_src_=prefs;preference=ears;task=input'>[active_character.features["ears"]]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if("body_size" in active_character.pref_species.default_features)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Size</h3>"

				dat += "<a href='?_src_=prefs;preference=body_size;task=input'>[active_character.features["body_size"]]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(CONFIG_GET(flag/join_with_mutant_humans))

				if("wings" in active_character.pref_species.default_features && GLOB.r_wings_list.len >1)
					if(!mutant_category)
						dat += APPEARANCE_CATEGORY_COLUMN

					dat += "<h3>Wings</h3>"

					dat += "<a href='?_src_=prefs;preference=wings;task=input'>[active_character.features["wings"]]</a><BR>"

					mutant_category++
					if(mutant_category >= MAX_MUTANT_ROWS)
						dat += "</td>"
						mutant_category = 0

			if(mutant_category)
				dat += "</td>"
				mutant_category = 0
			dat += "</tr></table>"


		if (1) // Game Preferences
			dat += "<table><tr><td width='340px' height='300px' valign='top'>"
			dat += "<h2>General Settings</h2>"
			dat += "<b>UI Style:</b> <a href='?_src_=prefs;task=input;preference=ui'>[UI_style]</a><br>"
			dat += "<b>Outline:</b> <a href='?_src_=prefs;preference=outline_enabled'>[toggles & PREFTOGGLE_OUTLINE_ENABLED ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>Outline Color:</b> <span style='border:1px solid #161616; background-color: [outline_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=outline_color'>Change</a><BR>"
			dat += "<b>tgui Monitors:</b> <a href='?_src_=prefs;preference=tgui_lock'>[(toggles2 & PREFTOGGLE_2_LOCKED_TGUI) ? "Primary" : "All"]</a><br>"
			dat += "<b>tgui Style:</b> <a href='?_src_=prefs;preference=tgui_fancy'>[(toggles2 & PREFTOGGLE_2_FANCY_TGUI) ? "Fancy" : "No Frills"]</a><br>"
			dat += "<b>Show Runechat Chat Bubbles:</b> <a href='?_src_=prefs;preference=chat_on_map'>[toggles & PREFTOGGLE_RUNECHAT_GLOBAL ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>See Runechat for non-mobs:</b> <a href='?_src_=prefs;preference=see_chat_non_mob'>[toggles & PREFTOGGLE_RUNECHAT_NONMOBS ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>See Runechat emotes:</b> <a href='?_src_=prefs;preference=see_rc_emotes'>[toggles & PREFTOGGLE_RUNECHAT_EMOTES ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>See Balloon alerts: </b> <a href='?_src_=prefs;preference=see_balloon_alerts;task=input'>[see_balloon_alerts]</a>"
			dat += "<br>"
			dat += "<b>Action Buttons:</b> <a href='?_src_=prefs;preference=action_buttons'>[(toggles2 & PREFTOGGLE_2_LOCKED_BUTTONS) ? "Locked In Place" : "Unlocked"]</a><br>"
			dat += "<b>Hotkey Mode:</b> <a href='?_src_=prefs;preference=hotkeys'>[(toggles2 & PREFTOGGLE_2_HOTKEYS) ? "Hotkeys" : "Default"]</a><br>"
			dat += "<br>"
			dat += "<b>PDA Theme:</b> <a href='?_src_=prefs;task=input;preference=pda_theme'>[theme_name_for_id(pda_theme)]</a><br>"
			dat += "<b>PDA Classic Color:</b> <span style='border:1px solid #161616; background-color: [pda_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=pda_color;task=input'>Change</a><BR>"
			dat += "<br>"
			dat += "<b>Crew Objectives:</b> <a href='?_src_=prefs;preference=crewobj'>[(toggles2 & PREFTOGGLE_2_CREW_OBJECTIVES) ? "Yes" : "No"]</a><br>"
			dat += "<br>"
			dat += "<b>Ghost Ears:</b> <a href='?_src_=prefs;preference=ghost_ears'>[(chat_toggles & CHAT_GHOSTEARS) ? "All Speech" : "Nearest Creatures"]</a><br>"
			dat += "<b>Ghost Radio:</b> <a href='?_src_=prefs;preference=ghost_radio'>[(chat_toggles & CHAT_GHOSTRADIO) ? "All Messages":"No Messages"]</a><br>"
			dat += "<b>Ghost Sight:</b> <a href='?_src_=prefs;preference=ghost_sight'>[(chat_toggles & CHAT_GHOSTSIGHT) ? "All Emotes" : "Nearest Creatures"]</a><br>"
			dat += "<b>Ghost Whispers:</b> <a href='?_src_=prefs;preference=ghost_whispers'>[(chat_toggles & CHAT_GHOSTWHISPER) ? "All Speech" : "Nearest Creatures"]</a><br>"
			dat += "<b>Ghost PDA:</b> <a href='?_src_=prefs;preference=ghost_pda'>[(chat_toggles & CHAT_GHOSTPDA) ? "All Messages" : "Nearest Creatures"]</a><br>"
			dat += "<b>Ghost Law Changes:</b> <a href='?_src_=prefs;preference=ghost_laws'>[(chat_toggles & CHAT_GHOSTLAWS) ? "All Law Changes" : "No Law Changes"]</a><br>"
			dat += "<b>Ghost (F) Chat toggle:</b> <a href='?_src_=prefs;preference=ghost_follow'>[(chat_toggles & CHAT_GHOSTFOLLOWMINDLESS) ? "All mobs" : "Only mobs with mind"]</a><br>"

			if(unlock_content)
				dat += "<b>Ghost Form:</b> <a href='?_src_=prefs;task=input;preference=ghostform'>[ghost_form]</a><br>"
				dat += "<B>Ghost Orbit: </B> <a href='?_src_=prefs;task=input;preference=ghostorbit'>[ghost_orbit]</a><br>"

			var/button_name = "If you see this something went wrong."
			switch(ghost_accs)
				if(GHOST_ACCS_FULL)
					button_name = GHOST_ACCS_FULL_NAME
				if(GHOST_ACCS_DIR)
					button_name = GHOST_ACCS_DIR_NAME
				if(GHOST_ACCS_NONE)
					button_name = GHOST_ACCS_NONE_NAME

			dat += "<b>Ghost Accessories:</b> <a href='?_src_=prefs;task=input;preference=ghostaccs'>[button_name]</a><br>"

			switch(ghost_others)
				if(GHOST_OTHERS_THEIR_SETTING)
					button_name = GHOST_OTHERS_THEIR_SETTING_NAME
				if(GHOST_OTHERS_DEFAULT_SPRITE)
					button_name = GHOST_OTHERS_DEFAULT_SPRITE_NAME
				if(GHOST_OTHERS_SIMPLE)
					button_name = GHOST_OTHERS_SIMPLE_NAME

			dat += "<b>Ghosts of Others:</b> <a href='?_src_=prefs;task=input;preference=ghostothers'>[button_name]</a><br>"
			dat += "<br>"

			dat += "<b>Income Updates:</b> <a href='?_src_=prefs;preference=income_pings'>[(chat_toggles & CHAT_BANKCARD) ? "Allowed" : "Muted"]</a><br>"
			dat += "<br>"

			dat += "<b>FPS:</b> <a href='?_src_=prefs;preference=clientfps;task=input'>[clientfps]</a><br>"

			dat += "<b>Parallax (Fancy Space):</b> <a href='?_src_=prefs;preference=parallaxdown' oncontextmenu='window.location.href=\"?_src_=prefs;preference=parallaxup\";return false;'>"
			switch (parallax)
				if (PARALLAX_LOW)
					dat += "Low"
				if (PARALLAX_MED)
					dat += "Medium"
				if (PARALLAX_INSANE)
					dat += "Insane"
				if (PARALLAX_DISABLE)
					dat += "Disabled"
				else
					dat += "High"
			dat += "</a><br>"

			dat += "<b>Ambient Occlusion:</b> <a href='?_src_=prefs;preference=ambientocclusion'>[toggles2 & PREFTOGGLE_2_AMBIENT_OCCLUSION ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>Fit Viewport:</b> <a href='?_src_=prefs;preference=auto_fit_viewport'>[toggles2 & PREFTOGGLE_2_AUTO_FIT_VIEWPORT ? "Auto" : "Manual"]</a><br>"

			button_name = pixel_size
			dat += "<b>Pixel Scaling:</b> <a href='?_src_=prefs;preference=pixel_size'>[(button_name) ? "Pixel Perfect [button_name]x" : "Stretch to fit"]</a><br>"

			switch(scaling_method)
				if(SCALING_METHOD_NORMAL)
					button_name = "Nearest Neighbor"
				if(SCALING_METHOD_DISTORT)
					button_name = "Point Sampling"
				if(SCALING_METHOD_BLUR)
					button_name = "Bilinear"
			dat += "<b>Scaling Method:</b> <a href='?_src_=prefs;preference=scaling_method'>[button_name]</a><br>"

			if (CONFIG_GET(flag/maprotation))
				var/p_map = preferred_map
				if (!p_map)
					p_map = "Default"
					if (config.defaultmap)
						p_map += " ([config.defaultmap.map_name])"
				else
					if (p_map in config.maplist)
						var/datum/map_config/VM = config.maplist[p_map]
						if (!VM)
							p_map += " (No longer exists)"
						else
							p_map = VM.map_name
					else
						p_map += " (No longer exists)"
				if(CONFIG_GET(flag/preference_map_voting))
					dat += "<b>Preferred Map:</b> <a href='?_src_=prefs;preference=preferred_map;task=input'>[p_map]</a><br>"

			dat += "</td><td width='300px' height='300px' valign='top'>"

			dat += "<h2>Special Role Settings</h2>"

			if(is_banned_from(user.ckey, ROLE_SYNDICATE))
				dat += "<font color=red><b>You are banned from antagonist roles.</b></font><br>"
				src.be_special = list()


			for (var/i in GLOB.special_roles)
				if(is_banned_from(user.ckey, i))
					dat += "<b>Be [capitalize(i)]:</b> <a href='?_src_=prefs;bancheck=[i]'>BANNED</a><br>"
				else
					var/days_remaining = null
					if(ispath(GLOB.special_roles[i]) && CONFIG_GET(flag/use_age_restriction_for_jobs)) //If it's a game mode antag, check if the player meets the minimum age
						var/mode_path = GLOB.special_roles[i]
						var/datum/game_mode/temp_mode = new mode_path
						days_remaining = temp_mode.get_remaining_days(user.client)

					if(days_remaining)
						dat += "<b>Be [capitalize(i)]:</b> <font color=red> \[IN [days_remaining] DAYS]</font><br>"
					else
						dat += "<b>Be [capitalize(i)]:</b> <a href='?_src_=prefs;preference=be_special;be_special_type=[i]'>[(i in be_special) ? "Enabled" : "Disabled"]</a><br>"
			dat += "<br>"
			dat += "<b>Midround Antagonist:</b> <a href='?_src_=prefs;preference=allow_midround_antag'>[(toggles & PREFTOGGLE_MIDROUND_ANTAG) ? "Enabled" : "Disabled"]</a><br>"

			dat += "</td></tr><tr><td> </td></tr>" // i hate myself for this
			dat += "<tr><td colspan='2' width='100%'><center><a style='font-size: 18px;' href='?_src_=prefs;preference=keybindings_menu'>Customize Keybinds</a></center></td></tr>"
			dat += "</table>"

		if(2) //Loadout
			var/list/type_blacklist = list()
			if(length(active_character.equipped_gear))
				for(var/i in 1 to length(active_character.equipped_gear))
					var/datum/gear/G = GLOB.gear_datums[active_character.equipped_gear[i]]
					if(G)
						if(G.subtype_path in type_blacklist)
							continue
						type_blacklist += G.subtype_path
					else
						active_character.equipped_gear.Cut(i,i+1)

			dat += "<center>"
			var/name
			var/unspaced_slots = 0
			for(var/datum/character_save/CS as anything in character_saves)
				unspaced_slots++
				if(unspaced_slots > 4)
					dat += "<br>"
					unspaced_slots = 0
				name = CS.real_name
				if(!name)
					name = "Character [CS.slot_number]"
				if(CS.slot_locked)
					dat += "<a style='white-space:nowrap;' class='linkOff'>[name] (Locked)</a> "
				else
					dat += "<a style='white-space:nowrap;' href='?_src_=prefs;preference=changeslot;num=[CS.slot_number];' [CS.slot_number == default_slot ? "class='linkOn'" : ""]>[name]</a> "
			dat += "</center>"

			var/fcolor =  "#3366CC"
			var/metabalance = user.client.get_metabalance()
			dat += "<table align='center' width='100%'>"
			dat += "<tr><td colspan=4><center><b>Current balance: <font color='[fcolor]'>[metabalance]</font> [CONFIG_GET(string/metacurrency_name)]s.</b> \[<a href='?_src_=prefs;preference=gear;clear_loadout=1'>Clear Loadout</a>\]</center></td></tr>"
			dat += "<tr><td colspan=4><center><b>"

			var/firstcat = 1
			for(var/category in GLOB.loadout_categories)
				if(category == "Donator" && (!LAZYLEN(GLOB.patrons) || !CONFIG_GET(flag/donator_items)))
					continue
				if(firstcat)
					firstcat = 0
				else
					dat += " |"
				if(category == gear_tab)
					dat += " <span class='linkOff'>[category]</span> "
				else
					dat += " <a href='?_src_=prefs;preference=gear;select_category=[category]'>[category]</a> "
			dat += "</b></center></td></tr>"

			var/datum/loadout_category/LC = GLOB.loadout_categories[gear_tab]
			dat += "<tr><td colspan=4><hr></td></tr>"
			dat += "<tr><td colspan=4><b><center>[LC.category]</center></b></td></tr>"
			dat += "<tr><td colspan=4><hr></td></tr>"

			dat += "<tr><td colspan=4><hr></td></tr>"
			dat += "<tr><td><b>Name</b></td>"
			dat += "<td><b>Cost</b></td>"
//			dat += "<td><b>Restricted Jobs</b></td>"
			dat += "<td><b>Description</b></td></tr>"
			dat += "<tr><td colspan=4><hr></td></tr>"
			var/endingdat
			for(var/gear_id in LC.gear)
				var/datum/gear/G = LC.gear[gear_id]
				var/ticked = (G.id in active_character.equipped_gear)
				var/donator = G.sort_category == "Donator"

				if(G.sort_category != "OOC" && (G.id in purchased_gear))
					//Defines the beginning of the row
					dat += "<tr style='vertical-align:top;'>"

					//First column of info - the item's name
					dat += "<td width=15%>[G.display_name]</td>" 
					
					//Second column for the equip button, since we already own this item
					dat += "<td width = 10% style='vertical-align:top'>"
					dat += "<a style='white-space:normal;' [ticked ? "class='linkOn' " : ""]href='?_src_=prefs;preference=gear;toggle_gear=[G.id]'>Equip</a></td>" 
/*					
					//Third column gets a bit messy, it's for listing restricted jobs
					dat += "<td width = 12%>"
					if(G.allowed_roles)
						dat += "<font size=2>"
						for(var/role in G.allowed_roles)
							dat += role + ", "
						dat += "</font>"
					dat += "</td>"
*/
					//And the fourth and final column is just for the item's description
					dat += "<td><font size=2><i>[G.description]</i></font></td>"

					//Finally, we close out the row
					dat += "</tr>"

				else

					//beginning of the row
					endingdat += "<tr style='vertical-align:top;'>"

					//First column
					endingdat += "<td width=15%>[G.display_name]</td>" 
					
					//Second column for the purchase or donator button since we have not purchased items in this loop
					endingdat += "<td width = 10% style='vertical-align:top'>"
					endingdat += "<a style='white-space:normal;' href='?_src_=prefs;preference=gear;purchase_gear=[G.id]'>[donator ? "Donator" : "Purchase: [G.cost]"]</a></td>"

/*					//Third column
					endingdat += "<td width = 12%>"
					if(G.allowed_roles)
						endingdat += "<font size=2>"
						for(var/role in G.allowed_roles)
							endingdat += role + ", "
						endingdat += "</font>"
					endingdat += "</td>"
*/
					//fourth column
					endingdat += "<td><font size=2><i>[G.description]</i></font></td>"

					//end of row
					endingdat += "</tr>"

			//time to combine our purchased and non-purchased rows and end the table
			dat += endingdat
			dat += "</table>"

		if(3) //OOC Preferences
			dat += "<table><tr><td width='340px' height='300px' valign='top'>"
			dat += "<h2>OOC Settings</h2>"
			dat += "<b>Window Flashing:</b> <a href='?_src_=prefs;preference=winflash'>[(toggles2 & PREFTOGGLE_2_WINDOW_FLASHING) ? "Enabled":"Disabled"]</a><br>"
			dat += "<br>"
			dat += "<b>Play Admin MIDIs:</b> <a href='?_src_=prefs;preference=hear_midis'>[(toggles & PREFTOGGLE_SOUND_MIDI) ? "Enabled":"Disabled"]</a><br>"
			dat += "<b>Play Lobby Music:</b> <a href='?_src_=prefs;preference=lobby_music'>[(toggles & PREFTOGGLE_SOUND_LOBBY) ? "Enabled":"Disabled"]</a><br>"
			dat += "<b>See Pull Requests:</b> <a href='?_src_=prefs;preference=pull_requests'>[(chat_toggles & CHAT_PULLR) ? "Enabled":"Disabled"]</a><br>"
			dat += "<br>"


			if(user.client)
				if(unlock_content)
					dat += "<b>BYOND Membership Publicity:</b> <a href='?_src_=prefs;preference=publicity'>[(toggles & PREFTOGGLE_MEMBER_PUBLIC) ? "Public" : "Hidden"]</a><br>"

				if(unlock_content || check_rights_for(user.client, R_ADMIN))
					dat += "<b>OOC Color:</b> <span style='border: 1px solid #161616; background-color: [ooccolor ? ooccolor : GLOB.normal_ooc_colour];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=ooccolor;task=input'>Change</a><br>"

			dat += "</td>"

			if(user.client.holder)
				dat +="<td width='300px' height='300px' valign='top'>"

				dat += "<h2>Admin Settings</h2>"

				dat += "<b>Adminhelp Sounds:</b> <a href='?_src_=prefs;preference=hear_adminhelps'>[(toggles & PREFTOGGLE_SOUND_ADMINHELP)?"Enabled":"Disabled"]</a><br>"
				dat += "<b>Prayer Sounds:</b> <a href = '?_src_=prefs;preference=hear_prayers'>[(toggles & PREFTOGGLE_SOUND_PRAYERS)?"Enabled":"Disabled"]</a><br>"
				dat += "<b>Announce Login:</b> <a href='?_src_=prefs;preference=announce_login'>[(toggles & PREFTOGGLE_ANNOUNCE_LOGIN)?"Enabled":"Disabled"]</a><br>"
				dat += "<br>"
				dat += "<b>Combo HUD Lighting:</b> <a href = '?_src_=prefs;preference=combohud_lighting'>[(toggles & PREFTOGGLE_COMBOHUD_LIGHTING)?"Full-bright":"No Change"]</a><br>"
				dat += "<br>"
				dat += "<b>Hide Dead Chat:</b> <a href = '?_src_=prefs;preference=toggle_dead_chat'>[(chat_toggles & CHAT_DEAD)?"Shown":"Hidden"]</a><br>"
				dat += "<b>Hide Radio Messages:</b> <a href = '?_src_=prefs;preference=toggle_radio_chatter'>[(chat_toggles & CHAT_RADIO)?"Shown":"Hidden"]</a><br>"
				dat += "<b>Hide Prayers:</b> <a href = '?_src_=prefs;preference=toggle_prayers'>[(chat_toggles & CHAT_PRAYER)?"Shown":"Hidden"]</a><br>"
				if(CONFIG_GET(flag/allow_admin_asaycolor))
					dat += "<br>"
					dat += "<b>ASAY Color:</b> <span style='border: 1px solid #161616; background-color: [asaycolor ? asaycolor : "#FF4500"];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=asaycolor;task=input'>Change</a><br>"

				//deadmin
				dat += "<h2>Deadmin While Playing</h2>"
				if(CONFIG_GET(flag/auto_deadmin_players))
					dat += "<b>Always Deadmin:</b> FORCED</a><br>"
				else
					dat += "<b>Always Deadmin:</b> <a href = '?_src_=prefs;preference=toggle_deadmin_always'>[(toggles & PREFTOGGLE_DEADMIN_ALWAYS)?"Enabled":"Disabled"]</a><br>"
					if(!(toggles & PREFTOGGLE_DEADMIN_ALWAYS))
						dat += "<br>"
						if(!CONFIG_GET(flag/auto_deadmin_antagonists))
							dat += "<b>As Antag:</b> <a href = '?_src_=prefs;preference=toggle_deadmin_antag'>[(toggles & PREFTOGGLE_DEADMIN_ANTAGONIST)?"Deadmin":"Keep Admin"]</a><br>"
						else
							dat += "<b>As Antag:</b> FORCED<br>"

						if(!CONFIG_GET(flag/auto_deadmin_heads))
							dat += "<b>As Command:</b> <a href = '?_src_=prefs;preference=toggle_deadmin_head'>[(toggles & PREFTOGGLE_DEADMIN_POSITION_HEAD)?"Deadmin":"Keep Admin"]</a><br>"
						else
							dat += "<b>As Command:</b> FORCED<br>"

						if(!CONFIG_GET(flag/auto_deadmin_security))
							dat += "<b>As Security:</b> <a href = '?_src_=prefs;preference=toggle_deadmin_security'>[(toggles & PREFTOGGLE_DEADMIN_POSITION_SECURITY)?"Deadmin":"Keep Admin"]</a><br>"
						else
							dat += "<b>As Security:</b> FORCED<br>"

						if(!CONFIG_GET(flag/auto_deadmin_silicons))
							dat += "<b>As Silicon:</b> <a href = '?_src_=prefs;preference=toggle_deadmin_silicon'>[(toggles & PREFTOGGLE_DEADMIN_POSITION_SILICON)?"Deadmin":"Keep Admin"]</a><br>"
						else
							dat += "<b>As Silicon:</b> FORCED<br>"

				dat += "</td>"
			dat += "</tr></table>"

	dat += "<hr><center>"

	if(!IS_GUEST_KEY(user.key))
		dat += "<a href='?_src_=prefs;preference=load'>Undo</a> "
		dat += "<a href='?_src_=prefs;preference=save'>Save Setup</a> "

	dat += "<a href='?_src_=prefs;preference=reset_all'>Reset Setup</a>"
	dat += "</center>"

	winshow(user, "preferences_window", TRUE)
	var/datum/browser/popup = new(user, "preferences_browser", "<div align='center'>Character Setup</div>", 640, 830)
	popup.set_content(dat.Join())
	popup.open(FALSE)
	onclose(user, "preferences_window", src)

#undef APPEARANCE_CATEGORY_COLUMN
#undef MAX_MUTANT_ROWS

/datum/preferences/proc/SetChoices(mob/user, limit = 16, list/splitJobs = list(JOB_NAME_CLOWN, JOB_NAME_RESEARCHDIRECTOR), widthPerColumn = 295, height = 620)
	if(!SSjob)
		return

	//limit - The amount of jobs allowed per column. Defaults to 17 to make it look nice.
	//splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads. Defaults to CE to make it look nice.
	//widthPerColumn - Screen's width for every column.
	//height - Screen's height.

	var/width = widthPerColumn

	var/HTML = "<center>"
	if(SSjob.occupations.len <= 0)
		HTML += "The job SSticker is not yet finished creating jobs, please try again later"
		HTML += "<center><a href='?_src_=prefs;preference=job;task=close'>Done</a></center><br>" // Easier to press up here.

	else
		HTML += "<b>Choose occupation chances</b><br>"
		HTML += "<div align='center'>Left-click to raise an occupation preference, right-click to lower it.<br></div>"
		HTML += "<center><a href='?_src_=prefs;preference=job;task=close'>Done</a></center><br>" // Easier to press up here.
		HTML += "<script type='text/javascript'>function setJobPrefRedirect(level, rank) { window.location.href='?_src_=prefs;preference=job;task=setJobLevel;level=' + level + ';text=' + encodeURIComponent(rank); return false; }</script>"
		HTML += "<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='20%'>" // Table within a table for alignment, also allows you to easily add more colomns.
		HTML += "<table width='100%' cellpadding='1' cellspacing='0'>"
		var/index = -1

		//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
		var/datum/job/lastJob

		var/datum/job/overflow = SSjob.GetJob(SSjob.overflow_role)

		for(var/datum/job/job in sortList(SSjob.occupations, /proc/cmp_job_display_asc))
			if(job.gimmick) //Gimmick jobs run off of a single pref
				continue
			index += 1
			if((index >= limit) || (job.title in splitJobs))
				width += widthPerColumn
				if((index < limit) && (lastJob != null))
					//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
					//the last job's selection color. Creating a rather nice effect.
					for(var/i = 0, i < (limit - index), i += 1)
						HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"
				HTML += "</table></td><td width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
				index = 0

			HTML += "<tr bgcolor='[job.selection_color]'><td width='60%' align='right'>"
			var/rank = job.title
			lastJob = job
			if(is_banned_from(user.ckey, rank))
				HTML += "<font color=red>[rank]</font></td><td><a href='?_src_=prefs;bancheck=[rank]'> BANNED</a></td></tr>"
				continue
			var/required_playtime_remaining = job.required_playtime_remaining(user.client)
			if(required_playtime_remaining)
				HTML += "<font color=red>[rank]</font></td><td><font color=red> \[ [get_exp_format(required_playtime_remaining)] as [job.get_exp_req_type()] \] </font></td></tr>"
				continue
			if(!job.player_old_enough(user.client))
				var/available_in_days = job.available_in_days(user.client)
				HTML += "<font color=red>[rank]</font></td><td><font color=red> \[IN [(available_in_days)] DAYS\]</font></td></tr>"
				continue
			if((active_character.job_preferences[overflow] == JP_LOW) && (rank != SSjob.overflow_role) && !is_banned_from(user.ckey, SSjob.overflow_role))
				HTML += "<font color=orange>[rank]</font></td><td></td></tr>"
				continue
			if((rank in GLOB.command_positions) || (rank == JOB_NAME_AI))//Bold head jobs
				HTML += "<b><span class='dark'>[rank]</span></b>"
			else
				HTML += "<span class='dark'>[rank]</span>"

			HTML += "</td><td width='40%'>"

			var/prefLevelLabel = "ERROR"
			var/prefLevelColor = "pink"
			var/prefUpperLevel = -1 // level to assign on left click
			var/prefLowerLevel = -1 // level to assign on right click

			switch(active_character.job_preferences[job.title])
				if(JP_HIGH)
					prefLevelLabel = "High"
					prefLevelColor = "slateblue"
					prefUpperLevel = 4
					prefLowerLevel = 2
				if(JP_MEDIUM)
					prefLevelLabel = "Medium"
					prefLevelColor = "green"
					prefUpperLevel = 1
					prefLowerLevel = 3
				if(JP_LOW)
					prefLevelLabel = "Low"
					prefLevelColor = "orange"
					prefUpperLevel = 2
					prefLowerLevel = 4
				else
					prefLevelLabel = "NEVER"
					prefLevelColor = "red"
					prefUpperLevel = 3
					prefLowerLevel = 1

			HTML += "<a class='white' href='?_src_=prefs;preference=job;task=setJobLevel;level=[prefUpperLevel];text=[rank]' oncontextmenu='javascript:return setJobPrefRedirect([prefLowerLevel], \"[rank]\");'>"

			if(rank == SSjob.overflow_role)//Overflow is special
				if(active_character.job_preferences[overflow.title] == JP_LOW)
					HTML += "<font color=green>Yes</font>"
				else
					HTML += "<font color=red>No</font>"
				HTML += "</a></td></tr>"
				continue

			HTML += "<font color=[prefLevelColor]>[prefLevelLabel]</font>"
			HTML += "</a></td></tr>"

		for(var/i = 1, i < (limit - index), i += 1) // Finish the column so it is even
			HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"

		HTML += "</td'></tr></table>"
		HTML += "</center></table>"

		var/message = "Be an [SSjob.overflow_role] if preferences unavailable"
		if(active_character.joblessrole == BERANDOMJOB)
			message = "Get random job if preferences unavailable"
		else if(active_character.joblessrole == RETURNTOLOBBY)
			message = "Return to lobby if preferences unavailable"
		HTML += "<center><br><a href='?_src_=prefs;preference=job;task=random'>[message]</a></center>"
		HTML += "<center><a href='?_src_=prefs;preference=job;task=reset'>Reset Preferences</a></center>"

	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Occupation Preferences</div>", width, height)
	popup.set_window_options("can_close=0")
	popup.set_content(HTML)
	popup.open(FALSE)


/datum/preferences/proc/ShowKeybindings(mob/user)
	// Create an inverted list of keybindings -> key
	var/list/user_binds = list()
	for(var/key in key_bindings)
		for(var/kb_name in key_bindings[key])
			user_binds[kb_name] = key

	var/list/kb_categories = list()
	// Group keybinds by category
	for (var/name in GLOB.keybindings_by_name)
		var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
		if (!(kb.category in kb_categories))
			kb_categories[kb.category] = list()
		kb_categories[kb.category] += list(kb)

	var/HTML = "<style>label { display: inline-block; width: 200px; }</style><body>"

	for (var/category in kb_categories)
		HTML += "<h3>[category]</h3>"
		for (var/i in kb_categories[category])
			var/datum/keybinding/kb = i
			var/bound_key = user_binds[kb.name]
			bound_key = (bound_key) ? bound_key : "Unbound"

			HTML += "<label>[kb.full_name]</label> <a href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=[url_encode(bound_key)]'>[bound_key] Default: ( [kb.key] )</a>"
			HTML += "<br>"

	HTML += "<br><br>"
	HTML += "<a href ='?_src_=prefs;preference=keybindings_done'>Close</a>"
	HTML += "<a href ='?_src_=prefs;preference=keybindings_reset'>Reset to default</a>"
	HTML += "</body>"

	winshow(user, "keybindings", TRUE)
	var/datum/browser/popup = new(user, "keybindings", "<div align='center'>Keybindings</div>", 500, 900)
	popup.set_content(HTML)
	popup.open(FALSE)
	onclose(user, "keybindings", src)


/datum/preferences/proc/CaptureKeybinding(mob/user, datum/keybinding/kb, var/old_key)
	var/HTML = {"
	<div id='focus' style="outline: 0;" tabindex=0>Keybinding: [kb.full_name]<br>[kb.description]<br><br><b>Press any key to change<br>Press ESC to clear</b></div>
	<script>
	document.onkeyup = function(e) {
		var shift = e.shiftKey ? 1 : 0;
		var alt = e.altKey ? 1 : 0;
		var ctrl = e.ctrlKey ? 1 : 0;
		var numpad = (95 < e.keyCode && e.keyCode < 112) ? 1 : 0;
		var escPressed = e.keyCode == 27 ? 1 : 0;
		var url = 'byond://?_src_=prefs;preference=keybindings_set;keybinding=[kb.name];old_key=[url_encode(old_key)];clear_key='+escPressed+';key='+encodeURIComponent(e.key)+';shift='+shift+';alt='+alt+';ctrl='+ctrl+';numpad='+numpad+';key_code='+e.keyCode;
		window.location=url;
	}
	document.getElementById('focus').focus();
	</script>
	"}
	winshow(user, "capturekeypress", TRUE)
	var/datum/browser/popup = new(user, "capturekeypress", "<div align='center'>Keybindings</div>", 350, 300)
	popup.set_content(HTML)
	popup.open(FALSE)
	onclose(user, "capturekeypress", src)


/datum/preferences/proc/SetJobPreferenceLevel(datum/job/job, level)
	if (!job)
		return FALSE

	if (level == JP_HIGH) // to high
		//Set all other high to medium
		for(var/j in active_character.job_preferences)
			if(active_character.job_preferences[j] == JP_HIGH)
				active_character.job_preferences[j] = JP_MEDIUM
				//technically break here

	active_character.job_preferences[job.title] = level
	return TRUE




/datum/preferences/proc/UpdateJobPreference(mob/user, role, desiredLvl)
	if(!SSjob || SSjob.occupations.len <= 0)
		return
	var/datum/job/job = SSjob.GetJob(role)

	if(!job)
		user << browse(null, "window=mob_occupation")
		ShowChoices(user)
		return

	if (!isnum_safe(desiredLvl))
		to_chat(user, "<span class='danger'>UpdateJobPreference - desired level was not a number. Please notify coders!</span>")
		ShowChoices(user)
		return

	var/jpval = null
	switch(desiredLvl)
		if(3)
			jpval = JP_LOW
		if(2)
			jpval = JP_MEDIUM
		if(1)
			jpval = JP_HIGH

	if(role == SSjob.overflow_role)
		if(active_character.job_preferences[job.title] == JP_LOW)
			jpval = null
		else
			jpval = JP_LOW

	SetJobPreferenceLevel(job, jpval)
	SetChoices(user)

	return 1


/datum/preferences/proc/ResetJobs()
	active_character.job_preferences = list()

/datum/preferences/proc/SetQuirks(mob/user)
	if(!SSquirks)
		to_chat(user, "<span class='danger'>The quirk subsystem is still initializing! Try again in a minute.</span>")
		return

	var/list/dat = list()
	if(!SSquirks.quirks.len)
		dat += "The quirk subsystem hasn't finished initializing, please hold..."
		dat += "<center><a href='?_src_=prefs;preference=trait;task=close'>Done</a></center><br>"
	else
		dat += "<center><b>Choose quirk setup</b></center><br>"
		dat += "<div align='center'>Left-click to add or remove quirks. You need negative quirks to have positive ones.<br>\
		Quirks are applied at roundstart and cannot normally be removed.</div>"
		dat += "<center><a href='?_src_=prefs;preference=trait;task=close'>Done</a></center>"
		dat += "<hr>"
		dat += "<center><b>Current quirks:</b> [length(active_character.all_quirks) ? active_character.all_quirks.Join(", ") : "None"]</center>"
		dat += "<center>[GetPositiveQuirkCount()] / [MAX_QUIRKS] max positive quirks<br>\
		<b>Quirk balance remaining:</b> [GetQuirkBalance()]</center><br>"
		for(var/V in SSquirks.quirks)
			var/datum/quirk/T = SSquirks.quirks[V]
			var/quirk_name = initial(T.name)
			var/has_quirk
			var/quirk_cost = initial(T.value) * -1
			var/lock_reason = "This trait is unavailable."
			var/quirk_conflict = FALSE
			for(var/_V in active_character.all_quirks)
				if(_V == quirk_name)
					has_quirk = TRUE
			if(initial(T.mood_quirk) && CONFIG_GET(flag/disable_human_mood))
				lock_reason = "Mood is disabled."
				quirk_conflict = TRUE
			if(has_quirk)
				if(quirk_conflict)
					active_character.all_quirks -= quirk_name
					has_quirk = FALSE
				else
					quirk_cost *= -1 //invert it back, since we'd be regaining this amount
			if(quirk_cost > 0)
				quirk_cost = "+[quirk_cost]"
			var/font_color = "#AAAAFF"
			if(initial(T.value) != 0)
				font_color = initial(T.value) > 0 ? "#AAFFAA" : "#FFAAAA"
			if(quirk_conflict)
				dat += "<font color='[font_color]'>[quirk_name]</font> - [initial(T.desc)] \
				<font color='red'><b>LOCKED: [lock_reason]</b></font><br>"
			else
				if(has_quirk)
					dat += "<a href='?_src_=prefs;preference=trait;task=update;trait=[quirk_name]'>[has_quirk ? "Remove" : "Take"] ([quirk_cost] pts.)</a> \
					<b><font color='[font_color]'>[quirk_name]</font></b> - [initial(T.desc)]<br>"
				else
					dat += "<a href='?_src_=prefs;preference=trait;task=update;trait=[quirk_name]'>[has_quirk ? "Remove" : "Take"] ([quirk_cost] pts.)</a> \
					<font color='[font_color]'>[quirk_name]</font> - [initial(T.desc)]<br>"
		dat += "<br><center><a href='?_src_=prefs;preference=trait;task=reset'>Reset Quirks</a></center>"

	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Quirk Preferences</div>", 900, 600) //no reason not to reuse the occupation window, as it's cleaner that way
	popup.set_window_options("can_close=0")
	popup.set_content(dat.Join())
	popup.open(FALSE)

/datum/preferences/proc/GetQuirkBalance()
	var/bal = 0
	for(var/V in active_character.all_quirks)
		var/datum/quirk/T = SSquirks.quirks[V]
		bal -= initial(T.value)
	return bal

/datum/preferences/proc/GetPositiveQuirkCount()
	. = 0
	for(var/q in active_character.all_quirks)
		if(SSquirks.quirk_points[q] > 0)
			.++

/datum/preferences/Topic(href, href_list, hsrc)			//yeah, gotta do this I guess..
	. = ..()
	if(href_list["close"])
		var/client/C = usr.client
		if(C)
			C.clear_character_previews()

/datum/preferences/proc/process_link(mob/user, list/href_list)
	if(href_list["bancheck"])
		var/list/ban_details = is_banned_from_with_details(user.ckey, user.client.address, user.client.computer_id, href_list["bancheck"])
		var/admin = FALSE
		if(GLOB.admin_datums[user.ckey] || GLOB.deadmins[user.ckey])
			admin = TRUE
		for(var/i in ban_details)
			if(admin && !text2num(i["applies_to_admins"]))
				continue
			ban_details = i
			break //we only want to get the most recent ban's details
		if(ban_details && ban_details.len)
			var/expires = "This is a permanent ban."
			if(ban_details["expiration_time"])
				expires = " The ban is for [DisplayTimeText(text2num(ban_details["duration"]) MINUTES)] and expires on [ban_details["expiration_time"]] (server time)."
			to_chat(user, "<span class='danger'>You, or another user of this computer or connection ([ban_details["key"]]) is banned from playing [href_list["bancheck"]].<br>The ban reason is: [ban_details["reason"]]<br>This ban (BanID #[ban_details["id"]]) was applied by [ban_details["admin_key"]] on [ban_details["bantime"]] during round ID [ban_details["round_id"]].<br>[expires]</span>")
			return
	if(href_list["preference"] == "job")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=mob_occupation")
				ShowChoices(user)
			if("reset")
				ResetJobs()
				SetChoices(user)
			if("random")
				switch(active_character.joblessrole)
					if(RETURNTOLOBBY)
						if(is_banned_from(user.ckey, SSjob.overflow_role))
							active_character.joblessrole = BERANDOMJOB
						else
							active_character.joblessrole = BEOVERFLOW
					if(BEOVERFLOW)
						active_character.joblessrole = BERANDOMJOB
					if(BERANDOMJOB)
						active_character.joblessrole = RETURNTOLOBBY
				SetChoices(user)
			if("setJobLevel")
				UpdateJobPreference(user, href_list["text"], text2num(href_list["level"]))
			else
				SetChoices(user)
		return 1

	else if(href_list["preference"] == "trait")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=mob_occupation")
				ShowChoices(user)
			if("update")
				var/quirk = href_list["trait"]
				if(!SSquirks.quirks[quirk])
					return
				for(var/V in SSquirks.quirk_blacklist) //V is a list
					var/list/L = V
					for(var/Q in active_character.all_quirks)
						if((quirk in L) && (Q in L) && !(Q == quirk)) //two quirks have lined up in the list of the list of quirks that conflict with each other, so return (see quirks.dm for more details)
							to_chat(user, "<span class='danger'>[quirk] is incompatible with [Q].</span>")
							return
				var/value = SSquirks.quirk_points[quirk]
				var/balance = GetQuirkBalance()
				if(quirk in active_character.all_quirks)
					if(balance + value < 0)
						to_chat(user, "<span class='warning'>Refunding this would cause you to go below your balance!</span>")
						return
					active_character.all_quirks -= quirk
				else
					var/is_positive_quirk = SSquirks.quirk_points[quirk] > 0
					if(is_positive_quirk && GetPositiveQuirkCount() >= MAX_QUIRKS)
						to_chat(user, "<span class='warning'>You can't have more than [MAX_QUIRKS] positive quirks!</span>")
						return
					if(balance - value < 0)
						to_chat(user, "<span class='warning'>You don't have enough balance to gain this quirk!</span>")
						return
					active_character.all_quirks += quirk
				SetQuirks(user)
			if("reset")
				active_character.all_quirks = list()
				SetQuirks(user)
			else
				SetQuirks(user)
		return TRUE

	if(href_list["preference"] == "gear")
		if(href_list["purchase_gear"])
			var/datum/gear/TG = GLOB.gear_datums[href_list["purchase_gear"]]
			if(TG.sort_category == "Donator")
				if(CONFIG_GET(flag/donator_items) && alert(parent, "This item is only accessible to our patrons. Would you like to subscribe?", "Patron Locked", "Yes", "No") == "Yes")
					parent.donate()
			else if(TG.cost <= user.client.get_metabalance())
				purchased_gear += TG.id
				TG.purchase(user.client)
				user.client.inc_metabalance((TG.cost * -1), TRUE, "Purchased [TG.display_name].")
				save_preferences()
			else
				to_chat(user, "<span class='warning'>You don't have enough [CONFIG_GET(string/metacurrency_name)]s to purchase \the [TG.display_name]!</span>")
		if(href_list["toggle_gear"])
			var/datum/gear/TG = GLOB.gear_datums[href_list["toggle_gear"]]
			if(TG.id in active_character.equipped_gear)
				active_character.equipped_gear -= TG.id
			else
				var/list/type_blacklist = list()
				var/list/slot_blacklist = list()
				for(var/gear_id in active_character.equipped_gear)
					var/datum/gear/G = GLOB.gear_datums[gear_id]
					if(istype(G))
						type_blacklist += G.subtype_path
						if((G.slot == TG.slot))
							to_chat(user, "<span class='warning'>Can't equip [TG.display_name]. You already have an item equipped in that slot.</span>")
							return
						else
							continue
				if((TG.id in purchased_gear))
					if(!(TG.subtype_path in type_blacklist) || !(TG.slot in slot_blacklist))
						active_character.equipped_gear += TG.id
					else if(TG.subtype_path == /datum/gear/equipment)
						type_blacklist -= /datum/gear/equipment
						if(!(TG.subtype_path in type_blacklist))
							active_character.equipped_gear += TG.id
						else
							to_chat(user, "<span class='warning'>Can't equip [TG.display_name]. You can only chose two pieces of combat equipment.</span>")
					else
						to_chat(user, "<span class='warning'>Can't equip [TG.display_name]. It conflicts with an already-equipped item.</span>")
				else
					log_href_exploit(user)
			active_character.save(user.client)

		else if(href_list["select_category"])
			gear_tab = href_list["select_category"]
		else if(href_list["clear_loadout"])
			active_character.equipped_gear.Cut()
			active_character.save(user.client)

		ShowChoices(user)
		return

	switch(href_list["task"])
		if("random")
			switch(href_list["preference"])
				if("name")
					active_character.real_name = active_character.pref_species.random_name(active_character.gender, 1)
				if("age")
					active_character.age = rand(AGE_MIN, AGE_MAX)
				if("hair_color")
					active_character.hair_color = random_short_color()
				if("hair_style")
					active_character.hair_style = random_hair_style(active_character.gender)
				if("facial")
					active_character.facial_hair_color = random_short_color()
				if("facial_hair_style")
					active_character.facial_hair_style = random_facial_hair_style(active_character.gender)
				if("underwear")
					active_character.underwear = random_underwear(active_character.gender)
				if("underwear_color")
					active_character.underwear_color = random_short_color()
				if("undershirt")
					active_character.undershirt = random_undershirt(active_character.gender)
				if("socks")
					active_character.socks = random_socks()
				if(BODY_ZONE_PRECISE_EYES)
					active_character.eye_color = random_eye_color()
				if("s_tone")
					active_character.skin_tone = random_skin_tone()
				if("bag")
					active_character.backbag = pick(GLOB.backbaglist)
				if("all")
					active_character.randomise()

		if("input")

			if(href_list["preference"] in GLOB.preferences_custom_names)
				ask_for_custom_name(user,href_list["preference"])

			if(href_list["preference"] in active_character.pref_species.forced_features)
				alert("You cannot change that bodypart for your selected species!")
				active_character.features[href_list["preference"]] = active_character.pref_species.forced_features[href_list["preference"]]
				return

			switch(href_list["preference"])
				if("ghostform")
					if(unlock_content)
						var/new_form = input(user, "Thanks for supporting BYOND - Choose your ghostly form:","Thanks for supporting BYOND",null) as null|anything in GLOB.ghost_forms
						if(new_form)
							ghost_form = new_form
				if("ghostorbit")
					if(unlock_content)
						var/new_orbit = input(user, "Thanks for supporting BYOND - Choose your ghostly orbit:","Thanks for supporting BYOND", null) as null|anything in GLOB.ghost_orbits
						if(new_orbit)
							ghost_orbit = new_orbit

				if("ghostaccs")
					var/new_ghost_accs = alert("Do you want your ghost to show full accessories where possible, hide accessories but still use the directional sprites where possible, or also ignore the directions and stick to the default sprites?",,GHOST_ACCS_FULL_NAME, GHOST_ACCS_DIR_NAME, GHOST_ACCS_NONE_NAME)
					switch(new_ghost_accs)
						if(GHOST_ACCS_FULL_NAME)
							ghost_accs = GHOST_ACCS_FULL
						if(GHOST_ACCS_DIR_NAME)
							ghost_accs = GHOST_ACCS_DIR
						if(GHOST_ACCS_NONE_NAME)
							ghost_accs = GHOST_ACCS_NONE

				if("ghostothers")
					var/new_ghost_others = alert("Do you want the ghosts of others to show up as their own setting, as their default sprites or always as the default white ghost?",,GHOST_OTHERS_THEIR_SETTING_NAME, GHOST_OTHERS_DEFAULT_SPRITE_NAME, GHOST_OTHERS_SIMPLE_NAME)
					switch(new_ghost_others)
						if(GHOST_OTHERS_THEIR_SETTING_NAME)
							ghost_others = GHOST_OTHERS_THEIR_SETTING
						if(GHOST_OTHERS_DEFAULT_SPRITE_NAME)
							ghost_others = GHOST_OTHERS_DEFAULT_SPRITE
						if(GHOST_OTHERS_SIMPLE_NAME)
							ghost_others = GHOST_OTHERS_SIMPLE

				if("name")
					var/new_name =  reject_bad_name( input(user, "Choose your character's name:", "Character Preference")  as text|null , active_character.pref_species.allow_numbers_in_name)
					if(new_name)
						active_character.real_name = new_name
					else
						to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")

				if("age")
					var/new_age = input(user, "Choose your character's age:\n([AGE_MIN]-[AGE_MAX])", "Character Preference") as num|null
					if(new_age)
						active_character.age = max(min( round(text2num(new_age)), AGE_MAX),AGE_MIN)

				if("hair_color")
					var/new_hair = input(user, "Choose your character's hair colour:", "Character Preference","#" + active_character.hair_color) as color|null
					if(new_hair)
						active_character.hair_color = sanitize_hexcolor(new_hair)
				if("hair_style")
					var/new_hair_style
					if(active_character.gender == MALE)
						new_hair_style = input(user, "Choose your character's hair style:", "Character Preference")  as null|anything in GLOB.hair_styles_male_list
					else
						new_hair_style = input(user, "Choose your character's hair style:", "Character Preference")  as null|anything in GLOB.hair_styles_female_list
					if(new_hair_style)
						active_character.hair_style = new_hair_style

				if("gradient_style")
					var/new_gradient_style
					new_gradient_style = input(user, "Choose your character's hair gradient style:", "Character Preference")  as null|anything in GLOB.hair_gradients_list
					if(new_gradient_style)
						active_character.gradient_style = new_gradient_style

				if("gradient_color")
					var/new_hair_gradient = input(user, "Choose your character's hair gradient colour:", "Character Preference", "#" + active_character.gradient_color) as color|null
					if(new_hair_gradient)
						active_character.gradient_color = sanitize_hexcolor(new_hair_gradient)

				if("next_hair_style")
					if(active_character.gender == MALE)
						active_character.hair_style = next_list_item(active_character.hair_style, GLOB.hair_styles_male_list)
					else
						active_character.hair_style = next_list_item(active_character.hair_style, GLOB.hair_styles_female_list)

				if("previous_hair_style")
					if(active_character.gender == MALE)
						active_character.hair_style = previous_list_item(active_character.hair_style, GLOB.hair_styles_male_list)
					else
						active_character.hair_style = previous_list_item(active_character.hair_style, GLOB.hair_styles_female_list)

				if("next_gradient_style")
					active_character.gradient_style = next_list_item(active_character.gradient_style, GLOB.hair_gradients_list)

				if("previous_gradient_style")
					active_character.gradient_style = previous_list_item(active_character.gradient_style, GLOB.hair_gradients_list)

				if("facial")
					var/new_facial = input(user, "Choose your character's facial-hair colour:", "Character Preference","#" + active_character.facial_hair_color) as color|null
					if(new_facial)
						active_character.facial_hair_color = sanitize_hexcolor(new_facial)

				if("facial_hair_style")
					var/new_facial_hair_style
					if(active_character.gender == MALE)
						new_facial_hair_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in GLOB.facial_hair_styles_male_list
					else
						new_facial_hair_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in GLOB.facial_hair_styles_female_list
					if(new_facial_hair_style)
						active_character.facial_hair_style = new_facial_hair_style

				if("next_facehair_style")
					if (active_character.gender == MALE)
						active_character.facial_hair_style = next_list_item(active_character.facial_hair_style, GLOB.facial_hair_styles_male_list)
					else
						active_character.facial_hair_style = next_list_item(active_character.facial_hair_style, GLOB.facial_hair_styles_female_list)

				if("previous_facehair_style")
					if (active_character.gender == MALE)
						active_character.facial_hair_style = previous_list_item(active_character.facial_hair_style, GLOB.facial_hair_styles_male_list)
					else
						active_character.facial_hair_style = previous_list_item(active_character.facial_hair_style, GLOB.facial_hair_styles_female_list)

				if("underwear")
					var/new_underwear
					if(active_character.gender == MALE)
						new_underwear = input(user, "Choose your character's underwear:", "Character Preference")  as null|anything in GLOB.underwear_m
					else
						new_underwear = input(user, "Choose your character's underwear:", "Character Preference")  as null|anything in GLOB.underwear_f
					if(new_underwear)
						active_character.underwear = new_underwear

				if("underwear_color")
					var/new_underwear_color = input(user, "Choose your character's underwear color:", "Character Preference","#"+active_character.underwear_color) as color|null
					if(new_underwear_color)
						active_character.underwear_color = sanitize_hexcolor(new_underwear_color)

				if("undershirt")
					var/new_undershirt
					if(active_character.gender == MALE)
						new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference") as null|anything in GLOB.undershirt_m
					else
						new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference") as null|anything in GLOB.undershirt_f
					if(new_undershirt)
						active_character.undershirt = new_undershirt

				if("socks")
					var/new_socks
					new_socks = input(user, "Choose your character's socks:", "Character Preference") as null|anything in GLOB.socks_list
					if(new_socks)
						active_character.socks = new_socks

				if("eyes")
					var/new_eyes = input(user, "Choose your character's eye colour:", "Character Preference","#"+active_character.eye_color) as color|null
					if(new_eyes)
						active_character.eye_color = sanitize_hexcolor(new_eyes)

				if("body_size")
					var/new_size = input(user, "Choose your character's height:", "Character Preference") as null|anything in GLOB.body_sizes
					if(new_size)
						active_character.features["body_size"] = new_size

				if("species")

					var/result = input(user, "Select a species", "Species Selection") as null|anything in GLOB.roundstart_races

					if(result)
						var/new_species_type = GLOB.species_list[result]
						var/datum/species/new_species = new new_species_type()

						if (!CONFIG_GET(keyed_list/paywall_races)[new_species.id] || IS_PATRON(parent.ckey) || parent.holder)
							active_character.pref_species = new_species
							//Now that we changed our species, we must verify that the mutant colour is still allowed.
							var/temp_hsv = RGBtoHSV(active_character.features["mcolor"])
							if(active_character.features["mcolor"] == "#000" || (!(MUTCOLORS_PARTSONLY in active_character.pref_species.species_traits) && ReadHSV(temp_hsv)[3] < ReadHSV("#7F7F7F")[3]))
								active_character.features["mcolor"] = active_character.pref_species.default_color
							//Set our forced bodyparts
							for(var/forced_part in active_character.pref_species.forced_features)
								//Get the forced type
								var/forced_type = active_character.pref_species.forced_features[forced_part]
								//Apply the forced bodypart.
								active_character.features[forced_part] = forced_type
						else
							if(alert(parent, "This species is only accessible to our patrons. Would you like to subscribe?", "Patron Locked", "Yes", "No") == "Yes")
								parent.donate()


				if("mutant_color")
					var/new_mutantcolor = input(user, "Choose your character's alien/mutant color:", "Character Preference","#"+active_character.features["mcolor"]) as color|null
					if(new_mutantcolor)
						var/temp_hsv = RGBtoHSV(new_mutantcolor)
						if(new_mutantcolor == "#000000")
							active_character.features["mcolor"] = active_character.pref_species.default_color
						else if((MUTCOLORS_PARTSONLY in active_character.pref_species.species_traits) || ReadHSV(temp_hsv)[3] >= ReadHSV("#7F7F7F")[3]) // mutantcolors must be bright, but only if they affect the skin
							active_character.features["mcolor"] = sanitize_hexcolor(new_mutantcolor)
						else
							to_chat(user, "<span class='danger'>Invalid color. Your color is not bright enough.</span>")

				if("color_ethereal")
					var/new_etherealcolor = input(user, "Choose your ethereal color", "Character Preference") as null|anything in GLOB.color_list_ethereal
					if(new_etherealcolor)
						active_character.features["ethcolor"] = GLOB.color_list_ethereal[new_etherealcolor]

				if("helmet_style")
					var/style = input(user, "Choose your helmet style", "Character Preference") as null|anything in list(HELMET_DEFAULT, HELMET_MK2, HELMET_PROTECTIVE)
					if(style)
						active_character.helmet_style = style

				if("tail_lizard")
					var/new_tail
					new_tail = input(user, "Choose your character's tail:", "Character Preference") as null|anything in GLOB.tails_list_lizard
					if(new_tail)
						active_character.features["tail_lizard"] = new_tail

				if("tail_human")
					var/new_tail
					new_tail = input(user, "Choose your character's tail:", "Character Preference") as null|anything in GLOB.tails_list_human
					if(new_tail)
						active_character.features["tail_human"] = new_tail

				if("snout")
					var/new_snout
					new_snout = input(user, "Choose your character's snout:", "Character Preference") as null|anything in GLOB.snouts_list
					if(new_snout)
						active_character.features["snout"] = new_snout

				if("horns")
					var/new_horns
					new_horns = input(user, "Choose your character's horns:", "Character Preference") as null|anything in GLOB.horns_list
					if(new_horns)
						active_character.features["horns"] = new_horns

				if("ears")
					var/new_ears
					new_ears = input(user, "Choose your character's ears:", "Character Preference") as null|anything in GLOB.ears_list
					if(new_ears)
						active_character.features["ears"] = new_ears

				if("wings")
					var/new_wings
					new_wings = input(user, "Choose your character's wings:", "Character Preference") as null|anything in GLOB.r_wings_list
					if(new_wings)
						active_character.features["wings"] = new_wings

				if("frills")
					var/new_frills
					new_frills = input(user, "Choose your character's frills:", "Character Preference") as null|anything in GLOB.frills_list
					if(new_frills)
						active_character.features["frills"] = new_frills

				if("spines")
					var/new_spines
					new_spines = input(user, "Choose your character's spines:", "Character Preference") as null|anything in GLOB.spines_list
					if(new_spines)
						active_character.features["spines"] = new_spines

				if("body_markings")
					var/new_body_markings
					new_body_markings = input(user, "Choose your character's body markings:", "Character Preference") as null|anything in GLOB.body_markings_list
					if(new_body_markings)
						active_character.features["body_markings"] = new_body_markings

				if("legs")
					var/new_legs
					new_legs = input(user, "Choose your character's legs:", "Character Preference") as null|anything in GLOB.legs_list
					if(new_legs)
						active_character.features["legs"] = new_legs

				if("moth_wings")
					var/new_moth_wings
					new_moth_wings = input(user, "Choose your character's wings:", "Character Preference") as null|anything in GLOB.moth_wings_roundstart_list
					if(new_moth_wings)
						active_character.features["moth_wings"] = new_moth_wings

				if("moth_antennae")
					var/new_moth_antennae
					new_moth_antennae = input(user, "Choose your character's antennae:", "Character Preference") as null|anything in GLOB.moth_antennae_roundstart_list
					if(new_moth_antennae)
						active_character.features["moth_antennae"] = new_moth_antennae

				if("moth_markings")
					var/new_moth_markings
					new_moth_markings = input(user, "Choose your character's markings:", "Character Preference") as null|anything in GLOB.moth_markings_roundstart_list
					if(new_moth_markings)
						active_character.features["moth_markings"] = new_moth_markings

				if("ipc_screen")
					var/new_ipc_screen

					new_ipc_screen = input(user, "Choose your character's screen:", "Character Preference") as null|anything in GLOB.ipc_screens_list

					if(new_ipc_screen)
						active_character.features["ipc_screen"] = new_ipc_screen

				if("ipc_antenna")
					var/new_ipc_antenna

					new_ipc_antenna = input(user, "Choose your character's antenna:", "Character Preference") as null|anything in GLOB.ipc_antennas_list

					if(new_ipc_antenna)
						active_character.features["ipc_antenna"] = new_ipc_antenna

				if("ipc_chassis")
					var/new_ipc_chassis

					new_ipc_chassis = input(user, "Choose your character's chassis:", "Character Preference") as null|anything in GLOB.ipc_chassis_list

					if(new_ipc_chassis)
						active_character.features["ipc_chassis"] = new_ipc_chassis

				if("insect_type")
					var/new_insect_type

					new_insect_type = input(user, "Choose your character's species:", "Character Preference") as null|anything in GLOB.insect_type_list

					if(new_insect_type)
						active_character.features["insect_type"] = new_insect_type

				if("apid_antenna")
					var/new_apid_antenna

					new_apid_antenna = input(user, "Choose your apid antennae:", "Character Preference") as null|anything in GLOB.apid_antenna_list

					if(new_apid_antenna)
						active_character.features["apid_antenna"] = new_apid_antenna

				if("apid_stripes")
					var/new_apid_stripes

					new_apid_stripes = input(user, "Choose your apid stripes:", "Character Preference") as null|anything in GLOB.apid_stripes_list

					if(new_apid_stripes)
						active_character.features["apid_stripes"] = new_apid_stripes

				if("apid_headstripes")
					var/new_apid_headstripes

					new_apid_headstripes = input(user, "Choose your apid headstripes:", "Character Preference") as null|anything in GLOB.apid_headstripes_list

					if(new_apid_headstripes)
						active_character.features["apid_headstripes"] = new_apid_headstripes

				if("s_tone")
					var/new_s_tone = input(user, "Choose your character's skin-tone:", "Character Preference")  as null|anything in GLOB.skin_tones
					if(new_s_tone)
						active_character.skin_tone = new_s_tone

				if("ooccolor")
					var/new_ooccolor = input(user, "Choose your OOC colour:", "Game Preference",ooccolor) as color|null
					if(new_ooccolor)
						ooccolor = new_ooccolor

				if("asaycolor")
					var/new_asaycolor = input(user, "Choose your ASAY color:", "Game Preference",asaycolor) as color|null
					if(new_asaycolor)
						asaycolor = new_asaycolor

				if("bag")
					var/new_backbag = input(user, "Choose your character's style of bag:", "Character Preference")  as null|anything in GLOB.backbaglist
					if(new_backbag)
						active_character.backbag = new_backbag

				if("suit")
					if(active_character.jumpsuit_style == PREF_SUIT)
						active_character.jumpsuit_style = PREF_SKIRT
					else
						active_character.jumpsuit_style = PREF_SUIT

				if("uplink_loc")
					var/new_loc = input(user, "Choose your character's traitor uplink spawn location:", "Character Preference") as null|anything in GLOB.uplink_spawn_loc_list
					if(new_loc)
						// This is done to prevent affecting saves
						active_character.uplink_spawn_loc = new_loc == UPLINK_IMPLANT_WITH_PRICE ? UPLINK_IMPLANT : new_loc

				if("ai_core_icon")
					var/ai_core_icon = input(user, "Choose your preferred AI core display screen:", "AI Core Display Screen Selection") as null|anything in GLOB.ai_core_display_screens - "Portrait"
					if(ai_core_icon)
						active_character.preferred_ai_core_display = ai_core_icon

				if("sec_dept")
					var/department = input(user, "Choose your preferred security department:", "Security Departments") as null|anything in GLOB.security_depts_prefs
					if(department)
						active_character.preferred_security_department = department

				if ("preferred_map")
					var/maplist = list()
					var/default = "Default"
					if (config.defaultmap)
						default += " ([config.defaultmap.map_name])"
					for (var/M in config.maplist)
						var/datum/map_config/VM = config.maplist[M]
						if(!VM.votable || SSmapping.config.map_name == VM.map_name) //current map will be excluded from the vote
							continue
						var/friendlyname = "[VM.map_name] "
						if (VM.voteweight <= 0)
							friendlyname += " (disabled)"
						maplist[friendlyname] = VM.map_name
					maplist[default] = null
					var/pickedmap = input(user, "Choose your preferred map. This will be used to help weight random map selection.", "Character Preference")  as null|anything in sortList(maplist)
					if (pickedmap)
						preferred_map = maplist[pickedmap]

				if ("clientfps")
					var/desiredfps = input(user, "Choose your desired fps. (0 = synced with server tick rate (currently:[world.fps]))", "Character Preference", clientfps)  as null|num
					if (!isnull(desiredfps))
						clientfps = desiredfps
						parent.fps = desiredfps
				if("ui")
					var/pickedui = input(user, "Choose your UI style.", "Character Preference", UI_style)  as null|anything in GLOB.available_ui_styles
					if(pickedui)
						UI_style = pickedui
						if (parent && parent.mob && parent.mob.hud_used)
							parent.mob.hud_used.update_ui_style(ui_style2icon(UI_style))
				if("pda_theme")
					var/pickedPDAStyle = input(user, "Choose your default PDA theme.", "Character Preference", pda_theme)  as null|anything in GLOB.ntos_device_themes_default
					if(pickedPDAStyle)
						pda_theme = GLOB.ntos_device_themes_default[pickedPDAStyle]
				if("pda_color")
					var/pickedPDAColor = input(user, "Choose your default Thinktronic Classic theme background color.", "Character Preference", pda_color) as color|null
					if(pickedPDAColor)
						pda_color = pickedPDAColor
				if ("see_balloon_alerts")
					var/pickedstyle = input(user, "Choose how you want balloon alerts displayed", "Balloon alert preference", BALLOON_ALERT_ALWAYS) as null|anything in list(BALLOON_ALERT_ALWAYS, BALLOON_ALERT_WITH_CHAT, BALLOON_ALERT_NEVER)
					if (!isnull(pickedstyle))
						see_balloon_alerts = pickedstyle

		else
			switch(href_list["preference"])
				if("publicity")
					if(unlock_content)
						toggles ^= PREFTOGGLE_MEMBER_PUBLIC
				if("gender")
					if(active_character.gender == MALE)
						active_character.gender = FEMALE
					else
						active_character.gender = MALE
					active_character.underwear = random_underwear(active_character.gender)
					active_character.undershirt = random_undershirt(active_character.gender)
					active_character.socks = random_socks()
					active_character.facial_hair_style = random_facial_hair_style(active_character.gender)
					active_character.hair_style = random_hair_style(active_character.gender)

				if("hotkeys")
					toggles2 ^= PREFTOGGLE_2_HOTKEYS
					if(toggles2 & PREFTOGGLE_2_HOTKEYS)
						winset(user, null, "input.focus=true input.background-color=[COLOR_INPUT_ENABLED] mainwindow.macro=default")
					else
						winset(user, null, "input.focus=true input.background-color=[COLOR_INPUT_ENABLED] mainwindow.macro=old_default")
				if("action_buttons")
					toggles2 ^= PREFTOGGLE_2_LOCKED_BUTTONS
				if("tgui_fancy")
					toggles2 ^= PREFTOGGLE_2_FANCY_TGUI
				if("outline_enabled")
					toggles ^= PREFTOGGLE_OUTLINE_ENABLED
				if("outline_color")
					var/pickedOutlineColor = input(user, "Choose your outline color.", "General Preference", outline_color) as color|null
					if(pickedOutlineColor)
						outline_color = pickedOutlineColor
				if("tgui_lock")
					toggles2 ^= PREFTOGGLE_2_LOCKED_TGUI
				if("winflash")
					toggles2 ^= PREFTOGGLE_2_WINDOW_FLASHING
				if("crewobj")
					toggles2 ^= PREFTOGGLE_2_WINDOW_FLASHING

				//here lies the badmins
				if("hear_adminhelps")
					user.client.toggleadminhelpsound()
				if("hear_prayers")
					user.client.toggle_prayer_sound()
				if("announce_login")
					user.client.toggleannouncelogin()
				if("combohud_lighting")
					toggles ^= PREFTOGGLE_COMBOHUD_LIGHTING
				if("toggle_dead_chat")
					user.client.deadchat()
				if("toggle_radio_chatter")
					user.client.toggle_hear_radio()
				if("toggle_prayers")
					user.client.toggleprayers()
				if("toggle_deadmin_always")
					toggles ^= PREFTOGGLE_DEADMIN_ALWAYS
				if("toggle_deadmin_antag")
					toggles ^= PREFTOGGLE_DEADMIN_ANTAGONIST
				if("toggle_deadmin_head")
					toggles ^= PREFTOGGLE_DEADMIN_POSITION_HEAD
				if("toggle_deadmin_security")
					toggles ^= PREFTOGGLE_DEADMIN_POSITION_SECURITY
				if("toggle_deadmin_silicon")
					toggles ^= PREFTOGGLE_DEADMIN_POSITION_SILICON


				if("be_special")
					var/be_special_type = href_list["be_special_type"]
					if(be_special_type in be_special)
						be_special -= be_special_type
					else
						be_special += be_special_type

				if("name")
					active_character.be_random_name = !active_character.be_random_name

				if("all")
					active_character.be_random_body = !active_character.be_random_body

				if("hear_midis")
					toggles ^= PREFTOGGLE_SOUND_MIDI

				if("lobby_music")
					toggles ^= PREFTOGGLE_SOUND_LOBBY
					if((toggles & PREFTOGGLE_SOUND_LOBBY) && user.client && isnewplayer(user))
						user.client.playtitlemusic()
					else
						user.stop_sound_channel(CHANNEL_LOBBYMUSIC)

				if("ghost_ears")
					chat_toggles ^= CHAT_GHOSTEARS

				if("ghost_sight")
					chat_toggles ^= CHAT_GHOSTSIGHT

				if("ghost_whispers")
					chat_toggles ^= CHAT_GHOSTWHISPER

				if("ghost_radio")
					chat_toggles ^= CHAT_GHOSTRADIO

				if("ghost_pda")
					chat_toggles ^= CHAT_GHOSTPDA

				if("ghost_laws")
					chat_toggles ^= CHAT_GHOSTLAWS

				if("ghost_follow")
					chat_toggles ^= CHAT_GHOSTFOLLOWMINDLESS

				if("income_pings")
					chat_toggles ^= CHAT_BANKCARD

				if("pull_requests")
					chat_toggles ^= CHAT_PULLR

				if("allow_midround_antag")
					toggles ^= PREFTOGGLE_MIDROUND_ANTAG

				if("parallaxup")
					parallax = WRAP(parallax + 1, PARALLAX_INSANE, PARALLAX_DISABLE + 1)
					if (parent && parent.mob && parent.mob.hud_used)
						parent.mob.hud_used.update_parallax_pref(parent.mob)

				if("parallaxdown")
					parallax = WRAP(parallax - 1, PARALLAX_INSANE, PARALLAX_DISABLE + 1)
					if (parent && parent.mob && parent.mob.hud_used)
						parent.mob.hud_used.update_parallax_pref(parent.mob)

				if("ambientocclusion")
					toggles2 ^= PREFTOGGLE_2_AMBIENT_OCCLUSION
					if(parent && parent.screen && parent.screen.len)
						var/atom/movable/screen/plane_master/game_world/PM = locate(/atom/movable/screen/plane_master/game_world) in parent.screen
						PM.backdrop(parent.mob)

				if("auto_fit_viewport")
					toggles2 ^= PREFTOGGLE_2_AUTO_FIT_VIEWPORT
					if((toggles2 & PREFTOGGLE_2_AUTO_FIT_VIEWPORT) && parent)
						parent.fit_viewport()

				if("pixel_size")
					switch(pixel_size)
						if(PIXEL_SCALING_AUTO)
							pixel_size = PIXEL_SCALING_1X
						if(PIXEL_SCALING_1X)
							pixel_size = PIXEL_SCALING_1_2X
						if(PIXEL_SCALING_1_2X)
							pixel_size = PIXEL_SCALING_2X
						if(PIXEL_SCALING_2X)
							pixel_size = PIXEL_SCALING_3X
						if(PIXEL_SCALING_3X)
							pixel_size = PIXEL_SCALING_AUTO
					user.client.view_size.resetToDefault(getScreenSize(user))	//Fix our viewport size so it doesn't reset on change

				if("scaling_method")
					switch(scaling_method)
						if(SCALING_METHOD_NORMAL)
							scaling_method = SCALING_METHOD_DISTORT
						if(SCALING_METHOD_DISTORT)
							scaling_method = SCALING_METHOD_BLUR
						if(SCALING_METHOD_BLUR)
							scaling_method = SCALING_METHOD_NORMAL
					user.client.view_size.setZoomMode()

				if("save")
					save_preferences()
					active_character.save(user.client)

				if("load")
					load_from_database()
					load_characters()

				if("changeslot")
					var/numerical_slot = text2num(href_list["num"])
					var/datum/character_save/CS = character_saves[numerical_slot]
					if(CS && !CS.slot_locked)
						active_character = CS
						default_slot = numerical_slot
						// If its fresh, randomise & save it
						if(!CS.from_db)
							CS.randomise()
							CS.save(user.client)

				if("tab")
					if (href_list["tab"])
						current_tab = text2num(href_list["tab"])

				if("keybindings_menu")
					ShowKeybindings(user)
					return

				if("keybindings_capture")
					var/datum/keybinding/kb = GLOB.keybindings_by_name[href_list["keybinding"]]
					var/old_key = href_list["old_key"]
					CaptureKeybinding(user, kb, old_key)
					return

				if("keybindings_set")
					var/kb_name = href_list["keybinding"]
					if(!kb_name)
						user << browse(null, "window=capturekeypress")
						ShowKeybindings(user)
						return

					var/clear_key = text2num(href_list["clear_key"])
					var/old_key = href_list["old_key"]

					if(clear_key)
						if(old_key != "Unbound") // if it was already set
							key_bindings[old_key] -= kb_name
							key_bindings["Unbound"] += list(kb_name)
						save_preferences()
						user << browse(null, "window=capturekeypress")
						ShowKeybindings(user)
						return

					var/key = href_list["key"]
					var/numpad = text2num(href_list["numpad"])
					// TODO: Handle holding shift or alt down
					var/AltMod = text2num(href_list["alt"]) ? "Alt-" : ""
					var/CtrlMod = text2num(href_list["ctrl"]) ? "Ctrl-" : ""
					var/ShiftMod = text2num(href_list["shift"]) ? "Shift-" : ""
					// var/key_code = text2num(href_list["key_code"])

					var/new_key = uppertext(key)

					// This is a mapping from JS keys to Byond - ref: https://keycode.info/
					var/list/_kbMap = list(
						"INSERT" = "Insert", "HOME" = "Northwest", "PAGEUP" = "Northeast",
						"DEL" = "Delete", "END" = "Southwest",  "PAGEDOWN" = "Southeast",
						"SPACEBAR" = "Space", "ALT" = "Alt", "SHIFT" = "Shift", "CONTROL" = "Ctrl"
					)
					new_key = _kbMap[new_key] ? _kbMap[new_key] : new_key

					if (numpad)
						new_key = "Numpad[new_key]"

					var/full_key = "[AltMod][CtrlMod][ShiftMod][new_key]"
					if(old_key && (old_key in key_bindings))
						key_bindings[old_key] -= kb_name
					key_bindings[full_key] += list(kb_name)
					key_bindings[full_key] = sortList(key_bindings[full_key])

					save_preferences()
					user << browse(null, "window=capturekeypress")
					ShowKeybindings(user)
					return

				if("keybindings_done")
					user << browse(null, "window=keybindings")

				if("keybindings_reset")
					key_bindings = deepCopyList(GLOB.keybinding_list_by_key)
					save_preferences()
					ShowKeybindings(user)
					return

				if("chat_on_map")
					toggles ^= PREFTOGGLE_RUNECHAT_GLOBAL
				if("see_chat_non_mob")
					toggles ^= PREFTOGGLE_RUNECHAT_NONMOBS
				if("see_rc_emotes")
					toggles ^= PREFTOGGLE_RUNECHAT_EMOTES

	ShowChoices(user)
	return 1

/datum/preferences/proc/ask_for_custom_name(mob/user,name_id)
	var/namedata = GLOB.preferences_custom_names[name_id]
	if(!namedata)
		return

	var/raw_name = capped_input(user, "Choose your character's [namedata["qdesc"]]:","Character Preference")
	if(!raw_name)
		if(namedata["allow_null"])
			active_character.custom_names[name_id] = get_default_name(name_id)
		else
			return
	else
		var/sanitized_name = reject_bad_name(raw_name,namedata["allow_numbers"])
		if(!sanitized_name)
			to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z,[namedata["allow_numbers"] ? ",0-9," : ""] -, ' and .</font>")
			return
		else
			active_character.custom_names[name_id] = sanitized_name

/// Handles adding and removing donator items from clients
/datum/preferences/proc/handle_donator_items()
	var/datum/loadout_category/DLC = GLOB.loadout_categories["Donator"] // stands for donator loadout category but the other def for DLC works too xD
	if(!LAZYLEN(GLOB.patrons) || !CONFIG_GET(flag/donator_items)) // donator items are only accesibile by servers with a patreon
		return
	if(IS_PATRON(parent.ckey) || (parent in GLOB.admins))
		for(var/gear_id in DLC.gear)
			var/datum/gear/AG = DLC.gear[gear_id]
			if(AG.id in purchased_gear)
				continue
			purchased_gear += AG.id
			AG.purchase(parent)
		save_preferences()
	else if(length(purchased_gear) || length(active_character.equipped_gear))
		for(var/gear_id in DLC.gear)
			var/datum/gear/RG = DLC.gear[gear_id]
			active_character.equipped_gear -= RG.id
			purchased_gear -= RG.id
		save_preferences()
