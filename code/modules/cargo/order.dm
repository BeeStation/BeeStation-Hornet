/// The chance for a manifest or crate to be created with errors
#define MANIFEST_ERROR_CHANCE		5

// MANIFEST BITFLAGS
/// Determines if the station name will be incorrect on the manifest
#define MANIFEST_ERROR_NAME (1 << 0)
/// Determines if contents will be deleted from the manifest but still be present in the crate
#define MANIFEST_ERROR_CONTENTS (1 << 1)
/// Determines if contents will be deleted from the crate but still be present in the manifest
#define MANIFEST_ERROR_ITEM (1 << 2)


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
	id = SSsupply.ordernum++
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
	var/obj/item/paper/fluff/jobs/cargo/manifest/manifest_paper = new(C, id, 0)

	var/station_name = (manifest_paper.errors & MANIFEST_ERROR_NAME) ? new_station_name() : GLOB.station_name

	manifest_paper.name = "shipping manifest - [packname?"#[id] ([pack.name])":"(Grouped Item Crate)"]"

	var/manifest_text = "<h2>[command_name()] Shipping Manifest</h2>"
	manifest_text += "<hr/>"
	if(owner && !(owner == "Cargo"))
		manifest_text += "Direct purchase from [owner]<br/>"
		manifest_paper.name += " - Purchased by [owner]"
	manifest_text += "Order[packname?"":"s"]: [id]<br/>"
	manifest_text += "Destination: [station_name]<br/>"
	if(packname)
		manifest_text += "Item: [packname]<br/>"
	manifest_text += "Contents: <br/>"
	manifest_text += "<ul>"
	for(var/atom/movable/AM in C.contents - manifest_paper)
		if((manifest_paper.errors & MANIFEST_ERROR_CONTENTS))
			if(prob(50))
				manifest_text += "<li>[AM.name]</li>"
			else
				continue
		manifest_text += "<li>[AM.name]</li>"
	manifest_text += "</ul>"
	manifest_text += "<h4>Stamp below to confirm receipt of goods:</h4>"

	manifest_paper.add_raw_text(manifest_text)

	if(manifest_paper.errors & MANIFEST_ERROR_ITEM)
		if(istype(C, /obj/structure/closet/crate/secure) || istype(C, /obj/structure/closet/crate/large))
			manifest_paper.errors &= ~MANIFEST_ERROR_ITEM
		else
			var/lost = max(round(C.contents.len / 10), 1)
			while(--lost >= 0)
				qdel(pick(C.contents))

	manifest_paper.update_appearance()
	manifest_paper.forceMove(C)

	C.manifest = manifest_paper
	C.update_icon()

	return manifest_paper

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

#undef MANIFEST_ERROR_CHANCE
#undef MANIFEST_ERROR_NAME
#undef MANIFEST_ERROR_CONTENTS
#undef MANIFEST_ERROR_ITEM
