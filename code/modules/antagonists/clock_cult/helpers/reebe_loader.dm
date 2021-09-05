/proc/LoadReebe()
	//Don't load reebe twice in case something happens
	var/static/reebe_loaded = FALSE
	if(reebe_loaded)
		return
	var/datum/map_template/template = new("_maps/map_files/generic/CityOfCogs.dmm", "Reebe")
	template.load_new_z(null, ZTRAITS_REEBE)
	reebe_loaded = TRUE