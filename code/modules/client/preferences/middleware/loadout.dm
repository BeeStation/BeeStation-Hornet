/datum/preference_middleware/loadout
	action_delegations = list(
		"purchase_gear" = PROC_REF(purchase_gear),
		"equip_gear" = PROC_REF(equip_gear),
	)

/datum/preference_middleware/loadout/get_ui_data(mob/user)
	var/list/data = list()
	data["equipped_gear"] = preferences.equipped_gear
	data["purchased_gear"] = preferences.purchased_gear
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
			gear_entry["multi_purchase"] = G.multi_purchase
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
	if(((TG.id in preferences.purchased_gear) || (TG.id in preferences.equipped_gear)) && !TG.multi_purchase)
		to_chat(user, span_warning("You already own \the [TG.display_name]!"))
		return TRUE
	if(TG.sort_category == "Donator")
		if(user.client && CONFIG_GET(flag/donator_items) && alert(user.client, "This item is only accessible to our patrons. Would you like to subscribe?", "Patron Locked", "Yes", "No") == "Yes")
			user.client.donate()
		return

	if(TG.cost <= user.client.get_metabalance_db())
		preferences.purchased_gear += TG.id
		TG.purchase(user.client)
		user.client.inc_metabalance((TG.cost * -1), TRUE, "Purchased [TG.display_name].")
		log_preferences("[preferences?.parent?.ckey]: Purchased loadout gear: [TG.id] ([TG.display_name])")
		preferences.mark_undatumized_dirty_player()
		return TRUE
	else
		to_chat(user, span_warning("You don't have enough [CONFIG_GET(string/metacurrency_name)]s to purchase \the [TG.display_name]!"))

/datum/preference_middleware/loadout/proc/equip_gear(list/params, mob/user)
	var/datum/gear/TG = GLOB.gear_datums[params["id"]]
	if(!istype(TG))
		return
	if(TG.id in preferences.equipped_gear)
		preferences.equipped_gear -= TG.id
		log_preferences("[preferences?.parent?.ckey]: Unequipped loadout gear: [TG.id] ([TG.display_name])")
		preferences.character_preview_view?.update_body()
		preferences.mark_undatumized_dirty_character()
		return TRUE
	else
		var/list/type_blacklist = list()
		var/list/slot_blacklist = list()
		for(var/gear_id in preferences.equipped_gear)
			var/datum/gear/G = GLOB.gear_datums[gear_id]
			if(istype(G))
				if(!(G.subtype_path in type_blacklist))
					type_blacklist += G.subtype_path
				if(!(G.slot in slot_blacklist))
					slot_blacklist += G.slot
		if((TG.id in preferences.purchased_gear))
			if(!(TG.subtype_path in type_blacklist) || !(TG.slot in slot_blacklist))
				preferences.equipped_gear += TG.id
				log_preferences("[preferences?.parent?.ckey]: Equipped loadout gear: [TG.id] ([TG.display_name])")
				preferences.character_preview_view?.update_body()
				preferences.mark_undatumized_dirty_character()
				return TRUE
			else
				to_chat(user, span_warning("Can't equip [TG.display_name]. It conflicts with an already-equipped item."))
		else
			log_href_exploit(user, "Attempting to equip [TG.type] when they do not own it.")
			return TRUE
