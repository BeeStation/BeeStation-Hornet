
/obj/item/food/bread
	name = "bread?"
	desc = "This shouldn't exist, report to codermonkeys"
	icon = 'icons/obj/food/burgerbread.dmi'
	max_volume = 80
	tastes = list("bread" = 10)
	foodtypes = GRAIN
	eat_time = 3 SECONDS
	/// type is spawned 5 at a time and replaces this bread loaf when processed by cutting tool
	var/obj/item/food/breadslice/slice_type
	/// so that the yield can change if it isnt 5
	var/yield = 5

/obj/item/food/bread/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/dunkable, 10)
	AddComponent(/datum/component/food_storage)

/obj/item/food/bread/make_processable()
	if (slice_type)
		AddElement(/datum/element/processable, TOOL_KNIFE, slice_type, yield, 3 SECONDS, table_required = TRUE)
		AddElement(/datum/element/processable, TOOL_SAW, slice_type, yield, 4 SECONDS, table_required = TRUE)

/obj/item/food/breadslice
	name = "breadslice?"
	desc = "This shouldn't exist, report to codermonkeys"
	icon = 'icons/obj/food/burgerbread.dmi'
	foodtypes = GRAIN
	food_flags = FOOD_FINGER_FOOD
	eat_time = 0.5 SECONDS
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/breadslice/Initialize()
	. = ..()
	AddElement(/datum/element/dunkable, 10)

/obj/item/food/bread/plain
	name = "bread"
	desc = "Some plain old earthen bread."
	icon_state = "bread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10
	)
	tastes = list("bread" = 10)
	foodtypes = GRAIN
	w_class = WEIGHT_CLASS_SMALL
	slice_type = /obj/item/food/breadslice/plain

/obj/item/food/breadslice/plain
	name = "bread slice"
	desc = "A slice of home."
	icon_state = "breadslice"
	foodtypes = GRAIN
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2
	)

/*
 * REAL MOLDY FOOD. We just cant support it right now. Start porting after newfood is complete
 *
/obj/item/food/breadslice/moldy
	name = "moldy 'bread' slice"
	desc = "Entire stations have been ripped apart arguing whether this is still good to eat."
	icon_state = "moldybreadslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/mold = 10,
	)
	tastes = list("decaying fungus" = 1)
	foodtypes = GROSS
	preserved_food = TRUE

/obj/item/food/breadslice/moldy/bacteria
	name = "bacteria-rich moldy 'bread' slice"
	desc = "Something (possibly necroyeast) has caused this bread to rise in a macabre state of unlife. \
		It lurchs about when unattended. You might want to locate a priest if you see this. Or maybe a flamethrower."

/obj/item/food/breadslice/moldy/bacteria/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MOLD, CELL_VIRUS_TABLE_GENERIC, rand(2, 4), 25)
*/

/obj/item/food/breadslice/moldy
	name = "moldy bread slice"
	desc = "Entire stations have been ripped apart over arguing whether this is still good to eat."
	icon_state = "moldybreadslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2
	)
	tastes = list("decaying fungus" = 1)
	foodtypes = GROSS

/obj/item/food/bread/meat
	name = "meatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman."
	icon_state = "meatbread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 10
	)
	tastes = list("bread" = 10, "meat" = 10)
	foodtypes = GRAIN | MEAT
	slice_type = /obj/item/food/breadslice/meat

/obj/item/food/breadslice/meat
	name = "meatbread slice"
	desc = "A slice of delicious meatbread."
	icon_state = "meatbreadslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("bread" = 1, "meat" = 1)
	foodtypes = GRAIN | MEAT

/obj/item/food/bread/xenomeat
	name = "xenomeatbread loaf"
	desc = "Extra Heretical."
	icon_state = "xenomeatbread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 10
	)
	tastes = list("bread" = 10, "acid" = 10)
	foodtypes = GRAIN | MEAT
	slice_type = /obj/item/food/breadslice/xenomeat

/obj/item/food/breadslice/xenomeat
	name = "xenomeatbread slice"
	desc = "A slice of delicious meatbread. Extra Heretical."
	icon_state = "xenobreadslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("bread" = 10, "acid" = 10)
	foodtypes = GRAIN | MEAT

/obj/item/food/bread/spidermeat
	name = "spider meat loaf"
	desc = "Reassuringly green meatloaf made from spider meat."
	icon_state = "spidermeatbread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/toxin = 15,
		/datum/reagent/consumable/nutriment/vitamin = 10
	)
	tastes = list("bread" = 10, "cobwebs" = 5)
	foodtypes = GRAIN | MEAT | TOXIC
	slice_type = /obj/item/food/breadslice/spidermeat

/obj/item/food/breadslice/spidermeat
	name = "spider meat bread slice"
	desc = "A slice of meatloaf made from an animal that most likely still wants you dead."
	icon_state = "xenobreadslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/toxin = 3,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	tastes = list("bread" = 10, "cobwebs" = 5)
	foodtypes = GRAIN | MEAT | TOXIC

/obj/item/food/bread/banana
	name = "banana-nut bread"
	desc = "A heavenly and filling treat."
	icon_state = "bananabread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/banana = 20
	)
	tastes = list("bread" = 10) // bananjuice will also flavour
	foodtypes = GRAIN | FRUIT
	slice_type = /obj/item/food/breadslice/banana

/obj/item/food/breadslice/banana
	name = "banana-nut bread slice"
	desc = "A slice of delicious banana bread."
	icon_state = "bananabreadslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/banana = 4
	)
	tastes = list("bread" = 10)
	foodtypes = GRAIN | FRUIT

/obj/item/food/bread/tofu
	name = "Tofubread"
	desc = "Like meatbread but for vegetarians. Not guaranteed to give superpowers."
	icon_state = "tofubread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 10
	)
	tastes = list("bread" = 10, "tofu" = 10)
	foodtypes = GRAIN | VEGETABLES
	slice_type = /obj/item/food/breadslice/tofu

/obj/item/food/breadslice/tofu
	name = "tofubread slice"
	desc = "A slice of delicious tofubread."
	icon_state = "tofubreadslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("bread" = 10, "tofu" = 10)
	foodtypes = GRAIN | VEGETABLES

/obj/item/food/bread/creamcheese
	name = "cream cheese bread"
	desc = "Just a schmear."
	icon_state = "creamcheesebread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 10
	)
	tastes = list("bread" = 10, "cheese" = 10)
	foodtypes = GRAIN | DAIRY
	slice_type = /obj/item/food/breadslice/creamcheese

/obj/item/food/breadslice/creamcheese
	name = "cream cheese bread slice"
	desc = "A slice of Brotherly love!"
	icon_state = "creamcheesebreadslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("bread" = 10, "cheese" = 10)
	foodtypes = GRAIN | DAIRY

/obj/item/food/bread/mimana
	name = "mimana bread"
	desc = "Best eaten in silence."
	icon_state = "mimanabread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/toxin/mutetoxin = 10,
		/datum/reagent/consumable/nothing = 10,
		/datum/reagent/consumable/nutriment/vitamin = 10
	)
	tastes = list("bread" = 10, "silence" = 10)
	foodtypes = GRAIN | FRUIT
	slice_type = /obj/item/food/breadslice/mimana

/obj/item/food/breadslice/mimana
	name = "mimana bread slice"
	desc = "A slice of silence!"
	icon_state = "mimanabreadslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/toxin/mutetoxin = 2,
		/datum/reagent/consumable/nothing = 2,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	foodtypes = GRAIN | FRUIT

/obj/item/food/breadslice/custom
	name = "bread slice"
	icon_state = "tofubreadslice"
	foodtypes = GRAIN

/obj/item/food/baguette
	name = "baguette"
	desc = "Bon appetit!"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "baguette"
	item_state = null
	worn_icon_state = "baguette"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 3
	)
	bite_consumption = 3
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	attack_verb = list("touche")
	tastes = list("bread" = 1)
	foodtypes = GRAIN

/obj/item/food/baguette/mime
	name = "French Baguette"
	desc = "It would be a shame if it was consumed by someone unworthy..."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/nothing = 2
	)
	bite_consumption = null

/obj/item/food/garlicbread
	name = "garlic bread"
	desc = "Alas, it is limited."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "garlicbread"
	item_state = null
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/garlic = 2
	)
	bite_consumption = 3
	tastes = list("bread" = 1, "garlic" = 1, "butter" = 1)
	foodtypes = GRAIN

/obj/item/food/deepfryholder
	name = "Deep Fried Foods Holder Obj"
	desc = "If you can see this description the code for the deep fryer fucked up."
	icon = 'icons/obj/food/food.dmi'
	icon_state = ""
	bite_consumption = 2

/obj/item/food/deepfryholder/make_edible()
	AddComponent(/datum/component/edible,\
			initial_reagents = food_reagents,\
			food_flags = food_flags,\
			foodtypes = foodtypes,\
			volume = max_volume,\
			eat_time = eat_time,\
			tastes = tastes,\
			eatverbs = eatverbs,\
			bite_consumption = bite_consumption,\
			on_consume = CALLBACK(src, PROC_REF(On_Consume)))


/obj/item/food/deepfryholder/Initialize(mapload, obj/item/fried)
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

/obj/item/food/butterbiscuit
	name = "butter biscuit"
	desc = "Well butter my biscuit!"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "butterbiscuit"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	tastes = list("butter" = 1, "biscuit" = 1)
	foodtypes = GRAIN | BREAKFAST
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/butterdog
	name = "butterdog"
	desc = "Made from exotic butters."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "butterdog"
	bite_consumption = 1
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	tastes = list("butter" = 1, "exotic butter" = 1)
	foodtypes = GRAIN | DAIRY
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/butterdog/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery, 8 SECONDS)
