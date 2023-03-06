
/client
	var/list/parallax_layers
	var/list/parallax_layers_cached
	var/turf/previous_turf
	/// Direction our current area wants to move parallax
	var/parallax_movedir = 0
	/// How many parallax layers to show our client
	var/parallax_layers_max = 4
	/// Timer for the area directional animation
	var/parallax_animate_timer
	/// Do we want to do parallax animations at all?
	/// Exists to prevent laptop fires
	var/do_parallax_animations = TRUE

	var/frozen_parallax

/datum/hud/proc/create_parallax(mob/viewmob)
	var/mob/screenmob = viewmob || mymob
	var/client/C = screenmob.client
	if (!C || !apply_parallax_pref(viewmob)) //don't want shit computers to crash when specing someone with insane parallax, so use the viewer's pref
		return

	if(!length(C.parallax_layers_cached))
		C.parallax_layers_cached = list()
		C.parallax_layers_cached += new /atom/movable/screen/parallax_layer/layer_1(null, screenmob)
		C.parallax_layers_cached += new /atom/movable/screen/parallax_layer/layer_2(null, screenmob)
		C.parallax_layers_cached += new /atom/movable/screen/parallax_layer/planet(null, screenmob)
		if(SSparallax.random_layer)
			C.parallax_layers_cached += new SSparallax.random_layer(null, screenmob)
		C.parallax_layers_cached += new /atom/movable/screen/parallax_layer/layer_3(null, screenmob)

	C.parallax_layers = C.parallax_layers_cached.Copy()

	if (length(C.parallax_layers) > C.parallax_layers_max)
		C.parallax_layers.len = C.parallax_layers_max

	C.screen |= (C.parallax_layers)
	var/atom/movable/screen/plane_master/plane_master = screenmob.hud_used.plane_masters["[PLANE_SPACE]"]
	if(screenmob != mymob)
		C.screen -= locate(/atom/movable/screen/plane_master/parallax_white) in C.screen
		C.screen += plane_master
	plane_master.color = list(
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		1, 1, 1, 1,
		0, 0, 0, 0
		)


/datum/hud/proc/remove_parallax(mob/viewmob)
	var/mob/screenmob = viewmob || mymob
	var/client/C = screenmob.client
	// Default to HIGH
	var/parallax_selection = PARALLAX_HIGH
	C.screen -= (C.parallax_layers_cached)
	var/atom/movable/screen/plane_master/plane_master = screenmob.hud_used.plane_masters["[PLANE_SPACE]"]
	if(screenmob != mymob)
		C.screen -= locate(/atom/movable/screen/plane_master/parallax_white) in C.screen
		C.screen += plane_master
	plane_master.color = initial(plane_master.color)
	C.parallax_layers = null

/datum/hud/proc/apply_parallax_pref(mob/viewmob)
	var/mob/screenmob = viewmob || mymob

	var/client/C = screenmob.client
	// Default to HIGH
	var/parallax_selection =  C.prefs.parallax || PARALLAX_HIGH

	switch(parallax_selection)
		if (PARALLAX_INSANE)
			C.parallax_layers_max = 5
			C.do_parallax_animations = TRUE
			return TRUE

		if (PARALLAX_MED)
			C.parallax_layers_max = 3
			C.do_parallax_animations = TRUE
			return TRUE

		if (PARALLAX_LOW)
			C.parallax_layers_max = 1
			C.do_parallax_animations = FALSE
			return TRUE

		if (PARALLAX_DISABLE)
			return FALSE

/datum/hud/proc/update_parallax_pref(mob/viewmob)
	var/mob/screen_mob = viewmob || mymob
	if(!screen_mob.client)
		return
	remove_parallax(viewmob)
	create_parallax(viewmob)
	update_parallax()

// This sets which way the current shuttle is moving (returns true if the shuttle has stopped moving so the caller can append their animation)
/datum/hud/proc/set_parallax_movedir(new_parallax_movedir = 0, skip_windups)
	. = FALSE
	var/client/C = mymob.client
	if(new_parallax_movedir == C.parallax_movedir)
		return
	var/animatedir = new_parallax_movedir
	if(new_parallax_movedir == FALSE)
		var/animate_time = 0
		for(var/thing in C.parallax_layers)
			var/atom/movable/screen/parallax_layer/L = thing
			L.icon_state = initial(L.icon_state)
			L.update_o(C.view)
			var/T = PARALLAX_LOOP_TIME / L.speed
			if (T > animate_time)
				animate_time = T
		animatedir = C.parallax_movedir

	var/matrix/newtransform
	switch(animatedir)
		if(NORTH)
			newtransform = matrix(1, 0, 0, 0, 1, 480)
		if(SOUTH)
			newtransform = matrix(1, 0, 0, 0, 1,-480)
		if(EAST)
			newtransform = matrix(1, 0, 480, 0, 1, 0)
		if(WEST)
			newtransform = matrix(1, 0,-480, 0, 1, 0)

	var/shortesttimer
	if(!skip_windups)
		for(var/thing in C.parallax_layers)
			var/atom/movable/screen/parallax_layer/L = thing

			var/T = PARALLAX_LOOP_TIME / L.speed
			if (isnull(shortesttimer))
				shortesttimer = T
			if (T < shortesttimer)
				shortesttimer = T
			L.transform = newtransform
			animate(L, transform = matrix(), time = T, easing = QUAD_EASING | (new_parallax_movedir ? EASE_IN : EASE_OUT), flags = ANIMATION_END_NOW)
			if (new_parallax_movedir)
				L.transform = newtransform
				animate(transform = matrix(), time = T) //queue up another animate so lag doesn't create a shutter

	C.parallax_movedir = new_parallax_movedir
	if (C.parallax_animate_timer)
		deltimer(C.parallax_animate_timer)
	var/datum/callback/CB = CALLBACK(src, .proc/update_parallax_motionblur, C, animatedir, new_parallax_movedir, newtransform)
	if(skip_windups)
		CB.Invoke()
	else
		C.parallax_animate_timer = addtimer(CB, min(shortesttimer, PARALLAX_LOOP_TIME), TIMER_CLIENT_TIME|TIMER_STOPPABLE)


/datum/hud/proc/update_parallax_motionblur(client/C, animatedir, new_parallax_movedir, matrix/newtransform)
	if(!C)
		return
	C.parallax_animate_timer = FALSE
	for(var/thing in C.parallax_layers)
		var/atom/movable/screen/parallax_layer/L = thing
		if (!new_parallax_movedir)
			animate(L)
			continue

		var/newstate = initial(L.icon_state)
		var/T = PARALLAX_LOOP_TIME / L.speed

		if (newstate in icon_states(L.icon))
			L.icon_state = newstate
			L.update_o(C.view)

		L.transform = newtransform

		animate(L, transform = matrix(), time = T, loop = -1)
		animate(transform = newtransform, time = 0, loop = -1)

/datum/hud/proc/freeze_parallax()
	var/client/C = mymob.client
	var/turf/posobj = get_turf(C.eye)
	if(!posobj)
		return

	var/area/areaobj = posobj.loc

	// Update the movement direction of the parallax if necessary (for shuttles)
	set_parallax_movedir(areaobj.parallax_movedir, FALSE)

	for(var/atom/movable/screen/parallax_layer/L as() in C.parallax_layers)
		if (L.view_sized != C.view)
			L.update_o(C.view)
		L.update_status(mymob)
		if(!C.frozen_parallax)
			L.screen_loc = "CENTER-7:0,CENTER-7:0"
			C.frozen_parallax = TRUE

/datum/hud/proc/update_parallax()
	var/client/C = mymob.client
	if(!C)
		return
	var/turf/posobj = get_turf(C.eye)
	if(!posobj)
		return

	var/area/areaobj = posobj.loc
	// Update the movement direction of the parallax if necessary (for shuttles)
	set_parallax_movedir(areaobj.parallax_movedir, FALSE)

	var/force = FALSE
	if(!C.previous_turf || (C.previous_turf.z != posobj.z))
		C.previous_turf = posobj
		force = TRUE

	//Doing it this way prevents parallax layers from "jumping" when you change Z-Levels.
	var/offset_x = posobj.x - C.previous_turf.x
	var/offset_y = posobj.y - C.previous_turf.y

	if(!offset_x && !offset_y && !force)
		return

	var/glide_rate = round(world.icon_size / mymob.glide_size * world.tick_lag, world.tick_lag)
	C.previous_turf = posobj

	var/largest_change = max(abs(offset_x), abs(offset_y))
	var/max_allowed_dist = (glide_rate / world.tick_lag) + 1
	// If we aren't already moving/don't allow parallax, have made some movement, and that movement was smaller then our "glide" size, animate
	var/run_parralax = (C.do_parallax_animations && glide_rate && !areaobj.parallax_movedir && C.dont_animate_parallax <= world.time && largest_change <= max_allowed_dist)

	for(var/atom/movable/screen/parallax_layer/parallax_layer as anything in C.parallax_layers)
		var/our_speed = parallax_layer.speed
		var/change_x
		var/change_y
		if(parallax_layer.absolute)
			// We use change here so the typically large absolute objects (just lavaland for now) don't jitter so much
			change_x = (posobj.x - SSparallax.planet_x_offset) * our_speed + parallax_layer.offset_x
			change_y = (posobj.y - SSparallax.planet_y_offset) * our_speed + parallax_layer.offset_y
		else
			change_x = offset_x * our_speed
			change_y = offset_y * our_speed

			// This is how we tile parralax sprites
			// It doesn't use change because we really don't want to animate this
			if(parallax_layer.offset_x - change_x > 240)
				parallax_layer.offset_x -= 480
			else if(parallax_layer.offset_x - change_x < -240)
				parallax_layer.offset_x += 480
			if(parallax_layer.offset_y - change_y > 240)
				parallax_layer.offset_y -= 480
			else if(parallax_layer.offset_y - change_y < -240)
				parallax_layer.offset_y += 480

		if(parallax_layer.smooth_movement && !areaobj.parallax_movedir && (offset_x || offset_y))
			parallax_layer.transform = matrix(1, 0, offset_x*parallax_layer.speed, 0, 1, offset_y*parallax_layer.speed)
			animate(parallax_layer, transform=matrix(), time = SSparallax.wait, flags = ANIMATION_PARALLEL)

		// Now that we have our offsets, let's do our positioning
		parallax_layer.offset_x -= change_x
		parallax_layer.offset_y -= change_y

		parallax_layer.screen_loc = "CENTER-7:[round(parallax_layer.offset_x, 1)],CENTER-7:[round(parallax_layer.offset_y, 1)]"

		// We're going to use a transform to "glide" that last movement out, so it looks nicer
		// Don't do any animates if we're not actually moving enough distance yeah? thanks lad
		if(run_parralax && (largest_change * our_speed > 1))
			parallax_layer.transform = matrix(1,0,change_x, 0,1,change_y)
			animate(parallax_layer, transform=matrix(), time = glide_rate)

/atom/movable/proc/update_parallax_contents()
	for(var/mob/client_mob as anything in client_mobs_in_contents)
		if(length(client_mob?.client?.parallax_layers) && client_mob.hud_used)
			client_mob.hud_used.update_parallax()

/mob/proc/update_parallax_teleport()	//used for arrivals shuttle
	if(client && client.eye && hud_used && length(client.parallax_layers))
		var/area/areaobj = get_area(client.eye)
		hud_used.set_parallax_movedir(areaobj.parallax_movedir, TRUE)

// We need parallax to always pass its args down into initialize, so we immediate init it
INITIALIZE_IMMEDIATE(/atom/movable/screen/parallax_layer)

/atom/movable/screen/parallax_layer
	icon = 'icons/effects/parallax.dmi'
	var/speed = 1
	var/offset_x = 0
	var/offset_y = 0
	var/view_sized
	var/absolute = FALSE
	var/smooth_movement = FALSE
	blend_mode = BLEND_ADD
	plane = PLANE_SPACE_PARALLAX
	screen_loc = "CENTER-7,CENTER-7"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/parallax_layer/Initialize(mapload, mob/owner)
	. = ..()
	var/client/boss = owner?.client
	if(!boss) // If this typepath all starts to harddel your culprit is likely this
		return INITIALIZE_HINT_QDEL

	// I do not want to know bestie
	var/view = boss.view || world.view
	update_o(view)
	RegisterSignal(boss, COMSIG_VIEW_SET, .proc/on_view_change)

/atom/movable/screen/parallax_layer/proc/on_view_change(datum/source, new_size)
	SIGNAL_HANDLER
	update_o(new_size)

/atom/movable/screen/parallax_layer/proc/update_o(view)
	if (!view)
		view = world.view

	var/static/parallax_scaler = world.icon_size / 480

	// Turn the view size into a grid of correctly scaled overlays

	var/list/viewscales = getviewsize(view)
	var/countx = CEILING((viewscales[1] / 2) * parallax_scaler, 1) + 1
	var/county = CEILING((viewscales[2] / 2) * parallax_scaler, 1) + 1
	var/list/new_overlays = new
	for(var/x in -countx to countx)
		for(var/y in -county to county)
			if(x == 0 && y == 0)
				continue
			var/mutable_appearance/texture_overlay = mutable_appearance(icon, icon_state)
			texture_overlay.transform = matrix(1, 0, x*480, 0, 1, y*480)
			new_overlays += texture_overlay
	cut_overlays()
	add_overlay(new_overlays)
	view_sized = view

/atom/movable/screen/parallax_layer/layer_1
	icon_state = "layer1"
	speed = 0.6
	layer = 1

/atom/movable/screen/parallax_layer/layer_2
	icon_state = "layer2"
	speed = 1
	layer = 2

/atom/movable/screen/parallax_layer/layer_3
	icon_state = "layer3"
	speed = 1.4
	layer = 3

/atom/movable/screen/parallax_layer/random
	blend_mode = BLEND_OVERLAY
	speed = 2.6
	layer = 3

/atom/movable/screen/parallax_layer/random/space_gas
	icon_state = "random_layer1"

/atom/movable/screen/parallax_layer/random/space_gas/Initialize(mapload, mob/owner)
	src.add_atom_colour(SSparallax.random_parallax_color, ADMIN_COLOUR_PRIORITY)

/atom/movable/screen/parallax_layer/random/asteroids
	icon_state = "random_layer2"
	smooth_movement = TRUE

/atom/movable/screen/parallax_layer/planet
	icon_state = "planet"
	blend_mode = BLEND_OVERLAY
	absolute = TRUE //Status of seperation
	speed = 3
	layer = 30
	smooth_movement = TRUE

/atom/movable/screen/parallax_layer/planet/Initialize(mapload, mob/owner)
	. = ..()
	if(!owner?.client)
		return
	var/static/list/connections = list(
		COMSIG_MOVABLE_Z_CHANGED = .proc/on_z_change,
		COMSIG_MOB_LOGOUT = .proc/on_mob_logout,
	)
	AddComponent(/datum/component/connect_mob_behalf, owner.client, connections)
	on_z_change(owner)

/atom/movable/screen/parallax_layer/planet/proc/on_mob_logout(mob/source)
	SIGNAL_HANDLER
	var/client/boss = source.canon_client
	on_z_change(boss.mob)

/atom/movable/screen/parallax_layer/planet/proc/on_z_change(mob/source)
	SIGNAL_HANDLER
	var/client/boss = source.client
	var/turf/posobj = get_turf(boss?.eye)
	if(!posobj)
		return
	invisibility = is_station_level(posobj.z) ? 0 : INVISIBILITY_ABSTRACT

/atom/movable/screen/parallax_layer/planet/update_o()
	return //Shit wont move
