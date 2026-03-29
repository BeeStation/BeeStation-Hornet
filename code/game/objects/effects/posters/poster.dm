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


//separated to reduce code duplication. Moved here for ease of reference and to unclutter r_wall/attackby()
/turf/closed/wall/proc/place_poster(obj/item/poster/P, mob/user)
	if(!P.poster_structure)
		to_chat(user, span_warning("[P] has no poster... inside it? Inform a coder!"))
		return

	// Deny placing posters on currently-diagonal walls, although the wall may change in the future.
	if (smoothing_flags & SMOOTH_DIAGONAL_CORNERS)
		for (var/O in overlays)
			var/image/I = O
			if(copytext(I.icon_state, 1, 3) == "d-") //3 == length("d-") + 1
				return

	var/stuff_on_wall = 0
	for(var/obj/O in contents) //Let's see if it already has a poster on it or too much stuff
		if(istype(O, /obj/structure/sign/poster))
			to_chat(user, span_warning("The wall is far too cluttered to place a poster!"))
			return
		stuff_on_wall++
		if(stuff_on_wall == 3)
			to_chat(user, span_warning("The wall is far too cluttered to place a poster!"))
			return

	to_chat(user, span_notice("You start placing the poster on the wall...")	)

	var/obj/structure/sign/poster/D = P.poster_structure

	var/temp_loc = get_turf(user)
	flick("poster_being_set",D)
	D.forceMove(src)
	qdel(P)	//delete it now to cut down on sanity checks afterwards. Agouri's code supports rerolling it anyway
	playsound(D.loc, 'sound/items/poster_being_created.ogg', 100, 1)

	if(do_after(user, PLACE_SPEED, target=src))
		if(QDELETED(D))
			return

		if(iswallturf(src) && user && user.loc == temp_loc)	//Let's check if everything is still there
			to_chat(user, span_notice("You place the poster!"))
			return

	if(D.loc == src) //Would do QDELETED, but it's also possible the poster gets taken down by dismantling the wall
		to_chat(user, span_notice("The poster falls down!"))
		D.roll_and_drop(temp_loc, user)

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
