SUBSYSTEM_DEF(supply)
	name = "Supply"
	//Get a new stock update every 2 minutes
	wait = 2 MINUTES
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME

	/// Legacy supply_packs list — kept for backwards compatibility with station goals etc.
	/// Keyed by type path. Only contains legacy /datum/supply_pack subtypes (if any remain).
	var/list/supply_packs = list()

	/// All orderable cargo items, keyed by type path
	var/list/cargo_items = list()
	/// All orderable cargo crates (packs), keyed by type path
	var/list/cargo_crates = list()
	/// Combined catalogue of everything orderable, keyed by type path.
	/// Values are assoc lists with a "type" key ("item" or "crate") and a "datum" key.
	var/list/catalogue = list()

	var/list/shoppinglist = list()
	var/list/requestlist = list()
	var/list/orderhistory = list()
	var/ordernum = 1					//order number given to next order

/datum/controller/subsystem/supply/Initialize()
	ordernum = rand(1, 9000)

	// --- Initialize legacy supply packs (backwards compat) ---
	for(var/pack in subtypesof(/datum/supply_pack))
		var/datum/supply_pack/P = new pack()
		if(!P.contains)
			continue
		supply_packs[P.type] = P

	// --- Initialize cargo items ---
	for(var/item_type in subtypesof(/datum/cargo_item))
		var/datum/cargo_item/item = new item_type()
		if(!item.item_path)
			continue
		cargo_items[item_type] = item
		catalogue[item_type] = list("type" = "item", "datum" = item)

	// --- Initialize cargo crates ---
	for(var/crate_type in subtypesof(/datum/cargo_crate))
		var/datum/cargo_crate/crate = new crate_type()
		if(!crate.contains)
			continue
		cargo_crates[crate_type] = crate
		catalogue[crate_type] = list("type" = "crate", "datum" = crate)

	return SS_INIT_SUCCESS

/datum/controller/subsystem/supply/fire()
	// Restock cargo items
	var/total_restock_required = 0
	var/list/restock_list = list()

	for(var/type in cargo_items)
		var/datum/cargo_item/item = cargo_items[type]
		if(item.current_supply < item.max_supply)
			var/deficit = item.max_supply - item.current_supply
			total_restock_required += deficit
			restock_list[item] = deficit

	// Restock cargo crates
	for(var/type in cargo_crates)
		var/datum/cargo_crate/crate = cargo_crates[type]
		if(crate.current_supply < crate.max_supply)
			var/deficit = crate.max_supply - crate.current_supply
			total_restock_required += deficit
			restock_list[crate] = deficit

	// Restock legacy supply packs
	for(var/type in supply_packs)
		var/datum/supply_pack/pack = supply_packs[type]
		if(pack.current_supply < pack.max_supply)
			var/deficit = pack.max_supply - pack.current_supply
			total_restock_required += deficit
			restock_list[pack] = deficit

	// Determine how much restocking to do this tick
	var/lower = sqrt(total_restock_required)
	var/upper = lower + total_restock_required / 10
	var/refill_amount = min(rand(lower, upper), total_restock_required)

	// Perform restocks
	while(refill_amount > 0 && length(restock_list))
		refill_amount--
		var/selected = pick_weight(restock_list)
		if(istype(selected, /datum/cargo_item))
			var/datum/cargo_item/item = selected
			item.current_supply = min(item.current_supply + 1, item.max_supply)
		else if(istype(selected, /datum/cargo_crate))
			var/datum/cargo_crate/crate = selected
			crate.current_supply = min(crate.current_supply + 1, crate.max_supply)
		else if(istype(selected, /datum/supply_pack))
			var/datum/supply_pack/pack = selected
			pack.current_supply = min(pack.current_supply + 1, pack.max_supply)
		restock_list -= selected
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_RESUPPLY)

/datum/controller/subsystem/supply/Recover()
	ordernum = SSsupply.ordernum
	if(istype(SSsupply.shoppinglist))
		shoppinglist = SSsupply.shoppinglist
	if(istype(SSsupply.requestlist))
		requestlist = SSsupply.requestlist
	if(istype(SSsupply.orderhistory))
		orderhistory = SSsupply.orderhistory

/// Helper: look up any orderable product by type path.
/// Checks catalogue (cargo_items + cargo_crates) first, falls back to legacy supply_packs.
/// Returns a list("type", "datum") or null.
/datum/controller/subsystem/supply/proc/get_product(product_type)
	if(catalogue[product_type])
		return catalogue[product_type]
	if(supply_packs[product_type])
		return list("type" = "legacy", "datum" = supply_packs[product_type])
	return null
