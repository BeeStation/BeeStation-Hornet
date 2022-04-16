/datum/round_event_control/beer_clog
	name = "Foamy beer stationwide"
	typepath = /datum/round_event/beer_clog
	max_occurrences = 0
	auto_add = FALSE

/datum/round_event/beer_clog
	var/list/vents  = list()
	announceWhen	= 1
	startWhen		= 5
	endWhen			= 35

/datum/round_event/beer_clog/setup()
	endWhen = rand(25, 100)
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/temp_vent in GLOB.machines)
		var/turf/T = get_turf(temp_vent)
		if(T && is_station_level(T.z) && !temp_vent.welded)
			vents += temp_vent
	if(!length(vents))
		return kill()


/datum/round_event/beer_clog/announce()
	priority_announce("The scrubbers network is experiencing an unexpected surge of pressurized beer. Some ejection of contents may occur.", "Atmospherics alert", SSstation.announcer.get_rand_alert_sound())


/datum/round_event/beer_clog/start()
	for(var/obj/machinery/atmospherics/components/unary/vent in vents)
		if(!vent.loc)
			CRASH("A vent got added to the list of vents without a location!")
		var/datum/reagents/R = new/datum/reagents(1000)
		R.my_atom = vent
		R.add_reagent(/datum/reagent/consumable/ethanol/beer, 100)

		var/datum/effect_system/foam_spread/foam = new
		foam.set_up(200, get_turf(vent), R)
		foam.start()
		CHECK_TICK
