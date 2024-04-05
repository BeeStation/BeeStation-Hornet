/datum/movespeed_modifier/jetpack
	id = MOVESPEED_ID_JETPACK
	conflicts_with = MOVE_CONFLICT_JETPACK
	movetypes = FLOATING

/datum/movespeed_modifier/jetpack/cybernetic
	id = MOVESPEED_ID_CYBER_THRUSTER
	variable = TRUE

/datum/movespeed_modifier/jetpack/fullspeed
	id = MOVESPEED_ID_JETPACK
	multiplicative_slowdown = -0.5

/datum/movespeed_modifier/die_of_fate
	multiplicative_slowdown = 1

/datum/movespeed_modifier/admantine_armor
	multiplicative_slowdown = 4

/datum/movespeed_modifier/drawing_firearm
	variable = TRUE
	movetypes = GROUND
