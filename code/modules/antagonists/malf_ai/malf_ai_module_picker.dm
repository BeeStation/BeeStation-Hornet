/datum/action/innate/choose_modules
	name = "Malfunction Modules"
	desc = "Choose from a variety of insidious modules to aid you."
	button_icon = 'icons/hud/actions/actions_AI.dmi'
	button_icon_state = "modules_menu"
	var/datum/module_picker/module_picker

/datum/action/innate/choose_modules/New(picker)
	. = ..()
	if(istype(picker, /datum/module_picker))
		module_picker = picker
	else
		CRASH("choose_modules action created with non module picker")

/datum/action/innate/choose_modules/on_activate()
	module_picker.ui_interact(owner)

/// The datum and interface for the malf unlock menu, which lets them choose actions to unlock.
/datum/module_picker
	var/name = "Malfunction Modules Menu"
	var/selected_cat
	var/compact_mode = FALSE
	var/processing_time = 50
	var/list/possible_modules

/datum/module_picker/New()
	possible_modules = get_malf_modules()

/proc/cmp_malfmodules_priority(datum/ai_module/A, datum/ai_module/B)
	return B.cost - A.cost

/proc/get_malf_modules()
	var/list/filtered_modules = list()

	for(var/path in GLOB.malf_modules)
		var/datum/ai_module/AM = new path
		if((AM.power_type == /datum/action/innate/ai) && !AM.upgrade)
			continue
		if(!filtered_modules[AM.category])
			filtered_modules[AM.category] = list()
		filtered_modules[AM.category][AM] = AM

	for(var/category in filtered_modules)
		sortTim(filtered_modules[category], GLOBAL_PROC_REF(cmp_malfmodules_priority))

	return filtered_modules

/datum/module_picker/ui_state(mob/user)
	return GLOB.always_state

/datum/module_picker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MalfunctionModulePicker", name)
		ui.open()

/datum/module_picker/ui_data(mob/user)
	var/list/data = list()
	data["processingTime"] = processing_time
	data["compactMode"] = compact_mode
	return data

/datum/module_picker/ui_static_data(mob/user)
	var/list/data = list()

	data["categories"] = list()
	for(var/category in possible_modules)
		var/list/cat = list(
			"name" = category,
			"items" = list())
		for(var/module in possible_modules[category])
			var/datum/ai_module/AM = possible_modules[category][module]
			cat["items"] += list(list(
				"name" = AM.name,
				"cost" = AM.cost,
				"desc" = AM.description,
			))
		data["categories"] += list(cat)

	return data

/datum/module_picker/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!isAI(usr))
		return
	switch(action)
		if("buy")
			var/item_name = params["name"]
			var/list/buyable_items = list()
			for(var/category in possible_modules)
				buyable_items += possible_modules[category]
			for(var/key in buyable_items)
				var/datum/ai_module/module = buyable_items[key]
				if(module.name == item_name)
					purchase_module(usr, module)
					return TRUE
		if("select")
			selected_cat = params["category"]
			return TRUE
		if("compact_toggle")
			compact_mode = !compact_mode
			return TRUE

/datum/module_picker/proc/purchase_module(mob/living/silicon/ai/AI, datum/ai_module/AM)
	if(!istype(AM))
		return
	if(!AI || AI.stat == DEAD)
		return
	if(AM.cost > processing_time)
		return

	var/datum/action/innate/ai/action = locate(AM.power_type) in AI.actions
	// Give the power and take away the money.
	if(AM.upgrade) //upgrade and upgrade() are separate, be careful!
		AM.upgrade(AI)
		possible_modules[AM.category] -= AM
		if(AM.unlock_text)
			to_chat(AI, AM.unlock_text)
		if(AM.unlock_sound)
			AI.playsound_local(AI, AM.unlock_sound, 50, 0)
		update_static_data(AI)
	else
		if(AM.power_type)
			if(AM.unlock_text)
				to_chat(AI, AM.unlock_text)
			if(AM.unlock_sound)
				AI.playsound_local(AI, AM.unlock_sound, 50, 0)

			if(!action) //Unlocking for the first time
				var/datum/action/AC = new AM.power_type
				AC.Grant(AI)
				AI.current_modules += new AM.type
				if(AM.one_purchase)
					possible_modules[AM.category] -= AM
					update_static_data(AI)

			else //Adding uses to an existing module
				action.uses += initial(action.uses)
				action.desc = "[initial(action.desc)] It has [action.uses] use\s remaining."
				action.update_buttons()
	processing_time -= AM.cost
	AI.log_message("purchased malf module [AM.name] (NEW PROCESSING: [processing_time])", LOG_GAME)
	SSblackbox.record_feedback("nested tally", "malfunction_modules_bought", 1, list("[initial(AM.name)]", "[AM.cost]"))
