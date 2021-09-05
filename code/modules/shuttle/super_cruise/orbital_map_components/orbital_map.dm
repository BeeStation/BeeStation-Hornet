/datum/orbital_map
	//the primary star. Set to be lavaland by default.
	var/datum/orbital_object/center = null
	//A list of all bodies in their assigned collision zones
	var/list/collision_zone_bodies = list()
	//Object count
	var/object_count

/datum/orbital_map/proc/add_body(datum/orbital_object/body)
	//Add the orbital body in the correct collision zone
	var/position_key = "[round(body.position.x / ORBITAL_MAP_ZONE_SIZE)],[round(body.position.y / ORBITAL_MAP_ZONE_SIZE)]"
	LAZYADDASSOCLIST(collision_zone_bodies, position_key, body)
	object_count ++

/datum/orbital_map/proc/remove_body(datum/orbital_object/body)
	//Find the objects collision zone and remove it
	var/position_key = "[round(body.position.x / ORBITAL_MAP_ZONE_SIZE)],[round(body.position.y / ORBITAL_MAP_ZONE_SIZE)]"
	LAZYREMOVEASSOC(collision_zone_bodies, position_key, body)
	object_count --

/datum/orbital_map/proc/on_body_move(datum/orbital_object/body, prev_x, prev_y)
	//Find the objects old collision zone and remove it
	//Find the objects new collision zone and add it
	var/pre_position_key = "[round(prev_x / ORBITAL_MAP_ZONE_SIZE)],[round(prev_y / ORBITAL_MAP_ZONE_SIZE)]"
	var/post_position_key = "[round(body.position.x / ORBITAL_MAP_ZONE_SIZE)],[round(body.position.y / ORBITAL_MAP_ZONE_SIZE)]"
	if(pre_position_key == post_position_key)
		return
	LAZYREMOVEASSOC(collision_zone_bodies, pre_position_key, body)
	LAZYADDASSOCLIST(collision_zone_bodies, post_position_key, body)

//Returns a list of gravitationally relevant bodies.
/datum/orbital_map/proc/get_relevnant_bodies(datum/orbital_object/source)
	. = list()
	//Get all orbital bodies on the map.
	for(var/collision_zone in collision_zone_bodies)
		for(var/datum/orbital_object/body as() in collision_zone_bodies[collision_zone])
			//Distance check last for optimisations
			if(body != source && body.relevant_gravity_range && source.position.Distance(body.position) <= body.relevant_gravity_range)
				. += body

//Post setup function that runs after SSorbit init.
//Moves map objects to the correct positions and gives them velocities so that they can orbit dynamically.
/datum/orbital_map/proc/post_setup()
	for(var/collision_zone in collision_zone_bodies)
		for(var/datum/orbital_object/body as() in collision_zone_bodies[collision_zone])
			body.post_map_setup()
