#define FILE_ANTAG_REP "data/AntagReputation.json"

/datum/controller/subsystem/persistence/proc/load_antag_reputation()
	var/json = rustg_file_read(FILE_ANTAG_REP)
	if(!json)
		var/json_file = file(FILE_ANTAG_REP)
		if(!fexists(json_file))
			WARNING("Failed to load antag reputation. File likely corrupt.")
			return
		return
	antag_rep = json_decode(json)

/datum/controller/subsystem/persistence/proc/collect_antag_reputation()
	for(var/p_ckey in antag_rep_change)
		antag_rep[p_ckey] = max(0, min(antag_rep[p_ckey]+antag_rep_change[p_ckey], CONFIG_GET(number/antag_rep_maximum)))

	antag_rep_change = list()

	fdel(FILE_ANTAG_REP)
	rustg_file_append(json_encode(antag_rep), FILE_ANTAG_REP)
	return

#undef FILE_ANTAG_REP
