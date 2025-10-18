//============ Actions ============
/datum/action/innate/shuttle_creator
	button_icon = 'icons/hud/actions/actions_shuttle.dmi'
	button_icon_state = null
	var/mob/living/C
	var/mob/camera/ai_eye/remote/shuttle_creation/remote_eye
	var/obj/item/shuttle_creator/shuttle_creator

/datum/action/innate/shuttle_creator/on_activate()
	if(!master)
		return TRUE
	C = owner
	remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/shuttle_creator/internal_console = master
	shuttle_creator = internal_console.owner_rsd
	if(shuttle_creator.update_origin())
		to_chat(usr, span_warning("Warning, the shuttle has moved during designation. Please wait for the shuttle to dock and try again."))
		shuttle_creator.reset_saved_area(FALSE)
		internal_console.remove_eye_control(owner)
		return TRUE

//Add an area
/datum/action/innate/shuttle_creator/designate_area
	name = "Designate Room"
	button_icon_state = "designate_area"

/datum/action/innate/shuttle_creator/designate_area/on_activate()
	if(..())
		return
	shuttle_creator.add_saved_area(remote_eye)

//Add a single turf
/datum/action/innate/shuttle_creator/designate_turf
	name = "Designate Turf"
	button_icon_state = "designate_turf"

/datum/action/innate/shuttle_creator/designate_turf/on_activate()
	if(..())
		return
	var/turf/T = get_turf(remote_eye)
	if(GLOB.shuttle_turf_blacklist[T.type])
		var/connectors_exist = FALSE
		for(var/obj/structure/lattice/lattice in T)
			connectors_exist = TRUE
			break
		if(!connectors_exist)
			to_chat(usr, span_warning("This turf requires support, build some catwalks or lattices."))
			return
	if(!shuttle_creator.check_area(list(T)))
		return
	if(shuttle_creator.turf_in_list(T))
		return
	shuttle_creator.add_single_turf(T)

//Clear a single entire area
/datum/action/innate/shuttle_creator/clear_turf
	name = "Clear Turf"
	button_icon_state = "clear_turf"

/datum/action/innate/shuttle_creator/clear_turf/on_activate()
	if(..())
		return
	shuttle_creator.remove_single_turf(get_turf(remote_eye))

//Clear the entire area
/datum/action/innate/shuttle_creator/reset
	name = "Reset Buffer"
	button_icon_state = "clear_area"

/datum/action/innate/shuttle_creator/reset/on_activate()
	if(..())
		return
	shuttle_creator.reset_saved_area()

//Finish the shuttle
/datum/action/innate/shuttle_creator/airlock
	name = "Select Docking Airlock"
	button_icon_state = "select_airlock"

/datum/action/innate/shuttle_creator/airlock/on_activate()
	if(..())
		return
	var/turf/T = get_turf(remote_eye)
	for(var/obj/machinery/door/airlock/A in T)
		if(!(T in shuttle_creator.loggedTurfs))
			to_chat(C, span_warning("Caution, airlock must be on the shuttle to function as a dock."))
			return
		if(shuttle_creator.linkedShuttleId)
			return
		if(GLOB.custom_shuttle_count > CUSTOM_SHUTTLE_LIMIT)
			to_chat(C, span_warning("Shuttle limit reached, sorry."))
			return
		if(shuttle_creator.loggedTurfs.len > SHUTTLE_CREATOR_MAX_SIZE)
			to_chat(C, span_warning("This shuttle is too large!"))
			return
		if(!shuttle_creator.getNonShuttleDirection(T))
			to_chat(C, span_warning("Docking port must be on an external wall, with only 1 side exposed to space."))
			return
		if(shuttle_creator.shuttle_create_docking_port(A, C))
			to_chat(C, span_notice("Shuttle created!"))
	//Remove eye control
	var/obj/machinery/computer/camera_advanced/shuttle_creator/internal_console = master
	internal_console.remove_eye_control(owner)

/datum/action/innate/shuttle_creator/modify
	name = "Confirm Shuttle Modifications"
	button_icon_state = "modify"

/datum/action/innate/shuttle_creator/modify/on_activate()
	if(..())
		return
	if(shuttle_creator.loggedTurfs.len > SHUTTLE_CREATOR_MAX_SIZE)
		to_chat(C, span_warning("This shuttle is too large!"))
		return
	if(shuttle_creator.modify_shuttle_area(C))
		to_chat(C, span_notice("Shuttle modifications have been finalized."))
		//Remove eye control
	var/obj/machinery/computer/camera_advanced/shuttle_creator/internal_console = master
	internal_console.remove_eye_control(owner)
