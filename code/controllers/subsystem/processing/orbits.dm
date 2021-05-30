PROCESSING_SUBSYSTEM_DEF(orbits)
	name = "Orbits"
	flags = SS_KEEP_TIMING | SS_NO_INIT
	//init_order = INIT_ORDER_ORBITS
	priority = FIRE_PRIORITY_ORBITS
	wait = ORBITAL_UPDATE_RATE

	//The primary orbital map.
	var/datum/orbital_map/orbital_map = new()

	var/datum/orbital_map_tgui/orbital_map_tgui = new()

	var/initial_objective_beacons = 4

	//key = port_id
	//value = orbital shuttle object
	var/list/assoc_shuttles = list()

/datum/controller/subsystem/processing/orbits/proc/post_load_init()
	orbital_map.post_setup()
	//Create initial ruins

/datum/controller/subsystem/processing/orbits/fire(resumed)
	//Check creating objectives / missions.
	//Do processing.
	. = ..()

/mob/dead/observer/verb/open_orbit_ui()
	set name = "View Orbits"
	set category = "Ghost"
	SSorbits.orbital_map_tgui.ui_interact(src)
