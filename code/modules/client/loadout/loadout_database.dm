
/// Equip the specified gear datum
/datum/loadout/proc/equip(datum/gear/gear)
	if (ispath(gear))
		gear = GLOB.gear_datums[gear::id || gear]
	if (loading_failed)
		return
	var/datum/user_gear/user_gear = purchased_gear[gear.id]

	// Not purchased
	if (!user_gear)
		return

	// Already equipped
	if (equipped_gear[gear.id])
		return

	// Unequip any gear that conflicts with this gear
	var/list/unequipped_gear = list()
	for (var/equipped_key in equipped_gear)
		var/datum/user_gear/equipped = equipped_gear[equipped_key]
		if (equipped.gear.slot == gear.slot)
			// To prevent SQL injection, use static values
			unequipped_gear += "'[equipped.gear::id || equipped.gear::type]'"
			equipped_gear -= equipped_key
			equipped.equipped = FALSE

	equipped_gear[gear.id] = user_gear
	user_gear.equipped = TRUE

	if (length(unequipped_gear))
		// Equip the item and unequip conflicting ones
		// If we don't have the item in the database, it is a free item, so we equip
		// it but keep the purchase count at 0.
		var/datum/db_query/load_user_gear = SSdbcore.NewQuery("CALL equip_gear(:ckey, :gear_path, [jointext(unequipped_gear, ", ")])",
			list("ckey" = ckey, "gear_path" = gear.id)
		)
		load_user_gear.warn_execute()
		qdel(load_user_gear)
	else
		// Equip the item
		// If we don't have the item in the database, it is a free item, so we equip
		// it but keep the purchase count at 0.
		var/datum/db_query/load_user_gear = SSdbcore.NewQuery(
			{"
INSERT INTO [format_table_name("loadout_gear")] (ckey, gear_path, equipped, purchased_amount)
VALUES (:ckey, :gear_path, 1, 0)
ON DUPLICATE KEY UPDATE
	equipped = 1
			"},
			list("ckey" = ckey, "gear_path" = gear.id)
		)
		load_user_gear.warn_execute()
		qdel(load_user_gear)

/// Unequip the specified gear datum
/datum/loadout/proc/unequip(datum/gear/gear)
	if (ispath(gear))
		gear = GLOB.gear_datums[gear::id || gear]
	if (loading_failed)
		return
	var/datum/user_gear/user_gear = purchased_gear[gear.id]

	// Not purchased
	if (!user_gear)
		return

	// Not equipped
	if (!equipped_gear[gear.id])
		return

	equipped_gear -= gear.id
	user_gear.equipped = FALSE

	// Save the information in the database
	var/datum/db_query/load_user_gear = SSdbcore.NewQuery(
		"UPDATE [format_table_name("loadout_gear")] SET equipped = 0 WHERE ckey = :ckey AND gear_path = :gear_path",
		list("ckey" = ckey, "gear_path" = gear.id)
	)
	load_user_gear.warn_execute()
	qdel(load_user_gear)

/client/verb/test()
	set name = "test"
	set category = "powerfulbacon"
	var/datum/gear/a = GLOB.gear_datums[GLOB.gear_datums[1]]
	player_details.loadout.purchase_for_cost_transaction(a, 1000000)

/// Purchase the item and update the gear database in a single transaction, returning FALSE
/// if the transaction failed.
/datum/loadout/proc/purchase_for_cost_transaction(datum/gear/gear, cost)
	var/datum/db_query/purchase_gear = SSdbcore.NewQuery("CALL purchase_gear(:ckey, :gear_path, :cost)",
		list(
			"ckey" = ckey,
			"gear_path" = gear.id,
			"cost" = cost
		)
	)
	if (!purchase_gear.warn_execute())
		qdel(purchase_gear)
		return FALSE
	if (!purchase_gear.NextRow())
		qdel(purchase_gear)
		return FALSE
	if (!purchase_gear.item[1])
		qdel(purchase_gear)
		return FALSE
	qdel(purchase_gear)
	// Update cached metabalance to keep it in sync
	var/client/connected_user = GLOB.directory[ckey]
	if (connected_user)
		connected_user.metabalance_cached -= cost
	// Update the purchased gear lists
	var/datum/user_gear/user_gear = purchased_gear[gear.id]
	if (user_gear)
		user_gear.purchased_amount ++
	else
		user_gear = new(gear, FALSE, 1)
		purchased_gear[gear.id] = user_gear
	return TRUE
