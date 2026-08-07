/* Wax */

GLOBAL_LIST_INIT(wax_recipes, list (new/datum/stack_recipe("Wax tile", /obj/item/stack/tile/mineral/wax, 1, 4, 20)))

STACKSIZE_MACRO(/obj/item/stack/sheet/wax)

/* Sandbags - no recipes sorry!*/

STACKSIZE_MACRO(/obj/item/stack/sheet/sandbags)

/* Snow */

GLOBAL_LIST_INIT(snow_recipes, list (
	new/datum/stack_recipe("snow wall", /turf/closed/wall/mineral/snow, 5, time = 4 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_STRUCTURE), \
	new/datum/stack_recipe("snowman", /obj/structure/statue/snow/snowman, 5, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_ENTERTAINMENT), \
	new/datum/stack_recipe("snowball", /obj/item/toy/snowball, 1, crafting_flags = NONE, category = CAT_WEAPON_RANGED), \
	new/datum/stack_recipe("snow tile", /obj/item/stack/tile/mineral/snow, 1, 4, 20, crafting_flags = NONE, category = CAT_TILES), \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/snow)

/* Plastic */

GLOBAL_LIST_INIT(plastic_recipes, list(
	new /datum/stack_recipe("plastic chair", /obj/structure/chair/fancy/plastic, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS, category = CAT_FURNITURE), \
	new /datum/stack_recipe("plastic flaps", /obj/structure/plasticflaps, 5, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 4 SECONDS, category = CAT_FURNITURE), \
	new /datum/stack_recipe("water bottle", /obj/item/reagent_containers/cup/glass/waterbottle/empty, category = CAT_CONTAINERS), \
	new /datum/stack_recipe("large water bottle", /obj/item/reagent_containers/cup/glass/waterbottle/large/empty, 3, category = CAT_CONTAINERS), \
	new /datum/stack_recipe("wet floor sign", /obj/item/clothing/suit/caution, 2, category = CAT_EQUIPMENT), \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/plastic)

/* Cardboard */

GLOBAL_LIST_INIT(cardboard_recipes, list ( \
	new/datum/stack_recipe("box", /obj/item/storage/box, crafting_flags = NONE, category = CAT_CONTAINERS), \
	new/datum/stack_recipe("cardborg suit", /obj/item/clothing/suit/costume/cardborg, 3, crafting_flags = NONE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("cardborg helmet", /obj/item/clothing/head/costume/cardborg, crafting_flags = NONE, category = CAT_CLOTHING), \
	new/datum/stack_recipe("large box", /obj/structure/closet/cardboard, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_CONTAINERS), \
	new/datum/stack_recipe("cardboard cutout", /obj/item/cardboard_cutout, 5, crafting_flags = NONE, category = CAT_ENTERTAINMENT), \
	null, \

	new/datum/stack_recipe("pizza box", /obj/item/pizzabox, crafting_flags = NONE, category = CAT_CONTAINERS), \
	new/datum/stack_recipe("folder", /obj/item/folder, crafting_flags = NONE, category = CAT_CONTAINERS), \
	null, \

	//TO-DO: Find a proper way to just change the illustration on the box. Code isn't the issue, input is.
	new/datum/stack_recipe_list("fancy boxes", list(
		new /datum/stack_recipe("donut box", /obj/item/storage/fancy/donut_box, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("egg box", /obj/item/storage/fancy/egg_box, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("donk-pockets box", /obj/item/storage/box/donkpockets, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("donk-pockets spicy box", /obj/item/storage/box/donkpockets/donkpocketspicy, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("donk-pockets teriyaki box", /obj/item/storage/box/donkpockets/donkpocketteriyaki, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("donk-pockets pizza box", /obj/item/storage/box/donkpockets/donkpocketpizza, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("donk-pockets berry box", /obj/item/storage/box/donkpockets/donkpocketberry, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("donk-pockets honk box", /obj/item/storage/box/donkpockets/donkpockethonk, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("monkey cube box", /obj/item/storage/box/monkeycubes, crafting_flags = NONE, category = CAT_CONTAINERS),
		new /datum/stack_recipe("nugget box", /obj/item/storage/fancy/nugget_box, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("drinking glasses box", /obj/item/storage/box/drinkingglasses, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("paper cups box", /obj/item/storage/box/cups, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("cigar case", /obj/item/storage/fancy/cigarettes/cigars, crafting_flags = NONE, category = CAT_CONTAINERS), \
		null, \

		new /datum/stack_recipe("lethal ammo box", /obj/item/storage/box/lethalshot, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("rubber shot ammo box", /obj/item/storage/box/rubbershot, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("bean bag ammo box", /obj/item/storage/box/beanbag, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("flashbang box", /obj/item/storage/box/flashbangs, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("flashes box", /obj/item/storage/box/flashes, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("handcuffs box", /obj/item/storage/box/handcuffs, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("ID card box", /obj/item/storage/box/ids, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("PDA box", /obj/item/storage/box/PDAs, crafting_flags = NONE, category = CAT_CONTAINERS), \
		null, \

		new /datum/stack_recipe("pillbottle box", /obj/item/storage/box/pillbottles, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("beaker box", /obj/item/storage/box/beakers, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("syringe box", /obj/item/storage/box/syringes, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("latex gloves box", /obj/item/storage/box/gloves, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("sterile masks box", /obj/item/storage/box/masks, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("body bag box", /obj/item/storage/box/bodybags, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("prescription glasses box", /obj/item/storage/box/rxglasses, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("medipen box", /obj/item/storage/box/medipens, crafting_flags = NONE, category = CAT_CONTAINERS), \
		null, \

		new /datum/stack_recipe("survival box", /obj/item/storage/box/survival, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("disk box", /obj/item/storage/box/disks, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("light tubes box", /obj/item/storage/box/lights/tubes, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("light bulbs box", /obj/item/storage/box/lights/bulbs, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("mixed lights box", /obj/item/storage/box/lights/mixed, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("mouse traps box", /obj/item/storage/box/mousetraps, crafting_flags = NONE, category = CAT_CONTAINERS), \
		new /datum/stack_recipe("candle box", /obj/item/storage/fancy/candle_box, crafting_flags = NONE, category = CAT_CONTAINERS), \
		)),
	null, \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/cardboard)
