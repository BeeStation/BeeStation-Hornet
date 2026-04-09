// This is synced up to the poster placing animation.
#define PLACE_SPEED (3.7 SECONDS)

// The poster item

/**
 * The rolled up item form of a poster
 *
 * In order to create one of these for a specific poster, you must pass the structure form of the poster as an argument to /new().
 * This structure then gets moved into the contents of the item where it will stay until the poster is placed by a player.
 * The structure form is [obj/structure/sign/poster] and that's where all the specific posters are defined.
 * If you just want a random poster, see [/obj/item/poster/random_official] or [/obj/item/poster/random_contraband]
 */
/obj/item/poster
	name = "poorly coded poster"
	desc = "You probably shouldn't be holding this."
	icon = 'icons/obj/poster.dmi'
	force = 0
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_SMALL
	var/poster_type
	var/obj/structure/sign/poster/poster_structure

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/poster)

/obj/item/poster/Initialize(mapload, obj/structure/sign/poster/new_poster_structure)
	. = ..()
	poster_structure = new_poster_structure
	if(!new_poster_structure && poster_type)
		poster_structure = new poster_type(src)

	// posters store what name and description they would like their
	// rolled up form to take.
	if(poster_structure)
		name = poster_structure.poster_item_name
		desc = poster_structure.poster_item_desc
		icon_state = poster_structure.poster_item_icon_state

		name = "[name] - [poster_structure.original_name]"

/obj/item/poster/Destroy()
	QDEL_NULL(poster_structure)
	return ..()

/obj/item/poster/afterattack(turf/closed/wall_structure, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!isclosedturf(wall_structure))
		return FALSE

	var/turf/user_turf = get_turf(user)
	var/dir = get_dir(user_turf, wall_structure)
	if(!(dir in GLOB.cardinals))
		balloon_alert(user, "stand in line with wall!")
		return FALSE

	// Deny placing posters on currently-diagonal walls, although the wall may change in the future.
	if (wall_structure.smoothing_flags & SMOOTH_DIAGONAL_CORNERS)
		for(var/overlay in wall_structure.overlays)
			var/image/new_image = overlay
			if(copytext(new_image.icon_state, 1, 3) == "d-") //3 == length("d-") + 1
				to_chat(user, span_warning("Cannot place on diagonal wall!"))
				return FALSE

	var/stuff_on_wall = 0
	for(var/obj/contained_object in wall_structure.contents) //Let's see if it already has a poster on it or too much stuff
		if(istype(contained_object, /obj/structure/sign/poster))
			balloon_alert(user, "no room!")
			return FALSE
		stuff_on_wall++
		if(stuff_on_wall == 3)
			balloon_alert(user, "no room!")
			return FALSE

	balloon_alert(user, "hanging poster...")
	var/obj/structure/sign/poster/placed_poster = poster_structure || new poster_type(src)
	placed_poster.forceMove(user_turf)
	placed_poster.setDir(dir)
	switch(dir)
		if(NORTH)
			placed_poster.pixel_y = 32
		if(SOUTH)
			placed_poster.pixel_y = -32
		if(EAST)
			placed_poster.pixel_x = 32
		if(WEST)
			placed_poster.pixel_x = -32

	placed_poster.poster_item_type = type
	poster_structure = null
	flick("poster_being_set", placed_poster)
	playsound(src, 'sound/items/poster_being_created.ogg', 100, TRUE)
	qdel(src)

	var/turf/user_drop_location = get_turf(user)
	if(!do_after(user, PLACE_SPEED, placed_poster))
		//only put back if the poster wasen't teared off or snipped with a wirecutter during placing
		if(!QDELETED(placed_poster))
			placed_poster.roll_and_drop(user_drop_location, user)
		return FALSE
	return TRUE

/**
 * The structure form of a poster.
 * These are what get placed on maps as posters. They are also what gets created when a player places a poster on a wall.
 * For the item form that can be spawned for players, see [/obj/item/poster]
 */
/obj/structure/sign/poster
	name = "poster"
	var/original_name
	desc = "A large piece of space-resistant printed paper."
	icon = 'icons/obj/poster.dmi'
	layer = ABOVE_WINDOW_LAYER
	anchored = TRUE
	var/ruined = FALSE
	var/random_basetype
	var/never_random = FALSE // used for the 'random' subclasses.

	var/poster_item_name = "hypothetical poster"
	var/poster_item_desc = "This hypothetical poster item should not exist, let's be honest here."
	var/poster_item_icon_state = "rolled_poster"
	var/poster_item_type = /obj/item/poster

/obj/structure/sign/poster/Initialize(mapload)
	. = ..()
	if(random_basetype)
		randomise(random_basetype)
	if(!ruined)
		original_name = name // can't use initial because of random posters
		name = "poster - [name]"
		desc = "A large piece of space-resistant printed paper. [desc]"

/obj/structure/sign/poster/proc/randomise(base_type)
	var/list/poster_types = subtypesof(base_type)
	var/list/approved_types = list()
	for(var/t in poster_types)
		var/obj/structure/sign/poster/T = t
		if(initial(T.icon_state) && !initial(T.never_random))
			approved_types |= T

	var/obj/structure/sign/poster/selected = pick(approved_types)

	name = initial(selected.name)
	desc = initial(selected.desc)
	icon_state = initial(selected.icon_state)
	poster_item_name = initial(selected.poster_item_name)
	poster_item_desc = initial(selected.poster_item_desc)
	poster_item_icon_state = initial(selected.poster_item_icon_state)
	ruined = initial(selected.ruined)
	update_appearance()

/obj/structure/sign/poster/wirecutter_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src, 100)
	if(ruined)
		to_chat(user, span_notice("You remove the remnants of the poster."))
		qdel(src)
	else
		to_chat(user, span_notice("You carefully remove the poster from the wall."))
		roll_and_drop(Adjacent(user) ? get_turf(user) : loc, user)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/structure/sign/poster/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(ruined)
		return

	visible_message("[user] rips [src] in a single, decisive motion!" )
	playsound(src, 'sound/items/poster_ripped.ogg', 100, TRUE)

	var/obj/structure/sign/poster/ripped/torn_poster = new(loc)
	torn_poster.pixel_y = pixel_y
	torn_poster.pixel_x = pixel_x
	torn_poster.add_fingerprint(user)
	qdel(src)

/obj/structure/sign/poster/proc/roll_and_drop(atom/location, mob/user)
	pixel_x = 0
	pixel_y = 0
	var/obj/item/poster/rolled_poster = new poster_item_type(loc, src)
	if(!user?.put_in_hands(rolled_poster))
		forceMove(rolled_poster)
	qdel(src)
	return rolled_poster

// Various possible posters follow

/obj/structure/sign/poster/ripped
	ruined = TRUE
	icon_state = "poster_ripped"
	name = "ripped poster"
	desc = "You can't make out anything from the poster's original print. It's ruined."

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/ripped, 32)

/obj/structure/sign/poster/random
	name = "random poster" // could even be ripped
	icon_state = "random_anything"
	never_random = TRUE
	random_basetype = /obj/structure/sign/poster

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/random, 32)

#undef PLACE_SPEED
