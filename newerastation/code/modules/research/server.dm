/obj/machinery/rnd/server/proc/newera_process_bc_miner(points)
	var/obj/item/infiltrator_miner/B = (locate(/obj/item/infiltrator_miner) in src.contents)
	if(B && !B.target_reached)
		var/intercepted = points*0.6
		B.on_mine(intercepted)
		return points - intercepted
	return points
