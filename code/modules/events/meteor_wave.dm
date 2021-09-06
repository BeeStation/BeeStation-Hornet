// Normal strength

/datum/round_event_control/meteor_wave
	name = "Meteor Wave: Normal"
	typepath = /datum/round_event/meteor_wave
	weight = 4
	min_players = 15
	max_occurrences = 3
	earliest_start = 30 MINUTES
	can_malf_fake_alert = TRUE

/datum/round_event/meteor_wave
	announceWhen	= 150
	startWhen = 1
	endWhen = 151
	var/list/wave_type
	var/wave_name = "normal"
	var/start_x
	var/start_y
	var/datum/orbital_object/station_target
	var/meteor_time = 15 MINUTES

/datum/round_event/meteor_wave/New()
	..()
	if(!wave_type)
		determine_wave_type()
	start_x = sin(rand(0, 360)) * 9000
	start_y = cos(rand(0, 360)) * 9000
	station_target = locate(/datum/orbital_object/z_linked/station) in SSorbits.orbital_map.bodies
	if(!station_target)
		CRASH("Meteor failed to locate a target.")

/datum/round_event/meteor_wave/Destroy(force, ...)
	station_target = null
	. = ..()

/datum/round_event/meteor_wave/tick()
	if(ISMULTIPLE(activeFor, 3) && activeFor < 61 && station_target)
		var/datum/orbital_object/meteor/meteor = new()
		meteor.name = "Meteor ([wave_name])"
		meteor.meteor_types = wave_type
		meteor.start_x = start_x + rand(-600, 600)
		meteor.start_y = start_y + rand(-600, 600)
		meteor.position.x = meteor.start_x
		meteor.position.y = meteor.start_y
		//Calculate velocity
		meteor.velocity.x = (station_target.position.x - meteor.start_x * 10) / meteor_time
		meteor.velocity.y = (station_target.position.y - meteor.start_y * 10) / meteor_time
		meteor.end_tick = world.time + meteor_time
		meteor.target = station_target

/datum/round_event/meteor_wave/on_admin_trigger()
	if(alert(usr, "Trigger meteors instantly? (This will not change the alert, just send them quicker. Nobody will ever notice!)", "Meteor Trigger", "Yes", "No") == "Yes")
		announceWhen = 1
		meteor_time = 1 MINUTES

/datum/round_event/meteor_wave/proc/determine_wave_type()
	if(!wave_name)
		wave_name = pickweight(list(
			"normal" = 50,
			"threatening" = 40,
			"catastrophic" = 10))
	switch(wave_name)
		if("normal")
			wave_type = GLOB.meteors_normal
		if("threatening")
			wave_type = GLOB.meteors_threatening
		if("catastrophic")
			if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
				wave_type = GLOB.meteorsSPOOKY
			else
				wave_type = GLOB.meteors_catastrophic
		if("meaty")
			wave_type = GLOB.meteorsB
		if("space dust")
			wave_type = GLOB.meteorsC
		if("halloween")
			wave_type = GLOB.meteorsSPOOKY
		else
			WARNING("Wave name of [wave_name] not recognised.")
			kill()

/datum/round_event/meteor_wave/announce(fake)
	priority_announce("Meteors have been detected on collision course with the station. Estimated time until impact: 10 MINUTES. Anti-meteor point defense is available for purchase via the station's cargo shuttle.", "Meteor Alert", ANNOUNCER_METEORS)
	if(!fake)
		var/datum/supply_pack/P = SSshuttle.supply_packs[/datum/supply_pack/engineering/shield_sat]
		P.special_enabled = TRUE
		P = SSshuttle.supply_packs[/datum/supply_pack/engineering/shield_sat_control]
		P.special_enabled = TRUE

/datum/round_event_control/meteor_wave/threatening
	name = "Meteor Wave: Threatening"
	typepath = /datum/round_event/meteor_wave/threatening
	weight = 5
	min_players = 20
	max_occurrences = 3
	earliest_start = 35 MINUTES

/datum/round_event/meteor_wave/threatening
	wave_name = "threatening"

/datum/round_event_control/meteor_wave/catastrophic
	name = "Meteor Wave: Catastrophic"
	typepath = /datum/round_event/meteor_wave/catastrophic
	weight = 7
	min_players = 25
	max_occurrences = 3
	earliest_start = 45 MINUTES

/datum/round_event/meteor_wave/catastrophic
	wave_name = "catastrophic"
