#define PARALLAX_SPEED_MOD 2 /// a constant value that makes parallax moving faster well
#define PARALLAX_IMAGE_SIZE 480 /// just image size of a parallax. standard value

/client
	/// currently using parallax layers
	var/list/parallax_layers
	var/list/parallax_layers_cached
	var/parallax_layers_max
	/// previous turf that your eye was at
	var/turf/previous_turf
	/// previous area where your previous turf was
	var/area/previous_area

	/// prevents running parallax animate() when it's animating something
	COOLDOWN_DECLARE(parallax_animate_cooldown)
	/// prevents running parallax animate() when shuttle is docking. Becomes FALSE after shuttle dock.
	var/parallax_is_shuttle_docking
	/// prevents running parallax animate() when shuttle is going to hyperspace Becomes FALSE after entering hyperspace (likely a few seconds)
	var/parallax_is_hyperspace
	/// caches values to keep the consistency between parallax animation procs, for what it should show to you.
	var/list/parallax_hyperspace_animation_info

/datum/hud/proc/create_parallax(mob/viewmob)
	var/mob/screenmob = viewmob || mymob
	var/client/C = screenmob.client
	if (!C)
		return
	apply_parallax_pref(viewmob)

	if(!length(C.parallax_layers_cached))
		C.parallax_layers_cached = list()
		C.parallax_layers_cached += new /atom/movable/screen/parallax_layer/multigrid/layer_1(null)
		C.parallax_layers_cached += new /atom/movable/screen/parallax_layer/multigrid/layer_2(null)
		C.parallax_layers_cached += new /atom/movable/screen/parallax_layer/planet(null)
		if(SSparallax.random_layer)
			C.parallax_layers_cached += new SSparallax.random_layer
		C.parallax_layers_cached += new /atom/movable/screen/parallax_layer/multigrid/layer_3(null)

	C.parallax_layers = C.parallax_layers_cached.Copy()

	if (length(C.parallax_layers) > C.parallax_layers_max)
		C.parallax_layers.len = C.parallax_layers_max

	C.screen |= (C.parallax_layers)
	var/atom/movable/screen/plane_master/PM = screenmob.hud_used.plane_masters["[PLANE_SPACE]"]
	if(PM)
		if(screenmob != mymob)
			C.screen -= locate(/atom/movable/screen/plane_master/parallax_white) in C.screen
			C.screen += PM
		PM.color = list(
			0, 0, 0, 0,
			0, 0, 0, 0,
			0, 0, 0, 0,
			1, 1, 1, 1,
			0, 0, 0, 0
			)

/datum/hud/proc/remove_parallax(mob/viewmob)
	var/mob/screenmob = viewmob || mymob
	var/client/C = screenmob.client
	C.screen -= (C.parallax_layers_cached)
	var/atom/movable/screen/plane_master/PM = screenmob.hud_used.plane_masters["[PLANE_SPACE]"]
	if(PM)
		if(screenmob != mymob)
			C.screen -= locate(/atom/movable/screen/plane_master/parallax_white) in C.screen
			C.screen += PM
		PM.color = initial(PM.color)
	C.parallax_layers = null

/datum/hud/proc/apply_parallax_pref(mob/viewmob)
	var/mob/screenmob = viewmob || mymob
	var/client/C = screenmob.client
	if(C.prefs)
		var/pref = C.prefs.read_player_preference(/datum/preference/choiced/parallax)
		switch(pref)
			if (PARALLAX_INSANE)
				C.parallax_layers_max = 999
			if (PARALLAX_HIGH)
				C.parallax_layers_max = 5
			if (PARALLAX_MED)
				C.parallax_layers_max = 3
			if (PARALLAX_LOW)
				C.parallax_layers_max = 1
			if (PARALLAX_DISABLE)
				C.parallax_layers_max = 0
			else
				C.parallax_layers_max = 5
	else
		C.parallax_layers_max = 5

/datum/hud/proc/update_parallax_pref(mob/viewmob)
	remove_parallax(viewmob)
	create_parallax(viewmob)
	update_parallax()

/// Called when a mob enters hyperspace, or they moves z level. This will show a smooth starting animation first, then calls update_parallax_hyperspace_consistent()
/datum/hud/proc/update_parallax_hyperspace(client/C, area/my_area, list/animation_info = null, force = FALSE)
	if(!C)
		return
	if(C.parallax_is_hyperspace && !force) // force is necessary when you move between shuttles
		return
	if(!my_area)
		my_area = get_area(C.eye)
	if(!my_area.parallax_movedir)
		C.parallax_is_hyperspace = FALSE
		return
	C.parallax_is_shuttle_docking = FALSE
	C.parallax_is_hyperspace = TRUE
	if(isnull(animation_info))
		if(C.parallax_hyperspace_animation_info)
			C.parallax_hyperspace_animation_info.Cut()
			C.parallax_hyperspace_animation_info = null
		animation_info = build_parallax_hyperspace_consistent_data(C, my_area.parallax_movedir)
	var/real_anim_time = PARALLAX_LOOP_TIME * 1.5 // this looks smooth based on 'easing = SINE_EASING | EASE_IN'
	for(var/atom/movable/screen/parallax_layer/para_layer as anything in animation_info)
		para_layer.transform = para_layer.flight_anim_preserve
		animate(para_layer, transform = animation_info[para_layer], time = real_anim_time, easing = SINE_EASING | EASE_IN, flags = ANIMATION_END_NOW)
		animate(transform = para_layer.flight_anim_preserve, time = 0)
	addtimer(CALLBACK(src, PROC_REF(update_parallax_hyperspace_consistent), C, my_area, animation_info), real_anim_time)
	C.parallax_hyperspace_animation_info = animation_info
	COOLDOWN_START(C, parallax_animate_cooldown, real_anim_time)

/// Followed by 'update_parallax_hyperspace()' proc, showing consistent animation as if your shuttle is forwarding
/datum/hud/proc/update_parallax_hyperspace_consistent(client/C, area/my_area, list/animation_info = null)
	if(!C)
		return
	if(C.parallax_is_shuttle_docking)
		return
	if(!my_area)
		my_area = get_area(C.eye)
	else
		var/area/current_area = get_area(C.eye)
		if(my_area != current_area && my_area.parallax_movedir != current_area.parallax_movedir) // this one is late to show
			return
	if(!my_area.parallax_movedir)
		update_parallax_hyperspace_exiting(C)
		C.parallax_is_hyperspace = FALSE
		return
	if(isnull(animation_info))
		if(C.parallax_hyperspace_animation_info)
			C.parallax_hyperspace_animation_info.Cut()
			C.parallax_hyperspace_animation_info = null
		animation_info = build_parallax_hyperspace_consistent_data(C, my_area.parallax_movedir)
	for(var/atom/movable/screen/parallax_layer/para_layer as anything in animation_info)
		para_layer.transform = para_layer.flight_anim_preserve
		animate(para_layer, transform = animation_info[para_layer], time = PARALLAX_LOOP_TIME, loop = -1, flags = ANIMATION_END_NOW)
		animate(transform = para_layer.flight_anim_preserve, time = 0)
	C.parallax_hyperspace_animation_info = animation_info

/// Called by shuttle docking code (find it yourself. it's somewhere). Used to show a smooth ending animation of parallaxes
/datum/hud/proc/update_parallax_hyperspace_exiting(client/C)
	if(!C)
		return
	if(C.parallax_is_shuttle_docking)
		return
	C.parallax_is_shuttle_docking = TRUE
	C.parallax_is_hyperspace = FALSE
	var/real_anim_time = PARALLAX_LOOP_TIME * 1.5 // this looks smooth based on 'easing = SINE_EASING | EASE_OUT'
	for(var/atom/movable/screen/parallax_layer/para_layer as anything in C.parallax_hyperspace_animation_info)
		para_layer.transform = para_layer.flight_anim_preserve
		animate(para_layer, transform = C.parallax_hyperspace_animation_info[para_layer], time = real_anim_time, easing = SINE_EASING | EASE_OUT, flags = ANIMATION_END_NOW)
	C.parallax_hyperspace_animation_info.Cut()
	C.parallax_hyperspace_animation_info = null
	COOLDOWN_START(C, parallax_animate_cooldown, real_anim_time)

/// Builds a list for each parallax on how it should animate parallaxes.
/datum/hud/proc/build_parallax_hyperspace_consistent_data(client/C, direction)
	var/list/animation_info = list()
	for(var/atom/movable/screen/parallax_layer/para_layer as anything in C.parallax_layers)
		if(para_layer.invisibility || !para_layer.use_hyperspace_animation)
			continue

		var/anim_x_offset = 0
		var/anim_y_offset = 0
		switch(direction)
			if(NORTH)
				anim_y_offset = -PARALLAX_IMAGE_SIZE * para_layer.layer_scale * PARALLAX_SPEED_MOD
			if(SOUTH)
				anim_y_offset = PARALLAX_IMAGE_SIZE * para_layer.layer_scale * PARALLAX_SPEED_MOD
			if(EAST)
				anim_x_offset = -PARALLAX_IMAGE_SIZE * para_layer.layer_scale * PARALLAX_SPEED_MOD
			if(WEST)
				anim_x_offset = PARALLAX_IMAGE_SIZE * para_layer.layer_scale * PARALLAX_SPEED_MOD
			else
				anim_y_offset = -PARALLAX_IMAGE_SIZE * para_layer.layer_scale * PARALLAX_SPEED_MOD
				stack_trace("direction value is wrong: [direction]")

		if(para_layer.animation_result)
			para_layer.transform = para_layer.animation_result
		para_layer.flight_anim_preserve = para_layer.transform

		var/matrix/anim_matrix = para_layer.transform.Translate(anim_x_offset, anim_y_offset)
		animation_info[para_layer] = anim_matrix

	return animation_info

/// a proc that is used always...
/datum/hud/proc/update_parallax(do_animate = TRUE)
	var/client/C = mymob.client
	if(!C)
		return
	// parallax animation is doing something. Skips.
	if(COOLDOWN_TIMELEFT(C, parallax_animate_cooldown))
		return
	var/turf/current_turf = get_turf(C.eye)
	if(!current_turf)
		return

/* ------------------------------------------------------------------------------- */
	// From this line, this proc mainly checks your z level to know if it should run a smooth moving parallax animation on hyperspace

	// check_z() proc will return TRUE if a parallax layer is added or gone
	// i.e.) planet parallax is only available on station level
	var/z_is_different
	if(C.previous_turf && (current_turf.z != C.previous_turf.z))
		for(var/atom/movable/screen/parallax_layer/para_layer as anything in C.parallax_layers)
			z_is_different += para_layer.check_z(current_turf, C.previous_turf)

	var/area/current_area = current_turf.loc
	// checks if movedir from two areas are different, and then shows moving parallax
	if(current_area.parallax_movedir)
		if(current_area != C.previous_area && C.previous_area.parallax_movedir != current_area.parallax_movedir)
			update_parallax_hyperspace(C, current_area, force = TRUE)

		C.previous_area = current_area
		return // as long as 'current_area.parallax_movedir' exists, don't update

	else
		C.parallax_is_hyperspace = FALSE

	if(C.previous_area && C.previous_area.parallax_movedir)
		do_animate = FALSE
	C.previous_area = current_area

/* ------------------------------------------------------------------------------- */
	// From this line, now this proc updates your parallax based on your movement

	// calculate diff value
	var/x_diff = 0
	var/y_diff = 0
	if(C.previous_turf)
		x_diff = (C.previous_turf.x - current_turf.x) * PARALLAX_SPEED_MOD
		y_diff = (C.previous_turf.y - current_turf.y) * PARALLAX_SPEED_MOD
		if(abs(x_diff) + abs(y_diff) > 100) // too fast
			do_animate = FALSE

	C.previous_turf = current_turf

	for(var/atom/movable/screen/parallax_layer/para_layer as anything in C.parallax_layers)
		if(para_layer.invisibility) // skip rendering
			continue

		if(para_layer.animation_result)
			para_layer.transform = para_layer.animation_result
			para_layer.animation_result = null

		if(z_is_different)
			if(para_layer.use_old_xy)
				var/old_x_diff = (para_layer.old_x - current_turf.x) * para_layer.layer_scale * PARALLAX_SPEED_MOD
				var/old_y_diff = (para_layer.old_y - current_turf.y) * para_layer.layer_scale * PARALLAX_SPEED_MOD
				para_layer.transform = para_layer.transform.Translate(old_x_diff, old_y_diff)
				para_layer.use_old_xy = FALSE
				animate(para_layer)
			else
				para_layer.transform = para_layer.transform.Translate(para_layer.layer_scale*x_diff, para_layer.layer_scale*y_diff)
				animate(para_layer)
		else
			if(do_animate)
				para_layer.animation_result = para_layer.transform.Translate(para_layer.layer_scale*x_diff, para_layer.layer_scale*y_diff)
				animate(para_layer, time = SSparallax.wait, transform = para_layer.animation_result)
			else
				para_layer.transform = para_layer.transform.Translate(para_layer.layer_scale*x_diff, para_layer.layer_scale*y_diff)
				animate(para_layer)

/*  < VERY IMPORTANT NOTE FOR PARALLAXE >
 *		Parallax is highly dependent on using 'transform'
 * 		If you use transform and matrix very well, it doesn't cause much load on rendering system
 * 		Old parallax code used 'screen_loc' to render it on correct location
 * 		But that's slow, and possibly won't render up to values given to 'screen_loc'
 * 		That's why this is highly dependent on using 'transform'
*/
/atom/movable/screen/parallax_layer
	icon = 'icons/effects/parallax.dmi'
	blend_mode = BLEND_ADD
	plane = PLANE_SPACE_PARALLAX
	screen_loc = "CENTER-7,CENTER-7"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	/// size and speed of the parallax. 0.5 means 50%. 480x480 will become 240x240, and matrix.Translate() will take 50% value of your movement distance.
	var/layer_scale = 1
	/// If TRUE, this parallax will do animate() to the direction of area/var/parallax_movedir
	var/use_hyperspace_animation = FALSE
	/// a holder value that is a result of animate() in update_parallax() proc
	var/matrix/animation_result
	/// same, but when you're at a shuttle
	var/matrix/flight_anim_preserve
	/// a flag variable which x,y values a parallax should use on update
	var/use_old_xy = TRUE // TRUE is necessary for client init
	var/old_x = 1 // necessary for client init
	var/old_y = 1 // necessary for client init
	// because a new client doesn't remember their old parallax...

/atom/movable/screen/parallax_layer/Initialize(mapload)
	. = ..()
	init_parallax()

/atom/movable/screen/parallax_layer/proc/init_parallax()
	animation_result = null // somehow it is too early injected
	transform = transform.Translate(PARALLAX_IMAGE_SIZE * layer_scale, 0)
	transform = transform.Scale(layer_scale)

/// checks if your new z level should be visible to your parallax image
/atom/movable/screen/parallax_layer/proc/check_z(turf/my_turf, turf/old_turf)
	if(invisibility) // do not merge the if condition
		if(is_allowed_z(my_turf.z))
			use_old_xy = TRUE
			invisibility = 0
			return TRUE
	else
		if(!is_allowed_z(my_turf.z))
			invisibility = INVISIBILITY_ABSTRACT
			old_x = old_turf.x
			old_y = old_turf.y
			return TRUE
	return FALSE

/// typically all parallaxes are allowed. this is specifically made for planet parallax
/atom/movable/screen/parallax_layer/proc/is_allowed_z(z)
	return z // if z isn't null or 0, it's okay

///
/atom/movable/screen/parallax_layer/multigrid
	// DO NOT USE THIS to multigrid subtypes. use 'grid_icon_state' instead
	// Reason: handling a main appearance of this atom individually aside from "overlays" is just tedious.
	// But also, 'transform = matrix()' should be essentially managed here
	icon_state = null
	/// true icon_state that we'll duplicate into 'overlays'
	var/grid_icon_state
	/// if TRUE, we'll flip and rotate to make it look less different for each round
	var/randomise_grid

	use_hyperspace_animation = TRUE

/atom/movable/screen/parallax_layer/multigrid/init_parallax(mapload)
	if(icon_state)
		stack_trace("multigrid parallax should use 'grid_icon_state' instead of 'icon_state'")
		grid_icon_state = icon_state
		icon_state = null
	if(isnull(grid_icon_state))
		CRASH("grid_icon_state doesn't exist.")
	if(length(overlays) > 5)
		stack_trace("something attempted to 'init_parallax' but overlays are all already set. Did you want to reset?")
		cut_overlays() // in case if you wanted to reset, okay...
		transform = matrix()
		animation_result = null

	if(SSparallax.multigrid_appearance_cache[type]) // we have this already
		add_overlay(SSparallax.multigrid_appearance_cache[type])

	else
		var/list/new_overlays = list()


		var/scale_x = 1
		var/scale_y = 1
		var/matrix_turn = 0
		if(randomise_grid) // obvious pattern is boring, right?
			switch(rand(1, 4))
				if(1)
					scale_x = -1
					scale_y = -1
				if(2)
					scale_x = 1
					scale_y = -1
				if(3)
					scale_x = -1
					scale_y = 1
				if(4)
					pass() // do nothing
			switch(rand(1, 4))
				if(1)
					matrix_turn = 90
				if(2)
					matrix_turn = 180
				if(3)
					matrix_turn = 270
				if(4)
					pass() // do nothing

		var/countx = 4
		var/county = 4
		for(var/x in -countx to countx) // I know this makes (4*2+1)^2 = 81 overlays, but I was lazy to calculate sane size for big scale parallax
			for(var/y in -county to county)
				var/image/texture_overlay = image(icon, null, grid_icon_state)
				texture_overlay.transform = texture_overlay.transform.Scale(scale_x, scale_y)
				texture_overlay.transform = texture_overlay.transform.Turn(matrix_turn)
				texture_overlay.transform = texture_overlay.transform.Translate(x * PARALLAX_IMAGE_SIZE, y * PARALLAX_IMAGE_SIZE)
				new_overlays += texture_overlay

		SSparallax.multigrid_appearance_cache[type] = new_overlays
		add_overlay(new_overlays)

		// and we rotate ourselves randomly!
		//SSparallax.multigrid_incline_cache[type] = rand(1,359)

	transform = transform.Turn(SSparallax.multigrid_incline_cache[type])
	..()

/atom/movable/screen/parallax_layer/multigrid/layer_1
	grid_icon_state = "layer1"
	layer_scale = 0.8
	layer = 1
	randomise_grid = TRUE

/atom/movable/screen/parallax_layer/multigrid/layer_2
	grid_icon_state = "layer2"
	layer_scale = 1
	layer = 2
	randomise_grid = TRUE

/atom/movable/screen/parallax_layer/multigrid/layer_3
	grid_icon_state = "layer3"
	layer_scale = 1.2
	layer = 2.8
	randomise_grid = TRUE

/atom/movable/screen/parallax_layer/multigrid/random
	blend_mode = BLEND_OVERLAY
	layer_scale = 1.4
	layer = 3
	randomise_grid = TRUE

/atom/movable/screen/parallax_layer/multigrid/random/space_gas
	grid_icon_state = "random_layer1"

/atom/movable/screen/parallax_layer/multigrid/random/space_gas/Initialize(mapload, view)
	. = ..()
	src.add_atom_colour(SSparallax.assign_random_parallax_colour(), ADMIN_COLOUR_PRIORITY)

/atom/movable/screen/parallax_layer/multigrid/random/asteroids
	grid_icon_state = "random_layer2"

/atom/movable/screen/parallax_layer/planet
	icon_state = "planet"
	blend_mode = BLEND_OVERLAY
	layer_scale = 3
	layer = 30

/atom/movable/screen/parallax_layer/planet/is_allowed_z(z_level)
	return is_station_level(z_level)

// same as parent, but don't use layer_scale to recalculate its location
/atom/movable/screen/parallax_layer/planet/init_parallax()
	animation_result = null // somehow it is too early injected
	transform = transform.Turn(SSparallax.planet_incline_offset)
	transform = transform.Translate(SSparallax.planet_x_offset,SSparallax.planet_y_offset)

#undef PARALLAX_SPEED_MOD
#undef PARALLAX_IMAGE_SIZE
