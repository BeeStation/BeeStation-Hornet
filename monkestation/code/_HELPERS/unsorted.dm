//Used to get a random closed and non-secure locker on the station z-level, created for the Stowaway trait.
/proc/get_unlocked_closed_locker() //I've seen worse proc names
	var/list/picked_lockers = list()
	var/turf/object_location
	for(var/obj/structure/closet/find_closet in world)
		if(!istype(find_closet,/obj/structure/closet/secure_closet))
			object_location = get_turf(find_closet)
			if(object_location) //If it can't read a Z on the next step, it will error out. Needs a separate check.
				if(is_station_level(object_location.z) && !find_closet.opened) //On the station and closed.
					picked_lockers += find_closet
	if(picked_lockers)
		return pick(picked_lockers)
	return FALSE
  
//For all your moth grabbing needs.
/proc/Grab_Moths(turf/T, range = 6, speed = 0.5)
	for(var/mob/living/carbon/human/H in oview(range, T))
		if(ismoth(H) && isliving(H))
			pick(H.emote("scream"), H.visible_message("<span class='boldwarning'>[H] lunges for the light!</span>"))
			H.throw_at(T, range, speed)

