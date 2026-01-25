/datum/preference_middleware/loadout
	action_delegations = list(
		"purchase_gear" = PROC_REF(purchase_gear),
		"equip_gear" = PROC_REF(equip_gear),
	)

/datum/preference_middleware/loadout/get_ui_data(mob/user)
	var/list/data = list()
	// Gear that we have equipped
	var/list/equipped_gear = list()
	for (var/item_key in preferences.parent.player_details?.loadout?.equipped_gear)
		equipped_gear += item_key
	data["equipped_gear"] = equipped_gear
	// Gear that we have purchased
	var/list/purchased_gear = list()
	for (var/item_key in preferences.parent.player_details?.loadout?.purchased_gear)
		purchased_gear += item_key
	data["purchased_gear"] = purchased_gear
	// Gear that we can purchase
	var/list/purchasable_gear = list()
	for (var/item_key in GLOB.gear_datums)
		var/datum/gear/gear = GLOB.gear_datums[item_key]
		if (gear.can_purchase(preferences.parent, TRUE))
			purchasable_gear += item_key
	data["purchasable_gear"] = purchasable_gear
	// Other stuff
	data["metacurrency_balance"] = preferences.parent.get_metabalance_unreliable()
	data["is_donator"] = (IS_PATRON(preferences.parent.ckey) || is_admin(preferences.parent))
	return data

/datum/preference_middleware/loadout/get_constant_data()
	var/list/data = list()
	var/list/categories = list()
	for(var/category_id in GLOB.loadout_categories)
		var/datum/loadout_category/LC = GLOB.loadout_categories[category_id]
		var/list/category = list()
		category["name"] = LC.category
		var/list/gear = list()
		for(var/gear_id in LC.gear)
			var/datum/gear/G = LC.gear[gear_id]
			var/list/gear_entry = list()
			// Don't show donator items if the server has them off
			if((G.gear_flags & GEAR_DONATOR) && !CONFIG_GET(flag/donator_items))
				continue
			gear_entry["id"] = G.id
			gear_entry["display_name"] = G.display_name
			gear_entry["skirt_display_name"] = G.skirt_display_name
			gear_entry["cost"] = G.cost
			gear_entry["description"] = G.description
			gear_entry["skirt_description"] = G.skirt_description
			gear_entry["allowed_roles"] = G.allowed_roles
			gear_entry["is_equippable"] = G.is_equippable
			gear += list(gear_entry)
		if (!length(gear))
			continue
		category["gear"] = gear
		categories += list(category)
	data["categories"] = categories
	data["metacurrency_name"] = CONFIG_GET(string/metacurrency_name)
	return data

/datum/preference_middleware/loadout/proc/purchase_gear(list/params, mob/user)
	var/datum/gear/TG = GLOB.gear_datums[params["id"]]
	if(!istype(TG))
		return FALSE
	if (!user.client)
		return FALSE
	if (!TG.can_purchase(user.client, FALSE))
		return FALSE
	if (!TG.do_purchase(user.client))
		to_chat(user, span_warning("Purchase failed, you have not been charged."))
		return FALSE
	return TRUE

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
	if (loadout.is_equipped(TG))
		loadout.unequip(TG)
	else
		loadout.equip(TG)
	preferences.character_preview_view?.update_body()
	return TRUE
