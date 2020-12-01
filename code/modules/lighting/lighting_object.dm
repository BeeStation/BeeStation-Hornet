/*
 * The darkness of the world
 */

/atom/movable/lighting_darkness
	name          = "lighting darkness"

	anchored      = TRUE

	icon             = LIGHTING_ICON
	icon_state       = "dark"
	plane            = LIGHTING_PLANE
	//DEBUG: mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer            = LIGHTING_LAYER
	invisibility     = INVISIBILITY_LIGHTING

	var/needs_update = FALSE
	var/turf/myturf

/atom/movable/lighting_darkness/Initialize(mapload)
	. = ..()
	remove_verb(verbs)
	atom_colours.Cut()

	myturf = loc
	if (myturf.lighting_object)
		qdel(myturf.lighting_object, force = TRUE)
	myturf.lighting_object = src
	myturf.luminosity = 1

	needs_update = TRUE
	GLOB.lighting_update_objects += src

/atom/movable/lighting_darkness/Destroy(var/force)
	if (force)
		GLOB.lighting_update_objects     -= src
		if (loc != myturf)
			var/turf/oldturf = get_turf(myturf)
			var/turf/newturf = get_turf(loc)
			stack_trace("A lighting object was qdeleted with a different loc then it is suppose to have ([COORD(oldturf)] -> [COORD(newturf)])")
		if (isturf(myturf))
			myturf.lighting_object = null
			myturf.luminosity = 1
		myturf = null

		return ..()

	else
		return QDEL_HINT_LETMELIVE

/// TODO REMOVE
/atom/movable/lighting_darkness/proc/update()
	return

// Variety of overrides so the overlays don't get affected by weird things.

/atom/movable/lighting_darkness/ex_act(severity)
	return 0

/atom/movable/lighting_darkness/singularity_act()
	return

/atom/movable/lighting_darkness/singularity_pull()
	return

/atom/movable/lighting_darkness/blob_act()
	return

/atom/movable/lighting_darkness/onTransitZ()
	return

// Override here to prevent things accidentally moving around overlays.
/atom/movable/lighting_darkness/forceMove(atom/destination, var/no_tp=FALSE, var/harderforce = FALSE)
	if(harderforce)
		. = ..()
