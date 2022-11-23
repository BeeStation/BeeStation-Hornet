/obj/item/paper/fluff/jobs/cargo/manifest
	var/order_cost = 0
	var/order_id = 0
	var/errors = 0

/obj/item/paper/fluff/jobs/cargo/manifest/New(atom/A, id, cost)
	..()
	order_id = id
	order_cost = cost

	if(prob(MANIFEST_ERROR_CHANCE))
		errors |= MANIFEST_ERROR_NAME
	if(prob(MANIFEST_ERROR_CHANCE))
		errors |= MANIFEST_ERROR_CONTENTS
	if(prob(MANIFEST_ERROR_CHANCE))
		errors |= MANIFEST_ERROR_ITEM

/obj/item/paper/fluff/jobs/cargo/manifest/proc/is_approved()
	return LAZYLEN(stamp_cache) && !is_denied()

/obj/item/paper/fluff/jobs/cargo/manifest/proc/is_denied()
	return LAZYLEN(stamp_cache) && ("stamp-deny" in stamp_cache)

/datum/supply_order
	var/id
	var/orderer
	var/orderer_rank
	var/orderer_ckey
	var/reason
	var/datum/supply_pack/pack
	var/datum/bank_account/paying_account

/datum/supply_order/New(datum/supply_pack/pack, orderer, orderer_rank, orderer_ckey, reason, paying_account)
	id = SSshuttle.ordernum++
	src.pack = pack
	src.orderer = orderer
	src.orderer_rank = orderer_rank
	src.orderer_ckey = orderer_ckey
	src.reason = reason
	src.paying_account = paying_account

/datum/supply_order/proc/generateRequisition(turf/T)
	var/obj/item/paper/requisition_paper  = new(T)

	requisition_paper.name = "requisition form - #[id] ([pack.name])"
	var/requisition_text = "<h2>[GLOB.station_name] Supply Requisition</h2>"
	requisition_text += "<hr/>"
	requisition_text += "Order #[id]<br/>"
	requisition_text += "Item: [pack.name]<br/>"
	requisition_text += "Access Restrictions: [get_access_desc(pack.access)]<br/>"
	requisition_text += "Requested by: [orderer]<br/>"
	if(paying_account)
		requisition_text += "Paid by: [paying_account.account_holder]<br/>"
	requisition_text += "Rank: [orderer_rank]<br/>"
	requisition_text += "Comment: [reason]<br/>"

	requisition_paper.add_raw_text(requisition_text)
	requisition_paper.update_appearance()
	return requisition_paper

/datum/supply_order/proc/generateManifest(obj/structure/closet/crate/C, var/owner, var/packname) //generates-the-manifests.
	var/obj/item/paper/fluff/jobs/cargo/manifest/P = new(C, id, 0)

	var/station_name = (P.errors & MANIFEST_ERROR_NAME) ? new_station_name() : GLOB.station_name

	P.name = "shipping manifest - [packname?"#[id] ([pack.name])":"(Grouped Item Crate)"]"
	P.default_raw_text += "<h2>[command_name()] Shipping Manifest</h2>"
	P.default_raw_text += "<hr/>"
	if(owner && !(owner == "Cargo"))
		P.default_raw_text += "Direct purchase from [owner]<br/>"
		P.name += " - Purchased by [owner]"
	P.default_raw_text += "Order[packname?"":"s"]: [id]<br/>"
	P.default_raw_text += "Destination: [station_name]<br/>"
	if(packname)
		P.default_raw_text += "Item: [packname]<br/>"
	P.default_raw_text += "Contents: <br/>"
	P.default_raw_text += "<ul>"
	for(var/atom/movable/AM in C.contents - P)
		if((P.errors & MANIFEST_ERROR_CONTENTS))
			if(prob(50))
				P.default_raw_text += "<li>[AM.name]</li>"
			else
				continue
		P.default_raw_text += "<li>[AM.name]</li>"
	P.default_raw_text += "</ul>"
	P.default_raw_text += "<h4>Stamp below to confirm receipt of goods:</h4>"

	if(P.errors & MANIFEST_ERROR_ITEM)
		if(istype(C, /obj/structure/closet/crate/secure) || istype(C, /obj/structure/closet/crate/large))
			P.errors &= ~MANIFEST_ERROR_ITEM
		else
			var/lost = max(round(C.contents.len / 10), 1)
			while(--lost >= 0)
				qdel(pick(C.contents))

	P.update_icon()
	P.forceMove(C)
	C.manifest = P
	C.update_icon()

	return P

/datum/supply_order/proc/generate(atom/A)
	var/account_holder
	if(paying_account)
		account_holder = paying_account.account_holder
	else
		account_holder = "Cargo"
	var/obj/structure/closet/crate/C = pack.generate(A, paying_account)
	generateManifest(C, account_holder, pack)
	return C

/datum/supply_order/proc/generateCombo(var/miscbox, var/misc_own, var/misc_contents)
	for (var/I in misc_contents)
		new I(miscbox)
	generateManifest(miscbox, misc_own, "")
	return
