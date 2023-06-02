/datum/antagonist/traitor
	ui_name = "TraitorObjectivesMenu"
	var/datum/action/innate/traitor_menu/menu

/datum/antagonist/traitor/proc/add_menu_action()
	if(menu != null)
		return
	menu = new /datum/action/innate/traitor_menu(src)
	menu.Grant(owner.current)

/datum/action/innate/traitor_menu
	name = "Traitor Objectives"
	desc = "View and customize your traitor faction, backstory, objectives, and objective backstories."
	button_icon_state = "traitor_objectives"
	background_icon_state = "bg_agent"
	var/datum/antagonist/traitor/ownerantag

/datum/action/innate/traitor_menu/New(datum/H)
	. = ..()
	button.name = name
	ownerantag = H

/datum/action/innate/traitor_menu/Activate()
	ownerantag.ui_interact(owner)

/datum/antagonist/traitor/ui_data(mob/user)
	var/list/data = list()
	data["allowed_factions"] = allowed_factions
	data["allowed_backstories"] = allowed_backstories
	data["recommended_factions"] = recommended_factions
	data["recommended_backstories"] = recommended_backstories
	if(istype(backstory))
		data["backstory"] = "[backstory.type]"
	if(istype(faction))
		data["faction"] = faction.key
	return data

/datum/antagonist/traitor/ui_static_data(mob/user)
	var/list/data = list()
	var/list/all_factions = list()
	for(var/key in GLOB.traitor_factions_to_datum)
		var/datum/traitor_faction/faction = GLOB.traitor_factions_to_datum[key]
		all_factions[key] = list(
			"name" = faction.name,
			"description" = faction.description,
			"key" = key,
		)
	data["all_factions"] = all_factions
	var/list/all_backstories = list()
	for(var/path in GLOB.traitor_backstories)
		var/datum/traitor_backstory/backstory = GLOB.traitor_backstories[path]
		all_backstories[path] = list(
			"name" = backstory.name,
			"description" = backstory.description,
			"path" = path,
			"allowed_factions" = backstory.allowed_factions,
			"motivations" = backstory.motivations,
		)
	data["all_backstories"] = all_backstories
	data["all_motivations"] = GLOB.traitor_motivations
	return data

/datum/antagonist/traitor/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("select_backstory")
			if(istype(backstory)) // bad!!
				return TRUE
			var/datum/traitor_backstory/selected_backstory = GLOB.traitor_backstories[params["backstory"]]
			var/datum/traitor_faction/selected_faction = GLOB.traitor_factions_to_datum[params["faction"]]
			if(!istype(selected_faction) || !istype(selected_backstory))
				return TRUE
			if(istype(faction) && faction.key != selected_faction.key) // bad!
				return TRUE
			if(!(selected_faction.key in selected_backstory.allowed_factions))
				return TRUE
			if(!("[selected_backstory.type]" in allowed_backstories))
				return TRUE
			set_faction(selected_faction)
			set_backstory(selected_backstory)
			return TRUE
