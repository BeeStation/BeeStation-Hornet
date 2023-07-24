/client/verb/game_preferences()
	set name = "Game Preferences"
	set category = "Preferences"
	set desc = "Open Game Preferences Window"
	prefs.current_tab = 1
	prefs.ShowChoices(usr)

/client/verb/character_preferences()
	set name = "Character Preferences"
	set category = "Preferences"
	set desc = "Open Character Preferences Window"
	prefs.current_tab = 0
	prefs.ShowChoices(usr)

/client/verb/toggle_ghost_ears()
	set name = "Show/Hide GhostEars"
	set category = "Preferences"
	set desc = "See All Speech"
	prefs.chat_toggles ^= CHAT_GHOSTEARS
	to_chat(usr, "As a ghost, you will now [(prefs.chat_toggles & CHAT_GHOSTEARS) ? "see all speech in the world" : "only see speech from nearby mobs"].")
	prefs.save_preferences()
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Ghost Ears", "[prefs.chat_toggles & CHAT_GHOSTEARS ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_sight()
	set name = "Show/Hide GhostSight"
	set category = "Preferences"
	set desc = "See All Emotes"
	prefs.chat_toggles ^= CHAT_GHOSTSIGHT
	to_chat(usr, "As a ghost, you will now [(prefs.chat_toggles & CHAT_GHOSTSIGHT) ? "see all emotes in the world" : "only see emotes from nearby mobs"].")
	prefs.save_preferences()
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Ghost Sight", "[prefs.chat_toggles & CHAT_GHOSTSIGHT ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_whispers()
	set name = "Show/Hide GhostWhispers"
	set category = "Preferences"
	set desc = "See All Whispers"
	prefs.chat_toggles ^= CHAT_GHOSTWHISPER
	to_chat(usr, "As a ghost, you will now [(prefs.chat_toggles & CHAT_GHOSTWHISPER) ? "see all whispers in the world" : "only see whispers from nearby mobs"].")
	prefs.save_preferences()
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Ghost Whispers", "[prefs.chat_toggles & CHAT_GHOSTWHISPER ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_radio()
	set name = "Show/Hide GhostRadio"
	set category = "Preferences"
	set desc = "See All Radio Chatter"
	prefs.chat_toggles ^= CHAT_GHOSTRADIO
	to_chat(usr, "As a ghost, you will now [(prefs.chat_toggles & CHAT_GHOSTRADIO) ? "see radio chatter" : "not see radio chatter"].")
	prefs.save_preferences()
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Ghost Radio", "[prefs.chat_toggles & CHAT_GHOSTRADIO ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc! //social experiment, increase the generation whenever you copypaste this shamelessly GENERATION 1

/client/verb/toggle_ghost_pda()
	set name = "Show/Hide GhostPDA"
	set category = "Preferences"
	set desc = "See All PDA Messages"
	prefs.chat_toggles ^= CHAT_GHOSTPDA
	to_chat(usr, "As a ghost, you will now [(prefs.chat_toggles & CHAT_GHOSTPDA) ? "see all pda messages in the world" : "only see pda messages from nearby mobs"].")
	prefs.save_preferences()
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Ghost PDA", "[prefs.chat_toggles & CHAT_GHOSTPDA ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_laws()
	set name = "Show/Hide GhostLaws"
	set category = "Preferences"
	set desc = "See All Law Changes"
	prefs.chat_toggles ^= CHAT_GHOSTLAWS
	to_chat(usr, "As a ghost, you will now [(prefs.chat_toggles & CHAT_GHOSTLAWS) ? "be notified of all law changes" : "no longer be notified of law changes"].")
	prefs.save_preferences()
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Ghost Laws", "[prefs.chat_toggles & CHAT_GHOSTLAWS ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_follow()
	set name = "Toggle NPC GhostFollow"
	set category = "Preferences"
	set desc = "Toggle the visibility of the follow button for NPC messages and emotes."
	prefs.chat_toggles ^= CHAT_GHOSTFOLLOWMINDLESS
	to_chat(usr, "As a ghost, you will [(prefs.chat_toggles & CHAT_GHOSTFOLLOWMINDLESS) ? "now" : "no longer"] see the follow button for NPC mobs.")
	prefs.save_preferences()
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle NPC GhostFollow", "[prefs.chat_toggles & CHAT_GHOSTFOLLOWMINDLESS ? "Enabled" : "Disabled"]"))

//please be aware that the following two verbs have inverted stat output, so that "Toggle Deathrattle|1" still means you activated it
/client/verb/toggle_deathrattle()
	set name = "Toggle Deathrattle"
	set category = "Preferences"
	set desc = "Death"
	prefs.toggles ^= PREFTOGGLE_DISABLE_DEATHRATTLE
	prefs.save_preferences()
	to_chat(usr, "You will [(prefs.toggles & PREFTOGGLE_DISABLE_DEATHRATTLE) ? "no longer" : "now"] get messages when a sentient mob dies.")
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Deathrattle", "[!(prefs.toggles & PREFTOGGLE_DISABLE_DEATHRATTLE) ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, maybe you should spend some time reading the comments.

/client/verb/toggle_arrivalrattle()
	set name = "Toggle Arrivalrattle"
	set category = "Preferences"
	set desc = "New Player Arrival"
	prefs.toggles ^= PREFTOGGLE_DISABLE_ARRIVALRATTLE
	to_chat(usr, "You will [(prefs.toggles & PREFTOGGLE_DISABLE_ARRIVALRATTLE) ? "no longer" : "now"] get messages when someone joins the station.")
	prefs.save_preferences()
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Arrivalrattle", "[!(prefs.toggles & PREFTOGGLE_DISABLE_ARRIVALRATTLE) ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, maybe you should rethink where your life went so wrong.

/client/verb/toggletitlemusic()
	set name = "Hear/Silence Lobby Music"
	set category = "Preferences"
	set desc = "Hear Music In Lobby"
	prefs.toggles ^= PREFTOGGLE_SOUND_LOBBY
	prefs.save_preferences()
	if(prefs.toggles & PREFTOGGLE_SOUND_LOBBY)
		to_chat(usr, "You will now hear music in the game lobby.")
		if(isnewplayer(usr))
			playtitlemusic()
	else
		to_chat(usr, "You will no longer hear music in the game lobby.")
		usr.stop_sound_channel(CHANNEL_LOBBYMUSIC)
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Lobby Music", "[prefs.toggles & PREFTOGGLE_SOUND_LOBBY ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/togglemidis()
	set name = "Hear/Silence Midis"
	set category = "Preferences"
	set desc = "Hear Admin Triggered Sounds (Midis)"
	prefs.toggles ^= PREFTOGGLE_SOUND_MIDI
	prefs.save_preferences()
	if(prefs.toggles & PREFTOGGLE_SOUND_MIDI)
		to_chat(usr, "You will now hear any sounds uploaded by admins.")
	else
		to_chat(usr, "You will no longer hear sounds uploaded by admins")
		usr.stop_sound_channel(CHANNEL_ADMIN)
		var/client/C = usr.client
		C?.tgui_panel?.stop_music()
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Hearing Midis", "[prefs.toggles & PREFTOGGLE_SOUND_MIDI ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_instruments()
	set name = "Hear/Silence Instruments"
	set category = "Preferences"
	set desc = "Hear In-game Instruments"
	prefs.toggles ^= PREFTOGGLE_SOUND_INSTRUMENTS
	prefs.save_preferences()
	if(prefs.toggles & PREFTOGGLE_SOUND_INSTRUMENTS)
		to_chat(usr, "You will now hear people playing musical instruments.")
	else
		to_chat(usr, "You will no longer hear musical instruments.")
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Instruments", "[prefs.toggles & PREFTOGGLE_SOUND_INSTRUMENTS ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/Toggle_Soundscape()
	set name = "Hear/Silence Ambience"
	set category = "Preferences"
	set desc = "Hear Ambient Sound Effects"
	prefs.toggles ^= PREFTOGGLE_SOUND_AMBIENCE
	prefs.save_preferences()
	if(prefs.toggles & PREFTOGGLE_SOUND_AMBIENCE)
		to_chat(usr, "You will now hear ambient sounds.")
	else
		to_chat(usr, "You will no longer hear ambient sounds.")
		usr.stop_sound_channel(CHANNEL_AMBIENT_EFFECTS)
		usr.stop_sound_channel(CHANNEL_AMBIENT_MUSIC)
		usr.stop_sound_channel(CHANNEL_BUZZ)
		usr.client.buzz_playing = FALSE
	usr.client.update_ambience_pref()
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Ambience", "[usr.client.prefs.toggles & PREFTOGGLE_SOUND_AMBIENCE ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ship_ambience()
	set name = "Hear/Silence Ship Ambience"
	set category = "Preferences"
	set desc = "Hear Ship Ambience Roar"
	prefs.toggles ^= PREFTOGGLE_SOUND_SHIP_AMBIENCE
	prefs.save_preferences()
	if(prefs.toggles & PREFTOGGLE_SOUND_SHIP_AMBIENCE)
		to_chat(usr, "You will now hear ship ambience.")
	else
		to_chat(usr, "You will no longer hear ship ambience.")
		usr.stop_sound_channel(CHANNEL_BUZZ)
		usr.client.buzz_playing = FALSE
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Ship Ambience", "[usr.client.prefs.toggles & PREFTOGGLE_SOUND_SHIP_AMBIENCE ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, I bet you read this comment expecting to see the same thing :^)

/client/verb/toggle_soundtrack()
	set name = "Hear/Silence Soundtrack"
	set category = "Preferences"
	set desc = "Hear Soundtrack Songs"
	prefs.toggles2 ^= PREFTOGGLE_2_SOUNDTRACK
	prefs.save_preferences()
	if(prefs.toggles2 & PREFTOGGLE_2_SOUNDTRACK)
		to_chat(usr, "You will now hear soundtrack songs.")
		usr.play_current_soundtrack()
	else
		to_chat(usr, "You will no longer hear soundtrack songs.")
		usr.stop_sound_channel(CHANNEL_SOUNDTRACK)
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Soundtrack", "[usr.client.prefs.toggles2 & PREFTOGGLE_2_SOUNDTRACK ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, I bet you read this comment expecting to see the same thing :^)


/client/verb/toggle_announcement_sound()
	set name = "Hear/Silence Announcements"
	set category = "Preferences"
	set desc = "Hear Announcement Sound"
	prefs.toggles ^= PREFTOGGLE_SOUND_ANNOUNCEMENTS
	to_chat(usr, "You will now [(prefs.toggles & PREFTOGGLE_SOUND_ANNOUNCEMENTS) ? "hear announcement sounds" : "no longer hear announcements"].")
	prefs.save_preferences()
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Announcement Sound", "[prefs.toggles & PREFTOGGLE_SOUND_ANNOUNCEMENTS ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/stop_client_sounds()
	set name = "Stop Sounds"
	set category = "Preferences"
	set desc = "Stop Current Sounds"
	SEND_SOUND(usr, sound(null))
	tgui_panel?.stop_music()
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Stop Self Sounds")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/listen_ooc()
	set name = "Show/Hide OOC"
	set category = "Preferences"
	set desc = "Show OOC Chat"
	prefs.chat_toggles ^= CHAT_OOC
	prefs.save_preferences()
	to_chat(usr, "You will [(prefs.chat_toggles & CHAT_OOC) ? "now" : "no longer"] see messages on the OOC channel.")
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Seeing OOC", "[prefs.chat_toggles & CHAT_OOC ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/listen_bank_card()
	set name = "Show/Hide Income Updates"
	set category = "Preferences"
	set desc = "Show or hide updates to your income"
	prefs.chat_toggles ^= CHAT_BANKCARD
	prefs.save_preferences()
	to_chat(usr, "You will [(prefs.chat_toggles & CHAT_BANKCARD) ? "now" : "no longer"] be notified when you get paid.")
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Income Notifications", "[(prefs.chat_toggles & CHAT_BANKCARD) ? "Enabled" : "Disabled"]"))

GLOBAL_LIST_INIT(ghost_forms, sort_list(list("ghost","ghostking","ghostian2","skeleghost","ghost_red","ghost_black", \
							"ghost_blue","ghost_yellow","ghost_green","ghost_pink", \
							"ghost_cyan","ghost_dblue","ghost_dred","ghost_dgreen", \
							"ghost_dcyan","ghost_grey","ghost_dyellow","ghost_dpink", "ghost_purpleswirl","ghost_funkypurp","ghost_pinksherbert","ghost_blazeit",\
							"ghost_mellow","ghost_rainbow","ghost_camo","ghost_fire", "catghost")))

/client/proc/pick_form()
	if(!is_content_unlocked())
		alert("This setting is for accounts with BYOND premium only.")
		return
	var/new_form = input(src, "Thanks for supporting BYOND - Choose your ghostly form:","Thanks for supporting BYOND",null) as null|anything in GLOB.ghost_forms
	if(new_form)
		prefs.ghost_form = new_form
		prefs.save_preferences()
		if(isobserver(mob))
			var/mob/dead/observer/O = mob
			O.update_icon(new_form = new_form)

GLOBAL_LIST_INIT(ghost_orbits, list(GHOST_ORBIT_CIRCLE,GHOST_ORBIT_TRIANGLE,GHOST_ORBIT_SQUARE,GHOST_ORBIT_HEXAGON,GHOST_ORBIT_PENTAGON))

/client/proc/pick_ghost_orbit()
	if(!is_content_unlocked())
		alert("This setting is for accounts with BYOND premium only.")
		return
	var/new_orbit = input(src, "Thanks for supporting BYOND - Choose your ghostly orbit:","Thanks for supporting BYOND",null) as null|anything in GLOB.ghost_orbits
	if(new_orbit)
		prefs.ghost_orbit = new_orbit
		prefs.save_preferences()
		if(isobserver(mob))
			var/mob/dead/observer/O = mob
			O.ghost_orbit = new_orbit

/client/proc/pick_ghost_accs()
	var/new_ghost_accs = alert("Do you want your ghost to show full accessories where possible, hide accessories but still use the directional sprites where possible, or also ignore the directions and stick to the default sprites?",,"full accessories", "only directional sprites", "default sprites")
	if(new_ghost_accs)
		switch(new_ghost_accs)
			if("full accessories")
				prefs.ghost_accs = GHOST_ACCS_FULL
			if("only directional sprites")
				prefs.ghost_accs = GHOST_ACCS_DIR
			if("default sprites")
				prefs.ghost_accs = GHOST_ACCS_NONE
		prefs.save_preferences()
		if(isobserver(mob))
			var/mob/dead/observer/O = mob
			O.update_icon()

/client/verb/pick_ghost_customization()
	set name = "Ghost Customization"
	set category = "Preferences"
	set desc = "Customize your ghastly appearance."
	if(is_content_unlocked())
		switch(alert("Which setting do you want to change?",,"Ghost Form","Ghost Orbit","Ghost Accessories"))
			if("Ghost Form")
				pick_form()
			if("Ghost Orbit")
				pick_ghost_orbit()
			if("Ghost Accessories")
				pick_ghost_accs()
	else
		pick_ghost_accs()

/client/verb/pick_ghost_others()
	set name = "Ghosts of Others"
	set category = "Preferences"
	set desc = "Change display settings for the ghosts of other players."
	var/new_ghost_others = alert("Do you want the ghosts of others to show up as their own setting, as their default sprites or always as the default white ghost?",,"Their Setting", "Default Sprites", "White Ghost")
	if(new_ghost_others)
		switch(new_ghost_others)
			if("Their Setting")
				prefs.ghost_others = GHOST_OTHERS_THEIR_SETTING
			if("Default Sprites")
				prefs.ghost_others = GHOST_OTHERS_DEFAULT_SPRITE
			if("White Ghost")
				prefs.ghost_others = GHOST_OTHERS_SIMPLE
		prefs.save_preferences()
		if(isobserver(mob))
			var/mob/dead/observer/O = mob
			O.update_sight()

/client/verb/toggle_intent_style()
	set name = "Toggle Intent Selection Style"
	set category = "Preferences"
	set desc = "Toggle between directly clicking the desired intent or clicking to rotate through."
	prefs.toggles ^= PREFTOGGLE_INTENT_STYLE
	to_chat(src, "[(prefs.toggles & PREFTOGGLE_INTENT_STYLE) ? "Clicking directly on intents selects them." : "Clicking on intents rotates selection clockwise."]")
	prefs.save_preferences()
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Intent Selection", "[prefs.toggles & PREFTOGGLE_INTENT_STYLE ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_hud_pref()
	set name = "Toggle Ghost HUD"
	set category = "Preferences"
	set desc = "Hide/Show Ghost HUD"

	prefs.toggles2 ^= PREFTOGGLE_2_GHOST_HUD
	to_chat(src, "Ghost HUD will now be [(prefs.toggles2 & PREFTOGGLE_2_GHOST_HUD) ? "visible" : "hidden"].")
	prefs.save_preferences()
	if(isobserver(mob))
		mob.hud_used.show_hud()
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Ghost HUD", "[(prefs.toggles2 & PREFTOGGLE_2_GHOST_HUD) ? "Enabled" : "Disabled"]"))

/client/verb/toggle_show_credits()
	set name = "Toggle Credits"
	set category = "Preferences"
	set desc = "Hide/Show Credits"

	prefs.toggles2 ^= PREFTOGGLE_2_SHOW_CREDITS
	to_chat(src, "Credits will now be [prefs.toggles2 & PREFTOGGLE_2_SHOW_CREDITS ? "visible" : "hidden"].")
	prefs.save_preferences()
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Credits", "[prefs.toggles2 & PREFTOGGLE_2_SHOW_CREDITS ? "Enabled" : "Disabled"]"))

/client/verb/toggle_inquisition() // warning: unexpected inquisition
	set name = "Toggle Inquisitiveness"
	set desc = "Sets whether your ghost examines everything on click by default"
	set category = "Preferences"

	prefs.toggles2 ^= PREFTOGGLE_2_GHOST_INQUISITIVENESS
	prefs.save_preferences()
	if(prefs.toggles2 & PREFTOGGLE_2_GHOST_INQUISITIVENESS)
		to_chat(src, "<span class='notice'>You will now examine everything you click on.</span>")
	else
		to_chat(src, "<span class='notice'>You will no longer examine things you click on.</span>")
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Ghost Inquisitiveness", "[(prefs.toggles2 & PREFTOGGLE_2_GHOST_INQUISITIVENESS) ? "Enabled" : "Disabled"]"))

//Admin Preferences
/client/proc/toggleadminhelpsound()
	set name = "Hear/Silence Adminhelps"
	set category = "Prefs - Admin"
	set desc = "Toggle hearing a notification when admin PMs are received"
	if(!holder)
		return
	prefs.toggles ^= PREFTOGGLE_SOUND_ADMINHELP
	prefs.save_preferences()
	to_chat(usr, "You will [(prefs.toggles & PREFTOGGLE_SOUND_ADMINHELP) ? "now" : "no longer"] hear a sound when adminhelps arrive.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Adminhelp Sound", "[prefs.toggles & PREFTOGGLE_SOUND_ADMINHELP ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggleadminalertsound()
	set name = "Hear/Silence Admin alerts"
	set category = "Prefs - Admin"
	set desc = "Toggle hearing a notification when various admin alerts happen"
	if(!holder)
		return
	prefs.toggles ^= PREFTOGGLE_2_SOUND_ADMINALERT
	prefs.save_preferences()
	to_chat(usr, "You will [(prefs.toggles & PREFTOGGLE_2_SOUND_ADMINALERT) ? "now" : "no longer"] hear a sound when an admin alert shows up.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Admin alert Sound", "[prefs.toggles & PREFTOGGLE_2_SOUND_ADMINALERT ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggleannouncelogin()
	set name = "Do/Don't Announce Login"
	set category = "Prefs - Admin"
	set desc = "Toggle if you want an announcement to admins when you login during a round"
	if(!holder)
		return
	prefs.toggles ^= PREFTOGGLE_ANNOUNCE_LOGIN
	prefs.save_preferences()
	to_chat(usr, "You will [(prefs.toggles & PREFTOGGLE_ANNOUNCE_LOGIN) ? "now" : "no longer"] have an announcement to other admins when you login.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Login Announcement", "[prefs.toggles & PREFTOGGLE_ANNOUNCE_LOGIN ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_hear_radio()
	set name = "Show/Hide Radio Chatter"
	set category = "Prefs - Admin"
	set desc = "Toggle seeing radiochatter from nearby radios and speakers"
	if(!holder)
		return
	prefs.chat_toggles ^= CHAT_RADIO
	prefs.save_preferences()
	to_chat(usr, "You will [(prefs.chat_toggles & CHAT_RADIO) ? "now" : "no longer"] see radio chatter from nearby radios or speakers")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Radio Chatter", "[prefs.chat_toggles & CHAT_RADIO ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/deadchat()
	set name = "Show/Hide Deadchat"
	set category = "Prefs - Admin"
	set desc ="Toggles seeing deadchat"
	if(!holder)
		return
	prefs.chat_toggles ^= CHAT_DEAD
	prefs.save_preferences()
	to_chat(src, "You will [(prefs.chat_toggles & CHAT_DEAD) ? "now" : "no longer"] see deadchat.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Deadchat Visibility", "[prefs.chat_toggles & CHAT_DEAD ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggleprayers()
	set name = "Show/Hide Prayers"
	set category = "Prefs - Admin"
	set desc = "Toggles seeing prayers"
	if(!holder)
		return
	prefs.chat_toggles ^= CHAT_PRAYER
	prefs.save_preferences()
	to_chat(src, "You will [(prefs.chat_toggles & CHAT_PRAYER) ? "now" : "no longer"] see prayerchat.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Prayer Visibility", "[prefs.chat_toggles & CHAT_PRAYER ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_prayer_sound()
	set name = "Hear/Silence Prayer Sounds"
	set category = "Prefs - Admin"
	set desc = "Hear Prayer Sounds"
	if(!holder)
		return
	prefs.toggles ^= PREFTOGGLE_SOUND_PRAYERS
	prefs.save_preferences()
	to_chat(usr, "You will [(prefs.toggles & PREFTOGGLE_SOUND_PRAYERS) ? "now" : "no longer"] hear a sound when prayers arrive.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Prayer Sounds", "[prefs.toggles & PREFTOGGLE_SOUND_PRAYERS ? "Enabled" : "Disabled"]"))

/client/proc/colorasay()
	set name = "Set Admin Say Color"
	set category = "Prefs - Admin"
	set desc = "Set the color of your ASAY messages"
	if(!holder)
		return
	if(!CONFIG_GET(flag/allow_admin_asaycolor))
		to_chat(src, "Custom Asay color is currently disabled by the server.")
		return
	var/new_asaycolor = tgui_color_picker(src, "Please select your ASAY color.", "ASAY color", prefs.asaycolor)
	if(new_asaycolor)
		prefs.asaycolor = sanitize_ooccolor(new_asaycolor)
		prefs.save_preferences()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Set ASAY Color")
	return

/client/proc/resetasaycolor()
	set name = "Reset your Admin Say Color"
	set desc = "Returns your ASAY Color to default"
	set category = "Prefs - Admin"
	if(!holder)
		return
	if(!CONFIG_GET(flag/allow_admin_asaycolor))
		to_chat(src, "Custom Asay color is currently disabled by the server.")
		return
	prefs.asaycolor = initial(prefs.asaycolor)
	prefs.save_preferences()
