
/**
  * Gets a unique value for a new virtual z level.
  * This is just a number, the game wont slow down if you have a ton of empty ones.
  */
/proc/get_new_virtual_z()
	var/static/virtual_value = VIRTUAL_Z_START
	return virtual_value ++

/**
  * Used to get the virtual z-level.
  * Will give unique values to each shuttle while it is in a transit level.
  * Note: If the user teleports to another virtual z on the same z-level they will need to have reset_virtual_z called. (Teleportations etc.)
  */
/atom/proc/get_virtual_z_level()
	var/turf/T = get_turf(src)
	if(!T)
		return 0
	var/area/A = T.loc
	if(!A)
		return 0
	return A.get_virtual_z(T)
