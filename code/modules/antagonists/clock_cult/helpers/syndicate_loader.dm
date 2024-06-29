/proc/LoadSyndicate()
	//Don't load reebe twice in case something happens
	var/static/syndicate_loaded = FALSE
	if(syndicate_loaded)
		return
	var/datum/map_template/template = new("_maps/map_files/generic/SyndicateOperativeBase.dmm", "Reebe")
	template.load_new_z(null, ZTRAITS_REEBE)
	syndicate_loaded = TRUE
