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
	mats_per_unit = list(/datum/material/wood=MINERAL_MATERIAL_AMOUNT)
	sheettype = "wood"
	armor_type = /datum/armor/sheet_wood
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/sheet/wood
	material_type = /datum/material/wood
	grind_results = list(/datum/reagent/carbon = 20)
	walltype = /turf/closed/wall/mineral/wood


/datum/armor/sheet_wood
	fire = 50

/obj/item/stack/sheet/wood/get_recipes()
	return GLOB.wood_recipes

/* Bamboo */

/obj/item/stack/sheet/bamboo
	name = "bamboo cuttings"
	desc = "Finely cut bamboo sticks."
	singular_name = "cut bamboo"
	icon_state = "sheet-bamboo"
	item_state = "sheet-bamboo"
	icon = 'icons/obj/stacks/organic.dmi'
	force = 10
	throwforce = 10
	armor_type = /datum/armor/sheet_bamboo
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/sheet/bamboo
	grind_results = list("carbon" = 5)


/datum/armor/sheet_bamboo
	fire = 50

/obj/item/stack/sheet/bamboo/get_recipes()
	return GLOB.bamboo_recipes

/obj/item/stack/sheet/bamboo/Topic(href, href_list)
	. = ..()
	if(href_list["make"])
		var/list/recipes_list = get_recipes()
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

/obj/item/stack/sheet/paperframes/get_recipes()
	return GLOB.paperframe_recipes
