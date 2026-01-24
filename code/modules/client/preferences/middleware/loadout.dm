/datum/preference_middleware/loadout
	action_delegations = list(
		"purchase_gear" = PROC_REF(purchase_gear),
		"equip_gear" = PROC_REF(equip_gear),
	)

/datum/preference_middleware/loadout/get_ui_data(mob/user)
	var/list/data = list()
	data["equipped_gear"] = preferences.parent.player_details?.loadout?.equipped_gear || list()
	data["purchased_gear"] = preferences.parent.player_details?.loadout?.purchased_gear || list()
	data["metacurrency_balance"] = preferences.parent.get_metabalance_unreliable()
	data["is_donator"] = (IS_PATRON(preferences.parent.ckey) || is_admin(preferences.parent))
	return data

/datum/preference_middleware/loadout/get_constant_data()
	var/list/data = list()
	var/list/categories = list()
	for(var/category_id in GLOB.loadout_categories)
		var/datum/loadout_category/LC = GLOB.loadout_categories[category_id]
		if(LC.category == "Donator" && !CONFIG_GET(flag/donator_items)) // Don't show donator items if the server has them off
			continue
		var/list/category = list()
		category["name"] = LC.category
		var/list/gear = list()
		for(var/gear_id in LC.gear)
			var/datum/gear/G = LC.gear[gear_id]
			var/list/gear_entry = list()
			gear_entry["id"] = G.id
			gear_entry["display_name"] = G.display_name
			gear_entry["skirt_display_name"] = G.skirt_display_name
			gear_entry["donator"] = G.sort_category == "Donator"
			gear_entry["cost"] = G.cost
			gear_entry["description"] = G.description
			gear_entry["skirt_description"] = G.skirt_description
			gear_entry["allowed_roles"] = G.allowed_roles
			gear_entry["is_equippable"] = G.is_equippable
			gear_entry["can_purchase"] = preferences?.parent ? G.can_purchase(preferences.parent, TRUE) : FALSE
			gear += list(gear_entry)
		category["gear"] = gear
		categories += list(category)
	data["categories"] = categories
	data["metacurrency_name"] = CONFIG_GET(string/metacurrency_name)
	return data

/datum/preference_middleware/loadout/proc/purchase_gear(list/params, mob/user)
	var/datum/gear/TG = GLOB.gear_datums[params["id"]]
	if(!istype(TG))
		return
	if (!user.client)
		return
	if (!TG.can_purchase(user.client, FALSE))
		return
	TG.do_purchase(preferences, user.client)

/datum/preference_middleware/loadout/proc/equip_gear(list/params, mob/user)
	var/datum/gear/TG = GLOB.gear_datums[params["id"]]
	if(!istype(TG))
		return
	if (!user.client)
		return
	var/datum/loadout/loadout = user.client.player_details.loadout
	if (!loadout.is_purchased(TG))
		log_href_exploit(user, "Attempting to equip [TG.type] when they do not own it.")
		return
	if (loadout.is_equipped())
		loadout.unequip(TG)
	else
		loadout.equip(TG)
	preferences.character_preview_view?.update_body()
	return TRUE
