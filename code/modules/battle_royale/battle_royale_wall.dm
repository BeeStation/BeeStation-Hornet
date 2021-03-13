//==================================
// WORLD BORDER
//==================================

/obj/effect/death_wall
	var/current_radius = 118
	var/turf/center_turf
	icon = 'icons/effects/fields.dmi'
	icon_state = "projectile_dampen_generic"

/obj/effect/death_wall/Crossed(atom/movable/AM, oldloc)
	. = ..()
	//lol u died
	if(isliving(AM))
		var/mob/living/M = AM
		M.gib()
		to_chat(M, "<span class='warning'>You left the zone!</span>")

/obj/effect/death_wall/Moved(atom/OldLoc, Dir)
	. = ..()
	for(var/mob/living/M in get_turf(src))
		M.gib()
		to_chat(M, "<span class='warning'>You left the zone!</span>")

/obj/effect/death_wall/proc/set_center(turf/center)
	center_turf = center

/obj/effect/death_wall/proc/decrease_size()
	var/minx = CLAMP(center_turf.x - current_radius, 1, 255)
	var/maxx = CLAMP(center_turf.x + current_radius, 1, 255)
	var/miny = CLAMP(center_turf.y - current_radius, 1, 255)
	var/maxy = CLAMP(center_turf.y + current_radius, 1, 255)
	if(y == maxy || y == miny)
		//We have nowhere to move to so are deleted
		if(x == minx || x == minx + 1 || x == maxx || x == maxx - 1)
			qdel(src)
			return
	//Where do we go to?
	var/top = y == maxy
	var/bottom = y == miny
	var/left = x == minx
	var/right = x == maxx
	if(left)
		forceMove(get_step(get_turf(src), EAST))
	else if(right)
		forceMove(get_step(get_turf(src), WEST))
	else if(bottom)
		forceMove(get_step(get_turf(src), NORTH))
	else if(top)
		forceMove(get_step(get_turf(src), SOUTH))
	current_radius--
