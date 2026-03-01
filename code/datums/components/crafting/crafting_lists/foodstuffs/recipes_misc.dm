
/// Misc. Foodstuff crafting

/datum/crafting_recipe/food/candiedapple
	name = "Candied apple"
	result = /obj/item/food/candiedapple
	reqs = list(
		/datum/reagent/consumable/caramel = 5,
		/obj/item/food/grown/apple = 1
	)
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/spiderlollipop
	name = "Spider Lollipop"
	result = /obj/item/food/spiderlollipop
	reqs = list(/obj/item/stack/rods = 1,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/water = 5,
		/obj/item/food/spiderling = 1
	)
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/chococoin
	name = "Choco coin"
	result = /obj/item/food/chococoin
	reqs = list(
		/obj/item/coin = 1,
		/obj/item/food/chocolatebar = 1,
	)
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/fudgedice
	name = "Fudge dice"
	result = /obj/item/food/fudgedice
	reqs = list(
		/obj/item/dice = 1,
		/obj/item/food/chocolatebar = 1,
	)
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/chocoorange
	name = "Choco orange"
	result = /obj/item/food/chocoorange
	reqs = list(
		/obj/item/food/grown/citrus/orange = 1,
		/obj/item/food/chocolatebar = 1,
	)
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/loaded_baked_potato
	name = "Loaded baked potato"
	result = /obj/item/food/loaded_baked_potato
	reqs = list(
		/obj/item/food/grown/potato = 1,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/meat/bacon = 1,
		/obj/item/food/grown/cabbage = 1,
	)
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/cheesyfries
	name = "Cheesy fries"
	result = /obj/item/food/cheesyfries
	reqs = list(
		/obj/item/food/fries = 1,
		/obj/item/food/cheese/wedge = 1
	)
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/beans
	name = "Beans"
	result = /obj/item/food/canned/beans
	time = 4 SECONDS
	reqs = list(/datum/reagent/consumable/ketchup = 5,
		/obj/item/food/grown/soybeans = 2
	)
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/eggplantparm
	name ="Eggplant parmigiana"
	result = /obj/item/food/eggplantparm
	reqs = list(
		/obj/item/food/cheese/wedge = 2,
		/obj/item/food/grown/eggplant = 1
	)
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/melonkeg
	name ="Melon keg"
	result = /obj/item/food/melonkeg
	reqs = list(
		/datum/reagent/consumable/ethanol/vodka = 25,
		/obj/item/food/grown/holymelon = 1,
		/obj/item/reagent_containers/cup/glass/bottle/vodka = 1
	)
	parts = list(/obj/item/reagent_containers/cup/glass/bottle/vodka = 1)
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/honeybar
	name = "Honey nut bar"
	result = /obj/item/food/honeybar
	reqs = list(
		/obj/item/food/grown/oat = 1,
		/datum/reagent/consumable/honey = 5
	)
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/powercrepe
	name = "Powercrepe"
	result = /obj/item/food/powercrepe
	time = 4 SECONDS
	reqs = list(
		/obj/item/food/flatdough = 1,
		/datum/reagent/consumable/milk = 1,
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/stock_parts/cell/super =1,
		/obj/item/melee/sabre = 1
	)
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/branrequests
	name = "Bran Requests Cereal"
	result = /obj/item/food/branrequests
	reqs = list(
		/obj/item/food/grown/wheat = 1,
		/obj/item/food/no_raisin = 1,
	)
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/ricepudding
	name = "Rice pudding"
	result = /obj/item/food/salad/ricepudding
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/boiledrice = 1
	)
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/butterbear //ITS ALIVEEEEEE!
	name = "Living bear/butter hybrid"
	result = /mob/living/simple_animal/hostile/bear/butter
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/organ/heart = 1,
		/obj/item/food/butter = 10,
		/obj/item/food/meat/slab = 5,
		/datum/reagent/blood = 50,
		/datum/reagent/teslium = 1 //To shock the whole thing into life
	)
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/crab_rangoon
	name = "Crab Rangoon"
	result = /obj/item/food/crab_rangoon
	reqs = list(
		/obj/item/food/doughslice = 1,
		/datum/reagent/consumable/cream = 5,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/meat/rawcrab = 1
	)
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/ant_candy
	name = "Ant Candy"
	reqs = list(/obj/item/stack/rods = 1,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/water = 5,
		/datum/reagent/ants = 10
	)
	result = /obj/item/food/ant_candy
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/pingles
	name = "Pingles"
	result = /obj/item/food/pingles
	reqs = list(
		/obj/item/c_tube = 1,
		/obj/item/food/grown/potato/wedges = 1,
		/obj/item/food/onion_slice = 1,
		/datum/reagent/consumable/cream = 10
	)
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/swirl_lollipop
	name = "swirl lollipop"
	result = /obj/item/food/swirl_lollipop
	reqs = list(
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/consumable/caramel = 5,
		/datum/reagent/drug/happiness = 5,
		)
	category = CAT_MISCFOOD

///Easter foods crafting

/datum/crafting_recipe/food/hotcrossbun
	name = "Hot-Cross Bun"
	result = /obj/item/food/hotcrossbun
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/datum/reagent/consumable/sugar = 1
	)
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/briochecake
	name = "Brioche cake"
	result = /obj/item/food/cake/brioche
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/datum/reagent/consumable/sugar = 2
	)
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/scotchegg
	name = "Scotch egg"
	result = /obj/item/food/scotchegg
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/datum/reagent/consumable/blackpepper = 1,
		/obj/item/food/boiledegg = 1,
		/obj/item/food/meatball = 1
	)
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/mammi
	name = "Mammi"
	result = /obj/item/food/soup/mammi
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/obj/item/food/chocolatebar = 1,
		/datum/reagent/consumable/milk = 5
	)
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/chocolatebunny
	name = "Chocolate bunny"
	result = /obj/item/food/chocolatebunny
	reqs = list(
		/datum/reagent/consumable/sugar = 2,
		/obj/item/food/chocolatebar = 1
	)
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/onigiri
	name = "Onigiri"
	reqs = list(
		/obj/item/food/boiledrice = 1,
		/obj/item/food/seaweed_sheet = 1,
	)
	result = /obj/item/food/onigiri
	category = CAT_MISCFOOD
