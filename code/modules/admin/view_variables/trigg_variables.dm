/client/proc/trigg_VV(datum/D in world)
	set category = "Debug"
	set name = "AAAVARIABLES"
	if(!D)
		message_admins("Oh fuck trigg_VV was called without a D what the fuck")
		return

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

	var/list/data = list()
	var/list/staticdata = list()

/datum/trigg_variables/New(mob/user, target)
	C = user.client
	if(!C)
		CRASH("Uh... No client? What?")
	if(!target)
		CRASH("What the hell... No target?")
	D = target

	if(!D)
		CRASH("Boi D is null I'm outta here")

	islist = islist(D)
	objtype = islist? /list : D.type
	//Or, in English; '/list' if islist, else it's a datum so we can just 'D.type'

	if(!islist && !istype(D))
		CRASH("Uhhhh what the fuck did you just give me?")

/datum/trigg_variables/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.admin_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ViewVariables", "[REF(D)] ([objtype])", 700, 700, master_ui, state)
		ui.set_autoupdate(FALSE)
		ui.open()
	UI = ui

/datum/trigg_variables/ui_data(mob/user)
	message_admins("UI data update!")

	data["flags"] = get_flags()
	if(!islist)
		data["snowflake"] = get_snowflake()
	return data

/datum/trigg_variables/ui_static_data(mob/user)
	message_admins("UI static data update!")

	staticdata["vars"] = get_vars()
	staticdata["objectinfo"] = list(
		"name"  = D,
		"ref"   = REF(D),
		"type"  = objtype,
		"class" = C.vv_get_class(D, D),
		"title" = VV_TITLE(D)||"unnamed... for some reason. shit."
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
		var/refid = REF(D)
		.= list(
			"---",
			"Add Item" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_ADD),
			"Remove Nulls" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_ERASE_NULLS),
			"Remove Dupes" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_ERASE_DUPES),
			"Set len" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_SET_LENGTH),
			"Shuffle" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_SHUFFLE),
			"Show VV To Player" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_EXPOSE),
			"---"
			)
		for(var/i in 1 to length(.))
			var/name = .[i]
			var/link = .[name]
			.[i] = "<option value[link? "='[link]'":""]>[name]</option>"
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
	if(UI)
		message_admins("Found ui.. Closing it..")
	qdel(UI)
	qdel(src)
	if(UI)
		message_admins("Uh... I think I'm still alive. What.")

/datum/trigg_variables/ui_act(action, params)
	if(..())
		return

	message_admins("UI act! Action: '[action]' | Params: '[english_list(params)]'")
	if(!C)
		message_admins("Erm what client is ded")
		return

	if(view_var_Topic2(action, params))
		return TRUE //quick reminder for anyone code diving: returning TRUE makes the UI update.

	//CRASH("hm")
	/*
	switch(action)
		if("refresh")
			update_static_data(usr)
			return TRUE //quick reminder for anyone code diving: returning TRUE makes the UI update.

		if("view")
			var/target = params["target"]
			message_admins("Boi ok. What is target? '[target]'")
			C.trigg_VV(locate(target))
			return

		if("edit")
			if(!check_rights(NONE))
				return

			var/datum/D = locate(params["targetdatum"])
			if(!istype(D, /datum))
				to_chat(usr, "This can only be used on datums.")
				return

			if(!C.modify_variables(D, params["targetvar"], TRUE))
				//staticdata["vars"]["name"] = "FUCK FUCK FUCK"
				//UI.push_data(staticdata)
				return TRUE

		else
			message_admins("Hm.. Looks like an unhandled action has been passed to ui_act: Action: '[action]' | Params: '[english_list(params)]'")
			return
	*/

#undef VV_TITLE


