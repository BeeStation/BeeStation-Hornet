/datum/orbital_object/meteor
	name = "Meteor"
	collision_type = COLLISION_METEOR
	collision_flags = COLLISION_SHUTTLES | COLLISION_Z_LINKED
	render_mode = RENDER_MODE_SHUTTLE
	priority = -1
	//Target of the meteor
	var/datum/orbital_object/target
	var/list/meteor_types
	var/start_tick
	var/end_tick
	var/start_x
	var/start_y
	var/end_x
	var/end_y

/datum/orbital_object/meteor/New()
	. = ..()
	//Use continuous time for smoother meteors
	start_tick = SSorbits.times_fired
	end_tick = SSorbits.times_fired + (10 MINUTES / SSorbits.wait)
	radius = rand(10, 50)

/datum/orbital_object/meteor/Destroy()
	target = null
	meteor_types = null
	. = ..()

/datum/orbital_object/meteor/process(delta_time)
	if(!QDELETED(target))
		end_x = target.position.x
		end_y = target.position.y
	var/current_tick = SSorbits.times_fired
	var/tick_proportion = min((current_tick - start_tick) / (end_tick - start_tick), 1)
	//stop when reached the target
	if(tick_proportion == 1)
		velocity.x = 0
		velocity.y = 0
	var/current_x = (end_x * tick_proportion) + (start_x * (1 - tick_proportion))
	var/current_y = (end_y * tick_proportion) + (start_y * (1 - tick_proportion))
	//Set the velocity for better rendering
	velocity.x = current_x - position.x
	velocity.y = current_y - position.y
	. = ..()
	MOVE_ORBITAL_BODY(src, current_x, current_y)
	if(abs(position.x) > 10000 || abs(position.y) > 10000)
		qdel(src)

/datum/orbital_object/meteor/collision(datum/orbital_object/other)
	//If we collide with a shuttle, do a little explosion
	if(istype(other, /datum/orbital_object/shuttle))
		var/datum/orbital_object/shuttle/shuttleobj = other
		if(shuttleobj.port)
			for(var/i in 1 to 5)
				impact_turfs(shuttleobj.port.return_turfs())
	//If we collide with a z-linked, spawn a meteor on that z-level
	if(istype(other, /datum/orbital_object/z_linked))
		var/datum/orbital_object/z_linked/z_linked = other
		if(!z_linked.can_dock_anywhere && !z_linked.random_docking)
			return
		if(!LAZYLEN(z_linked.linked_z_level))
			return
		var/datum/space_level/space_level = pick(z_linked.linked_z_level)
		//Check protected levels
		if(space_level.traits[ZTRAIT_CENTCOM] || space_level.traits[ZTRAIT_REEBE])
			return
		//Check level flags for planetary bodies
		if(space_level.traits[ZTRAIT_MINING] || (space_level.traits[ZTRAIT_STATION] && SSmapping.current_map.planetary_station))
			for(var/i in 1 to 5)
				meteor_impact(locate(rand(10, world.maxx - 10), rand(10, world.maxx-10), space_level.z_value))
		else
			//Spawn meteor wave
			spawn_meteors(5, meteor_types, space_level.z_value)
	qdel(src)

/datum/orbital_object/meteor/proc/impact_turfs(list/valid_turfs)
	if(length(valid_turfs))
		meteor_impact(pick(valid_turfs))

//Fall from the sky
/datum/orbital_object/meteor/proc/meteor_impact(turf/T)
	//Make it so meteors fall from high Z and will impact the top Z-Levels first
	var/turf/target_turf = T
	var/turf/next = GET_TURF_ABOVE(target_turf)
	while (next != null)
		target_turf = next
		next = GET_TURF_ABOVE(target_turf)
	new /obj/effect/falling_meteor(target_turf, meteor_types ? pick(meteor_types) : null)
