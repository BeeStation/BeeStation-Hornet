/obj/machinery/computer/cargo/express
	name = "express supply console"
	desc = "This console allows the user to purchase a package \
		with 1/40th of the delivery time: made possible by Nanotrasen's new \"1500mm Orbital Railgun\".\
		All sales are near instantaneous - please choose carefully"
	icon_screen = "supply_express"
	circuit = /obj/item/circuitboard/computer/cargo/express


	blockade_warning = "Bluespace instability detected. Delivery impossible."
	req_access = list(ACCESS_QM)

	var/message
	var/printed_beacons = 0 //number of beacons printed. Used to determine beacon names.
	var/list/meme_pack_data
	var/obj/item/supplypod_beacon/beacon //the linked supplypod beacon
	var/area/landingzone = /area/quartermaster/storage //where we droppin boys
	var/podType = /obj/structure/closet/supplypod
	var/cooldown = 0 //cooldown to prevent printing supplypod beacon spam
	var/locked = TRUE //is the console locked? unlock with ID
	var/usingBeacon = FALSE //is the console in beacon mode? exists to let beacon know when a pod may come in

/obj/machinery/computer/cargo/express/Initialize(mapload)
	. = ..()
	packin_up()

/obj/machinery/computer/cargo/express/Destroy()
	if(beacon)
		beacon.unlink_console()
	return ..()

/obj/machinery/computer/cargo/express/attackby(obj/item/W, mob/living/user, params)
	if((istype(W, /obj/item/card/id) || istype(W, /obj/item/modular_computer/tablet/pda)) && allowed(user))
		locked = !locked
		to_chat(user, span_notice("You [locked ? "lock" : "unlock"] the interface."))
		return
	else if(istype(W, /obj/item/disk/cargo/bluespace_pod))
		podType = /obj/structure/closet/supplypod/bluespacepod//doesnt effect circuit board, making reversal possible
		to_chat(user, span_notice("You insert the disk into [src], allowing for advanced supply delivery vehicles."))
		qdel(W)
		return TRUE
	else if(istype(W, /obj/item/supplypod_beacon))
		var/obj/item/supplypod_beacon/sb = W
		if (sb.express_console != src)
			sb.link_console(src, user)
			return TRUE
		else
			to_chat(user, span_notice("[src] is already linked to [sb]."))
	..()

/obj/machinery/computer/cargo/express/on_emag(mob/user)
	..()
	to_chat(user,span_notice("You change the routing protocols, allowing the Supply Pod to land anywhere on the station."))
	packin_up()

/obj/machinery/computer/cargo/express/proc/packin_up()
	meme_pack_data = list()

	// Cargo items
	for(var/item_type in SSsupply.cargo_items)
		var/datum/cargo_item/item = SSsupply.cargo_items[item_type]
		if(item.hidden || item.DropPodOnly)
			continue
		if(!((obj_flags & EMAGGED) || contraband) && item.contraband)
			continue
		meme_pack_data += list(list(
			"name" = item.name,
			"cost" = item.get_cost(),
			"id" = item_type,
			"desc" = item.desc || item.name,
			"supply" = item.current_supply
		))

	// Cargo crates
	for(var/crate_type in SSsupply.cargo_crates)
		var/datum/cargo_crate/crate = SSsupply.cargo_crates[crate_type]
		if(crate.hidden || crate.special || crate.DropPodOnly)
			continue
		if(!((obj_flags & EMAGGED) || contraband) && crate.contraband)
			continue
		meme_pack_data += list(list(
			"name" = crate.name,
			"cost" = crate.get_cost(),
			"id" = crate_type,
			"desc" = crate.desc || crate.name,
			"supply" = crate.current_supply
		))

	// Legacy supply packs (backwards compat)
	for(var/pack in SSsupply.supply_packs)
		var/datum/supply_pack/P = SSsupply.supply_packs[pack]
		if(P.hidden || P.special || P.DropPodOnly)
			continue
		if(!((obj_flags & EMAGGED) || contraband) && P.contraband)
			continue
		meme_pack_data += list(list(
			"name" = P.name,
			"cost" = P.get_cost(),
			"id" = pack,
			"desc" = P.desc || P.name,
			"supply" = P.current_supply
		))


/obj/machinery/computer/cargo/express/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/cargo/express/ui_interact(mob/user, datum/tgui/ui) // Remember to use the appropriate state.
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CargoExpress")
		ui.set_autoupdate(TRUE) // Account balance
		ui.open()

/obj/machinery/computer/cargo/express/ui_data(mob/user)
	var/canBeacon = beacon && (isturf(beacon.loc) || ismob(beacon.loc))//is the beacon in a valid location?
	var/list/data = list()
	var/datum/bank_account/D = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
	if(D)
		data["points"] = D.account_balance
	data["locked"] = locked//swipe an ID to unlock
	data["siliconUser"] = user.has_unlimited_silicon_privilege
	data["beaconzone"] = beacon ? get_area(beacon) : ""//where is the beacon located? outputs in the tgui
	data["usingBeacon"] = usingBeacon //is the mode set to deliver to the beacon or the cargobay?
	data["canBeacon"] = !usingBeacon || canBeacon //is the mode set to beacon delivery, and is the beacon in a valid location?
	data["canBuyBeacon"] = cooldown <= 0 && D.account_balance >= BEACON_COST
	data["beaconError"] = usingBeacon && !canBeacon ? "(BEACON ERROR)" : ""//changes button text to include an error alert if necessary
	data["hasBeacon"] = beacon != null//is there a linked beacon?
	data["beaconName"] = beacon ? beacon.name : "No Beacon Found"
	data["printMsg"] = cooldown > 0 ? "Print Beacon for [BEACON_COST] credits ([cooldown])" : "Print Beacon for [BEACON_COST] credits"//buttontext for printing beacons
	data["supplies"] = list()
	message = "Sales are near-instantaneous - please choose carefully."
	if(SSshuttle.supplyBlocked)
		message = blockade_warning
	if(usingBeacon && !beacon)
		message = "BEACON ERROR: BEACON MISSING"//beacon was destroyed
	else if (usingBeacon && !canBeacon)
		message = "BEACON ERROR: MUST BE EXPOSED"//beacon's loc/user's loc must be a turf
	if(obj_flags & EMAGGED)
		message = "(&!#@ERROR: ROUTING_#PROTOCOL MALF(*CT#ON. $UG%ESTE@ ACT#0N: !^/PULS3-%E)ET CIR*)ITB%ARD."
	data["message"] = message
	if(!meme_pack_data)
		packin_up()
		stack_trace("You didn't give the cargo tech good advice, and he ripped the manifest. As a result, there was no pack data for [src]")
	data["supplies"] = meme_pack_data
	if (cooldown > 0)//cooldown used for printing beacons
		cooldown--
	return data

/obj/machinery/computer/cargo/express/ui_act(action, params, datum/tgui/ui)
	if(action == "add")
		action = "express_add" // Ignore parent's "add" action
	. = ..(action, params, ui)
	if(.)
		return
	switch(action)
		if("LZCargo")
			usingBeacon = FALSE
			if (beacon)
				beacon.update_status(SP_UNREADY) //ready light on beacon will turn off
				. = TRUE
		if("LZBeacon")
			usingBeacon = TRUE
			if (beacon)
				beacon.update_status(SP_READY) //turns on the beacon's ready light
				. = TRUE
		if("printBeacon")
			var/datum/bank_account/D = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
			if(D)
				if(D.adjust_money(-BEACON_COST))
					cooldown = 10//a ~ten second cooldown for printing beacons to prevent spam
					var/obj/item/supplypod_beacon/C = new /obj/item/supplypod_beacon(drop_location())
					C.link_console(src, usr)//rather than in beacon's Initialize(), we can assign the computer to the beacon by reusing this proc)
					printed_beacons++//printed_beacons starts at 0, so the first one out will be called beacon # 1
					beacon.name = "Supply Pod Beacon #[printed_beacons]"
					. = TRUE


		if("express_add")//Generate Supply Order first
			if(!COOLDOWN_FINISHED(src, order_cooldown))
				return
			if(usingBeacon && !(beacon && (isturf(beacon.loc) || ismob(beacon.loc))))
				return
			var/id = text2path(params["id"])
			var/list/product_info = SSsupply.get_product(id)
			if(!product_info)
				return
			var/datum/product = product_info["datum"]
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
			var/reason = ""
			var/list/empty_turfs
			var/datum/supply_order/SO = new(product, name, rank, ckey, reason)
			var/points_to_check
			var/datum/bank_account/D = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
			if(D)
				points_to_check = D.account_balance
			if(!(obj_flags & EMAGGED))
				if(SO.pack_cost <= points_to_check && get_product_supply(SO.pack) >= 0)
					var/LZ
					if (istype(beacon) && usingBeacon)//prioritize beacons over landing in cargobay
						LZ = get_turf(beacon)
						beacon.update_status(SP_LAUNCH)
					else if (!usingBeacon)//find a suitable supplypod landing zone in cargobay
						landingzone = GLOB.areas_by_type[/area/quartermaster/storage]
						if (!landingzone)
							WARNING("[src] couldnt find a Quartermaster/Storage (aka cargobay) area on the station, and as such it has set the supplypod landingzone to the area it resides in.")
							landingzone = get_area(src)
						for(var/turf/open/floor/T in landingzone.get_contained_turfs())//uses default landing zone
							if(T.is_blocked_turf())
								continue
							LAZYADD(empty_turfs, T)
							CHECK_TICK
						if(empty_turfs?.len)
							LZ = pick(empty_turfs)
					if (SO.pack_cost <= points_to_check && LZ)//we need to call the cost check again because of the CHECK_TICK call
						new /obj/effect/pod_landingzone(LZ, podType, SO)
						investigate_log("Order #[SO.id] [SO.pack_name], placed by [key_name(SO.orderer_ckey)], paid by [D.account_holder] has been launched to [loc_name(LZ)].", INVESTIGATE_CARGO)
						COOLDOWN_START(src, order_cooldown, ORDER_COOLDOWN)
						D.adjust_money(-SO.pack_cost)
						adjust_product_supply(SO.pack, -1)
						SEND_GLOBAL_SIGNAL(COMSIG_GLOB_RESUPPLY)
						. = TRUE
						update_icon()
			else
				if(SO.pack_cost * (0.72*MAX_EMAG_ROCKETS) <= points_to_check && get_product_supply(SO.pack) >= 0) // bulk discount :^)
					landingzone = GLOB.areas_by_type[pick(GLOB.the_station_areas)]  //override default landing zone
					for(var/turf/open/floor/T in landingzone.get_contained_turfs())
						if(T.is_blocked_turf())
							continue
						LAZYADD(empty_turfs, T)
						CHECK_TICK
					if(empty_turfs && empty_turfs.len)
						D.adjust_money(-(SO.pack_cost * (0.72*MAX_EMAG_ROCKETS)))
						adjust_product_supply(SO.pack, -1)
						SEND_GLOBAL_SIGNAL(COMSIG_GLOB_RESUPPLY)
						for(var/i in 1 to MAX_EMAG_ROCKETS)
							var/LZ = pick(empty_turfs)
							LAZYREMOVE(empty_turfs, LZ)
							new /obj/effect/pod_landingzone(LZ, podType, SO)
							investigate_log("Order #[SO.id] [SO.pack_name], has been randomly launched to [loc_name(LZ)] by [key_name(SO.orderer_ckey)] using an emagged express supply console.", INVESTIGATE_CARGO)
							COOLDOWN_START(src, order_cooldown, ORDER_COOLDOWN/2)
							. = TRUE
							update_icon()
							CHECK_TICK
