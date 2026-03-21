/atom/movable/lighting_object
	name = ""

	anchored = TRUE

	icon = LIGHTING_ICON
	icon_state = "transparent"
	color = LIGHTING_BASE_MATRIX
	plane = LIGHTING_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_LIGHTING

	var/needs_update = FALSE
	var/turf/myturf
	var/mutable_appearance/additive_underlay

/atom/movable/lighting_object/Initialize(mapload)
	. = ..()
	remove_verb(verbs)
	atom_colours.Cut()

	myturf = loc
	if (myturf.lighting_object)
		qdel(myturf.lighting_object, force = TRUE)
	myturf.lighting_object = src

	additive_underlay = mutable_appearance(LIGHTING_ICON, "light", FLOAT_LAYER, LIGHTING_PLANE_ADDITIVE, 255, RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM)
	additive_underlay.blend_mode = BLEND_ADD

	needs_update = TRUE
	SSlighting.objects_queue += src

/atom/movable/lighting_object/Destroy(force)
	if (force)
		SSlighting.objects_queue -= src
		if (loc != myturf)
			var/turf/oldturf = get_turf(myturf)
			var/turf/newturf = get_turf(loc)
			stack_trace("A lighting object was qdeleted with a different loc then it is suppose to have ([COORD(oldturf)] -> [COORD(newturf)])")
		if (isturf(myturf))
			myturf.lighting_object = null
			myturf.underlays -= additive_underlay
		myturf = null

		return ..()

	else
		return QDEL_HINT_LETMELIVE

/atom/movable/lighting_object/proc/update()
#ifdef VISUALIZE_LIGHT_UPDATES
	myturf.add_atom_colour(COLOR_BLUE_LIGHT, ADMIN_COLOUR_PRIORITY)
	animate(myturf, 10, color = null)
	addtimer(CALLBACK(myturf, TYPE_PROC_REF(/atom, remove_atom_colour), ADMIN_COLOUR_PRIORITY, COLOR_BLUE_LIGHT), 10, TIMER_UNIQUE|TIMER_OVERRIDE)
#endif

	// To the future coder who sees this and thinks
	// "Why didn't he just use a loop?"
	// Well my man, it's because the loop performed like shit.
	// And there's no way to improve it because
	// without a loop you can make the list all at once which is the fastest you're gonna get.
	// Oh it's also shorter line wise.
	// Including with these comments.

	// See LIGHTING_CORNER_DIAGONAL in lighting_corner.dm for why these values are what they are.
	var/static/datum/lighting_corner/dummy/dummy_lighting_corner = new

	var/datum/lighting_corner/red_corner = myturf.lighting_corner_SW || dummy_lighting_corner
	var/datum/lighting_corner/green_corner = myturf.lighting_corner_SE || dummy_lighting_corner
	var/datum/lighting_corner/blue_corner = myturf.lighting_corner_NW || dummy_lighting_corner
	var/datum/lighting_corner/alpha_corner = myturf.lighting_corner_NE || dummy_lighting_corner

	var/max = max(red_corner.largest_color_luminosity, green_corner.largest_color_luminosity, blue_corner.largest_color_luminosity, alpha_corner.largest_color_luminosity)

	#if LIGHTING_SOFT_THRESHOLD != 0
	var/set_luminosity = max > LIGHTING_SOFT_THRESHOLD
	#else
	// Because of floating points�?, it won't even be a flat 0.
	// This number is mostly arbitrary.
	var/set_luminosity = max > 1e-6
	#endif

	if(red_corner.cache_r & green_corner.cache_r & blue_corner.cache_r & alpha_corner.cache_r && \
		(red_corner.cache_g + green_corner.cache_g + blue_corner.cache_g + alpha_corner.cache_g + \
		red_corner.cache_b + green_corner.cache_b + blue_corner.cache_b + alpha_corner.cache_b == 8))
		//anything that passes the first case is very likely to pass the second, and addition is a little faster in this case
		icon_state = "transparent"
		color = null
	else if(!set_luminosity)
		icon_state = "dark"
		color = null
	else
		icon_state = null
		color = list(
			red_corner.cache_r, red_corner.cache_g, red_corner.cache_b, 00,
			green_corner.cache_r, green_corner.cache_g, green_corner.cache_b, 00,
			blue_corner.cache_r, blue_corner.cache_g, blue_corner.cache_b, 00,
			alpha_corner.cache_r, alpha_corner.cache_g, alpha_corner.cache_b, 00,
			00, 00, 00, 01
		)

	if(red_corner.applying_additive || green_corner.applying_additive || blue_corner.applying_additive || alpha_corner.applying_additive)
		myturf.underlays -= additive_underlay
		additive_underlay.icon_state = "light"

		additive_underlay.color = list(
			red_corner.add_r, red_corner.add_g, red_corner.add_b, 00,
			green_corner.add_r, green_corner.add_g, green_corner.add_b, 00,
			blue_corner.add_r, blue_corner.add_g, blue_corner.add_b, 00,
			alpha_corner.add_r, alpha_corner.add_g, alpha_corner.add_b, 00,
			00, 00, 00, 01
		)

		myturf.underlays += additive_underlay
	else
		myturf.underlays -= additive_underlay

	// Use luminosity directly because we are the lighting object
	// and not the turf
	luminosity = set_luminosity

	if (myturf.above)
		if(myturf.above.shadower)
			myturf.above.shadower.copy_lighting(src, myturf.loc, myturf)
		else
			myturf.above.update_mimic()

// Variety of overrides so the overlays don't get affected by weird things.

/atom/movable/lighting_object/update_luminosity()
	return

/atom/movable/lighting_object/ex_act(severity)
	return 0

/atom/movable/lighting_object/singularity_act()
	return

/atom/movable/lighting_object/singularity_pull(obj/anomaly/singularity/singularity, current_size)
	return

/atom/movable/lighting_object/blob_act()
	return

/atom/movable/lighting_object/onTransitZ()
	return

/atom/movable/lighting_object/wash(clean_types)
	SHOULD_CALL_PARENT(FALSE)
	return

// Override here to prevent things accidentally moving around overlays.
/atom/movable/lighting_object/forceMove(atom/destination, no_tp=FALSE, harderforce = FALSE)
	if(harderforce)
		. = ..()
