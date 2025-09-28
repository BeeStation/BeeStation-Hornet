// A few defines for use in calculating our plant's bite size.
/// When calculating bite size, potency is multiplied by this number.
#define BITE_SIZE_POTENCY_MULTIPLIER 0.05
/// When calculating bite size, max_volume is multiplied by this number.
#define BITE_SIZE_VOLUME_MULTIPLIER 0.01

///Abstract class to allow us to easily create all the generic "normal" food without too much copy pasta of adding more components
/obj/item/food
	name = "food"
	desc = "you eat this"
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/food/food.dmi'
	icon_state = null
	layer = OBJ_LAYER+0.1 //so food appears above stuff like plates 'n stuff
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	///List of reagents this food gets on creation
	var/list/food_reagents
	///Extra flags for things such as if the food is in a container or not
	var/food_flags
	///Bitflag of the types of food this food is
	var/foodtypes
	///Amount of volume the food can contain
	var/max_volume
	///How long it will take to eat this food without any other modifiers
	var/eat_time
	///Tastes to describe this food
	var/list/tastes
	///Verbs used when eating this food in the to_chat messages
	var/list/eatverbs
	///How much reagents per bite
	var/bite_consumption
	///What you get if you microwave the food, this should be replaced once I fully re-work cooking.
	var/microwaved_type
	///Type of atom thats spawned after eating this item
	var/trash_type
	///How much junkiness this food has? God I should remove junkiness soon
	var/junkiness
	///Food that's immune to decomposition.
	var/preserved_food = FALSE
	///Does our food normally attract ants?
	var/ant_attracting = FALSE
	///What our food decomposes into.
	var/decomp_type = /obj/item/food/badrecipe/moldy
	///Food that needs to be picked up in order to decompose.
	var/decomp_req_handle = FALSE
	///Used to set custom decomposition times for food. Set to 0 to have it automatically set via the food's flags.
	var/decomposition_time = 0
	///How exquisite the meal is. Applicable to crafted food, increasing its quality. Spans from 0 to 5.
	var/crafting_complexity = 0
	///Buff given when a hand-crafted version of this item is consumed. Randomized according to crafting_complexity if not assigned.
	var/datum/status_effect/food/crafted_food_buff = null

/obj/item/food/Initialize(mapload)
	. = ..()
	if(food_reagents)
		food_reagents = string_assoc_list(food_reagents)
	if(tastes)
		tastes = string_assoc_list(tastes)
	if(eatverbs)
		eatverbs = string_list(eatverbs)
	make_edible()
	make_processable()
	make_leave_trash()
	make_grillable()
	make_decompose(mapload)	//if it was placed by a mapper, there is a good reason why it isn't ants already
	make_bakeable()

///This proc adds the edible component, overwrite this if you for some reason want to change some specific args like callbacks.
/obj/item/food/proc/make_edible()
	AddComponent(/datum/component/edible,\
		initial_reagents = food_reagents,\
		food_flags = food_flags,\
		foodtypes = foodtypes,\
		volume = max_volume,\
		eat_time = eat_time,\
		tastes = tastes,\
		eatverbs = eatverbs,\
		bite_consumption = bite_consumption,\
		microwaved_type = microwaved_type,\
		junkiness = junkiness)


///This proc handles processable elements, overwrite this if you want to add behavior such as slicing, forking, spooning, whatever, to turn the item into something else
/obj/item/food/proc/make_processable()
	return

///This proc handles grillable components, overwrite if you want different grill results etc.
/obj/item/food/proc/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/badrecipe, rand(20 SECONDS, 30 SECONDS), FALSE)
	return

///This proc handles bakeable components, overwrite if you want different bake results etc.
/obj/item/food/proc/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/badrecipe, rand(25 SECONDS, 40 SECONDS), FALSE)

///This proc handles trash components, overwrite this if you want the object to spawn trash
/obj/item/food/proc/make_leave_trash()
	if(trash_type)
		AddElement(/datum/element/food_trash, trash_type)
	return

///This proc makes things decompose. Set preserved_food to TRUE to make it never decompose.
///Set decomp_req_handle to TRUE to only make it decompose when someone picks it up.
/obj/item/food/proc/make_decompose(mapload)
	if(!preserved_food)
		AddComponent(/datum/component/decomposition, mapload, decomp_req_handle, decomp_flags = foodtypes, decomp_result = decomp_type, ant_attracting = ant_attracting, custom_time = decomposition_time)

/obj/item/food/burn()
	if(QDELETED(src))
		return
	if(prob(25))
		microwave_act(src)
	else
		var/turf/T = get_turf(src)
		new /obj/item/food/badrecipe(T)
		if(resistance_flags & ON_FIRE)
			SSfire_burning.processing -= src
		qdel(src)

/obj/item/food/attackby(obj/item/attacking_item, mob/living/user)
	. = ..()
	if(istype(attacking_item, /obj/item/pen))
		var/target_name = tgui_input_text(user, "What would you like to name your masterpiece?", "Name:", name || "Food", MAX_MESSAGE_LEN)
		if(!target_name || !length(target_name))
			return
		if(CHAT_FILTER_CHECK(target_name))
			to_chat(user, span_warning("The given name contains prohibited word(s)."))
			return
		to_chat(user, span_notice("You rename the '<span class='cfc_bluesky'>[name]</span>' to '<span class='cfc_orange'>[target_name]</span>'."))
		name = target_name
		update_appearance()
