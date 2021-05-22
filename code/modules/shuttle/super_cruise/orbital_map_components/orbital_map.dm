
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
	//Create lavaland (Uses earth stats lol)
	//var/datum/orbital_object/z_linked/lavaland/lavaland = new()
	//lavaland.position = new /datum/orbital_vector(100, 0)
	//lavaland.velocity = new /datum/orbital_vector(0, 2)
	//lavaland.set_orbitting_around_body(star, 150)
	//bodies += lavaland

//Returns a list of gravitationally relevant bodies.
/datum/orbital_map/proc/get_relevnant_bodies(datum/orbital_object/source)
	. = list()
	for(var/datum/orbital_object/body as() in bodies)
		if(body != source && source.position.Distance(body.position) <= body.relevant_gravity_range)
			. += body
