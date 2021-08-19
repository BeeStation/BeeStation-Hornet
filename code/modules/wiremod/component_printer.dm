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
