GLOBAL_LIST_EMPTY(loadout_categories)
GLOBAL_LIST_EMPTY(gear_datums)

/datum/loadout_category
	var/category = ""
	var/list/gear = list()

/datum/loadout_category/New(cat)
	category = cat
	..()

/proc/populate_gear_list()
	//create a list of gear datums to sort
	var/list/used_ids = list()
	for(var/geartype in subtypesof(/datum/gear))
		var/datum/gear/G = geartype

		var/use_name = initial(G.display_name)
		var/use_id = initial(G.id) || "[G::type]"
		var/use_category = initial(G.sort_category)

		if(G == initial(G.subtype_path))
			continue

		if(!use_name)
			WARNING("Loadout - Missing display name: [G]")
			continue
		if(use_id in used_ids)
			WARNING("Loadout - ID Already Exists: [G], with ID:[use_id], Conflicts with: [used_ids[use_id]]")
			continue
		if(!initial(G.cost))
			WARNING("Loadout - Missing cost: [G]")
			continue
		if(!initial(G.path) && use_category != "OOC") //OOC category does not contain actual items
			WARNING("Loadout - Missing path definition: [G]")
			continue

		if(!GLOB.loadout_categories[use_category])
			GLOB.loadout_categories[use_category] = new /datum/loadout_category(use_category)
		used_ids[use_id] = G
		var/datum/loadout_category/LC = GLOB.loadout_categories[use_category]
		GLOB.gear_datums[use_id] = new geartype
		LC.gear[use_id] = GLOB.gear_datums[use_id]

	GLOB.loadout_categories = sortAssoc(GLOB.loadout_categories)

/// Loadout gear datum.
/datum/gear
	/// Display name of the item
	var/display_name
	/// ID of the item, which MUST be unique. Defaults to the typepath, but can be changed
	/// for cases where the item's typepath was changed.
	/// DO NOT SET THIS unless you are re-pathing an existing item!
	var/id
	/// Description of this gear. If left blank will default to the description of the pathed item.
	var/description
	var/path               //Path to item.
	var/cost = INFINITY    //Number of metacoins
	var/slot               //Slot to equip to.
	var/list/allowed_roles //Roles that can spawn with this item.
	var/list/species_blacklist //Stop certain species from receiving this gear
	var/list/species_whitelist //Only allow certain species to receive this gear
	var/sort_category = "General"
	/// If the typepath exactly matches this subtype path, then the item will not be displayed
	/// in the browser, which is used to create abstract gear datums for categorisation.
	var/subtype_path = /datum/gear
	var/skirt_display_name
	var/skirt_path = null
	var/skirt_description
	/// If this gear is actually granting an item, and can be equipped.
	var/is_equippable = TRUE
	/// Determine behaviours of the gear
	var/gear_flags = NONE

/datum/gear/New()
	..()
	id = "[type]"
	if(!description)
		var/obj/O = path
		description = initial(O.desc)
	if(!isnull(skirt_path))
		var/obj/O = skirt_path
		skirt_description = initial(O.desc)

/// Returns true if we are allowed to purchase this item
/datum/gear/proc/can_purchase(client/user, silent)
	var/datum/loadout/loadout = user.player_details.loadout
	if (loadout.loading_failed)
		return FALSE
	if (gear_flags & GEAR_DONATOR)
		if (!silent)
			to_chat(user, span_warning("\The [display_name] is a donator item and is not purchasable."))
		return FALSE
	if (!(gear_flags & GEAR_MULTI_PURCHASE) && loadout.is_purchased(src))
		if (!silent)
			to_chat(user, span_warning("You already own \the [display_name]!"))
		return FALSE
	if (user.get_metabalance_async() < cost)
		if (!silent)
			to_chat(user, span_warning("You don't have enough [CONFIG_GET(string/metacurrency_name)]s to purchase \the [display_name]!"))
		return FALSE
	return TRUE

/datum/gear/proc/do_purchase(client/user)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/datum/loadout/loadout = user.player_details.loadout
	if (loadout.loading_failed)
		return FALSE
	if (loadout.purchase_for_cost_transaction(src, cost))
		var/purchase_count = loadout.get_purchased_count(src)
		purchase(user, purchase_count)
		update_purchased_effects(user, purchase_count)
		return TRUE
	return FALSE

/// Called every time the gear is purchased, with purchase_count being the number
/// of times that it has been purchased.
/datum/gear/proc/purchase(client/user, purchase_count)
	SHOULD_NOT_SLEEP(TRUE)
	PROTECTED_PROC(TRUE)
	return

/// Called whenever the gear is purchased, or when the user logs in with
/// the gear purchased. Can be called mutliple times per-round, but purchase_count
/// will never decrease from the previous value.
/datum/gear/proc/update_purchased_effects(client/user, purchase_count = 0)
	return

/datum/gear/proc/spawn_item(location, skirt_pref)
	var/item_path = path
	if(skirt_pref == PREF_SKIRT && !isnull(skirt_path))
		item_path = skirt_path
	return new item_path(location)

/datum/gear/vv_edit_var(var_name, var_value)
	// ID gets passed to the database directly, to prevent SQL injection
	// we disallow all edits to ID
	return FALSE
