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
	var/list/obj/miscboxes = list() //miscboxes are combo boxes that contain all small_item orders grouped
	var/list/misc_order_num = list() //list of strings of order numbers, so that the manifest can show all orders in a box
	var/list/misc_contents = list() //list of lists of items that each box will contain
	var/list/misc_costs = list() //list of overall costs sustained by each buyer.
	if(!SSsupply.shoppinglist.len)
		return

	var/list/empty_turfs = list()
	for(var/place in shuttle_areas)
		var/area/shuttle/shuttle_area = place
		for(var/turf/open/floor/T in shuttle_area)
			if(T.is_blocked_turf())
				continue
			empty_turfs += T

	var/value = 0
	var/purchases = 0
	for(var/datum/supply_order/SO in SSsupply.shoppinglist)
		if(!empty_turfs.len)
			break
		var/price = SO.pack.get_cost()
		var/datum/bank_account/D
		if(SO.paying_account) //Someone paid out of pocket
			D = SO.paying_account
			price *= 1.1 //TODO make this customizable by the quartermaster
		else
			D = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
		if(D)
			if(!D.adjust_money(-price))
				if(SO.paying_account)
					D.bank_card_talk("Cargo order #[SO.id] rejected due to lack of funds. Credits required: [price]")
				continue
		//No stock
		if(SO.pack.current_supply <= 0)
			continue

		SO.pack.current_supply --

		if(SO.paying_account)
			D.bank_card_talk("Cargo order #[SO.id] has shipped. [price] credits have been charged to your bank account.")
			var/datum/bank_account/department/cargo = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
			cargo.adjust_money(price - SO.pack.get_cost()) //Cargo gets the handling fee
		value += SO.pack.get_cost()
		SSsupply.shoppinglist -= SO
		SSsupply.orderhistory += SO

		if(SO.pack.small_item) //small_item means it gets piled in the miscbox
			if(SO.paying_account)
				if(!miscboxes.len || !miscboxes[D.account_holder]) //if there's no miscbox for this person
					miscboxes[D.account_holder] = new /obj/structure/closet/crate/secure/owned(pick_n_take(empty_turfs), SO.paying_account)
					miscboxes[D.account_holder].name = "small items crate - purchased by [D.account_holder]"
					misc_contents[D.account_holder] = list()
					miscboxes[D.account_holder].req_access = list()
				for (var/item in SO.pack.contains)
					misc_contents[D.account_holder] += item
				misc_costs[D.account_holder] += SO.pack.cost
				misc_order_num[D.account_holder] = "[misc_order_num[D.account_holder]]#[SO.id]  "
			else //No private payment, so we just stuff it all into a generic crate
				if(!miscboxes.len || !miscboxes["Cargo"])
					miscboxes["Cargo"] = new /obj/structure/closet/crate/secure(pick_n_take(empty_turfs))
					miscboxes["Cargo"].name = "small items crate"
					misc_contents["Cargo"] = list()
					miscboxes["Cargo"].req_access = list()
				for (var/item in SO.pack.contains)
					misc_contents["Cargo"] += item
					//new item(miscboxes["Cargo"])
				if(SO.pack.access)
					miscboxes["Cargo"].req_access |= SO.pack.access
				misc_order_num["Cargo"] = "[misc_order_num["Cargo"]]#[SO.id]  "
		else
			SO.generate(pick_n_take(empty_turfs))

		SSblackbox.record_feedback("nested tally", "cargo_imports", 1, list("[SO.pack.get_cost()]", "[SO.pack.name]"))
		investigate_log("Order #[SO.id] ([SO.pack.name], placed by [key_name(SO.orderer_ckey)]), paid by [D.account_holder] has shipped.", INVESTIGATE_CARGO)
		if(SO.pack.dangerous)
			message_admins("\A [SO.pack.name] ordered by [ADMIN_LOOKUPFLW(SO.orderer_ckey)], paid by [D.account_holder] has shipped.")
		purchases++

	for(var/I in miscboxes)
		var/datum/supply_order/SO = new/datum/supply_order()
		SO.id = misc_order_num[I]
		SO.generateCombo(miscboxes[I], I, misc_contents[I], misc_costs[I])
		qdel(SO)

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
