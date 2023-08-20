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
		to_chat(user, "<span class='warning'>You already own \the [TG.display_name]!</span>")
		return TRUE
	if(TG.sort_category == "Donator")
		if(user.client && CONFIG_GET(flag/donator_items) && alert(user.client, "This item is only accessible to our patrons. Would you like to subscribe?", "Patron Locked", "Yes", "No") == "Yes")
			user.client.donate()
		return

	if(TG.cost <= user.client.get_metabalance_db())
		preferences.purchased_gear += TG.id
		TG.purchase(user.client)
		user.client.inc_metabalance((TG.cost * -1), TRUE, "Purchased [TG.display_name].")
		preferences.mark_undatumized_dirty_player()
		return TRUE
	else
		to_chat(user, "<span class='warning'>You don't have enough [CONFIG_GET(string/metacurrency_name)]s to purchase \the [TG.display_name]!</span>")

/datum/preference_middleware/loadout/proc/equip_gear(list/params, mob/user)
	var/datum/gear/new_gear = GLOB.gear_datums[params["id"]]
	if(!istype(new_gear))
		return
	if(new_gear.id in preferences.equipped_gear)
		preferences.equipped_gear -= new_gear.id
		preferences.character_preview_view?.update_body()
		preferences.mark_undatumized_dirty_character()
		return TRUE
	else
		var/list/type_blacklist = list()
		var/list/slot_blacklist = list()
		for(var/gear_id in preferences.equipped_gear)
			var/datum/gear/other_gear = GLOB.gear_datums[gear_id]
			if(istype(other_gear))
				// Don't add to blacklist if this has different requirements (i.e department-specific coats)
				var/list/n_roles = new_gear.allowed_roles
				var/list/o_roles = other_gear.allowed_roles
				var/list/n_specs = new_gear.species_whitelist
				var/list/o_specs = other_gear.species_whitelist
				if((length(n_roles) && length(o_roles) && n_roles ~! o_roles) || (length(n_specs) && length(o_specs) && n_specs ~! o_specs))
					continue
				if(!(other_gear.subtype_path in type_blacklist))
					type_blacklist += other_gear.subtype_path
				if(!(other_gear.slot in slot_blacklist))
					slot_blacklist += other_gear.slot
		if((new_gear.id in preferences.purchased_gear))
			if(!(new_gear.subtype_path in type_blacklist) || !(new_gear.slot in slot_blacklist))
				preferences.equipped_gear += new_gear.id
				preferences.character_preview_view?.update_body()
				preferences.mark_undatumized_dirty_character()
				return TRUE
			else
				to_chat(user, "<span class='warning'>Can't equip [new_gear.display_name]. It conflicts with an already-equipped item.</span>")
		else
			log_href_exploit(user, "Attempting to equip [new_gear.type] when they do not own it.")
			return TRUE
