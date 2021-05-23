
/datum/orbital_map
	//the primary star
	var/datum/orbital_object/star = null
	//A list of all bodies
	var/list/datum/orbital_object/bodies = list()

/datum/orbital_map/New()
	. = ..()
	//Create the star
	star = new /datum/orbital_object/star()
	bodies += star

//Returns a list of gravitationally relevant bodies.
/datum/orbital_map/proc/get_relevnant_bodies(datum/orbital_object/source)
	. = list()
	for(var/datum/orbital_object/body as() in bodies)
		if(body != source && source.position.Distance(body.position) <= body.relevant_gravity_range)
			. += body

/datum/orbital_map/proc/post_setup()
	for(var/datum/orbital_object/body as() in bodies)
		body.post_map_setup()
