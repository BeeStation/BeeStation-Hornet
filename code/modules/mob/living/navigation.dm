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
		addtimer(CALLBACK(src, PROC_REF(cut_navigation)), world.tick_lag)
		balloon_alert(src, "navigation path removed")
		return
	if(!COOLDOWN_FINISHED(src, navigate_cooldown))
		balloon_alert(src, "navigation on cooldown!")
		return
	addtimer(CALLBACK(src, PROC_REF(create_navigation)), world.tick_lag)

/mob/living/proc/create_navigation()
	if(incapacitated())
		to_chat(src, "<span class='notice'>You are not conscious enough to do that.</span>")
		return
	var/list/filtered_navigation_list = list()
	for(var/each_nav_id in GLOB.navigate_destinations)
		var/obj/effect/landmark/navigate_destination/each_nav = GLOB.navigate_destinations[each_nav_id]
		if(!each_nav || !each_nav.is_available_to_user(src))
			continue
		filtered_navigation_list[each_nav_id] = each_nav

	if(!is_reserved_level(z)) //don't let us path to nearest staircase or ladder on shuttles in transit
		if(z > 1)
			filtered_navigation_list["Nearest Way Down"] = DOWN
		if(z < world.maxz)
			filtered_navigation_list["Nearest Way Up"] = UP

	if(!length(filtered_navigation_list))
		balloon_alert(src, "no navigation signals!")
		return

	var/target_nav_id = tgui_input_list(src, "Select a location", "Navigate", sort_list(filtered_navigation_list))
	var/obj/effect/landmark/navigate_destination/target_destination = filtered_navigation_list[target_nav_id]

	if(isnull(target_destination))
		return
	if(isatom(target_destination) && !target_destination.is_available_to_user(src))
		return
	if(incapacitated())
		return

	// automatically change your destination to another floor
	if(istype(target_destination, /obj/effect/landmark/navigate_destination))
		var/z_result = target_destination.compare_z_with(src)
		if(!z_result)
			return
		if(z_result > 1) // UP: 16, DOWN: 32
			target_destination = z_result
			to_chat(src, "<span class='notice'>Your destination is at another floor. You should go [target_destination == UP ? "up" : "down"] first.</span>")

	COOLDOWN_START(src, navigate_cooldown, 15 SECONDS)

	if(target_destination == UP || target_destination == DOWN)
		var/new_target = find_nearest_stair_or_ladder(target_destination)

		if(!new_target)
			balloon_alert(src, "can't find ladder or staircase going [target_destination == UP ? "up" : "down"]!")
			COOLDOWN_RESET(src, navigate_cooldown)
			return

		target_destination = new_target

	if(!isatom(target_destination))
		stack_trace("Navigate target ([target_destination]) is not an atom, somehow.")
		return

	var/list/path = get_path_to(src, target_destination, MAX_NAVIGATE_RANGE, mintargetdist = 1, access = get_access(), skip_first = FALSE)
	if(!length(path))
		if(tgui_alert(src, "No valid path found with your current access. Bypass access restrictions?", "Navigation", list("Yes", "No")) != "Yes")
			balloon_alert(src, "no valid path with current access!")
			//Let them path again
			COOLDOWN_RESET(src, navigate_cooldown)
			return
		path = get_path_to_all_access(src, target_destination, MAX_NAVIGATE_RANGE, mintargetdist = 1, skip_first = FALSE)
		if(!length(path))
			balloon_alert(src, "no valid path found!")
			//Let them path again
			COOLDOWN_RESET(src, navigate_cooldown)
			return
	path |= get_turf(target_destination)
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
	addtimer(CALLBACK(src, PROC_REF(shine_navigation)), 0.5 SECONDS)
	RegisterSignal(src, COMSIG_LIVING_DEATH, PROC_REF(cut_navigation))
	balloon_alert(src, "navigation path created")

/mob/living/proc/shine_navigation()
	for(var/i in 1 to length(client.navigation_images))
		if(!length(client.navigation_images))
			return
		animate(client.navigation_images[i], time = 1 SECONDS, loop = -1, alpha = 200, color = "#bbffff", easing = BACK_EASING | EASE_OUT)
		animate(time = 2 SECONDS, loop = -1, alpha = 150, color = COLOR_CYAN, easing = CUBIC_EASING | EASE_OUT)
		stoplag(0.1 SECONDS)

/mob/living/proc/cut_navigation()
	SIGNAL_HANDLER
	for(var/image/navigation_path in client.navigation_images)
		client.images -= navigation_path
	client.navigation_images.Cut()
	UnregisterSignal(src, COMSIG_LIVING_DEATH)

/**
 * Finds nearest ladder or staircase either up or down.
 *
 * Arguments:
 * * direction - UP or DOWN.
 */
/mob/living/proc/find_nearest_stair_or_ladder(direction)
	if(!direction)
		return
	if(direction != UP && direction != DOWN)
		return

	var/target
	for(var/obj/structure/ladder/lad in GLOB.ladders)
		if(lad.z != z)
			continue
		if(direction == UP && !lad.up)
			continue
		if(direction == DOWN && !lad.down)
			continue
		if(!target)
			target = lad
			continue
		if(get_dist_euclidean(lad, src) > get_dist_euclidean(target, src))
			continue
		target = lad

	for(var/obj/structure/stairs/stairs_bro in GLOB.stairs)
		if(direction == UP && stairs_bro.z != z) //if we're going up, we need to find stairs on our z level
			continue
		if(direction == DOWN && stairs_bro.z != z - 1) //if we're going down, we need to find stairs on the z level beneath us
			continue
		if(!target)
			target = stairs_bro.z == z ? stairs_bro : get_step_multiz(stairs_bro, UP) //if the stairs aren't on our z level, get the turf above them (on our zlevel) to path to instead
			continue
		if(get_dist_euclidean(stairs_bro, src) > get_dist_euclidean(target, src))
			continue
		target = stairs_bro.z == z ? stairs_bro : get_step_multiz(stairs_bro, UP)

	return target
