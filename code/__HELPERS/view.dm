/proc/getviewsize(view, extra_x = 0, extra_y = 0)
	var/viewX
	var/viewY
	if(IS_FINITE(view))
		var/totalviewrange = (view < 0 ? -1 : 1) + 2 * view
		viewX = totalviewrange + extra_x
		viewY = totalviewrange + extra_y
	else
		var/list/viewrangelist = splittext(view,"x")
		viewX = text2num(viewrangelist[1]) + extra_x
		viewY = text2num(viewrangelist[2]) + extra_y
	return list(viewX, viewY)

/proc/getexpandedview(view, extra_x = 0, extra_y = 0)
	var/list/output = getviewsize(view, extra_x, extra_y)
	return "[output[1]]x[output[2]]"

/proc/in_view_range(mob/user, atom/A)
	var/list/view_range = getviewsize(user.client.view)
	var/turf/source = get_turf(user)
	var/turf/target = get_turf(A)
	return ISINRANGE(target.x, source.x - view_range[1], source.x + view_range[1]) && ISINRANGE(target.y, source.y - view_range[1], source.y + view_range[1])

//Returns an in proportion scaled out view, with zoom_amt extra tiles on the y axis.
/proc/get_zoomed_view(view, zoom_amt)
	var/viewX
	var/viewY
	if(IS_FINITE(view))
		return view + zoom_amt
	else
		var/list/viewrangelist = splittext(view,"x")
		viewX = text2num(viewrangelist[1])
		viewY = text2num(viewrangelist[2])
		var/proportion = viewX / viewY
		viewX += zoom_amt * proportion
		viewY += zoom_amt
	//God, I hate that we have to round this.
	return "[round(viewX)]x[round(viewY)]"


/// Takes a string or num view, and converts it to pixel width/height in a list(pixel_width, pixel_height)
/proc/view_to_pixels(view)
	if(!view)
		return list(0, 0)
	var/list/view_info = getviewsize(view)
	view_info[1] *= ICON_SIZE_X
	view_info[2] *= ICON_SIZE_Y
	return view_info

/**
* Frustrated with bugs in can_see(), this instead uses viewers for a much more effective approach.
* ### Things to note:
* - Src/source must be a mob. `viewers()` returns mobs.
* - Adjacent objects are always considered visible.
*/

/// The default tile-distance between two atoms for one to consider the other as visible.
#define DEFAULT_SIGHT_DISTANCE 7

/// Basic check to see if the src object can see the target object.
#define CAN_I_SEE(target) ((src in viewers(DEFAULT_SIGHT_DISTANCE, target)) || in_range(target, src))


/// Checks the visibility between two other objects.
#define CAN_THEY_SEE(target, source) ((source in viewers(DEFAULT_SIGHT_DISTANCE, target)) || in_range(target, source))


/// Further checks distance between source and target.
#define CAN_SEE_RANGED(target, source, dist) ((source in viewers(dist, target)) || in_range(target, source))
