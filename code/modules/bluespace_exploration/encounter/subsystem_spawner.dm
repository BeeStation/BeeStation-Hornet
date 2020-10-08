/datum/controller/subsystem/bluespace_exploration/proc/spawn_and_register_shuttle(datum/map_template/shuttle/ship/S, z_level)
	if(!istype(S))
		return
	//Spawn the ship and just plop it somewhere on the z_level
	var/obj/docking_port/mobile/M = S.try_to_place(z_level, /area/space)
	if(!istype(M))
		return
	register_new_ship(M.id, /datum/ship_datum/npc, /datum/faction/syndicate/gorlex)
