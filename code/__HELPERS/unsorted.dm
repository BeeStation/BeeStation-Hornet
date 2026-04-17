//here lies unsorted.dm, bane of many coders, pain of lots of maintainers

//* 2005? / + 2022

/// identical alert proc, but without waiting for user input. It's useful when you shouldn't set your proc `waitfor = 0`
/proc/client_alert(client/C, message, title)
	set waitfor = 0
	alert(C, message, title)

/proc/get_unlocked_closed_locker()
	var/list/eligible_lockers = list()
	for(var/obj/structure/closet/closet in world)
		if(QDELETED(closet) || closet.opened || istype(closet, /obj/structure/closet/secure_closet))
			continue
		var/turf/closet_turf = get_turf(closet)
		if(!closet_turf || !is_station_level(closet_turf.z) || closet_turf.is_blocked_turf(ignore_atoms = list(closet)))
			continue
		eligible_lockers += closet
	if(length(eligible_lockers))
		return pick(eligible_lockers)
