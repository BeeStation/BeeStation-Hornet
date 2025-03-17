/*
 *	These absorb the functionality of the plant bag, ore satchel, etc.
 *	They use the use_to_pickup, quick_gather, and quick_empty functions
 *	that were already defined in weapon/storage, but which had been
 *	re-implemented in other classes.
 *
 *	Contains:
 *		Trash Bag
 *		Mining Satchel
 *		Plant Bag
 *		Sheet Snatcher
 *		Book Bag
 *      Biowaste Bag
 * 		mail bag
 *
 *	-Sayu
 */

//  Generic non-item
/obj/item/storage/bag
	slot_flags = ITEM_SLOT_BELT

/obj/item/storage/bag/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.allow_quick_gather = TRUE
	STR.allow_quick_empty = TRUE
	STR.display_numerical_stacking = TRUE
	STR.click_gather = TRUE

// -----------------------------
//          Trash bag
// -----------------------------
/obj/item/storage/bag/trash
	name = "trash bag"
	desc = "It's the heavy-duty black polymer kind. Time to take out the trash!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "trashbag"
	item_state = "trashbag"
	worn_icon_state = "trashbag"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	var/insertable = TRUE

/obj/item/storage/bag/trash/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.max_combined_w_class = 30
	STR.max_items = 30
	STR.set_holdable(null, list(/obj/item/disk/nuclear))
	STR.can_be_opened = FALSE //Have to dump a trash bag out to look at its contents

/obj/item/storage/bag/trash/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] puts [src] over [user.p_their()] head and starts chomping at the insides! Disgusting!"))
	playsound(loc, 'sound/items/eatfood.ogg', 50, 1, -1)
	return TOXLOSS

/obj/item/storage/bag/trash/update_icon_state()
	switch(contents.len)
		if(20 to INFINITY)
			icon_state = "[initial(icon_state)]3"
		if(11 to 20)
			icon_state = "[initial(icon_state)]2"
		if(1 to 11)
			icon_state = "[initial(icon_state)]1"
		else
			icon_state = "[initial(icon_state)]"
	return ..()

/obj/item/storage/bag/trash/cyborg
	insertable = FALSE

/obj/item/storage/bag/trash/proc/janicart_insert(mob/user, obj/structure/janitorialcart/J)
	if(insertable)
		J.put_in_cart(src, user)
		J.mybag=src
		J.update_icon()
	else
		to_chat(user, span_warning("You are unable to fit your [name] into the [J.name]."))
		return

/obj/item/storage/bag/trash/bluespace
	name = "trash bag of holding"
	desc = "The latest and greatest in custodial convenience, a trashbag that is capable of holding vast quantities of garbage."
	icon_state = "bluetrashbag"
	worn_icon_state = "bluetrashbag"
	item_flags = NO_MAT_REDEMPTION

/obj/item/storage/bag/trash/bluespace/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 60
	STR.max_items = 60


/obj/item/storage/bag/trash/bluespace/hammerspace
	name = "hammerspace belt"
	desc = "A belt that opens into a near infinite pocket of bluespace."
	icon_state = "hammerspace"
	w_class = WEIGHT_CLASS_GIGANTIC
	icon = 'icons/obj/storage/backpack.dmi'

/obj/item/storage/bag/trash/bluespace/hammerspace/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 1000
	STR.max_items = 300
	STR.max_w_class = WEIGHT_CLASS_GIGANTIC

/obj/item/storage/bag/trash/bluespace/hammerspace/update_icon()
	if(contents.len == 0)
		icon_state = "[initial(icon_state)]"
	else icon_state = "[initial(icon_state)]"



/obj/item/storage/bag/trash/bluespace/cyborg
	insertable = FALSE

// -----------------------------
//        Mining Satchel
// -----------------------------

/obj/item/storage/bag/ore
	name = "mining satchel"
	desc = "This little bugger can be used to store and transport ores."
	icon = 'icons/obj/mining.dmi'
	icon_state = "satchel"
	worn_icon_state = "satchel"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_POCKETS
	w_class = WEIGHT_CLASS_NORMAL
	component_type = /datum/component/storage/concrete/stack
	var/is_bluespace = FALSE //If this is TRUE, when picking up ores it picks up ore from neighbouring tiles as well
	var/bs_range=1	//Range in which the bluespace satchels pick up ores from.
	var/mob/listeningTo

/obj/item/storage/bag/ore/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/rad_insulation, 0.05) //please datum mats no more cancer
	var/datum/component/storage/concrete/stack/STR = GetComponent(/datum/component/storage/concrete/stack)
	STR.allow_quick_empty = TRUE
	STR.set_holdable(list(/obj/item/stack/ore))
	STR.max_w_class = WEIGHT_CLASS_HUGE
	STR.max_items = 20
	STR.max_combined_stack_amount = 250

/obj/item/storage/bag/ore/equipped(mob/user)
	. = ..()
	if(listeningTo == user)
		return
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(Pickup_ores))
	listeningTo = user

/obj/item/storage/bag/ore/dropped()
	..()
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
		listeningTo = null

/obj/item/storage/bag/ore/proc/Pickup_ores(mob/living/user)
	SIGNAL_HANDLER

	var/show_message = FALSE
	var/obj/structure/ore_box/box
	var/turf/tile = user.loc
	if (!isturf(tile))
		return
	if (istype(user.pulling, /obj/structure/ore_box))
		box = user.pulling
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)

	if (STR)
		// Handle the tile the player steps in
		show_message=handle_ores_in_turf(tile, user, box)

	if(show_message)
		playsound(user, "rustle", 50, TRUE)
		STR.animate_parent()
		//Handling message perspectives semi-dynamically.
		var/message_action_pov = box ? "offload" : "scoop up"
		var/message_action = box ? "offloads" : "scoop up"
		var/message_location = is_bluespace ? "around" : "beneath"
		var/message_box_pov = box ? " into [box]" : " with your [name]"
		var/message_box = box ? " into [box]" : " with their [name]"

		user.visible_message(
			span_notice("[user] [message_action] the ores [message_location] [user.p_them()][message_box]."),
			span_notice("You [message_action_pov] the ores [message_location] you[message_box_pov].")
		)

/obj/item/storage/bag/ore/proc/handle_ores_in_turf(var/turf/turf, var/mob/living/user, var/obj/structure/ore_box/box)
	var/item_transferred = FALSE
	var/collection_range = (is_bluespace ? bs_range : 0) // 0 means the current turf only
	var/ore_found=FALSE
	if (box)
		for (var/obj/item/stack/ore/ore in turf)
			user.transferItemToLoc(ore, box)
			box.ui_update()
			item_transferred = TRUE
	else
		for (var/obj/item/stack/ore/ore in range(collection_range, turf))
			//This logic is needed so that we can send both an ore scooping up and the full bag message,
			//if there are too many ores in a single tile for a normal ore bag to hold
			if (!item_transferred)
				item_transferred = SEND_SIGNAL(src, COMSIG_TRY_STORAGE_INSERT, ore, user, TRUE)
			else
				SEND_SIGNAL(src, COMSIG_TRY_STORAGE_INSERT, ore, user, TRUE)
	// Check if any ore exists in the turf
	for(var/obj/item/stack/ore/ore in turf)
		ore_found = TRUE
		break // If we find any ore, no need to continue the loop
	if (ore_found)
		to_chat(user, span_warning("Your [name] is full and can't hold any more!"));

	return item_transferred

/obj/item/storage/bag/ore/cyborg
	name = "cyborg mining satchel"

/obj/item/storage/bag/ore/holding //miners, your messiah has arrived
	name = "mining satchel of holding"
	desc = "A revolution in convenience, this satchel allows for huge amounts of ore storage. It's been outfitted with anti-malfunction safety measures."
	icon_state = "satchel_bspace"

/obj/item/storage/bag/ore/holding/ComponentInitialize()
	. = ..()
	var/datum/component/storage/concrete/stack/STR = GetComponent(/datum/component/storage/concrete/stack)
	STR.max_items = INFINITY
	STR.max_combined_w_class = INFINITY
	STR.max_combined_stack_amount = INFINITY
	is_bluespace = TRUE

// -----------------------------
//          Plant bag
// -----------------------------

/obj/item/storage/bag/plants
	name = "plant bag"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "plantbag"
	worn_icon_state = "plantbag"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/plants/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 100
	STR.max_items = 100
	STR.set_holdable(
		list(
			/obj/item/food/grown,
			/obj/item/seeds,
			/obj/item/grown,
			/obj/item/reagent_containers/cup/glass/honeycomb,
			/obj/item/disk/plantgene,
			/obj/item/food/seaweed_sheet
		)
	)

////////

/obj/item/storage/bag/plants/portaseeder
	name = "portable seed extractor"
	desc = "For the enterprising botanist on the go. Less efficient than the stationary model, it creates one seed per plant."
	icon_state = "portaseeder"
	actions_types = list(/datum/action/item_action/portaseeder_dissolve)

/obj/item/storage/bag/plants/portaseeder/proc/dissolve_contents()
	if(usr.incapacitated())
		return
	for(var/obj/item/O in contents)
		seedify(O, 1)

/obj/item/storage/bag/plants/portaseeder/compact
	name = "compact portable seed extractor"
	desc = "Create seeds for your plants in your arm."
	icon_state = "compactseeder"

/obj/item/storage/bag/plants/portaseeder/compact/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 10
	STR.max_items = 3
	STR.set_holdable(list(/obj/item/food/grown, /obj/item/seeds, /obj/item/grown))

// -----------------------------
//        Sheet Snatcher
// -----------------------------
// Because it stacks stacks, this doesn't operate normally.
// However, making it a storage/bag allows us to reuse existing code in some places. -Sayu

/obj/item/storage/bag/sheetsnatcher
	name = "sheet snatcher"
	desc = "A patented Nanotrasen storage system designed for any kind of mineral sheet."
	icon = 'icons/obj/mining.dmi'
	icon_state = "sheetsnatcher"
	worn_icon_state = "satchel"

	var/capacity = 150 //the number of sheets it can carry.
	w_class = WEIGHT_CLASS_NORMAL
	component_type = /datum/component/storage/concrete/stack

/obj/item/storage/bag/sheetsnatcher/ComponentInitialize()
	. = ..()
	var/datum/component/storage/concrete/stack/STR = GetComponent(/datum/component/storage/concrete/stack)
	STR.allow_quick_empty = TRUE
	STR.set_holdable(list(/obj/item/stack/sheet))
	STR.max_combined_stack_amount = 150

// -----------------------------
//    Sheet Snatcher (Cyborg)
// -----------------------------

/obj/item/storage/bag/sheetsnatcher/borg
	name = "sheet snatcher 9000"
	desc = ""
	capacity = 500//Borgs get more because >specialization

/obj/item/storage/bag/sheetsnatcher/borg/ComponentInitialize()
	. = ..()
	var/datum/component/storage/concrete/stack/STR = GetComponent(/datum/component/storage/concrete/stack)
	STR.max_combined_stack_amount = 500
	STR.max_combined_w_class = 30

// -----------------------------
//           Book bag
// -----------------------------

/obj/item/storage/bag/books
	name = "book bag"
	desc = "A bag for books."
	icon = 'icons/obj/library.dmi'
	icon_state = "bookbag"
	worn_icon_state = "bookbag"
	w_class = WEIGHT_CLASS_BULKY //Bigger than a book because physics
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/books/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 21
	STR.max_items = 7
	STR.display_numerical_stacking = FALSE
	STR.set_holdable(list(/obj/item/book, /obj/item/storage/book, /obj/item/spellbook, /obj/item/codex_cicatrix))

/*
 * Trays - Agouri
 */
/obj/item/storage/bag/tray
	name = "serving tray"
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "tray"
	worn_icon_state = "tray"
	desc = "A metal tray to lay food on."
	force = 5
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron=3000)

/obj/item/storage/bag/tray/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.insert_preposition = "on"

/obj/item/storage/bag/tray/attack(mob/living/M, mob/living/user)
	. = ..()
	// Drop all the things. All of them.
	var/list/obj/item/oldContents = contents.Copy()
	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_QUICK_EMPTY)
	// Make each item scatter a bit
	for(var/obj/item/tray_item in oldContents)
		do_scatter(tray_item)
	if(prob(50))
		playsound(M, 'sound/items/trayhit1.ogg', 50, 1)
	else
		playsound(M, 'sound/items/trayhit2.ogg', 50, 1)

	if(ishuman(M) || ismonkey(M))
		if(prob(10))
			M.Paralyze(40)
	update_icon()

/obj/item/storage/bag/tray/proc/do_scatter(obj/item/tray_item)
	var/delay = rand(2,4)
	var/datum/move_loop/loop = SSmove_manager.move_rand(tray_item, list(NORTH,SOUTH,EAST,WEST), delay, timeout = rand(1, 2) * delay, flags = MOVEMENT_LOOP_START_FAST)
	//This does mean scattering is tied to the tray. Not sure how better to handle it
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(change_speed))

/obj/item/storage/bag/tray/proc/change_speed(datum/move_loop/source)
	SIGNAL_HANDLER
	var/new_delay = rand(2, 4)
	var/count = source.lifetime / source.delay
	source.lifetime = count * new_delay
	source.delay = new_delay

/obj/item/storage/bag/tray/update_overlays()
	. = ..()
	for(var/obj/item/I in contents)
		var/mutable_appearance/I_copy = new(I)
		I_copy.plane = FLOAT_PLANE
		I_copy.layer = FLOAT_LAYER
		. += I_copy

/obj/item/storage/bag/tray/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	update_icon()

/obj/item/storage/bag/tray/Exited(atom/movable/gone, direction)
	. = ..()
	update_icon()

/*
 *	Chemistry bag
 */

/obj/item/storage/bag/chemistry
	name = "chemistry bag"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bag"
	worn_icon_state = "chembag"
	desc = "A bag for storing pills, patches, and bottles."
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/chemistry/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 200
	STR.max_items = 50
	STR.insert_preposition = "in"
	STR.set_holdable(
		list(
			/obj/item/reagent_containers/pill,
			/obj/item/reagent_containers/cup/beaker,
			/obj/item/reagent_containers/cup/bottle,
			/obj/item/reagent_containers/medspray,
			/obj/item/reagent_containers/syringe,
			/obj/item/reagent_containers/dropper,
			/obj/item/reagent_containers/cup/glass/waterbottle
			)
		)

/*
 *  Biowaste bag (mostly for xenobiologists)
 */

/obj/item/storage/bag/bio
	name = "bio bag"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "biobag"
	worn_icon_state = "biobag"
	desc = "A bag for the safe transportation and disposal of biowaste and other biological materials."
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/bio/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 200
	STR.max_items = 25
	STR.insert_preposition = "in"
	STR.set_holdable(
		list(
			/obj/item/slime_extract,
			/obj/item/reagent_containers/syringe,
			/obj/item/reagent_containers/dropper,
			/obj/item/reagent_containers/cup/beaker,
			/obj/item/reagent_containers/cup/bottle,
			/obj/item/reagent_containers/blood,
			/obj/item/reagent_containers/hypospray/medipen,
			/obj/item/food/deadmouse,
			/obj/item/food/monkeycube,
			/obj/item/organ,
			/obj/item/bodypart
			)
		)

/obj/item/storage/bag/bio/pre_attack(atom/A, mob/living/user, params)
	if(istype(A, /obj/item/slimecross/reproductive))
		return TRUE
	return ..()

/obj/item/storage/bag/construction
	name = "construction bag"
	icon = 'icons/obj/tools.dmi'
	icon_state = "construction_bag"
	worn_icon_state = "construction_bag"
	desc = "A bag for storing small construction components."
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/construction/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 100
	STR.max_items = 50
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.insert_preposition = "in"
	STR.set_holdable(
		list(
			/obj/item/stack/ore/bluespace_crystal,
			/obj/item/assembly,
			/obj/item/stock_parts,
			/obj/item/reagent_containers/cup/beaker,
			/obj/item/stack/cable_coil,
			/obj/item/circuitboard,
			/obj/item/electronics,
			/obj/item/rcd_ammo
			)
		)
