GLOBAL_LIST_INIT(blacklisted_cargo_types, typecacheof(list(
	/mob/living,
	/obj/structure/blob,
	/obj/effect/rune,
	/obj/structure/spider/spiderling,
	/obj/item/disk/nuclear,
	/obj/machinery/nuclearbomb,
	/obj/item/beacon,
	/obj/eldritch/narsie,
	/obj/tear_in_reality,
	/obj/machinery/teleport/station,
	/obj/machinery/teleport/hub,
	/obj/machinery/quantumpad,
	/obj/machinery/clonepod,
	/obj/effect/mob_spawn,
	/obj/effect/hierophant,
	/obj/structure/receiving_pad,
	/obj/item/warp_cube,
	/obj/machinery/rnd/production, //print tracking beacons, send shuttle
	/obj/machinery/modular_fabricator/autolathe, //same
	/obj/projectile/beam/wormhole,
	/obj/effect/portal,
	/obj/item/shared_storage,
	/obj/structure/extraction_point,
	/obj/machinery/syndicatebomb,
	/obj/item/hilbertshotel,
	/obj/item/swapper,
	/obj/item/mail,
	/obj/docking_port,
	/obj/effect/warped_rune, // no teleporting to cc for you
	/obj/structure/slime_crystal/bluespace // Dang it, you still teleported to CC!
)))

GLOBAL_LIST_INIT(whitelisted_cargo_types, typecacheof(list(
	/obj/effect/mob_spawn/sentient_artifact,
	/mob/living/simple_animal/shade/sentience,
)))


/obj/docking_port/mobile/supply
	name = "supply shuttle"
	id = "supply"
	callTime = 600

	dir = WEST
	port_direction = EAST
	width = 12
	dwidth = 5
	height = 7
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	undockable = TRUE


	//Export categories for this run, this is set by console sending the shuttle.
	var/export_categories = EXPORT_CARGO

/obj/docking_port/mobile/supply/register()
	. = ..()
	SSshuttle.supply = src

/obj/docking_port/mobile/supply/canMove()
	if(is_station_level(z))
		return check_blacklist(shuttle_areas)
	return ..()

/obj/docking_port/mobile/supply/proc/check_blacklist(areaInstances)
	for(var/place in areaInstances)
		var/area/shuttle/shuttle_area = place
		for(var/trf in shuttle_area)
			var/turf/T = trf
			for(var/a in T.GetAllContents())
				if(is_type_in_typecache(a, GLOB.blacklisted_cargo_types) && !istype(a, /obj/docking_port) && !is_type_in_typecache(a, GLOB.whitelisted_cargo_types))
					return FALSE
	return TRUE

/obj/docking_port/mobile/supply/request(obj/docking_port/stationary/S)
	if(mode != SHUTTLE_IDLE)
		return 2
	return ..()

/obj/docking_port/mobile/supply/initiate_docking()
	if(getDockedId() == "supply_away") // Buy when we leave home.
		buy()
		create_mail()
	. = ..() // Fly/enter transit.
	if(. != DOCKING_SUCCESS)
		return
	if(getDockedId() == "supply_away") // Sell when we get home
		sell()

/obj/docking_port/mobile/supply/proc/buy()
	var/list/obj/miscboxes = list() //miscboxes are combo boxes that contain all small_item orders grouped
	var/list/misc_order_num = list() //list of strings of order numbers, so that the manifest can show all orders in a box
	var/list/misc_contents = list() //list of lists of items that each box will contain
	var/list/misc_costs = list() //list of overall costs sustained by each buyer.
	var/list/misc_orders = list() // list of lists of supply_order datums per owner for combo manifests
	if(!SSsupply.shoppinglist.len)
		return

	var/list/empty_turfs = list()
	for(var/place in shuttle_areas)
		var/area/shuttle/shuttle_area = place
		for(var/turf/open/floor/T in shuttle_area)
			if(T.is_blocked_turf())
				continue
			empty_turfs += T

	// Generate a unique batch code for this entire shipment
	var/batch_code = generate_batch_code()

	// First pass: process payments and sort into regular crates vs small item groups
	// Also expand batch orders into individual sub-orders
	var/list/regular_orders = list() // list of supply_order datums that get their own crate
	var/value = 0
	var/purchases = 0
	for(var/datum/supply_order/SO in SSsupply.shoppinglist)
		if(!empty_turfs.len)
			break

		// Handle batch orders by expanding them into individual items
		if(istype(SO, /datum/supply_order/batch))
			var/datum/supply_order/batch/BO = SO
			var/datum/bank_account/D
			if(BO.paying_account)
				D = BO.paying_account
			else
				D = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)

			// Calculate actual cost at purchase time
			var/batch_total = 0
			var/list/valid_entries = list()
			for(var/list/entry in BO.entries)
				var/datum/product = entry["pack"]
				var/quantity = entry["quantity"]
				var/entry_cost = entry["cost"]
				// Check stock for each entry
				var/available = min(quantity, get_product_supply(product))
				if(available <= 0)
					continue
				var/cost_for_entry = entry_cost * available
				if(BO.paying_account)
					cost_for_entry = round(cost_for_entry * 1.1)
				batch_total += cost_for_entry
				valid_entries += list(list("pack" = product, "quantity" = available, "cost" = entry_cost))

			if(!length(valid_entries))
				continue

			// Try to charge the full batch
			if(D)
				if(!D.adjust_money(-batch_total))
					if(BO.paying_account)
						D.bank_card_talk("Batch order #[BO.id] rejected due to lack of funds. Credits required: [batch_total]")
					continue

			if(BO.paying_account)
				D.bank_card_talk("Batch order #[BO.id] has shipped. [batch_total] credits have been charged to your bank account.")
				var/datum/bank_account/department/cargo = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
				// Cargo gets the handling fee (difference between charged amount and base cost)
				var/base_cost = 0
				for(var/list/ve in valid_entries)
					base_cost += ve["cost"] * ve["quantity"]
				cargo.adjust_money(batch_total - base_cost)

			value += batch_total
			SSsupply.shoppinglist -= BO
			SSsupply.orderhistory += BO

			// Now expand each valid entry into individual sub-orders for crate generation
			for(var/list/ventry in valid_entries)
				var/datum/product = ventry["pack"]
				var/quantity = ventry["quantity"]
				adjust_product_supply(product, -quantity)

				var/p_small = FALSE
				var/p_name = ""
				var/p_access = null
				var/p_dangerous = FALSE
				var/p_cost = ventry["cost"]
				if(istype(product, /datum/cargo_item))
					var/datum/cargo_item/item = product
					p_small = item.small_item
					p_name = item.name
					p_access = item.access
					p_dangerous = item.dangerous
				else if(istype(product, /datum/cargo_crate))
					var/datum/cargo_crate/crate = product
					p_small = crate.small_item
					p_name = crate.name
					p_access = crate.access
					p_dangerous = crate.dangerous
				else if(istype(product, /datum/supply_pack))
					var/datum/supply_pack/legacy = product
					p_small = legacy.small_item
					p_name = legacy.name
					p_access = legacy.access
					p_dangerous = legacy.dangerous

				for(var/i in 1 to quantity)
					// Create a temporary sub-order for crate generation
					var/datum/supply_order/sub = new(product, BO.orderer, BO.orderer_rank, BO.orderer_ckey, BO.reason, BO.paying_account)
					if(p_small)
						var/list/item_contents = get_pack_contains(product)
						var/owner_key = BO.paying_account ? D.account_holder : "Cargo"
						if(!miscboxes[owner_key])
							if(BO.paying_account)
								miscboxes[owner_key] = new /obj/structure/closet/crate/secure/owned(pick_n_take(empty_turfs), BO.paying_account)
							else
								miscboxes[owner_key] = new /obj/structure/closet/crate/secure(pick_n_take(empty_turfs))
							misc_contents[owner_key] = list()
							miscboxes[owner_key].req_access = list()
							misc_orders[owner_key] = list()
						for(var/item in item_contents)
							misc_contents[owner_key] += item
						misc_costs[owner_key] += p_cost
						misc_order_num[owner_key] = "[misc_order_num[owner_key]]#[sub.id]  "
						misc_orders[owner_key] += sub
						if(!BO.paying_account && p_access)
							miscboxes[owner_key].req_access |= p_access
					else
						regular_orders += sub

					SSblackbox.record_feedback("nested tally", "cargo_imports", 1, list("[p_cost]", "[p_name]"))
					investigate_log("Batch order #[BO.id] sub-item ([p_name], placed by [key_name(BO.orderer_ckey)]), paid by [D.account_holder] has shipped.", INVESTIGATE_CARGO)
					if(p_dangerous)
						message_admins("\A [p_name] from batch order by [ADMIN_LOOKUPFLW(BO.orderer_ckey)], paid by [D.account_holder] has shipped.")
					purchases++
			continue

		// Regular (non-batch) order handling
		if(!empty_turfs.len)
			break
		var/price = SO.pack_cost
		var/datum/bank_account/D
		if(SO.paying_account) //Someone paid out of pocket
			D = SO.paying_account
			price *= 1.1 //TODO make this customizable by the quartermaster
		else
			D = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
		if(D)
			if(!D.adjust_money(-price))
				if(SO.paying_account)
					D.bank_card_talk("Cargo order #[SO.id] rejected due to lack of funds. Credits required: [price]")
				continue
		//No stock
		if(get_product_supply(SO.pack) <= 0)
			continue

		adjust_product_supply(SO.pack, -1)

		if(SO.paying_account)
			D.bank_card_talk("Cargo order #[SO.id] has shipped. [price] credits have been charged to your bank account.")
			var/datum/bank_account/department/cargo = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
			cargo.adjust_money(price - SO.pack_cost) //Cargo gets the handling fee
		value += SO.pack_cost
		SSsupply.shoppinglist -= SO
		SSsupply.orderhistory += SO

		if(SO.pack_small_item) //small_item means it gets piled in the miscbox
			var/list/item_contents = get_pack_contains(SO.pack)
			var/owner_key = SO.paying_account ? D.account_holder : "Cargo"
			if(!miscboxes[owner_key])
				if(SO.paying_account)
					miscboxes[owner_key] = new /obj/structure/closet/crate/secure/owned(pick_n_take(empty_turfs), SO.paying_account)
				else
					miscboxes[owner_key] = new /obj/structure/closet/crate/secure(pick_n_take(empty_turfs))
				misc_contents[owner_key] = list()
				miscboxes[owner_key].req_access = list()
				misc_orders[owner_key] = list()
			for(var/item in item_contents)
				misc_contents[owner_key] += item
			misc_costs[owner_key] += SO.pack_cost
			misc_order_num[owner_key] = "[misc_order_num[owner_key]]#[SO.id]  "
			misc_orders[owner_key] += SO
			if(!SO.paying_account && SO.pack_access)
				miscboxes[owner_key].req_access |= SO.pack_access
		else
			regular_orders += SO

		SSblackbox.record_feedback("nested tally", "cargo_imports", 1, list("[SO.pack_cost]", "[SO.pack_name]"))
		investigate_log("Order #[SO.id] ([SO.pack_name], placed by [key_name(SO.orderer_ckey)]), paid by [D.account_holder] has shipped.", INVESTIGATE_CARGO)
		if(SO.pack_dangerous)
			message_admins("\A [SO.pack_name] ordered by [ADMIN_LOOKUPFLW(SO.orderer_ckey)], paid by [D.account_holder] has shipped.")
		purchases++

	// Count total crates for naming
	var/total_crates = length(regular_orders) + length(miscboxes)
	var/crate_num = 0

	// Generate regular crates with batch naming and per-crate manifests
	for(var/datum/supply_order/SO in regular_orders)
		if(!empty_turfs.len)
			break
		crate_num++
		var/obj/structure/closet/crate/C = SO.generate(pick_n_take(empty_turfs))
		if(C)
			C.name = "Batch [batch_code] - Crate [crate_num]/[total_crates]"
			SO.generateManifest(C, batch_code, crate_num, total_crates)

	// Generate combo crates for small items with batch naming
	for(var/owner_key in miscboxes)
		crate_num++
		var/obj/structure/closet/crate/miscbox = miscboxes[owner_key]
		for(var/item_path in misc_contents[owner_key])
			new item_path(miscbox)
		miscbox.name = "Batch [batch_code] - Crate [crate_num]/[total_crates]"
		// Use the first order in this group to generate the combo manifest
		if(length(misc_orders[owner_key]))
			var/datum/supply_order/first_order = misc_orders[owner_key][1]
			first_order.generateComboManifest(miscbox, batch_code, crate_num, total_crates, owner_key, misc_order_num[owner_key])

	// Generate the master shipment manifest paper on the shuttle floor
	if(purchases && length(empty_turfs))
		generate_shipment_manifest(pick(empty_turfs), batch_code, regular_orders, miscboxes, misc_order_num, misc_orders, total_crates)

	var/datum/bank_account/cargo_budget = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
	investigate_log("[purchases] orders in this shipment, worth [value] credits. [cargo_budget.account_balance] credits left.", INVESTIGATE_CARGO)

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_RESUPPLY)

/// Generates the master shipment manifest paper listing all orders in this batch.
/obj/docking_port/mobile/supply/proc/generate_shipment_manifest(turf/T, batch_code, list/regular_orders, list/miscboxes, list/misc_order_num, list/misc_orders, total_crates)
	var/obj/item/paper/manifest_paper = new(T)
	manifest_paper.name = "shipment manifest - Batch [batch_code]"

	var/text = "<h2>[command_name()] Shipment Manifest</h2>"
	text += "<hr/>"
	text += "<b>Batch Order: [batch_code]</b><br/>"
	text += "Total Crates: [total_crates]<br/>"
	text += "Destination: [GLOB.station_name]<br/>"
	text += "<hr/>"

	var/crate_num = 0

	// List regular orders
	for(var/datum/supply_order/SO in regular_orders)
		crate_num++
		text += "<b>Crate [crate_num]/[total_crates] — Order #[SO.id]</b><br/>"
		text += "Item: [SO.pack_name]<br/>"
		text += "Ordered by: [SO.orderer] ([SO.orderer_rank])<br/>"
		if(SO.paying_account)
			text += "Paid by: [SO.paying_account.account_holder]<br/>"
		if(SO.reason)
			text += "Reason: [SO.reason]<br/>"
		// List expected contents
		var/list/contents_readable = list()
		if(istype(SO.pack, /datum/cargo_item))
			var/datum/cargo_item/item = SO.pack
			contents_readable = item.get_contents_readable()
		else if(istype(SO.pack, /datum/cargo_crate))
			var/datum/cargo_crate/crate = SO.pack
			contents_readable = crate.get_contents_readable()
		else if(istype(SO.pack, /datum/supply_pack))
			var/datum/supply_pack/legacy = SO.pack
			contents_readable = legacy.get_contents_readable()
		if(length(contents_readable))
			text += "Contents: "
			text += "<ul>"
			for(var/item_name in contents_readable)
				text += "<li>[item_name]</li>"
			text += "</ul>"
		text += "<br/>"

	// List grouped small item crates
	for(var/owner_key in miscboxes)
		crate_num++
		text += "<b>Crate [crate_num]/[total_crates] — Grouped Small Items</b><br/>"
		text += "Orders: [misc_order_num[owner_key]]<br/>"
		if(owner_key != "Cargo")
			text += "Paid by: [owner_key]<br/>"
		// List the individual orders in this group
		if(misc_orders[owner_key])
			text += "Contents: "
			text += "<ul>"
			for(var/datum/supply_order/SO in misc_orders[owner_key])
				text += "<li>[SO.pack_name] (Order #[SO.id])</li>"
			text += "</ul>"
		text += "<br/>"

	text += "<hr/>"
	text += "<h4>Stamp below to confirm receipt of shipment:</h4>"

	manifest_paper.add_raw_text(text)
	manifest_paper.update_appearance()
	return manifest_paper

/obj/docking_port/mobile/supply/proc/sell()
	var/datum/bank_account/D = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
	var/presale_points = D.account_balance

	var/msg = ""
	var/matched_bounty = FALSE

	var/datum/export_report/report = new

	for(var/place in shuttle_areas)
		var/area/shuttle/shuttle_area = place
		for(var/atom/movable/AM in shuttle_area)
			if(iscameramob(AM))
				continue
			if(bounty_ship_item_and_contents(AM, dry_run = FALSE))
				matched_bounty = TRUE
			if(!AM.anchored)
				export_item_and_contents(AM, export_categories , dry_run = FALSE, external_report = report)

	if(matched_bounty)
		msg += "Bounty items received. An update has been sent to all bounty consoles. "

	for(var/datum/export/export in report.exported_atoms)
		var/export_text = export.total_printout(report)
		if(!export_text)
			continue

		msg += export_text + "\n"
		D.adjust_money(report.total_value[export])

	SSshuttle.centcom_message = msg
	investigate_log("Shuttle contents sold for [D.account_balance - presale_points] credits. Exported: [SSshuttle.centcom_message || "none."]", INVESTIGATE_CARGO)


//	Generates a box of mail depending on our exports and imports.
//	Applied in the cargo shuttle sending/arriving, by building the crate if the round is ready to introduce mail based on the economy subsystem.
// Then, fills the mail crate with mail, by picking applicable crew who can receive mail at the time to sending.

/obj/docking_port/mobile/supply/proc/create_mail()
	//Early return if there's no mail waiting to prevent taking up a slot.
	if(SSeconomy.mail_waiting < MAIL_REQUIRED_BEFORE_SPAWN)
		return
	//spawn crate
	var/list/empty_turfs = list()
	for(var/area/shuttle/shuttle_area in shuttle_areas)
		for(var/turf/open/floor/T in shuttle_area)
			if(T.is_blocked_turf())
				continue
			empty_turfs += T

	if(!length(empty_turfs))
		return

	new /obj/structure/closet/crate/mail/economy(pick(empty_turfs))
