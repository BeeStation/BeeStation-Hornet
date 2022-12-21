/datum/orbital_map
	//the primary star. Set to be lavaland by default.
	var/datum/orbital_object/center = null
	//A list of bodies too large to have optimised collision zones
	var/list/large_bodies = list()
	//A list of all bodies in their assigned collision zones
	var/list/collision_zone_bodies = list()
	//Object count
	var/object_count

/datum/orbital_map/proc/add_body(datum/orbital_object/body)
	object_count ++
	if(body.radius > ORBITAL_MAX_RADIUS)
		large_bodies += body
		return
	//Add the orbital body in the correct collision zone
	var/position_key = "[round(body.position.GetX() / ORBITAL_MAP_ZONE_SIZE)],[round(body.position.GetY() / ORBITAL_MAP_ZONE_SIZE)]"
	LAZYADDASSOCLIST(collision_zone_bodies, position_key, body)

/datum/orbital_map/proc/remove_body(datum/orbital_object/body)
	object_count --
	if(body.radius > ORBITAL_MAX_RADIUS)
		large_bodies -= body
		return
	//Find the objects collision zone and remove it
	var/position_key = "[round(body.position.GetX() / ORBITAL_MAP_ZONE_SIZE)],[round(body.position.GetY() / ORBITAL_MAP_ZONE_SIZE)]"
	if(!(body in collision_zone_bodies[position_key]))
		//Mass search for ourselves
		for(var/zone in collision_zone_bodies)
			LAZYREMOVEASSOC(collision_zone_bodies, zone, body)
		CRASH("An orbital object was removed from [position_key] but was not there in the first place. ([body]). Is a body being improperly moved? (performed a slow deletion to prevent hard-dels)")
	LAZYREMOVEASSOC(collision_zone_bodies, position_key, body)

/datum/orbital_map/proc/on_body_move(datum/orbital_object/body, prev_x, prev_y)
	if(body.radius > ORBITAL_MAX_RADIUS)
		return
	//Find the objects old collision zone and remove it
	//Find the objects new collision zone and add it
	var/pre_position_key = "[round(prev_x / ORBITAL_MAP_ZONE_SIZE)],[round(prev_y / ORBITAL_MAP_ZONE_SIZE)]"
	var/post_position_key = "[round(body.position.GetX() / ORBITAL_MAP_ZONE_SIZE)],[round(body.position.GetY() / ORBITAL_MAP_ZONE_SIZE)]"
	if(pre_position_key == post_position_key)
		return
	LAZYREMOVEASSOC(collision_zone_bodies, pre_position_key, body)
	LAZYADDASSOCLIST(collision_zone_bodies, post_position_key, body)

/datum/orbital_map/proc/get_all_bodies()
	. = list()
	for(var/zone in collision_zone_bodies)
		. += collision_zone_bodies[zone]
	. += large_bodies

//Returns a list of gravitationally relevant bodies.
/datum/orbital_map/proc/get_relevnant_bodies(datum/orbital_object/source)
	. = list()
	//Get all orbital bodies on the map.
	for(var/datum/orbital_object/body as() in get_all_bodies())
		//Distance check last for optimisations
		if(body != source && body.relevant_gravity_range && source.position.DistanceTo(body.position) <= body.relevant_gravity_range)
			. += body

//Post setup function that runs after SSorbit init.
//Moves map objects to the correct positions and gives them velocities so that they can orbit dynamically.
/datum/orbital_map/proc/post_setup()
	for(var/datum/orbital_object/body as() in get_all_bodies())
		body.post_map_setup()
