//TODO: Fix a million artifacts spawning in one crate - Racc
///Stability lost on purchase
#define STABILITY_COST 30
///Stability gained on-tick
#define STABILITY_GAIN 5

/obj/machinery/computer/xenoarchaeology_console
	name = "research and development listing console"
	desc = "A science console used to source sellers, and buyers, for various blacklisted research objects."
	icon_screen = "xenoartifact_console"
	icon_keyboard = "rd_key"
	circuit = /obj/item/circuitboard/computer/xenoarchaeology_console

	///Which science server receives points
	var/datum/techweb/linked_techweb
	///Which department's budget receives profit
	var/datum/bank_account/budget

	///List of current listing sellers
	var/list/sellers = list(/datum/rnd_lister/artifact_seller/bastard, /datum/rnd_lister/artifact_seller/uranium_bananium,
	/datum/rnd_lister/artifact_seller/bluespace, /datum/rnd_lister/artifact_seller/plasma_bluespace)

	///radio used by the console to send messages on science channel
	var/obj/item/radio/headset/radio
	///Do we do purchase notices on the radio?
	var/radio_purchase_notice = TRUE
	///Do we do solved notices on the radio?
	var/radio_solved_notice = TRUE

	///List of active orders
	var/list/console_orders = list()
	///Max contents per order - leave this as a variable, trust
	var/max_pack_contents = 5

	///History of purchases and sales
	var/list/history = list()

	///Is this console the main character?
	var/main_console = FALSE

/obj/machinery/computer/xenoarchaeology_console/Initialize()
	. = ..()
	//Link up with SS to see if we're the choosen one
	if(!SSxenoarchaeology.main_console)
		SSxenoarchaeology.register_console(src)
	RegisterSignal(SSxenoarchaeology, XENOA_NEW_CONSOLE, PROC_REF(be_the_guy))
	//Link relevant stuff
	linked_techweb = SSresearch.science_tech
	budget = SSeconomy.get_budget_account(ACCOUNT_SCI_ID)
	var/list/new_sellers = sellers.Copy()
	sellers = list()
	for(var/datum/rnd_lister/S as() in new_sellers)
		sellers += new S()
	//Radio setup
	radio = new /obj/item/radio/headset/headset_sci(src)
	//Look for sold artifacts
	RegisterSignal(SSdcs, COMSIG_GLOB_ATOM_SOLD, PROC_REF(check_sold))

/obj/machinery/computer/xenoarchaeology_console/Destroy()
	. = ..()
	QDEL_LIST(sellers)
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(radio)

/obj/machinery/computer/xenoarchaeology_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "XenoartifactConsole")
		ui.open()

/obj/machinery/computer/xenoarchaeology_console/ui_data(mob/user)
	var/list/data = list()

	//Seller data
	data["sellers"] = list()
	for(var/datum/rnd_lister/seller as() in sellers)
		var/list/stock = list()
		for(var/atom/A as() in seller.current_stock)
			stock += list(list("name" = A?.name, "description" = A?.desc, "id" = REF(A), "cost" = seller.get_price(A) || 0))
		data["sellers"] += list(list("name" = seller.name, "dialogue" = seller.dialogue, "stock" = stock, "id" = REF(seller)))
	//Cash available
	var/datum/bank_account/D = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
	data["money"] = D.account_balance
	//Audio
	data["purchase_radio"] = radio_purchase_notice
	data["solved_radio"] = radio_solved_notice
	//History
	data["history"] = history
	//Current requests
	data["active_request"] = list()
	if(length(console_orders))
		for(var/datum/supply_order/console_order in console_orders)
			if(!(console_order in SSsupply.shoppinglist))
				console_orders -= console_order
				qdel(console_order)
				continue
			data["active_request"] += list(list(
				"object" = console_order.pack.name,
				"cost" = console_order.pack.get_cost(),
				"supply" = console_order.pack.current_supply,
				"orderer" = console_order.orderer,
				"reason" = console_order.reason,
				"id" = console_order.id
				))

	return data

/obj/machinery/computer/xenoarchaeology_console/ui_act(action, params)
	if(..())
		return

	switch(action)
		//Purchase items
		if("stock_purchase")
			//Locate seller and purchase our item from them
			var/datum/rnd_lister/seller = locate(params["seller_id"])
			//Check if this is even possible
			if(!(locate(params["item_id"]) in seller.current_stock))
				return
			//If we got no cash
			var/datum/bank_account/D = SSeconomy.get_budget_account(ACCOUNT_SCI_ID)
			if(seller.get_price(locate(params["item_id"])) > D.account_balance)
				say("Insufficient funds!")
				return
			//Annouce it
			if(radio_purchase_notice)
				radio?.talk_into(src, "[locate(params["item_id"])] was requested for purchase, for [seller.get_price(locate(params["item_id"]))] credits, at [station_time_timestamp()].", RADIO_CHANNEL_SCIENCE)
			history += list("[locate(params["item_id"])] was requested for purchase, for [seller.get_price(locate(params["item_id"]))] credits, at [station_time_timestamp()].")
			//handle ID and such
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
			//Check if we can add the artifact to a pending order
			var/datum/supply_order/current_order
			var/datum/supply_pack/current_pack
			if(length(console_orders))
				current_order = console_orders[length(console_orders)]
				current_pack = console_orders[current_order]
				if(length(current_pack.contains) < max_pack_contents && (current_order in SSsupply.shoppinglist))
					//Update pack content and cost
					current_pack.cost += seller?.get_price(locate(params["item_id"]))
					current_pack.contains += seller?.buy_stock(locate(params["item_id"]))
					//Generate a new order
					SSsupply.shoppinglist -= current_order
					console_orders -= current_order
					qdel(current_order)
					current_order = new /datum/supply_order(current_pack, name, rank, ckey, "Research Material Requisition", D)
					SSsupply.shoppinglist += current_order
					console_orders[current_order] = current_pack
					ui_update()
					return
				else if(!(current_order in SSsupply.shoppinglist))
					console_orders -= current_order
					qdel(current_order)
			//If we can't, make a new order
			current_pack = new /datum/supply_pack/science_listing()
			current_pack.contains = list()
			current_pack?.current_supply = max(1, current_pack.current_supply) //Don't worry about it :^)
			current_pack.cost += seller?.get_price(locate(params["item_id"]))
			current_pack.contains += seller?.buy_stock(locate(params["item_id"]))
			current_order = new /datum/supply_order(current_pack, name, rank, ckey, "Research Material Requisition", D)
			current_order.generateRequisition(get_turf(src))
			SSsupply.shoppinglist += current_order
			console_orders[current_order] = current_pack
		//Radio shit
		if("toggle_purchase_audio")
			radio_purchase_notice = !radio_purchase_notice
		if("toggle_solved_audio")
			radio_solved_notice = !radio_solved_notice

	ui_update()

/obj/machinery/computer/xenoarchaeology_console/proc/check_sold(datum/source, atom/movable/AM, sold)
	SIGNAL_HANDLER

	var/obj/item/sticker/xenoartifact_label/L = AM
	if(!istype(L))
		return
	var/atom/artifact = L.loc
	var/datum/component/xenoartifact/X = artifact?.GetComponent(/datum/component/xenoartifact)
	if(!X || !artifact)
		return
	//Grab values to calculate success
	var/score = 0
	var/max_score = 0
	var/bonus = 0
	var/max_bonus = 0
	var/attempted_bonus = FALSE
	var/list/traits_by_type = list()
	for(var/i in X.artifact_traits) //By priority
		for(var/datum/xenoartifact_trait/T in X.artifact_traits[i]) //By trait in priorty
			traits_by_type += list(T.type)
			if(T.contribute_calibration)
				max_score += 1
			else
				max_bonus += 1
	for(var/datum/xenoartifact_trait/T as() in L.traits)
		if((T in traits_by_type))
			if(initial(T.contribute_calibration))
				score += 1
			else
				bonus += 1
				attempted_bonus = TRUE
		else
			if(initial(T.contribute_calibration))
				score -= 1
			else
				bonus -= 1
				attempted_bonus = TRUE
	//Calculate success rate
	var/success_rate = score / (max_score || 1)
	var/bonus_rate = max(1, 2*(bonus/(max_bonus||1)))
	//Rewards
		//Research Points
	var/rnd_reward = max(0, (artifact.custom_price*X.artifact_type.rnd_rate)*success_rate) * bonus_rate
		//Discovery Points
	var/dp_reward = max(0, (artifact.custom_price*X.artifact_type.dp_rate)*success_rate) * bonus_rate
		//Money //TODO: Check if this is sufficient - Racc : PLAYTEST
	var/monetary_reward = ((artifact.custom_price * success_rate * 1.5)^1.1) * (success_rate >= 0.5 ? 1 : 0) * bonus_rate
	//Alloctae
	if(main_console)
		linked_techweb?.add_point_type(TECHWEB_POINT_TYPE_GENERIC, rnd_reward)
		linked_techweb?.add_point_type(TECHWEB_POINT_TYPE_DISCOVERY, dp_reward)
		budget.adjust_money(monetary_reward)
	//Announce victory or fuck up
	var/success_type
	switch(success_rate)
		if(0.3 to 0.69)
			success_type = "sufficient research"
		if(0.7 to 0.89)
			success_type = "admirable research"
		if(0.9 to INFINITY)
			success_type = "incredible discovery"
		else
			success_type = prob(1) ? "scientific failure." : "who let the clown in?"
	if(radio_solved_notice)
		radio?.talk_into(src, "[artifact] has been submitted with a success rate of [100*success_rate]% '[success_type]', \
		[attempted_bonus ? "with a bonus achieved of [100 * (bonus / (max_bonus||1))]%, " : ""]\
		at [station_time_timestamp()]. The Research Department has been awarded [rnd_reward] Research Points, [dp_reward] Discovery Points, and a monetary commision of $[monetary_reward].",\
	RADIO_CHANNEL_SCIENCE)
	history += list("[artifact] has been submitted with a success rate of [100*success_rate]% '[success_type]', \
	at [station_time_timestamp()]. The Research Department has been awarded [rnd_reward] Research Points, [dp_reward] Discovery Points, and a monetary commision of $[monetary_reward].")

/obj/machinery/computer/xenoarchaeology_console/proc/be_the_guy(datum/source)
	SIGNAL_HANDLER

	if(!SSxenoarchaeology.main_console && !main_console)
		SSxenoarchaeology.register_console(src)

//Circuitboard for this console
/obj/item/circuitboard/computer/xenoarchaeology_console
	name = "research and development listing console (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/xenoarchaeology_console
