/datum/intoxication
	var/mob/living/carbon/host

	var/psychedelic = 0
	var/next_psychedelic = 0

	var/lite = 0
	var/next_lite = 0

	var/deliriant = 0
	var/next_deliriant = 0

	var/dissociative = 0
	var/next_dissociative = 0

	var/depressant = 0
	var/next_depressant = 0

	var/stimulant = 0
	var/next_stimulant = 0

	var/opioid = 0
	var/next_opioid = 0


/datum/intoxication/New(mob/living/carbon/H)
	host = H
	H.intoxication = src

/datum/intoxication/proc/run_life() 

	// TODO: Color matrix adding for multiple hallucination types

	if(!(host?.hud_used))
		return

	psychedelic = max(psychedelic - 1,  0)
	lite = max(lite - 1,  0)
	deliriant = max(deliriant - 1,  0)
	dissociative = max(dissociative - 1,  0)
	depressant = max(depressant - 1,  0)
	stimulant = max(stimulant - 1,  0)
	opioid = max(opioid - 1,  0)

	if(deliriant)
		if(world.time >= next_deliriant)
			var/halpick = pickweight(GLOB.hallucination_list)
			new halpick(host, FALSE)
			next_deliriant = world.time + rand(100, 600)
	
	if(psychedelic)
		if(world.time >= next_psychedelic)
			var/list/screens = list(host?.hud_used.plane_masters["[FLOOR_PLANE]"], host?.hud_used.plane_masters["[GAME_PLANE]"], host?.hud_used.plane_masters["[LIGHTING_PLANE]"])
			for(var/obj/whole_screen in screens)
				animate(whole_screen, color = color_matrix_rotate_hue(rand(0, psychedelic*1.5)), time = rand(2, 10))
			next_deliriant = world.time + rand(5, 50)

	else
		var/list/screens = list(host?.hud_used.plane_masters["[FLOOR_PLANE]"], host?.hud_used.plane_masters["[GAME_PLANE]"], host?.hud_used.plane_masters["[LIGHTING_PLANE]"])
		for(var/obj/whole_screen in screens)
			animate(whole_screen, color = color_matrix_rotate_hue(0), time = 50)

/mob/living/carbon/proc/testnav()
	to_chat(world, "Starting navigation")
	var/turf/T = pick(/turf/open/floor in range(100, src))
	walk_to(src, T)
	to_chat(world, "Ended navigation")