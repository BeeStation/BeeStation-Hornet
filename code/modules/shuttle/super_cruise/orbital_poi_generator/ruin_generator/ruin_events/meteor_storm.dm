/datum/ruin_event/meteor_storm
	warning_message = "METEOR STORM"
	probability = 1
	start_tick_min = 300
	start_tick_max = 600
	tick_rate = 4

/datum/ruin_event/meteor_storm/event_tick(z_value)
	var/startSide = pick(GLOB.cardinals)
	var/turf/pickedstart = spaceDebrisStartLoc(startSide, z_value)
	var/turf/pickedgoal = spaceDebrisFinishLoc(startSide, z_value)
	var/Me = pickweight(GLOB.meteorsC)
	var/obj/effect/meteor/M = new Me(pickedstart, pickedgoal)
	M.dest = pickedgoal
