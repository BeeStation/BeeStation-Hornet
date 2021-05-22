
/datum/orbital_object/star
	name = "Stellar Body"
	mass = 1000
	radius = 1
	static_object = TRUE

/datum/orbital_object/star/collision(datum/orbital_object/other)
	message_admins("Orbital body [other.name] collided with the star [name] and was destroyed.")
	log_game("Orbital body [other.name] collided with the star [name] and was destroyed.")
	//Rip.
	if(istype(other, /datum/orbital_object/star))
		//Make a black hole or something
		return
	//Destroy the other orbital object.
	other.Destroy()
