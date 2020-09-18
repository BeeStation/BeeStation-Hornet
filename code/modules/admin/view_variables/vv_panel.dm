/client/proc/debug_variables2(datum/D in world)
	set category = "Debug"
	set name = "New View Variables"

	if(!usr.client || !usr.client.holder) //This is usr because admins can call the proc on other clients, even if they're not admins, to show them VVs.
		to_chat(usr, "<span class='danger'>You need to be an administrator to access this.</span>")
		return

	var/datum/vv_panel/UI = new(D)
	UI.ui_interact(src.mob)


#define VV_TITLE(D) ("[D] [REF(D)] = [objtype]")

/datum/vv_panel
	var/datum/D
	var/islist
	var/objtype

	//We'll cache these to avoid rescanning everything on every single UI update
	var/list/data = list()
	var/list/staticdata = list()

/datum/vv_panel/New(target)
	D = target

	islist = islist(D)
	objtype = islist? /list : D.type
	//Or, in English; '/list' if islist, else it's a datum so we can just 'D.type'

	if(!islist && !istype(D))
		//CRASH("Uhhhh what the fuck did you just give me?")
		return

/datum/vv_panel/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.VV_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ViewVariables", "[REF(D)] ([objtype])", 700, 700, master_ui, state)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/vv_panel/ui_data(mob/user)
	data["flags"] = get_flags(user.client)
	if(!islist) //no snowflakes for lists
		data["snowflake"] = get_snowflake()
	return data

/datum/vv_panel/ui_static_data(mob/user)
	if(!staticdata["vars"].len)
		staticdata["vars"] = get_vars(user.client)
	staticdata["objectinfo"] = list(
		"name"  = islist ? "/list" : D,
		"ref"   = REF(D),
		"type"  = islist ? "" : objtype,
		"class" = user.client.vv_get_class(D, D),
		"title" = VV_TITLE(D),
		)
	staticdata["dropdown"] = get_dropdown()
	return staticdata

/datum/vv_panel/proc/get_snowflake()
	. = list()
	. += D.vv_get_snowflake()

/datum/vv_panel/proc/get_flags(client/C)
	.= list()
	if(islist)
		return
	if(C.holder && C.holder.marked_datum && C.holder.marked_datum == D)
		. += "Marked Object"
	if(D.datum_flags & DF_VAR_EDITED)
		. += "Var Edited"
	if(D.gc_destroyed)
		. += "Deleted"

/datum/vv_panel/proc/get_dropdown()
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
/datum/vv_panel/proc/get_vars(client/C)
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

/datum/vv_panel/proc/refresh_vars(client/C)
	staticdata["vars"] = get_vars(C)

/datum/vv_panel/proc/update_var(name, client/C)
	var/newentry = list()
	if(D.can_vv_get(name))
		newentry = D.vv_get_var2(name)
		newentry += list("type" = C.vv_get_class(newentry["name"], newentry["value"]))

	for(var/list/entry in staticdata["vars"])
		if(entry["name"] == name)
			entry += newentry //yes, += to overwrite it. I love byond.
			return TRUE

/datum/vv_panel/ui_close(mob/user)
	return

/datum/vv_panel/ui_act(action, params, datum/tgui/ui)
	if(..())
		return


	if(view_var_Topic2(action, params, ui.user.client))
		update_static_data(ui.user)
		return TRUE //quick reminder for anyone code diving: returning TRUE makes the UI update.

#undef VV_TITLE


