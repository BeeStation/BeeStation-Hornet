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

	///Stability - lowers as people buy artifacts, stops spam buying
	var/stability = 100

	///List of current listing sellers
	var/list/sellers = list(/datum/rnd_lister/artifact_seller/bastard, /datum/rnd_lister/artifact_seller/bastard, /datum/rnd_lister/artifact_seller/bastard)

	var/list/test = list()

/obj/machinery/computer/xenoarchaeology_console/Initialize()
	. = ..()
	//Link relevant stuff
	linked_techweb = SSresearch.science_tech
	budget = SSeconomy.get_budget_account(ACCOUNT_SCI_ID)
	//Start processing to gain stability
	START_PROCESSING(SSobj, src)
	///Build seller list
	var/list/new_sellers = sellers.Copy()
	sellers = list()
	for(var/datum/rnd_lister/S as() in new_sellers)
		sellers += new S()

/obj/machinery/computer/xenoarchaeology_console/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/machinery/computer/xenoarchaeology_console/process()
	stability = min(100, stability + STABILITY_GAIN)
	//Update UI every 3 seconds, may be delayed
	if(world.time % 3 == 0)
		ui_update()

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
			stock += list(list("name" = A?.name, "description" = A?.desc, "id" = REF(A), "cost" = A?.custom_price || 0))
		data["sellers"] += list(list("name" = seller.name, "dialogue" = seller.dialogue, "stock" = stock, "id" = REF(seller)))
	//Stability
	data["stability"] = stability
	///Cash available
	var/datum/bank_account/D = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
	data["money"] = D.account_balance
	
	return data

/obj/machinery/computer/xenoarchaeology_console/ui_act(action, params)
	if(..())
		return
	
	switch(action)
		//Purchase items
		if("stock_purchase")
			//If we got no instability
			if(!stability)
				say("Insufficient straythread stability!")
				return
			//Locate seller and purchase our item from them
			var/datum/rnd_lister/seller = locate(params["seller_id"])
			//If we got no cash
			var/datum/bank_account/D = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
			if(seller.get_price(locate(params["item_id"])) > D.account_balance)
				say("Insufficient funds!")
				return
			var/datum/supply_pack/SP = seller?.buy_stock(locate(params["item_id"]))
			//Ship the pack
			var/datum/supply_order/SO = new(SP, null, null, null, "Research Material Requisition", D)
			SO.generateRequisition(get_turf(src))
			//TODO: For whatever reason this doesn't auto approve - Racc
			SSsupply.shoppinglist += SO
			//Take our toll
			stability = clamp(stability-STABILITY_COST, 0, 100)

	ui_update()

//Circuitboard for this console
/obj/item/circuitboard/computer/xenoarchaeology_console
	name = "research and development listing console (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/xenoarchaeology_console
