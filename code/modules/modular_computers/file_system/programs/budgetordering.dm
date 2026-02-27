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

	// Cargo items
	for(var/item_type in SSsupply.cargo_items)
		var/datum/cargo_item/item = SSsupply.cargo_items[item_type]
		if(!is_visible_pack(user, item.contraband) || item.hidden)
			continue
		if(!data["supplies"][item.category])
			data["supplies"][item.category] = list(
				"name" = item.category,
				"packs" = list()
			)
		if(item.DropPodOnly)
			continue
		data["supplies"][item.category]["packs"] += list(list(
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
		if(!data["supplies"][crate.category])
			data["supplies"][crate.category] = list(
				"name" = crate.category,
				"packs" = list()
			)
		if((crate.special && !crate.special_enabled) || crate.DropPodOnly)
			continue
		data["supplies"][crate.category]["packs"] += list(list(
			"name" = crate.name,
			"cost" = crate.cost,
			"supply" = crate.current_supply,
			"id" = crate_type,
			"desc" = crate.desc || crate.name,
			"access" = crate.access
		))

	// Legacy supply packs
	for(var/pack in SSsupply.supply_packs)
		var/datum/supply_pack/P = SSsupply.supply_packs[pack]
		if(!is_visible_pack(user, P.contraband) || P.hidden)
			continue
		if(!data["supplies"][P.group])
			data["supplies"][P.group] = list(
				"name" = P.group,
				"packs" = list()
			)
		if((P.hidden && (P.contraband && !contraband) || (P.special && !P.special_enabled) || P.DropPodOnly))
			continue
		data["supplies"][P.group]["packs"] += list(list(
			"name" = P.name,
			"cost" = P.cost,
			"supply" = P.current_supply,
			"id" = pack,
			"desc" = P.desc || P.name,
			"access" = P.access
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

/// Returns the batch items list and crate breakdown for the UI.
/datum/computer_file/program/budgetorders/proc/get_batch_data()
	var/list/batch_data = list()
	batch_data["items"] = list()
	batch_data["total_cost"] = 0
	batch_data["crates"] = list()
	batch_data["item_count"] = 0

	if(!length(batch))
		return batch_data

	var/total_cost = 0
	var/total_items = 0
	for(var/list/entry in batch)
		var/pack_id = entry["pack_id"]
		var/quantity = entry["quantity"]
		var/list/product_info = SSsupply.get_product(pack_id)
		if(!product_info)
			continue
		var/datum/product = product_info["datum"]
		var/p_cost = 0
		var/p_name = ""
		var/p_small = FALSE
		var/p_supply = 0
		if(istype(product, /datum/cargo_item))
			var/datum/cargo_item/item = product
			p_cost = item.cost
			p_name = item.name
			p_small = item.small_item
			p_supply = item.current_supply
		else if(istype(product, /datum/cargo_crate))
			var/datum/cargo_crate/crate = product
			p_cost = crate.cost
			p_name = crate.name
			p_small = crate.small_item
			p_supply = crate.current_supply
		else if(istype(product, /datum/supply_pack))
			var/datum/supply_pack/legacy = product
			p_cost = legacy.cost
			p_name = legacy.name
			p_small = legacy.small_item
			p_supply = legacy.current_supply
		var/entry_cost = p_cost * quantity
		if(self_paid)
			entry_cost = round(entry_cost * 1.1)
		total_cost += entry_cost
		total_items += quantity
		batch_data["items"] += list(list(
			"pack_id" = "[pack_id]",
			"name" = p_name,
			"cost" = p_cost,
			"quantity" = quantity,
			"entry_cost" = entry_cost,
			"small_item" = p_small,
			"supply" = p_supply
		))

	batch_data["total_cost"] = total_cost
	batch_data["item_count"] = total_items
	batch_data["crates"] = calculate_crate_breakdown()
	return batch_data

/// Calculates how the current batch would be broken down into crates.
/datum/computer_file/program/budgetorders/proc/calculate_crate_breakdown()
	var/list/crates = list()
	var/list/small_items = list()
	var/list/regular_items = list()

	for(var/list/entry in batch)
		var/pack_id = entry["pack_id"]
		var/quantity = entry["quantity"]
		var/list/product_info = SSsupply.get_product(pack_id)
		if(!product_info)
			continue
		var/datum/product = product_info["datum"]
		var/p_small = FALSE
		var/p_name = ""
		if(istype(product, /datum/cargo_item))
			var/datum/cargo_item/item = product
			p_small = item.small_item
			p_name = item.name
		else if(istype(product, /datum/cargo_crate))
			var/datum/cargo_crate/crate = product
			p_small = crate.small_item
			p_name = crate.name
		else if(istype(product, /datum/supply_pack))
			var/datum/supply_pack/legacy = product
			p_small = legacy.small_item
			p_name = legacy.name
		if(p_small)
			small_items += list(list("name" = p_name, "quantity" = quantity))
		else
			for(var/i in 1 to quantity)
				regular_items += list(p_name)

	var/crate_index = 0
	for(var/item_name in regular_items)
		crate_index++
		crates += list(list(
			"crate_name" = "Crate [crate_index]",
			"contents" = list(item_name),
			"count" = 1
		))

	if(length(small_items))
		var/list/small_queue = list()
		for(var/list/item in small_items)
			for(var/i in 1 to item["quantity"])
				small_queue += item["name"]

		var/crate_count = 0
		while(length(small_queue) > 0)
			var/list/crate_contents = list()
			var/take_count = min(10, length(small_queue))
			for(var/i in 1 to take_count)
				crate_contents += small_queue[1]
				small_queue.Cut(1, 2)
			crate_count++
			crate_index++
			crates += list(list(
				"crate_name" = "Crate [crate_index] (Small Items #[crate_count])",
				"contents" = crate_contents,
				"count" = length(crate_contents)
			))

	return crates

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
			else if(istype(product, /datum/supply_pack))
				var/datum/supply_pack/legacy = product
				p_hidden = legacy.hidden
				p_contraband = legacy.contraband
				p_droppod = legacy.DropPodOnly
				p_access_budget = legacy.access_budget
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
			else if(istype(product, /datum/supply_pack))
				var/datum/supply_pack/legacy = product
				p_hidden = legacy.hidden
				p_contraband = legacy.contraband
				p_droppod = legacy.DropPodOnly
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
			quantity = clamp(round(quantity), 1, 20)
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
						else if(istype(batch_product, /datum/supply_pack))
							var/datum/supply_pack/legacy = batch_product
							bp_access_budget = legacy.access_budget
							bp_name = legacy.name
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
