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
	var/image/border
	var/image/shown_image
	var/image/border_look_accessory
	var/active_color
	var/fail_color
	var/finish_color
	var/old_format
	var/bar_look

/datum/progressbar/New(mob/User, goal_number, atom/target, border_look = "border", border_look_accessory, \
bar_look = "prog_bar", old_format = FALSE, active_color = "#6699FF", finish_color = "#FFEE8C", fail_color = "#FF0033" , mutable_appearance/additional_image)
	. = ..()
	if (!istype(target))
		EXCEPTION("Invalid target given")
	if (goal_number)
		goal = goal_number

	src.old_format = old_format
	src.active_color = active_color
	src.fail_color = fail_color
	src.finish_color = finish_color

	src.bar_look = bar_look
	if(additional_image)
		shown_image = image(additional_image.icon, target, additional_image.icon_state, (HUD_LAYER - 0.1))
		shown_image.plane = ABOVE_HUD_PLANE
		shown_image.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	border = image('icons/effects/progessbar.dmi', target, "[border_look]", HUD_LAYER)
	border.plane = ABOVE_HUD_PLANE
	border.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	bar.plane = ABOVE_HUD_PLANE
	bar.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	bar.color = active_color
	user = User

	if(border_look_accessory)
		src.border_look_accessory = shown_image = image('icons/effects/progessbar.dmi', target, border_look_accessory, (HUD_LAYER + 0.2))
		src.border_look_accessory.plane = ABOVE_HUD_PLANE
		src.border_look_accessory.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
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
	if(border_look_accessory)
		src.border_look_accessory.pixel_y = 0
		src.border_look_accessory.alpha = 0
		animate(src.border_look_accessory, pixel_y = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1)), alpha = 255, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)

/datum/progressbar/proc/update(progress)
	if (!user || !user.client)
		shown = FALSE
		return
	if (user.client != client)
		if (client)
			client.images -= bar
			client.images -= border
			if(shown_image)
				client.images -= shown_image
			if(border_look_accessory)
				client.images -= border_look_accessory
		if (user.client)
			user.client.images += bar
			user.client.images += border
			if(shown_image)
				user.client.images += shown_image
			if(border_look_accessory)
				user.client.images += border_look_accessory

	progress = CLAMP(progress, 0, goal)
	last_progress = progress
	var/complete = clamp(progress / goal, 0, 1)
	if(old_format)
		bar.icon_state = "[bar_look]_[round(((progress / goal) * 100), 5)]"
	else
		bar.transform = matrix(complete, 0, -10 * (1 - complete), 0, 1, 0)
	if (!shown)
		user.client.images += bar
		if(shown_image)
			user.client.images += shown_image
		if(border_look_accessory)
			user.client.images += border_look_accessory
		shown = TRUE

/datum/progressbar/proc/shiftDown()
	--listindex
	bar.pixel_y = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1))
	border.pixel_y = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1))
	var/dist_to_travel = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1)) - PROGRESSBAR_HEIGHT
	animate(bar, pixel_y = dist_to_travel, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)
	animate(border, pixel_y = dist_to_travel, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)
	if(shown_image)
		shown_image.pixel_y = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1))
		animate(shown_image, pixel_y = dist_to_travel, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)
	if(border_look_accessory)
		border_look_accessory.pixel_y = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1))
		animate(border_look_accessory, pixel_y = dist_to_travel, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)

/datum/progressbar/Destroy()
	if(last_progress != goal)
		if(old_format)
			bar.icon_state = "[bar.icon_state]_fail"
		else
			bar.color = fail_color
	for(var/I in user?.progressbars[bar.loc])
		var/datum/progressbar/P = I
		if(P != src && P.listindex > listindex)
			P.shiftDown()

	var/list/bars = user.progressbars[bar.loc]
	bars.Remove(src)
	if(!bars.len)
		LAZYREMOVE(user.progressbars, bar.loc)

	animate(bar, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
	animate(border, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)

	addtimer(CALLBACK(src, .proc/remove_from_client), PROGRESSBAR_ANIMATION_TIME, TIMER_CLIENT_TIME)
	QDEL_IN(bar, PROGRESSBAR_ANIMATION_TIME * 2) //for garbage collection safety
	QDEL_IN(border, PROGRESSBAR_ANIMATION_TIME * 2) //for garbage collection safety

	if(shown_image)
		animate(shown_image, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
		QDEL_IN(shown_image, PROGRESSBAR_ANIMATION_TIME * 2) //for garbage collection safety
	if(border_look_accessory)
		animate(border_look_accessory, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
		QDEL_IN(border_look_accessory, PROGRESSBAR_ANIMATION_TIME * 2) //for garbage collection safety
	. = ..()

/datum/progressbar/proc/remove_from_client()
	if(client)
		client.images -= bar
		client.images -= border
		if(shown_image)
			client.images -= shown_image
		if(border_look_accessory)
			client.images -= border_look_accessory
		client = null

/datum/progressbar/proc/end_progress()
	if(last_progress != goal)
		if(old_format)
			bar.icon_state = "[bar.icon_state]_fail"
		else
			bar.color = fail_color
	else
		bar.color = finish_color

	animate(bar, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
	animate(border, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
	if(shown_image)
		animate(shown_image, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
	if(border_look_accessory)
		animate(border_look_accessory, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
	QDEL_IN(src, PROGRESSBAR_ANIMATION_TIME)

/obj/effect/world_progressbar
	///The progress bar visual element.
	icon = 'icons/effects/progessbar.dmi'
	icon_state = "border"
	plane = RUNECHAT_PLANE
	layer = FLY_LAYER
	appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART | TILE_BOUND
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_y = 20
	var/obj/effect/bar/bar
	var/obj/effect/additional_image/additional_image
	var/obj/effect/border_accessory/border_accessory
	///The target where this progress bar is applied and where it is shown.
	var/atom/movable/bar_loc
	///The atom who "created" the bar
	var/atom/owner
	///Effectively the number of steps the progress bar will need to do before reaching completion.
	var/goal = 1
	///Control check to see if the progress was interrupted before reaching its goal.
	var/last_progress = 0
	///Variable to ensure smooth visual stacking on multiple progress bars.
	var/listindex = 0
	///the look of the bar inside the progress bar
	var/bar_look
	///does this use the old format of icons(useful for totally unqiue progress bars)
	var/old_format = FALSE

	///the color of the bar for new style bars
	var/finish_color
	var/active_color
	var/fail_color

/obj/effect/world_progressbar/Initialize(mapload, atom/owner, goal, atom/target, border_look = "border", border_accessory, bar_look = "prog_bar", old_format = FALSE, active_color = "#6699FF", finish_color = "#FFEE8C", fail_color = "#FF0033" , mutable_appearance/additional_image, has_outline = TRUE, y_multiplier)
	. = ..()
	if(!owner || !target || !goal)
		return INITIALIZE_HINT_QDEL

	src.icon_state = border_look
	src.bar_look = bar_look
	src.old_format = old_format
	src.owner = owner
	src.goal = goal
	src.bar_loc = target
	src.pixel_y *= y_multiplier
	if(additional_image)
		src.additional_image = new /obj/effect/additional_image
		src.additional_image.icon = additional_image.icon
		src.additional_image.icon_state = additional_image.icon_state
		src.additional_image.plane = src.plane
		src.additional_image.layer = src.layer - 0.1
		src.additional_image.pixel_y *= y_multiplier
		if(has_outline)
			src.additional_image.add_filter("outline", 1, list(type = "outline", size = 1,  color = "#FFFFFF"))
		src.bar_loc.vis_contents += src.additional_image

	src.bar_loc:vis_contents += src

	src.bar = new /obj/effect/bar
	src.bar.icon = icon
	src.bar.icon_state = bar_look
	src.bar.layer = src.layer + 0.1
	src.bar.plane = src.plane
	src.bar_loc.vis_contents += src.bar
	src.bar.alpha = 0
	src.bar.pixel_y *= y_multiplier

	if(border_accessory)
		src.border_accessory = new /obj/effect/border_accessory
		src.border_accessory.icon = icon
		src.border_accessory.icon_state = border_accessory
		src.border_accessory.layer = src.layer + 0.2
		src.border_accessory.plane = src.plane
		src.border_accessory.pixel_y *= y_multiplier
		if(has_outline)
			src.border_accessory.add_filter("outline", 1, list(type = "outline", size = 1,  color = "#FFFFFF"))
		src.bar_loc.vis_contents += src.border_accessory

	src.finish_color = finish_color
	src.active_color = active_color
	src.fail_color = fail_color
	if(has_outline)
		src.add_filter("outline", 1, list(type = "outline", size = 1,  color = "#FFFFFF"))

	RegisterSignal(bar_loc, COMSIG_PARENT_QDELETING, .proc/bar_loc_delete, override = TRUE)
	RegisterSignal(owner, COMSIG_PARENT_QDELETING, .proc/owner_delete, override = TRUE)

/obj/effect/world_progressbar/Destroy()
	owner = null
	bar_loc?:vis_contents -= src
	cut_overlays()
	return ..()

/obj/effect/world_progressbar/proc/bar_loc_delete()
	SIGNAL_HANDLER
	qdel(src)

/obj/effect/world_progressbar/proc/owner_delete()
	SIGNAL_HANDLER
	qdel(src)

///Updates the progress bar image visually.
/obj/effect/world_progressbar/proc/update(progress)
	bar.alpha = 255
	bar.color = active_color
	var/complete = clamp(progress / goal, 0, 1)
	progress = clamp(progress, 0, goal)
	if(progress == last_progress)
		return
	last_progress = progress
	if(old_format)
		bar.icon_state = "[bar_look]_[round(((progress / goal) * 100), 5)]"
	else
		bar.transform = matrix(complete, 0, -10 * (1 - complete), 0, 1, 0)

/obj/effect/world_progressbar/proc/end_progress()
	if(last_progress != goal)
		bar.icon_state = "[bar_look]_fail"
		bar.color = fail_color
	bar.color = finish_color
	animate(src, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
	animate(src.bar, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)

	QDEL_IN(src, PROGRESSBAR_ANIMATION_TIME)
	QDEL_IN(src.bar, PROGRESSBAR_ANIMATION_TIME)

	if(additional_image)
		animate(src.additional_image, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
		QDEL_IN(src.additional_image, PROGRESSBAR_ANIMATION_TIME)
	if(border_accessory)
		animate(src.border_accessory, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
		QDEL_IN(src.border_accessory, PROGRESSBAR_ANIMATION_TIME)

#undef PROGRESSBAR_ANIMATION_TIME
#undef PROGRESSBAR_HEIGHT

/obj/effect/bar
	plane = RUNECHAT_PLANE
	pixel_y = 20
	appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART | TILE_BOUND
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/additional_image
	plane = RUNECHAT_PLANE
	pixel_y = 20
	appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART | TILE_BOUND
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/border_accessory
	plane = RUNECHAT_PLANE
	pixel_y = 20
	appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART | TILE_BOUND
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/proc/machine_do_after_visable(atom/source, delay, progress = TRUE, border_look = "border", border_look_accessory, bar_look = "prog_bar", active_color = "#6699FF", finish_color = "#FFEE8C", fail_color = "#FF0033", old_format = FALSE, image/add_image, has_outline = TRUE, y_multiplier = 1)
	var/atom/target_loc = source

	var/datum/progressbar/progbar
	if(progress)
		progbar = new /obj/effect/world_progressbar(null, source, delay, target_loc || source, border_look, border_look_accessory, bar_look, old_format, active_color, finish_color, fail_color, add_image, has_outline, y_multiplier)

	var/endtime = world.time + delay
	var/starttime = world.time
	. = TRUE

	while (world.time < endtime)
		stoplag(1)
		if(!QDELETED(progbar))
			progbar.update(world.time - starttime)

	if(!QDELETED(progbar))
		progbar.end_progress()
