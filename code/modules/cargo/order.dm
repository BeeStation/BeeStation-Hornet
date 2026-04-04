/// The chance for a manifest or crate to be created with errors
#define MANIFEST_ERROR_CHANCE		5

// MANIFEST BITFLAGS
/// Determines if the station name will be incorrect on the manifest
#define MANIFEST_ERROR_NAME (1 << 0)
/// Determines if contents will be deleted from the manifest but still be present in the crate
#define MANIFEST_ERROR_CONTENTS (1 << 1)
/// Determines if contents will be deleted from the crate but still be present in the manifest
#define MANIFEST_ERROR_ITEM (1 << 2)


/obj/item/paper/fluff/jobs/cargo/manifest
	var/order_cost = 0
	var/order_id = 0
	var/errors = 0

/obj/item/paper/fluff/jobs/cargo/manifest/New(atom/A, id, cost)
	..()
	order_id = id
	order_cost = cost

	if(prob(MANIFEST_ERROR_CHANCE))
		errors |= MANIFEST_ERROR_NAME
	if(prob(MANIFEST_ERROR_CHANCE))
		errors |= MANIFEST_ERROR_CONTENTS
	if(prob(MANIFEST_ERROR_CHANCE))
		errors |= MANIFEST_ERROR_ITEM

/obj/item/paper/fluff/jobs/cargo/manifest/proc/is_approved()
	return LAZYLEN(stamp_cache) && !is_denied()

/obj/item/paper/fluff/jobs/cargo/manifest/proc/is_denied()
	return LAZYLEN(stamp_cache) && ("stamp-deny" in stamp_cache)

/datum/supply_order
	var/id
	var/orderer
	var/orderer_rank
	var/orderer_ckey
	var/reason
	/// The product being ordered. Can be /datum/cargo_item or /datum/cargo_crate.
	var/datum/pack
	var/datum/bank_account/paying_account

	// Cached values for display - set from the product datum at order creation time
	var/pack_name = ""
	var/pack_cost = 0
	var/pack_access = null
	var/pack_dangerous = FALSE
	var/pack_small_item = FALSE

/datum/supply_order/New(datum/product, orderer, orderer_rank, orderer_ckey, reason, paying_account)
	id = SSsupply.ordernum++
	src.pack = product
	src.orderer = orderer
	src.orderer_rank = orderer_rank
	src.orderer_ckey = orderer_ckey
	src.reason = reason
	src.paying_account = paying_account
	// Cache display values
	if(istype(product, /datum/cargo_item))
		var/datum/cargo_item/item = product
		pack_name = item.name
		pack_cost = item.get_cost()
		pack_access = item.access
		pack_dangerous = item.dangerous
		pack_small_item = item.small_item
	else if(istype(product, /datum/cargo_crate))
		var/datum/cargo_crate/crate = product
		pack_name = crate.name
		pack_cost = crate.get_cost()
		pack_access = crate.access
		pack_dangerous = crate.dangerous

/// Generate a unique batch order code (e.g. "#513-X131-T")
/proc/generate_batch_code()
	var/num_part = rand(100, 9999)
	var/static/list/alpha_chars = list("A","B","C","D","E","F","G","H","J","K","L","M","N","P","Q","R","S","T","U","V","W","X","Y","Z")
	var/mid = "[pick(alpha_chars)][rand(100, 999)]"
	var/tail = pick(alpha_chars)
	return "#[num_part]-[mid]-[tail]"

/// Generate a shipping manifest paper placed inside a crate.
/// This lists the crate's actual contents and is stampable.
/datum/supply_order/proc/generateManifest(obj/structure/closet/crate/C, batch_code, crate_index, total_crates)
	var/obj/item/paper/fluff/jobs/cargo/manifest/manifest_paper = new(C, id, pack_cost)

	var/station_name = (manifest_paper.errors & MANIFEST_ERROR_NAME) ? new_station_name() : GLOB.station_name

	manifest_paper.name = "shipping manifest - [batch_code] Crate [crate_index]/[total_crates]"

	var/manifest_text = "<h2>[command_name()] Shipping Manifest</h2>"
	manifest_text += "<hr/>"
	manifest_text += "Batch Order: [batch_code]<br/>"
	manifest_text += "Crate [crate_index] of [total_crates]<br/>"
	manifest_text += "Order #[id] - [pack_name]<br/>"
	manifest_text += "Destination: [station_name]<br/>"
	if(paying_account)
		manifest_text += "Purchased by: [paying_account.account_holder]<br/>"
	manifest_text += "Ordered by: [orderer] ([orderer_rank])<br/>"
	if(reason)
		manifest_text += "Reason: [reason]<br/>"
	manifest_text += "<br/>Contents: <br/>"
	manifest_text += "<ul>"
	for(var/atom/movable/AM in C.contents - manifest_paper)
		if((manifest_paper.errors & MANIFEST_ERROR_CONTENTS))
			if(prob(50))
				manifest_text += "<li>[AM.name]</li>"
			else
				continue
		manifest_text += "<li>[AM.name]</li>"
	manifest_text += "</ul>"
	manifest_text += "<h4>Stamp below to confirm receipt of goods:</h4>"

	manifest_paper.add_raw_text(manifest_text)

	if(manifest_paper.errors & MANIFEST_ERROR_ITEM)
		if(istype(C, /obj/structure/closet/crate/secure) || istype(C, /obj/structure/closet/crate/large))
			manifest_paper.errors &= ~MANIFEST_ERROR_ITEM
		else
			var/lost = max(round(C.contents.len / 10), 1)
			while(--lost >= 0)
				qdel(pick(C.contents))

	manifest_paper.update_appearance()
	manifest_paper.forceMove(C)

	C.manifest = manifest_paper
	C.update_icon()

	return manifest_paper

/// Generate a combo crate manifest for grouped small items.
/datum/supply_order/proc/generateComboManifest(obj/structure/closet/crate/C, batch_code, crate_index, total_crates, owner, order_ids)
	var/total_cost = 0
	for(var/atom/movable/AM in C.contents)
		total_cost += 50 // rough per-item cost for combo crates
	var/obj/item/paper/fluff/jobs/cargo/manifest/manifest_paper = new(C, order_ids, total_cost)

	var/station_name = (manifest_paper.errors & MANIFEST_ERROR_NAME) ? new_station_name() : GLOB.station_name

	manifest_paper.name = "shipping manifest - [batch_code] Crate [crate_index]/[total_crates]"

	var/manifest_text = "<h2>[command_name()] Shipping Manifest</h2>"
	manifest_text += "<hr/>"
	manifest_text += "Batch Order: [batch_code]<br/>"
	manifest_text += "Crate [crate_index] of [total_crates] (Grouped Small Items)<br/>"
	manifest_text += "Orders: [order_ids]<br/>"
	manifest_text += "Destination: [station_name]<br/>"
	if(owner && owner != "Cargo")
		manifest_text += "Purchased by: [owner]<br/>"
	manifest_text += "<br/>Contents: <br/>"
	manifest_text += "<ul>"
	for(var/atom/movable/AM in C.contents - manifest_paper)
		if((manifest_paper.errors & MANIFEST_ERROR_CONTENTS))
			if(prob(50))
				manifest_text += "<li>[AM.name]</li>"
			else
				continue
		manifest_text += "<li>[AM.name]</li>"
	manifest_text += "</ul>"
	manifest_text += "<h4>Stamp below to confirm receipt of goods:</h4>"

	manifest_paper.add_raw_text(manifest_text)

	if(manifest_paper.errors & MANIFEST_ERROR_ITEM)
		if(istype(C, /obj/structure/closet/crate/secure) || istype(C, /obj/structure/closet/crate/large))
			manifest_paper.errors &= ~MANIFEST_ERROR_ITEM
		else
			var/lost = max(round(C.contents.len / 10), 1)
			while(--lost >= 0)
				qdel(pick(C.contents))

	manifest_paper.update_appearance()
	manifest_paper.forceMove(C)

	C.manifest = manifest_paper
	C.update_icon()

	return manifest_paper

/// Generate the crate and its contents at the given location. Does NOT name or add manifest - that's handled by the shuttle buy proc.
/datum/supply_order/proc/generate(atom/A)
	var/obj/structure/closet/crate/C

	if(istype(pack, /datum/cargo_crate))
		var/datum/cargo_crate/crate = pack
		C = crate.generate(A, paying_account)
	else if(istype(pack, /datum/cargo_item))
		var/datum/cargo_item/item = pack
		// For individual items, create a crate and put the item in it
		if(paying_account && item.can_secure)
			C = new /obj/structure/closet/crate/secure/owned(A, paying_account)
		else
			C = new item.crate_type(A)
		if(item.access && !paying_account)
			if(islist(item.access))
				C.req_one_access = item.access
			else
				C.req_one_access = list(item.access)
		new item.item_path(C)

	return C

/**
 * # Batch Supply Order
 *
 * Represents a confirmed batch order - multiple items bundled into a single
 * entry on the shopping list / request list. The UI shows this as one row
 * with expandable contents and crate count.
 *
 * When the supply shuttle processes this order, it expands the entries into
 * individual crates grouped by crate type, with up to 10 items per crate.
 *
 * ## Pricing Model
 * - **Base item costs**: Sum of each item's cost × quantity.
 * - **Batch surcharge**: Flat fee that shrinks linearly as you add
 *   items, reaching 0 at BATCH_SURCHARGE_ITEMS_ZERO items.
 * - **Bulk discount**: After BATCH_BULK_DISCOUNT_START items, the total
 *   gets a discount that grows up to BATCH_BULK_DISCOUNT_MAX at
 *   BATCH_BULK_DISCOUNT_CAP+ items.
 * - **Crate cost**: Each crate in the order costs a per-type fee (see BATCH_CRATE_COST_* defines).
 *   Fully refunded when the crate is sent back on the shuttle.
 * - **Self-paid surcharge**: BATCH_SELF_PAID_PCT% on top of the final price.
 */
/datum/supply_order/batch
	/// List of entries in this batch. Each entry is list("pack" = datum, "quantity" = num)
	var/list/entries = list()
	/// Total cost of the batch (after all modifiers, pre-computed at creation time)
	var/total_cost = 0
	/// Base cost before modifiers
	var/base_cost = 0
	/// Total number of individual items in the batch
	var/total_items = 0
	/// Number of crates this batch will produce
	var/crate_count = 0
	/// Whether this batch is self-paid
	var/self_paid_batch = FALSE
	/// The batch surcharge amount applied
	var/surcharge = 0
	/// The bulk discount multiplier (0 to BATCH_BULK_DISCOUNT_MAX)
	var/bulk_discount = 0
	/// The total crate cost applied
	var/crate_cost = 0

// Batch pricing #defines now live in code/__DEFINES/cargo.dm

/datum/supply_order/batch/New(list/batch_entries, orderer, orderer_rank, orderer_ckey, reason, paying_account, is_self_paid = FALSE)
	id = SSsupply.ordernum++
	src.orderer = orderer
	src.orderer_rank = orderer_rank
	src.orderer_ckey = orderer_ckey
	src.reason = reason
	src.paying_account = paying_account
	self_paid_batch = is_self_paid

	// Process batch entries - each is list("pack_id" = type_path, "quantity" = num)
	var/cost_sum = 0
	var/item_sum = 0
	for(var/list/raw_entry in batch_entries)
		var/pack_id = raw_entry["pack_id"]
		var/quantity = raw_entry["quantity"]
		var/list/product_info = SSsupply.get_product(pack_id)
		if(!product_info)
			continue
		var/datum/product = product_info["datum"]
		var/p_cost = get_product_cost(product)
		cost_sum += p_cost * quantity
		item_sum += quantity
		entries += list(list("pack" = product, "quantity" = quantity, "cost" = p_cost))

	base_cost = cost_sum
	total_items = item_sum

	// Calculate crate breakdown by type and count
	var/list/crate_data = calculate_batch_crates(entries)
	crate_count = length(crate_data)

	// Calculate pricing modifiers
	var/list/modifiers = calculate_batch_pricing(base_cost, total_items, crate_data, is_self_paid)
	surcharge = modifiers["surcharge"]
	bulk_discount = modifiers["bulk_discount"]
	crate_cost = modifiers["crate_cost"]
	total_cost = modifiers["final_cost"]

	// Set display values for the base datum
	pack_name = "Batch Order ([total_items] items, [crate_count] crate\s)"
	pack_cost = total_cost

/// Returns a human-readable list of item names and quantities for UI display
/datum/supply_order/batch/proc/get_batch_contents_readable()
	var/list/readable = list()
	for(var/list/entry in entries)
		var/datum/product = entry["pack"]
		var/quantity = entry["quantity"]
		readable += "[get_product_name(product)] x[quantity]"
	return readable

// ============================================================================
// BATCH PRICING HELPERS - shared between order creation and UI preview
// ============================================================================

/// Get the cost of a product datum
/proc/get_product_cost(datum/product)
	if(istype(product, /datum/cargo_item))
		var/datum/cargo_item/item = product
		return item.get_cost()
	if(istype(product, /datum/cargo_crate))
		var/datum/cargo_crate/crate = product
		return crate.get_cost()
	return 0

/// Get the name of a product datum
/proc/get_product_name(datum/product)
	if(istype(product, /datum/cargo_item))
		var/datum/cargo_item/item = product
		return item.name
	if(istype(product, /datum/cargo_crate))
		var/datum/cargo_crate/crate = product
		return crate.name
	return "Unknown"

/// Get the crate_type path of a product datum
/proc/get_product_crate_type(datum/product)
	if(istype(product, /datum/cargo_item))
		var/datum/cargo_item/item = product
		return item.crate_type
	if(istype(product, /datum/cargo_crate))
		var/datum/cargo_crate/crate = product
		return crate.crate_type
	return /obj/structure/closet/crate

/// Get whether a product datum is a small item (TRUE) or bulky (FALSE)
/proc/get_product_small_item(datum/product)
	if(istype(product, /datum/cargo_item))
		var/datum/cargo_item/item = product
		return item.small_item
	if(istype(product, /datum/cargo_crate))
		var/datum/cargo_crate/crate = product
		return crate.small_item
	return FALSE

/// Get how many crate slots a single unit of a product occupies.
/proc/get_product_crate_slots(datum/product)
	return get_product_small_item(product) ? 1 : BATCH_BULKY_ITEM_SLOTS

/// Get the access requirement for a product datum (null = no access restriction)
/proc/get_product_access(datum/product)
	if(istype(product, /datum/cargo_item))
		var/datum/cargo_item/item = product
		return item.access
	if(istype(product, /datum/cargo_crate))
		var/datum/cargo_crate/crate = product
		return crate.access
	return null

/// Get the display name of a crate type path
/proc/get_crate_type_name(crate_type_path)
	if(!crate_type_path)
		return "Standard Crate"
	var/obj/structure/closet/crate/C = crate_type_path
	return initial(C.name)

/// Get the batch deposit cost for a given crate type path.
/// Returns the crate's custom_price (which mirrors the per-type define), falling back to BATCH_CRATE_COST_STANDARD.
/proc/get_crate_type_cost(crate_type_path)
	if(!crate_type_path)
		return BATCH_CRATE_COST_STANDARD
	var/obj/structure/closet/crate/C = crate_type_path
	var/price = initial(C.custom_price)
	return price ? price : BATCH_CRATE_COST_STANDARD

/// Calculate the crate breakdown for a batch of entries.
/// Groups items by their crate_type AND access requirement, packing by slot usage (small items = 1 slot, bulky = BATCH_BULKY_ITEM_SLOTS).
/// Items with different access restrictions will never be placed in the same crate.
/// Returns a list of assoc lists: ("crate_type" = path, "crate_name" = string, "access" = access, "items" = list of names, "count" = num, "slots_used" = num)
/proc/calculate_batch_crates(list/entries)
	// Group items by (crate_type, access), keeping per-item slot cost
	var/list/type_groups = list() // "crate_type|access" => list("crate_type", "access", "items" = list of list("name", "slots"))
	for(var/list/entry in entries)
		var/datum/product = entry["pack"]
		var/quantity = entry["quantity"]
		var/crate_type = get_product_crate_type(product)
		var/p_name = get_product_name(product)
		var/slots_per = get_product_crate_slots(product)
		var/p_access = get_product_access(product)
		// Build a composite key from crate_type and access so items with different access go in separate crates
		var/group_key = "[crate_type]|[p_access]"
		if(!type_groups[group_key])
			type_groups[group_key] = list("crate_type" = crate_type, "access" = p_access, "items" = list())
		var/list/group = type_groups[group_key]
		for(var/i in 1 to quantity)
			group["items"] += list(list("name" = p_name, "slots" = slots_per))

	// Now split each group into crates by slot capacity (BATCH_CRATE_MAX_ITEMS slots per crate)
	var/list/crates = list()
	for(var/type_key in type_groups)
		var/list/group = type_groups[type_key]
		var/crate_type = group["crate_type"]
		var/crate_access = group["access"]
		var/crate_display_name = get_crate_type_name(crate_type)
		var/crate_unit_cost = get_crate_type_cost(crate_type)
		var/list/items = group["items"]
		var/list/current_crate_items = list()
		var/current_slots = 0
		for(var/list/item_info in items)
			var/item_slots = item_info["slots"]
			// If adding this item would exceed capacity, start a new crate
			// (unless the crate is empty - always allow at least one item)
			if(current_slots + item_slots > BATCH_CRATE_MAX_ITEMS && length(current_crate_items))
				crates += list(list(
					"crate_type" = crate_type,
					"crate_name" = crate_display_name,
					"access" = crate_access,
					"items" = current_crate_items,
					"count" = length(current_crate_items),
					"slots_used" = current_slots,
					"crate_cost" = crate_unit_cost
				))
				current_crate_items = list()
				current_slots = 0
			current_crate_items += item_info["name"]
			current_slots += item_slots
		// Don't forget the last crate
		if(length(current_crate_items))
			crates += list(list(
				"crate_type" = crate_type,
				"crate_name" = crate_display_name,
				"access" = crate_access,
				"items" = current_crate_items,
				"count" = length(current_crate_items),
				"slots_used" = current_slots,
				"crate_cost" = crate_unit_cost
			))

	return crates

/// Returns all batch pricing constants for the UI so descriptions stay in sync.
/proc/get_batch_pricing_constants()
	return list(
		"surcharge_max"            = BATCH_SURCHARGE_MAX,
		"surcharge_items_zero"     = BATCH_SURCHARGE_ITEMS_ZERO,
		"bulk_discount_start"      = BATCH_BULK_DISCOUNT_START,
		"bulk_discount_cap"        = BATCH_BULK_DISCOUNT_CAP,
		"bulk_discount_max_pct"    = round(BATCH_BULK_DISCOUNT_MAX * 100),
		"crate_max_items"          = BATCH_CRATE_MAX_ITEMS,
		"bulky_item_slots"         = BATCH_BULKY_ITEM_SLOTS,
		"self_paid_pct"            = BATCH_SELF_PAID_PCT,
		"crate_costs"              = list(
			"crate"                    = BATCH_CRATE_COST_STANDARD,
			"large crate"              = BATCH_CRATE_COST_LARGE,
			"internals crate"          = BATCH_CRATE_COST_INTERNALS,
			"medical crate"            = BATCH_CRATE_COST_MEDICAL,
			"radiation crate"          = BATCH_CRATE_COST_RADIATION,
			"secure crate"             = BATCH_CRATE_COST_SECURE,
			"gear crate"               = BATCH_CRATE_COST_SECURE_GEAR,
			"secure hydroponics crate" = BATCH_CRATE_COST_SECURE_HYDRO,
			"weapons crate"            = BATCH_CRATE_COST_SECURE_WEAPON,
			"plasma crate"             = BATCH_CRATE_COST_SECURE_PLASMA,
			"secure engineering crate" = BATCH_CRATE_COST_SECURE_ENGI,
			"engineering crate"        = BATCH_CRATE_COST_ENGINEERING,
		),
	)

/// Calculate all batch pricing modifiers.
/// Returns an assoc list with surcharge, bulk_discount, crate_cost, and final_cost.
/proc/calculate_batch_pricing(base_cost, total_items, list/crate_data, is_self_paid = FALSE)
	var/list/result = list()

	// 1. Batch surcharge: shrinks to 0 at BATCH_SURCHARGE_ITEMS_ZERO items
	var/surcharge_val = 0
	if(total_items > 0)
		var/surcharge_factor = clamp(1 - (total_items / BATCH_SURCHARGE_ITEMS_ZERO), 0, 1)
		surcharge_val = round(BATCH_SURCHARGE_MAX * surcharge_factor)
	result["surcharge"] = surcharge_val

	// 2. Bulk discount: kicks in above BATCH_BULK_DISCOUNT_START items
	var/bulk_discount_pct = 0
	if(total_items > BATCH_BULK_DISCOUNT_START)
		var/excess = total_items - BATCH_BULK_DISCOUNT_START
		var/range = BATCH_BULK_DISCOUNT_CAP - BATCH_BULK_DISCOUNT_START
		bulk_discount_pct = clamp(excess / range, 0, 1) * BATCH_BULK_DISCOUNT_MAX
	result["bulk_discount"] = bulk_discount_pct

	// 3. Crate cost: per-type fee per crate, refunded when the crate is sent back
	var/crate_cost_total = 0
	for(var/list/crate in crate_data)
		crate_cost_total += crate["crate_cost"]
	result["crate_cost"] = crate_cost_total

	// 4. Calculate final cost
	var/modified = base_cost
	modified += surcharge_val                         // Add flat surcharge
	modified *= (1 - bulk_discount_pct)               // Apply bulk discount
	modified += crate_cost_total                       // Add crate costs
	if(is_self_paid)
		modified *= 1 + (BATCH_SELF_PAID_PCT / 100)    // Self-paid surcharge
	result["final_cost"] = round(modified)

	return result

#undef MANIFEST_ERROR_CHANCE
#undef MANIFEST_ERROR_NAME
#undef MANIFEST_ERROR_CONTENTS
#undef MANIFEST_ERROR_ITEM
