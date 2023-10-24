/obj/machinery/bluespace_beacon

	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_beaconf"
	name = "bluespace gigabeacon"
	desc = "A device that draws power from bluespace and creates a permanent tracking beacon."
	layer = LOW_OBJ_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 0
	var/obj/item/beacon/Beacon

/obj/machinery/bluespace_beacon/Initialize(mapload)
	. = ..()
	var/turf/T = loc
	Beacon = new(T)
	Beacon.invisibility = INVISIBILITY_MAXIMUM

	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE)

/obj/machinery/bluespace_beacon/Destroy()
	QDEL_NULL(Beacon)
	return ..()

/obj/machinery/bluespace_beacon/process()
	if(QDELETED(Beacon)) //Don't move it out of nullspace BACK INTO THE GAME for the love of god
		var/turf/T = loc
		Beacon = new(T)
		Beacon.invisibility = INVISIBILITY_MAXIMUM
	else if (Beacon.loc != loc)
		Beacon.forceMove(loc)

/obj/structure/iceland_beacon
	name = "Frozen bluespace beacon"
	desc = "A receiving beacon for tracking and locating."
	icon = 'icons/obj/device.dmi'
	icon_state = "Prison_beacon"
	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE
	light_range = 2
	light_power = 1
	light_color = "#850000"
	var/gps = null

GLOBAL_LIST_INIT(icebeacons, list())
/obj/structure/iceland_beacon/Initialize(mapload)
	. = ..()
	for(var/turf/closed/mineral/M in RANGE_TURFS(1, src))
		M.ScrapeAway(null, CHANGETURF_IGNORE_AIR)
	AddComponent(/datum/component/gps, gps)
	GLOB.icebeacons += src
