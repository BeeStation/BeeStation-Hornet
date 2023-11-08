#define MAX_NAVIGATE_RANGE 125

/mob/living
	/// Cooldown of the navigate() verb.
	COOLDOWN_DECLARE(navigate_cooldown)

/client
	/// Images of the path created by navigate().
	var/list/navigation_images = list()

/mob/living/verb/navigate()
	set name = "Navigate"
	set category = "IC"

	if(incapacitated())
		return
	if(length(client.navigation_images))
		addtimer(CALLBACK(src, .proc/cut_navigation), world.tick_lag)
		balloon_alert(src, "navigation path removed")
		return
	if(!COOLDOWN_FINISHED(src, navigate_cooldown))
		balloon_alert(src, "navigation on cooldown!")
		return
	addtimer(CALLBACK(src, .proc/create_navigation), world.tick_lag)

/mob/living/proc/create_navigation()
	var/list/beacon_list = list()
	for(var/obj/machinery/navbeacon/beacon in GLOB.wayfindingbeacons)
		if(beacon.z != z || get_dist(beacon, src) > MAX_NAVIGATE_RANGE)
			continue
		beacon_list[beacon.location] = beacon
	if(!length(beacon_list))
		balloon_alert(src, "no navigation signals!")
		return
	var/beacon_id = tgui_input_list(src, "Select a location", "Navigate", sort_list(beacon_list))
	var/obj/machinery/navbeacon/navigate_target = beacon_list[beacon_id]
	if(!istype(navigate_target))
		return
	if(incapacitated())
		return
	COOLDOWN_START(src, navigate_cooldown, 15 SECONDS)
	var/list/path = get_path_to(src, navigate_target, MAX_NAVIGATE_RANGE, mintargetdist = 1, id = get_idcard(), skip_first = FALSE)
	if(!length(path))
		balloon_alert(src, "no valid path with current access!")
		return
	path |= get_turf(navigate_target)
	for(var/i in 1 to length(path))
		var/image/path_image = image(icon = 'icons/effects/navigation.dmi', layer = HIGH_PIPE_LAYER, loc = path[i])
		path_image.plane = GAME_PLANE
		path_image.color = COLOR_CYAN
		path_image.alpha = 0
		var/dir_1 = 0
		var/dir_2 = 0
		if(i == 1)
			dir_2 = turn(angle2dir(get_angle(path[i+1], path[i])), 180)
		else if(i == length(path))
			dir_2 = turn(angle2dir(get_angle(path[i-1], path[i])), 180)
		else
			dir_1 = turn(angle2dir(get_angle(path[i+1], path[i])), 180)
			dir_2 = turn(angle2dir(get_angle(path[i-1], path[i])), 180)
			if(dir_1 > dir_2)
				dir_1 = dir_2
				dir_2 = turn(angle2dir(get_angle(path[i+1], path[i])), 180)
		path_image.icon_state = "[dir_1]-[dir_2]"
		client.images += path_image
		client.navigation_images += path_image
		animate(path_image, 0.5 SECONDS, alpha = 150)
	addtimer(CALLBACK(src, .proc/shine_navigation), 0.5 SECONDS)
	RegisterSignal(src, COMSIG_LIVING_DEATH, .proc/cut_navigation)
	balloon_alert(src, "navigation path created")

/mob/living/proc/shine_navigation()
	for(var/i in 1 to length(client.navigation_images))
		animate(client.navigation_images[i], time = 1 SECONDS, loop = -1, alpha = 200, color = "#bbffff", easing = BACK_EASING | EASE_OUT)
		animate(time = 2 SECONDS, loop = -1, alpha = 150, color = "#00ffff", easing = CUBIC_EASING | EASE_OUT)
		stoplag(0.1 SECONDS)

/mob/living/proc/cut_navigation()
	SIGNAL_HANDLER
	for(var/image/navigation_path in client.navigation_images)
		client.images -= navigation_path
	client.navigation_images.Cut()
	UnregisterSignal(src, COMSIG_LIVING_DEATH)

#undef MAX_NAVIGATE_RANGE
