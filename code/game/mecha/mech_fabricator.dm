/obj/machinery/mecha_part_fabricator
	icon = 'icons/obj/robotics.dmi'
	icon_state = "fab-idle"
	name = "exosuit fabricator"
	desc = "Nothing is being built."
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 5000
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/machine/mechfab

	/// Current items in the build queue.
	var/list/queue = list()
	/// Whether or not the machine is building the entire queue automagically.
	var/process_queue = FALSE

	/// The current design datum that the machine is building.
	var/datum/design/being_built
	/// World time when the build will finish.
	var/build_finish = 0
	/// World time when the build started.
	var/build_start = 0
	/// Reference to all materials used in the creation of the item being_built.
	var/list/build_materials
	/// Part currently stored in the Exofab.
	var/obj/item/stored_part

	/// Coefficient for the speed of item building. Based on the installed parts.
	var/time_coeff = 1
	/// Coefficient for the efficiency of material usage in item building. Based on the installed parts.
	var/component_coeff = 1

	/// Copy of the currently synced techweb.
	var/datum/techweb/specialized/autounlocking/exofab/stored_research

	/// Whether the Exofab links to the ore silo on init. Special derelict or maintanance variants should set this to FALSE.
	var/link_on_init = TRUE

	/// Reference to a remote material inventory, such as an ore silo.
	var/datum/component/remote_materials/rmat

	/// A list of categories that valid MECHFAB design datums will broadly categorise themselves under.
	var/list/part_sets = list(
								"Cyborg",
								"Ripley",
								"Firefighter",
								"Odysseus",
								"Gygax",
								"Durand",
								"H.O.N.K",
								"Phazon",
								"Exosuit Equipment",
								"Cyborg Upgrade Modules",
								"IPC Components",
								"Cybernetics",
								"Implants",
								"Control Interfaces",
								"Misc"
								)

/obj/machinery/mecha_part_fabricator/Initialize(mapload)
	stored_research = new
	rmat = AddComponent(/datum/component/remote_materials, "mechfab", mapload && link_on_init)
	RefreshParts() //Recalculating local material sizes if the fab isn't linked
	return ..()

/obj/machinery/mecha_part_fabricator/RefreshParts()
	var/T = 0

	//maximum stocking amount (default 300000, 600000 at T4)
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	rmat.set_local_size((200000 + (T*50000)))

	//resources adjustment coefficient (1 -> 0.85 -> 0.7 -> 0.55)
	T = 1.15
	for(var/obj/item/stock_parts/micro_laser/Ma in component_parts)
		T -= Ma.rating*0.15
	component_coeff = T

	//building time adjustment coefficient (1 -> 0.8 -> 0.6)
	T = -1
	for(var/obj/item/stock_parts/manipulator/Ml in component_parts)
		T += Ml.rating
	time_coeff = round(initial(time_coeff) - (initial(time_coeff)*(T))/5,0.01)

	// Adjust the build time of any item currently being built.
	if(being_built)
		var/last_const_time = build_finish - build_start
		var/new_const_time = get_construction_time_w_coeff(initial(being_built.construction_time))
		var/const_time_left = build_finish - world.time
		var/new_build_time = (new_const_time / last_const_time) * const_time_left
		build_finish = world.time + new_build_time

	update_static_data(usr)

/obj/machinery/mecha_part_fabricator/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Storing up to <b>[rmat.local_size]</b> material units.<br>Material consumption at <b>[component_coeff*100]%</b>.<br>Build time reduced by <b>[100-time_coeff*100]%</b>.</span>"

/**
  * Generates an info list for a given part.
  *
  * Returns a list of part information.
  * * D - Design datum to get information on.
  * * categories - Boolean, whether or not to parse snowflake categories into the part information list.
  */
/obj/machinery/mecha_part_fabricator/proc/output_part_info(datum/design/D, var/categories = FALSE)
	var/cost = list()
	for(var/c in D.materials)
		var/datum/material/M = c
		cost[M.name] = get_resource_cost_w_coeff(D, M)

	var/obj/built_item = D.build_path

	var/list/category_override = null
	var/list/sub_category = null

	if(categories)
		// Handle some special cases to build up sub-categories for the fab interface.
		// Start with checking if this design builds a cyborg module.
		if(built_item in typesof(/obj/item/borg/upgrade))
			var/obj/item/borg/upgrade/U = built_item
			var/module_types = initial(U.module_flags)
			sub_category = list()
			if(module_types)
				if(module_types & BORG_MODULE_SECURITY)
					sub_category += "Security"
				if(module_types & BORG_MODULE_MINER)
					sub_category += "Mining"
				if(module_types & BORG_MODULE_JANITOR)
					sub_category += "Janitor"
				if(module_types & BORG_MODULE_MEDICAL)
					sub_category += "Medical"
				if(module_types & BORG_MODULE_ENGINEERING)
					sub_category += "Engineering"
				if(module_types & BORG_MODULE_SPECIALITY)
					sub_category += "Specialization"
			else
				sub_category += "All Cyborgs"
		// Else check if this design builds a piece of exosuit equipment.
		else if(built_item in typesof(/obj/item/mecha_parts/mecha_equipment))
			var/obj/item/mecha_parts/mecha_equipment/E = built_item
			var/mech_types = initial(E.mech_flags)
			sub_category = "Equipment"
			if(mech_types)
				category_override = list()
				if(mech_types & EXOSUIT_MODULE_RIPLEY)
					category_override += "Ripley"
				if(mech_types & EXOSUIT_MODULE_ODYSSEUS)
					category_override += "Odysseus"
				if(mech_types & EXOSUIT_MODULE_GYGAX)
					category_override += "Gygax"
				if(mech_types & EXOSUIT_MODULE_DURAND)
					category_override += "Durand"
				if(mech_types & EXOSUIT_MODULE_HONK)
					category_override += "H.O.N.K"
				if(mech_types & EXOSUIT_MODULE_PHAZON)
					category_override += "Phazon"


	var/list/part = list(
		"name" = D.name,
		"desc" = initial(built_item.desc),
		"printTime" = get_construction_time_w_coeff(initial(D.construction_time))/10,
		"cost" = cost,
		"id" = D.id,
		"subCategory" = sub_category,
		"categoryOverride" = category_override,
		"searchMeta" = D.search_metadata
	)

	return part

/**
  * Generates a list of resources / materials available to this Exosuit Fab
  *
  * Returns null if there is no material container available.
  * List format is list(material_name = list(amount = ..., ref = ..., etc.))
  */
/obj/machinery/mecha_part_fabricator/proc/output_available_resources()
	var/datum/component/material_container/materials = rmat.mat_container

	var/list/material_data = list()

	if(materials)
		for(var/mat_id in materials.materials)
			var/datum/material/M = mat_id
			var/list/material_info = list()
			var/amount = materials.materials[mat_id]

			material_info = list(
				"name" = M.name,
				"ref" = REF(M),
				"amount" = amount,
				"sheets" = round(amount / MINERAL_MATERIAL_AMOUNT),
				"removable" = amount >= MINERAL_MATERIAL_AMOUNT
			)

			material_data += list(material_info)

		return material_data

	return null

/**
  * Intended to be called when an item starts printing.
  *
  * Adds the overlay to show the fab working and sets active power usage settings.
  */
/obj/machinery/mecha_part_fabricator/proc/on_start_printing()
	add_overlay("fab-active")
	use_power = ACTIVE_POWER_USE

/**
  * Intended to be called when the exofab has stopped working and is no longer printing items.
  *
  * Removes the overlay to show the fab working and sets idle power usage settings. Additionally resets the description and turns off queue processing.
  */
/obj/machinery/mecha_part_fabricator/proc/on_finish_printing()
	cut_overlay("fab-active")
	use_power = IDLE_POWER_USE
	desc = initial(desc)
	process_queue = FALSE

/**
  * Calculates resource/material costs for printing an item based on the machine's resource coefficient.
  *
  * Returns a list of k,v resources with their amounts.
  * * D - Design datum to calculate the modified resource cost of.
  */
/obj/machinery/mecha_part_fabricator/proc/get_resources_w_coeff(datum/design/D)
	var/list/resources = list()
	for(var/R in D.materials)
		var/datum/material/M = R
		resources[M] = get_resource_cost_w_coeff(D, M)
	return resources

/**
  * Checks if the Exofab has enough resources to print a given item.
  *
  * Returns FALSE if the design has no reagents used in its construction (?) or if there are insufficient resources.
  * Returns TRUE if there are sufficient resources to print the item.
  * * D - Design datum to calculate the modified resource cost of.
  */
/obj/machinery/mecha_part_fabricator/proc/check_resources(datum/design/D)
	if(length(D.reagents_list)) // No reagents storage - no reagent designs.
		return FALSE
	var/datum/component/material_container/materials = rmat.mat_container
	if(materials.has_materials(get_resources_w_coeff(D)))
		return TRUE
	return FALSE

/**
  * Attempts to build the next item in the build queue.
  *
  * Returns FALSE if either there are no more parts to build or the next part is not buildable.
  * Returns TRUE if the next part has started building.
  * * verbose - Whether the machine should use say() procs. Set to FALSE to disable the machine saying reasons for failure to build.
  */
/obj/machinery/mecha_part_fabricator/proc/build_next_in_queue(verbose = TRUE)
	if(!length(queue))
		return FALSE

	var/datum/design/D = queue[1]
	if(build_part(D, verbose))
		remove_from_queue(1)
		return TRUE

	return FALSE

/**
  * Starts the build process for a given design datum.
  *
  * Returns FALSE if the procedure fails. Returns TRUE when being_built is set.
  * Uses materials.
  * * D - Design datum to attempt to print.
  * * verbose - Whether the machine should use say() procs. Set to FALSE to disable the machine saying reasons for failure to build.
  */
/obj/machinery/mecha_part_fabricator/proc/build_part(datum/design/D, verbose = TRUE)
	if(!D)
		return FALSE

	var/datum/component/material_container/materials = rmat.mat_container
	if (!materials)
		if(verbose)
			say("No access to material storage, please contact the quartermaster.")
		return FALSE
	if (rmat.on_hold())
		if(verbose)
			say("Mineral access is on hold, please contact the quartermaster.")
		return FALSE
	if(!check_resources(D))
		if(verbose)
			say("Not enough resources. Processing stopped.")
		return FALSE

	build_materials = get_resources_w_coeff(D)

	materials.use_materials(build_materials)
	being_built = D
	build_finish = world.time + get_construction_time_w_coeff(initial(D.construction_time))
	build_start = world.time
	desc = "It's building \a [D.name]."

	rmat.silo_log(src, "built", -1, "[D.name]", build_materials)

	return TRUE

/obj/machinery/mecha_part_fabricator/process()
	// If there's a stored part to dispense due to an obstruction, try to dispense it.
	if(stored_part)
		var/turf/exit = get_step(src,(dir))
		if(exit.density)
			return TRUE

		say("Obstruction cleared. \The [stored_part] is complete.")
		stored_part.forceMove(exit)
		stored_part = null

	// If there's nothing being built, try to build something
	if(!being_built)
		// If we're not processing the queue anymore or there's nothing to build, end processing.
		if(!process_queue || !build_next_in_queue())
			on_finish_printing()
			STOP_PROCESSING(SSfastprocess, src)
			return TRUE
		on_start_printing()

	// If there's an item being built, check if it is complete.
	if(being_built && (build_finish < world.time))
		// Then attempt to dispense it and if appropriate build the next item.
		dispense_built_part(being_built)
		if(process_queue)
			build_next_in_queue(FALSE)
		return TRUE

/**
  * Dispenses a part to the tile infront of the Exosuit Fab.
  *
  * Returns FALSE is the machine cannot dispense the part on the appropriate turf.
  * Return TRUE if the part was successfully dispensed.
  * * D - Design datum to attempt to dispense.
  */
/obj/machinery/mecha_part_fabricator/proc/dispense_built_part(datum/design/D)
	var/obj/item/I = new D.build_path(src)

	being_built = null

	var/turf/exit = get_step(src,(dir))
	if(exit.density)
		say("Error! Part outlet is obstructed.")
		desc = "It's trying to dispense \a [D.name], but the part outlet is obstructed."
		stored_part = I
		return FALSE

	say("\The [I] is complete.")
	I.forceMove(exit)
	return TRUE

/**
  * Adds a list of datum designs to the build queue.
  *
  * Will only add designs that are in this machine's stored techweb.
  * Does final checks for datum IDs and makes sure this machine can build the designs.
  * * part_list - List of datum design ids for designs to add to the queue.
  */
/obj/machinery/mecha_part_fabricator/proc/add_part_set_to_queue(list/part_list)
	for(var/v in stored_research.researched_designs)
		var/datum/design/D = SSresearch.techweb_design_by_id(v)
		if((D.build_type & MECHFAB) && (D.id in part_list))
			add_to_queue(D)

/**
  * Adds a datum design to the build queue.
  *
  * Returns TRUE if successful and FALSE if the design was not added to the queue.
  * * D - Datum design to add to the queue.
  */
/obj/machinery/mecha_part_fabricator/proc/add_to_queue(datum/design/D)
	if(!istype(queue))
		queue = list()
	if(D)
		queue[++queue.len] = D
		return TRUE
	return FALSE

/**
  * Removes datum design from the build queue based on index.
  *
  * Returns TRUE if successful and FALSE if a design was not removed from the queue.
  * * index - Index in the build queue of the element to remove.
  */
/obj/machinery/mecha_part_fabricator/proc/remove_from_queue(index)
	if(!isnum_safe(index) || !ISINTEGER(index) || !istype(queue) || (index<1 || index>queue.len))
		return FALSE
	queue.Cut(index,++index)
	return TRUE

/**
  * Generates a list of parts formatted for tgui based on the current build queue.
  *
  * Returns a formatted list of lists containing formatted part information for every part in the build queue.
  */
/obj/machinery/mecha_part_fabricator/proc/list_queue()
	if(!istype(queue) || !length(queue))
		return null

	var/list/queued_parts = list()
	for(var/datum/design/D in queue)
		var/list/part = output_part_info(D)
		queued_parts += list(part)
	return queued_parts

/**
  * Syncs machine with R&D servers.
  *
  * Requires an R&D Console visible within 7 tiles. Copies techweb research. Updates tgui's state data.
  */
/obj/machinery/mecha_part_fabricator/proc/sync()
	for(var/obj/machinery/computer/rdconsole/RDC in orange(7,src))
		RDC.stored_research.copy_research_to(stored_research)
		update_static_data(usr)
		say("Successfully synchronized with R&D server.")
		return

	say("Unable to connect to local R&D server.")
	return

/**
  * Calculates the coefficient-modified resource cost of a single material component of a design's recipe.
  *
  * Returns coefficient-modified resource cost for the given material component.
  * * D - Design datum to pull the resource cost from.
  * * resource - Material datum reference to the resource to calculate the cost of.
  * * roundto - Rounding value for round() proc
  */
/obj/machinery/mecha_part_fabricator/proc/get_resource_cost_w_coeff(datum/design/D, var/datum/material/resource, roundto = 1)
	return round(D.materials[resource]*component_coeff, roundto)

/**
  * Calculates the coefficient-modified build time of a design.
  *
  * Returns coefficient-modified build time of a given design.
  * * D - Design datum to calculate the modified build time of.
  * * roundto - Rounding value for round() proc
  */
/obj/machinery/mecha_part_fabricator/proc/get_construction_time_w_coeff(construction_time, roundto = 1) //aran
	return round(construction_time*time_coeff, roundto)

/obj/machinery/mecha_part_fabricator/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/sheetmaterials)
	)

/obj/machinery/mecha_part_fabricator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ExosuitFabricator")
		ui.open()

/obj/machinery/mecha_part_fabricator/ui_static_data(mob/user)
	var/list/data = list()

	var/list/final_sets = list()
	var/list/buildable_parts = list()

	for(var/part_set in part_sets)
		final_sets += part_set

	for(var/v in stored_research.researched_designs)
		var/datum/design/D = SSresearch.techweb_design_by_id(v)
		if(D.build_type & MECHFAB)
			// This is for us.
			var/list/part = output_part_info(D, TRUE)

			if(part["category_override"])
				for(var/cat in part["category_override"])
					buildable_parts[cat] += list(part)
					if(!(cat in part_sets))
						final_sets += cat
				continue

			for(var/cat in part_sets)
				// Find all matching categories.
				if(!(cat in D.category))
					continue

				buildable_parts[cat] += list(part)

	data["partSets"] = final_sets
	data["buildableParts"] = buildable_parts

	return data

/obj/machinery/mecha_part_fabricator/ui_data(mob/user)
	var/list/data = list()

	data["materials"] = output_available_resources()

	if(being_built)
		var/list/part = list(
			"name" = being_built.name,
			"duration" = build_finish - world.time,
			"printTime" = get_construction_time_w_coeff(initial(being_built.construction_time))
		)
		data["buildingPart"] = part
	else
		data["buildingPart"] = null

	data["queue"] = list_queue()

	if(stored_part)
		data["storedPart"] = stored_part.name
	else
		data["storedPart"] = null

	data["isProcessingQueue"] = process_queue

	return data

/obj/machinery/mecha_part_fabricator/ui_act(action, var/list/params)
	if(..())
		return TRUE

	. = TRUE

	add_fingerprint(usr)
	usr.set_machine(src)

	switch(action)
		if("sync_rnd")
			// Sync with R&D Servers
			sync()
			return
		if("add_queue_set")
			// Add all parts of a set to queue
			var/part_list = params["part_list"]
			add_part_set_to_queue(part_list)
			return
		if("add_queue_part")
			// Add a specific part to queue
			var/T = params["id"]
			for(var/v in stored_research.researched_designs)
				var/datum/design/D = SSresearch.techweb_design_by_id(v)
				if((D.build_type & MECHFAB) && (D.id == T))
					add_to_queue(D)
					break
			return
		if("del_queue_part")
			// Delete a specific from from the queue
			var/index = text2num(params["index"])
			remove_from_queue(index)
			return
		if("clear_queue")
			// Delete everything from queue
			queue.Cut()
			return
		if("build_queue")
			// Build everything in queue
			if(process_queue)
				return
			process_queue = TRUE

			if(!being_built)
				START_PROCESSING(SSfastprocess, src)
			return
		if("stop_queue")
			// Pause queue building. Also known as stop.
			process_queue = FALSE
			return
		if("build_part")
			// Build a single part
			if(being_built || process_queue)
				return

			var/id = params["id"]
			var/datum/design/D = SSresearch.techweb_design_by_id(id)

			if(!(D.build_type & MECHFAB) || !(D.id == id))
				return

			if(build_part(D))
				on_start_printing()
				STOP_PROCESSING(SSfastprocess, src)

			return
		if("move_queue_part")
			// Moves a part up or down in the queue.
			var/index = text2num(params["index"])
			var/new_index = index + text2num(params["newindex"])
			if(isnum(index) && isnum(new_index) && ISINTEGER(index) && ISINTEGER(new_index))
				if(ISINRANGE(new_index,1,length(queue)))
					queue.Swap(index,new_index)
			return
		if("remove_mat")
			// Remove a material from the fab
			var/mat_ref = params["ref"]
			var/amount = text2num(params["amount"])
			var/datum/material/mat = locate(mat_ref)
			eject_sheets(mat, amount)
			return

	return FALSE

/**
  * Eject material sheets.
  *
  * Returns the number of sheets successfully ejected.
  * eject_sheet - Byond REF of the material to eject.
  *	eject_amt - Number of sheets to attempt to eject.
  */
/obj/machinery/mecha_part_fabricator/proc/eject_sheets(eject_sheet, eject_amt)
	var/datum/component/material_container/mat_container = rmat.mat_container
	if (!mat_container)
		say("No access to material storage, please contact the quartermaster.")
		return 0
	if (rmat.on_hold())
		say("Mineral access is on hold, please contact the quartermaster.")
		return 0
	var/count = mat_container.retrieve_sheets(text2num(eject_amt), eject_sheet, drop_location())
	var/list/matlist = list()
	matlist[eject_sheet] = text2num(eject_amt)
	rmat.silo_log(src, "ejected", -count, "sheets", matlist)
	return count

/obj/machinery/mecha_part_fabricator/proc/AfterMaterialInsert(type_inserted, id_inserted, amount_inserted)
	var/datum/material/M = id_inserted
	add_overlay("fab-load-[M.name]")
	addtimer(CALLBACK(src, /atom/proc/cut_overlay, "fab-load-[M.name]"), 10)

/obj/machinery/mecha_part_fabricator/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(being_built)
		to_chat(user, "<span class='warning'>\The [src] is currently processing! Please wait until completion.</span>")
		return FALSE
	return default_deconstruction_screwdriver(user, "fab-o", "fab-idle", I)

/obj/machinery/mecha_part_fabricator/crowbar_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(being_built)
		to_chat(user, "<span class='warning'>\The [src] is currently processing! Please wait until completion.</span>")
		return FALSE
	return default_deconstruction_crowbar(I)

/obj/machinery/mecha_part_fabricator/proc/is_insertion_ready(mob/user)
	if(panel_open)
		to_chat(user, "<span class='warning'>You can't load [src] while it's opened!</span>")
		return FALSE
	if(being_built)
		to_chat(user, "<span class='warning'>\The [src] is currently processing! Please wait until completion.</span>")
		return FALSE

	return TRUE

/obj/machinery/mecha_part_fabricator/maint
	link_on_init = FALSE
