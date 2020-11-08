/proc/getviewsize(view, extra_x = 0, extra_y = 0)
	var/viewX
	var/viewY
	if(isnum_safe(view))
		var/totalviewrange = (view < 0 ? -1 : 1) + 2 * view
		viewX = totalviewrange + extra_x
		viewY = totalviewrange + extra_y
	else
		var/list/viewrangelist = splittext(view,"x")
		viewX = text2num(viewrangelist[1]) + extra_x
		viewY = text2num(viewrangelist[2]) + extra_y
	return list(viewX, viewY)

/proc/in_view_range(mob/user, atom/A)
	var/list/view_range = getviewsize(user.client.view)
	var/turf/source = get_turf(user)
	var/turf/target = get_turf(A)
	return ISINRANGE(target.x, source.x - view_range[1], source.x + view_range[1]) && ISINRANGE(target.y, source.y - view_range[1], source.y + view_range[1])

//Returns an in proportion scaled out view, with zoom_amt extra tiles on the y axis.
/proc/get_zoomed_view(view, zoom_amt)
	var/viewX
	var/viewY
	if(isnum_safe(view))
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
