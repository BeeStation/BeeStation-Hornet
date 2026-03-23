/// A preview of the mech for the UI
/atom/movable/screen/mech_view
	name = "mechview"
	del_on_map_removal = FALSE
	layer = OBJ_LAYER
	plane = GAME_PLANE

	/// The body that is displayed
	var/obj/vehicle/sealed/mecha/owner
	///list of plane masters to apply to owners
	var/list/plane_masters = list()

/atom/movable/screen/mech_view/Initialize(mapload, obj/vehicle/sealed/mecha/newowner)
	. = ..()
	owner = newowner
	assigned_map = "mech_view_[REF(owner)]"
	set_position(1, 1)
	for(var/plane_master_type in subtypesof(/atom/movable/screen/plane_master) - /atom/movable/screen/plane_master/blackness)
		var/atom/movable/screen/plane_master/plane_master = new plane_master_type()
		plane_master.screen_loc = "[assigned_map]:CENTER"
		plane_masters += plane_master

/atom/movable/screen/mech_view/Destroy()
	QDEL_LIST(plane_masters)
	owner = null
	return ..()

/obj/vehicle/sealed/mecha/ui_close(mob/user)
	. = ..()
	user.client?.screen -= ui_view.plane_masters
	user.client?.clear_map(ui_view.assigned_map)

/obj/vehicle/sealed/mecha/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Mecha", name)
		ui.open()
		ui.set_autoupdate(TRUE)
		user.client?.screen |= ui_view.plane_masters
		user.client?.register_map_obj(ui_view)

/obj/vehicle/sealed/mecha/ui_status(mob/user)
	if(contains(user))
		return UI_INTERACTIVE
	return min(
		ui_status_user_is_abled(user, src),
		ui_status_user_has_free_hands(user, src),
		ui_status_user_is_advanced_tool_user(user),
		ui_status_only_living(user),
		max(
			ui_status_user_is_adjacent(user, src),
			ui_status_silicon_has_access(user, src),
		)
	)

/obj/vehicle/sealed/mecha/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/mecha_equipment),
	)

/obj/vehicle/sealed/mecha/ui_static_data(mob/user)
	var/list/data = list()
	data["ui_theme"] = ui_theme
	//same thresholds as in air alarm
	data["cabin_pressure_warning_min"]  = WARNING_LOW_PRESSURE
	data["cabin_pressure_hazard_min"]  = HAZARD_LOW_PRESSURE
	data["cabin_pressure_warning_max"]  = WARNING_HIGH_PRESSURE
	data["cabin_pressure_hazard_max"]  = HAZARD_HIGH_PRESSURE
	data["cabin_temp_warning_min"]  = BODYTEMP_COLD_WARNING_1 + 10 - T0C
	data["cabin_temp_hazard_min"]  = BODYTEMP_COLD_WARNING_1 - T0C
	data["cabin_temp_warning_max"]  = BODYTEMP_HEAT_WARNING_1 - 27 - T0C
	data["cabin_temp_hazard_max"]  = BODYTEMP_HEAT_WARNING_1 - T0C
	data["one_atmosphere"]  = ONE_ATMOSPHERE

	data["mineral_material_amount"] = MINERAL_MATERIAL_AMOUNT
	//map of relevant flags to check tgui side, not every flag needs to be here
	data["mechflag_keys"] = list(
		"ID_LOCK_ON" = ID_LOCK_ON,
		"LIGHTS_ON" = LIGHTS_ON,
		"HAS_LIGHTS" = HAS_LIGHTS,
	)
	data["internal_damage_keys"] = list(
		"MECHA_INT_FIRE" = MECHA_INT_FIRE,
		"MECHA_INT_TEMP_CONTROL" = MECHA_INT_TEMP_CONTROL,
		"MECHA_CABIN_AIR_BREACH" = MECHA_CABIN_AIR_BREACH,
		"MECHA_INT_CONTROL_LOST" = MECHA_INT_CONTROL_LOST,
		"MECHA_INT_SHORT_CIRCUIT" = MECHA_INT_SHORT_CIRCUIT,
	)

	var/list/regions = list()
	for(var/i in 1 to 7)
		var/list/accesses = list()
		for(var/access in get_region_accesses(i))
			if (get_access_desc(access))
				accesses += list(list(
					"desc" = replacetext(get_access_desc(access), "&nbsp", " "),
					"ref" = access,
				))

		regions += list(list(
			"name" = get_region_accesses_name(i),
			"regid" = i,
			"accesses" = accesses
		))

	data["regions"] = regions
	return data

/obj/vehicle/sealed/mecha/ui_data(mob/user)
	var/list/data = list()
	var/isoperator = (user in occupants) //maintenance mode outside of mech
	data["isoperator"] = isoperator
	data["cell"] = cell?.name
	data["scanning"] = scanmod?.name
	data["capacitor"] = capacitor?.name
	data["servo"] = servo?.name
	ui_view.appearance = appearance
	data["name"] = name
	data["integrity"] = atom_integrity
	data["integrity_max"] = max_integrity
	data["power_level"] = cell?.charge
	data["power_max"] = cell?.maxcharge
	data["mecha_flags"] = mecha_flags
	data["internal_damage"] = internal_damage

	data["can_use_overclock"] = can_use_overclock
	data["overclock_mode"] = overclock_mode
	data["overclock_temp_percentage"] = overclock_temp / overclock_temp_danger

	//data["dna_lock"] = dna_lock

	data["one_access"] = one_access
	data["accesses"] = accesses

	data["servo_rating"] = servo?.rating
	data["scanmod_rating"] = scanmod?.rating
	data["capacitor_rating"] = capacitor?.rating

	data["weapons_safety"] = weapons_safety
	data["enclosed"] = mecha_flags & IS_ENCLOSED
	data["cabin_sealed"] = cabin_sealed
	data["cabin_temp"] =  round(cabin_air.temperature - T0C)
	data["cabin_pressure"] = round(cabin_air.return_pressure())
	data["mech_view"] = ui_view.assigned_map
	data["modules"] = get_module_ui_data()
	data["selected_module_index"] = ui_selected_module_index
	return data

/obj/vehicle/sealed/mecha/proc/get_module_ui_data()
	var/list/data = list()
	var/module_index = 0
	for(var/category in max_equip_by_category)
		var/max_per_category = max_equip_by_category[category]
		for(var/i = 1 to max_per_category)
			var/equipment = equip_by_category[category]
			var/is_slot_free = islist(equipment) ? i > length(equipment) : isnull(equipment)
			if(is_slot_free)
				data += list(list(
					"slot" = category
				))
				if(ui_selected_module_index == module_index)
					ui_selected_module_index = null
			else
				var/obj/item/mecha_parts/mecha_equipment/module = islist(equipment) ? equipment[i] : equipment
				data += list(list(
					"slot" = category,
					"icon" = module.icon_state,
					"name" = module.name,
					"desc" = module.desc,
					"detachable" = module.detachable,
					"integrity" = (module.get_integrity()/module.max_integrity),
					"can_be_toggled" = module.can_be_toggled,
					"can_be_triggered" = module.can_be_triggered,
					"active" = module.active,
					"active_label" = module.active_label,
					"equip_cooldown" = module.equip_cooldown && DisplayTimeText(module.equip_cooldown),
					"energy_per_use" = module.energy_drain,
					"snowflake" = module.get_snowflake_data(),
					"ref" = REF(module),
				))
				if(isnull(ui_selected_module_index))
					ui_selected_module_index = module_index
			module_index++
	return data

/obj/vehicle/sealed/mecha/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("clear_all")
			accesses = list()
			one_access = 0
			update_access()
		if("grant_all")
			accesses = get_all_accesses()
			update_access()
		if("one_access")
			one_access = !one_access
			update_access()
		if("set")
			var/access = params["access"]
			if (!(access in accesses))
				accesses += access
			else
				accesses -= access
			update_access()
		if("grant_region")
			var/region = params["region"]
			if(isnull(region))
				return
			accesses |= get_region_accesses(region)
			update_access()
		if("deny_region")
			var/region = params["region"]
			if(isnull(region))
				return
			accesses -= get_region_accesses(region)
			update_access()
		if("select_module")
			ui_selected_module_index = text2num(params["index"])
			return TRUE
		if("changename")
			var/userinput = tgui_input_text(usr, "Choose a new exosuit name", "Rename exosuit", max_length = MAX_NAME_LEN, default = name)
			if(!userinput)
				return
			if(userinput == format_text(name)) //default mecha names may have improper span artefacts in their name, so we format the name
				to_chat(usr, span_notice("You rename [name] to... well, [userinput]."))
				return
			name = userinput
			//chassis_camera?.update_c_tag(src)
		if("toggle_safety")
			set_safety(usr)
			return
		/*
		if("dna_lock")
			var/mob/living/carbon/user = usr
			if(!istype(user) || !user.dna)
				to_chat(user, "[icon2html(src, occupants)][span_notice("You can't create a DNA lock with no DNA!.")]")
				return
			dna_lock = user.dna.unique_enzymes
			to_chat(user, "[icon2html(src, occupants)][span_notice("You feel a prick as the needle takes your DNA sample.")]")
		if("reset_dna")
			dna_lock = null
		*/
		if("toggle_cabin_seal")
			set_cabin_seal(usr, !cabin_sealed)
		if("toggle_id_lock")
			mecha_flags ^= ID_LOCK_ON
		if("toggle_lights")
			toggle_lights(user = usr)
		if("toggle_overclock")
			toggle_overclock()
			var/datum/action/act = locate(/datum/action/vehicle/sealed/mecha/mech_overclock) in usr.actions
			act.button_icon_state = "mech_overload_[overclock_mode ? "on" : "off"]"
			act.update_buttons()
		if("repair_int_damage")
			try_repair_int_damage(usr, params["flag"])
			return FALSE
		if("equip_act")
			var/obj/item/mecha_parts/mecha_equipment/gear = locate(params["ref"]) in flat_equipment
			return gear?.ui_act(params["gear_action"], params, ui, state)
	return TRUE
