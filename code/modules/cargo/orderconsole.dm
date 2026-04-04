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

/// Returns the batch items list, crate breakdown, and pricing modifiers for the UI.
/obj/machinery/computer/cargo/proc/get_batch_data()
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

	// Build item list and temporary entries for pricing
	var/base_cost = 0
	var/total_items = 0
	var/list/temp_entries = list() // same format as batch order entries for pricing calc
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

	// Calculate crate breakdown (grouped by crate type, max items per crate)
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

	// Average crate fill for display (slot-based)
	if(length(crate_data))
		var/total_fill = 0
		for(var/list/crate in crate_data)
			total_fill += crate["slots_used"]
		batch_data["avg_crate_fill"] = round((total_fill / length(crate_data)) / BATCH_CRATE_MAX_ITEMS * 100, 1)

	return batch_data

/obj/machinery/computer/cargo/ui_static_data(mob/user)
	var/list/data = list()
	data["requestonly"] = requestonly
	data["supplies"] = list()
	data["batch_constants"] = get_batch_pricing_constants()

	// --- Cargo items ---
	for(var/item_type in SSsupply.cargo_items)
		var/datum/cargo_item/item = SSsupply.cargo_items[item_type]
		if((item.hidden && !(obj_flags & EMAGGED)) || (item.contraband && !contraband) || item.DropPodOnly)
			continue
		data["supplies"] += list(list(
			"name" = item.name,
			"cost" = item.get_cost(),
			"id" = item_type,
			"supply" = item.current_supply,
			"desc" = item.desc || item.name,
			"small_item" = item.small_item,
			"access" = item.access
		))

	// --- Cargo crates ---
	for(var/crate_type in SSsupply.cargo_crates)
		var/datum/cargo_crate/crate = SSsupply.cargo_crates[crate_type]
		if((crate.hidden && !(obj_flags & EMAGGED)) || (crate.contraband && !contraband) || (crate.special && !crate.special_enabled) || crate.DropPodOnly)
			continue
		data["supplies"] += list(list(
			"name" = crate.name,
			"cost" = crate.get_cost(),
			"id" = crate_type,
			"supply" = crate.current_supply,
			"desc" = crate.desc || crate.name,
			"small_item" = crate.small_item,
			"access" = crate.access
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
				print_order_summary()
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

			// Stock check - cannot order more than available supply
			if(get_product_supply(product) <= 0)
				say("Out of stock.")
				return

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
			// Stock check - cannot add more than available supply
			var/available_stock = get_product_supply(product)
			var/already_in_batch = 0
			for(var/list/existing in batch)
				if(existing["pack_id"] == id)
					already_in_batch = existing["quantity"]
					break
			if(already_in_batch >= available_stock)
				say("Not enough stock available.")
				return
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

/// Prints an order summary receipt at the console's location listing all pending orders.
/// Called when the shuttle is sent home (i.e. the user confirms the shipment).
/obj/machinery/computer/cargo/proc/print_order_summary()
	var/turf/T = get_turf(src)
	if(!T)
		return
	generate_order_summary(T)

/// Generates an order summary receipt paper at the given location, listing all pending supply orders.
/// Used by cargo consoles and the budget ordering app when the shuttle is called home.
/proc/generate_order_summary(atom/location)
	if(!length(SSsupply.shoppinglist))
		return

	var/obj/item/paper/summary = new(location)
	summary.name = "order summary receipt"

	var/text = "<h2>[command_name()] Order Summary</h2>"
	text += "<hr/>"
	text += "Destination: [GLOB.station_name]<br/>"
	text += "Total Orders: [length(SSsupply.shoppinglist)]<br/>"
	text += "<hr/>"

	var/order_num = 0
	var/total_cost = 0
	for(var/datum/supply_order/SO in SSsupply.shoppinglist)
		order_num++
		if(istype(SO, /datum/supply_order/batch))
			var/datum/supply_order/batch/BO = SO
			text += "<b>Order [order_num] — Batch #[BO.id]</b><br/>"
			text += "Items: [BO.total_items] across [BO.crate_count] crate\s<br/>"
			text += "Ordered by: [BO.orderer] ([BO.orderer_rank])<br/>"
			if(BO.paying_account)
				text += "Paid by: [BO.paying_account.account_holder]<br/>"
			if(BO.reason)
				text += "Reason: [BO.reason]<br/>"
			var/list/readable = BO.get_batch_contents_readable()
			if(length(readable))
				text += "Contents:<ul>"
				for(var/line in readable)
					text += "<li>[line]</li>"
				text += "</ul>"
			text += "Est. Cost: [BO.total_cost] credits<br/>"
			total_cost += BO.total_cost
		else
			text += "<b>Order [order_num] — #[SO.id]</b><br/>"
			text += "Item: [SO.pack_name]<br/>"
			text += "Ordered by: [SO.orderer] ([SO.orderer_rank])<br/>"
			if(SO.paying_account)
				text += "Paid by: [SO.paying_account.account_holder]<br/>"
			if(SO.reason)
				text += "Reason: [SO.reason]<br/>"
			text += "Est. Cost: [SO.pack_cost] credits<br/>"
			total_cost += SO.pack_cost
		text += "<br/>"

	text += "<hr/>"
	text += "<b>Estimated Total: [total_cost] credits</b><br/>"

	summary.add_raw_text(text)
	summary.update_appearance()
	return summary

/// Helper: get current_supply from any product datum type
/proc/get_product_supply(datum/product)
	if(istype(product, /datum/cargo_item))
		var/datum/cargo_item/item = product
		return item.current_supply
	if(istype(product, /datum/cargo_crate))
		var/datum/cargo_crate/crate = product
		return crate.current_supply
	return 0

/// Helper: adjust current_supply on any product datum type
/proc/adjust_product_supply(datum/product, amount)
	if(istype(product, /datum/cargo_item))
		var/datum/cargo_item/item = product
		item.current_supply += amount
	else if(istype(product, /datum/cargo_crate))
		var/datum/cargo_crate/crate = product
		crate.current_supply += amount

/// Helper: get the list of content types from any product datum type (for small_item grouping)
/proc/get_pack_contains(datum/product)
	if(istype(product, /datum/cargo_item))
		var/datum/cargo_item/item = product
		return list(item.item_path)
	if(istype(product, /datum/cargo_crate))
		var/datum/cargo_crate/crate = product
		return crate.contains
	return list()
