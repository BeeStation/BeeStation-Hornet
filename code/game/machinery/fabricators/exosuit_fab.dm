/obj/machinery/modular_fabricator/exosuit_fab
	icon = 'icons/obj/robotics.dmi' //Previously known as "/obj/machinery/mecha_part_fabricator", before modular_fabricator refactor of 2021
	icon_state = "fab-idle"
	name = "exosuit fabricator"
	desc = "An advanced machine containing many internal robotic arms which fabricate components for robots and exosuits."
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 5000
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/machine/mechfab
	output_direction = SOUTH
	remote_materials = TRUE
	can_print_entire_categories = TRUE
	use_station_research = TRUE
	allowed_buildtypes = MECHFAB

/obj/machinery/modular_fabricator/exosuit_fab/ui_interact(mob/user, datum/tgui/ui)
	if(!is_operational)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ExosuitFabricator")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/modular_fabricator/exosuit_fab/ui_static_data(mob/user)
	var/list/data = list()
	data["designs"] = fabricator_ui_designs(cached_designs, creation_efficiency)
	return data

/obj/machinery/modular_fabricator/exosuit_fab/ui_data(mob/user)
	var/list/data = list()
	var/datum/component/material_container/materials = get_material_container()
	data["materials"] = materials?.ui_data()
	data["queue"] = list()
	data["processing"] = operating

	if(being_built)
		data["queue"] += list(list(
			"jobId" = "building-[being_built.id]",
			"designId" = being_built.id,
			"processing" = TRUE,
			"timeLeft" = max(process_completion_world_tick - world.time, 0),
		))

	var/queue_index = 0
	for(var/design_id in design_queue)
		for(var/copy in 1 to max(design_queue[design_id]["amount"], 1))
			queue_index++
			data["queue"] += list(list(
				"jobId" = "queued-[queue_index]-[design_id]",
				"designId" = design_id,
				"processing" = FALSE,
				"timeLeft" = 0,
			))
	return data

/obj/machinery/modular_fabricator/exosuit_fab/screwdriver_act(mob/living/user, obj/item/tool)
	if(operating)
		to_chat(user, span_warning("\The [src] is currently processing! Please wait until completion."))
		return
	return default_deconstruction_screwdriver(user, "fab-o", "fab-idle", tool)

/obj/machinery/modular_fabricator/exosuit_fab/crowbar_act(mob/living/user, obj/item/tool)
	if(operating)
		to_chat(user, span_warning("\The [src] is currently processing! Please wait until completion."))
		return
	return default_deconstruction_crowbar(tool)

/obj/machinery/modular_fabricator/exosuit_fab/after_material_insert(type_inserted, id_inserted, amount_inserted)
	. = ..()
	var/datum/material/M = id_inserted
	add_overlay("fab-load-[M.name]")
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, cut_overlay), "fab-load-[M.name]"), 10)

/obj/machinery/modular_fabricator/exosuit_fab/set_default_sprite()
	cut_overlay("fab-active")

/obj/machinery/modular_fabricator/exosuit_fab/set_working_sprite()
	add_overlay("fab-active")

/obj/machinery/modular_fabricator/exosuit_fab/maint
	auto_link = FALSE
