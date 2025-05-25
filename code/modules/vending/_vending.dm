/*
 * Vending machine types - Can be found under /code/modules/vending/
 */

/*

/obj/machinery/vending/[vendors name here]   // --vending machine template   :)
	name = ""
	desc = ""
	icon = ''
	icon_state = ""
	products = list()
	contraband = list()
	premium = list()
*/

#define MAX_VENDING_INPUT_AMOUNT 30
/**
  * # vending record datum
  *
  * A datum that represents a product that is vendable
  */
/datum/vending_product
	var/name = "generic"
	///Typepath of the product that is created when this record "sells"
	var/product_path = null
	///How many of this product we currently have
	var/amount = 0
	///How many we can store at maximum
	var/max_amount = 0
	///Does the item have a custom price override
	var/custom_price
	///Does the item have a custom premium price override
	var/custom_premium_price
	///Whether the product can be recolored by the GAGS system
	var/colorable
	///List of items that have been returned to the vending machine.
	var/list/returned_products
	/// The category the product was in, if any.
	/// Sourced directly from product_categories.
	var/category

/**
  * # vending machines
  *
  * Captalism in the year 2525, everything in a vending machine, even love
  */
/obj/machinery/vending
	name = "\improper Vendomat"
	desc = "A generic vending machine."
	icon = 'icons/obj/vending.dmi'
	icon_state = "generic"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	max_integrity = 300
	integrity_failure = 0.33
	armor_type = /datum/armor/machinery_vending
	circuit = /obj/item/circuitboard/machine/vendor
	clicksound = 'sound/machines/pda_button1.ogg'
	dept_req_for_free = ACCOUNT_SRV_BITFLAG

	light_power = 0.5
	light_range = MINIMUM_USEFUL_LIGHT_RANGE

	/// Is the machine active (No sales pitches if off)!
	var/active = 1
	///Are we ready to vend?? Is it time??
	var/vend_ready = TRUE
	///The ref of the last mob to shop with us
	var/last_shopper
	var/tilted = FALSE
	var/tiltable = TRUE
	var/squish_damage = 75
	var/forcecrit = 0
	var/num_shards = 7
	var/list/pinned_mobs = list()
	COOLDOWN_DECLARE(purchase_message_cooldown)

	/**
	  * List of products this machine sells
	  *
	  *	form should be list(/type/path = amount, /type/path2 = amount2)
	  */
	var/list/products = list()

	/**
	 * List of products this machine sells, categorized.
	 * Can only be used as an alternative to `products`, not alongside it.
	 *
	 * Form should be list(
	 * 	"name" = "Category Name",
	 * 	"icon" = "UI Icon (Font Awesome or tgfont)",
	 * 	"products" = list(/type/path = amount, ...),
	 * )
	 */
	var/list/product_categories = null

	/**
	  * List of products this machine sells when you hack it
	  *
	  *	form should be list(/type/path = amount, /type/path2 = amount2)
	  */
	var/list/contraband	= list()

	/**
	  * List of premium products this machine sells
	  *
	  *	form should be list(/type/path, /type/path2) as there is only ever one in stock
	  */
	var/list/premium 	= list()

	///String of slogans separated by semicolons, optional
	var/product_slogans = ""
	///String of small ad messages in the vending screen - random chance
	var/product_ads = ""

	var/list/product_records = list()
	var/list/hidden_records = list()
	var/list/coin_records = list()
	var/list/slogan_list = list()
	///Small ad messages in the vending screen - random chance of popping up whenever you open it
	var/list/small_ads = list()
	///Message sent post vend (Thank you for shopping!)
	var/vend_reply
	///Last world tick we sent a vent reply
	var/last_reply = 0
	///Last world tick we sent a slogan message out
	var/last_slogan = 0
	///How many ticks until we can send another
	var/slogan_delay = 6000
	///Icon when vending an item to the user
	var/icon_vend
	///Icon to flash when user is denied a vend
	var/icon_deny
	///World ticks the machine is electified for
	var/seconds_electrified = MACHINE_NOT_ELECTRIFIED
	///When this is TRUE, we fire items at customers! We're broken!
	var/shoot_inventory = 0
	///How likely this is to happen (prob 100) per second
	var/shoot_inventory_chance = 1
	//Stop spouting those godawful pitches!
	var/shut_up = 0
	///can we access the hidden inventory?
	var/extended_inventory = 0
	///Are we checking the users ID
	var/scan_id = 1
	///Default price of items if not overridden
	var/default_price = 25
	///Default price of premium items if not overridden
	var/extra_price = 50
	/**
	  * Is this item on station or not
	  *
	  * if it doesn't originate from off-station during mapload, everything is free
	  */
	var/onstation = TRUE //if it doesn't originate from off-station during mapload, everything is free

	///A variable to change on a per instance basis on the map that allows the instance to force cost and ID requirements
	var/onstation_override = FALSE //change this on the object on the map to override the onstation check. DO NOT APPLY THIS GLOBALLY.

	///ID's that can load this vending machine wtih refills
	var/list/canload_access_list


	var/list/vending_machine_input = list()
	///Display header on the input view
	var/input_display_header = "Custom Compartment"

	//The type of refill canisters used by this machine.
	var/obj/item/vending_refill/refill_canister = null

	/// how many items have been inserted in a vendor
	var/loaded_items = 0

	///Name of lighting mask for the vending machine
	var/light_mask


/datum/armor/machinery_vending
	melee = 20
	fire = 50
	acid = 70

/obj/item/circuitboard
	///determines if the circuit board originated from a vendor off station or not.
	var/onstation = TRUE

/**
  * Initialize the vending machine
  *
  * Builds the vending machine inventory, sets up slogans and other such misc work
  *
  * This also sets the onstation var to:
  * * FALSE - if the machine was maploaded on a zlevel that doesn't pass the is_station_level check
  * * TRUE - all other cases
  */
/obj/machinery/vending/Initialize(mapload)
	var/build_inv = FALSE
	if(!refill_canister)
		circuit = null
		build_inv = TRUE
	. = ..()
	wires = new /datum/wires/vending(src)

	if(build_inv) //non-constructable vending machine
		build_inventories()

	slogan_list = splittext(product_slogans, ";")
	// So not all machines speak at the exact same time.
	// The first time this machine says something will be at slogantime + this random value,
	// so if slogantime is 10 minutes, it will say it at somewhere between 10 and 20 minutes after the machine is crated.
	last_slogan = world.time + rand(0, slogan_delay)
	power_change()

	if(onstation_override) //overrides the checks if true.
		onstation = TRUE
		return
	if(mapload) //check if it was initially created off station during mapload.
		if(!is_station_level(z))
			onstation = FALSE
			if(circuit)
				circuit.onstation = onstation //sync up the circuit so the pricing schema is carried over if it's reconstructed.
	else if(circuit && (circuit.onstation != onstation)) //check if they're not the same to minimize the amount of edited values.
		onstation = circuit.onstation //if it was constructed outside mapload, sync the vendor up with the circuit's var so you can't bypass price requirements by moving / reconstructing it off station.

/obj/machinery/vending/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/vending/can_speak()
	return !shut_up

//Better would be to make constructable child
/obj/machinery/vending/RefreshParts()
	if(!component_parts)
		return

	build_products_from_categories()

	product_records = list()
	hidden_records = list()
	coin_records = list()

	build_inventories(start_empty = TRUE)

	for(var/obj/item/vending_refill/VR in component_parts)
		restock(VR)

/obj/machinery/vending/deconstruct(disassembled = TRUE)
	if(!refill_canister) //the non constructable vendors drop iron instead of a machine frame.
		if(!(flags_1 & NODECONSTRUCT_1))
			new /obj/item/stack/sheet/iron(loc, 3)
		qdel(src)
	else
		..()

/obj/machinery/vending/update_appearance(updates=ALL)
	. = ..()
	if(machine_stat & BROKEN)
		set_light(0)
		return
	set_light(powered() ? MINIMUM_USEFUL_LIGHT_RANGE : 0)


/obj/machinery/vending/update_icon_state()
	if(machine_stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
		return ..()
	icon_state = "[initial(icon_state)][powered() ? null : "-off"]"
	return ..()


/obj/machinery/vending/update_overlays()
	. = ..()
	if(light_mask && !(machine_stat & BROKEN) && powered())
		. += emissive_appearance(icon, light_mask, layer)
		ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)

/obj/machinery/vending/atom_break(damage_flag)
	. = ..()
	if(!.)
		return

	var/dump_amount = 0
	var/found_anything = TRUE
	while (found_anything)
		found_anything = FALSE
		for(var/record in shuffle(product_records))
			var/datum/vending_product/R = record

			//first dump any of the items that have been returned, in case they contain the nuke disk or something
			for(var/obj/returned_obj_to_dump in R.returned_products)
				LAZYREMOVE(R.returned_products, returned_obj_to_dump)
				returned_obj_to_dump.forceMove(get_turf(src))
				step(returned_obj_to_dump, pick(GLOB.alldirs))
				R.amount--

			if(R.amount <= 0) //Try to use a record that actually has something to dump.
				continue
			var/dump_path = R.product_path
			if(!dump_path)
				continue
			R.amount--
			// busting open a vendor will destroy some of the contents
			if(found_anything && prob(80))
				continue

			var/obj/obj_to_dump = new dump_path(loc)
			step(obj_to_dump, pick(GLOB.alldirs))
			found_anything = TRUE
			dump_amount++
			if (dump_amount >= 16)
				return

/**
  * Build the inventory of the vending machine from it's product and record lists
  *
  * This builds up a full set of /datum/vending_products from the product list of the vending machine type
  * Arguments:
  * * productlist - the list of products that need to be converted
  * * recordlist - the list containing /datum/vending_product datums
  * * startempty - should we set vending_product record amount from the product list (so it's prefilled at roundstart)
  */
/obj/machinery/vending/proc/build_inventory(list/productlist, list/recordlist, list/categories, start_empty = FALSE)

	var/list/product_to_category = list()
	for (var/list/category as anything in categories)
		var/list/products = category["products"]
		for (var/product_key in products)
			product_to_category[product_key] = category

	for(var/typepath in productlist)
		var/amount = productlist[typepath]
		if(isnull(amount))
			amount = 0

		var/atom/temp = typepath
		var/datum/vending_product/R = new /datum/vending_product()
		R.name = initial(temp.name)
		R.product_path = typepath
		if(!start_empty)
			R.amount = amount
		R.max_amount = amount
		R.custom_price = initial(temp.custom_price)
		R.custom_premium_price = initial(temp.custom_premium_price)
		R.colorable = !!(initial(temp.greyscale_config) && initial(temp.greyscale_colors) && (initial(temp.flags_1) & IS_PLAYER_COLORABLE_1))
		R.category = product_to_category[typepath]
		recordlist += R

/obj/machinery/vending/proc/build_inventories(start_empty)
	build_inventory(products, product_records, product_categories, start_empty)
	build_inventory(contraband, hidden_records, create_categories_from(contraband, "mask", "Contraband"), start_empty)
	build_inventory(premium, coin_records, create_categories_from(premium, "coins", "Premium"), start_empty)

/obj/machinery/vending/proc/create_categories_from(products, icon, name)
	return list(list(
		"name" = name,
		"icon" = icon,
		"products" = products,
	))

/obj/machinery/vending/proc/build_products_from_categories()
	if (isnull(product_categories))
		return

	products = list()

	for (var/list/category in product_categories)
		var/list/category_products = category["products"]
		for (var/product_key in category_products)
			products[product_key] += category_products[product_key]

/**
  * Refill a vending machine from a refill canister
  *
  * This takes the products from the refill canister and then fills the products,contraband and premium product categories
  *
  * Arguments:
  * * canister - the vending canister we are refilling from
  */
/obj/machinery/vending/proc/restock(obj/item/vending_refill/canister)
	if (!canister.products)
		canister.products = products.Copy()
	if (!canister.contraband)
		canister.contraband = contraband.Copy()
	if (!canister.premium)
		canister.premium = premium.Copy()

	. = 0

	if (isnull(canister.product_categories) && !isnull(product_categories))
		canister.product_categories = product_categories.Copy()

	if (!isnull(canister.product_categories))
		var/list/products_unwrapped = list()
		for (var/list/category as anything in canister.product_categories)
			var/list/products = category["products"]
			for (var/product_key in products)
				products_unwrapped[product_key] += products[product_key]

		. += refill_inventory(products_unwrapped, product_records)
	else
		. += refill_inventory(canister.products, product_records)

	. += refill_inventory(canister.contraband, hidden_records)
	. += refill_inventory(canister.premium, coin_records)

	return .

/**
  * Refill our inventory from the passed in product list into the record list
  *
  * Arguments:
  * * productlist - list of types -> amount
  * * recordlist - existing record datums
  */
/obj/machinery/vending/proc/refill_inventory(list/productlist, list/recordlist)
	. = 0
	for(var/R in recordlist)
		var/datum/vending_product/record = R
		var/diff = min(record.max_amount - record.amount, productlist[record.product_path])
		if (diff)
			productlist[record.product_path] -= diff
			record.amount += diff
			. += diff
/**
  * Set up a refill canister that matches this machines products
  *
  * This is used when the machine is deconstructed, so the items aren't "lost"
  */
/obj/machinery/vending/proc/update_canister()
	if (!component_parts)
		return

	var/obj/item/vending_refill/R = locate() in component_parts
	if (!R)
		CRASH("Constructible vending machine did not have a refill canister")

	unbuild_inventory_into(product_records, R.products, R.product_categories)

	R.contraband = unbuild_inventory(hidden_records)
	R.premium = unbuild_inventory(coin_records)

/**
  * Given a record list, go through and and return a list of type -> amount
  */
/obj/machinery/vending/proc/unbuild_inventory(list/recordlist)
	. = list()
	for(var/R in recordlist)
		var/datum/vending_product/record = R
		.[record.product_path] += record.amount

/// Put stuff in product_categories if the products have a category, otherwise put them in products
/obj/machinery/vending/proc/unbuild_inventory_into(list/product_records, list/products, list/product_categories)
	products?.Cut()
	product_categories?.Cut()

	var/others_have_category = null

	var/list/categories_to_index = list()

	for (var/datum/vending_product/record as anything in product_records)
		var/list/category = record.category
		var/has_category = !isnull(category)

		if (isnull(others_have_category))
			others_have_category = has_category
		else if (others_have_category != has_category)
			if (has_category)
				WARNING("[record.product_path] in [type] has a category, but other products don't")
			else
				WARNING("[record.product_path] in [type] does not have a category, but other products do")

			continue

		if (has_category)
			var/index = categories_to_index.Find(category)

			if (index)
				var/list/category_in_list = product_categories[index]
				var/list/products_in_category = category_in_list["products"]
				products_in_category[record.product_path] += record.amount
			else
				categories_to_index += list(category)
				index = categories_to_index.len

				var/list/category_clone = category.Copy()

				var/list/initial_product_list = list()
				initial_product_list[record.product_path] = record.amount
				category_clone["products"] = initial_product_list

				product_categories += list(category_clone)
		else
			products[record.product_path] = record.amount

/obj/machinery/vending/crowbar_act(mob/living/user, obj/item/I)
	if(!component_parts)
		return FALSE
	default_deconstruction_crowbar(I)
	return TRUE

/obj/machinery/vending/wrench_act(mob/living/user, obj/item/I)
	..()
	if(!panel_open)
		return FALSE
	if(default_unfasten_wrench(user, I, time = 6 SECONDS))
		unbuckle_all_mobs(TRUE)
		return TOOL_ACT_TOOLTYPE_SUCCESS
	return FALSE

/obj/machinery/vending/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(anchored || (!anchored && !panel_open))
		default_deconstruction_screwdriver(user, icon_state, icon_state, I)
		cut_overlays()
		if(panel_open)
			add_overlay("[initial(icon_state)]-panel")
	else
		to_chat(user, span_warning("You must first secure [src]."))
	return TRUE

/obj/machinery/vending/attackby(obj/item/I, mob/living/user, params)
	if(panel_open && is_wire_tool(I))
		wires.interact(user)
		return

	if(refill_canister && istype(I, refill_canister))
		if (!panel_open)
			to_chat(user, span_notice("You should probably unscrew the service panel first."))
		else if (machine_stat & (BROKEN|NOPOWER))
			to_chat(user, span_notice("[src] does not respond."))
		else
			//if the panel is open we attempt to refill the machine
			var/obj/item/vending_refill/canister = I
			if(canister.get_part_rating() == 0)
				to_chat(user, span_notice("[canister] is empty!"))
			else
				// instantiate canister if needed
				var/transferred = restock(canister)
				if(transferred)
					to_chat(user, span_notice("You loaded [transferred] items in [src]."))
				else
					to_chat(user, span_notice("There's nothing to restock!"))
			return
	if(compartmentLoadAccessCheck(user) && !user.combat_mode)
		if(canLoadItem(I))
			loadingAttempt(I,user)
			ui_update()

		if(istype(I, /obj/item/storage/bag)) //trays USUALLY
			var/obj/item/storage/T = I
			var/loaded = 0
			var/denied_items = 0
			for(var/obj/item/the_item in T.contents)
				if(contents.len >= MAX_VENDING_INPUT_AMOUNT) // no more than 30 item can fit inside, legacy from snack vending although not sure why it exists
					to_chat(user, span_warning("[src]'s compartment is full."))
					break
				if(canLoadItem(the_item) && loadingAttempt(the_item,user))
					T.atom_storage?.attempt_remove(the_item, src)
					loaded++
				else
					denied_items++
			if(denied_items)
				to_chat(user, span_warning("[src] refuses some items!"))
			if(loaded)
				to_chat(user, span_notice("You insert [loaded] dishes into [src]'s compartment."))
				ui_update()
	else
		. = ..()
		if(tiltable && !tilted && I.force)
			switch(rand(1, 100))
				if(1 to 5)
					freebie(user, 3)
				if(6 to 15)
					freebie(user, 2)
				if(16 to 25)
					freebie(user, 1)
				if(26 to 40)
					tilt(user)
				if(41 to 50)
					tilt(user, crit=TRUE)
				if(51 to 100)
					pass()

/obj/machinery/vending/proc/freebie(mob/fatty, freebies)
	visible_message(span_notice("[src] yields [freebies > 1 ? "several free goodies" : "a free goody"]!"))

	for(var/i in 1 to freebies)
		playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = -3)
		for(var/datum/vending_product/R in shuffle(product_records))

			if(R.amount <= 0) //Try to use a record that actually has something to dump.
				continue
			var/dump_path = R.product_path
			if(!dump_path)
				continue
			if(R.amount > LAZYLEN(R.returned_products)) //always give out new stuff that costs before free returned stuff, because of the risk getting gibbed involved
				new dump_path(get_turf(src))
			else
				var/obj/returned_obj_to_dump = LAZYACCESS(R.returned_products, LAZYLEN(R.returned_products)) //first in, last out
				LAZYREMOVE(R.returned_products, returned_obj_to_dump)
				returned_obj_to_dump.forceMove(get_turf(src))
			R.amount--
			break

/obj/machinery/vending/proc/tilt(mob/fatty, crit=FALSE)
	if(QDELETED(src))
		return
	visible_message(span_danger("[src] tips over!"))
	tilted = TRUE
	layer = ABOVE_MOB_LAYER

	var/crit_case
	if(crit)
		crit_case = rand(1,5)

	if(forcecrit)
		crit_case = forcecrit

	if(in_range(fatty, src))
		for(var/mob/living/L in get_turf(fatty))
			var/mob/living/carbon/C = L

			if(istype(C))
				var/crit_rebate = 0 // lessen the normal damage we deal for some of the crits

				if(crit_case != 5) // the head asplode case has its own description
					C.visible_message(span_danger("[C] is crushed by [src]!"), \
						span_userdanger("You are crushed by [src]!"))

				switch(crit_case) // only carbons can have the fun crits
					if(1) // shatter their legs and bleed 'em
						crit_rebate = 60
						C.bleed(150)
						var/obj/item/bodypart/l_leg/l = C.get_bodypart(BODY_ZONE_L_LEG)
						if(l)
							l.receive_damage(brute=200, updating_health=TRUE)
						var/obj/item/bodypart/r_leg/r = C.get_bodypart(BODY_ZONE_R_LEG)
						if(r)
							r.receive_damage(brute=200, updating_health=TRUE)
						if(l || r)
							C.visible_message(span_danger("[C]'s legs shatter with a sickening crunch!"), \
								span_userdanger("Your legs shatter with a sickening crunch!"))
					if(2) // pin them beneath the machine until someone untilts it
						forceMove(get_turf(C))
						buckle_mob(C, force=TRUE)
						C.visible_message(span_danger("[C] is pinned underneath [src]!"), \
							span_userdanger("You are pinned down by [src]!"))
					if(3) // glass candy
						crit_rebate = 50
						for(var/i in 1 to num_shards)
							var/obj/item/shard/shard = new /obj/item/shard(get_turf(C))
							shard.embedding = list(embed_chance = 10000, ignore_throwspeed_threshold = TRUE, impact_pain_mult=1, pain_chance=5)
							shard.updateEmbedding()
							C.hitby(shard, skipcatch = TRUE, hitpush = FALSE)
							shard.embedding = list()
							shard.updateEmbedding()
					if(4) // paralyze this binch
						// the new paraplegic gets like 4 lines of losing their legs so skip them
						visible_message(span_danger("[C]'s spinal cord is obliterated with a sickening crunch!"))
						C.gain_trauma(/datum/brain_trauma/severe/paralysis/paraplegic)
					if(5) // skull squish!
						var/obj/item/bodypart/head/O = C.get_bodypart(BODY_ZONE_HEAD)
						if(O)
							C.visible_message(span_danger("[O] explodes in a shower of gore beneath [src]!"), \
								span_userdanger("Oh f-"))
							O.dismember()
							O.drop_organs()
							qdel(O)
							new /obj/effect/gibspawner/human/bodypartless(get_turf(C))

				C.apply_damage(max(0, squish_damage - crit_rebate), forced=TRUE)
				C.AddElement(/datum/element/squish, 80 SECONDS)
			else
				L.visible_message(span_danger("[L] is crushed by [src]!"), \
				span_userdanger("You are crushed by [src]!"))
				L.apply_damage(squish_damage, forced=TRUE)
				if(crit_case)
					L.apply_damage(squish_damage, forced=TRUE)

			L.Paralyze(60)
			L.emote("scream")
			playsound(L, 'sound/effects/blobattack.ogg', 40, TRUE)
			playsound(L, 'sound/effects/splat.ogg', 50, TRUE)

	var/matrix/M = matrix()
	M.Turn(pick(90, 270))
	transform = M

	if(get_turf(fatty) != get_turf(src))
		throw_at(get_turf(fatty), 1, 1, spin=FALSE)

/obj/machinery/vending/proc/untilt(mob/user)
	user.visible_message(span_notice("[user] rights [src]."), \
		span_notice("You right [src]."))

	unbuckle_all_mobs(TRUE)

	tilted = FALSE
	layer = initial(layer)

	var/matrix/M = matrix()
	M.Turn(0)
	transform = M

/obj/machinery/vending/proc/loadingAttempt(obj/item/I, mob/user)
	. = TRUE
	if(!user.transferItemToLoc(I, src))
		return FALSE
	to_chat(user, span_notice("You insert [I] into [src]'s input compartment."))

	for(var/datum/vending_product/product_datum in product_records + coin_records + hidden_records)
		if(ispath(I.type, product_datum.product_path))
			product_datum.amount++
			LAZYADD(product_datum.returned_products, I)
			return

	if(vending_machine_input[format_text(I.name)])
		vending_machine_input[format_text(I.name)]++
	else
		vending_machine_input[format_text(I.name)] = 1
	loaded_items++

/obj/machinery/vending/unbuckle_mob(mob/living/buckled_mob, force=FALSE)
	if(!force)
		return
	. = ..()

/**
  * Is the passed in user allowed to load this vending machines compartments
  *
  * Arguments:
  * * user - mob that is doing the loading of the vending machine
  */
/obj/machinery/vending/proc/compartmentLoadAccessCheck(mob/user)
	if(!canload_access_list)
		return TRUE
	else
		var/do_you_have_access = FALSE
		var/req_access_txt_holder = req_access_txt
		for(var/i in canload_access_list)
			req_access_txt = i
			if(!allowed(user) && !(obj_flags & EMAGGED) && scan_id)
				continue
			else
				do_you_have_access = TRUE
				break //you passed don't bother looping anymore
		req_access_txt = req_access_txt_holder // revert to normal (before the proc ran)
		if(do_you_have_access)
			return TRUE
		else
			to_chat(user, span_warning("[src]'s input compartment blinks red: Access denied."))
			return FALSE

/obj/machinery/vending/exchange_parts(mob/user, obj/item/storage/part_replacer/W)
	if(!istype(W))
		return FALSE
	if((flags_1 & NODECONSTRUCT_1) && !W.works_from_distance)
		return FALSE
	if(!component_parts || !refill_canister)
		return FALSE

	var/moved = 0
	if(panel_open || W.works_from_distance)
		if(W.works_from_distance)
			display_parts(user)
		for(var/I in W)
			if(istype(I, refill_canister))
				moved += restock(I)
	else
		display_parts(user)
	if(moved)
		to_chat(user, span_notice("[moved] items restocked."))
		W.play_rped_sound()
	return TRUE

/obj/machinery/vending/on_deconstruction()
	update_canister()
	. = ..()

/obj/machinery/vending/on_emag(mob/user)
	..()
	to_chat(user, span_notice("You short out the product lock on [src]."))

/obj/machinery/vending/_try_interact(mob/user)
	if(seconds_electrified && !(machine_stat & NOPOWER))
		if(shock(user, 100))
			return

	if(tilted && !user.buckled && !isAI(user))
		to_chat(user, span_notice("You begin righting [src]."))
		if(do_after(user, 50, target=src))
			untilt(user)
		return

	return ..()

/obj/machinery/vending/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/vending),
	)

/obj/machinery/vending/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Vending", name)
		ui.open()

/obj/machinery/vending/ui_static_data(mob/user)
	var/list/data = list()
	data["onstation"] = onstation
	data["department_bitflag"] = dept_req_for_free
	data["product_records"] = list()

	var/list/categories = list()

	data["product_records"] = collect_records_for_static_data(product_records, categories)
	data["coin_records"] = collect_records_for_static_data(coin_records, categories, premium = TRUE)
	data["hidden_records"] = collect_records_for_static_data(hidden_records, categories, premium = TRUE)

	data["categories"] = categories

	return data

/obj/machinery/vending/proc/collect_records_for_static_data(list/records, list/categories, premium)
	var/static/list/default_category = list(
		"name" = "Products",
		"icon" = "cart-shopping",
	)

	var/list/out_records = list()

	for (var/datum/vending_product/record as anything in records)
		var/list/static_record = list(
			path = replacetext(replacetext("[record.product_path]", "/obj/item/", ""), "/", "-"),
			name = record.name,
			price = premium ? (record.custom_premium_price || extra_price) : (record.custom_price || default_price),
			max_amount = record.max_amount,
			ref = REF(record),
		)

		var/list/category = record.category || default_category
		if (!isnull(category))
			if (!(category["name"] in categories))
				categories[category["name"]] = list(
					"icon" = category["icon"],
				)

			static_record["category"] = category["name"]

		if (premium)
			static_record["premium"] = TRUE

		out_records += list(static_record)

	return out_records

/obj/machinery/vending/ui_data(mob/user)
	. = list()
	var/mob/living/carbon/human/H
	var/obj/item/card/id/card
	.["user"] = null
	if(ishuman(user))
		H = user
		card = H.get_idcard(TRUE)

		.["user"] = list()
		if(card?.registered_account)
			.["user"]["name"] = card.registered_account.account_holder
		else
			.["user"]["name"] = H.name
		.["user"]["cash"] = H.get_accessible_cash()
		.["user"]["job"] = "No Job"
		.["user"]["department_bitflag"] = 0
		var/datum/record/crew/R = find_record(card?.registered_account?.account_holder, GLOB.manifest.general)
		if(card?.registered_account?.account_job)
			.["user"]["job"] = card.registered_account.account_job.title
			.["user"]["department_bitflag"] = card.registered_account.active_departments
		if(R)
			.["user"]["job"] = R.rank
	.["stock"] = list()

	for (var/datum/vending_product/product_record in product_records + coin_records + hidden_records)
		var/list/product_data = list(
			name = product_record.name,
			amount = product_record.amount,
			colorable = product_record.colorable,
		)

		.["stock"][product_record.name] = product_data

	.["extended_inventory"] = extended_inventory

/obj/machinery/vending/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("vend")
			. = vend(params)
		if("select_colors")
			. = select_colors(params)

/obj/machinery/vending/proc/can_vend(user, silent=FALSE)
	. = FALSE
	if(!vend_ready)
		return
	if(panel_open)
		to_chat(user, span_warning("The vending machine cannot dispense products while its service panel is open!"))
		return
	return TRUE

/obj/machinery/vending/proc/select_colors(list/params)
	. = TRUE
	if(!can_vend(usr))
		return
	var/datum/vending_product/product = locate(params["ref"])
	var/atom/fake_atom = product.product_path

	var/list/allowed_configs = list()
	var/config = initial(fake_atom.greyscale_config)
	if(!config)
		return
	allowed_configs += "[config]"
	if(ispath(fake_atom, /obj/item))
		var/obj/item/item = fake_atom
		if(initial(item.greyscale_config_worn))
			allowed_configs += "[initial(item.greyscale_config_worn)]"
		if(initial(item.greyscale_config_inhand_left))
			allowed_configs += "[initial(item.greyscale_config_inhand_left)]"
		if(initial(item.greyscale_config_inhand_right))
			allowed_configs += "[initial(item.greyscale_config_inhand_right)]"

	var/datum/greyscale_modify_menu/menu = new(
		src, usr, allowed_configs, CALLBACK(src, PROC_REF(vend_greyscale), params),
		starting_icon_state=initial(fake_atom.icon_state),
		starting_config=initial(fake_atom.greyscale_config),
		starting_colors=initial(fake_atom.greyscale_colors)
	)
	menu.ui_interact(usr)

/obj/machinery/vending/proc/vend_greyscale(list/params, datum/greyscale_modify_menu/menu)
	if(usr != menu.user)
		return
	if(!menu.target.can_interact(usr))
		return
	vend(params, menu.split_colors)

/obj/machinery/vending/proc/vend(list/params, list/greyscale_colors)
	. = TRUE
	if(!can_vend(usr))
		return
	vend_ready = FALSE //One thing at a time!!
	var/datum/vending_product/R = locate(params["ref"])
	var/list/record_to_check = product_records + coin_records
	if(extended_inventory)
		record_to_check = product_records + coin_records + hidden_records
	if(!R || !istype(R) || !R.product_path)
		vend_ready = TRUE
		return
	var/price_to_use = default_price
	if(R.custom_price)
		price_to_use = R.custom_price
	if(R in hidden_records)
		if(!extended_inventory)
			vend_ready = TRUE
			return
	else if (!(R in record_to_check))
		vend_ready = TRUE
		message_admins("Vending machine exploit attempted by [ADMIN_LOOKUPFLW(usr)]!")
		return
	if (R.amount <= 0)
		say("Sold out of [R.name].")
		flick(icon_deny,src)
		vend_ready = TRUE
		return
	if(onstation)
		var/obj/item/card/id/C
		if(isliving(usr))
			var/mob/living/L = usr
			C = L.get_idcard(TRUE)
		if(!C)
			say("No card found.")
			flick(icon_deny,src)
			vend_ready = TRUE
			return
		else if (!C.registered_account)
			say("No account found.")
			flick(icon_deny,src)
			vend_ready = TRUE
			return
		// Department cards cannot be used to order stuff in vendors, we make an exception for the debug card
		else if(!C.registered_account.account_job && !istype(C, /obj/item/card/id/syndicate/debug))
			say("Departmental accounts have been blacklisted from personal expenses due to embezzlement.")
			flick(icon_deny, src)
			vend_ready = TRUE
			return
		var/datum/bank_account/account = C.registered_account
		if(account.account_job && (account.active_departments & dept_req_for_free))
			price_to_use = 0
		if(coin_records.Find(R) || hidden_records.Find(R))
			price_to_use = R.custom_premium_price ? R.custom_premium_price : extra_price
		if(LAZYLEN(R.returned_products))
			price_to_use = 0 //returned items are free
		if(price_to_use && !account.adjust_money(-price_to_use))
			say("You do not possess the funds to purchase [R.name].")
			flick(icon_deny,src)
			vend_ready = TRUE
			return
		if(price_to_use && seller_department)
			var/list/dept_list = SSeconomy.get_dept_id_by_bitflag(seller_department)
			if(length(dept_list))
				price_to_use = round(price_to_use/length(dept_list))
				for(var/datum/bank_account/department/D in dept_list)
					if(D)
						D.adjust_money(price_to_use)
						SSblackbox.record_feedback("amount", "vending_spent", price_to_use)
						log_econ("[price_to_use] credits were inserted into [src] by [D.account_holder] to buy [R].")

	if(last_shopper != REF(usr) || purchase_message_cooldown < world.time)
		say("Thank you for shopping with [src]!")
		purchase_message_cooldown = world.time + 5 SECONDS
		last_shopper = REF(usr)
	use_power(5)
	if(icon_vend) //Show the vending animation if needed
		flick(icon_vend,src)
	playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = -3)
	var/obj/item/vended_item
	if(!LAZYLEN(R.returned_products)) //always give out free returned stuff first, e.g. to avoid walling a traitor objective in a bag behind paid items
		vended_item = new R.product_path(get_turf(src))
	else
		vended_item = LAZYACCESS(R.returned_products, LAZYLEN(R.returned_products)) //first in, last out
		LAZYREMOVE(R.returned_products, vended_item)
		vended_item.forceMove(get_turf(src))
	if(greyscale_colors)
		vended_item.set_greyscale(colors=greyscale_colors)
	R.amount--
	if(usr.CanReach(src) && usr.put_in_hands(vended_item))
		to_chat(usr, span_notice("You take [R.name] out of the slot."))
	else
		to_chat(usr, span_warning("[capitalize(R.name)] falls onto the floor!"))
	SSblackbox.record_feedback("nested tally", "vending_machine_usage", 1, list("[type]", "[R.product_path]"))
	vend_ready = TRUE

/obj/machinery/vending/process(delta_time)
	if(machine_stat & (BROKEN|NOPOWER))
		return PROCESS_KILL
	if(!active)
		return

	if(seconds_electrified > MACHINE_NOT_ELECTRIFIED)
		seconds_electrified--
		if(seconds_electrified <= MACHINE_NOT_ELECTRIFIED)
			wires.ui_update()

	//Pitch to the people!  Really sell it!
	if(last_slogan + slogan_delay <= world.time && slogan_list.len > 0 && !shut_up && DT_PROB(2.5, delta_time))
		var/slogan = pick(slogan_list)
		speak(slogan)
		last_slogan = world.time

	if(shoot_inventory && DT_PROB(shoot_inventory_chance, delta_time))
		throw_item()
/**
  * Speak the given message verbally
  *
  * Checks if the machine is powered and the message exists
  *
  * Arguments:
  * * message - the message to speak
  */
/obj/machinery/vending/proc/speak(message)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	if(!message)
		return

	say(message)

/obj/machinery/vending/power_change()
	. = ..()
	if(powered())
		START_PROCESSING(SSmachines, src)

//Somebody cut an important wire and now we're following a new definition of "pitch."
/**
  * Throw an item from our internal inventory out in front of us
  *
  * This is called when we are hacked, it selects a random product from the records that has an amount > 0
  * This item is then created and tossed out in front of us with a visible message
  */
/obj/machinery/vending/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7,src)
	if(!target || target.incorporeal_move >= INCORPOREAL_MOVE_BASIC)
		return FALSE

	for(var/datum/vending_product/R in shuffle(product_records))
		if(R.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		var/dump_path = R.product_path
		if(!dump_path)
			continue
		if(R.amount > LAZYLEN(R.returned_products)) //always throw new stuff that costs before free returned stuff, because of the hacking effort and time between throws involved
			throw_item = new dump_path(loc)
		else
			throw_item = LAZYACCESS(R.returned_products, LAZYLEN(R.returned_products)) //first in, last out
			throw_item.forceMove(loc)
			LAZYREMOVE(R.returned_products, throw_item)
		R.amount--
		break
	if(!throw_item)
		return FALSE

	pre_throw(throw_item)

	throw_item.throw_at(target, 16, 3)
	visible_message(span_danger("[src] launches [throw_item] at [target]!"))
	ui_update()
	return TRUE
/**
  * A callback called before an item is tossed out
  *
  * Override this if you need to do any special case handling
  *
  * Arguments:
  * * I - obj/item being thrown
  */
/obj/machinery/vending/proc/pre_throw(obj/item/I)
	return
/**
  * Shock the passed in user
  *
  * This checks we have power and that the passed in prob is passed, then generates some sparks
  * and calls electrocute_mob on the user
  *
  * Arguments:
  * * user - the user to shock
  * * prb - probability the shock happens
  */
/obj/machinery/vending/proc/shock(mob/user, prb)
	if(machine_stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return FALSE
	if(!prob(prb))
		return FALSE
	do_sparks(5, TRUE, src)
	var/check_range = TRUE
	if(electrocute_mob(user, get_area(src), src, 0.7, check_range))
		return TRUE
	else
		return FALSE
/**
  * Are we able to load the item passed in
  *
  * Arguments:
  * * I - the item being loaded
  * * user - the user doing the loading
  */
/obj/machinery/vending/proc/canLoadItem(obj/item/I, mob/user)
	if((I.type in products) || (I.type in premium) || (I.type in contraband))
		return TRUE
	balloon_alert(user, "[src] does not accept [I]!")
	return FALSE

/obj/machinery/vending/onTransitZ()
	return

/obj/machinery/vending/custom
	name = "Custom Vendor"
	icon_state = "robotics"
	icon_deny = "robotics-deny"
	light_mask = "robotics-light-mask"
	max_integrity = 400
	dept_req_for_free = NO_FREEBIES
	refill_canister = /obj/item/vending_refill/custom
	/// where the money is sent
	var/datum/bank_account/private_a
	/// max number of items that the custom vendor can hold
	var/max_loaded_items = 100
	/// Base64 cache of custom icons.
	var/list/base64_cache = list()

/obj/machinery/vending/custom/examine(mob/user)
	. = ..()
	if(private_a)
		if(private_a.account_job)
			. += span_notice("It's owned by [private_a.account_holder], a [private_a.account_job.title].")
		else
			. += span_notice("It's owned by [private_a.account_holder]")
	else
		. += span_notice("It's not owned by anyone!")

/obj/machinery/vending/custom/compartmentLoadAccessCheck(mob/user)
	. = FALSE
	var/mob/living/carbon/human/H
	var/obj/item/card/id/C
	if(ishuman(user))
		H = user
		C = H.get_idcard(TRUE)
		if(C?.registered_account && C.registered_account == private_a)
			return TRUE

/obj/machinery/vending/custom/canLoadItem(obj/item/I, mob/user)
	. = FALSE
	if(I.flags_1 & HOLOGRAM_1)
		say("This vendor cannot accept nonexistent items.")
		return
	if(loaded_items >= max_loaded_items)
		say("There are too many items in stock.")
		return
	if(isstack(I))
		say("Loose items may cause problems, try to use it inside wrapping paper.")
		return
	if(I.custom_price)
		return TRUE

/obj/machinery/vending/custom/ui_data(mob/user)
	. = ..()
	.["access"] = compartmentLoadAccessCheck(user)
	.["vending_machine_input"] = list()
	.["stock"] = list()
	for (var/O in vending_machine_input)
		if(vending_machine_input[O] > 0)
			var/base64
			var/item_price = 0
			var/item_path
			for(var/obj/T in contents)
				if(format_text(T.name) == O)
					item_price = T.custom_price
					item_path = T.type
					if(!base64)
						if(base64_cache["[T.icon]_[T.icon_state]"])
							base64 = base64_cache["[T.icon]_[T.icon_state]"]
						else
							base64 = icon2base64(getFlatIcon(T, no_anim=TRUE))
							base64_cache["[T.icon]_[T.icon_state]"] = base64
					break
			var/list/data = list(
				name = O,
				price = item_price,
				img = base64,
				amount = vending_machine_input[O],
				colorable = FALSE,
				path = "[replacetext(replacetext("[item_path]", "/obj/item/", ""), "/", "-")]-[O]"
			)
			.["stock"]["[replacetext(replacetext("[item_path]", "/obj/item/", ""), "/", "-")]-[O]"] = vending_machine_input[O]
			.["vending_machine_input"] += list(data)

/obj/machinery/vending/custom/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("dispense")
			if(!vend_ready)
				return
			var/N = params["item"]
			var/obj/S
			vend_ready = FALSE
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				var/obj/item/card/id/C = H.get_idcard(TRUE)

				for(var/obj/O in contents)
					if(format_text(O.name) == N)
						S = O
						break
				if(S)
					if(compartmentLoadAccessCheck(usr))
						vending_machine_input[N] = max(vending_machine_input[N] - 1, 0)
						S.forceMove(drop_location())
						if (usr.CanReach(src) && usr.put_in_hands(S))
							to_chat(usr, span_notice("You take [S.name] out of the slot."))
						else
							to_chat(usr, span_warning("[capitalize(S.name)] falls onto the floor!"))
						loaded_items--
						use_power(5)
						vend_ready = TRUE
						return TRUE
					//var/datum/bank_account/account = C?.registered_account
					if(H.spend_cash(S.custom_price))
						make_purchase(S, H, N)
						return TRUE
					else
						var/additional_message = ""
						if(!C)
							additional_message += "No ID card found. "
						if(!C?.registered_account)
							additional_message += "No account found. "
						say("[additional_message]Not enough funds to purchase [S.name].")
						flick(icon_deny,src)
						vend_ready = TRUE
						return
			vend_ready = TRUE

/obj/machinery/vending/custom/proc/make_purchase(var/obj/bought_item, var/mob/living/carbon/human/H, var/N)
	var/datum/bank_account/owner = private_a
	if(owner)
		owner.adjust_money(bought_item.custom_price)
		SSblackbox.record_feedback("amount", "vending_spent", bought_item.custom_price)
		log_econ("[bought_item.custom_price] credits were spent on [src] buying a [bought_item] by [owner.account_holder], owned by [private_a.account_holder].")
		var/obj/item/card/id/id_card = H.get_idcard(TRUE)
		if(id_card)
			owner.bank_card_talk("[id_card.registered_name] has bought \a [bought_item] for [bought_item.custom_price] credits at your [name]!")
		else
			owner.bank_card_talk("[H.name] has bought \a [bought_item] for [bought_item.custom_price] credits at your [name]!")
	SSblackbox.record_feedback("amount", "vending_spent", bought_item.custom_price)
	vending_machine_input[N] = max(vending_machine_input[N] - 1, 0)
	bought_item.forceMove(drop_location())
	if (usr.CanReach(src) && usr.put_in_hands(bought_item))
		to_chat(usr, span_notice("You take [bought_item.name] out of the slot."))
	else
		to_chat(usr, span_warning("[capitalize(bought_item.name)] falls onto the floor!"))
	playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = -3)
	loaded_items--
	use_power(5)
	if(last_shopper != REF(usr) || COOLDOWN_FINISHED(src, purchase_message_cooldown))
		say("Thank you for buying local and purchasing [bought_item]!")
		COOLDOWN_START(src, purchase_message_cooldown, (5 SECONDS))
		last_shopper = REF(usr)
	vend_ready = TRUE

/obj/machinery/vending/custom/attackby(obj/item/I, mob/user, params)
	if(!private_a)
		var/mob/living/carbon/human/H
		var/obj/item/card/id/C
		if(ishuman(user))
			H = user
			C = H.get_idcard(TRUE)
			if(C?.registered_account)
				private_a = C.registered_account
				say("\The [src] has been linked to [C].")

	if(compartmentLoadAccessCheck(user))
		if(istype(I, /obj/item/pen))
			name = stripped_input(user,"Set name","Name", name, 20)
			desc = stripped_input(user,"Set description","Description", desc, 60)
			slogan_list += stripped_input(user,"Set slogan","Slogan","Epic", 60)
			last_slogan = world.time + rand(0, slogan_delay)
			return

	return ..()

/obj/machinery/vending/custom/crowbar_act(mob/living/user, obj/item/I)
	return FALSE

/obj/machinery/vending/custom/Destroy()
	unbuckle_all_mobs(TRUE)
	var/turf/T = get_turf(src)
	if(T)
		for(var/obj/item/I in contents)
			I.forceMove(T)
		explosion(T, -1, 0, 3)
	return ..()

/obj/machinery/vending/custom/unbreakable
	name = "Indestructible Vendor"
	resistance_flags = INDESTRUCTIBLE

/obj/item/vending_refill/custom
	machine_name = "Custom Vendor"
	icon_state = "refill_custom"
	custom_premium_price = 75

/obj/item/price_tagger
	name = "price tagger"
	desc = "This tool is used to set a price for items used in custom vendors."
	icon = 'icons/obj/device.dmi'
	icon_state = "pricetagger"
	custom_premium_price = 20
	///the price of the item
	var/price = 1

/obj/item/price_tagger/attack_self(mob/user)
	price = max(1, round(input(user,"set price","price") as num|null, 1))
	to_chat(user, span_notice(" The [src] will now give things a [price] cr tag."))

/obj/item/price_tagger/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(isitem(target))
		var/obj/item/I = target
		I.custom_price = price
		if(atom_storage)
			for(var/atom/A in I.contents)
				A.custom_price = price
			to_chat(user, span_notice("You set the price of [I] and everything inside of it to [price] cr."))
		else
			to_chat(user, span_notice("You set the price of [I] to [price] cr."))
