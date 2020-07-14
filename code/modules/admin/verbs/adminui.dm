GLOBAL_DATUM_INIT(admin_ui, /datum/admin_ui_holder)

/datum/admin_ui_holder
	var/list/active_uis = list()

/datum/admin_ui_holder/New(admin_owner)
	init_components()

/datum/admin_ui_holder/proc/init_components()
	for(var/comp in subtypesof(/datum/admin_ui_component))
		var/datum/admin_ui_component/UI = new comp
		active_uis["[UI.unique_id]"] = UI

/datum/admin_ui_holder/proc/display_ui(name, mob/user)
	if(!active_uis[name])
		to_chat(user, "<font color='red'>Interface [name] not found!</font>")
		return
	active_uis[name].ui_interact(user)

/datum/admin_ui_component
	var/unique_id = "unset"
	var/default_ui_key = "admin"
	var/default_ui_name = "Undefined"
	var/window_name = "Undefined Window"
	var/width = 600
	var/height = 480
	var/auto_update = TRUE

/datum/admin_ui_component/ui_interact(mob/user, ui_key = "", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.admin_state)
	if(!ui_key)
		ui_key = default_ui_key
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		log_admin_private("[user.ckey] opened the [window_name].")
		ui = new(user, src, ui_key, default_ui_name, window_name, width, height, master_ui, state)
		ui.set_autoupdate(auto_update)
		ui.open()
