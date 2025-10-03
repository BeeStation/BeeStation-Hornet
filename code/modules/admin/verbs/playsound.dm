//world/proc/shelleo
#define SHELLEO_ERRORLEVEL 1
#define SHELLEO_STDOUT 2
#define SHELLEO_STDERR 3

/client/proc/play_sound(sound as sound)
	set category = "Fun"
	set name = "Play Global Sound"
	if(!check_rights(R_SOUND))
		return

	var/vol = tgui_input_number(usr, "What volume would you like the sound to play at?", max_value = 100)
	if(!vol)
		return
	vol = clamp(vol, 1, 100)

	var/sound/admin_sound = new
	admin_sound.file = sound
	admin_sound.priority = 250
	admin_sound.channel = CHANNEL_ADMIN
	admin_sound.frequency = 1
	admin_sound.wait = 1
	admin_sound.repeat = FALSE
	admin_sound.status = SOUND_STREAM
	admin_sound.volume = vol

	var/res = tgui_alert(usr, "Show the title of this song to the players?",, list("Yes","No", "Cancel"))
	switch(res)
		if("Yes")
			to_chat(world, span_boldannounce("An admin played: [sound]"))
		if("Cancel")
			return

	log_admin("[key_name(usr)] played sound [sound]")
	message_admins("[key_name_admin(usr)] played sound [sound]")

	for(var/mob/player in GLOB.player_list)
		if(player.client.prefs.read_player_preference(/datum/preference/toggle/sound_midi))
			admin_sound.volume = vol * player.client.admin_music_volume
			SEND_SOUND(player, admin_sound)
			admin_sound.volume = vol

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Global Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/play_local_sound(sound as sound)
	set category = "Fun"
	set name = "Play Local Sound"
	if(!check_rights(R_SOUND))
		return

	log_admin("[key_name(src)] played a local sound [sound]")
	message_admins("[key_name_admin(src)] played a local sound [sound]")
	var/volume = tgui_input_number(src, "What volume would you like the sound to play at?", max_value = 100)
	playsound(get_turf(src.mob), sound, volume || 50, FALSE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Local Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

GLOBAL_VAR_INIT(web_sound_cooldown, 0)

///Takes an input from either proc/play_web_sound or the request manager and runs it through yt-dlp and prompts the user before playing it to the server.
/proc/web_sound(mob/user, input, credit)
	if(!check_rights(R_SOUND))
		return
	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl)
		to_chat(user, span_boldwarning("yt-dlp was not configured, action unavailable")) //Check config.txt for the INVOKE_YOUTUBEDL value
		return
	var/web_sound_url = ""
	var/stop_web_sounds = FALSE
	var/list/music_extra_data = list()
	var/duration = 0
	if(istext(input))
		var/shell_scrubbed_input = shell_url_scrub(input)
		var/list/output = world.shelleo("[ytdl] --geo-bypass --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height <= 360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" --dump-single-json --no-playlist -- \"[shell_scrubbed_input]\"")
		var/errorlevel = output[SHELLEO_ERRORLEVEL]
		var/stdout = output[SHELLEO_STDOUT]
		var/stderr = output[SHELLEO_STDERR]
		if(errorlevel)
			to_chat(user, span_boldwarning("yt-dlp URL retrieval FAILED:"))
			to_chat(user, span_warning("[stderr]"))
			return
		var/list/data
		try
			data = json_decode(stdout)
		catch(var/exception/e)
			to_chat(user, span_boldwarning("yt-dlp JSON parsing FAILED:"))
			to_chat(user, span_warning("[e]: [stdout]"))
			return
		if (data["url"])
			web_sound_url = data["url"]
		var/title = "[data["title"]]"
		var/webpage_url = title
		if (data["webpage_url"])
			webpage_url = "<a href=\"[data["webpage_url"]]\">[title]</a>"
		music_extra_data["duration"] = DisplayTimeText(data["duration"] * 1 SECONDS)
		music_extra_data["link"] = data["webpage_url"]
		music_extra_data["artist"] = data["artist"]
		music_extra_data["upload_date"] = data["upload_date"]
		music_extra_data["album"] = data["album"]
		duration = data["duration"] * 1 SECONDS
		if (duration > 10 MINUTES)
			if((tgui_alert(user, "This song is over 10 minutes long. Are you sure you want to play it?", "Length Warning!", list("No", "Yes", "Cancel")) != "Yes"))
				return
		var/res = tgui_alert(user, "Show the title of and link to this song to the players?\n[title]", "Show Info?", list("Yes", "No", "Cancel"))
		switch(res)
			if("Yes")
				music_extra_data["title"] = data["title"]
			if("No")
				music_extra_data["link"] = "Song Link Hidden"
				music_extra_data["title"] = "Song Title Hidden"
				music_extra_data["artist"] = "Song Artist Hidden"
				music_extra_data["upload_date"] = "Song Upload Date Hidden"
				music_extra_data["album"] = "Song Album Hidden"
			if("Cancel", null)
				return
		var/anon = tgui_alert(user, "Display who played the song?", "Credit Yourself?", list("Yes", "No", "Cancel"))
		switch(anon)
			if("Yes")
				if(res == "Yes")
					to_chat(world, span_boldannounce("[user.key] played: [webpage_url]"))
				else
					to_chat(world, span_boldannounce("[user.key] played a sound"))
			if("No")
				if(res == "Yes")
					to_chat(world, span_boldannounce("An admin played: [webpage_url]"))
			if("Cancel", null)
				return
		if(credit)
			to_chat(world, span_boldannounce(credit))
		SSblackbox.record_feedback("nested tally", "played_url", 1, list("[user.ckey]", "[input]"))
		log_admin("[key_name(user)] played web sound: [input]")
		message_admins("[key_name(user)] played web sound: [input]")
	else
		//pressed ok with blank
		log_admin("[key_name(user)] stopped web sounds.")

		message_admins("[key_name(user)] stopped web sounds.")
		web_sound_url = null
		stop_web_sounds = TRUE
	if(web_sound_url && !findtext(web_sound_url, GLOB.is_http_protocol))
		tgui_alert(user, "The media provider returned a content URL that isn't using the HTTP or HTTPS protocol. This is a security risk and the sound will not be played.", "Security Risk", list("OK"))
		to_chat(user, span_boldwarning("BLOCKED: Content URL not using HTTP(S) Protocol!"))

		return
	if(web_sound_url || stop_web_sounds)
		for(var/mob/player in GLOB.player_list)
			var/client/player_client = player.client
			if(player_client.prefs.read_player_preference(/datum/preference/toggle/sound_midi))
				// Stops playing lobby music and admin loaded music automatically.
				SEND_SOUND(player_client, sound(null, channel = CHANNEL_LOBBYMUSIC))
				SEND_SOUND(player_client, sound(null, channel = CHANNEL_ADMIN))
				if(!stop_web_sounds)
					player_client.tgui_panel?.play_music(web_sound_url, music_extra_data)
				else
					player_client.tgui_panel?.stop_music()

	CLIENT_COOLDOWN_START(GLOB, web_sound_cooldown, duration)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Internet Sound")

/client/proc/play_web_sound()
	set category = "Fun"
	set name = "Play Internet Sound"
	if(!check_rights(R_SOUND))
		return

	if(!CLIENT_COOLDOWN_FINISHED(GLOB, web_sound_cooldown))
		if(tgui_alert(usr, "Someone else is already playing an Internet sound! It has [DisplayTimeText(CLIENT_COOLDOWN_TIMELEFT(GLOB, web_sound_cooldown), 1)] remaining. \
		Would you like to override?", "Musicalis Interruptus", list("No","Yes")) != "Yes")
			return

	var/web_sound_input = tgui_input_text(usr, "Enter content URL (supported sites only, leave blank to stop playing)", "Play Internet Sound", null)

	if(length(web_sound_input))
		web_sound_input = trim(web_sound_input)
		if(findtext(web_sound_input, ":") && !findtext(web_sound_input, GLOB.is_http_protocol))
			to_chat(usr, span_boldwarning("Non-http(s) URIs are not allowed."))
			to_chat(usr, span_warning("For youtube-dl shortcuts like ytsearch: please use the appropriate full URL from the website."))
			return
		web_sound(src.mob, web_sound_input)
	else
		web_sound(src.mob, null)

/client/proc/set_round_end_sound(S as sound)
	set category = "Fun"
	set name = "Set Round End Sound"
	if(!check_rights(R_SOUND))
		return

	SSticker.SetRoundEndSound(S)

	log_admin("[key_name(src)] set the round end sound to [S]")
	message_admins("[key_name_admin(src)] set the round end sound to [S]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Set Round End Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/play_soundtrack()
	set category = "Fun"
	set name = "Play Soundtrack Music"
	set desc = "Choose a song to play from the available soundtrack."

	var/station_only = alert(usr, "Play only on station?", "Station Setting", "Station Only", "All", "Cancel")
	if(station_only == "Cancel" || station_only == null)
		return
	var/soundtracks = subtypesof(/datum/soundtrack_song)
	for(var/datum/soundtrack_song/song as() in soundtracks)
		if(initial(song.file) != null)
			continue
		soundtracks -= song
	var/song_choice = input(usr, "Choose a song", "Song Choice", null) as null|anything in soundtracks
	if(!ispath(song_choice, /datum/soundtrack_song))
		return
	play_soundtrack_music(song_choice, only_station = (station_only == "Station Only" ? SOUNDTRACK_PLAY_ONLYSTATION : SOUNDTRACK_PLAY_ALL))

/client/proc/stop_sounds()
	set category = "Debug"
	set name = "Stop All Playing Sounds"
	if(!src.holder)
		return

	log_admin("[key_name(src)] stopped all currently playing sounds.")
	message_admins("[key_name_admin(src)] stopped all currently playing sounds.")
	for(var/mob/M in GLOB.player_list)
		if(M.client)
			SEND_SOUND(M, sound(null))
			var/client/C = M.client
			C?.tgui_panel?.stop_music()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Stop All Playing Sounds") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

#undef SHELLEO_ERRORLEVEL
#undef SHELLEO_STDOUT
#undef SHELLEO_STDERR
