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

	// Collect all generated crates from batch and non-batch orders
	var/list/all_generated_crates = list() // list of assoc: ("crate" = obj, "order" = supply_order)
	var/value = 0
	var/purchases = 0

	for(var/datum/supply_order/SO in SSsupply.shoppinglist)
		if(!empty_turfs.len)
			break

		// Handle batch orders - group items by crate_type, max 10 per crate
		if(istype(SO, /datum/supply_order/batch))
			var/datum/supply_order/batch/BO = SO
			var/datum/bank_account/D
			if(BO.paying_account)
				D = BO.paying_account
			else
				D = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)

			// Check stock and build valid entries
			var/list/valid_entries = list()
			var/base_cost_sum = 0
			var/total_valid_items = 0
			for(var/list/entry in BO.entries)
				var/datum/product = entry["pack"]
				var/quantity = entry["quantity"]
				var/entry_cost = entry["cost"]
				var/available = min(quantity, get_product_supply(product))
				if(available <= 0)
					continue
				base_cost_sum += entry_cost * available
				total_valid_items += available
				valid_entries += list(list("pack" = product, "quantity" = available, "cost" = entry_cost))

			if(!length(valid_entries))
				continue

			// Recalculate pricing with batch modifiers based on what's actually available
			var/list/crate_data = calculate_batch_crates(valid_entries)
			var/list/pricing = calculate_batch_pricing(base_cost_sum, total_valid_items, crate_data, BO.self_paid_batch)
			var/batch_total = pricing["final_cost"]

			// Try to charge the full batch
			if(D)
				if(!D.adjust_money(-batch_total))
					if(BO.paying_account)
						D.bank_card_talk("Batch order #[BO.id] rejected due to lack of funds. Credits required: [batch_total]")
					continue

			if(BO.paying_account)
				D.bank_card_talk("Batch order #[BO.id] has shipped. [batch_total] credits have been charged to your bank account.")
				var/datum/bank_account/department/cargo = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
				// Cargo gets the difference between what was charged and base cost
				cargo.adjust_money(batch_total - base_cost_sum)

			value += batch_total
			SSsupply.shoppinglist -= BO
			SSsupply.orderhistory += BO

			// Deduct stock
			for(var/list/ventry in valid_entries)
				var/datum/product = ventry["pack"]
				var/quantity = ventry["quantity"]
				adjust_product_supply(product, -quantity)

			// Generate crates grouped by (crate_type, access) (slot-based packing)
			for(var/list/crate_info in crate_data)
				if(!length(empty_turfs))
					break
				var/crate_type_path = crate_info["crate_type"]
				var/crate_access = crate_info["access"]
				var/list/item_names = crate_info["items"]
				var/obj/structure/closet/crate/C
				if(BO.paying_account)
					C = new /obj/structure/closet/crate/secure/owned(pick_n_take(empty_turfs), BO.paying_account)
				else
					C = new crate_type_path(pick_n_take(empty_turfs))

				// Fill the crate with actual items from valid entries matching BOTH crate type and access
				var/items_to_fill = length(item_names)
				var/items_filled = 0
				for(var/list/ventry in valid_entries)
					if(items_filled >= items_to_fill)
						break
					var/datum/product = ventry["pack"]
					// Must match both crate_type and access to ensure correct grouping
					if(get_product_crate_type(product) != crate_type_path)
						continue
					if(get_product_access(product) != crate_access)
						continue
					var/remaining_from_entry = ventry["quantity"]
					if(remaining_from_entry <= 0)
						continue
					var/take = min(remaining_from_entry, items_to_fill - items_filled)
					ventry["quantity"] -= take
					items_filled += take
					var/p_name = get_product_name(product)
					var/p_dangerous = FALSE
					if(istype(product, /datum/cargo_item))
						var/datum/cargo_item/item = product
						p_dangerous = item.dangerous
						for(var/i in 1 to take)
							new item.item_path(C)
					else if(istype(product, /datum/cargo_crate))
						var/datum/cargo_crate/crate = product
						p_dangerous = crate.dangerous
						for(var/i in 1 to take)
							crate.fill(C)
					SSblackbox.record_feedback("nested tally", "cargo_imports", take, list("[ventry["cost"]]", "[p_name]"))
					investigate_log("Batch order #[BO.id] sub-item ([p_name] x[take], placed by [key_name(BO.orderer_ckey)]), paid by [D.account_holder] has shipped.", INVESTIGATE_CARGO)
					if(p_dangerous)
						message_admins("\A [p_name] x[take] from batch order by [ADMIN_LOOKUPFLW(BO.orderer_ckey)], paid by [D.account_holder] has shipped.")
					purchases += take

				// Apply the group-level access to the crate (only for non-personal purchases)
				if(!BO.paying_account && crate_access)
					if(islist(crate_access))
						C.req_one_access = crate_access
					else
						C.req_one_access = list(crate_access)

				// Create a temporary sub-order for manifest generation
				var/datum/supply_order/sub = new(valid_entries[1]["pack"], BO.orderer, BO.orderer_rank, BO.orderer_ckey, BO.reason, BO.paying_account)
				all_generated_crates += list(list("crate" = C, "order" = sub))
			continue

		// Regular (non-batch) order handling
		if(!empty_turfs.len)
			break
		var/price = SO.pack_cost
		var/datum/bank_account/D
		if(SO.paying_account) //Someone paid out of pocket
			D = SO.paying_account
			price *= 1 + (BATCH_SELF_PAID_PCT / 100) // Self-paid surcharge
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

		// Generate the crate for this single order
		var/obj/structure/closet/crate/C = SO.generate(pick_n_take(empty_turfs))
		if(C)
			all_generated_crates += list(list("crate" = C, "order" = SO))

		SSblackbox.record_feedback("nested tally", "cargo_imports", 1, list("[SO.pack_cost]", "[SO.pack_name]"))
		investigate_log("Order #[SO.id] ([SO.pack_name], placed by [key_name(SO.orderer_ckey)]), paid by [D.account_holder] has shipped.", INVESTIGATE_CARGO)
		if(SO.pack_dangerous)
			message_admins("\A [SO.pack_name] ordered by [ADMIN_LOOKUPFLW(SO.orderer_ckey)], paid by [D.account_holder] has shipped.")
		purchases++

	// Name and add manifests to all generated crates
	var/total_crates = length(all_generated_crates)
	var/crate_num = 0
	for(var/list/crate_entry in all_generated_crates)
		crate_num++
		var/obj/structure/closet/crate/C = crate_entry["crate"]
		var/datum/supply_order/SO = crate_entry["order"]
		C.name = "Batch [batch_code] - Crate [crate_num]/[total_crates]"
		SO.generateManifest(C, batch_code, crate_num, total_crates)

	var/datum/bank_account/cargo_budget = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
	investigate_log("[purchases] orders in this shipment, worth [value] credits. [cargo_budget.account_balance] credits left.", INVESTIGATE_CARGO)

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_RESUPPLY)

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
