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
			"desc" = P.desc || P.name, // If there is a description, use it. Otherwise use the pack's name.
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
		data["cart"] += list(list(
			"object" = SO.pack.name,
			"cost" = SO.pack.cost,
			"supply" = SO.pack.current_supply,
			"id" = SO.id,
			"orderer" = SO.orderer,
			"paid" = !isnull(SO.paying_account), //paid by requester
			"contents" = SO.pack.get_contents_readable()
		))

	data["requests"] = list()
	for(var/datum/supply_order/SO in SSsupply.requestlist)
		data["requests"] += list(list(
			"object" = SO.pack.name,
			"cost" = SO.pack.cost,
			"supply" = SO.pack.current_supply,
			"orderer" = SO.orderer,
			"reason" = SO.reason,
			"id" = SO.id,
			"contents" = SO.pack.get_contents_readable()
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
		var/datum/supply_pack/pack = SSsupply.supply_packs[pack_id]
		if(!pack)
			continue
		var/entry_cost = pack.cost * quantity
		if(self_paid)
			entry_cost = round(entry_cost * 1.1)
		total_cost += entry_cost
		total_items += quantity
		batch_data["items"] += list(list(
			"pack_id" = "[pack_id]",
			"name" = pack.name,
			"cost" = pack.cost,
			"quantity" = quantity,
			"entry_cost" = entry_cost,
			"small_item" = pack.small_item,
			"crate_name" = pack.crate_name,
			"supply" = pack.current_supply
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
		var/datum/supply_pack/pack = SSsupply.supply_packs[pack_id]
		if(!pack)
			continue
		if(pack.small_item)
			small_items += list(list("name" = pack.name, "crate_name" = pack.crate_name, "quantity" = quantity))
		else
			for(var/i in 1 to quantity)
				regular_items += list(list("name" = pack.name, "crate_name" = pack.crate_name))

	for(var/list/item in regular_items)
		crates += list(list(
			"crate_name" = item["crate_name"],
			"contents" = list(item["name"]),
			"count" = 1
		))

	if(length(small_items))
		var/list/small_queue = list()
		for(var/list/item in small_items)
			for(var/i in 1 to item["quantity"])
				small_queue += list(list("name" = item["name"], "crate_name" = item["crate_name"]))

		var/list/by_crate_type = list()
		for(var/list/item in small_queue)
			var/ctype = item["crate_name"]
			if(!by_crate_type[ctype])
				by_crate_type[ctype] = list()
			by_crate_type[ctype] += list(item["name"])

		for(var/ctype in by_crate_type)
			var/list/items_of_type = by_crate_type[ctype]
			var/crate_count = 0
			while(length(items_of_type) > 0)
				var/list/crate_contents = list()
				var/take_count = min(10, length(items_of_type))
				for(var/i in 1 to take_count)
					crate_contents += items_of_type[1]
					items_of_type.Cut(1, 2)
				crate_count++
				crates += list(list(
					"crate_name" = "[ctype] (Small Items #[crate_count])",
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
			var/datum/supply_pack/pack = SSsupply.supply_packs[id]
			if(!istype(pack))
				return
			if((pack.hidden && (pack.contraband && !contraband) || pack.DropPodOnly))
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
				if(!(computer.obj_flags & EMAGGED) && pack.access_budget && !(pack.access_budget in access))
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


			var/turf/T = get_turf(src)
			var/datum/supply_order/SO = new(pack, name, rank, ckey, reason, account)
			SO.generateRequisition(T)
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
			var/datum/supply_pack/pack = SSsupply.supply_packs[id]
			if(!istype(pack))
				return
			if((pack.hidden && (pack.contraband && !contraband) || pack.DropPodOnly))
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
						var/datum/supply_pack/pack = SSsupply.supply_packs[entry["pack_id"]]
						if(pack?.access_budget && !(pack.access_budget in access))
							computer.say("Insufficient access on [id_card] for [pack.name].")
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

			var/turf/T = get_turf(src)
			for(var/list/entry in batch)
				var/pack_id = entry["pack_id"]
				var/quantity = entry["quantity"]
				var/datum/supply_pack/pack = SSsupply.supply_packs[pack_id]
				if(!pack)
					continue
				for(var/i in 1 to quantity)
					var/datum/supply_order/SO = new(pack, name, rank, ckey, reason, account)
					SO.generateRequisition(T)
					if((requestonly && !self_paid) || !(get_buyer_id(usr)))
						SSsupply.requestlist += SO
					else
						SSsupply.shoppinglist += SO
						if(self_paid)
							computer.say("Order processed. The price will be charged to [account.account_holder]'s bank account on delivery.")
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
