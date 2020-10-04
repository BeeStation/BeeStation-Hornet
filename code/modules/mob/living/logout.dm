/mob/living/Logout()
	update_z(null)
	..()
	if(!key && mind)	//key and mind have become separated.
		mind.active = 0	//This is to stop say, a mind.transfer_to call on a corpse causing a ghost to re-enter its body.
	if(mind && mind.active)
		player_logged = TRUE
	else
		player_logged = FALSE
