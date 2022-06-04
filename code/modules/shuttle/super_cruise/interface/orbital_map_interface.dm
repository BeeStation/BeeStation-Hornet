/datum/orbital_map_tgui
	var/list/assoc_data = list()
	var/default_orbital_map = PRIMARY_ORBITAL_MAP

/datum/orbital_map_tgui/ui_state(mob/user)
	return GLOB.observer_state

/datum/orbital_map_tgui/Destroy(force, ...)
	. = ..()
	SSorbits.open_orbital_maps -= SStgui.get_all_open_uis(src)

/datum/orbital_map_tgui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		//Store user specific data.
		assoc_data["[REF(user)]"] = list(
			"open_map" = default_orbital_map,
		)
		ui = new(user, src, "OrbitalMap")
		ui.open()
	//Do not auto update, handled by orbits subsystem.
	SSorbits.open_orbital_maps |= ui
	ui.set_autoupdate(FALSE)

/datum/orbital_map_tgui/ui_close(mob/user, datum/tgui/tgui)
	SSorbits.open_orbital_maps -= tgui
	//Clear the data from the user, we don't need it anymore.
	assoc_data -= "[REF(user)]"

/datum/orbital_map_tgui/ui_data(mob/user)
	//Fetch the user data
	var/open_orbital_map = default_orbital_map
	var/user_ref = "[REF(user)]"
	if(assoc_data[user_ref])
		open_orbital_map = assoc_data[user_ref]["open_map"]
	else
		log_runtime("Orbital map updated UI without reference to [user] in the assoc data list.")
		assoc_data[user_ref] = list(
			"open_map" = default_orbital_map,
		)

	//Show the correct map to the user
	var/datum/orbital_map/showing_map = SSorbits.orbital_maps[open_orbital_map]

	//Return default orbital map data
	return SSorbits.get_orbital_map_base_data(showing_map, user_ref, TRUE, null)
