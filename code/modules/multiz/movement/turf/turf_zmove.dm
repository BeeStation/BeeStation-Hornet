/// Shows a radial with up and down arrows that forward to zMove()
/turf/proc/show_zmove_radial(mob/user)
	if(get_turf(user) != src)
		return
	var/list/tool_list = list()
	var/turf/above = above()
	if(above)
		tool_list["Up"] = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTH)
	var/turf/below = below()
	if(below)
		tool_list["Down"] = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTH)

	if(!length(tool_list))
		return

	var/result = show_radial_menu(user, user, tool_list, require_near = TRUE, tooltips = TRUE)
	if(get_turf(user) != src)
		return
	switch(result)
		if("Cancel")
			return
		if("Up")
			if(user.zMove(UP, TRUE))
				to_chat(user, "<span class='notice'>You move upwards.</span>")
		if("Down")
			if(user.zMove(DOWN, TRUE))
				to_chat(user, "<span class='notice'>You move down.</span>")

/// Moves a mob, any buckled mobs, and pulled mobs between Zs
/turf/proc/travel_z(mob/user, turf/target, dir)
	var/mob/living/L = user
	if(istype(L) && L.incorporeal_move) // Allow most jaunting
		user.client?.Process_Incorpmove(dir)
		return
	var/atom/movable/AM
	if(user.pulling)
		AM = user.pulling
		AM.forceMove(target)
	if(user.pulledby) // We moved our way out of the pull
		user.pulledby.stop_pulling()
	if(user.has_buckled_mobs())
		for(var/M in user.buckled_mobs)
			var/mob/living/buckled_mob = M
			var/old_dir = buckled_mob.dir
			if(!buckled_mob.Move(target, dir))
				user.doMove(buckled_mob.loc) //forceMove breaks buckles, use doMove
				user.last_move = buckled_mob.last_move
				// Otherwise they will always face north
				buckled_mob.setDir(old_dir)
				user.setDir(old_dir)
				return FALSE
	else
		user.forceMove(target)
	if(istype(AM) && user.Adjacent(AM))
		user.start_pulling(AM)
