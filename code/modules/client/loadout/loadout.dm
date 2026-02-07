
/datum/loadout
	/// The ckey of the user that owns this loadout datum
	var/ckey
	/// If we failed to execute the query that loads our gear from the database, then this will be true
	var/loading_failed = FALSE
	/// List of gear purchased by the user
	var/list/purchased_gear = list()
	/// List of gear equipped by the user
	var/list/equipped_gear = list()

/datum/loadout/New(ckey)
	. = ..()
	src.ckey = ckey

/datum/loadout/proc/load_from_database()
	var/static/list/unknown_gear_items
	// Grab the gear info for this user
	var/datum/db_query/load_user_gear = SSdbcore.NewQuery(
		"SELECT gear_path, equipped, purchased_amount FROM [format_table_name("loadout_gear")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)

	// Query execution failure, no gear loaded
	if(!load_user_gear.Execute())
		qdel(load_user_gear)
		loading_failed = TRUE
		return

	// === HANDLE FREE ITEMS HERE ===
	// Unlock donator items first
	unlock_donator_items()

	// === Handle purchased items ===
	// Used up slots
	var/list/used_slots = list()
	// Now row for this user
	while (load_user_gear.NextRow())
		var/gear = load_user_gear.item[1]
		var/equipped = text2num(load_user_gear.item[2])
		var/purchased_amount = text2num(load_user_gear.item[3])
		// Locate the ID of the gear
		var/datum/gear/located_gear = GLOB.gear_datums[gear]
		if (!located_gear)
			// We already know about it
			if (LAZYFIND(unknown_gear_items, gear))
				continue
			LAZYADD(unknown_gear_items, gear)
			log_sql("Loadout: Could not find /datum/gear with the ID [gear], user will not be granted this item.")
			continue
		// Recognise the purchased item
		var/datum/user_gear/user_gear = new(located_gear, equipped, purchased_amount)
		// For donator items, we may have items equipped which we haven't purchased
		// These do not count as purchased, unless they were unlocked by unlock_donator_items
		if (purchased_amount > 0)
			purchased_gear[located_gear.id] = user_gear
		// If we have not purchased this gear, we ignore it
		// We maintain the equip status in the database, so that if we re-unlock the item, then
		// it will maintain the previously equipped status.
		if (!purchased_gear[located_gear.id])
			continue
		// Handle equipping
		if (equipped && (!located_gear.slot || !used_slots["[located_gear.slot]"]))
			equipped_gear[located_gear.id] = user_gear
			if (located_gear.slot)
				used_slots["[located_gear.slot]"] = TRUE

	// Remove any donator items that we no longer own
	remove_donator_items()
	// Cleanup the query
	qdel(load_user_gear)
	// Load the character slot count
	var/datum/preferences/prefs = GLOB.preferences_datums[ckey]
	prefs.compute_save_slot_count(src)

/// Returns true if the user has equipped the specified gear datum.
/datum/loadout/proc/is_equipped(datum/gear/gear)
	if (ispath(gear))
		gear = GLOB.gear_datums[gear::id || "[gear]"]
	if (loading_failed)
		return FALSE
	if (!equipped_gear[gear.id])
		return FALSE
	return TRUE

/// Returns true if we have purchased the specified gear datum.
/datum/loadout/proc/is_purchased(datum/gear/gear)
	if (ispath(gear))
		gear = GLOB.gear_datums[gear::id || "[gear]"]
	if (loading_failed)
		return FALSE
	if ((gear.gear_flags & GEAR_DONATOR) && (IS_PATRON(ckey) || is_admin(ckey)))
		return TRUE
	if (!purchased_gear[gear.id])
		return FALSE
	return TRUE

/// Returns the number of times that we have purchased the specified gear datum.
/datum/loadout/proc/get_purchased_count(datum/gear/gear)
	if (ispath(gear))
		gear = GLOB.gear_datums[gear::id || "[gear]"]
	if (loading_failed)
		return 0
	var/datum/user_gear/user_gear = purchased_gear[gear.id]
	if (!user_gear)
		return 0
	return user_gear.purchased_amount

/// Handles adding and removing donator items from clients
/datum/loadout/proc/unlock_donator_items()
	// Donator items are only accesibile by servers with a patreon
	if(!CONFIG_GET(flag/donator_items))
		return
	if(!IS_PATRON(ckey) && !is_admin(ckey))
		return
	for(var/gear_id in GLOB.gear_datums)
		var/datum/gear/AG = GLOB.gear_datums[gear_id]
		if(AG.id in purchased_gear)
			continue
		if (!(AG.gear_flags & GEAR_DONATOR))
			continue
		var/datum/user_gear/user_gear = new(AG, FALSE, 0)
		purchased_gear[AG.id] = user_gear

/datum/loadout/proc/remove_donator_items()
	// Donator items are only accesibile by servers with a patreon
	if(!CONFIG_GET(flag/donator_items))
		return
	if(IS_PATRON(ckey) || is_admin(ckey))
		return
	for (var/gear_id in equipped_gear)
		var/datum/user_gear/user_gear = equipped_gear[gear_id]
		if (user_gear.gear.gear_flags & GEAR_DONATOR)
			equipped_gear -= gear_id

/datum/user_gear
	var/datum/gear/gear
	var/equipped = FALSE
	var/purchased_amount = 0

/datum/user_gear/New(gear, equipped, amount)
	. = ..()
	src.gear = gear
	src.equipped = equipped
	src.purchased_amount = amount
