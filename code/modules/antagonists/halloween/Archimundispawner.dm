/client/proc/generateArchimundi()
	set name = "Delete Station"
	set desc = "Deletes the Station and Generates Archimundi DO NOT PRESS LIGHTLY"
	set category = "Fun"

	if(!check_rights(R_PERMISSIONS))
		return
	log_admin("[key_name(usr)] Started generating Archimundi.")
	SSzclear.wipe_z_level(2)
	log_admin("[key_name(usr)] Generated Archimundi.")

/proc/LoadArchimundi()
	//Don't load archimundi twice in case something happens
	var/static/archimundi_loaded = FALSE
	if(archimundi_loaded)
		return
	var/datum/map_template/template = new("_maps/map_files/RadStation/RadStation.dmm", "Archimundi")
	template.load_new_z()
	archimundi_loaded = TRUE

/client/proc/removestationlatejoining()
	set name = "Turn Off Station Latejoins"
	set desc = "Stops latejoins and deletes the arrivals shuttle"
	set category = "Fun"

	if(!check_rights(R_FUN))
		return
	var/static/disabled_latejoins = FALSE
	if(disabled_latejoins)
		return
	log_admin("[key_name(usr)] Removed latejoining on the station.")
	SSticker.late_join_disabled = TRUE
	SSshuttle.arrivals.jumpToNullSpace()
	disabled_latejoins = TRUE

/client/proc/enableicelandlatejoining()
	set name = "Enables Late joining after abandoning Station"
	set desc = "Adds new landmarks to latejoining and renables latejoining"
	set category = "Fun"

	if(!check_rights(R_FUN))
		return
	for(var/obj/effect/landmark/icelate/L in GLOB.landmarks_list)
		SSjob.latejoin_trackers += L.loc
	SSticker.late_join_disabled = FALSE

