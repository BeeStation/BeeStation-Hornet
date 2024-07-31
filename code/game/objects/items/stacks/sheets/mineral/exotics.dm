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
	mats_per_unit = list(/datum/material/bananium=MINERAL_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/consumable/banana = 20)
	point_value = 50
	merge_type = /obj/item/stack/sheet/mineral/bananium
	material_type = /datum/material/bananium
	walltype = /turf/closed/wall/mineral/bananium

/obj/item/stack/sheet/mineral/bananium/get_recipes()
	return GLOB.bananium_recipes


/* Adamantine */

/obj/item/stack/sheet/mineral/adamantine
	name = "adamantine"
	icon_state = "sheet-adamantine"
	item_state = "sheet-adamantine"
	singular_name = "adamantine sheet"
	mats_per_unit = list(/datum/material/adamantine=MINERAL_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/liquidadamantine = 10)
	merge_type = /obj/item/stack/sheet/mineral/adamantine
	material_type = /datum/material/adamantine

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
	mats_per_unit = list(/datum/material/alloy/alien=MINERAL_MATERIAL_AMOUNT)
	merge_type = /obj/item/stack/sheet/mineral/abductor
	material_type = /datum/material/alloy/alien
	walltype = /turf/closed/wall/mineral/abductor

/obj/item/stack/sheet/mineral/abductor/get_recipes()
	return GLOB.abductor_recipes
