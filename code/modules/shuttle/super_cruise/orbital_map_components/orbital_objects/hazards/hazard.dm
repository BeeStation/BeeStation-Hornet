/datum/orbital_object/hazard
	name = "Map Hazard"
	mass = 0
	priority = -5
	radius = 500
	static_object = TRUE
	collision_type = COLLISION_HAZARD
	collision_flags = COLLISION_SHUTTLES
	render_mode = RENDER_MODE_HAZARD
	signal_range = 25000
	var/damage_per_second = 2

/datum/orbital_object/hazard/New(datum/orbital_vector/position, datum/orbital_vector/velocity, orbital_map_index)
	. = ..()
	SSorbits.active_hazards += src
	var/static/count = 0
	name = "[name] ([++count])"

/datum/orbital_object/hazard/Destroy()
	SSorbits.active_hazards -= src
	. = ..()

/datum/orbital_object/hazard/collision(datum/orbital_object/other)
	var/datum/orbital_object/shuttle/shuttle = other
	if(istype(shuttle))
		//Get the shuttle data
		var/datum/shuttle_data/shuttle_stats = shuttle.shuttle_data
		//Hm? No shuttle stats
		if(!shuttle_stats)
			return
		//Deal shield damage
		shuttle_stats.deal_damage(damage_per_second * ORBITAL_UPDATE_RATE_SECONDS)
		//If shield is down, do the effect
		if(!shuttle_stats.is_protected())
			effect(shuttle_stats)

/datum/orbital_object/hazard/proc/effect(datum/shuttle_data/shuttle_data)
	return
