
//generic (by snowflake) tile smoothing code; smooth your icons with this!
/*
	Each tile is divided in 4 corners, each corner has an appearance associated to it; the tile is then overlayed by these 4 appearances
	To use this, just set your atom's 'smoothing_flags' var to 1. If your atom can be moved/unanchored, set its 'can_be_unanchored' var to 1.
	If you don't want your atom's icon to smooth with anything but atoms of the same type, set the list 'canSmoothWith' to null;
	Otherwise, put all the smoothing groups you want the atom icon to smooth with in 'canSmoothWith', including the group of the atom itself.
	Smoothing groups are just shared flags between objects. If one of the 'canSmoothWith' of A matches one of the `smoothing_groups` of B, then A will smooth with B.

	Each atom has its own icon file with all the possible corner states. See 'smooth_wall.dmi' for a template.

	DIAGONAL SMOOTHING INSTRUCTIONS
	To make your atom smooth diagonally you need all the proper icon states (see 'smooth_wall.dmi' for a template) and
	to add the 'SMOOTH_DIAGONAL_CORNERS' flag to the atom's smoothing_flags var (in addition to either SMOOTH_TRUE or SMOOTH_MORE).

	For turfs, what appears under the diagonal corners depends on the turf that was in the same position previously: if you make a wall on
	a plating floor, you will see plating under the diagonal wall corner, if it was space, you will see space.

	If you wish to map a diagonal wall corner with a fixed underlay, you must configure the turf's 'fixed_underlay' list var, like so:
		fixed_underlay = list("icon"='icon_file.dmi', "icon_state"="iconstatename")
	A non null 'fixed_underlay' list var will skip copying the previous turf appearance and always use the list. If the list is
	not set properly, the underlay will default to regular floor plating.

	To see an example of a diagonal wall, see '/turf/closed/wall/mineral/titanium' and its subtypes.
*/

//Redefinitions of the diagonal directions so they can be stored in one var without conflicts
#define NORTH_JUNCTION		NORTH //(1<<0)
#define SOUTH_JUNCTION		SOUTH //(1<<1)
#define EAST_JUNCTION		EAST  //(1<<2)
#define WEST_JUNCTION		WEST  //(1<<3)
#define NORTHEAST_JUNCTION	(1<<4)
#define SOUTHEAST_JUNCTION	(1<<5)
#define SOUTHWEST_JUNCTION	(1<<6)
#define NORTHWEST_JUNCTION	(1<<7)

DEFINE_BITFIELD(smoothing_junction, list(
	"NORTH_JUNCTION" = NORTH_JUNCTION,
	"SOUTH_JUNCTION" = SOUTH_JUNCTION,
	"EAST_JUNCTION" = EAST_JUNCTION,
	"WEST_JUNCTION" = WEST_JUNCTION,
	"NORTHEAST_JUNCTION" = NORTHEAST_JUNCTION,
	"SOUTHEAST_JUNCTION" = SOUTHEAST_JUNCTION,
	"SOUTHWEST_JUNCTION" = SOUTHWEST_JUNCTION,
	"NORTHWEST_JUNCTION" = NORTHWEST_JUNCTION,
))


#define NO_ADJ_FOUND 0
#define ADJ_FOUND 1
#define NULLTURF_BORDER 2
#define DEFAULT_UNDERLAY_ICON 			'icons/turf/floors.dmi'
#define DEFAULT_UNDERLAY_ICON_STATE 	"plating"


///Scans all adjacent turfs to find targets to smooth with.
/atom/proc/calculate_adjacencies()
	. = NONE

	if(!loc)
		return

	for(var/direction in GLOB.cardinals)
		switch(find_type_in_direction(direction))
			if(NULLTURF_BORDER)
				if((smoothing_flags & SMOOTH_BORDER))
					. |= direction //BYOND and smooth dirs are the same for cardinals
			if(ADJ_FOUND)
				. |= direction //BYOND and smooth dirs are the same for cardinals

	if(. & NORTH_JUNCTION)
		if(. & WEST_JUNCTION)
			switch(find_type_in_direction(NORTHWEST))
				if(NULLTURF_BORDER)
					if((smoothing_flags & SMOOTH_BORDER))
						. |= NORTHWEST_JUNCTION
				if(ADJ_FOUND)
					. |= NORTHWEST_JUNCTION

		if(. & EAST_JUNCTION)
			switch(find_type_in_direction(NORTHEAST))
				if(NULLTURF_BORDER)
					if((smoothing_flags & SMOOTH_BORDER))
						. |= NORTHEAST_JUNCTION
				if(ADJ_FOUND)
					. |= NORTHEAST_JUNCTION

	if(. & SOUTH_JUNCTION)
		if(. & WEST_JUNCTION)
			switch(find_type_in_direction(SOUTHWEST))
				if(NULLTURF_BORDER)
					if((smoothing_flags & SMOOTH_BORDER))
						. |= SOUTHWEST_JUNCTION
				if(ADJ_FOUND)
					. |= SOUTHWEST_JUNCTION

		if(. & EAST_JUNCTION)
			switch(find_type_in_direction(SOUTHEAST))
				if(NULLTURF_BORDER)
					if((smoothing_flags & SMOOTH_BORDER))
						. |= SOUTHEAST_JUNCTION
				if(ADJ_FOUND)
					. |= SOUTHEAST_JUNCTION

/atom/movable/calculate_adjacencies()
	if(can_be_unanchored && !anchored)
		return NONE
	return ..()


//do not use, use QUEUE_SMOOTH(atom)
/atom/proc/smooth_icon()
	smoothing_flags &= ~SMOOTH_QUEUED
	if(!z) //nullspace are not sending their best
		CRASH("[type] called smooth_icon() without being on a z-level")
		// * NOTE: it can throw runtime if the atom is abstract type in nullspace, but somehow it called 'smmoth_icon()' due to smoothing vars.
		// In this case, you need to nullify values of smoothing_flags and related list vars.
	if(smoothing_flags & SMOOTH_CORNERS)
		if(smoothing_flags & SMOOTH_DIAGONAL_CORNERS)
			corners_diagonal_smooth(calculate_adjacencies())
		else
			corners_cardinal_smooth(src, calculate_adjacencies())
	else if(smoothing_flags & SMOOTH_BITMASK)
		bitmask_smooth()
	else
		CRASH("smooth_icon called for [src] with smoothing_flags == [smoothing_flags]")

/atom/proc/corners_diagonal_smooth(adjacencies)
	switch(adjacencies)
		if(NORTH_JUNCTION|WEST_JUNCTION)
			replace_smooth_overlays("d-se","d-se-0")
		if(NORTH_JUNCTION|EAST_JUNCTION)
			replace_smooth_overlays("d-sw","d-sw-0")
		if(SOUTH_JUNCTION|WEST_JUNCTION)
			replace_smooth_overlays("d-ne","d-ne-0")
		if(SOUTH_JUNCTION|EAST_JUNCTION)
			replace_smooth_overlays("d-nw","d-nw-0")

		if(NORTH_JUNCTION|WEST_JUNCTION|NORTHWEST_JUNCTION)
			replace_smooth_overlays("d-se","d-se-1")
		if(NORTH_JUNCTION|EAST_JUNCTION|NORTHEAST_JUNCTION)
			replace_smooth_overlays("d-sw","d-sw-1")
		if(SOUTH_JUNCTION|WEST_JUNCTION|SOUTHWEST_JUNCTION)
			replace_smooth_overlays("d-ne","d-ne-1")
		if(SOUTH_JUNCTION|EAST_JUNCTION|SOUTHEAST_JUNCTION)
			replace_smooth_overlays("d-nw","d-nw-1")

		else
			corners_cardinal_smooth(src, adjacencies)
			return

	icon_state = ""
	return adjacencies

// diagonal_smooth to corners_cardinal_smooth
/atom/proc/corners_cardinal_smooth(atom/A, adjacencies)
	//NW CORNER
	var/nw = "1-i"
	if((adjacencies & NORTH_JUNCTION) && (adjacencies & WEST_JUNCTION))
		if(adjacencies & NORTHWEST_JUNCTION)
			nw = "1-f"
		else
			nw = "1-nw"
	else
		if(adjacencies & NORTH_JUNCTION)
			nw = "1-n"
		else if(adjacencies & WEST_JUNCTION)
			nw = "1-w"

	//NE CORNER
	var/ne = "2-i"
	if((adjacencies & NORTH_JUNCTION) && (adjacencies & EAST_JUNCTION))
		if(adjacencies & NORTHEAST_JUNCTION)
			ne = "2-f"
		else
			ne = "2-ne"
	else
		if(adjacencies & NORTH_JUNCTION)
			ne = "2-n"
		else if(adjacencies & EAST_JUNCTION)
			ne = "2-e"

	//SW CORNER
	var/sw = "3-i"
	if((adjacencies & SOUTH_JUNCTION) && (adjacencies & WEST_JUNCTION))
		if(adjacencies & SOUTHWEST_JUNCTION)
			sw = "3-f"
		else
			sw = "3-sw"
	else
		if(adjacencies & SOUTH_JUNCTION)
			sw = "3-s"
		else if(adjacencies & WEST_JUNCTION)
			sw = "3-w"

	//SE CORNER
	var/se = "4-i"
	if((adjacencies & SOUTH_JUNCTION) && (adjacencies & EAST_JUNCTION))
		if(adjacencies & SOUTHEAST_JUNCTION)
			se = "4-f"
		else
			se = "4-se"
	else
		if(adjacencies & SOUTH_JUNCTION)
			se = "4-s"
		else if(adjacencies & EAST_JUNCTION)
			se = "4-e"

	var/list/new_overlays = list()

	if(A.top_left_corner != nw)
		A.cut_overlay(top_left_corner)
		A.top_left_corner = nw
		new_overlays += nw

	if(A.top_right_corner != ne)
		A.cut_overlay(top_right_corner)
		A.top_right_corner = ne
		new_overlays += ne

	if(A.bottom_right_corner != sw)
		A.cut_overlay(bottom_right_corner)
		A.bottom_right_corner = sw
		new_overlays += sw

	if(A.bottom_left_corner != se)
		A.cut_overlay(bottom_left_corner)
		A.bottom_left_corner = se
		new_overlays += se

	if(new_overlays.len)
		A.add_overlay(new_overlays)


///Scans direction to find targets to smooth with.
/atom/proc/find_type_in_direction(direction)
	var/turf/target_turf = get_step(src, direction)
	if(!target_turf)
		return NULLTURF_BORDER

	var/area/target_area = get_area(target_turf)
	var/area/source_area = get_area(src)
	if((source_area.area_limited_icon_smoothing && !istype(target_area, source_area.area_limited_icon_smoothing)) || (target_area.area_limited_icon_smoothing && !istype(source_area, target_area.area_limited_icon_smoothing)))
		return NO_ADJ_FOUND

	var/atom/match //Used later in a special check

	if(isnull(canSmoothWith)) //special case in which it will only smooth with itself
		if(isturf(src))
			match = (type == target_turf.type) ? target_turf : null
		else
			var/atom/matching_obj = locate(type) in target_turf
			match = (matching_obj && matching_obj.type == type) ? matching_obj : null

	if(isnull(match) && !isnull(target_turf.smoothing_groups))
		for(var/target in canSmoothWith)
			if(canSmoothWith[target] & target_turf.smoothing_groups[target])
				match = target_turf

	if(isnull(match) && smoothing_flags & SMOOTH_OBJ)
		for(var/am in target_turf)
			var/atom/movable/thing = am
			if(!thing.anchored || isnull(thing.smoothing_groups))
				continue
			for(var/target in canSmoothWith)
				if(canSmoothWith[target] & thing.smoothing_groups[target])
					match = thing

	if(isnull(match))
		return NO_ADJ_FOUND
	. = ADJ_FOUND

	if(smoothing_flags & SMOOTH_DIRECTIONAL)
		if(match.dir != dir)
			return NO_ADJ_FOUND

/**
  * Basic smoothing proc. The atom checks for adjacent directions to smooth with and changes the icon_state based on that.
  *
  * Returns the previous smoothing_junction state so the previous state can be compared with the new one after the proc ends, and see the changes, if any.
  *
*/
/atom/proc/bitmask_smooth()
	var/new_junction = NONE

	// cache for sanic speed
	var/canSmoothWith = src.canSmoothWith

	var/smooth_border = (smoothing_flags & SMOOTH_BORDER)
	var/smooth_obj = (smoothing_flags & SMOOTH_OBJ)
	var/smooth_directional = (smoothing_flags & SMOOTH_DIRECTIONAL)
	var/skip_corners = (smoothing_flags & SMOOTH_BITMASK_SKIP_CORNERS)

	#define EXTRA_CHECKS(atom) \
		if(smooth_directional) { \
			if(atom.dir != dir) { \
				break set_adj_in_dir; \
			}; \
		}; \

	#define SET_ADJ_IN_DIR(direction, direction_flag) \
		set_adj_in_dir: { \
			do { \
				var/turf/neighbor = get_step(src, direction); \
				if(neighbor) { \
					var/neighbor_smoothing_groups = neighbor.smoothing_groups; \
					if(neighbor_smoothing_groups) { \
						for(var/target in canSmoothWith) { \
							if(canSmoothWith[target] & neighbor_smoothing_groups[target]) { \
								EXTRA_CHECKS(neighbor); \
								new_junction |= direction_flag; \
								break set_adj_in_dir; \
							}; \
						}; \
					}; \
					if(smooth_obj) { \
						for(var/atom/movable/thing as anything in neighbor) { \
							var/thing_smoothing_groups = thing.smoothing_groups; \
							if(!thing.anchored || isnull(thing_smoothing_groups)) { \
								continue; \
							}; \
							for(var/target in canSmoothWith) { \
								if(canSmoothWith[target] & thing_smoothing_groups[target]) { \
									EXTRA_CHECKS(thing); \
									new_junction |= direction_flag; \
									break set_adj_in_dir; \
								}; \
							}; \
						}; \
					}; \
				} else if (smooth_border) { \
					new_junction |= direction_flag; \
				}; \
			} while(FALSE) \
		}

	for(var/direction in GLOB.cardinals) //Cardinal case first.
		SET_ADJ_IN_DIR(direction, direction)

	if(skip_corners || !(new_junction & (NORTH|SOUTH)) || !(new_junction & (EAST|WEST)))
		set_smoothed_icon_state(new_junction)
		return

	if(new_junction & NORTH_JUNCTION)
		if(new_junction & WEST_JUNCTION)
			SET_ADJ_IN_DIR(NORTHWEST, NORTHWEST_JUNCTION)

		if(new_junction & EAST_JUNCTION)
			SET_ADJ_IN_DIR(NORTHEAST, NORTHEAST_JUNCTION)

	if(new_junction & SOUTH_JUNCTION)
		if(new_junction & WEST_JUNCTION)
			SET_ADJ_IN_DIR(SOUTHWEST, SOUTHWEST_JUNCTION)

		if(new_junction & EAST_JUNCTION)
			SET_ADJ_IN_DIR(SOUTHEAST, SOUTHEAST_JUNCTION)

	set_smoothed_icon_state(new_junction)

	#undef SET_ADJ_IN_DIR
	#undef EXTRA_CHECKS

///Changes the icon state based on the new junction bitmask. Returns the old junction value.
/atom/proc/set_smoothed_icon_state(new_junction)
	. = smoothing_junction
	smoothing_junction = new_junction
	icon_state = "[base_icon_state]-[smoothing_junction]"


/turf/closed/set_smoothed_icon_state(new_junction)
	// Avoid calling ..() here to avoid setting icon_state twice, which is expensive given how hot this proc is
	. = smoothing_junction
	smoothing_junction = new_junction

	if (!(smoothing_flags & SMOOTH_DIAGONAL_CORNERS))
		icon_state = "[base_icon_state]-[smoothing_junction]"
		return .

	switch(new_junction)
		if(
			NORTH_JUNCTION|WEST_JUNCTION,
			NORTH_JUNCTION|EAST_JUNCTION,
			SOUTH_JUNCTION|WEST_JUNCTION,
			SOUTH_JUNCTION|EAST_JUNCTION,
			NORTH_JUNCTION|WEST_JUNCTION|NORTHWEST_JUNCTION,
			NORTH_JUNCTION|EAST_JUNCTION|NORTHEAST_JUNCTION,
			SOUTH_JUNCTION|WEST_JUNCTION|SOUTHWEST_JUNCTION,
			SOUTH_JUNCTION|EAST_JUNCTION|SOUTHEAST_JUNCTION,
		)
			icon_state = "[base_icon_state]-[smoothing_junction]-d"
			if(new_junction == . || fixed_underlay) // Mutable underlays?
				return .

			var/junction_dir = reverse_ndir(smoothing_junction)
			var/turned_adjacency = REVERSE_DIR(junction_dir)
			var/turf/neighbor_turf = get_step(src, turned_adjacency & (NORTH|SOUTH))
			var/mutable_appearance/underlay_appearance = mutable_appearance(layer = TURF_LAYER, plane = FLOOR_PLANE)
			if(!neighbor_turf.get_smooth_underlay_icon(underlay_appearance, src, turned_adjacency))
				neighbor_turf = get_step(src, turned_adjacency & (EAST|WEST))

				if(!neighbor_turf.get_smooth_underlay_icon(underlay_appearance, src, turned_adjacency))
					neighbor_turf = get_step(src, turned_adjacency)

					if(!neighbor_turf.get_smooth_underlay_icon(underlay_appearance, src, turned_adjacency))
						if(!get_smooth_underlay_icon(underlay_appearance, src, turned_adjacency)) //if all else fails, ask our own turf
							underlay_appearance.icon = DEFAULT_UNDERLAY_ICON
							underlay_appearance.icon_state = DEFAULT_UNDERLAY_ICON_STATE
			underlays += underlay_appearance
		else
			icon_state = "[base_icon_state]-[smoothing_junction]"

/turf/open/floor/set_smoothed_icon_state(new_junction)
	if(broken || burnt)
		return
	return ..()

//Icon smoothing helpers
/proc/smooth_zlevel(zlevel, now = FALSE)
	var/list/away_turfs = block(locate(1, 1, zlevel), locate(world.maxx, world.maxy, zlevel))
	for(var/V in away_turfs)
		var/turf/T = V
		if(T.smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
			if(now)
				T.smooth_icon()
			else
				QUEUE_SMOOTH(T)
		for(var/R in T)
			var/atom/A = R
			if(A.smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
				if(now)
					A.smooth_icon()
				else
					QUEUE_SMOOTH(A)


/atom/proc/clear_smooth_overlays()
	cut_overlay(top_left_corner)
	top_left_corner = null
	cut_overlay(top_right_corner)
	top_right_corner = null
	cut_overlay(bottom_right_corner)
	bottom_right_corner = null
	cut_overlay(bottom_left_corner)
	bottom_left_corner = null


/atom/proc/replace_smooth_overlays(nw, ne, sw, se)
	clear_smooth_overlays()
	var/list/O = list()
	top_left_corner = nw
	O += nw
	top_right_corner = ne
	O += ne
	bottom_left_corner = sw
	O += sw
	bottom_right_corner = se
	O += se
	add_overlay(O)


/proc/reverse_ndir(ndir)
	switch(ndir)
		if(NORTH_JUNCTION)
			return NORTH
		if(SOUTH_JUNCTION)
			return SOUTH
		if(WEST_JUNCTION)
			return WEST
		if(EAST_JUNCTION)
			return EAST
		if(NORTHWEST_JUNCTION)
			return NORTHWEST
		if(NORTHEAST_JUNCTION)
			return NORTHEAST
		if(SOUTHEAST_JUNCTION)
			return SOUTHEAST
		if(SOUTHWEST_JUNCTION)
			return SOUTHWEST
		if(NORTH_JUNCTION | WEST_JUNCTION)
			return NORTHWEST
		if(NORTH_JUNCTION | EAST_JUNCTION)
			return NORTHEAST
		if(SOUTH_JUNCTION | WEST_JUNCTION)
			return SOUTHWEST
		if(SOUTH_JUNCTION | EAST_JUNCTION)
			return SOUTHEAST
		if(NORTH_JUNCTION | WEST_JUNCTION | NORTHWEST_JUNCTION)
			return NORTHWEST
		if(NORTH_JUNCTION | EAST_JUNCTION | NORTHEAST_JUNCTION)
			return NORTHEAST
		if(SOUTH_JUNCTION | WEST_JUNCTION | SOUTHWEST_JUNCTION)
			return SOUTHWEST
		if(SOUTH_JUNCTION | EAST_JUNCTION | SOUTHEAST_JUNCTION)
			return SOUTHEAST
		else
			return NONE

//Example smooth wall
/turf/closed/wall/smooth
	name = "smooth wall"
	icon = 'icons/turf/smooth_wall.dmi'
	icon_state = "smooth"
	smoothing_flags = SMOOTH_CORNERS|SMOOTH_DIAGONAL_CORNERS|SMOOTH_BORDER
	smoothing_groups = null
	canSmoothWith = null

#undef NORTH_JUNCTION
#undef SOUTH_JUNCTION
#undef EAST_JUNCTION
#undef WEST_JUNCTION
#undef NORTHEAST_JUNCTION
#undef NORTHWEST_JUNCTION
#undef SOUTHEAST_JUNCTION
#undef SOUTHWEST_JUNCTION

#undef NO_ADJ_FOUND
#undef ADJ_FOUND
#undef NULLTURF_BORDER

#undef DEFAULT_UNDERLAY_ICON
#undef DEFAULT_UNDERLAY_ICON_STATE



// These are subtypes of some smoothing objects.
// This is used to identify if there's any artefact in your smoothing sprites in practice.
/turf/closed/wall/debug
	name = "Sprite smoothing debugging walls"
	var/static/list/family = list()

/turf/closed/wall/debug/Initialize(mapload)
	. = ..()
	family += src

/turf/closed/wall/debug/Destroy()
	. = ..()
	family -= src

/turf/closed/wall/debug/attack_hand(mob/user, list/modifiers)
	. = ..()
	sprite_smooth_debug(user, family, src.parent_type)

/obj/structure/table/debug
	name = "Sprite smoothing debugging table"
	var/static/list/family = list()

/obj/structure/table/debug/Initialize(mapload)
	. = ..()
	family += src

/obj/structure/table/debug/Destroy()
	. = ..()
	family -= src

/obj/structure/table/debug/attack_hand(mob/user, list/modifiers)
	. = ..()
	sprite_smooth_debug(user, family, src.parent_type)

/turf/open/floor/carpet/debug
	name = "Sprite smoothing debugging floor"
	var/static/list/family = list()

/turf/open/floor/carpet/debug/Initialize(mapload)
	. = ..()
	family += src

/turf/open/floor/carpet/debug/Destroy()
	. = ..()
	family -= src

/turf/open/floor/carpet/debug/attack_hand(mob/user, list/modifiers)
	. = ..()
	sprite_smooth_debug(user, family, /turf/open)

/proc/sprite_smooth_debug(mob/user, list/family, desired_subtypes)
	// we don't want to see types that don't have smoothing.
	var/static/list/filtered_list = list()
	if(!filtered_list[desired_subtypes])
		var/list/L = list()
		var/list/temp_list = make_types_fancy(typesof(desired_subtypes))
		for(var/each in temp_list)
			var/atom/A = temp_list[each]
			if(!initial(A.canSmoothWith) || !(initial(A.smoothing_flags) & SMOOTH_BITMASK) || findtext(initial(A.name), "Sprite smoothing debugging"))
				continue
			L[each] = A
		filtered_list[desired_subtypes] = L

	// actual code
	var/atom/target = pick_closest_path(desired_subtypes, filtered_list[desired_subtypes])
	if(!target)
		return

	target = new target(get_turf(locate(1,1,1)))
	target.invisibility = INVISIBILITY_ABSTRACT
	for(var/atom/each in family)
		if(QDELETED(each))
			continue
		each.icon = target.icon
		each.base_icon_state = target.base_icon_state
		each.smoothing_flags = target.smoothing_flags
		each.smoothing_groups = target.smoothing_groups.Copy()
		each.canSmoothWith = target.canSmoothWith.Copy()
	for(var/atom/each in family)
		each.bitmask_smooth()
	if(isturf(target))
		var/turf/T = target
		T.ScrapeAway()
	else
		qdel(target)
