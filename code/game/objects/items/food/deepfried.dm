/obj/item/food/deepfryholder
	name = "Deep Fried Foods Holder Obj"
	desc = "If you can see this description the code for the deep fryer fucked up."
	icon = 'icons/obj/food/food.dmi'
	icon_state = ""
	bite_consumption = 2

/obj/item/food/deepfryholder/make_edible()
	. = ..()
	AddComponent(/datum/component/edible, on_consume = CALLBACK(src, PROC_REF(On_Consume)))

/obj/item/food/deepfryholder/Initialize(mapload, obj/item/fried)
	if(!fried)
		stack_trace("A deepfried object was created with no fried target")
		return INITIALIZE_HINT_QDEL
	. = ..()
	name = fried.name //We'll determine the other stuff when it's actually removed
	appearance = fried.appearance
	layer = initial(layer)
	plane = initial(plane)
	lefthand_file = fried.lefthand_file
	righthand_file = fried.righthand_file
	worn_icon_state = fried.worn_icon_state
	desc = fried.desc
	w_class = fried.w_class
	slowdown = fried.slowdown
	equip_delay_self = fried.equip_delay_self
	equip_delay_other = fried.equip_delay_other
	strip_delay = fried.strip_delay
	species_exception = fried.species_exception
	item_flags = fried.item_flags
	obj_flags = fried.obj_flags
	inhand_x_dimension = fried.inhand_x_dimension
	inhand_y_dimension = fried.inhand_y_dimension

	if(!(SEND_SIGNAL(fried, COMSIG_ITEM_FRIED, src) & COMSIG_FRYING_HANDLED)) //If frying is handled by signal don't do the defaault behavior.
		fried.forceMove(src)


/obj/item/food/deepfryholder/Destroy()
	if(contents)
		QDEL_LIST(contents)
	return ..()

/obj/item/food/deepfryholder/proc/On_Consume(eater, feeder)
	if(contents)
		QDEL_LIST(contents)


/obj/item/food/deepfryholder/proc/fry(cook_time = 30)
	switch(cook_time)
		if(0 to 15)
			add_atom_colour(rgb(166,103,54), FIXED_COLOUR_PRIORITY)
			name = "lightly-fried [name]"
			desc = "[desc] It's been lightly fried in a deep fryer."
		if(16 to 49)
			add_atom_colour(rgb(103,63,24), FIXED_COLOUR_PRIORITY)
			name = "fried [name]"
			desc = "[desc] It's been fried, increasing its tastiness value by [rand(1, 75)]%."
		if(50 to 59)
			add_atom_colour(rgb(63,23,4), FIXED_COLOUR_PRIORITY)
			name = "deep-fried [name]"
			desc = "[desc] Deep-fried to perfection."
		if(60 to INFINITY)
			add_atom_colour(rgb(33,19,9), FIXED_COLOUR_PRIORITY)
			name = "\proper the physical manifestation of the very concept of fried foods"
			desc = "A heavily-fried... something. Who can tell anymore?"
	foodtypes |= FRIED
