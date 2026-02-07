/proc/load_reebe()
	//Don't load reebe twice in case something happens
	var/static/reebe_loaded = FALSE
	if(reebe_loaded)
		return

	var/datum/map_template/reebe_template = new("_maps/templates/city_of_cogs.dmm", "Reebe")
	var/datum/turf_reservation/reebe_reservation = SSmapping.RequestBlockReservation(reebe_template.width, reebe_template.height)
	var/datum/async_map_generator/map_place/reebe_placer = reebe_template.load(locate(reebe_reservation.bottom_left_coords[1], reebe_reservation.bottom_left_coords[2], reebe_reservation.bottom_left_coords[3]))
	reebe_placer.on_completion(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(teleport_all_servants_to_reebe)))
	reebe_loaded = TRUE

/proc/teleport_all_servants_to_reebe()
	for(var/datum/mind/servant_mind in GLOB.servants_of_ratvar)
		var/mob/living/servant = servant_mind.current
		if(QDELETED(servant))
			continue

		servant.clear_fullscreen("reebe_loading", 1 SECONDS)

		servant.forceMove(pick(GLOB.servant_spawns))
