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

	///The supply pack we ship stuff in
	var/datum/supply_pack/console_pack
	///Our current, if available, order
	var/datum/supply_order/console_order

	///History
	var/list/history = list()

/obj/machinery/computer/xenoarchaeology_console/Initialize()
	. = ..()
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
	for(var/datum/rnd_lister/S as() in sellers)
		sellers -= S
		qdel(S)
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
	if(console_order?.pack)
		data["active_request"] = list(list(
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
			//Ship the pack
			if(!console_pack)
				console_pack = new /datum/supply_pack/science_listing()
				console_pack.contains = list()
			console_pack?.current_supply = max(1, console_pack.current_supply)
			if(!console_order || !(locate(console_order) in SSsupply.shoppinglist))
				console_pack.contains = list()
				console_pack.cost = 0
			console_pack.cost += seller?.get_price(locate(params["item_id"]))
			console_pack.contains += seller?.buy_stock(locate(params["item_id"]))
			if(console_order)
				SSsupply.shoppinglist -= console_order
				qdel(console_order)
			console_order = new(console_pack, name, rank, ckey, "Research Material Requisition", D)
			console_order.generateRequisition(get_turf(src))
			SSsupply.shoppinglist |= console_order
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
	var/datum/component/xenoartifact/X = artifact.GetComponent(/datum/component/xenoartifact)
	if(X && L)
		//Calculate success rate
		var/score = 0
		var/max_score = 0
		for(var/i in X.artifact_traits)
			for(var/datum/xenoartifact_trait/T in X.artifact_traits[i])
				if(T.contribute_calibration)
					if(locate(T) in L.traits)
						score += 1
					else
						score -= 1
				max_score = T.contribute_calibration ?  max_score + 1 : max_score
		var/success_rate = score / max_score
		//Rewards
			//Research Points
		var/rnd_reward = max(0, (artifact.custom_price*X.artifact_type.rnd_rate)*success_rate)
			//Discovery Points
		var/dp_reward = max(0, (artifact.custom_price*X.artifact_type.dp_rate)*success_rate)
			//Alloctae
		linked_techweb?.add_point_type(TECHWEB_POINT_TYPE_GENERIC, rnd_reward)
		linked_techweb?.add_point_type(TECHWEB_POINT_TYPE_DISCOVERY, dp_reward)
			//Money //TODO: Check if this is sufficient - Racc : PLAYTEST
		var/monetary_reward = ((artifact.custom_price * success_rate * 2)^1.5) * (success_rate >= 0.5 ? 1 : 0)
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
			at [station_time_timestamp()]. The Research Department has been awarded [rnd_reward] Research Points, [dp_reward] Discovery Points, and a monetary commision of $[monetary_reward].",\
		RADIO_CHANNEL_SCIENCE)
		history += list("[artifact] has been submitted with a success rate of [100*success_rate]% '[success_type]', \
		at [station_time_timestamp()]. The Research Department has been awarded [rnd_reward] Research Points, [dp_reward] Discovery Points, and a monetary commision of $[monetary_reward].")

//Circuitboard for this console
/obj/item/circuitboard/computer/xenoarchaeology_console
	name = "research and development listing console (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/xenoarchaeology_console
