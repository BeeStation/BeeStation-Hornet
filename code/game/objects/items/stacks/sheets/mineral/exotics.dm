/**********************
Exotic mineral Sheets
	Contains:
		- Bananium
		- Adamantine
		- Alien Alloy
**********************/

/* Bananium */

/obj/item/stack/sheet/mineral/bananium
	name = "bananium"
	icon_state = "sheet-bananium"
	item_state = "sheet-bananium"
	singular_name = "bananium sheet"
	sheettype = "bananium"
	materials = list(/datum/material/bananium=MINERAL_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/consumable/banana = 20)
	point_value = 50
	merge_type = /obj/item/stack/sheet/mineral/bananium

/obj/item/stack/sheet/mineral/bananium/get_recipes()
	return GLOB.bananium_recipes


/* Adamantine */

/obj/item/stack/sheet/mineral/adamantine
	name = "adamantine"
	icon_state = "sheet-adamantine"
	item_state = "sheet-adamantine"
	singular_name = "adamantine sheet"
	merge_type = /obj/item/stack/sheet/mineral/adamantine
	grind_results = list(/datum/reagent/liquidadamantine = 10)

/obj/item/stack/sheet/mineral/adamantine/get_recipes()
	return GLOB.adamantine_recipes

/* Alien Alloy */

/obj/item/stack/sheet/mineral/abductor
	name = "alien alloy"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "sheet-abductor"
	item_state = "sheet-abductor"
	singular_name = "alien alloy sheet"
	sheettype = "abductor"
	merge_type = /obj/item/stack/sheet/mineral/abductor

/obj/item/stack/sheet/mineral/abductor/get_recipes()
	return GLOB.abductor_recipes
