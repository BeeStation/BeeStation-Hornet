#define PROGRESSBAR_HEIGHT 6
#define PROGRESSBAR_ANIMATION_TIME 5

/datum/progressbar
	var/goal = 1
	var/last_progress = 0
	var/image/bar
	var/shown = 0
	var/mob/user
	var/client/client
	var/listindex
	var/image/shown_image
	var/image/shown_image_darkened
	var/alpha_filter
	var/icon/alpha_icon
	var/leftmost_pixel
	var/rightmost_pixel
	var/current_target
	var/show_bar = TRUE
	var/x_image_offset
	var/y_image_offset
	var/client/target_client
	var/current_outline_color = COLOR_BLUE_GRAY

/datum/progressbar/New(mob/User, goal_number, atom/target, show_to_target = FALSE, mutable_appearance/additional_image, \
l_pix = 1, r_pix = 32, x_offset = 0, y_offset = 0, scale = 1, targeted_client)
	. = ..()
	if (!istype(target))
		EXCEPTION("Invalid target given")
	if (goal_number)
		goal = goal_number
	leftmost_pixel = l_pix
	rightmost_pixel = r_pix
	current_target = target
	x_image_offset = x_offset
	y_image_offset = y_offset
	if(show_to_target)
		target_client = targeted_client
	if(additional_image)
		show_bar = FALSE
	if(show_bar)
		bar = image('icons/effects/progessbar.dmi', target, "prog_bar_0")
		bar.plane = ABOVE_HUD_PLANE
		bar.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	user = User
	if(user)
		client = user.client
	if(additional_image)
		shown_image = image(additional_image.icon, target, additional_image.icon_state, (ABOVE_HUD_PLANE - 0.1))
		shown_image.appearance_flags = KEEP_TOGETHER | APPEARANCE_UI_IGNORE_ALPHA
		shown_image.color = additional_image.color
		shown_image.underlays = additional_image.underlays
		shown_image.overlays = additional_image.overlays
		shown_image.plane = HUD_PLANE
		shown_image.transform = shown_image.transform.Scale(scale, scale)
		shown_image_darkened = image(additional_image.icon, target, additional_image.icon_state, (ABOVE_HUD_PLANE - 0.2))
		shown_image_darkened.appearance_flags = KEEP_TOGETHER | APPEARANCE_UI_IGNORE_ALPHA
		shown_image_darkened.color = additional_image.color
		shown_image_darkened.underlays = additional_image.underlays
		shown_image_darkened.overlays = additional_image.overlays
		shown_image_darkened.plane = HUD_PLANE
		shown_image_darkened.transform = shown_image_darkened.transform.Scale(scale, scale)
	if(show_bar)
		LAZYINITLIST(user.progressbars)
		LAZYINITLIST(user.progressbars[bar.loc])
		var/list/bars = user.progressbars[bar.loc]
		bars.Add(src)
		listindex = bars.len
		bar.pixel_y = 0
		bar.alpha = 0
		if(user?.client)
			user?.client.images += bar
		if(show_to_target)
			target_client?.images += bar
		animate(bar, pixel_y = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1)), alpha = 255, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)
	if(shown_image)
		shown_image.pixel_y = 0 + y_image_offset
		shown_image.pixel_x = 0 + x_image_offset
		shown_image.alpha = 0

		shown_image_darkened.pixel_y = 0 + y_image_offset
		shown_image_darkened.pixel_x = 0 + x_image_offset
		shown_image_darkened.alpha = 0

		alpha_icon = icon('icons/effects/64x64.dmi', "black_pillar")
		alpha_filter = filter(type = "alpha", x = -33 + leftmost_pixel , y = 0, icon = alpha_icon)
		shown_image.filters = alpha_filter
		user?.client.images += shown_image
		if(show_to_target)
			target_client?.images += shown_image
		animate(shown_image, pixel_y = 32 + y_image_offset + (PROGRESSBAR_HEIGHT * (listindex - 1)), alpha = 255, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)
		shown_image_darkened.filters += filter(type = "color", color = list(0.07,0.07,0.07,0,0.07,0.07,0.07,0,0.07,0.07,0.07,0,0,0,0,1))
		if(user?.client?.prefs)
			current_outline_color = user.client.prefs.read_player_preference(/datum/preference/color/outline_color)
		shown_image_darkened.filters += filter(type = "outline", size = 1, color = current_outline_color)
		user?.client.images += shown_image_darkened
		if(show_to_target)
			target_client?.images += shown_image_darkened
		animate(shown_image_darkened, pixel_y = 32 + y_image_offset + (PROGRESSBAR_HEIGHT * (listindex - 1)), alpha = 255, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)

/datum/progressbar/proc/update(progress)
	if ((!user || !user.client) && (!target_client))
		shown = FALSE
		return
	if (user.client != client)
		if (client)
			if(show_bar)
				client.images -= bar
			if(shown_image)
				client.images -= shown_image
				client.images -= shown_image_darkened
		if (user.client)
			if(show_bar)
				user.client.images += bar
			if(shown_image)
				user.client.images += shown_image
				user.client.images += shown_image_darkened
	if(target_client && shown_image && !shown)
		target_client?.images -= shown_image
		target_client?.images -= shown_image_darkened

	progress = CLAMP(progress, 0, goal)
	last_progress = progress
	if(show_bar)
		bar.icon_state = "prog_bar_[round(((progress / goal) * 100), 5)]"
	if(shown_image)
		shown_image.filters -= alpha_filter
		alpha_filter = filter(type = "alpha", x = -33 + leftmost_pixel + round(((progress / goal) * (rightmost_pixel - leftmost_pixel + 1)), 1) , y = 0, icon = alpha_icon)
		shown_image.filters += alpha_filter
	if (!shown)
		if(show_bar && user && user?.client)
			user.client.images += bar
		if(shown_image)
			if(user && user?.client)
				user.client.images += shown_image
				user.client.images += shown_image_darkened
			if(target_client)
				target_client?.images += shown_image
				target_client?.images += shown_image_darkened
		shown = TRUE

/datum/progressbar/proc/shiftDown()
	--listindex
	bar.pixel_y = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1))
	var/dist_to_travel = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1)) - PROGRESSBAR_HEIGHT
	animate(bar, pixel_y = dist_to_travel, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)
	if(shown_image)
		shown_image.pixel_y = 32 + y_image_offset + (PROGRESSBAR_HEIGHT * (listindex - 1))
		animate(shown_image, pixel_y = dist_to_travel, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)
		shown_image_darkened.pixel_y = 32 + y_image_offset + (PROGRESSBAR_HEIGHT * (listindex - 1))
		animate(shown_image_darkened, pixel_y = dist_to_travel, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)

/datum/progressbar/Destroy()
	if(show_bar)
		if(last_progress != goal)
			bar.icon_state = "[bar.icon_state]_fail"
		for(var/I in user?.progressbars[bar.loc])
			var/datum/progressbar/P = I
			if(P != src && P.listindex > listindex)
				P.shiftDown()
		var/list/bars = user.progressbars[bar.loc]
		bars.Remove(src)
		if(!bars.len)
			LAZYREMOVE(user.progressbars, bar.loc)
		animate(bar, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
	addtimer(CALLBACK(src, PROC_REF(remove_from_client)), PROGRESSBAR_ANIMATION_TIME, TIMER_CLIENT_TIME)
	if(show_bar)
		QDEL_IN(bar, PROGRESSBAR_ANIMATION_TIME * 2) //for garbage collection safety
	if(shown_image)
		if(user?.client?.images)
			user.client.images -= shown_image
			user.client.images -= shown_image_darkened
		if(target_client)
			target_client?.images -= shown_image
			target_client?.images -= shown_image_darkened
		if(goal != last_progress)
			shown_image.filters += filter(type = "color", color = rgb(255, 0, 51))
			shown_image_darkened.filters -= filter(type = "outline", size = 1, color = current_outline_color)
			current_outline_color = COLOR_DARK_RED
			shown_image_darkened.filters += filter(type = "color", color = rgb(128, 0, 0))
			shown_image_darkened.filters += filter(type = "outline", size = 1, color = current_outline_color)
		if(user?.client?.images)
			user.client.images += shown_image
			user.client.images += shown_image_darkened
		if(target_client)
			target_client?.images += shown_image
			target_client?.images += shown_image_darkened
		animate(shown_image, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
		animate(shown_image_darkened, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
		QDEL_IN(shown_image, PROGRESSBAR_ANIMATION_TIME * 2) //for garbage collection safety
		QDEL_IN(shown_image_darkened, PROGRESSBAR_ANIMATION_TIME * 2) //same as above
	. = ..()

/datum/progressbar/proc/remove_from_client()
	if(client)
		if(show_bar)
			client.images -= bar
		if(shown_image)
			client.images -= shown_image
			client.images -= shown_image_darkened
		client = null
/*
///Called on progress end, be it successful or a failure. Wraps up things to delete the datum and bar.
/datum/progressbar/proc/end_progress()

	bar.icon_state = "prog_bar_[round(((progress / goal) * 100), 5)]"
	animate(bar, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
	if(shown_image)
		animate(shown_image, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
	QDEL_IN(src, PROGRESSBAR_ANIMATION_TIME)
*/
#undef PROGRESSBAR_ANIMATION_TIME
#undef PROGRESSBAR_HEIGHT
