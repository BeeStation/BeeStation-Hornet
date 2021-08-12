/*
 *
 * RTX: ON Shadow calculator by PowerfulBacon.
 *
 * Calcuates sharp shadows on objects and makes shadow objects look sexy.
 * This took more than just hours to make, it was painful but a lot of fun.
 *
 * Credits:
 *  - PowerfulBacon
 *
 */

//Lighting texture scales in world units (divide by 32)
//256 = 8,4,2
//1024 = 32,16,8
#define LIGHTING_SHADOW_TEX_SIZE 8

#define COORD_LIST_ADD(listtoadd, x, y) \
	if(islist(listtoadd["[x]"])) { \
		var/list/_L = listtoadd["[x]"]; \
		BINARY_INSERT_NUM(y, _L); \
	} else { \
		listtoadd["[x]"] = list(y);\
	}

#ifdef SHADOW_DEBUG
#define DEBUG_HIGHLIGHT(x, y, colour) \
	do { \
		var/turf/T = locate(x, y, 2); \
		if(T) { \
			T.color = colour; \
		}\
	} while (0)
//For debugging use when we want to know if a turf is being affected multiple
//#define DEBUG_HIGHLIGHT(x, y, colour) do{var/turf/T=locate(x,y,2);if(T){switch(T.color){if("#ff0000"){T.color = "#00ff00"}if("#00ff00"){T.color="#0000ff"}else{T.color="#ff0000"}}}}while(0)
#define DO_SOMETHING_IF_DEBUGGING_SHADOWS(something) something
#else
#define DEBUG_HIGHLIGHT(x, y, colour)
#define DO_SOMETHING_IF_DEBUGGING_SHADOWS(something)
#endif

/atom/movable/lighting_mask
	var/list/turf/affecting_turfs
	//Amount of times lighting was calculated on this object
	var/times_calculated = 0

	//The last world time shadows were calculated on this object.
	//Prevents more than 1 shadow being made per 1/10s of a second which stops fast moving objects such as ghosts creating lag.
	var/last_calculation_time = 0

	//Please dont change these
	var/calculated_position_x
	var/calculated_position_y

/atom/movable/lighting_mask/Destroy()
	//Make sure we werent destroyed in init
	if(!SSlighting.started)
		SSlighting.sources_that_need_updating -= src
	//Remove from affecting turfs
	if(affecting_turfs)
		for(var/turf/thing as() in affecting_turfs)
			var/area/A = thing.loc
			LAZYREMOVE(thing.lights_affecting, src)
			if(!LAZYLEN(thing.lights_affecting) && !LAZYLEN(thing.legacy_affecting_lights) && !A.base_lighting_alpha)
				thing.luminosity = FALSE
		affecting_turfs = null
	. = ..()

/atom/movable/lighting_mask/proc/link_turf_to_light(turf/T)
	LAZYOR(affecting_turfs, T)
	LAZYOR(T.lights_affecting, src)

/atom/movable/lighting_mask/proc/unlink_turf_from_light(turf/T)
	LAZYREMOVE(affecting_turfs, T)
	LAZYREMOVE(T.lights_affecting, src)

//Returns a list of matrices corresponding to the matrices that should be applied to triangles of
//coordinates (0,0),(1,0),(0,1) to create a triangcalculate_shadows_matricesle that respresents the shadows
//takes in the old turf to smoothly animate shadow movement
/atom/movable/lighting_mask/proc/light_mask_update(force = FALSE)

	var/start_time = TICK_USAGE

	//Check to make sure lighting is actually started
	//If not count the amount of duplicate requests created.
	if(!SSlighting.started)
		if(awaiting_update)
			SSlighting.duplicate_shadow_updates_in_init ++
			return
		SSlighting.sources_that_need_updating += src
		awaiting_update = TRUE
		return

	//BIIIIG lag stopper.
	if(!force)
		if(world.time <= last_calculation_time)
			SSlighting.queue_shadow_render(src)
			return

	last_calculation_time = world.time

	//Dont bother calculating at all for small shadows
	var/range = radius

	//Dont calculate when the source atom is in nullspace
	if(!attached_atom.loc)
		return

	//Incremement the global counter for shadow calculations
	SSlighting.total_shadow_calculations ++

	//Ceiling the range since we need it in integer form
	var/unrounded_range = range
	range = CEILING(unrounded_range, 1)
	DO_SOMETHING_IF_DEBUGGING_SHADOWS(var/timer = TICK_USAGE)

	//Work out our position
	//Calculate shadow origin offset
	var/invert_offsets = attached_atom.dir & (NORTH | EAST)
	var/left_or_right = attached_atom.dir & (EAST | WEST)
	var/offset_x = (left_or_right ? attached_atom.light_pixel_y : attached_atom.light_pixel_x) * (invert_offsets ? -1 : 1)
	var/offset_y = (left_or_right ? attached_atom.light_pixel_x : attached_atom.light_pixel_y) * (invert_offsets ? -1 : 1)

	//Get the origin poin's
	var/turf/our_turf = get_turf(attached_atom)	//The mask is in nullspace, so we need the source turf of the container
	var/ourx = our_turf.x
	var/oury = our_turf.y

	//Account for pixel shifting and light offset
	calculated_position_x = ourx + ((offset_x) / world.icon_size)
	calculated_position_y = oury + ((offset_y) / world.icon_size)

	//Optimise grouping by storing as
	// Key : x (AS A STRING BECAUSE BYOND DOESNT ALLOW FOR INT KEY DICTIONARIES)
	// Value: List(y values)
	var/list/opaque_atoms_in_view = list()

	//Reset the list
	if(islist(affecting_turfs))
		for(var/turf/T as() in affecting_turfs)
			LAZYREMOVE(T?.lights_affecting, src)
			//The turf is no longer affected by any lights, make it non-luminous.
			var/area/A = T.loc
			if(T?.luminosity && !LAZYLEN(T.lights_affecting) && !LAZYLEN(T.legacy_affecting_lights) && !A.base_lighting_alpha)
				T.luminosity = FALSE

	//Clear the list
	LAZYCLEARLIST(affecting_turfs)

	//Rebuild the list
	var/isClosedTurf = istype(our_turf, /turf/closed)
	for(var/turf/thing in dview(range, get_turf(attached_atom)))
		link_turf_to_light(thing)
		//The turf is now affected by our light, make it luminous
		if(!thing.luminosity)
			thing.luminosity = TRUE
		//Dont consider shadows about our turf.
		if(!isClosedTurf)
			if(thing == our_turf)
				continue
		if(thing.has_opaque_atom || thing.opacity)
			//At this point we no longer care about
			//the atom itself, only the position values
			COORD_LIST_ADD(opaque_atoms_in_view, thing.x, thing.y)
			DEBUG_HIGHLIGHT(thing.x, thing.y, "#0000FF")

	if(islist(SSlighting.total_calculations["[range]"]))
		SSlighting.total_calculations["[range]"] ++
		SSlighting.total_time_spent_processing["[range]"] += TICK_USAGE_TO_MS(start_time)
	else
		SSlighting.total_calculations["[range]"] = 1
		SSlighting.total_time_spent_processing["[range]"] = TICK_USAGE_TO_MS(start_time)

#undef LIGHTING_SHADOW_TEX_SIZE
#undef COORD_LIST_ADD
#undef DEBUG_HIGHLIGHT
#undef DO_SOMETHING_IF_DEBUGGING_SHADOWS
