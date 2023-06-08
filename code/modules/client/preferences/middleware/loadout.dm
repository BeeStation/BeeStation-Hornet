/datum/preference_middleware/loadout
	action_delegations = list()

/datum/preference_middleware/loadout/get_ui_data(mob/user)
	var/list/data = list()
	data["equipped_gear"] = preferences.equipped_gear
	data["purchased_gear"] = preferences.purchased_gear
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
	return data
