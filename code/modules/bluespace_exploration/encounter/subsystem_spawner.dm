/datum/controller/subsystem/bluespace_exploration/proc/spawn_and_register_shuttle(datum/map_template/shuttle/ship/S)
	if(!istype(S))
		return
	//Spawn the ship and just plop it somewhere on the z_level
	var/obj/docking_port/mobile/M = S.try_to_place(reserved_bs_level.z_value, /area/space)
	if(!istype(M))
		return
	register_new_ship(M.id, /datum/ship_datum/npc)
