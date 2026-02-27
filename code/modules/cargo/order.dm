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
	/// The product being ordered. Can be /datum/cargo_item, /datum/cargo_crate, or /datum/supply_pack (legacy).
	var/datum/pack
	var/datum/bank_account/paying_account

	// Cached values for display — set from the product datum at order creation time
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
	else if(istype(product, /datum/supply_pack))
		var/datum/supply_pack/legacy = product
		pack_name = legacy.name
		pack_cost = legacy.get_cost()
		pack_access = legacy.access
		pack_dangerous = legacy.dangerous
		pack_small_item = legacy.small_item

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

/// Generate the crate and its contents at the given location. Does NOT name or add manifest — that's handled by the shuttle buy proc.
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
	else if(istype(pack, /datum/supply_pack))
		// Legacy supply_pack
		var/datum/supply_pack/legacy = pack
		C = legacy.generate(A, paying_account)

	return C

/**
 * # Batch Supply Order
 *
 * Represents a confirmed batch order — multiple items bundled into a single
 * entry on the shopping list / request list. The UI shows this as one row
 * with expandable contents and crate count.
 *
 * When the supply shuttle processes this order, it expands the entries into
 * individual crates (regular items) and grouped combo crates (small items).
 */
/datum/supply_order/batch
	/// List of entries in this batch. Each entry is list("pack" = datum, "quantity" = num)
	var/list/entries = list()
	/// Total cost of the batch (pre-computed at creation time)
	var/total_cost = 0
	/// Total number of individual items in the batch
	var/total_items = 0
	/// Number of crates this batch will produce
	var/crate_count = 0
	/// Whether this batch is self-paid
	var/self_paid_batch = FALSE

/datum/supply_order/batch/New(list/batch_entries, orderer, orderer_rank, orderer_ckey, reason, paying_account, is_self_paid = FALSE)
	id = SSsupply.ordernum++
	src.orderer = orderer
	src.orderer_rank = orderer_rank
	src.orderer_ckey = orderer_ckey
	src.reason = reason
	src.paying_account = paying_account
	self_paid_batch = is_self_paid

	// Process batch entries — each is list("pack_id" = type_path, "quantity" = num)
	var/cost_sum = 0
	var/item_sum = 0
	var/small_count = 0
	var/regular_count = 0
	for(var/list/raw_entry in batch_entries)
		var/pack_id = raw_entry["pack_id"]
		var/quantity = raw_entry["quantity"]
		var/list/product_info = SSsupply.get_product(pack_id)
		if(!product_info)
			continue
		var/datum/product = product_info["datum"]
		var/p_cost = 0
		var/p_small = FALSE
		if(istype(product, /datum/cargo_item))
			var/datum/cargo_item/item = product
			p_cost = item.get_cost()
			p_small = item.small_item
		else if(istype(product, /datum/cargo_crate))
			var/datum/cargo_crate/crate = product
			p_cost = crate.get_cost()
			p_small = crate.small_item
		else if(istype(product, /datum/supply_pack))
			var/datum/supply_pack/legacy = product
			p_cost = legacy.get_cost()
			p_small = legacy.small_item
		var/entry_cost = p_cost * quantity
		if(is_self_paid)
			entry_cost = round(entry_cost * 1.1)
		cost_sum += entry_cost
		item_sum += quantity
		entries += list(list("pack" = product, "quantity" = quantity, "cost" = p_cost))
		if(p_small)
			small_count += quantity
		else
			regular_count += quantity

	total_cost = cost_sum
	total_items = item_sum
	// Calculate crate count: regular items get 1 crate each, small items group into crates of 10
	crate_count = regular_count + CEILING(small_count, 10)

	// Set display values for the base datum
	pack_name = "Batch Order ([total_items] items, [crate_count] crate\s)"
	pack_cost = total_cost

/// Returns a human-readable list of item names and quantities for UI display
/datum/supply_order/batch/proc/get_batch_contents_readable()
	var/list/readable = list()
	for(var/list/entry in entries)
		var/datum/product = entry["pack"]
		var/quantity = entry["quantity"]
		var/p_name = ""
		if(istype(product, /datum/cargo_item))
			var/datum/cargo_item/item = product
			p_name = item.name
		else if(istype(product, /datum/cargo_crate))
			var/datum/cargo_crate/crate = product
			p_name = crate.name
		else if(istype(product, /datum/supply_pack))
			var/datum/supply_pack/legacy = product
			p_name = legacy.name
		readable += "[p_name] x[quantity]"
	return readable

#undef MANIFEST_ERROR_CHANCE
#undef MANIFEST_ERROR_NAME
#undef MANIFEST_ERROR_CONTENTS
#undef MANIFEST_ERROR_ITEM
