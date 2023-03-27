GLOBAL_LIST_EMPTY(objective_computers)

/obj/machinery/computer/objective
	name = "station objective console"
	desc = "A networked console that downloads and displays currently assigned station objectives."
	icon_screen = "bounty"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_ORANGE
	req_access = list()
	circuit = /obj/item/circuitboard/computer/objective
	var/faction_type = /datum/faction/independant

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

/obj/machinery/computer/objective/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["possible_objectives"] = list()
	var/datum/faction/lead_faction = SSorbits.get_lead_faction(faction_type)
	if (!lead_faction)
		return data
	for(var/datum/mission/objective in lead_faction.available_missions)
		data["possible_objectives"] += list(list(
			"name" = objective.name,
			"id" = objective.id,
			"payout" = objective.payment,
			"description" = objective.description
		))
	return data

/obj/machinery/computer/objective/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch (action)
		if ("assign")
			var/datum/faction/lead_faction = SSorbits.get_lead_faction(faction_type)
			if (!lead_faction)
				return FALSE
			var/obj_id = params["id"]
			for(var/datum/mission/objective in lead_faction.available_missions)
				// Find the client's lobby
				if(objective.id == obj_id)
					objective.accept(usr.client.lobby)
					return TRUE
