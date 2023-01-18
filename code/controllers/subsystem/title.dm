SUBSYSTEM_DEF(title)
	name = "Title Screen"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_TITLE

	var/file_path
	var/lobby_screen_size = "15x15"
	var/icon/icon
	var/icon/previous_icon
	var/turf/newplayer_start_loc
	var/turf/closed/indestructible/splashscreen/splash_turf

/datum/controller/subsystem/title/Initialize()
	if(file_path && icon)
		return

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
	var/icon/single_frame = new(icon, frame=1)

	//Calculate the screen size
	var/width = round(single_frame.Width() / world.icon_size)
	var/height = round(single_frame.Height() / world.icon_size)

	// Set the max allowed size of a lobby screen to the width of the z-level
	if (width < world.maxx)
		lobby_screen_size = "[width]x[height]"

		//Update the new player start (views are centered)
		var/new_player_x = splash_turf.x + FLOOR(width / 2, 1)
		var/new_player_y = splash_turf.y + FLOOR(height / 2, 1)
		newplayer_start_loc = locate(new_player_x, new_player_y, splash_turf.z)
		GLOB.newplayer_start.Cut()
		GLOB.newplayer_start += newplayer_start_loc

		//Update fast joiners
		for (var/mob/dead/new_player/fast_joiner in GLOB.new_player_list)
			if(isnull(fast_joiner.client?.view_size))
				fast_joiner.client?.change_view(getScreenSize(fast_joiner))
			else
				fast_joiner.client?.view_size.resetToDefault(getScreenSize(fast_joiner))
			fast_joiner.forceMove(newplayer_start_loc)
	else
		stack_trace("Title screen exception: The title screen [file_path] is not properly formatted and cannot be understood by BYOND. Verify that the image has the correct extension. If you're using a dmi file, ensure any animations are split into frames.")

	if(splash_turf)
		splash_turf.icon = icon

	return ..()

/datum/controller/subsystem/title/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		switch(var_name)
			if(NAMEOF(src, icon))
				if(splash_turf)
					splash_turf.icon = icon

/datum/controller/subsystem/title/Shutdown()
	if(file_path)
		var/F = file("data/previous_title.dat")
		WRITE_FILE(F, file_path)

	for(var/thing in GLOB.clients)
		if(!thing)
			continue
		var/atom/movable/screen/splash/S = new(null, thing, FALSE)
		S.Fade(FALSE,FALSE)

/datum/controller/subsystem/title/Recover()
	icon = SStitle.icon
	splash_turf = SStitle.splash_turf
	file_path = SStitle.file_path
	previous_icon = SStitle.previous_icon
