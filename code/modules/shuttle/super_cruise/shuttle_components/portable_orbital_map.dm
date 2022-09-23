/obj/item/navigation_map
	name = "holo-navigational map"
	desc = "A holographic tablet map that shows you information about the space around you."
	icon = 'icons/obj/supercruise/supercruise_items.dmi'
	icon_state = "holomap"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NOBLUDGEON

/obj/item/navigation_map/ui_state(mob/user)
	return GLOB.default_state

/obj/item/navigation_map/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OrbitalMap")
		ui.open()
	SSorbits.open_orbital_maps |= ui
	ui.set_autoupdate(FALSE)

/obj/item/navigation_map/ui_close(mob/user, datum/tgui/tgui)
	SSorbits.open_orbital_maps -= tgui

/obj/item/navigation_map/ui_data(mob/user)
	//Get out current location
	var/turf/T = get_turf(user)

	var/shuttleId
	var/datum/orbital_object/map_reference_object
	var/datum/orbital_object/shuttle/shuttleObject

	//Check area
	var/area/shuttle/shuttle_area = T.loc
	if(istype(shuttle_area))
		shuttleId = shuttle_area.mobile_port.id
		map_reference_object = SSorbits.assoc_shuttles[shuttleId]
		shuttleObject = map_reference_object
	//Get the z level
	if(!map_reference_object)
		map_reference_object = SSorbits.assoc_z_levels["[T.z]"]

	var/orbital_map_index = map_reference_object?.orbital_map_index

	//Fetch data
	var/user_ref = "[REF(user)]"
	var/datum/shuttle_data/shuttle_data = shuttleId && SSorbits.get_shuttle_data(shuttleId)

	//Get the base map data
	var/list/data = SSorbits.get_orbital_map_base_data(
		SSorbits.orbital_maps[orbital_map_index],
		user_ref,
		FALSE,
		map_reference_object,
		shuttle_data
	)

	data["shuttleName"] = map_reference_object?.name

	//Send shuttle data
	if(!SSshuttle.getShuttle(shuttleId) || !shuttleObject)
		data["linkedToShuttle"] = FALSE
		return data

	//Get shuttle data object
	if(length(shuttle_data.registered_engines))
		data["display_fuel"] = TRUE
		data["fuel"] = shuttle_data.get_fuel()

	//Display stats
	data["display_stats"] = list(
		"Shield Integrity" = "[shuttle_data.shield_health]",
		"Shuttle Mass" = "[shuttle_data.mass] Tons",
		"Engine Force" = "[shuttle_data.thrust] kN",
		"Supercruise Acceleration" = "[shuttle_data.get_thrust_force()] bknt^-2",
		"Fuel Consumption Rate" = "[shuttle_data.fuel_consumption] moles/s"
	)

	//Interdicted shuttles
	data["interdictedShuttles"] = list()
	if(SSorbits.interdicted_shuttles[shuttleId] > world.time)
		var/obj/docking_port/our_port = SSshuttle.getShuttle(shuttleId)
		data["interdictionTime"] = SSorbits.interdicted_shuttles[shuttleId] - world.time
		for(var/interdicted_id in SSorbits.interdicted_shuttles)
			var/timer = SSorbits.interdicted_shuttles[interdicted_id]
			if(timer < world.time)
				continue
			var/obj/docking_port/port = SSshuttle.getShuttle(interdicted_id)
			if(port && port.get_virtual_z_level() == our_port.get_virtual_z_level())
				data["interdictedShuttles"] += list(list(
					"shuttleName" = port.name,
					"x" = port.x - our_port.x,
					"y" = port.y - our_port.y,
				))
	else
		data["interdictionTime"] = 0

	data["canLaunch"] = FALSE
	if(QDELETED(shuttleObject))
		data["linkedToShuttle"] = FALSE
		return data
	data["linkedToShuttle"] = TRUE
	data["shuttleTarget"] = shuttleObject.shuttle_data.ai_pilot?.get_target_name()
	data["shuttleName"] = shuttleObject.name
	data["shuttleAngle"] = shuttleObject.angle
	data["shuttleThrust"] = shuttleObject.thrust
	data["autopilot_enabled"] = shuttleObject.shuttle_data.ai_pilot?.is_active()
	data["shuttleVelX"] = shuttleObject.velocity.GetX()
	data["shuttleVelY"] = shuttleObject.velocity.GetY()
	//Docking data
	data["canDock"] = FALSE
	data["isDocking"] = FALSE
	data["shuttleTargetX"] = shuttleObject.shuttleTargetPos?.GetX()
	data["shuttleTargetY"] = shuttleObject.shuttleTargetPos?.GetY()
	return data
