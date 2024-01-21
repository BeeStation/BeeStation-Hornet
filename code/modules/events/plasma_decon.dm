/datum/round_event_control/plasma_decon
	name = "Plasma decontamination"
	typepath = /datum/round_event/plasma_decon
	max_occurrences = 0
	category = EVENT_CATEGORY_ENGINEERING
	description = "Decontaminates distro & connected unary vents of plasma. Get blueballed, griffman."

/datum/round_event/plasma_decon
	announce_when	= 1
	start_when		= 5
	end_when			= 35
	var/list/vents  = list()

/datum/round_event/plasma_decon/setup()
	end_when = rand(25, 100)
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/temp_vent in GLOB.machines)
		var/turf/T = get_turf(temp_vent)
		if(T && is_station_level(T.z) && !temp_vent.welded)
			vents += temp_vent
	if(!vents.len)
		return kill()

/datum/round_event/plasma_decon/announce()
	priority_announce("We are deploying an experimental plasma decontamination system. Please stand away from the vents and do not breathe the smoke that comes out.", "Central Command Update", SSstation.announcer.get_rand_alert_sound())

/datum/round_event/plasma_decon/start()
	for(var/obj/machinery/atmospherics/components/unary/vent in vents)
		if(vent?.loc)
			var/datum/effect_system/smoke_spread/freezing/decon/smoke = new
			smoke.set_up(7, get_turf(vent), 7)
			smoke.start()
		CHECK_TICK
