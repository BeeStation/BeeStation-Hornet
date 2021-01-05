GLOBAL_LIST_EMPTY(icn_exports)

/obj/item/icn_tagger
	name = "\improper Interstation Cargo Network tagger"
	desc = "A device used to prepare a crate for export to the Interstation Cargo Network instead of CentCom."
	icon = 'icons/obj/device.dmi'
	icon_state = "export_scanner"
	item_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	siemens_coefficient = 1
	var/price = 1000
	var/payment_account = ACCOUNT_CAR
	var/icn_cooldown = 0

/obj/item/icn_tagger/examine(mob/user)
	. = ..()
	if(icn_cooldown > world.time + (5 MINUTES))
		. += "<span class='notice'>The ICN tagger is still in cooldown for: [DisplayTimeText(icn_cooldown - world.time)].</span>"
		. += "<span class='notice'>However, you can still edit crates that have already been tagged.</span>"
	else
		. += "<span class='notice'>Use the tagger in your hand to set the price and the account to pay.</span>"
		. += "<span class='notice'>Use the tagger on a crate then send it on the cargo shuttle to list it on the ICN.</span>"
		. += "<span class='notice'>The crate contents will be listed automatically; no gaming the system!</span>"
		. += "<span class='notice'>Price: [price], Account: [account_name()]"

/obj/item/icn_tagger/proc/account_name()
	if(SSeconomy.get_dep_account(src.payment_account))
		return SSeconomy.department_accounts[src.payment_account]
	else
		return payment_account

/obj/item/icn_tagger/attack_self(mob/user)
	..()
	add_fingerprint(user)

	//I hate creating UIs, enjoy some popups
	var/temp_price = input(user, "Set the export price. Min: $1,000. Max: $100,000.", "Set Export Price", 1000) as null|num
	if(temp_price < 1000 || temp_price > 100000 || !isnum_safe(temp_price))
		to_chat(user, "<span class='warning'>Invalid price! Minimum: $1,000. Maximum: $100,000.</span>")
		return
	price = temp_price
	var/acc_type = alert(user, "Select an account type", "Account Type", "Department", "Personal", "Cancel")
	if(acc_type == "Personal")
		var/temp_acc = input(user, "Insert your account ID.", "Account ID") as null|num
		if(temp_acc < 111111 || temp_acc > 999999 || !isnum_safe(temp_acc)) // Account IDs are rand(111111, 999999)
			to_chat(user, "<span class='warning'>Invalid account ID!</span>")
		else
			payment_account = temp_acc
	else if(acc_type == "Department")
		var/choice = input(user, "Select a department account","Account ID") as null|anything in SSeconomy.department_ids
		if(SSeconomy.department_accounts[choice])
			payment_account = choice

	to_chat(user, "<span class='notice'>Tag info updated! Price: [price]. Account ID: [account_name()]</span>")

/obj/item/icn_tagger/afterattack(obj/O, mob/user, proximity)
	. = ..()
	if(!istype(O) || !proximity)
		return

	if(istype(O, /obj/structure/closet/crate))
		if(istype(O, /obj/structure/closet/crate/secure))
			to_chat(user, "<span class='warning'>You can't sell secure crates on the ICN!</span>")
			return
		var/obj/structure/closet/crate/C = O
		var/datum/icn_export/E = C.icn_export
		if(!E)
			if(icn_cooldown > world.time) //We only care about the cooldown for new crates, you can still edit the values on already-tagged crates
				to_chat(user, "<span class='warning'>The ICN tagger is still in cooldown for: [DisplayTimeText(icn_cooldown - world.time)]</span>")
				return
			icn_cooldown = world.time + (5 MINUTES)
			E = new
			C.icn_export = E

		E.seller_ckey = user.ckey
		E.seller_name = user.real_name
		E.price = src.price
		E.roundid = GLOB.round_id
		E.station_name = station_name()
		E.payment_account = src.payment_account
		E.icn_id = rustg_hash_string(RUSTG_HASH_MD5, "[user.ckey][E.roundid][world.time]")
		E.order_no = copytext(E.icn_id,1,7)

		C.name = "\improper ICN Order #[E.order_no] crate"

		to_chat(user, "<span class='notice'>You prepare the crate for ICN export ($[price]). Account ID: [account_name()].</span>")

		return

/datum/icn_export
	var/seller_ckey
	var/seller_name
	var/price
	var/roundid
	var/station_name
	var/payment_account
	var/list/contents
	var/icn_id
	var/order_no
	var/purchased = FALSE

/datum/icn_export/Destroy()
	GLOB.icn_exports -= src
	..()

/datum/icn_export/proc/process_crate(var/obj/structure/closet/crate/C)
	if(!istype(C))
		qdel(C)
		qdel(src)
		return

	var/list/crate_contents = C.GetAllContents()
	if(!crate_contents.len)
		qdel(C)
		qdel(src)
		return

	contents = list()
	var/notify_seller = FALSE
	for(var/atom/A in crate_contents)
		if((A.flags_1 & ADMIN_SPAWNED_1) || (A.datum_flags & DF_VAR_EDITED))
			log_game("[seller_ckey] tried to sell an adminspawned or varedited [A.name] on the ICN")
			message_admins("[seller_ckey] tried to sell an adminspawned or varedited [A.name] on the ICN")
			qdel(A)
			notify_seller = TRUE
			continue
		if((A.flags_1 & HOLOGRAM_1) || (A.datum_flags & DF_ICNBANNED))
			qdel(A)
			notify_seller = TRUE
			continue
		if(isobj(A))
			var/obj/O = A
			if((O.resistance_flags & INDESTRUCTIBLE))
				qdel(O)
				notify_seller = TRUE
				continue
		if(ismob(A)) //This shouldn't be possible but better safe than sorry
			qdel(A)
			notify_seller = TRUE
			continue

		if(istype(A, /obj/item/stack)) //We have to care about the amount in a stack
			var/obj/item/stack/S = A
			contents += list("type" = "[A.type]", "name" = "[initial(A.name)]", "amount" = S.amount)
		else
			contents += list("type" = "[A.type]", "name" = "[initial(A.name)]") //We're not *super* concerned about any other vars

		qdel(A)

	C.contents = null
	qdel(C)

	if(notify_seller || !contents.len)
		//Notify the seller via PDA
		var/message = "One or more of the items in your listing (#[order_no]) have been seized by ICN Customs Agents. No refunds."
		if(!contents.len)
			message = "Your listing (#[order_no]) has been rejected by the ICN and the crate has been destroyed. No refunds."
		for (var/obj/item/pda/P as() in GLOB.PDAs)
			if(P.owner == seller_name)
				var/datum/signal/subspace/messaging/pda/signal = new(src, list(
					"name" = "Interstation Cargo Network",
					"job" = "CentCom",
					"message" = message,
					"targets" = list("[P.owner] ([P.ownjob])"),
					"automated" = 1))
				signal.send_to_receivers()
		qdel(src)
	else
		finalize_export()

/datum/icn_export/proc/finalize_export()
	if(price < 1000 || price > 100000 || !roundid || !payment_account || !seller_ckey) //This should never happen, but better safe than sorry
		qdel(src)
		return

	log_game("ICN EXPORT: Export #[order_no] ($[price]) created by [seller_ckey] with the following contents: [jointext(contents, ", ")]")

	GLOB.icn_exports += src
