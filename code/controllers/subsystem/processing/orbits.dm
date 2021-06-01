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

	var/orbits_setup = FALSE

	var/datum/orbital_objective/current_objective

	//key = port_id
	//value = orbital shuttle object
	var/list/assoc_shuttles = list()

/datum/controller/subsystem/processing/orbits/proc/post_load_init()
	orbital_map.post_setup()
	orbits_setup = TRUE
	//Create initial ruins
	for(var/i in 1 to initial_objective_beacons)
		new /datum/orbital_object/z_linked/beacon/ruin()

/datum/controller/subsystem/processing/orbits/fire(resumed)
	//Check creating objectives / missions.
	if(!current_objective && prob(0.5))
		create_objective()
	//Check objective
	if(current_objective)
		if(current_objective.check_failed())
			priority_announce("Central Command priority objective failed.", "Central Command Report", SSstation.announcer.get_rand_report_sound())
			QDEL_NULL(current_objective)
	//Do processing.
	. = ..()

/mob/dead/observer/verb/open_orbit_ui()
	set name = "View Orbits"
	set category = "Ghost"
	SSorbits.orbital_map_tgui.ui_interact(src)

/datum/controller/subsystem/processing/orbits/proc/create_objective()
	var/static/list/valid_objectives = list(
		/datum/orbital_objective/recover_blackbox = 6
	)
	var/chosen = pickweight(valid_objectives)
	if(!chosen)
		return
	var/datum/orbital_objective/objective = new chosen()
	objective.generate_payout()
	objective.generate_attached_beacon()
	objective.announce()
	current_objective = objective
