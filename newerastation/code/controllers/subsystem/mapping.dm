/datum/controller/subsystem/mapping
	var/list/station_room_templates = list()

/datum/controller/subsystem/mapping/proc/seedStation()
	for(var/V in GLOB.stationroom_landmarks)
		var/obj/effect/landmark/stationroom/LM = V
		LM.load()

	if(GLOB.stationroom_landmarks.len)
		seedStation() //I'm sure we can trust everyone not to insert a 1x1 rooms which loads a landmark which loads a landmark which loads a la...
