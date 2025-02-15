GLOBAL_LIST_EMPTY(objective_computers)

/obj/machinery/computer/objective
	name = "station objective console"
	desc = "A networked console that downloads and displays currently assigned station objectives."
	icon_screen = "bounty"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_ORANGE
	req_access = list( )
	circuit = /obj/item/circuitboard/computer/objective
	var/list/viewing_mobs = list()

CREATION_TEST_IGNORE_SUBTYPES(/obj/machinery/computer/objective)

/obj/machinery/computer/objective/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	GLOB.objective_computers += src

/obj/machinery/computer/objective/Destroy()
	GLOB.objective_computers -= src
	. = ..()

/obj/machinery/computer/objective/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/objective/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Objective")
		ui.open()
	viewing_mobs += user

/obj/machinery/computer/objective/ui_close(mob/user, datum/tgui/tgui)
	viewing_mobs -= user

/obj/machinery/computer/objective/ui_static_data(mob/user)
	var/list/data = list()
	data["possible_objectives"] = list()
	for(var/datum/orbital_objective/objective in SSorbits.possible_objectives)
		data["possible_objectives"] += list(list(
			"name" = objective.name,
			"id" = objective.id,
			"payout" = objective.payout,
			"description" = objective.get_text()
		))
	data["selected_objective"] = null
	if(SSorbits.current_objective)
		data["selected_objective"] = list(
			"name" = SSorbits.current_objective.name,
			"id" = SSorbits.current_objective.id,
			"payout" = SSorbits.current_objective.payout,
			"description" = SSorbits.current_objective.get_text()
		)
	return data

/obj/machinery/computer/objective/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(action != "assign")
		return
	var/obj_id = params["id"]
	for(var/datum/orbital_objective/objective in SSorbits.possible_objectives)
		if(objective.id == obj_id)
			say(SSorbits.assign_objective(src, objective))
			return
