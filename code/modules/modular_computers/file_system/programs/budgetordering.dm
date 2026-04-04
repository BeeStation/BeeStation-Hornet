/datum/computer_file/program/budgetorders
	filename = "orderapp"
	filedesc = "Nanotrasen Internal Requisition Network (NIRN)"
	category = PROGRAM_CATEGORY_SUPL
	program_icon_state = "request"
	extended_desc = "A request network that utilizes the Nanotrasen Ordering network to purchase supplies using a department budget account."
	requires_ntnet = TRUE
	size = 10
	tgui_id = "NtosCargo"
	program_icon = "credit-card"
	power_consumption = 40 WATT
	//Are you actually placing orders with it?
	var/requestonly = TRUE
	//Can the tablet see or buy illegal stuff?
	var/contraband = FALSE
	//Is it being bought from a personal account, or is it being done via a budget/cargo?
	var/self_paid = FALSE
	//Can this console approve purchase requests?
	var/can_approve_requests = FALSE
	//What do we say when the shuttle moves with living beings on it.
	var/safety_warning = "For safety and ethical reasons, the automated supply shuttle \
		cannot transport live organisms, human remains, classified nuclear weaponry, \
		homing beacons, mail, or machinery housing any form of artificial intelligence."
	//If you're being raided by pirates, what do you tell the crew?
	var/blockade_warning = "Bluespace instability detected. Shuttle movement impossible."
	/// The current batch of items being assembled before confirming an order.
	var/list/batch = list()

/datum/computer_file/program/budgetorders/proc/get_export_categories()
	return EXPORT_CARGO

/datum/computer_file/program/budgetorders/proc/get_buyer_id(mob/user) //gets access from id on person or inserted one
	var/obj/item/card/id/id
	if(ishuman(user))
		var/mob/living/carbon/human/U = user
		id = U.get_idcard(TRUE)
	else if(computer)
		var/obj/item/computer_hardware/card_slot/card_slot = computer.all_components[MC_CARD]
		id = card_slot?.GetID()
	return id ? id : FALSE

/datum/computer_file/program/budgetorders/proc/is_visible_pack(mob/user, contraband)
	if(issilicon(user)) //Borgs can't buy things.
		return FALSE
	if(computer.obj_flags & EMAGGED)
		return TRUE
	else if(contraband) //Hide contraband when non-emagged.
		return FALSE

	return TRUE

/datum/computer_file/program/budgetorders/ui_data(mob/user)
	var/list/data = list()
	data["location"] = SSshuttle.supply.getStatusText()
	var/datum/bank_account/buyer = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
	var/obj/item/card/id/id_card = get_buyer_id(user)
	if(get_buyer_id(user))
		if((ACCESS_QM in id_card.access) || (ACCESS_HEADS in id_card.access))
			requestonly = FALSE
			buyer = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
			can_approve_requests = TRUE
		else
			requestonly = TRUE
			can_approve_requests = FALSE
	else
		requestonly = TRUE
	if(isnull(buyer))
		buyer = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
	else if(SSeconomy.is_nonstation_account(buyer))
		buyer = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
	if(buyer)
		data["points"] = buyer.account_balance

//Otherwise static data, that is being applied in ui_data as the crates visible and buyable are not static
	data["requestonly"] = requestonly
	data["supplies"] = list()
	data["batch_constants"] = get_batch_pricing_constants()

	// Cargo items
	for(var/item_type in SSsupply.cargo_items)
		var/datum/cargo_item/item = SSsupply.cargo_items[item_type]
		if(!is_visible_pack(user, item.contraband) || item.hidden)
			continue
		if(item.DropPodOnly)
			continue
		data["supplies"] += list(list(
			"name" = item.name,
			"cost" = item.cost,
			"supply" = item.current_supply,
			"id" = item_type,
			"desc" = item.desc || item.name,
			"access" = item.access
		))

	// Cargo crates
	for(var/crate_type in SSsupply.cargo_crates)
		var/datum/cargo_crate/crate = SSsupply.cargo_crates[crate_type]
		if(!is_visible_pack(user, crate.contraband) || crate.hidden)
			continue
		if((crate.special && !crate.special_enabled) || crate.DropPodOnly)
			continue
		data["supplies"] += list(list(
			"name" = crate.name,
			"cost" = crate.cost,
			"supply" = crate.current_supply,
			"id" = crate_type,
			"desc" = crate.desc || crate.name,
			"access" = crate.access
		))

//Data regarding the User's capability to buy things.
	data["has_id"] = id_card
	data["away"] = SSshuttle.supply.getDockedId() == "supply_away"
	data["self_paid"] = self_paid
	data["docked"] = SSshuttle.supply.mode == SHUTTLE_IDLE
	data["loan"] = !!SSshuttle.shuttle_loan
	data["loan_dispatched"] = SSshuttle.shuttle_loan && SSshuttle.shuttle_loan.dispatched
	data["can_send"] = FALSE	//There is no situation where I want the app to be able to send the shuttle AWAY from the station, but conversely is fine.
	data["can_approve_requests"] = can_approve_requests
	data["app_cost"] = TRUE
	var/message = "Remember to stamp and send back the supply manifests."
	if(SSshuttle.centcom_message)
		message = SSshuttle.centcom_message
	if(SSshuttle.supplyBlocked)
		message = blockade_warning
	data["message"] = message
	data["cart"] = list()
	for(var/datum/supply_order/SO in SSsupply.shoppinglist)
		if(istype(SO, /datum/supply_order/batch))
			var/datum/supply_order/batch/BO = SO
			data["cart"] += list(list(
				"object" = BO.pack_name,
				"cost" = BO.total_cost,
				"id" = BO.id,
				"orderer" = BO.orderer,
				"paid" = !isnull(BO.paying_account),
				"contents" = BO.get_batch_contents_readable(),
				"is_batch" = TRUE,
				"crate_count" = BO.crate_count,
				"total_items" = BO.total_items
			))
			continue
		data["cart"] += list(list(
			"object" = SO.pack_name,
			"cost" = SO.pack_cost,
			"supply" = get_product_supply(SO.pack),
			"id" = SO.id,
			"orderer" = SO.orderer,
			"paid" = !isnull(SO.paying_account),
			"contents" = list()
		))

	data["requests"] = list()
	for(var/datum/supply_order/SO in SSsupply.requestlist)
		if(istype(SO, /datum/supply_order/batch))
			var/datum/supply_order/batch/BO = SO
			data["requests"] += list(list(
				"object" = BO.pack_name,
				"cost" = BO.total_cost,
				"orderer" = BO.orderer,
				"reason" = BO.reason,
				"id" = BO.id,
				"contents" = BO.get_batch_contents_readable(),
				"is_batch" = TRUE,
				"crate_count" = BO.crate_count,
				"total_items" = BO.total_items
			))
			continue
		data["requests"] += list(list(
			"object" = SO.pack_name,
			"cost" = SO.pack_cost,
			"supply" = get_product_supply(SO.pack),
			"orderer" = SO.orderer,
			"reason" = SO.reason,
			"id" = SO.id,
			"contents" = list()
		))

	// Batch data
	data["batch"] = get_batch_data()

	return data

/// Returns the batch items list, crate breakdown, and pricing modifiers for the UI.
/datum/computer_file/program/budgetorders/proc/get_batch_data()
	var/list/batch_data = list()
	batch_data["items"] = list()
	batch_data["total_cost"] = 0
	batch_data["base_cost"] = 0
	batch_data["crates"] = list()
	batch_data["item_count"] = 0
	batch_data["surcharge"] = 0
	batch_data["bulk_discount_pct"] = 0
	batch_data["crate_cost"] = 0
	batch_data["self_paid_pct"] = 0
	batch_data["avg_crate_fill"] = 0

	if(!length(batch))
		return batch_data

	var/base_cost = 0
	var/total_items = 0
	var/list/temp_entries = list()
	for(var/list/entry in batch)
		var/pack_id = entry["pack_id"]
		var/quantity = entry["quantity"]
		var/list/product_info = SSsupply.get_product(pack_id)
		if(!product_info)
			continue
		var/datum/product = product_info["datum"]
		var/p_cost = get_product_cost(product)
		var/p_name = get_product_name(product)
		var/p_crate_type = get_product_crate_type(product)
		var/p_supply = get_product_supply(product)
		var/entry_base = p_cost * quantity
		base_cost += entry_base
		total_items += quantity
		temp_entries += list(list("pack" = product, "quantity" = quantity, "cost" = p_cost))
		batch_data["items"] += list(list(
			"pack_id" = "[pack_id]",
			"name" = p_name,
			"cost" = p_cost,
			"quantity" = quantity,
			"entry_cost" = entry_base,
			"crate_type" = get_crate_type_name(p_crate_type),
			"supply" = p_supply
		))

	batch_data["base_cost"] = base_cost
	batch_data["item_count"] = total_items

	// Calculate crate breakdown
	var/list/crate_data = calculate_batch_crates(temp_entries)
	var/list/ui_crates = list()
	var/crate_idx = 0
	for(var/list/crate in crate_data)
		crate_idx++
		ui_crates += list(list(
			"crate_name" = "Crate [crate_idx]: [crate["crate_name"]]",
			"contents" = crate["items"],
			"count" = crate["count"],
			"slots_used" = crate["slots_used"],
			"crate_type_name" = crate["crate_name"],
			"crate_cost" = crate["crate_cost"]
		))
	batch_data["crates"] = ui_crates

	// Calculate pricing modifiers
	var/list/modifiers = calculate_batch_pricing(base_cost, total_items, crate_data, self_paid)
	batch_data["surcharge"] = modifiers["surcharge"]
	batch_data["bulk_discount_pct"] = round(modifiers["bulk_discount"] * 100, 0.1)
	batch_data["crate_cost"] = modifiers["crate_cost"]
	batch_data["self_paid_pct"] = self_paid ? BATCH_SELF_PAID_PCT : 0
	batch_data["total_cost"] = modifiers["final_cost"]

	if(length(crate_data))
		var/total_fill = 0
		for(var/list/crate in crate_data)
			total_fill += crate["slots_used"]
		batch_data["avg_crate_fill"] = round((total_fill / length(crate_data)) / BATCH_CRATE_MAX_ITEMS * 100, 1)

	return batch_data

/datum/computer_file/program/budgetorders/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	switch(action)
		if("send")
			if(!SSshuttle.supply.canMove())
				computer.say(safety_warning)
				return
			if(SSshuttle.supplyBlocked)
				computer.say(blockade_warning)
				return
			if(SSshuttle.supply.getDockedId() == "supply_home")
				SSshuttle.supply.export_categories = get_export_categories()
				SSshuttle.moveShuttle("supply", "supply_away", TRUE)
				computer.say("The supply shuttle is departing.")
				usr.investigate_log("sent the supply shuttle away.", INVESTIGATE_CARGO)
			else
				usr.investigate_log("called the supply shuttle.", INVESTIGATE_CARGO)
				computer.say("The supply shuttle has been called and will arrive in [SSshuttle.supply.timeLeft(600)] minutes.")
				SSshuttle.moveShuttle("supply", "supply_home", TRUE)
				generate_order_summary(get_turf(computer))
			. = TRUE
		if("loan")
			if(!SSshuttle.shuttle_loan)
				return
			if(SSshuttle.supplyBlocked)
				computer.say(blockade_warning)
				return
			else if(SSshuttle.supply.mode != SHUTTLE_IDLE)
				return
			else if(SSshuttle.supply.getDockedId() != "supply_away")
				return
			else
				SSshuttle.shuttle_loan.loan_shuttle()
				computer.say("The supply shuttle has been loaned to CentCom.")
				usr.investigate_log("accepted a shuttle loan event.", INVESTIGATE_CARGO)
				log_game("[key_name(usr)] accepted a shuttle loan event.")
				. = TRUE
		if("add")
			var/id = text2path(params["id"])
			var/list/product_info = SSsupply.get_product(id)
			if(!product_info)
				return
			var/datum/product = product_info["datum"]

			// Stock check - cannot order more than available supply
			if(get_product_supply(product) <= 0)
				computer.say("Out of stock.")
				return

			// Visibility checks
			var/p_hidden = FALSE
			var/p_contraband = FALSE
			var/p_droppod = FALSE
			var/p_access_budget = FALSE
			if(istype(product, /datum/cargo_item))
				var/datum/cargo_item/item = product
				p_hidden = item.hidden
				p_contraband = item.contraband
				p_droppod = item.DropPodOnly
				p_access_budget = item.access_budget
			else if(istype(product, /datum/cargo_crate))
				var/datum/cargo_crate/crate = product
				p_hidden = crate.hidden
				p_contraband = crate.contraband
				p_droppod = crate.DropPodOnly
				p_access_budget = crate.access_budget
			if((p_hidden && (p_contraband && !contraband) || p_droppod))
				return

			var/name = "*None Provided*"
			var/rank = "*None Provided*"
			var/ckey = usr.ckey
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				name = H.get_authentification_name()
				rank = H.get_assignment(hand_first = TRUE)
			else if(issilicon(usr))
				name = usr.real_name
				rank = "Silicon"

			var/datum/bank_account/account
			if(self_paid && ishuman(usr))
				var/obj/item/card/id/id_card = get_buyer_id(usr)
				if(!istype(id_card))
					computer.say("No ID card detected.")
					return
				if(istype(id_card, /obj/item/card/id/departmental_budget))
					computer.say("The application rejects [id_card].")
					return
				account = id_card.registered_account
				if(!istype(account))
					computer.say("Invalid bank account.")
					return

			var/reason = ""
			if((requestonly && !self_paid) || !(get_buyer_id(usr)))
				reason = stripped_input("Reason:", name, "")
				if(isnull(reason) || ..())
					return

			if(!self_paid && ishuman(usr) && !account)
				var/obj/item/card/id/id_card = get_buyer_id(usr)
				if(!istype(id_card))
					computer.say("No ID card detected.")
					return
				var/access = id_card.GetAccess()
				if(!(computer.obj_flags & EMAGGED) && p_access_budget && !(p_access_budget in access))
					computer.say("Insufficient access on [id_card].")
					return
				if(istype(id_card, /obj/item/card/id/departmental_budget))
					computer.say("The application rejects [id_card].")
					return
				else
					account = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
					if(isnull(account))
						computer.say("The application failed to identify [id_card].")
						return
					else if(SSeconomy.is_nonstation_account(account))
						computer.say("The application rejects [id_card].")
						return


			var/datum/supply_order/SO = new(product, name, rank, ckey, reason, account)
			if((requestonly && !self_paid) || !(get_buyer_id(usr)))
				SSsupply.requestlist += SO
			else
				SSsupply.shoppinglist += SO
				if(self_paid)
					computer.say("Order processed. The price will be charged to [account.account_holder]'s bank account on delivery.")
			. = TRUE
		if("remove")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSsupply.shoppinglist)
				if(SO.id == id)
					SSsupply.shoppinglist -= SO
					. = TRUE
					break
		if("clear")
			SSsupply.shoppinglist.Cut()
			. = TRUE
		if("approve")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSsupply.requestlist)
				if(SO.id == id)
					var/obj/item/card/id/id_card = get_buyer_id(usr)
					if(id_card && id_card?.registered_account)
						SO.paying_account = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
					if(SSeconomy.is_nonstation_account(SO.paying_account))
						return
					SSsupply.requestlist -= SO
					SSsupply.shoppinglist += SO
					. = TRUE
					break
		if("deny")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSsupply.requestlist)
				if(SO.id == id)
					SSsupply.requestlist -= SO
					. = TRUE
					break
		if("denyall")
			SSsupply.requestlist.Cut()
			. = TRUE
		if("toggleprivate")
			self_paid = !self_paid
			. = TRUE
		if("batch_add")
			var/id = text2path(params["id"])
			var/list/product_info = SSsupply.get_product(id)
			if(!product_info)
				return
			var/datum/product = product_info["datum"]
			// Stock check - cannot add more than available supply
			var/available_stock = get_product_supply(product)
			var/already_in_batch = 0
			for(var/list/existing in batch)
				if(existing["pack_id"] == id)
					already_in_batch = existing["quantity"]
					break
			if(already_in_batch >= available_stock)
				computer.say("Not enough stock available.")
				return
			var/p_hidden = FALSE
			var/p_contraband = FALSE
			var/p_droppod = FALSE
			if(istype(product, /datum/cargo_item))
				var/datum/cargo_item/item = product
				p_hidden = item.hidden
				p_contraband = item.contraband
				p_droppod = item.DropPodOnly
			else if(istype(product, /datum/cargo_crate))
				var/datum/cargo_crate/crate = product
				p_hidden = crate.hidden
				p_contraband = crate.contraband
				p_droppod = crate.DropPodOnly
			if((p_hidden && (p_contraband && !contraband) || p_droppod))
				return
			for(var/list/entry in batch)
				if(entry["pack_id"] == id)
					entry["quantity"] += 1
					. = TRUE
					return
			batch += list(list("pack_id" = id, "quantity" = 1))
			. = TRUE
		if("batch_remove")
			var/id = text2path(params["id"])
			for(var/list/entry in batch)
				if(entry["pack_id"] == id)
					entry["quantity"] -= 1
					if(entry["quantity"] <= 0)
						batch -= list(entry)
					. = TRUE
					break
		if("batch_set_quantity")
			var/id = text2path(params["id"])
			var/quantity = text2num(params["quantity"])
			if(!quantity || quantity < 0)
				return
			// Clamp to stock limit
			var/list/product_info = SSsupply.get_product(id)
			var/max_stock = 20
			if(product_info)
				max_stock = get_product_supply(product_info["datum"])
			quantity = clamp(round(quantity), 1, max_stock)
			for(var/list/entry in batch)
				if(entry["pack_id"] == id)
					entry["quantity"] = quantity
					. = TRUE
					break
		if("batch_remove_all")
			var/id = text2path(params["id"])
			for(var/list/entry in batch)
				if(entry["pack_id"] == id)
					batch -= list(entry)
					. = TRUE
					break
		if("batch_clear")
			batch.Cut()
			. = TRUE
		if("batch_confirm")
			if(!length(batch))
				return
			var/name = "*None Provided*"
			var/rank = "*None Provided*"
			var/ckey = usr.ckey
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				name = H.get_authentification_name()
				rank = H.get_assignment(hand_first = TRUE)
			else if(issilicon(usr))
				name = usr.real_name
				rank = "Silicon"

			var/datum/bank_account/account
			if(self_paid && ishuman(usr))
				var/obj/item/card/id/id_card = get_buyer_id(usr)
				if(!istype(id_card))
					computer.say("No ID card detected.")
					return
				if(istype(id_card, /obj/item/card/id/departmental_budget))
					computer.say("The application rejects [id_card].")
					return
				account = id_card.registered_account
				if(!istype(account))
					computer.say("Invalid bank account.")
					return

			var/reason = ""
			if((requestonly && !self_paid) || !(get_buyer_id(usr)))
				reason = stripped_input("Reason:", name, "")
				if(isnull(reason) || ..())
					return

			if(!self_paid && ishuman(usr) && !account)
				var/obj/item/card/id/id_card = get_buyer_id(usr)
				if(!istype(id_card))
					computer.say("No ID card detected.")
					return
				var/access = id_card.GetAccess()
				if(!(computer.obj_flags & EMAGGED))
					for(var/list/entry in batch)
						var/list/batch_product_info = SSsupply.get_product(entry["pack_id"])
						if(!batch_product_info)
							continue
						var/datum/batch_product = batch_product_info["datum"]
						var/bp_access_budget = FALSE
						var/bp_name = ""
						if(istype(batch_product, /datum/cargo_item))
							var/datum/cargo_item/item = batch_product
							bp_access_budget = item.access_budget
							bp_name = item.name
						else if(istype(batch_product, /datum/cargo_crate))
							var/datum/cargo_crate/crate = batch_product
							bp_access_budget = crate.access_budget
							bp_name = crate.name
						if(bp_access_budget && !(bp_access_budget in access))
							computer.say("Insufficient access on [id_card] for [bp_name].")
							return
				if(istype(id_card, /obj/item/card/id/departmental_budget))
					computer.say("The application rejects [id_card].")
					return
				else
					account = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
					if(isnull(account))
						computer.say("The application failed to identify [id_card].")
						return
					else if(SSeconomy.is_nonstation_account(account))
						computer.say("The application rejects [id_card].")
						return

			// Create a single batch order containing all items
			var/datum/supply_order/batch/BO = new(batch, name, rank, ckey, reason, account, self_paid)
			if((requestonly && !self_paid) || !(get_buyer_id(usr)))
				SSsupply.requestlist += BO
			else
				SSsupply.shoppinglist += BO
				if(self_paid)
					computer.say("Batch order processed. The price will be charged to [account.account_holder]'s bank account on delivery.")
			batch.Cut()
			. = TRUE
	if(.)
		post_signal("supply")

/datum/computer_file/program/budgetorders/proc/post_signal(command)

	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

	if(!frequency)
		return

	var/datum/signal/status_signal = new(list("command" = command))
	frequency.post_signal(src, status_signal)
