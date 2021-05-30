#define BALLOON_TEXT_WIDTH 200
#define BALLOON_TEXT_SPAWN_TIME (0.2 SECONDS)
#define BALLOON_TEXT_FADE_TIME (0.1 SECONDS)
#define BALLOON_TEXT_FULLY_VISIBLE_TIME (0.7 SECONDS)
#define BALLOON_TEXT_TOTAL_LIFETIME (BALLOON_TEXT_SPAWN_TIME + BALLOON_TEXT_FULLY_VISIBLE_TIME + BALLOON_TEXT_FADE_TIME)

/// Creates text that will float from the atom upwards to the viewer.
/atom/proc/balloon_alert(mob/viewer, text)
	SHOULD_NOT_SLEEP(TRUE)

	INVOKE_ASYNC(src, .proc/balloon_alert_perform, viewer, text)

/// Create balloon alerts (text that floats up) to everything within range.
/// Will only display to people who can see.
/atom/proc/balloon_alert_to_viewers(message, self_message, vision_distance = DEFAULT_MESSAGE_RANGE, list/ignored_mobs)
	SHOULD_NOT_SLEEP(TRUE)

	var/list/hearers = get_hearers_in_view(vision_distance, src)
	hearers -= ignored_mobs

	for (var/mob/hearer in hearers)
		if (is_blind(hearer))
			continue

		balloon_alert(hearer, (hearer == src && self_message) || message)

// Do not use.
// MeasureText blocks. I have no idea for how long.
// I would've made the maptext_height update on its own, but I don't know
// if this would look bad on laggy clients.
/atom/proc/balloon_alert_perform(mob/viewer, text)
	var/client/viewer_client = viewer.client
	if (isnull(viewer_client))
		return

	var/bound_width = world.icon_size
	if (ismovable(src))
		var/atom/movable/movable_source = src
		bound_width = movable_source.bound_width

	var/image/balloon_alert = image(loc = get_atom_on_turf(src), layer = ABOVE_MOB_LAYER)
	balloon_alert.plane = BALLOON_CHAT_PLANE
	balloon_alert.alpha = 0
	balloon_alert.maptext = MAPTEXT("<span style='text-align: center; -dm-text-outline: 1px #0005'>[text]</span>")
	balloon_alert.maptext_x = (BALLOON_TEXT_WIDTH - bound_width) * -0.5
	balloon_alert.maptext_height = WXH_TO_HEIGHT(viewer_client?.MeasureText(text, null, BALLOON_TEXT_WIDTH))
	balloon_alert.maptext_width = BALLOON_TEXT_WIDTH

	viewer_client?.images += balloon_alert

	animate(
		balloon_alert,
		pixel_y = world.icon_size * 1.2,
		time = BALLOON_TEXT_TOTAL_LIFETIME,
		easing = SINE_EASING | EASE_OUT,
	)

	animate(
		alpha = 255,
		time = BALLOON_TEXT_SPAWN_TIME,
		easing = CUBIC_EASING | EASE_OUT,
		flags = ANIMATION_PARALLEL,
	)

	animate(
		alpha = 0,
		time = BALLOON_TEXT_FULLY_VISIBLE_TIME,
		easing = CUBIC_EASING | EASE_IN,
	)

	addtimer(CALLBACK(GLOBAL_PROC, .proc/remove_image_from_client, balloon_alert, viewer_client), BALLOON_TEXT_TOTAL_LIFETIME)

#undef BALLOON_TEXT_FADE_TIME
#undef BALLOON_TEXT_FULLY_VISIBLE_TIME
#undef BALLOON_TEXT_SPAWN_TIME
#undef BALLOON_TEXT_TOTAL_LIFETIME
#undef BALLOON_TEXT_WIDTH
