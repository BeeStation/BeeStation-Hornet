/datum/orbital_object/hazard/gravity_storm
	name = "Gravitational Storm"

/datum/orbital_object/hazard/ion_storm/effect(datum/shuttle_data/shuttle_data)
	if(prob(90))
		return
	//Locate the orbital object
	var/datum/orbital_object/shuttle/shuttle = SSorbits.assoc_shuttles[shuttle_data.port_id]
	if(!shuttle)
		return
	//Add some random velocity
	shuttle.velocity.x += rand(-200, 200)
	shuttle.velocity.y += rand(-200, 200)
