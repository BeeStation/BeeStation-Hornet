/* Wax */

GLOBAL_LIST_INIT(wax_recipes, list (new/datum/stack_recipe("Wax tile", /obj/item/stack/tile/mineral/wax, 1, 4, 20)))

STACKSIZE_MACRO(/obj/item/stack/sheet/wax)

/* Sandbags - no recipes sorry!*/

STACKSIZE_MACRO(/obj/item/stack/sheet/sandbags)

/* Snow */

GLOBAL_LIST_INIT(snow_recipes, list ( \
	new/datum/stack_recipe("Snow wall", /turf/closed/wall/mineral/snow, 5, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("Snowman", /obj/structure/statue/snow/snowman, 5, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("Snowball", /obj/item/toy/snowball, 1), \
	new/datum/stack_recipe("Snow tile", /obj/item/stack/tile/mineral/snow, 1, 4, 20), \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/snow)

/* Plastic */

GLOBAL_LIST_INIT(plastic_recipes, list(
	new /datum/stack_recipe("plastic flaps", /obj/structure/plasticflaps, 5, one_per_turf = TRUE, on_floor = TRUE, time = 4 SECONDS), \
	new /datum/stack_recipe("water bottle", /obj/item/reagent_containers/glass/waterbottle/empty), \
	new /datum/stack_recipe("large water bottle", /obj/item/reagent_containers/glass/waterbottle/large/empty,3), \
	new /datum/stack_recipe("wet floor sign", /obj/item/clothing/suit/caution, 2), \
	new /datum/stack_recipe("plastic chair", /obj/structure/chair/fancy/plastic, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/plastic)

/* Cardboard */

GLOBAL_LIST_INIT(cardboard_recipes, list ( \
	new/datum/stack_recipe("box",									/obj/item/storage/box), \
	new/datum/stack_recipe("cardborg suit",							/obj/item/clothing/suit/cardborg, 3), \
	new/datum/stack_recipe("cardborg helmet",						/obj/item/clothing/head/cardborg), \
	new/datum/stack_recipe("large box",								/obj/structure/closet/cardboard, 4, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("cardboard cutout",						/obj/item/cardboard_cutout, 5), \
	null, \
	new/datum/stack_recipe("pizza box",								/obj/item/pizzabox), \
	new/datum/stack_recipe("folder",								/obj/item/folder), \
	null, \
	//TO-DO: Find a proper way to just change the illustration on the box. Code isn't the issue, input is.
	new/datum/stack_recipe_list("fancy boxes", list(
		new /datum/stack_recipe("donut box",						/obj/item/storage/fancy/donut_box), \
		new /datum/stack_recipe("egg box",							/obj/item/storage/fancy/egg_box), \
		new /datum/stack_recipe("donk-pockets box",					/obj/item/storage/box/donkpockets), \
		new /datum/stack_recipe("donk-pockets spicy box",			/obj/item/storage/box/donkpockets/donkpocketspicy), \
		new /datum/stack_recipe("donk-pockets teriyaki box",		/obj/item/storage/box/donkpockets/donkpocketteriyaki), \
		new /datum/stack_recipe("donk-pockets pizza box",			/obj/item/storage/box/donkpockets/donkpocketpizza), \
		new /datum/stack_recipe("donk-pockets berry box",			/obj/item/storage/box/donkpockets/donkpocketberry), \
		new /datum/stack_recipe("donk-pockets honk box",			/obj/item/storage/box/donkpockets/donkpockethonk), \
		new /datum/stack_recipe("monkey cube box",					/obj/item/storage/box/monkeycubes),
		new /datum/stack_recipe("nugget box",						/obj/item/storage/fancy/nugget_box), \
		null, \
		new /datum/stack_recipe("lethal ammo box",					/obj/item/storage/box/lethalshot), \
		new /datum/stack_recipe("rubber shot ammo box",				/obj/item/storage/box/rubbershot), \
		new /datum/stack_recipe("bean bag ammo box",				/obj/item/storage/box/beanbag), \
		new /datum/stack_recipe("flashbang box",					/obj/item/storage/box/flashbangs), \
		new /datum/stack_recipe("flashes box",						/obj/item/storage/box/flashes), \
		new /datum/stack_recipe("handcuffs box",					/obj/item/storage/box/handcuffs), \
		new /datum/stack_recipe("ID card box",						/obj/item/storage/box/ids), \
		new /datum/stack_recipe("PDA box",							/obj/item/storage/box/PDAs), \
		null, \
		new /datum/stack_recipe("pillbottle box",					/obj/item/storage/box/pillbottles), \
		new /datum/stack_recipe("beaker box",						/obj/item/storage/box/beakers), \
		new /datum/stack_recipe("syringe box",						/obj/item/storage/box/syringes), \
		new /datum/stack_recipe("latex gloves box",					/obj/item/storage/box/gloves), \
		new /datum/stack_recipe("sterile masks box",				/obj/item/storage/box/masks), \
		new /datum/stack_recipe("body bag box",						/obj/item/storage/box/bodybags), \
		new /datum/stack_recipe("prescription glasses box",			/obj/item/storage/box/rxglasses), \
		null, \
		new /datum/stack_recipe("disk box",							/obj/item/storage/box/disks), \
		new /datum/stack_recipe("light tubes box",					/obj/item/storage/box/lights/tubes), \
		new /datum/stack_recipe("light bulbs box",					/obj/item/storage/box/lights/bulbs), \
		new /datum/stack_recipe("mixed lights box",					/obj/item/storage/box/lights/mixed), \
		new /datum/stack_recipe("mouse traps box",					/obj/item/storage/box/mousetraps), \
		new /datum/stack_recipe("candle box",						/obj/item/storage/fancy/candle_box)
		)),
	null, \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/cardboard)
