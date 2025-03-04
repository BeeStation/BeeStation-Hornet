#define DEFAULT_SHELF_CAPACITY 3 // Default capacity of the shelf
#define DEFAULT_SHELF_USE_DELAY 1 SECONDS // Default interaction delay of the shelf
#define DEFAULT_SHELF_VERTICAL_OFFSET 16 // Vertical pixel offset of shelving-related things. Set to 10 by default due to this leaving more of the crate on-screen to be clicked.

/obj/structure/crate_shelf
	name = "crate shelf"
	desc = "It's a shelf! For storing crates!"
	icon = 'icons/obj/objects.dmi'
	icon_state = "shelf"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	max_integrity = 50 // Not hard to break

	var/capacity = DEFAULT_SHELF_CAPACITY
	var/use_delay = DEFAULT_SHELF_USE_DELAY
	var/list/shelf_contents

/obj/structure/crate_shelf/tall
	capacity = 12

/obj/structure/crate_shelf/Initialize(mapload)
	. = ..()
	shelf_contents = new/list(capacity) // Initialize our shelf's contents list, this will be used later.
	var/stack_layer // This is used to generate the sprite layering of the shelf pieces.
	var/stack_offset // This is used to generate the vertical offset of the shelf pieces.
	for(var/i in 1 to (capacity - 1))
		stack_layer  = ABOVE_MOB_LAYER + (0.02 * i) - 0.01 // Make each shelf piece render above the last, but below the crate that should be on it.
		stack_offset = DEFAULT_SHELF_VERTICAL_OFFSET * i // Make each shelf piece physically above the last.
		overlays += image(icon = 'icons/obj/objects.dmi', icon_state = "shelf", layer = stack_layer, pixel_y = stack_offset)
	return

/obj/structure/crate_shelf/Destroy()
	QDEL_LIST(shelf_contents)
	return ..()

/obj/structure/crate_shelf/examine(mob/user)
	. = ..()
	. += span_notice("There are some <b>bolts</b> holding [src] together.")
	if(shelf_contents.Find(null)) // If there's an empty space in the shelf, let the examiner know.
		. += span_notice("You could <b>drag</b> a crate into [src].")
	if(contents.len) // If there are any crates in the shelf, let the examiner know.
		. += span_notice("You could <b>drag</b> a crate out of [src].")
		. += span_notice("[src] contains:")
		for(var/obj/structure/closet/crate/crate in shelf_contents)
			. += "	[icon2html(crate, user)] [crate]"

/obj/structure/crate_shelf/attackby(obj/item/item, mob/living/user, params)
	if (item.tool_behaviour == TOOL_WRENCH && !(flags_1&NODECONSTRUCT_1))
		item.play_tool_sound(src)
		if(do_after(user, 3 SECONDS, target = src))
			deconstruct(TRUE)
			return TRUE
	return ..()

/obj/structure/crate_shelf/relay_container_resist(mob/living/user, obj/structure/closet/crate)
	to_chat(user, span_notice("You begin attempting to knock [crate] out of [src]."))
	if(do_after(user, 30 SECONDS, target = crate))
		if(!user || user.stat != CONSCIOUS || user.loc != crate || crate.loc != src)
			return // If the user is in a strange condition, return early.
		visible_message(span_warning("[crate] falls off of [src]!"), span_notice("You manage to knock [crate] free of [src]."), span_notice("You hear a thud."))
		crate.forceMove(drop_location()) // Drop the crate onto the shelf,
		step_rand(crate, 1) // Then try to push it somewhere.
		crate.layer = initial(crate.layer) // Reset the crate back to having the default layer, otherwise we might get strange interactions.
		crate.pixel_y = initial(crate.pixel_y) // Reset the crate back to having no offset, otherwise it will be floating.
		shelf_contents[shelf_contents.Find(crate)] = null // Remove the reference to the crate from the list.
		handle_visuals()

/obj/structure/crate_shelf/proc/handle_visuals()
	vis_contents = contents // It really do be that shrimple.
	return

/obj/structure/crate_shelf/proc/try_load(obj/structure/closet/crate/crate, mob/user)
	if(!get_free_slot())
		balloon_alert(user, "shelf full!")
		return FALSE
	if(do_after(user, use_delay, target = crate))
		load(crate)
		return
	return FALSE // If the do_after() is interrupted, return FALSE!

/obj/structure/crate_shelf/proc/load(obj/structure/closet/crate/crate)
	if(!get_free_slot())
		return FALSE // Something has been added to the shelf while we were waiting, abort!
	var/next_free = get_free_slot()
	if(crate.opened) // If the crate is open, try to close it.
		if(!crate.close())
			return FALSE // If we fail to close it, don't load it into the shelf.
	shelf_contents[next_free] = crate // Insert a reference to the crate into the free slot.
	crate.forceMove(src) // Insert the crate into the shelf.
	crate.pixel_y = DEFAULT_SHELF_VERTICAL_OFFSET * (next_free - 1) // Adjust the vertical offset of the crate to look like it's on the shelf.
	crate.layer = ABOVE_MOB_LAYER + 0.02 * (next_free - 1) // Adjust the layer of the crate to look like it's in the shelf.
	handle_visuals()
	return TRUE

/obj/structure/crate_shelf/proc/get_free_slot()
	var/next_free = shelf_contents.Find(null) // Find the first empty slot in the shelf.
	if(!next_free) // If we don't find an empty slot, return FALSE.
		return FALSE
	return next_free

/obj/structure/crate_shelf/proc/unload(obj/structure/closet/crate/crate, mob/user, turf/unload_turf)
	if(!unload_turf)
		unload_turf = get_turf(user) // If a turf somehow isn't passed into the proc, put it at the user's feet.
	if(!unload_turf.Enter(crate)) // If moving the crate from the shelf to the desired turf would bump, don't do it!
		unload_turf.balloon_alert(user, "no room!")
		return FALSE
	if(do_after(user, use_delay, target = crate))
		if(!shelf_contents.Find(crate))
			return FALSE // If something has happened to the crate while we were waiting, abort!
		crate.layer = initial(crate.layer) // Reset the crate back to having the default layer, otherwise we might get strange interactions.
		crate.pixel_y = initial(crate.pixel_y) // Reset the crate back to having no offset, otherwise it will be floating.
		crate.forceMove(unload_turf)
		shelf_contents[shelf_contents.Find(crate)] = null // We do this instead of removing it from the list to preserve the order of the shelf.
		handle_visuals()
		return TRUE
	return FALSE  // If the do_after() is interrupted, return FALSE!

/obj/structure/crate_shelf/deconstruct(disassembled = TRUE)
	var/turf/dump_turf = drop_location()
	for(var/obj/structure/closet/crate/crate in shelf_contents)
		crate.layer = initial(crate.layer) // Reset the crates back to default visual state
		crate.pixel_y = initial(crate.pixel_y)
		crate.forceMove(dump_turf)
		step(crate, pick(GLOB.alldirs)) // Shuffle the crates around as though they've fallen down.
		crate.SpinAnimation(rand(4,7), 1) // Spin the crates around a little as they fall. Randomness is applied so it doesn't look weird.
		switch(rand(1, 7)) // Randomly pick whether to do nothing, open the crate, or break it open.
			if(1 to 4) // Believe it or not, this does nothing.
			if(5 to 6) // Open the crate!
				if(crate.open()) // Break some open, cause a little chaos.
					crate.visible_message(span_warning("[crate]'s lid falls open!"))
				else // If we somehow fail to open the crate, just break it instead!
					crate.visible_message(span_warning("[crate] falls apart!"))
					crate.deconstruct()
			if(7) // Break that crate!
				crate.visible_message(span_warning("[crate] falls apart!"))
				crate.deconstruct()
		shelf_contents[shelf_contents.Find(crate)] = null
	if(!(flags_1&NODECONSTRUCT_1))
		density = FALSE
		var/obj/item/rack_parts/shelf/newparts = new(loc)
		transfer_fingerprints_to(newparts)
	return ..()

/obj/item/rack_parts/shelf
	name = "crate shelf parts"
	desc = "Parts of a shelf."
	construction_type = /obj/structure/crate_shelf
	icon_state = "crate_shelf"

#undef DEFAULT_SHELF_CAPACITY
#undef DEFAULT_SHELF_USE_DELAY
#undef DEFAULT_SHELF_VERTICAL_OFFSET
