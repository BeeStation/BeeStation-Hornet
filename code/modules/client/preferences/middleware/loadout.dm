/datum/preference_middleware/loadout
	action_delegations = list(
		"purchase_gear" = PROC_REF(purchase_gear),
		"equip_gear" = PROC_REF(equip_gear),
	)

/datum/preference_middleware/loadout/get_ui_data(mob/user)
	var/list/data = list()
	data["equipped_gear"] = preferences.equipped_gear
	data["purchased_gear"] = preferences.purchased_gear
	data["metacurrency_balance"] = preferences.parent.get_metabalance()
	data["is_donator"] = IS_PATRON(user.ckey) || (user in GLOB.admins)
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
			gear_entry["allowed_roles"] = G.allowed_roles
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
	if(TG.id in preferences.equipped_gear)
		to_chat(user, "<span class='warning'>You already own \the [TG.display_name]!</span>")
		return TRUE
	if(TG.sort_category == "Donator")
		if(user.client && CONFIG_GET(flag/donator_items) && alert(user.client, "This item is only accessible to our patrons. Would you like to subscribe?", "Patron Locked", "Yes", "No") == "Yes")
			user.client.donate()
		return

	if(TG.cost < user.client.get_metabalance_db())
		preferences.purchased_gear += TG.id
		TG.purchase(user.client)
		user.client.inc_metabalance((TG.cost * -1), TRUE, "Purchased [TG.display_name].")
		preferences.save_preferences()
		return TRUE
	else
		to_chat(user, "<span class='warning'>You don't have enough [CONFIG_GET(string/metacurrency_name)]s to purchase \the [TG.display_name]!</span>")

/datum/preference_middleware/loadout/proc/equip_gear(list/params, mob/user)
	var/datum/gear/TG = GLOB.gear_datums[params["id"]]
	if(!istype(TG))
		return
	if(TG.id in preferences.equipped_gear)
		preferences.equipped_gear -= TG.id
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
				return TRUE
			else
				to_chat(user, "<span class='warning'>Can't equip [TG.display_name]. It conflicts with an already-equipped item.</span>")
		else
			log_href_exploit(user, "Attempting to equip [TG.type] when they do not own it.")
			return TRUE
	preferences.save_preferences()
