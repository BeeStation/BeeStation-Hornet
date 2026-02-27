/obj/machinery/computer/cargo
	name = "supply console"
	desc = "Used to order supplies, approve requests, and control the shuttle."
	icon_screen = "supply"
	circuit = /obj/item/circuitboard/computer/cargo

	//Can the supply console send the shuttle back and forth? Used in the UI backend.
	var/can_send = TRUE
	var/requestonly = FALSE
	//Can you approve requests placed for cargo? Works differently between the app and the computer.
	var/can_approve_requests = TRUE
	var/contraband = FALSE
	var/self_paid = FALSE
	var/safety_warning = "For safety and ethical reasons, the automated supply shuttle \
		cannot transport live organisms, human remains, classified nuclear weaponry, \
		homing beacons, mail, or machinery housing any form of artificial intelligence."
	var/blockade_warning = "Bluespace instability detected. Shuttle movement impossible."
	/// radio used by the console to send messages on supply channel
	var/obj/item/radio/headset/radio
	/// var that tracks message cooldown
	var/message_cooldown
	COOLDOWN_DECLARE(order_cooldown)

	light_color = "#E2853D"//orange

	/// The current batch of items being assembled before confirming an order.
	/// Each entry is an assoc list with "pack_id" (type path) and "quantity".
	var/list/batch = list()

/obj/machinery/computer/cargo/request
	name = "supply request console"
	desc = "Used to request supplies from cargo."
	icon_screen = "request"
	circuit = /obj/item/circuitboard/computer/cargo/request
	can_send = FALSE
	can_approve_requests = FALSE
	requestonly = TRUE

/obj/machinery/computer/cargo/Initialize(mapload)
	. = ..()
	radio = new /obj/item/radio/headset/headset_cargo(src)
	RegisterSignal(SSdcs, COMSIG_GLOB_RESUPPLY, PROC_REF(update_static_ui))

/obj/machinery/computer/cargo/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/machinery/computer/cargo/proc/update_static_ui()
	for (var/datum/tgui/open_window as() in SStgui.get_all_open_uis(src))
		update_static_data(null, open_window)

/obj/machinery/computer/cargo/proc/get_export_categories()
	. = EXPORT_CARGO
	if(contraband)
		. |= EXPORT_CONTRABAND

/obj/machinery/computer/cargo/on_emag(mob/user)
	..()
	user?.visible_message(span_warning("[user] swipes a suspicious card through [src]!"),
		span_notice("You adjust [src]'s routing and receiver spectrum, unlocking special supplies and contraband."))

	contraband = TRUE

	// This also permamently sets this on the circuit board
	var/obj/item/circuitboard/computer/cargo/board = circuit
	board.contraband = TRUE
	board.obj_flags |= EMAGGED
	update_static_data(user)

/obj/machinery/computer/cargo/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/cargo/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Cargo")
		ui.open()
		ui.set_autoupdate(TRUE) // Account balance, shuttle status

/obj/machinery/computer/cargo/ui_data()
	var/list/data = list()
	data["location"] = SSshuttle.supply.getStatusText()
	var/datum/bank_account/D = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
	if(D)
		data["points"] = D.account_balance
	data["away"] = SSshuttle.supply.getDockedId() == "supply_away"
	data["self_paid"] = self_paid
	data["docked"] = SSshuttle.supply.mode == SHUTTLE_IDLE
	data["loan"] = !!SSshuttle.shuttle_loan
	data["loan_dispatched"] = SSshuttle.shuttle_loan && SSshuttle.shuttle_loan.dispatched
	data["can_send"] = can_send
	data["can_approve_requests"] = can_approve_requests
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
		var/list/contents_readable = list()
		var/order_cost = 0
		var/order_supply = 0
		if(istype(SO.pack, /datum/cargo_item))
			var/datum/cargo_item/item = SO.pack
			contents_readable = item.get_contents_readable()
			order_cost = item.get_cost()
			order_supply = item.current_supply
		else if(istype(SO.pack, /datum/cargo_crate))
			var/datum/cargo_crate/crate = SO.pack
			contents_readable = crate.get_contents_readable()
			order_cost = crate.get_cost()
			order_supply = crate.current_supply
		else if(istype(SO.pack, /datum/supply_pack))
			var/datum/supply_pack/legacy = SO.pack
			contents_readable = legacy.get_contents_readable()
			order_cost = legacy.get_cost()
			order_supply = legacy.current_supply
		data["cart"] += list(list(
			"object" = SO.pack_name,
			"cost" = order_cost,
			"supply" = order_supply,
			"id" = SO.id,
			"orderer" = SO.orderer,
			"paid" = !isnull(SO.paying_account),
			"contents" = contents_readable
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
		var/list/req_contents = list()
		var/req_cost = 0
		var/req_supply = 0
		if(istype(SO.pack, /datum/cargo_item))
			var/datum/cargo_item/item = SO.pack
			req_contents = item.get_contents_readable()
			req_cost = item.get_cost()
			req_supply = item.current_supply
		else if(istype(SO.pack, /datum/cargo_crate))
			var/datum/cargo_crate/crate = SO.pack
			req_contents = crate.get_contents_readable()
			req_cost = crate.get_cost()
			req_supply = crate.current_supply
		else if(istype(SO.pack, /datum/supply_pack))
			var/datum/supply_pack/legacy = SO.pack
			req_contents = legacy.get_contents_readable()
			req_cost = legacy.get_cost()
			req_supply = legacy.current_supply
		data["requests"] += list(list(
			"object" = SO.pack_name,
			"cost" = req_cost,
			"supply" = req_supply,
			"orderer" = SO.orderer,
			"reason" = SO.reason,
			"id" = SO.id,
			"contents" = req_contents
		))

	// Batch data
	data["batch"] = get_batch_data()

	return data

/// Returns the batch items list and crate breakdown for the UI.
/obj/machinery/computer/cargo/proc/get_batch_data()
	var/list/batch_data = list()
	batch_data["items"] = list()
	batch_data["total_cost"] = 0
	batch_data["crates"] = list()
	batch_data["item_count"] = 0

	if(!length(batch))
		return batch_data

	// Build item list for UI
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
			p_cost = item.get_cost()
			p_name = item.name
			p_small = item.small_item
			p_supply = item.current_supply
		else if(istype(product, /datum/cargo_crate))
			var/datum/cargo_crate/crate = product
			p_cost = crate.get_cost()
			p_name = crate.name
			p_small = crate.small_item
			p_supply = crate.current_supply
		else if(istype(product, /datum/supply_pack))
			var/datum/supply_pack/legacy = product
			p_cost = legacy.get_cost()
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

	// Calculate crate breakdown
	batch_data["crates"] = calculate_crate_breakdown()

	return batch_data

/// Calculates how the current batch would be broken down into crates.
/// Returns a list of crate info lists for the UI.
/obj/machinery/computer/cargo/proc/calculate_crate_breakdown()
	var/list/crates = list()
	// Separate small items and regular crate items
	var/list/small_items = list() // list of lists: (name, quantity)
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

	// Regular items: each gets its own crate
	var/crate_index = 0
	for(var/item_name in regular_items)
		crate_index++
		crates += list(list(
			"crate_name" = "Crate [crate_index]",
			"contents" = list(item_name),
			"count" = 1
		))

	// Small items: group into crates of up to 10
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

/obj/machinery/computer/cargo/ui_static_data(mob/user)
	var/list/data = list()
	data["requestonly"] = requestonly
	data["supplies"] = list()

	// --- Cargo items ---
	for(var/item_type in SSsupply.cargo_items)
		var/datum/cargo_item/item = SSsupply.cargo_items[item_type]
		if(!data["supplies"][item.category])
			data["supplies"][item.category] = list(
				"name" = item.category,
				"packs" = list()
			)
		if((item.hidden && !(obj_flags & EMAGGED)) || (item.contraband && !contraband) || item.DropPodOnly)
			continue
		data["supplies"][item.category]["packs"] += list(list(
			"name" = item.name,
			"cost" = item.get_cost(),
			"id" = item_type,
			"supply" = item.current_supply,
			"desc" = item.desc || item.name,
			"small_item" = item.small_item,
			"access" = item.access
		))

	// --- Cargo crates (show under "Packs" or their own category) ---
	for(var/crate_type in SSsupply.cargo_crates)
		var/datum/cargo_crate/crate = SSsupply.cargo_crates[crate_type]
		if(!data["supplies"][crate.category])
			data["supplies"][crate.category] = list(
				"name" = crate.category,
				"packs" = list()
			)
		if((crate.hidden && !(obj_flags & EMAGGED)) || (crate.contraband && !contraband) || (crate.special && !crate.special_enabled) || crate.DropPodOnly)
			continue
		data["supplies"][crate.category]["packs"] += list(list(
			"name" = crate.name,
			"cost" = crate.get_cost(),
			"id" = crate_type,
			"supply" = crate.current_supply,
			"desc" = crate.desc || crate.name,
			"small_item" = crate.small_item,
			"access" = crate.access
		))

	// --- Legacy supply packs (backwards compat, if any remain) ---
	for(var/pack in SSsupply.supply_packs)
		var/datum/supply_pack/P = SSsupply.supply_packs[pack]
		if(!data["supplies"][P.group])
			data["supplies"][P.group] = list(
				"name" = P.group,
				"packs" = list()
			)
		if((P.hidden && !(obj_flags & EMAGGED)) || (P.contraband && !contraband) || (P.special && !P.special_enabled) || P.DropPodOnly)
			continue
		data["supplies"][P.group]["packs"] += list(list(
			"name" = P.name,
			"cost" = P.get_cost(),
			"id" = pack,
			"supply" = P.current_supply,
			"desc" = P.desc || P.name,
			"small_item" = P.small_item,
			"access" = P.access
		))
	return data

/obj/machinery/computer/cargo/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	switch(action)
		if("send")
			if(!SSshuttle.supply.canMove())
				say(safety_warning)
				return
			if(SSshuttle.supplyBlocked)
				say(blockade_warning)
				return
			if(SSshuttle.supply.getDockedId() == "supply_home")
				SSshuttle.supply.export_categories = get_export_categories()
				SSshuttle.moveShuttle("supply", "supply_away", TRUE)
				say("The supply shuttle is departing.")
				usr.investigate_log(" sent the supply shuttle away.", INVESTIGATE_CARGO)
			else
				usr.investigate_log(" called the supply shuttle.", INVESTIGATE_CARGO)
				say("The supply shuttle has been called and will arrive in [SSshuttle.supply.timeLeft(600)] minutes.")
				SSshuttle.moveShuttle("supply", "supply_home", TRUE)
			. = TRUE
		if("loan")
			if(!SSshuttle.shuttle_loan)
				return
			if(SSshuttle.supplyBlocked)
				say(blockade_warning)
				return
			else if(SSshuttle.supply.mode != SHUTTLE_IDLE)
				return
			else if(SSshuttle.supply.getDockedId() != "supply_away")
				return
			else
				SSshuttle.shuttle_loan.loan_shuttle()
				say("The supply shuttle has been loaned to CentCom.")
				. = TRUE
		if("add")
			if(!COOLDOWN_FINISHED(src, order_cooldown))
				return
			var/id = text2path(params["id"])
			var/list/product_info = SSsupply.get_product(id)
			if(!product_info)
				return
			var/datum/product = product_info["datum"]

			// Visibility checks
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
			if((p_hidden && !(obj_flags & EMAGGED)) || (p_contraband && !contraband) || p_droppod)
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
				var/mob/living/carbon/human/H = usr
				var/obj/item/card/id/id_card = H.get_idcard(TRUE)
				if(!istype(id_card))
					say("No ID card detected.")
					return
				account = id_card.registered_account
				if(!istype(account))
					say("Invalid bank account.")
					return

			var/reason = ""
			if(requestonly && !self_paid)
				reason = stripped_input(usr, "Reason:", name, "")
				if(!reason)
					return
				if(CHAT_FILTER_CHECK(reason))
					to_chat(usr, span_warning("You cannot send a message that contains a word prohibited in IC chat!"))
					return

			var/datum/supply_order/SO = new(product, name, rank, ckey, reason, account)
			if(requestonly && !self_paid)
				SSsupply.requestlist += SO
			else
				SSsupply.shoppinglist += SO
				if(self_paid)
					say("Order processed. The price will be charged to [account.account_holder]'s bank account on delivery.")
			if(requestonly && message_cooldown < world.time)
				radio.talk_into(src, "A new order has been requested.", RADIO_CHANNEL_SUPPLY)
				message_cooldown = world.time + 30 SECONDS
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
			if(!COOLDOWN_FINISHED(src, order_cooldown))
				return
			var/id = text2path(params["id"])
			var/list/product_info = SSsupply.get_product(id)
			if(!product_info)
				return
			var/datum/product = product_info["datum"]
			// Visibility checks
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
			if((p_hidden && !(obj_flags & EMAGGED)) || (p_contraband && !contraband) || p_droppod)
				return
			// Check if this pack is already in the batch, if so increment quantity
			for(var/list/entry in batch)
				if(entry["pack_id"] == id)
					entry["quantity"] += 1
					. = TRUE
					return
			// Otherwise add a new entry
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
				var/mob/living/carbon/human/H = usr
				var/obj/item/card/id/id_card = H.get_idcard(TRUE)
				if(!istype(id_card))
					say("No ID card detected.")
					return
				account = id_card.registered_account
				if(!istype(account))
					say("Invalid bank account.")
					return

			var/reason = ""
			if(requestonly && !self_paid)
				reason = stripped_input(usr, "Reason:", name, "")
				if(!reason)
					return
				if(CHAT_FILTER_CHECK(reason))
					to_chat(usr, span_warning("You cannot send a message that contains a word prohibited in IC chat!"))
					return

			// Create a single batch order containing all items
			var/datum/supply_order/batch/BO = new(batch, name, rank, ckey, reason, account, self_paid)
			if(requestonly && !self_paid)
				SSsupply.requestlist += BO
			else
				SSsupply.shoppinglist += BO
				if(self_paid)
					say("Batch order processed. The price will be charged to [account.account_holder]'s bank account on delivery.")
			if(requestonly && message_cooldown < world.time)
				radio.talk_into(src, "A new batch order has been requested.", RADIO_CHANNEL_SUPPLY)
				message_cooldown = world.time + 30 SECONDS
			batch.Cut()
			. = TRUE
	if(.)
		post_signal("supply")

/obj/machinery/computer/cargo/proc/post_signal(command)

	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

	if(!frequency)
		return

	var/datum/signal/status_signal = new(list("command" = command))
	frequency.post_signal(src, status_signal)

/// Helper: get current_supply from any product datum type
/proc/get_product_supply(datum/product)
	if(istype(product, /datum/cargo_item))
		var/datum/cargo_item/item = product
		return item.current_supply
	if(istype(product, /datum/cargo_crate))
		var/datum/cargo_crate/crate = product
		return crate.current_supply
	if(istype(product, /datum/supply_pack))
		var/datum/supply_pack/legacy = product
		return legacy.current_supply
	return 0

/// Helper: adjust current_supply on any product datum type
/proc/adjust_product_supply(datum/product, amount)
	if(istype(product, /datum/cargo_item))
		var/datum/cargo_item/item = product
		item.current_supply += amount
	else if(istype(product, /datum/cargo_crate))
		var/datum/cargo_crate/crate = product
		crate.current_supply += amount
	else if(istype(product, /datum/supply_pack))
		var/datum/supply_pack/legacy = product
		legacy.current_supply += amount

/// Helper: get the list of content types from any product datum type (for small_item grouping)
/proc/get_pack_contains(datum/product)
	if(istype(product, /datum/cargo_item))
		var/datum/cargo_item/item = product
		return list(item.item_path)
	if(istype(product, /datum/cargo_crate))
		var/datum/cargo_crate/crate = product
		return crate.contains
	if(istype(product, /datum/supply_pack))
		var/datum/supply_pack/legacy = product
		return legacy.contains
	return list()
