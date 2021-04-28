/datum/trait_panel
	var/static/list/trait_types = list(STATION_TRAIT_POSITIVE, STATION_TRAIT_NEUTRAL, STATION_TRAIT_NEGATIVE)

/datum/trait_panel/New(mob/user)
	ui_interact(user)

/datum/trait_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/trait_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TraitPanel")
		ui.open()

/datum/trait_panel/ui_data()
	var/list/data = list()
	//for(var/type in SSstation.selectable_traits_by_types)
	//	for(var/datum/station_trait/T in SSstation.selectable_traits_by_types[type])
	//		data["traits"] |= list(list(T.name, T.trait_type))

	for(var/type in trait_types)
		for(var/datum/station_trait/T in SSstation.selectable_traits_by_types[type])
			data["traits"] |= list(list(initial(T.name), initial(T.trait_type)))

	return data

/datum/trait_panel/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("add")
			CRASH("test")
