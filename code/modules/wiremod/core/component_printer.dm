/obj/machinery/modular_fabricator/component_printer
	name = "component printer"
	desc = "Produces components for the creation of integrated circuits."
	icon = 'icons/obj/wiremod_fab.dmi'
	icon_state = "fab-idle"
	circuit = /obj/item/circuitboard/machine/component_printer

	remote_materials = TRUE
	auto_link = TRUE
	can_sync = TRUE

	//Quick.
	minimum_construction_time = 5

	stored_research_type = /datum/techweb/specialized/autounlocking/component_printer

	categories = WIREMODE_CATEGORIES

/obj/machinery/component_printer/crowbar_act(mob/living/user, obj/item/tool)

	if(..())
		return TRUE
	return default_deconstruction_crowbar(tool)

/obj/machinery/modular_fabricator/component_printer/screwdriver_act(mob/living/user, obj/item/tool)
	if(..())
		return TRUE
	return default_deconstruction_screwdriver(user, "fab-o", "fab-idle", tool)

/obj/item/circuitboard/machine/component_printer
	name = "\improper Component Printer (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/modular_fabricator/component_printer
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/reagent_containers/glass/beaker = 2,
	)

/// Module duplicator, allows you to save and recreate module components.
/obj/machinery/module_duplicator
	name = "module duplicator"
	desc = "Allows you to duplicate module components so that you don't have to recreate them. Scan a module component over this machine to add it as an entry."
	icon = 'icons/obj/wiremod_fab.dmi'
	icon_state = "module-fab-idle"
	circuit = /obj/item/circuitboard/machine/module_duplicator

	/// The internal material bus
	var/datum/component/remote_materials/materials

	density = TRUE

	var/list/scanned_designs = list()

	//Viewing mobs of the UI to update
	var/list/mob/viewing_mobs = list()

	///the multiplier for how much materials the created object takes from this machines stored materials
	var/creation_efficiency = 1.2

/obj/machinery/module_duplicator/Initialize(mapload)
	materials = AddComponent( \
		/datum/component/remote_materials, \
		"lathe", \
		mapload \
	)
	. = ..()

/obj/machinery/module_duplicator/ui_interact(mob/user, datum/tgui/ui = null)
	if(!is_operational)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ComponentPrinter", name)
		ui.open()
		ui.set_autoupdate(TRUE)
		viewing_mobs += user

/obj/machinery/modular_fabricator/ui_close(mob/user, datum/tgui/tgui)
	. = ..()
	viewing_mobs -= user

/obj/machinery/module_duplicator/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/sheetmaterials)
	)

/obj/machinery/module_duplicator/ui_act(action, list/params)
	. = ..()
	if (.)
		return

	switch (action)
		if ("print")
			var/design_id = text2num(params["designId"])

			if (design_id < 1 || design_id > length(scanned_designs))
				return TRUE

			var/list/design = scanned_designs[design_id]

			if (materials.on_hold())
				say("Mineral access is on hold, please contact the quartermaster.")
				return TRUE

			if (!materials.mat_container?.has_materials(design["materials"]))
				say("Not enough materials.")
				return TRUE

			balloon_alert_to_viewers("printed [design["name"]]")
			materials.mat_container?.use_materials(design["materials"])
			materials.silo_log(src, "printed", -1, design["name"], design["materials"])
			print_module(design)
		if ("remove_mat")
			var/datum/material/material = locate(params["ref"])
			var/amount = text2num(params["amount"])

			if (!amount)
				return TRUE

			// SAFETY: eject_sheets checks for valid mats
			materials.eject_sheets(material, amount)
			update_viewer_statics()

	return TRUE

/obj/machinery/module_duplicator/proc/print_module(list/design)
	flick("module-fab-print", src)
	addtimer(CALLBACK(src, PROC_REF(finish_module_print), design), 1.6 SECONDS)

/obj/machinery/module_duplicator/proc/finish_module_print(list/design)
	var/atom/movable/created_atom
	if(design["integrated_circuit"])
		var/obj/item/integrated_circuit/circuit = new(drop_location())
		var/list/errors = list()
		circuit.load_circuit_data(design["dupe_data"], errors)
		if(length(errors))
			stack_trace("Error loading user saved circuit [errors.Join(", ")].")
		created_atom = circuit
	else
		var/obj/item/circuit_component/module/module = new(drop_location())
		module.load_data_from_list(design["dupe_data"])
		created_atom = module
	created_atom.pixel_x = initial(created_atom.pixel_x) + rand(-5, 5)
	created_atom.pixel_y = initial(created_atom.pixel_y) + rand(-5, 5)
	update_viewer_statics()

/obj/machinery/module_duplicator/attackby(obj/item/weapon, mob/user, params)
	var/list/data = list()

	if(istype(weapon, /obj/item/circuit_component/module))
		var/obj/item/circuit_component/module/module = weapon

		data["dupe_data"] = list()
		module.save_data_to_list(data["dupe_data"])
		data["name"] = module.display_name

		var/length = length(module.internal_circuit.attached_components) - 2
		data["desc"] = "A module that has been loaded in by [user]. It has [length == 0 ? "no" : length] internal [length == 1 ? "component" : "components"]."

		data["materials"] = module.get_material_cost()
	else if(istype(weapon, /obj/item/integrated_circuit))
		var/obj/item/integrated_circuit/integrated_circuit = weapon

		data["dupe_data"] = integrated_circuit.convert_to_json()
		data["name"] = integrated_circuit.display_name

		var/length = length(integrated_circuit.attached_components)
		data["desc"] = "An integrated circuit that has been loaded in by [user]. It has [length == 0 ? "no" : length] attached [length == 1 ? "component" : "components"]."

		data["materials"] = integrated_circuit.get_material_cost()
		data["integrated_circuit"] = TRUE

	if(!length(data))
		return ..()

	if(!data["name"])
		balloon_alert(user, "it needs a name!")
		return ..()

	for(var/list/component_data as anything in scanned_designs)
		if(component_data["name"] == data["name"])
			balloon_alert(user, "name already exists!")
			return ..()

	flick("module-fab-scan", src)
	addtimer(CALLBACK(src, PROC_REF(finish_module_scan), user, data), 1.4 SECONDS)

/obj/machinery/module_duplicator/proc/finish_module_scan(mob/user, data)
	scanned_designs += list(data)

	balloon_alert(user, "module has been saved.")
	playsound(src, 'sound/machines/ping.ogg', 50)
	update_viewer_statics()

/obj/machinery/module_duplicator/RefreshParts()
	var/efficiency = 1.2
	for(var/obj/item/stock_parts/manipulator/new_manipulator in component_parts)
		efficiency -= new_manipulator.rating * 0.15
	creation_efficiency = max(0.1,efficiency)
	update_viewer_statics()

/obj/machinery/module_duplicator/proc/update_viewer_statics()
	for(var/mob/M in viewing_mobs)
		if(QDELETED(M) || !(M.client || M.mind))
			continue
		update_static_data(M)

/obj/machinery/module_duplicator/ui_static_data(mob/user)
	var/list/data = list()
	var/list/designs = list()

	var/index = 1
	for (var/list/D as anything in scanned_designs)
		//Calculate cost
		var/list/material_cost = list()
		for(var/mat_id in D["materials"])
			material_cost[mat_id] = D["materials"][mat_id] * creation_efficiency

		//Add
		designs["[index]"] = list(
			"name" = D["name"],
			"description" = D["desc"],
			"materials" = material_cost,
			"categories" = list("Circuitry"),
		)
		index++

	data["designs"] = designs
	data["materials"] = materials.mat_container.ui_data()

	return data

/obj/machinery/module_duplicator/crowbar_act(mob/living/user, obj/item/tool)
	if(..())
		return TRUE
	return default_deconstruction_crowbar(tool)

/obj/machinery/module_duplicator/screwdriver_act(mob/living/user, obj/item/tool)
	if(..())
		return TRUE
	return default_deconstruction_screwdriver(user, "module-fab-o", "module-fab-idle", tool)

/obj/machinery/module_duplicator/proc/get_material_cost_data(list/materials)
	var/list/data = list()

	for (var/datum/material/material_type as anything in materials)
		data[initial(material_type.name)] = materials[material_type]

	return data

/obj/item/circuitboard/machine/module_duplicator
	name = "\improper Module Duplicator (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/module_duplicator
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/reagent_containers/glass/beaker = 2,
	)
