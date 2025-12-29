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
	can_sync = TRUE
	can_print_category = TRUE

	categories = list(
		RND_CATEGORY_CYBORG,
		RND_CATEGORY_RIPLEY,
		RND_CATEGORY_ODYSSEUS,
		RND_CATEGORY_CLARKE,
		RND_CATEGORY_GYGAX,
		RND_CATEGORY_DURAND,
		RND_CATEGORY_HONK,
		RND_CATEGORY_PHAZON,
		RND_CATEGORY_EXOSUIT_EQUIPMENT,
		RND_CATEGORY_EXOSUIT_AMMUNITION,
		RND_CATEGORY_CYBORG_UPGRADE_MODULES,
		RND_CATEGORY_IPC_COMPONENTS,
		RND_CATEGORY_CYBERNETICS,
		RND_CATEGORY_IMPLANTS,
		RND_CATEGORY_CONTROL_INTERFACES,
		RND_CATEGORY_MOD_CONSTRUCTION,
		RND_CATEGORY_MOD_MODULES,
		RND_CATEGORY_MISC,
	)

	stored_research_type = /datum/techweb/autounlocking/exofab

/obj/machinery/modular_fabricator/exosuit_fab/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(being_built)
		to_chat(user, span_warning("\The [src] is currently processing! Please wait until completion."))
		return FALSE
	return default_deconstruction_screwdriver(user, "fab-o", "fab-idle", I)

/obj/machinery/modular_fabricator/exosuit_fab/crowbar_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(being_built)
		to_chat(user, span_warning("\The [src] is currently processing! Please wait until completion."))
		return FALSE
	return default_deconstruction_crowbar(I)

/obj/machinery/modular_fabricator/exosuit_fab/AfterMaterialInsert(type_inserted, id_inserted, amount_inserted)
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
