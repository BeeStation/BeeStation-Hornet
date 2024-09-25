// Workshop area for the prison wing in Brig


/obj/machinery/computer/holodeck/prison
	name = "workshop control console"
	desc = "a computer used to control the workshop in the prison"

	mapped_start_area = /area/holodeck/prison
	linked = /area/holodeck/prison //linked area
	program_type = /datum/map_template/holodeck/prison //load workshop programs
	req_access = list(ACCESS_SECURITY)
	var/startup
	var/offline = FALSE

/obj/machinery/computer/holodeck/prison/LateInitialize()
	var/area/computer_area = get_area(src)
	if(istype(computer_area, /area/holodeck/prison))
		log_mapping("Holodeck computer cannot be in a holodeck, This would cause circular power dependency.")
		qdel(src)
		return
	else
		offline_program = pick("donut", "plush")
		. = ..()

/obj/machinery/computer/holodeck/prison/generate_program_list()
	for(var/typekey in subtypesof(program_type))
		var/datum/map_template/holodeck/program = typekey
		var/list/info_this = list("id" = initial(program.template_id), "name" = initial(program.name))
		if(!(initial(program.template_id) == "offline"))
			LAZYADD(program_cache, list(info_this))

/obj/machinery/computer/holodeck/prison/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Workshop")
		ui.open()


/obj/machinery/computer/holodeck/prison/ui_data(mob/user)
	var/list/data = list()

	data["default_programs"] = program_cache
	data["program"] = program
	return data

/obj/machinery/computer/holodeck/prison/ui_act(action, params)
	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		return
	if(..())
		return
	switch(action)
		if("load_program")
			var/program_to_load = params["id"]

			var/valid = FALSE //dont tell security about this

			//checks if program_to_load is any one of the loadable programs, if it isnt then it rejects it
			for(var/list/check_list as anything in program_cache)
				if(check_list["id"] == program_to_load)
					valid = TRUE
					break
			if(!valid)
				return
			if(offline)
				say("Workshop shutdown underway! Standby for reboot...")
				return
			else //load the map_template that program_to_load represents
				load_program(program_to_load)
				. = TRUE
		if("shutdown")
			log_game("[key_name(usr)] has shutdown the prison workshop at [loc_name(src)]!")
			temporary_down()
			. = TRUE

/obj/machinery/computer/holodeck/prison/proc/temporary_down()
	if(!offline)
		say("Emergency shutdown engaged. Restarting in 2 minutes...")
		offline_program = "offline"
		emergency_shutdown()
		offline = TRUE
		offline_program = pick("donut", "plush")
		addtimer(CALLBACK(src, PROC_REF(load_program), offline_program), 1200)
	else
		say("Workshop shutdown underway! Standby for reboot...")

/obj/machinery/computer/holodeck/prison/nerf(nerf_this, is_loading) //We want items to behave as normal and to do damage
	return

/obj/machinery/computer/holodeck/prison/derez(atom/movable/holo_atom, silent = TRUE, forced = FALSE)
	spawned -= holo_atom
	if(!holo_atom)
		return
	if(!(get_turf(holo_atom) in linked)) //Don't derez items that have been hidden or taken away by prisoners
		return
	UnregisterSignal(holo_atom, COMSIG_PARENT_PREQDELETED)
	var/turf/target_turf = get_turf(holo_atom)
	for(var/atom/movable/atom_contents as anything in holo_atom) //make sure that things inside of a holoitem are moved outside before destroying it
		atom_contents.forceMove(target_turf)
	if(!silent)
		visible_message("<span class='notice'>[holo_atom] fades away!</span>")

	qdel(holo_atom)

/obj/machinery/computer/holodeck/prison/load_program()
	. = ..()
	offline = FALSE
