/datum/orbital_object/auri_geminae
	name = "Auri Geminae"
	mass = 100000
	radius = 100000
	static_object = TRUE
	render_mode = RENDER_MODE_PLANET
	priority = 100

/datum/orbital_object/auri_geminae/New()
	. = ..()
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	linked_map.center = src

/datum/orbital_object/z_linked/lavaland
	name = "Cinis"
	mass = 10000
	radius = 2000
	static_object = TRUE
	random_docking = TRUE
	render_mode = RENDER_MODE_PLANET
	priority = 90

/datum/orbital_object/z_linked/lavaland/post_map_setup()
	//Orbit around Auri Geminae
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	set_orbitting_around_body(linked_map.center, 200000)

/datum/orbital_object/z_linked/neo
	name = "Neo"
	mass = 0 // Nothing orbits this thing anyways
	radius = 100
	render_mode = RENDER_MODE_PLANET
	priority = 20

/datum/orbital_object/z_linked/neo/post_map_setup()
	//Orbit around Cinis
	var/datum/orbital_object/cinis = SSorbits.find_orbital_object_by_name("Cinis")
	if(cinis)
		set_orbitting_around_body(cinis, 4000)
	else
		var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
		set_orbitting_around_body(linked_map.center, 200000)

/datum/orbital_object/thetis
	name = "Thetis"
	mass = 30000
	radius = 5000
	static_object = TRUE
	render_mode = RENDER_MODE_PLANET
	priority = 30

/datum/orbital_object/thetis/post_map_setup()
	//Orbit Auri Geminae at a far distance
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	set_orbitting_around_body(linked_map.center, 400000)

// This is a placeholder that gets replaced by the station if planetary_station is true
/datum/orbital_object/echoplanet
	name = "Thallos"
	mass = 3000
	radius = 600
	render_mode = RENDER_MODE_PLANET
	priority = 20

/datum/orbital_object/echoplanet/post_map_setup()
	//Orbit Thetis
	var/datum/orbital_object/thetis = SSorbits.find_orbital_object_by_name("Thetis")
	if(thetis)
		set_orbitting_around_body(thetis, 17000)
	else
		var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
		set_orbitting_around_body(linked_map.center, 200000)

/datum/orbital_object/triea
	name = "Triea"
	mass = 100
	radius = 1000
	static_object = TRUE
	render_mode = RENDER_MODE_PLANET
	priority = 15

/datum/orbital_object/triea/post_map_setup()
	//Extremely far orbit around Auri Geminae
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	set_orbitting_around_body(linked_map.center, 1000000)
