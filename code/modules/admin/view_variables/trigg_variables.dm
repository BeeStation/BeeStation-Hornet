/client/proc/trigg_VV(datum/D in world)
	set category = "Debug"
	set name = "AAAVARIABLES"

	if(!usr.client || !usr.client.holder) //This is usr because admins can call the proc on other clients, even if they're not admins, to show them VVs.
		to_chat(usr, "<span class='danger'>You need to be an administrator to access this.</span>")
		return

	var/datum/trigg_variables/UI = new(usr, D)
	UI.ui_interact(usr)


#define VV_TITLE(D) ("[D] [REF(D)] = [objtype]")

/datum/trigg_variables
	var/client/C
	var/datum/D
	var/datum/tgui/UI
	var/islist
	var/objtype

	//We'll cache these to avoid rescanning everything on every single UI update
	var/list/data = list()
	var/list/staticdata = list()

/datum/trigg_variables/New(mob/user, target)
	C = user.client
	D = target

	islist = islist(D)
	objtype = islist? /list : D.type
	//Or, in English; '/list' if islist, else it's a datum so we can just 'D.type'

	if(!islist && !istype(D))
		CRASH("Uhhhh what the fuck did you just give me?")

/datum/trigg_variables/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.VV_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ViewVariables", "[REF(D)] ([objtype])", 700, 700, master_ui, state)
		ui.set_autoupdate(FALSE)
		ui.open()
	UI = ui

/datum/trigg_variables/ui_data(mob/user)
	message_admins("UI data update!")

	data["flags"] = get_flags()
	if(!islist) //no snowflakes for lists
		data["snowflake"] = get_snowflake()
	return data

/datum/trigg_variables/ui_static_data(mob/user)
	message_admins("UI static data update!")

	staticdata["vars"] = get_vars()
	staticdata["objectinfo"] = list(
		"name"  = islist ? "/list" : D,
		"ref"   = REF(D),
		"type"  = islist ? "" : objtype,
		"class" = C.vv_get_class(D, D),
		"title" = VV_TITLE(D),
		)
	staticdata["dropdown"] = get_dropdown()
	return staticdata

/datum/trigg_variables/proc/get_snowflake()
	. = list()
	. += D.vv_get_snowflake()

/datum/trigg_variables/proc/get_flags()
	.= list()
	if(C.holder && C.holder.marked_datum && C.holder.marked_datum == D)
		. += "MARKED"
	if(!islist && (D.datum_flags & DF_VAR_EDITED))
		. += "EDITED"
	if(!islist && D.gc_destroyed)
		. += "DELETED"

/datum/trigg_variables/proc/get_dropdown()
	.= list()
	if(islist)
		. = list()
		VV_DROPDOWN_OPTION2(VV_HK_LIST_ADD, "Add Item")
		VV_DROPDOWN_OPTION2(VV_HK_LIST_ERASE_NULLS, "Remove Nulls")
		VV_DROPDOWN_OPTION2(VV_HK_LIST_ERASE_DUPES, "Remove Dupes")
		VV_DROPDOWN_OPTION2(VV_HK_LIST_SET_LENGTH, "Set len")
		VV_DROPDOWN_OPTION2(VV_HK_LIST_SHUFFLE, "Shuffle")
		VV_DROPDOWN_OPTION2(VV_HK_EXPOSE, "Show VV To Player")
	else
		.= D.vv_get_dropdown2()


//The part that matters, the VARIABLES!

/datum/trigg_variables/proc/get_vars()
	message_admins("GETTIN' VARS")
	.= list()
	var/list/names = list()
	if(!islist)
		for(var/V in D.vars)
			names += V

	var/list/item
	if(islist)
		var/list/L = D
		for(var/i in 1 to L.len)
			var/key = L[i]
			var/value
			if(IS_NORMAL_LIST(L) && IS_VALID_ASSOC_KEY(key))
				value = L[key]
			item = debug_variable2(i, value, 0, L)
			item += list("type" = C.vv_get_class(item["name"], item["value"]))
			item += list("index" = i)
			.+= list(item)
	else
		names = sortList(names)
		for(var/V in names)
			if(D.can_vv_get(V))
				item = D.vv_get_var2(V)
				item += list("type" = C.vv_get_class(item["name"], item["value"]))
				.+= list(item)


/datum/trigg_variables/ui_close(mob/user)
	message_admins("UI CLOSE!")

/datum/trigg_variables/ui_act(action, params)
	if(..())
		return

	message_admins("UI act! Action: '[action]' | Params: '[english_list(params)]'")

	switch(action)
		if("to_asay")
			message_admins("[key_name_admin(usr)] has shared a VV window: [ADMIN_VV_LINK(D)]")
			return

	if(view_var_Topic2(action, params))
		return TRUE //quick reminder for anyone code diving: returning TRUE makes the UI update.

#undef VV_TITLE


