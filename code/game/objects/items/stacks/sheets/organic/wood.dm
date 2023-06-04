/**********************
Woods Sheets
	Contains:
		- Wood
		- Bamboo
		- Paper frames
**********************/


/* Wood */

/obj/item/stack/sheet/wood
	name = "wooden plank"
	desc = "One can only guess that this is a bunch of wood."
	singular_name = "wood plank"
	icon_state = "sheet-wood"
	item_state = "sheet-wood"
	icon = 'icons/obj/stacks/organic.dmi'
	sheettype = "wood"
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 0, STAMINA = 0)
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/sheet/wood
	grind_results = list(/datum/reagent/carbon = 20)

/obj/item/stack/sheet/wood/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.wood_recipes
	return ..()

/* Bamboo */

/obj/item/stack/sheet/bamboo
	name = "bamboo cuttings"
	desc = "Finely cut bamboo sticks."
	singular_name = "cut bamboo"
	icon_state = "sheet-bamboo"
	item_state = "sheet-bamboo"
	icon = 'icons/obj/stacks/organic.dmi'
	sheettype = "bamboo"
	force = 10
	throwforce = 10
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 0, STAMINA = 0)
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/sheet/bamboo
	grind_results = list("carbon" = 5)

/obj/item/stack/sheet/bamboo/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.bamboo_recipes
	return ..()

/obj/item/stack/sheet/bamboo/Topic(href, href_list)
	. = ..()
	if(href_list["make"])
		var/list/recipes_list = recipes
		var/datum/stack_recipe/R = recipes_list[text2num(href_list["make"])]
		if(R.result_type == /obj/structure/punji_sticks)
			var/turf/T = get_turf(src)
			usr.investigate_log("has placed punji sticks trap at [AREACOORD(T)].", INVESTIGATE_BOTANY)

/* Paper frames */

/obj/item/stack/sheet/paperframes
	name = "paper frames"
	desc = "A thin wooden frame with paper attached."
	singular_name = "paper frame"
	icon_state = "sheet-paper"
	item_state = "sheet-paper"
	icon = 'icons/obj/stacks/organic.dmi'
	merge_type = /obj/item/stack/sheet/paperframes
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/sheet/paperframes

/obj/item/stack/sheet/paperframes/Initialize(mapload)
	recipes = GLOB.paperframe_recipes
	. = ..()
