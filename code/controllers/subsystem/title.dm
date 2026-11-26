SUBSYSTEM_DEF(title)
	name = "Title Screen"
	ss_flags = SS_NO_FIRE
	init_stage = INITSTAGE_EARLY

	var/file_path
	var/lobby_screen_size = "15x15"
	var/icon/icon
	var/icon/previous_icon
	var/turf/newplayer_start_loc
	var/turf/closed/indestructible/splashscreen/splash_turf

/datum/controller/subsystem/title/Initialize()
	if(file_path && icon)
		return SS_INIT_SUCCESS

	if(fexists("data/previous_title.dat"))
		var/previous_path = rustg_file_read("data/previous_title.dat")
		if(istext(previous_path))
			previous_icon = new(previous_icon)
	fdel("data/previous_title.dat")

	var/list/provisional_title_screens = flist("[global.config.directory]/title_screens/images/")
	LAZYREMOVE(provisional_title_screens, "exclude")
	if(length(provisional_title_screens))
		file_path = "[global.config.directory]/title_screens/images/[pick(provisional_title_screens)]"
	else
		file_path = "icons/runtime/default_title.dmi"

	ASSERT(fexists(file_path))

	icon = new(fcopy_rsc(file_path))
	calculate_title_size()
	splash_turf?.icon = icon

	return SS_INIT_SUCCESS

/datum/controller/subsystem/title/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	switch(var_name)
		if(NAMEOF(src, icon))
			splash_turf?.icon = icon
			calculate_title_size()

/datum/controller/subsystem/title/Shutdown()
	if(file_path)
		WRITE_FILE(file("data/previous_title.dat"), file_path)

	for(var/thing in GLOB.clients_unsafe)
		if(!thing)
			continue
		var/atom/movable/screen/splash/S = new(null, thing, FALSE)
		S.fade(FALSE,FALSE)

/datum/controller/subsystem/title/Recover()
	icon = SStitle.icon
	splash_turf = SStitle.splash_turf
	file_path = SStitle.file_path
	previous_icon = SStitle.previous_icon

/datum/controller/subsystem/title/proc/calculate_title_size()
	// varedit support
	if(isfile(icon))
		icon = icon(icon)

	//Calculate the screen size
	var/width = icon.Width() / world.icon_size
	var/height = icon.Height() / world.icon_size
	var/calculated_lobby_screen_size = "[width]x[height]"

	if(lobby_screen_size != calculated_lobby_screen_size)
		lobby_screen_size = calculated_lobby_screen_size
		// Update the new player start (views are centered)
		var/new_player_x = splash_turf.x + floor(width / 2)
		var/new_player_y = splash_turf.y + floor(height / 2)
		newplayer_start_loc = locate(new_player_x, new_player_y, splash_turf.z)
		// Reset the newplayer start loc
		GLOB.newplayer_start.Cut()
		GLOB.newplayer_start += newplayer_start_loc

		// Update fast joiners
		for (var/mob/dead/new_player/fast_joiner in GLOB.player_list)
			if(isnull(fast_joiner.client?.view_size))
				fast_joiner.client?.change_view(getScreenSize(fast_joiner))
			else
				fast_joiner.client?.view_size.resetToDefault(getScreenSize(fast_joiner))
			// Execute this immediately, change_view runs through SStimer which doesn't execute until after
			// initialisation
			if (fast_joiner.client?.prefs?.read_player_preference(/datum/preference/toggle/auto_fit_viewport))
				fast_joiner.client?.fit_viewport()
			var/original_glide = fast_joiner.glide_size
			fast_joiner.glide_size = 0
			fast_joiner.forceMove(newplayer_start_loc)
			fast_joiner.glide_size = original_glide
