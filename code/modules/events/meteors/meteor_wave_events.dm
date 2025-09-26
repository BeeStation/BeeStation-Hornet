// Normal strength

/datum/round_event_control/meteor_wave
	name = "Meteor Wave: Normal"
	description = "A regular meteor wave."
	category = EVENT_CATEGORY_SPACE
	typepath = /datum/round_event/meteor_wave
	weight = 4
	min_players = 15
	max_occurrences = 3
	earliest_start = 30 MINUTES
	can_malf_fake_alert = TRUE
	map_flags = EVENT_SPACE_ONLY
	admin_setup = list(
		/datum/event_admin_setup/question/meteor_instant
	)

/// Admins can also force it to loop around forever, or at least until the RD gets their hands on it.
/datum/event_admin_setup/question/meteor_instant
	input_text = "Trigger meteors instantly? (This will not change the alert, just send them quicker. Nobody will ever notice!)"

/datum/event_admin_setup/question/meteor_instant/apply_to_event(datum/round_event/meteor_wave/event)
	event.announce_when = 1
	event.meteor_time = 1 MINUTES

/datum/round_event/meteor_wave
	announce_when = 150
	start_when = 1
	end_when = 151
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
	station_target = SSorbits.station_instance
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
		MOVE_ORBITAL_BODY(meteor, meteor.start_x, meteor.start_y)
		//Calculate velocity
		meteor.velocity.x = (station_target.position.x - meteor.start_x * 10) / meteor_time
		meteor.velocity.y = (station_target.position.y - meteor.start_y * 10) / meteor_time
		meteor.end_tick = SSorbits.times_fired + (meteor_time / SSorbits.wait)
		meteor.target = station_target

/datum/round_event/meteor_wave/proc/determine_wave_type()
	if(!wave_name)
		wave_name = pick_weight(list(
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

/datum/round_event_control/meteor_wave/threatening
	name = "Meteor Wave: Threatening"
	description = "A meteor wave with higher chance of big meteors."
	typepath = /datum/round_event/meteor_wave/threatening
	weight = 5
	min_players = 20
	max_occurrences = 3
	earliest_start = 35 MINUTES

/datum/round_event/meteor_wave/threatening
	wave_name = "threatening"

/datum/round_event_control/meteor_wave/catastrophic
	name = "Meteor Wave: Catastrophic"
	description = "A meteor wave that might summon a tunguska class meteor."
	typepath = /datum/round_event/meteor_wave/catastrophic
	weight = 7
	min_players = 25
	max_occurrences = 3
	earliest_start = 45 MINUTES

/datum/round_event/meteor_wave/catastrophic
	wave_name = "catastrophic"

/datum/round_event_control/meteor_wave/meaty
	name = "Meteor Wave: Meaty"
	description = "A meteor wave made of meat."
	typepath = /datum/round_event/meteor_wave/meaty
	weight = 2
	max_occurrences = 1

/datum/round_event/meteor_wave/meaty
	wave_name = "meaty"

/datum/round_event/meteor_wave/meaty/announce(fake)
	priority_announce("Meaty ores have been detected on collision course with the station.", "Oh crap, get the mop.", ANNOUNCER_METEORS)

/datum/round_event_control/meteor_wave/dust_storm
	name = "Major Space Dust"
	description = "The station is pelted by sand."
	category = EVENT_CATEGORY_SPACE
	typepath = /datum/round_event/meteor_wave/dust_storm
	weight = 8

/datum/round_event/meteor_wave/dust_storm
	wave_name = "space dust"

/datum/round_event/meteor_wave/dust_storm/announce(fake)
	var/list/reasons = list()

	reasons += "[station_name()] is passing through a debris cloud, expect minor damage \
		to external fittings and fixtures."

	reasons += "Nanotrasen Superweapons Division is testing a new prototype \
		[pick("field","projection","nova","super-colliding","reactive")] \
		[pick("cannon","artillery","tank","cruiser","\[REDACTED\]")], \
		some mild debris is expected."

	reasons += "A neighbouring station is throwing rocks at you. (Perhaps they've \
		grown tired of your messages.)"

	reasons += "[station_name()]'s orbit is passing through a cloud of remnants from an asteroid \
		mining operation. Minor hull damage is to be expected."

	reasons += "A large meteoroid on intercept course with [station_name()] has been demolished. \
		Residual debris may impact the station exterior."

	reasons += "[station_name()] has hit a particularly rough patch of space. \
		Please mind any turbulence or damage from debris."

	priority_announce(pick(reasons), "Collision Alert")
