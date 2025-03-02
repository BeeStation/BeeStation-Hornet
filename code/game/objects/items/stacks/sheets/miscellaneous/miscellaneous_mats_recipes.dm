/* Wax */

GLOBAL_LIST_INIT(wax_recipes, list (new/datum/stack_recipe("Wax tile", /obj/item/stack/tile/mineral/wax, 1, 4, 20)))

STACKSIZE_MACRO(/obj/item/stack/sheet/wax)

/* Sandbags - no recipes sorry!*/

STACKSIZE_MACRO(/obj/item/stack/sheet/sandbags)

/* Snow */

GLOBAL_LIST_INIT(snow_recipes, list (
	new/datum/stack_recipe("Snow wall", /turf/closed/wall/mineral/snow, 5, one_per_turf = TRUE, on_floor = TRUE, category = CAT_STRUCTURE), \
	new/datum/stack_recipe("Snowman", /obj/structure/statue/snow/snowman, 5, one_per_turf = TRUE, on_floor = TRUE, category = CAT_STRUCTURE), \
	new/datum/stack_recipe("Snowball", /obj/item/toy/snowball, 1, category = CAT_WEAPON_RANGED), \
	new/datum/stack_recipe("Snow tile", /obj/item/stack/tile/mineral/snow, 1, 4, 20, category = CAT_TILES), \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/snow)

/* Plastic */

GLOBAL_LIST_INIT(plastic_recipes, list(
	new /datum/stack_recipe("plastic chair", /obj/structure/chair/fancy/plastic, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS, category = CAT_FURNITURE), \
	new /datum/stack_recipe("plastic flaps", /obj/structure/plasticflaps, 5, one_per_turf = TRUE, on_floor = TRUE, time = 4 SECONDS, category = CAT_FURNITURE), \
	new /datum/stack_recipe("water bottle", /obj/item/reagent_containers/cup/glass/waterbottle/empty, category = CAT_CONTAINERS), \
	new /datum/stack_recipe("large water bottle", /obj/item/reagent_containers/cup/glass/waterbottle/large/empty, 3, category = CAT_CONTAINERS), \
	new /datum/stack_recipe("wet floor sign", /obj/item/clothing/suit/caution, 2, category = CAT_EQUIPMENT), \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/plastic)

/* Cardboard */

GLOBAL_LIST_INIT(cardboard_recipes, list ( \
	new/datum/stack_recipe("box", /obj/item/storage/box, category = CAT_CONTAINERS), \
	new/datum/stack_recipe("cardborg suit", /obj/item/clothing/suit/costume/cardborg, 3, category = CAT_CLOTHING), \
	new/datum/stack_recipe("cardborg helmet", /obj/item/clothing/head/costume/cardborg, category = CAT_CLOTHING), \
	new/datum/stack_recipe("large box", /obj/structure/closet/cardboard, 4, one_per_turf = TRUE, on_floor = TRUE, category = CAT_CONTAINERS), \
	new/datum/stack_recipe("cardboard cutout", /obj/item/cardboard_cutout, 5, category = CAT_ENTERTAINMENT), \
	null, \

	new/datum/stack_recipe("pizza box", /obj/item/pizzabox, category = CAT_CONTAINERS), \
	new/datum/stack_recipe("folder", /obj/item/folder, category = CAT_CONTAINERS), \
	null, \

	//TO-DO: Find a proper way to just change the illustration on the box. Code isn't the issue, input is.
	new/datum/stack_recipe_list("fancy boxes", list(
		new /datum/stack_recipe("donut box", /obj/item/storage/fancy/donut_box, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("egg box", /obj/item/storage/fancy/egg_box, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("donk-pockets box", /obj/item/storage/box/donkpockets, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("donk-pockets spicy box", /obj/item/storage/box/donkpockets/donkpocketspicy, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("donk-pockets teriyaki box", /obj/item/storage/box/donkpockets/donkpocketteriyaki, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("donk-pockets pizza box", /obj/item/storage/box/donkpockets/donkpocketpizza, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("donk-pockets berry box", /obj/item/storage/box/donkpockets/donkpocketberry, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("donk-pockets honk box", /obj/item/storage/box/donkpockets/donkpockethonk, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("monkey cube box", /obj/item/storage/box/monkeycubes, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("nugget box", /obj/item/storage/fancy/nugget_box, category = CAT_CONTAINERS), \
		null, \

		new /datum/stack_recipe("lethal ammo box", /obj/item/storage/box/lethalshot, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("rubber shot ammo box", /obj/item/storage/box/rubbershot, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("bean bag ammo box", /obj/item/storage/box/beanbag, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("flashbang box", /obj/item/storage/box/flashbangs, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("flashes box", /obj/item/storage/box/flashes, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("handcuffs box", /obj/item/storage/box/handcuffs, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("ID card box", /obj/item/storage/box/ids, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("PDA box", /obj/item/storage/box/PDAs, category = CAT_CONTAINERS), \
		null, \

		new /datum/stack_recipe("pillbottle box", /obj/item/storage/box/pillbottles, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("beaker box", /obj/item/storage/box/beakers, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("syringe box", /obj/item/storage/box/syringes, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("latex gloves box", /obj/item/storage/box/gloves, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("sterile masks box", /obj/item/storage/box/masks, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("body bag box", /obj/item/storage/box/bodybags, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("perscription glasses box", /obj/item/storage/box/rxglasses, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("medipen box", /obj/item/storage/box/medipens, category = CAT_CONTAINERS), \
		null, \

		new /datum/stack_recipe("survival box", /obj/item/storage/box/survival, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("disk box", /obj/item/storage/box/disks, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("light tubes box", /obj/item/storage/box/lights/tubes, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("light bulbs box", /obj/item/storage/box/lights/bulbs, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("mixed lights box", /obj/item/storage/box/lights/mixed, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("mouse traps box", /obj/item/storage/box/mousetraps, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("candle box", /obj/item/storage/fancy/candle_box, category = CAT_CONTAINERS), \
		)),
	null, \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/cardboard)
