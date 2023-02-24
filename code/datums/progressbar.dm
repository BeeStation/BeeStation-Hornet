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


/datum/progressbar/New(mob/User, goal_number, atom/target, mutable_appearance/additional_image)
	. = ..()
	if (!istype(target))
		EXCEPTION("Invalid target given")
	if (goal_number)
		goal = goal_number

	bar = image('icons/effects/progessbar.dmi', target, "prog_bar_0")
	if(additional_image)
		shown_image = image(additional_image.icon, target, additional_image.icon_state, (HUD_LAYER - 0.1))
		shown_image.plane = ABOVE_HUD_PLANE
		shown_image.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	bar.plane = ABOVE_HUD_PLANE
	bar.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	user = User
	if(user)
		client = user.client

	LAZYINITLIST(user.progressbars)
	LAZYINITLIST(user.progressbars[bar.loc])
	var/list/bars = user.progressbars[bar.loc]
	bars.Add(src)
	listindex = bars.len
	bar.pixel_y = 0
	bar.alpha = 0
	animate(bar, pixel_y = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1)), alpha = 255, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)
	if(shown_image)
		shown_image.pixel_y = 0
		shown_image.alpha = 0
		animate(shown_image, pixel_y = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1)), alpha = 255, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)

/datum/progressbar/proc/update(progress)
	if (!user || !user.client)
		shown = FALSE
		return
	if (user.client != client)
		if (client)
			client.images -= bar
			if(shown_image)
				client.images -= shown_image
		if (user.client)
			user.client.images += bar
			if(shown_image)
				user.client.images += shown_image

	progress = CLAMP(progress, 0, goal)
	last_progress = progress
	bar.icon_state = "prog_bar_[round(((progress / goal) * 100), 5)]"
	if (!shown)
		user.client.images += bar
		if(shown_image)
			user.client.images += shown_image
		shown = TRUE

/datum/progressbar/proc/shiftDown()
	--listindex
	bar.pixel_y = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1))
	var/dist_to_travel = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1)) - PROGRESSBAR_HEIGHT
	animate(bar, pixel_y = dist_to_travel, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)
	if(shown_image)
		shown_image.pixel_y = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1))
		animate(shown_image, pixel_y = dist_to_travel, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)

/datum/progressbar/Destroy()
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
	addtimer(CALLBACK(src, .proc/remove_from_client), PROGRESSBAR_ANIMATION_TIME, TIMER_CLIENT_TIME)
	QDEL_IN(bar, PROGRESSBAR_ANIMATION_TIME * 2) //for garbage collection safety
	if(shown_image)
		animate(shown_image, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
		QDEL_IN(shown_image, PROGRESSBAR_ANIMATION_TIME * 2) //for garbage collection safety
	. = ..()

/datum/progressbar/proc/remove_from_client()
	if(client)
		client.images -= bar
		client = null
		if(shown_image)
			client.images -= shown_image

#undef PROGRESSBAR_ANIMATION_TIME
#undef PROGRESSBAR_HEIGHT

/obj/effect/additional_image
	plane = RUNECHAT_PLANE
	//base_pixel_y = 20
	pixel_y = 20
	appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART | TILE_BOUND
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
