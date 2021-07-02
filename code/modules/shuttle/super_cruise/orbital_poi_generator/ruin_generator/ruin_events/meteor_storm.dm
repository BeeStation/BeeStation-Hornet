/datum/ruin_event/meteor_storm
	warning_message = "METEOR STORM"
	probability = 2
	start_tick_min = 600
	start_tick_max = 3000
	tick_rate = 80

/datum/ruin_event/meteor_storm/post_spawn(list/floor_turfs, z_value)
	exploration_announce("Incoming dust-storm. ETA: [round(start_tick / 10, 1)] seconds.", z_value)

/datum/ruin_event/meteor_storm/event_tick(z_value)
	var/startSide = pick(GLOB.cardinals)
	var/turf/pickedstart = spaceDebrisStartLoc(startSide, z_value)
	var/turf/pickedgoal = spaceDebrisFinishLoc(startSide, z_value)
	var/Me = pickweight(GLOB.meteorsC)
	var/obj/effect/meteor/M = new Me(pickedstart, pickedgoal)
	M.dest = pickedgoal
