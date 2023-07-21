/datum/orbital_zone
	var/name
	var/left
	var/right
	var/top
	var/bottom
	var/z

/datum/orbital_zone/New(name, left, right, top, bottom, z)
	. = ..()
	src.name = name
	src.left = left
	src.right = right
	src.top = top
	src.bottom = bottom
	src.z = z
