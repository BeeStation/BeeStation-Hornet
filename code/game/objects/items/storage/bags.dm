#define ORE_BAG_BALOON_COOLDOWN (2 SECONDS)

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

/obj/item/storage/bag/Initialize(mapload)
	. = ..()
	atom_storage.allow_quick_gather = TRUE
	atom_storage.allow_quick_empty = TRUE
	atom_storage.numerical_stacking = TRUE

// -----------------------------
//          Trash bag
// -----------------------------
/obj/item/storage/bag/trash
	name = "trash bag"
	desc = "It's the heavy-duty black polymer kind. Time to take out the trash!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "trashbag"
	inhand_icon_state = "trashbag"
	worn_icon_state = "trashbag"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	storage_type = /datum/storage/trash
	custom_price = 50
	var/insertable = TRUE

/obj/item/storage/bag/trash/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL
	atom_storage.max_total_storage = 30
	atom_storage.max_slots = 30
	atom_storage.set_holdable(cant_hold_list = list(/obj/item/disk/nuclear))
	atom_storage.supports_smart_equip = FALSE
	RegisterSignal(atom_storage, COMSIG_STORAGE_DUMP_POST_TRANSFER, PROC_REF(post_insertion))

/// If you dump a trash bag into something, anything that doesn't get inserted will spill out onto your feet
/obj/item/storage/bag/trash/proc/post_insertion(datum/storage/source, atom/dest_object, mob/user)
	SIGNAL_HANDLER
	// If there's no item in there, don't do anything
	if(!(locate(/obj/item) in src))
		return

	// Otherwise, we're gonna dump into the dest object
	var/turf/dump_onto = get_turf(dest_object)
	user.visible_message(
		span_notice("[user] dumps the contents of [src] all out on \the [dump_onto]"),
		span_notice("The remaining trash in \the [src] falls out onto \the [dump_onto]"),
	)
	source.remove_all(dump_onto)

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

/obj/item/storage/bag/trash/filled/PopulateContents()
	. = ..()
	for(var/i in 1 to rand(1, 7))
		new /obj/effect/spawner/random/trash/garbage(src)
	update_icon_state()

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

/obj/item/storage/bag/trash/bluespace/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 60
	atom_storage.max_slots = 60


/obj/item/storage/bag/trash/bluespace/hammerspace
	name = "hammerspace belt"
	desc = "A belt that opens into a near infinite pocket of bluespace."
	icon_state = "hammerspace"
	w_class = WEIGHT_CLASS_GIGANTIC
	icon = 'icons/obj/storage/backpack.dmi'

/obj/item/storage/bag/trash/bluespace/hammerspace/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 1000
	atom_storage.max_slots = 300
	atom_storage.max_specific_storage = WEIGHT_CLASS_GIGANTIC

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
	///If this is TRUE, when picking up ores it picks up ore from neighbouring tiles as well
	var/is_bluespace = FALSE
	///Range in which the bluespace satchels pick up ores from.
	var/bs_range = 1
	var/mob/listeningTo
	///Cooldown on balloon alerts when picking ore
	COOLDOWN_DECLARE(ore_bag_balloon_cooldown)

/obj/item/storage/bag/ore/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_HUGE
	atom_storage.max_total_storage = 250
	atom_storage.numerical_stacking = TRUE
	atom_storage.allow_quick_empty = TRUE
	atom_storage.allow_quick_gather = TRUE
	atom_storage.set_holdable(list(/obj/item/stack/ore))
	atom_storage.silent_for_user = TRUE

/obj/item/storage/bag/ore/equipped(mob/user)
	. = ..()
	if(listeningTo == user)
		return
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(pickup_ores))
	listeningTo = user

/obj/item/storage/bag/ore/dropped()
	..()
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
		listeningTo = null

/obj/item/storage/bag/ore/proc/pickup_ores(mob/living/user)
	SIGNAL_HANDLER

	var/show_message = FALSE
	var/obj/structure/ore_box/box
	var/turf/tile = get_turf(user)

	if(!isturf(tile))
		return

	if(istype(user.pulling, /obj/structure/ore_box))
		box = user.pulling

	if(atom_storage)
		// Handle the tile the player steps in
		show_message=handle_ores_in_turf(tile, user, box)

	if(show_message)
		playsound(user, "rustle", 50, TRUE)
		if(!COOLDOWN_FINISHED(src, ore_bag_balloon_cooldown))
			return

		COOLDOWN_START(src, ore_bag_balloon_cooldown, ORE_BAG_BALOON_COOLDOWN)
		atom_storage.animate_parent()
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

/obj/item/storage/bag/ore/proc/handle_ores_in_turf(turf/turf, mob/living/user, obj/structure/ore_box/box)
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
				item_transferred = atom_storage?.attempt_insert(ore, user, TRUE)
			else
				atom_storage?.attempt_insert(ore, user, TRUE)
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

/obj/item/storage/bag/ore/holding/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = INFINITY
	atom_storage.max_specific_storage = INFINITY
	atom_storage.max_total_storage = INFINITY
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

/obj/item/storage/bag/plants/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 100
	atom_storage.max_slots = 100
	atom_storage.set_holdable(
		list(
			/obj/item/food/grown,
			/obj/item/seeds,
			/obj/item/grown,
			/obj/item/food/honeycomb,
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
	if(usr.incapacitated)
		return
	for(var/obj/item/O in contents)
		seedify(O, 1)

/obj/item/storage/bag/plants/portaseeder/compact
	name = "compact portable seed extractor"
	desc = "Create seeds for your plants in your arm."
	icon_state = "compactseeder"

/obj/item/storage/bag/plants/portaseeder/compact/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 10
	atom_storage.max_slots = 3
	atom_storage.set_holdable(list(/obj/item/food/grown, /obj/item/seeds, /obj/item/grown))

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

	w_class = WEIGHT_CLASS_NORMAL

	var/capacity = 150 //the number of sheets it can carry.

/obj/item/storage/bag/sheetsnatcher/Initialize(mapload)
	. = ..()
	atom_storage.allow_quick_empty = TRUE
	atom_storage.allow_quick_gather = TRUE
	atom_storage.numerical_stacking = TRUE
	atom_storage.set_holdable(list(/obj/item/stack/sheet))
	atom_storage.max_total_storage = capacity / 2

// -----------------------------
//    Sheet Snatcher (Cyborg)
// -----------------------------

/obj/item/storage/bag/sheetsnatcher/borg
	name = "sheet snatcher 9000"
	desc = ""
	capacity = 500//Borgs get more because >specialization

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

/obj/item/storage/bag/books/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 21
	atom_storage.max_slots = 7
	atom_storage.set_holdable(
		list(
			/obj/item/book,
			/obj/item/storage/book,
			/obj/item/spellbook,
			/obj/item/codex_cicatrix
			)
		)

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

/obj/item/storage/bag/tray/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	atom_storage.set_holdable(list(
		/obj/item/clothing/mask/cigarette,
		/obj/item/food,
		/obj/item/kitchen,
		/obj/item/lighter,
		/obj/item/organ,
		/obj/item/plate,
		/obj/item/reagent_containers/condiment,
		/obj/item/reagent_containers/cup,
		/obj/item/rollingpaper,
		/obj/item/storage/box/matches,
		/obj/item/storage/fancy,
		/obj/item/trash,
		))
	atom_storage.insert_preposition = "on"
	atom_storage.max_slots = 7

/obj/item/storage/bag/tray/attack(mob/living/M, mob/living/user)
	. = ..()
	// Drop all the things. All of them.
	var/list/obj/item/oldContents = contents.Copy()
	atom_storage.remove_all(user)
	// Make each item scatter a bit
	for(var/obj/item/tray_item in oldContents)
		do_scatter(tray_item)

	if(prob(50))
		playsound(M, 'sound/items/trayhit1.ogg', 50, TRUE)
	else
		playsound(M, 'sound/items/trayhit2.ogg', 50, TRUE)

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

/obj/item/storage/bag/chemistry/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 200
	atom_storage.max_slots = 50
	atom_storage.set_holdable(
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

/obj/item/storage/bag/bio/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 200
	atom_storage.max_slots = 25
	atom_storage.set_holdable(
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

/obj/item/storage/bag/construction/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 100
	atom_storage.max_slots = 50
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL
	atom_storage.set_holdable(
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

#undef ORE_BAG_BALOON_COOLDOWN
