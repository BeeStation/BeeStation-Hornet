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

/obj/machinery/modular_fabricator/component_printer/crowbar_act(mob/living/user, obj/item/tool)

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

/obj/machinery/debug_component_printer
	name = "debug component printer"
	desc = "Produces components for the creation of integrated circuits."
	icon = 'icons/obj/wiremod_fab.dmi'
	icon_state = "fab-idle"

	/// All of the possible circuit designs stored by this debug printer
	var/list/all_circuit_designs

	density = TRUE

/obj/machinery/debug_component_printer/Initialize()
	. = ..()
	all_circuit_designs = list()

	for(var/id in SSresearch.techweb_designs)
		var/datum/design/design = SSresearch.techweb_design_by_id(id)
		if((design.build_type & COMPONENT_PRINTER) && design.build_path)
			all_circuit_designs[design.build_path] = list(
				"name" = design.name,
				"description" = design.desc,
				"materials" = design.materials,
				"categories" = design.category
			)

	for(var/obj/item/circuit_component/component as anything in subtypesof(/obj/item/circuit_component))
		var/categories = list("Inaccessible")
		if(initial(component.circuit_flags) & CIRCUIT_FLAG_ADMIN)
			categories = list("Admin")
		if(!(component in all_circuit_designs))
			all_circuit_designs[component] = list(
				"name" = initial(component.display_name),
				"description" = initial(component.desc),
				"materials" = list(),
				"categories" = categories,
			)

/obj/machinery/debug_component_printer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ComponentPrinter", name)
		ui.open()

/obj/machinery/debug_component_printer/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/sheetmaterials)
	)

/obj/machinery/debug_component_printer/ui_act(action, list/params)
	. = ..()
	if (.)
		return

	switch (action)
		if ("print")
			var/build_path = text2path(params["designId"])
			if (!build_path)
				return TRUE

			var/list/design = all_circuit_designs[build_path]
			if(!design)
				return TRUE

			balloon_alert_to_viewers("printed [design["name"]]")
			new build_path(drop_location())

	return TRUE

/obj/machinery/debug_component_printer/ui_static_data(mob/user)
	var/list/data = list()

	data["materials"] = list()
	data["designs"] = all_circuit_designs

	return data

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

	var/cost_per_component = 1000

/obj/machinery/module_duplicator/Initialize(mapload)
	. = ..()
	materials = AddComponent(/datum/component/remote_materials, "lathe", mapload)

/obj/machinery/module_duplicator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ComponentPrinter", name)
		ui.open()

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

	return TRUE

/obj/machinery/module_duplicator/proc/print_module(list/design)
	flick("module-fab-print", src)
	addtimer(CALLBACK(src, .proc/finish_module_print, design), 1.6 SECONDS)

/obj/machinery/module_duplicator/proc/finish_module_print(list/design)
	var/obj/item/circuit_component/module/module = new(drop_location())
	module.load_data_from_list(design["dupe_data"])

/obj/machinery/module_duplicator/attackby(obj/item/weapon, mob/user, params)
	if(!istype(weapon, /obj/item/circuit_component/module))
		return ..()

	var/obj/item/circuit_component/module/module = weapon
	if(module.circuit_flags & CIRCUIT_FLAG_UNDUPEABLE)
		balloon_alert(user, "module cannot be saved!")
		return ..()

	if(module.display_name == initial(module.display_name))
		balloon_alert(user, "module needs a name!")
		return ..()

	for(var/list/component_data as anything in scanned_designs)
		if(component_data["name"] == module.display_name)
			balloon_alert(user, "module name already exists!")
			return ..()

	var/total_cost = 0
	for(var/obj/item/circuit_component/component as anything in module.internal_circuit.attached_components)
		if(component.circuit_flags & CIRCUIT_FLAG_UNDUPEABLE)
			balloon_alert(user, "module contains prohibited components!")
			return ..()

		total_cost += cost_per_component

	var/list/data = list()

	data["dupe_data"] = list()
	module.save_data_to_list(data["dupe_data"])

	data["name"] = module.display_name
	data["desc"] = "A module that has been loaded in by [user]."
	data["materials"] = list(/datum/material/glass = total_cost)

	flick("module-fab-scan", src)
	addtimer(CALLBACK(src, .proc/finish_module_scan, user, data), 1.4 SECONDS)

/obj/machinery/module_duplicator/proc/finish_module_scan(mob/user, data)
	scanned_designs += list(data)

	balloon_alert(user, "module has been saved.")
	playsound(src, 'sound/machines/ping.ogg', 50)

/obj/machinery/module_duplicator/ui_data(mob/user)
	var/list/data = list()
	data["materials"] = materials.mat_container.ui_data()
	return data

/obj/machinery/module_duplicator/ui_static_data(mob/user)
	var/list/data = list()

	var/list/designs = list()

	var/index = 1
	for (var/list/design as anything in scanned_designs)
		designs["[index]"] = list(
			"name" = design["name"],
			"description" = design["desc"],
			"materials" = get_material_cost_data(design["materials"]),
			"categories" = list("Circuitry"),
		)
		index++

	data["designs"] = designs

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
	build_path = /obj/machinery/module_duplicator
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/reagent_containers/glass/beaker = 2,
	)
