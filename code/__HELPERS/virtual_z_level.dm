
/**
  * Gets a unique value for a new virtual z level.
  * This is just a number, the game wont slow down if you have a ton of empty ones.
  */
/proc/get_new_virtual_z()
	var/static/virtual_value = VIRTUAL_Z_START
	return virtual_value ++

/**
  * Returns a logical z-value which must be used for comparing of two different
  * locations are on the same z-level, or on different ones.
  *
  * This returns numbers outside of the range of world.maxz, and should not be
  * used when you need to get a physical location such as with locate(), but
  * should be used if you want to check if two turfs are on the same z.
  *
  * For example, two shuttles both of the reserved z-levels have different virtual
  * z-levels and all content that compares z-levels (suit sensors, radios, etc.)
  * should compare virtual-zs so that the are treated entirely independently. If
  * you need to use physical Zs to get an area (such as with block), then you should
  * compare the virtual z values for each tile in that if the behaviour should be
  * locked down to a single z.
  *
  * Will give unique values to each shuttle while it is in a transit level.
  */
/atom/proc/get_virtual_z_level()
	var/turf/T = get_turf(src)
	if(!T)
		return 0
	var/area/A = T.loc
	if(!A)
		return 0
	return A.get_virtual_z(T)
