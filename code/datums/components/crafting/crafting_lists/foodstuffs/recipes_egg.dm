
/// Egg stuff crafting

/datum/crafting_recipe/food/omelette
	name = "Omelette du fromage"
	result = /obj/item/food/omelette
	reqs = list(
		/obj/item/food/egg = 2,
		/obj/item/food/cheese/wedge = 2
	)
	subcategory = CAT_EGG

/datum/crafting_recipe/food/chocolateegg
	name = "Chocolate egg"
	result = /obj/item/food/chocolateegg
	reqs = list(
		/obj/item/food/boiledegg = 1,
		/obj/item/food/chocolatebar = 1
	)
	subcategory = CAT_EGG

/datum/crafting_recipe/food/eggsbenedict
	name = "Eggs benedict"
	result = /obj/item/food/benedict
	reqs = list(
		/obj/item/food/friedegg = 1,
		/obj/item/food/meat/steak = 1,
		/obj/item/food/breadslice/plain = 1,
	)
	subcategory = CAT_EGG

/datum/crafting_recipe/food/eggbowl
	name = "Egg bowl"
	result = /obj/item/food/salad/eggbowl
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/boiledrice = 1,
		/obj/item/food/boiledegg = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/corn = 1
	)
	subcategory = CAT_EGG

/datum/crafting_recipe/food/wrap
	name = "Wrap"
	result = /obj/item/food/eggwrap
	reqs = list(/datum/reagent/consumable/soysauce = 10,
		/obj/item/food/friedegg = 1,
		/obj/item/food/grown/cabbage = 1,
	)
	subcategory = CAT_EGG

/datum/crafting_recipe/food/chawanmushi
	name = "Chawanmushi"
	result = /obj/item/food/chawanmushi
	reqs = list(
		/datum/reagent/water = 5,
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/food/boiledegg = 2,
		/obj/item/food/grown/mushroom/chanterelle = 1
	)
	subcategory = CAT_EGG
