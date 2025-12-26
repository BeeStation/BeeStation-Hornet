/datum/orbital_object/z_linked/lavaland
	name = "Cinis"
	mass = 10000
	radius = 2000
	random_docking = TRUE
	render_mode = RENDER_MODE_PLANET
	priority = 90

/datum/orbital_object/z_linked/lavaland/New()
	. = ..()
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	linked_map.center = src

/////////////////////////////////////////////////// Moon 1:
// CC and nukies
/datum/orbital_object/z_linked/neo
	name = "Neo"
	mass = 0 // Nothing orbits this thing anyways
	radius = 100
	render_mode = RENDER_MODE_PLANET
	priority = 20

/datum/orbital_object/z_linked/neo/post_map_setup()
	//Orbit around the systems sun
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	set_orbitting_around_body(linked_map.center, 3000)

/////////////////////////////////////////////////// Moon 2:
// Echo / Thallos
// This is a placeholder that gets replaced by the station if planetary_station is true
/datum/orbital_object/echoplanet
	name = "Thallos"
	mass = 3000
	radius = 600
	render_mode = RENDER_MODE_PLANET
	priority = 20

/datum/orbital_object/echoplanet/post_map_setup()
	//Orbit around the systems sun
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	set_orbitting_around_body(linked_map.center, 20000)
