/obj/item/circuitboard/computer/xenoartifact_console
	name = "research and development listing console (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/xenoartifact_console

/obj/item/circuitboard/machine/xenoartifact_inbox
	name = "bluespace straythread pad (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/xenoartifact_inbox
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)

///Stability lost on purchase
#define STABILITY_COST 30
///Stability gained on-tick
#define STABILITY_GAIN 5

/obj/machinery/computer/xenoartifact_console
	name = "research and development listing console"
	desc = "A science console used to source sellers, and buyers, for various blacklisted research objects."
	icon_screen = "xenoartifact_console"
	icon_keyboard = "rd_key"
	circuit = /obj/item/circuitboard/computer/xenoartifact_console

	///Sellers give artifacts
	var/list/sellers = list()
	///Buyers take artifacts
	var/list/buyers = list()
	///All tabs
	var/list/tab_index = list("Listings", "Export", "Linking")
	var/current_tab = "Listings"
	var/current_tab_info = "Here you can find listings for various research samples, usually fresh from the field. These samples aren't distrubuted by the Nanotrasen affiliated cargo system, so instead listing data is sourced from stray bluespace-threads."
	///used for 'shipping'
	var/obj/machinery/xenoartifact_inbox/linked_inbox
	///List of linked machines for UI purposes
	var/list/linked_machines = list()
	///Which science server receives points
	var/datum/techweb/linked_techweb
	///Actually just a general list of items you've sold
	var/list/sold_artifacts = list()
	///Which department's budget receives profit
	var/datum/bank_account/budget
	///Stability - lowers as people buy artifacts, stops spam buying
	var/stability = 100

/obj/machinery/computer/xenoartifact_console/Initialize()
	. = ..()
	linked_techweb = SSresearch.science_tech
	budget = SSeconomy.get_budget_account(ACCOUNT_SCI_ID)
	sync_devices()
	for(var/I in 1 to XENOA_MAX_VENDORS) //Add initial buyers and sellers
		var/datum/xenoartifact_seller/S = new
		sellers += S
		S.generate()

		var/datum/xenoartifact_seller/buyer/B = new
		buyers += B
		B.generate()
	//Start processing to gain stability
	START_PROCESSING(SSobj, src)

/obj/machinery/computer/xenoartifact_console/Destroy()
	. = ..()
	on_inbox_del()
	qdel(sellers)
	qdel(buyers)
	qdel(sold_artifacts)
	STOP_PROCESSING(SSobj, src)

/obj/machinery/computer/xenoartifact_console/process()
	stability = min(100, stability + STABILITY_GAIN)
	//Update UI every 3 seconds, may be delayed
	if(world.time % 3 == 0)
		ui_update()

/obj/machinery/computer/xenoartifact_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "XenoartifactConsole")
		ui.open()

/obj/machinery/computer/xenoartifact_console/ui_data(mob/user)
	var/list/data = list()
	data["points"] = budget ? budget.account_balance : 0
	data["seller"] = list()
	for(var/datum/xenoartifact_seller/S as() in sellers) //Pass seller data
		data["seller"] += list(list(
			"name" = S.name,
			"dialogue" = S.dialogue,
			"price" = S.price,
			"id" = REF(S),
		))
	data["buyer"] = list()
	for(var/datum/xenoartifact_seller/buyer/B as() in buyers) //Buyer data
		data["buyer"] += list(list(
			"name" = B.name,
			"dialogue" = B.dialogue,
			"price" = B.price,
			"id" = B,
		))
	data["sold_artifacts"] = list()
	for(var/datum/xenoartifact_info_entry/E as() in sold_artifacts) //Pass seller data
		data["sold_artifacts"] += list(list(
			"main" = E.main, //Sold time
			"gain" = E.gain, //Profits
			"traits" = E.traits //traits
		))
	data["tab_index"] = tab_index
	data["current_tab"] = current_tab
	data["tab_info"] = current_tab_info
	data["linked_machines"] = linked_machines
	data["stability"] = stability

	return data

/obj/machinery/computer/xenoartifact_console/ui_act(action, params) //I should probably use a switch statement for this but, the for statements look painful
	. = TRUE
	if(..())
		return

	if(action == "link_nearby")
		sync_devices()
		return
	else if(action == "sell")
		sell()
		return
	else if(copytext(action, 1, 8) == "set_tab") //Set unique tab information
		var/t = copytext(action, 9, length(action)+1)
		if(current_tab != t)
			current_tab = t
			switch(t)
				if("Listings")//Not the best way of doing this but I can't be fucked otherwise.
					current_tab_info = "Here you can find listings for various research samples, usually fresh from the field. These samples aren't distrubuted by the Nanotrasen affiliated cargo system, so instead listing data is sourced from stray bluespace-threads."
				if("Export")
					current_tab_info = "Sell any export your department produces through open bluespace strings. Anonymously trade and sell ancient alien bombs, explosive slime cores, or just regular bombs."
				if("Linking")
					current_tab_info = "Link machines to the Listing Console."
		return
	else //Buy xenoartifact
		var/datum/xenoartifact_seller/S = locate(action)

		if(stability < STABILITY_COST)
			say("Error. Insufficient thread stability.")
			return
		if(!linked_inbox)
			say("Error. No linked hardware.")
			return
		else if(budget.account_balance-S.price < 0)
			say("Error. Insufficient funds.")
			return

		if(linked_inbox && budget.account_balance-S.price >= 0)
			var/obj/item/xenoartifact/A = new (get_turf(linked_inbox.loc), S.difficulty)
			var/datum/component/xenoartifact_pricing/X = A.GetComponent(/datum/component/xenoartifact_pricing)
			if(X)
				X.price = S.price //dont bother trying to use internal singals for this
				sellers -= S
				stability = max(0, stability - STABILITY_COST)
				budget.adjust_money(-1*S.price)
				say("Purchase complete. [budget.account_balance] credits remaining in Research Budget")
				addtimer(CALLBACK(src, PROC_REF(generate_new_seller)), (rand(1,3)*60) SECONDS)
				A = null
	update_icon()

//Auto sells item on pad, finds seller for you
/obj/machinery/computer/xenoartifact_console/proc/sell()
	if(!linked_inbox)
		say("Error. No linked hardware.")
		return
	var/obj/selling_item
	for(var/obj/I in oview(1, linked_inbox))
		for(var/datum/xenoartifact_seller/buyer/B as() in buyers)
			if(istype(I, B.buying))
				buyers -= B
				addtimer(CALLBACK(src, PROC_REF(generate_new_buyer)), (rand(1,3)*60) SECONDS)
				selling_item = I
				break
		if(selling_item)
			break
	var/final_price
	var/info
	if(selling_item)
		if(istype(selling_item, /obj/item/xenoartifact))
			var/datum/component/xenoartifact_pricing/X = selling_item.GetComponent(/datum/component/xenoartifact_pricing)
			if(X)
				//create new info entry datum to store UI dat
				var/datum/xenoartifact_info_entry/entry = new()

				//Give rewards
				final_price = max(X.modifier*X.price, 1)
				budget.adjust_money(final_price)
				linked_techweb.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, (final_price*XENOA_RP) * (final_price >= X.price))
				linked_techweb.add_point_type(TECHWEB_POINT_TYPE_DISCOVERY, ((XENOA_SOLD_DP*(final_price/X.price)) * max(1, final_price/1000)) * (final_price >= X.price))

				//Handle player info
				entry.main = "[selling_item.name] sold at [station_time_timestamp()] for [final_price] credits, bought for [X.price]."
				entry.gain = "Awarded [(final_price*2.3) * (final_price >= X.price)] Research Points & [XENOA_SOLD_DP*(final_price/X.price) * (final_price >= X.price)] Discovery Points."
				info = "[entry.main]\n[entry.gain]\n"

				//append sticker traits & pass it off
				var/obj/item/xenoartifact_label/L = (locate(/obj/item/xenoartifact_label) in selling_item.contents)
				var/obj/item/xenoartifact/A = selling_item
				for(var/datum/xenoartifact_trait/T as() in L?.trait_list)
					var/color = rgb(255, 0, 0)
					//using tertiary operator breaks it
					if(locate(T) in A.traits)
						color =rgb(0, 255, 0)
					var/name = (initial(T.desc) || initial(T.label_name))
					info += {"<span style="color: [color];">\n[name]</span>"}
					entry.traits += list(list("name" = "[name]", "color" = "[color]"))

				sold_artifacts += entry
				qdel(selling_item)
		else //Future feature, not currently in use, wont delete captains gun. Placeholder
			final_price = 120*rand(1, 10)
			budget.adjust_money(final_price)
			sold_artifacts += info
			qdel(selling_item)
	if(info)
		say(info)


/obj/machinery/computer/xenoartifact_console/proc/generate_new_seller() //Called after a short period
	var/datum/xenoartifact_seller/S = new
	S.generate()
	sellers += S
	ui_update()

/obj/machinery/computer/xenoartifact_console/proc/generate_new_buyer()
	var/datum/xenoartifact_seller/buyer/B = new
	B.generate()
	buyers += B
	ui_update()

/obj/machinery/computer/xenoartifact_console/proc/sync_devices()
	for(var/obj/machinery/xenoartifact_inbox/I in oview(9,src))
		if(I.linked_console || I.panel_open)
			return
		if(!(linked_inbox))
			linked_inbox = I
			linked_machines += I.name
			I.linked_console = src
			I.RegisterSignal(src, COMSIG_PARENT_QDELETING, /obj/machinery/xenoartifact_inbox/proc/on_machine_del)
			RegisterSignal(I, COMSIG_PARENT_QDELETING, PROC_REF(on_inbox_del))
			say("Successfully linked [I].")
			return
	say("Unable to find linkable hadrware.")

/obj/machinery/computer/xenoartifact_console/proc/on_inbox_del() //Hard del measures
	SIGNAL_HANDLER
	UnregisterSignal(linked_inbox, COMSIG_PARENT_QDELETING)
	linked_inbox = null

#undef STABILITY_COST
#undef STABILITY_GAIN

/obj/machinery/xenoartifact_inbox
	name = "bluespace straythread pad" //Science words
	desc = "This machine takes advantage of bluespace thread manipulation to highjack in-coming and out-going bluespace signals. Science uses it to deliver their very legal purchases." //All very sciencey
	icon = 'icons/obj/telescience.dmi'
	icon_state = "qpad-idle"
	circuit = /obj/item/circuitboard/machine/xenoartifact_inbox
	var/linked_console

/obj/machinery/xenoartifact_inbox/proc/on_machine_del()
	SIGNAL_HANDLER
	UnregisterSignal(linked_console, COMSIG_PARENT_QDELETING)
	linked_console = null

/obj/machinery/xenoartifact_inbox/Destroy()
	. = ..()
	on_machine_del()

/datum/xenoartifact_seller //Vendor
	var/name
	var/price
	var/dialogue
	var/difficulty //Xenoartifact shit, not exactly difficulty

/datum/xenoartifact_seller/proc/generate()
	name = pick(GLOB.xenoa_seller_names)
	dialogue = pick(GLOB.xenoa_seller_dialogue)
	price = rand(5,80) * 10
	switch(price)
		if(50 to 300)
			difficulty = XENOA_BLUESPACE
		if(301 to 500)
			difficulty = XENOA_PLASMA
		if(501 to 700)
			difficulty = XENOA_URANIUM
		if(701 to 800)
			difficulty = XENOA_BANANIUM
	price = price * rand(1.0, 1.5) //Measure of error for no particular reason
	addtimer(CALLBACK(src, PROC_REF(change_item)), (rand(1,3)*60) SECONDS)

/datum/xenoartifact_seller/proc/change_item()
	generate()

/datum/xenoartifact_seller/buyer //Buyer off shoot, for player-selling
	var/obj/buying

/datum/xenoartifact_seller/buyer/generate()
	name = pick(GLOB.xenoa_seller_names)
	buying = pick(/obj/item/xenoartifact)
	if(buying == /obj/item/xenoartifact) //Don't bother trying to use istype here
		dialogue = "[name] is requesting: Anomaly : Class : Artifact"
	addtimer(CALLBACK(src, PROC_REF(change_item)), (rand(1,3)*60) SECONDS)

//Used to hold information about artifact transactions. Might get standrardized sooner or later.
/datum/xenoartifact_info_entry
	var/main =""
	var/gain = ""
	var/list/traits = list()
