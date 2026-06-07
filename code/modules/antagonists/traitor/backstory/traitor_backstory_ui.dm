/datum/antagonist/traitor
	ui_name = "TraitorBackstoryMenu"

/// We will handle this ourselves, thank you.
/datum/antagonist/traitor/make_info_button()
	return null

/datum/antagonist/traitor/proc/add_menu_action()
	if(info_button_ref?.resolve() != null)
		return
	var/datum/action/antag_info/traitor_menu/menu = new(src)
	menu.Grant(owner.current)
	info_button_ref = WEAKREF(menu)

/datum/action/antag_info/traitor_menu
	name = "Traitor Info and Backstory"
	desc = "View and customize your backstory, objectives, codewords, uplink location, \
	and objective backstories."
	button_icon_state = "traitor_objectives"
	button_icon = 'icons/hud/actions/action_generic.dmi'
	background_icon_state = "bg_agent"

/datum/action/antag_info/traitor_menu/New(datum/H)
	. = ..()
	name = "Traitor Info and Backstory"

/datum/antagonist/traitor/ui_data(mob/user)

	var/list/data = list()
	data["allowed_backstories"] = allowed_backstories
	data["recommended_backstories"] = recommended_backstories
	if(istype(backstory))
		data["backstory"] = "[backstory.type]"

	var/datum/component/uplink/uplink = uplink_ref?.resolve()
	data["antag_name"] = name
	data["has_codewords"] = has_codewords
	if(has_codewords)
		data["phrases"] = jointext(GLOB.syndicate_code_phrase, ", ")
		data["responses"] = jointext(GLOB.syndicate_code_response, ", ")
	data["code"] = islist(uplink?.unlock_code) ? english_list(uplink?.unlock_code) : uplink?.unlock_code
	data["failsafe_code"] = islist(uplink?.failsafe_code) ? english_list(uplink?.failsafe_code) : uplink?.failsafe_code
	data["has_uplink"] = uplink ? TRUE : FALSE
	if(uplink)
		data["uplink_unlock_info"] = uplink.unlock_text
	data["objectives"] = get_objectives()
	data["backup_code"] = backup_code

	return data

/datum/antagonist/traitor/ui_static_data(mob/user)
	var/list/data = list()
	var/list/all_backstories = list()
	for(var/path in GLOB.traitor_backstories)
		var/datum/traitor_backstory/backstory = GLOB.traitor_backstories[path]
		all_backstories[path] = list(
			"name" = backstory.name,
			"description" = backstory.description,
			"path" = path,
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
			if(!("[selected_backstory.type]" in allowed_backstories))
				return TRUE
			set_backstory(selected_backstory)
			return TRUE
