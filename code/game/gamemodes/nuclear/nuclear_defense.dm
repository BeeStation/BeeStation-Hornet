/datum/game_mode/nuclear/defense
	name = "Nuclear Defense"
	config_tag = "goonops"

	announce_span = "danger"
	announce_text = "Syndicate forces are approaching the station in an attempt to destroy it!\n\
	<span class='danger'>Operatives</span>: Escort the device to one of the designated areas.\n\
	<span class='notice'>Crew</span>: Prevent the bomb from being planted, or destroy it.\n\
	<span class='notice'>Both</span>: The disk will double the countdown of the bomb!"

	var/list/area/target_zones
	var/max_zones = 3

/datum/game_mode/nuclear/defense/pre_setup() //Stolen from clownops.
	. = ..()
	if(.)
		for(var/obj/machinery/nuclearbomb/syndicate/S in GLOB.nuke_list)
			var/turf/T = get_turf(S)
			if(T)
				qdel(S)
				var/obj/machinery/nuclearbomb/syndicate/proto/thebomb = new /obj/machinery/nuclearbomb/syndicate/proto(T)
				var/panic = 0
				target_zones = list()
				while(length(target_zones) < 3 && panic < 100)
					var/area/target = pick(GLOB.sortedAreas - target_zones)
					if(target && is_station_level(target.z) && target.valid_territory)
						target_zones += target
					panic++
				thebomb.target_areas = target_zones


/datum/game_mode/nuclear/defense/generate_report()
	return "Cybersun Industries has recently been in contact with a secretive nuclear physicist with a background in high-grade weaponry. \
			We believe that they may be attempting to produce a weapon of mass destruction for use against our stations. While the formulas required \
			are hardly top secret, they are quite slow, thus the nuclear authentication disk on your vessel may be of use to them, protect it at all costs."

/datum/team/nuclear/defense/get_result()
	//This is essentially a remapper, as NOSURVIVORS is the intended victory condition.
	. = ..()
	switch(.)
		if(NUKE_RESULT_NOSURVIVORS)
			return NUKE_RESULT_NUKE_WIN
		if(NUKE_RESULT_DISK_LOST)
			return NUKE_RESULT_CREW_WIN
		else
			return //Everything else can fall through
