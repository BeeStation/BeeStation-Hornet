/datum/orbital_object/star
	name = "Stellar Body"
	mass = 100000
	radius = 200
	static_object = TRUE
	collision_flags = ALL

/datum/orbital_object/star/collision(datum/orbital_object/other)
	//You got lucky this time
	if(other.collision_ignored || collision_ignored)
		return
	//You didnt get lucky this time
	message_admins("Orbital body [other.name] collided with the star [name] and was destroyed.")
	log_game("Orbital body [other.name] collided with the star [name] and was destroyed.")
	//Rip.
	if(istype(other, /datum/orbital_object/star))
		//Make a black hole or something
		return
	//Destroy the other orbital object.
	other.explode()
