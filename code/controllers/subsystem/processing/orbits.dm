PROCESSING_SUBSYSTEM_DEF(orbits)
	name = "Orbits"
	flags = SS_KEEP_TIMING
	init_order = INIT_ORDER_STATION
	priority = FIRE_PRIORITY_ORBITS
	wait = ORBITAL_UPDATE_RATE

	//The primary orbital map.
	var/datum/orbital_map/orbital_map

	var/datum/orbital_map_tgui/orbital_map_tgui = new()

/datum/controller/subsystem/processing/orbits/Initialize(timeofday)
	. = ..()
	orbital_map = new()

/client/verb/open_orbit_ui()
	set name = "open orbit ui"
	set category = "orbits"
	SSorbits.orbital_map_tgui.ui_interact(mob)
