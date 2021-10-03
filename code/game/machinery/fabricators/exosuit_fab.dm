/obj/machinery/modular_fabricator/exosuit_fab
	icon = 'icons/obj/robotics.dmi'
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
	auto_link = TRUE
	can_sync = TRUE
	can_print_category = TRUE

	categories = list(
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

	stored_research_type = /datum/techweb/specialized/autounlocking/exofab

/obj/machinery/modular_fabricator/exosuit_fab/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(being_built)
		to_chat(user, "<span class='warning'>\The [src] is currently processing! Please wait until completion.</span>")
		return FALSE
	return default_deconstruction_screwdriver(user, "fab-o", "fab-idle", I)

/obj/machinery/modular_fabricator/exosuit_fab/crowbar_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(being_built)
		to_chat(user, "<span class='warning'>\The [src] is currently processing! Please wait until completion.</span>")
		return FALSE
	return default_deconstruction_crowbar(I)

/obj/machinery/modular_fabricator/exosuit_fab/AfterMaterialInsert(type_inserted, id_inserted, amount_inserted)
	. = ..()
	var/datum/material/M = id_inserted
	add_overlay("fab-load-[M.name]")
	addtimer(CALLBACK(src, /atom/proc/cut_overlay, "fab-load-[M.name]"), 10)

/obj/machinery/modular_fabricator/exosuit_fab/set_default_sprite()
	cut_overlay("fab-active")

/obj/machinery/modular_fabricator/exosuit_fab/set_working_sprite()
	add_overlay("fab-active")

/obj/machinery/modular_fabricator/exosuit_fab/maint
	auto_link = FALSE
