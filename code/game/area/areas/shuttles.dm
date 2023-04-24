
//These are shuttle areas; all subtypes are only used as teleportation markers, they have no actual function beyond that.
//Multi area shuttles are a thing now, use subtypes! ~ninjanomnom

/area/shuttle
	name = "Shuttle"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	has_gravity = STANDARD_GRAVITY
	always_unpowered = FALSE
	// Loading the same shuttle map at a different time will produce distinct area instances.
	area_flags = NONE
	lighting_colour_tube = "#fff0dd"
	lighting_colour_bulb = "#ffe1c1"
	sound_environment = SOUND_ENVIRONMENT_ROOM
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_ADVANCED
	//The mobile port attached to this area
	var/obj/docking_port/mobile/mobile_port
	area_limited_icon_smoothing = /area/shuttle

/area/shuttle/Initialize(mapload)
	if(!canSmoothWithAreas)
		canSmoothWithAreas = type
	. = ..()

/area/shuttle/Destroy()
	mobile_port = null
	. = ..()

//Returns how many shuttles are missing a skipovers on a given turf, this usually represents how many shuttles have hull breaches on this turf. This only works if this is the actual area of T when called.
//TODO: optimize this somehow
/area/shuttle/proc/get_missing_shuttles(turf/T)
	var/i = 0
	var/BT_index = length(T.baseturfs)
	var/area/shuttle/A
	var/obj/docking_port/mobile/S
	var/list/shuttle_stack = list(mobile_port) //Indexing through a list helps prevent looped directed graph errors.
	. = 0
	while(i++ < shuttle_stack.len)
		S = shuttle_stack[i]
		A = S.underlying_turf_area[T]
		if(istype(A) && A.mobile_port)
			shuttle_stack |= A.mobile_port
		.++
	for(BT_index in 1 to length(T.baseturfs))
		if(ispath(T.baseturfs[BT_index], /turf/baseturf_skipover/shuttle))
			.--

/area/shuttle/PlaceOnTopReact(turf/T, list/new_baseturfs, turf/fake_turf_type, flags)
	. = ..()
	if(!length(new_baseturfs) || !ispath(new_baseturfs[1], /turf/baseturf_skipover/shuttle) && (!ispath(new_baseturfs[1], /turf/open/floor/plating) || length(new_baseturfs) > 1 || fake_turf_type))
		return //Only add missing baseturfs if a shuttle is landing or player made plating is being added (player made is infered to be a new_baseturf list of 1 and no fake_turf_type)
	for(var/i in 1 to get_missing_shuttles(T))
		new_baseturfs.Insert(1,/turf/baseturf_skipover/shuttle)

/area/shuttle/proc/link_to_shuttle(obj/docking_port/mobile/M)
	mobile_port = M

/area/shuttle/get_virtual_z(turf/T)
	if(mobile_port && is_reserved_level(mobile_port.z))
		return mobile_port.current_z
	return ..(T)

////////////////////////////Multi-area shuttles////////////////////////////

////////////////////////////Syndicate infiltrator////////////////////////////

/area/shuttle/syndicate
	name = "Syndicate Infiltrator"
	ambience_index = AMBIENCE_DANGER
	canSmoothWithAreas = /area/shuttle/syndicate
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_MAXIMUM

/area/shuttle/syndicate/bridge
	name = "Syndicate Infiltrator Control"

/area/shuttle/syndicate/medical
	name = "Syndicate Infiltrator Medbay"

/area/shuttle/syndicate/armory
	name = "Syndicate Infiltrator Armory"

/area/shuttle/syndicate/eva
	name = "Syndicate Infiltrator EVA"

/area/shuttle/syndicate/hallway

/area/shuttle/syndicate/airlock
	name = "Syndicate Infiltrator Airlock"

////////////////////////////Pirate Shuttle////////////////////////////

/area/shuttle/pirate
	name = "Pirate Shuttle"
	requires_power = TRUE
	canSmoothWithAreas = /area/shuttle/pirate

////////////////////////////Bounty Hunter Shuttles////////////////////////////

/area/shuttle/hunter
	name = "Hunter Shuttle"
	requires_power = TRUE
	canSmoothWithAreas = /area/shuttle/hunter

////////////////////////////White Ship////////////////////////////

/area/shuttle/abandoned
	name = "Abandoned Ship"
	requires_power = TRUE
	canSmoothWithAreas = /area/shuttle/abandoned

/area/shuttle/abandoned/bridge
	name = "Abandoned Ship Bridge"

/area/shuttle/abandoned/engine
	name = "Abandoned Ship Engine"

/area/shuttle/abandoned/bar
	name = "Abandoned Ship Bar"

/area/shuttle/abandoned/crew
	name = "Abandoned Ship Crew Quarters"

/area/shuttle/abandoned/cargo
	name = "Abandoned Ship Cargo Bay"

/area/shuttle/abandoned/medbay
	name = "Abandoned Ship Medbay"

/area/shuttle/abandoned/pod
	name = "Abandoned Ship Pod"

////////////////////////////Single-area shuttles////////////////////////////

/area/shuttle/transit
	name = "Hyperspace"
	desc = "Weeeeee"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/shuttle/custom
	name = "Custom player shuttle"

/area/shuttle/custom/powered
	name = "Custom Powered player shuttle"
	requires_power = FALSE

/area/shuttle/arrival
	name = "Arrival Shuttle"
	area_flags = UNIQUE_AREA// SSjob refers to this area for latejoiners

/area/shuttle/pod_1
	name = "Escape Pod One"
	area_flags = BLOBS_ALLOWED

/area/shuttle/pod_2
	name = "Escape Pod Two"
	area_flags = BLOBS_ALLOWED

/area/shuttle/pod_3
	name = "Escape Pod Three"
	area_flags = BLOBS_ALLOWED

/area/shuttle/pod_4
	name = "Escape Pod Four"
	area_flags = BLOBS_ALLOWED

/area/shuttle/mining
	name = "Mining Shuttle"

/area/shuttle/mining/large
	name = "Mining Shuttle"
	requires_power = TRUE

/area/shuttle/science
	name = "Science Shuttle"
	requires_power = TRUE

/area/shuttle/exploration
	name = "Exploration Shuttle"
	requires_power = TRUE

/area/shuttle/labor
	name = "Labor Camp Shuttle"

/area/shuttle/supply
	name = "Supply Shuttle"

/area/shuttle/escape
	name = "Emergency Shuttle"

/area/shuttle/escape/backup
	name = "Backup Emergency Shuttle"

/area/shuttle/escape/luxury
	name = "Luxurious Emergency Shuttle"
	teleport_restriction = TELEPORT_ALLOW_NONE

/area/shuttle/escape/arena
	name = "The Arena"
	teleport_restriction = TELEPORT_ALLOW_NONE

/area/shuttle/escape/meteor
	name = "\proper a meteor with engines strapped to it"
	luminosity = NONE

/area/shuttle/transport
	name = "Transport Shuttle"

/area/shuttle/assault_pod
	name = "Steel Rain"

/area/shuttle/sbc_starfury
	name = "SBC Starfury"

/area/shuttle/sbc_fighter1
	name = "SBC Fighter 1"

/area/shuttle/sbc_fighter2
	name = "SBC Fighter 2"

/area/shuttle/sbc_corvette
	name = "SBC corvette"

/area/shuttle/syndicate_scout
	name = "Syndicate Scout"
	airlock_hack_difficulty = AIRLOCK_WIRE_SECURITY_MAXIMUM

/area/shuttle/caravan
	requires_power = TRUE

/area/shuttle/caravan/syndicate1
	name = "Syndicate Fighter"

/area/shuttle/caravan/syndicate2
	name = "Syndicate Fighter"

/area/shuttle/caravan/syndicate3
	name = "Syndicate Drop Ship"

/area/shuttle/caravan/pirate
	name = "Pirate Cutter"

/area/shuttle/caravan/freighter1
	name = "Small Freighter"

/area/shuttle/caravan/freighter2
	name = "Tiny Freighter"

/area/shuttle/caravan/freighter3
	name = "Tiny Freighter"
