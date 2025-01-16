/**********************
Miscellaneous material sheets
	Contains:
		- Wax (even if it's organic, shh)
		- Sandbags
		- Snow
		- Plastic
		- Cartboard
		- Capitalismium and Stalinium
**********************/

/* Wax */

/obj/item/stack/sheet/wax
	name = "wax"
	icon_state = "sheet-wax"
	item_state = "sheet-wax"
	singular_name = "wax block"
	force = 1
	throwforce = 2
	grind_results = list(/datum/reagent/consumable/honey = 20)
	merge_type = /obj/item/stack/sheet/wax

/obj/item/stack/sheet/wax/get_recipes()
	return GLOB.wax_recipes

/* Sandbags */

/obj/item/stack/sheet/sandbags
	name = "sandbags"
	icon_state = "sandbags"
	singular_name = "sandbag"
	icon = 'icons/obj/stacks/miscellaneous.dmi'
	layer = LOW_ITEM_LAYER
	novariants = TRUE
	merge_type = /obj/item/stack/sheet/sandbags

GLOBAL_LIST_INIT(sandbag_recipes, list ( \
	new/datum/stack_recipe("sandbags", /obj/structure/barricade/sandbags, 1, one_per_turf = TRUE, on_floor = TRUE, time = 2.5 SECONDS), \
	))

/obj/item/stack/sheet/sandbags/get_recipes()
	return GLOB.sandbag_recipes

/obj/item/emptysandbag
	name = "empty sandbag"
	desc = "A bag to be filled with sand, not to be used for slowing down shuttles."
	icon = 'icons/obj/stacks/miscellaneous.dmi'
	icon_state = "sandbags"
	w_class = WEIGHT_CLASS_TINY

/obj/item/emptysandbag/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/ore/glass))
		var/obj/item/stack/ore/glass/G = W
		to_chat(user, "<span class='notice'>You fill the sandbag.</span>")
		var/obj/item/stack/sheet/sandbags/I = new /obj/item/stack/sheet/sandbags(drop_location())
		qdel(src)
		if (Adjacent(user) && !issilicon(user))
			user.put_in_hands(I)
		G.use(1)
	else
		return ..()

/* Snow - baka baka*/

/obj/item/stack/sheet/snow
	name = "snow"
	icon_state = "sheet-snow"
	item_state = "sheet-snow"
	icon = 'icons/obj/stacks/minerals.dmi'
	singular_name = "snow block"
	force = 1
	throwforce = 2
	custom_materials = list(/datum/material/snow = MINERAL_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/consumable/ice = 20)
	merge_type = /obj/item/stack/sheet/snow
	material_type = /datum/material/snow

/obj/item/stack/sheet/snow/get_recipes()
	return GLOB.snow_recipes

/* Plastic */

/obj/item/stack/sheet/plastic
	name = "plastic"
	desc = "Compress dinosaur over millions of years, then refine, split and mold, and voila! You have plastic."
	singular_name = "plastic sheet"
	icon_state = "sheet-plastic"
	item_state = "sheet-plastic"
	mats_per_unit = list(/datum/material/plastic=MINERAL_MATERIAL_AMOUNT)
	throwforce = 7
	merge_type = /obj/item/stack/sheet/plastic
	material_type = /datum/material/plastic

/obj/item/stack/sheet/plastic/get_recipes()
	return GLOB.plastic_recipes

/* Cardboard */

/obj/item/stack/sheet/cardboard	//BubbleWrap //it's cardboard you fuck
	name = "cardboard"
	desc = "Large sheets of card, like boxes folded flat."
	singular_name = "cardboard sheet"
	icon = 'icons/obj/stacks/miscellaneous.dmi'
	icon_state = "sheet-card"
	item_state = "sheet-card"
	resistance_flags = FLAMMABLE
	force = 0
	throwforce = 0
	custom_materials = list(/datum/material/cardboard = MINERAL_MATERIAL_AMOUNT)
	merge_type = /obj/item/stack/sheet/cardboard
	material_type = /datum/material/cardboard

/obj/item/stack/sheet/cardboard/get_recipes()
	return GLOB.cardboard_recipes


/obj/item/stack/sheet/cardboard/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stamp/clown) && !istype(loc, /obj/item/storage))
		var/atom/droploc = drop_location()
		if(use(1))
			playsound(I, 'sound/items/bikehorn.ogg', 50, 1, -1)
			to_chat(user, "<span class='notice'>You stamp the cardboard! It's a clown box! Honk!</span>")
			if (amount >= 0)
				new/obj/item/storage/box/clown(droploc) //bugfix
	else
		. = ..()

/* capitalisium and stalinium*/

/obj/item/stack/sheet/capitalisium
	name = "capitalisium sheet"
	desc = "A source of raw capitalism, capable of bringing forth the prophesized Capitalist Golem."
	icon_state = "sheet-capitalisium"
	merge_type = /obj/item/stack/sheet/capitalisium

/obj/item/stack/sheet/stalinium
	name = "stalinium sheet"
	desc = "A source of raw socialism, capable of bringing forth the prophesized Soviet Golem."
	icon_state = "sheet-stalinium"
	merge_type = /obj/item/stack/sheet/stalinium

/obj/item/stack/sheet/meat
	name = "meat sheets"
	desc = "Something's bloody meat compressed into a nice solid sheet"
	singular_name = "meat sheet"
	icon_state = "sheet-meat"
	material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR
	mats_per_unit = list(/datum/material/meat = MINERAL_MATERIAL_AMOUNT)
	merge_type = /obj/item/stack/sheet/meat
	material_type = /datum/material/meat
	material_modifier = 1 //None of that wussy stuff

/obj/item/stack/sheet/meat/get_recipes()
	return GLOB.meat_recipes

/obj/item/stack/sheet/meat/fifty
	amount = 50
/obj/item/stack/sheet/meat/twenty
	amount = 20
/obj/item/stack/sheet/meat/five
	amount = 5

/obj/item/stack/sheet/pizza
	name = "pepperoni sheetzzas"
	desc = "It's a delicious pepperoni sheetzza!"
	singular_name = "pepperoni sheetzza"
	icon_state = "sheet-pizza"
	custom_materials = list(/datum/material/pizza = MINERAL_MATERIAL_AMOUNT)
	merge_type = /obj/item/stack/sheet/pizza
	material_type = /datum/material/pizza
	material_modifier = 1

/obj/item/stack/sheet/pizza/fifty
	amount = 50
/obj/item/stack/sheet/pizza/twenty
	amount = 20
/obj/item/stack/sheet/pizza/five
	amount = 5

/obj/item/stack/sheet/sandblock
	name = "blocks of sand"
	desc = "You're too old to be playing with sandcastles. Now you build... sandstations."
	singular_name = "block of sand"
	icon_state = "sheet-sandstone"
	custom_materials = list(/datum/material/sand = MINERAL_MATERIAL_AMOUNT)
	merge_type = /obj/item/stack/sheet/sandblock
	material_type = /datum/material/sand
	material_modifier = 1

/obj/item/stack/sheet/sandblock/fifty
	amount = 50
/obj/item/stack/sheet/sandblock/twenty
	amount = 20
/obj/item/stack/sheet/sandblock/five
	amount = 5
