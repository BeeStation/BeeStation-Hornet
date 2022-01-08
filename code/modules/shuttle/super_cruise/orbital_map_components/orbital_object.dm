/datum/orbital_object
	var/name = "undefined"
	//Mass of the object in solar masses
	var/mass = 0
	//Radius of the object in parsecs
	var/radius = 1
	//Position of the object (0,0) is the center of the map.
	//Position is in kilometers
	//If this is modified, on_body_move() MUST be called. (Really this should be a helper proc)
	var/datum/orbital_vector/position = new()
	//Velocity of the object
	//KILOMETERS PER SECOND
	var/datum/orbital_vector/velocity = new()
	//Static objects don't get moved.
	var/static_object = FALSE
	//Does the object actively thrust to maintain a stable orbit?
	var/maintain_orbit = FALSE
	//The object in which we are trying to maintain a stable orbit around.
	var/datum/orbital_object/target_orbital_body
	//Are we invisible on the map?
	var/stealth = FALSE
	//Multiplier for velocity
	var/velocity_multiplier = 1

	//Delta time updates
	//Ship translations are smooth so must use a delta time
	//Dont get confused with subsystem delta_time as this accounts for time dilation
	var/last_update_tick = 0

	//CALCULATED IN INIT
	//Once objects are outside of this range, we will not apply gravity to them.
	var/relevant_gravity_range
	//Are we force-orbitting something?
	var/orbitting = FALSE
	//The relative velocity required for a stable orbit
	var/relative_velocity_required
	//Bodies that are orbitting us.
	var/list/orbitting_bodies = list()
	//Are we currently immune to collisions
	var/collision_ignored = TRUE
	//What are we colliding with
	var/list/datum/orbital_object/colliding_with

	//The index or the orbital map we exist in
	var/orbital_map_index = PRIMARY_ORBITAL_MAP

	//Our collision type
	var/collision_type = COLLISION_UNDEFINED
	//The collision flags we register with
	var/collision_flags = NONE

/datum/orbital_object/New(datum/orbital_vector/position, datum/orbital_vector/velocity, orbital_map_index)
	if(orbital_map_index)
		src.orbital_map_index = orbital_map_index
	if(position)
		src.position = position
	if(velocity)
		src.velocity = velocity
	. = ..()
	//Calculate relevant grav range
	relevant_gravity_range = sqrt((mass * GRAVITATIONAL_CONSTANT) / MINIMUM_EFFECTIVE_GRAVITATIONAL_ACCEELRATION)
	//Process this
	if(!static_object)
		START_PROCESSING(SSorbits, src)
	//Add to orbital map
	var/datum/orbital_map/map = SSorbits.orbital_maps[src.orbital_map_index]
	map.add_body(src)
	//If orbits has already setup, then post map setup
	if(SSorbits.orbits_setup)
		post_map_setup()

/datum/orbital_object/Destroy()
	STOP_PROCESSING(SSorbits, src)
	var/datum/orbital_map/map = SSorbits.orbital_maps[orbital_map_index]
	map.remove_body(src)
	LAZYREMOVE(target_orbital_body?.orbitting_bodies, src)
	if(length(orbitting_bodies))
		for(var/datum/orbital_object/orbitting_bodies in orbitting_bodies)
			orbitting_bodies.target_orbital_body = null
		orbitting_bodies.Cut()
	. = ..()

/datum/orbital_object/proc/explode()
	return

//Process orbital objects, calculate gravity
/datum/orbital_object/process()
	//Dont process updates for static objects.
	if(static_object)
		return PROCESS_KILL

	//NOTE TO SELF: This does nothing because world.time is in ticks not realtime.
	var/delta_time = 0
	if(last_update_tick)
		//Don't go too crazy.
		delta_time = CLAMP(world.time - last_update_tick, 10, 50) * 0.1
	else
		delta_time = 1
	last_update_tick = world.time

	var/datum/orbital_map/parent_map = SSorbits.orbital_maps[orbital_map_index]

	//===================================
	// GRAVITATIONAL ATTRACTION
	//===================================
	//Gravity is not considered while we have just undocked and are at the center of a massive body.
	if(!collision_ignored)
		//Find relevant gravitational bodies.
		var/list/gravitational_bodies =parent_map.get_relevnant_bodies(src)
		//Calculate acceleration vector
		var/datum/orbital_vector/acceleration_per_second = new()
		//Calculate gravity
		for(var/datum/orbital_object/gravitational_body as() in gravitational_bodies)
			//https://en.wikipedia.org/wiki/Gravitational_acceleration
			var/distance = position.Distance(gravitational_body.position)
			if(!distance)
				continue
			var/acceleration_amount = (GRAVITATIONAL_CONSTANT * gravitational_body.mass) / (distance * distance)
			//Calculate acceleration direction
			var/datum/orbital_vector/direction = new (gravitational_body.position.x - position.x, gravitational_body.position.y - position.y)
			direction.Normalize()
			direction.Scale(acceleration_amount)
			//Add on the gravitational acceleration
			acceleration_per_second.Add(direction)
		//Divide acceleration per second by the tick rate
		accelerate_towards(acceleration_per_second, delta_time)

	//===================================
	// ORBIT CORRECTION
	//===================================
	//Some objects may automatically thrust to maintain a stable orbit
	if(maintain_orbit && target_orbital_body)
		//Velocity should always be perpendicular to the planet
		var/datum/orbital_vector/perpendicular_vector = new(position.y - target_orbital_body.position.y, target_orbital_body.position.x - position.x)
		//Calculate the relative velocity we should have
		perpendicular_vector.Normalize()
		perpendicular_vector.Scale(relative_velocity_required)
		//Set it because we are a lazy shit
		velocity = perpendicular_vector.Add(target_orbital_body.velocity)

	//===================================
	// MOVEMENT
	//===================================
	//Remember this
	var/prev_x = position.x
	var/prev_y = position.y

	//Move the gravitational body.
	var/datum/orbital_vector/vel_new = new(velocity.x * delta_time * velocity_multiplier, velocity.y * delta_time * velocity_multiplier)
	position.Add(vel_new)

	//Oh we moved btw
	parent_map.on_body_move(src, prev_x, prev_y)

	//===================================
	// COLLISION CHECKING
	//===================================
	var/colliding = FALSE
	LAZYCLEARLIST(colliding_with)

	//Calculate our current position
	var/section_x = round(position.x / ORBITAL_MAP_ZONE_SIZE)
	var/section_y = round(position.y / ORBITAL_MAP_ZONE_SIZE)

	var/position_key = "[section_x],[section_y]"
	var/valid_side_key = "none"
	var/valid_front_key = "none"
	var/valid_corner_key = "none"

	var/dir_flags = NONE

	var/segment_x = (position.x + abs(section_x) * ORBITAL_MAP_ZONE_SIZE) % ORBITAL_MAP_ZONE_SIZE
	var/segment_y = (position.y + abs(section_y) * ORBITAL_MAP_ZONE_SIZE) % ORBITAL_MAP_ZONE_SIZE

	if(segment_x < ORBITAL_MAP_ZONE_SIZE / 3)
		valid_side_key = "[section_x - 1],[section_y]"
		dir_flags |= WEST
	else if(segment_x > 2 * (ORBITAL_MAP_ZONE_SIZE / 3))
		valid_side_key = "[section_x + 1],[section_y]"
		dir_flags |= EAST

	if(segment_y < ORBITAL_MAP_ZONE_SIZE / 3)
		valid_front_key = "[section_x],[section_y - 1]"
		dir_flags |= SOUTH
	else if(segment_y > 2 * (ORBITAL_MAP_ZONE_SIZE / 3))
		valid_front_key = "[section_x],[section_y + 1]"
		dir_flags |= NORTH

	//Check multiple zones
	if(dir_flags & EAST)
		if(dir_flags & NORTH)
			valid_corner_key = "[section_x + 1],[section_y + 1]"
		else if(dir_flags & SOUTH)
			valid_corner_key = "[section_x + 1],[section_y - 1]"
	else if(dir_flags & WEST)
		if(dir_flags & NORTH)
			valid_corner_key = "[section_x - 1],[section_y + 1]"
		else if(dir_flags & SOUTH)
			valid_corner_key = "[section_x - 1],[section_y - 1]"

	var/list/valid_objects = list()

	//Only check nearby segments for collision objects
	if(parent_map.collision_zone_bodies[position_key])
		valid_objects += parent_map.collision_zone_bodies[position_key]
	if(parent_map.collision_zone_bodies[valid_side_key])
		valid_objects += parent_map.collision_zone_bodies[valid_side_key]
	if(parent_map.collision_zone_bodies[valid_front_key])
		valid_objects += parent_map.collision_zone_bodies[valid_front_key]
	if(parent_map.collision_zone_bodies[valid_corner_key])
		valid_objects += parent_map.collision_zone_bodies[valid_corner_key]

	//Track our delta positional values for collision detection purposes
	var/delta_x = position.x - prev_x
	var/delta_y = position.y - prev_y

	for(var/datum/orbital_object/object as() in valid_objects)
		if(object == src)
			continue
		if(!((collision_flags & object.collision_type) || (object.collision_flags & collision_type)))
			continue
		var/distance = object.position.Distance(position)
		if(distance < radius + object.radius)
			//Collision
			LAZYADD(colliding_with, object)
			collision(object)
			//Static objects dont check collisions, so call their collision proc for them.
			if(object.static_object)
				object.collision(src)
			colliding = TRUE
		else if(!object.static_object)
			//Vector collision.
			//Note: We detect collisions that occursed in the current move rather than in the next.
			//Position - Velocity -> Position
			//Detects collisions for when 2 objects pass each other.
			//Get the intersection point
			//Must be between 0 and 1
			var/other_x
			var/other_y
			var/other_delta_x = object.velocity.x
			var/other_delta_y = object.velocity.y
			if(object.last_update_tick == last_update_tick)
				//They are on the same tick as us
				other_x = object.position.x - other_delta_x
				other_y = object.position.y - other_delta_y
			else
				//They are still on the previous tick
				other_x = object.position.x
				other_y = object.position.y
			//ALRIGHT LETS DO THE CHECK
			//Reassign variables for ease of read.
			var/px = prev_x
			var/py = prev_y
			var/vx = delta_x
			var/vy = delta_y
			var/px2 = other_x
			var/py2 = other_y
			var/vx2 = other_delta_x
			var/vy2 = other_delta_y
			//Both must be moving
			if((vx || vy) && (vx2 || vy2))
				//Collision between 2 vectors using simultaneous equations.
				var/mu = (vx * py2 + vy * px - py * vx - vy * px2) / (vy * vx2 - vx * vy2)
				var/lambda = (px2 + vx2 * mu - px) / vx
				if(lambda >= 0 && lambda <= 1 && mu >= 0 && mu <= 1)
					//Collision
					LAZYADD(colliding_with, object)
					collision(object)
					colliding = TRUE
	if(!colliding)
		collision_ignored = FALSE

//We do a little suvatting
/datum/orbital_object/proc/accelerate_towards(datum/orbital_vector/acceleration_vector, time)
	velocity.Add(acceleration_vector.Scale(time))

//Called when we collide with another orbital object.
//Make sure to check if(other.collision_ignored || collision_ignored)
/datum/orbital_object/proc/collision(datum/orbital_object/other)
	return

/datum/orbital_object/proc/set_orbitting_around_body(datum/orbital_object/target_body, orbit_radius = 10, force = FALSE)
	if(orbitting && !force)
		return
	var/prev_x = position.x
	var/prev_y = position.y
	orbitting = TRUE
	//Calculates the required velocity for the object to orbit around the target body.
	//Hopefully the planets gravity doesn't fuck with each other too hard.
	//Set position
	var/delta_x = -position.x
	var/delta_y = -position.y
	position.x = target_body.position.x + orbit_radius
	position.y = target_body.position.y
	delta_x += position.x
	delta_y += position.y
	//Move all orbitting b()odies too.
	if(orbitting_bodies)
		for(var/datum/orbital_object/object in orbitting_bodies)
			object.position.Add(new /datum/orbital_vector(delta_x, delta_y))
	//Set velocity
	var/relative_velocity = sqrt((GRAVITATIONAL_CONSTANT * (target_body.mass + mass)) / orbit_radius)
	velocity.x = target_body.velocity.x
	velocity.y = target_body.velocity.y + relative_velocity
	//Set random angle
	var/random_angle = rand(0, 360)	//Is cos and sin in radians?
	position.Rotate(random_angle)
	velocity.Rotate(random_angle)
	//Update target
	target_orbital_body = target_body
	LAZYADD(target_body.orbitting_bodies, src)
	relative_velocity_required = relative_velocity
	//We moved, make sure to update the map.
	var/datum/orbital_map/parent_map = SSorbits.orbital_maps[orbital_map_index]
	parent_map.on_body_move(src, prev_x, prev_y)

/datum/orbital_object/proc/post_map_setup()
	return
