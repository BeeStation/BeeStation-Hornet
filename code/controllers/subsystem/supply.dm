SUBSYSTEM_DEF(supply)
	name = "Supply"
	//Get a new stock update every 2 minutes
	wait = 2 MINUTES
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME

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

	// --- Expand cargo lists into cargo items ---
	for(var/list_type in subtypesof(/datum/cargo_list))
		var/datum/cargo_list/CL = new list_type()
		if(!CL.entries || !length(CL.entries))
			qdel(CL)
			continue
		for(var/list/entry in CL.entries)
			var/path = entry["path"]
			if(!path)
				continue
			var/datum/cargo_item/item = new()
			item.item_path = path
			item.name = entry["name"]  // may be null — New() already auto-filled, so override only if provided
			item.cost = entry["cost"] || 400
			item.max_supply = entry["max_supply"] || 5
			item.small_item = ("small_item" in entry) ? entry["small_item"] : CL.small_item
			item.access = ("access" in entry) ? entry["access"] : CL.access
			item.access_budget = ("access_budget" in entry) ? entry["access_budget"] : CL.access_budget
			item.contraband = ("contraband" in entry) ? entry["contraband"] : CL.contraband
			item.hidden = ("hidden" in entry) ? entry["hidden"] : CL.hidden
			item.dangerous = ("dangerous" in entry) ? entry["dangerous"] : CL.dangerous
			item.DropPodOnly = ("DropPodOnly" in entry) ? entry["DropPodOnly"] : CL.DropPodOnly
			item.crate_type = ("crate_type" in entry) ? entry["crate_type"] : CL.crate_type
			item.can_secure = ("can_secure" in entry) ? entry["can_secure"] : CL.can_secure
			// Re-fill name/desc from item_path if entry didn't provide a name
			// (New() already ran, but we overwrote name above, so re-derive if null)
			if(!item.name && item.item_path)
				var/atom/A = item.item_path
				item.name = initial(A.name)
			if(!item.desc && item.item_path)
				var/atom/A = item.item_path
				item.desc = initial(A.desc)
			// Re-randomize supply since New() already did it but max_supply may have changed
			item.current_supply = rand(0, rand(1, item.max_supply))
			// Duplicate check — warn if this path is already in the catalogue
			if(catalogue[path])
				stack_trace("Duplicate cargo catalogue entry for path '[path]' from cargo_list [list_type]. Overwriting previous entry.")
			// Use item_path as the catalogue key (valid type path, works with text2path)
			cargo_items[path] = item
			catalogue[path] = list("type" = "item", "datum" = item)
		qdel(CL)

	// --- Initialize cargo items (legacy subtypes not yet converted to cargo_list) ---
	for(var/item_type in subtypesof(/datum/cargo_item))
		var/datum/cargo_item/item = new item_type()
		if(!item.item_path)
			continue
		if(catalogue[item_type])
			stack_trace("Duplicate cargo catalogue entry for type '[item_type]'. Overwriting previous entry.")
		cargo_items[item_type] = item
		catalogue[item_type] = list("type" = "item", "datum" = item)

	// --- Initialize cargo crates ---
	for(var/crate_type in subtypesof(/datum/cargo_crate))
		var/datum/cargo_crate/crate = new crate_type()
		if(!crate.contains)
			continue
		if(catalogue[crate_type])
			stack_trace("Duplicate cargo catalogue entry for type '[crate_type]'. Overwriting previous entry.")
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
/// Checks catalogue (cargo_items + cargo_crates).
/// Returns a list("type", "datum") or null.
/datum/controller/subsystem/supply/proc/get_product(product_type)
	if(catalogue[product_type])
		return catalogue[product_type]
	return null
