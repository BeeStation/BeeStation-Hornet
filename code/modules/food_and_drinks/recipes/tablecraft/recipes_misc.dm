
// see code/module/crafting/table.dm

// MISC

/datum/crafting_recipe/food/candiedapple
	name = "Candied apple"
	reqs = list(
		/datum/reagent/consumable/caramel = 5,
		/obj/item/reagent_containers/food/snacks/grown/apple = 1
	)
	result = /obj/item/reagent_containers/food/snacks/candiedapple
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/spiderlollipop
	name = "Spider Lollipop"
	reqs = list(/obj/item/stack/rods = 1,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/water = 5,
		/obj/item/reagent_containers/food/snacks/spiderling = 1
	)
	result = /obj/item/reagent_containers/food/snacks/spiderlollipop
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/chococoin
	name = "Choco coin"
	reqs = list(
		/obj/item/coin = 1,
		/obj/item/reagent_containers/food/snacks/chocolatebar = 1,
	)
	result = /obj/item/reagent_containers/food/snacks/chococoin
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/fudgedice
	name = "Fudge dice"
	reqs = list(
		/obj/item/dice = 1,
		/obj/item/reagent_containers/food/snacks/chocolatebar = 1,
	)
	result = /obj/item/reagent_containers/food/snacks/fudgedice
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/chocoorange
	name = "Choco orange"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange = 1,
		/obj/item/reagent_containers/food/snacks/chocolatebar = 1,
	)
	result = /obj/item/reagent_containers/food/snacks/chocoorange
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/loadedbakedpotato
	name = "Loaded baked potato"
	time = 40
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/potato = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1
	)
	result = /obj/item/reagent_containers/food/snacks/loadedbakedpotato
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/cheesyfries
	name = "Cheesy fries"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/fries = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1
	)
	result = /obj/item/reagent_containers/food/snacks/cheesyfries
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/beans
	name = "Beans"
	time = 40
	reqs = list(/datum/reagent/consumable/ketchup = 5,
		/obj/item/reagent_containers/food/snacks/grown/soybeans = 2
	)
	result = /obj/item/reagent_containers/food/snacks/canned/beans
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/eggplantparm
	name ="Eggplant parmigiana"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge = 2,
		/obj/item/reagent_containers/food/snacks/grown/eggplant = 1
	)
	result = /obj/item/reagent_containers/food/snacks/eggplantparm
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/baguette
	name = "Baguette"
	time = 40
	reqs = list(/datum/reagent/consumable/sodiumchloride = 1,
				/datum/reagent/consumable/blackpepper = 1,
				/obj/item/food/pastrybase = 2
	)
	result = /obj/item/food/baguette
	subcategory = CAT_MISCFOOD

////////////////////////////////////////////////TOAST////////////////////////////////////////////////

/datum/crafting_recipe/food/slimetoast
	name = "Slime toast"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/food/breadslice/plain = 1
	)
	result = /obj/item/reagent_containers/food/snacks/jelliedtoast/slime
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/jelliedyoast
	name = "Jellied toast"
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/food/breadslice/plain = 1
	)
	result = /obj/item/reagent_containers/food/snacks/jelliedtoast/cherry
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/butteredtoast
	name = "Buttered Toast"
	reqs = list(
		/obj/item/food/breadslice/plain = 1,
		/obj/item/reagent_containers/food/snacks/butter = 1
	)
	result = /obj/item/reagent_containers/food/snacks/butteredtoast
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/twobread
	name = "Two bread"
	reqs = list(
		/datum/reagent/consumable/ethanol/wine = 5,
		/obj/item/food/breadslice/plain = 2
	)
	result = /obj/item/reagent_containers/food/snacks/twobread
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/melonfruitbowl
	name ="Melon fruit bowl"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/watermelon = 1,
		/obj/item/reagent_containers/food/snacks/grown/apple = 1,
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange = 1,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon = 1,
		/obj/item/reagent_containers/food/snacks/grown/banana = 1,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia = 1
	)
	result = /obj/item/reagent_containers/food/snacks/melonfruitbowl
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/melonkeg
	name ="Melon keg"
	reqs = list(
		/datum/reagent/consumable/ethanol/vodka = 25,
		/obj/item/reagent_containers/food/snacks/grown/holymelon = 1,
		/obj/item/reagent_containers/food/drinks/bottle/vodka = 1
	)
	parts = list(/obj/item/reagent_containers/food/drinks/bottle/vodka = 1)
	result = /obj/item/reagent_containers/food/snacks/melonkeg
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/honeybar
	name = "Honey nut bar"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/oat = 1,
		/datum/reagent/consumable/honey = 5
	)
	result = /obj/item/reagent_containers/food/snacks/honeybar
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/powercrepe
	name = "Powercrepe"
	time = 40
	reqs = list(
		/obj/item/food/flatdough = 1,
		/datum/reagent/consumable/milk = 1,
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/stock_parts/cell/super =1,
		/obj/item/melee/sabre = 1
	)
	result = /obj/item/reagent_containers/food/snacks/powercrepe
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/branrequests
	name = "Bran Requests Cereal"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/wheat = 1,
		/obj/item/reagent_containers/food/snacks/no_raisin = 1,
	)
	result = /obj/item/reagent_containers/food/snacks/branrequests
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/ricepudding
	name = "Rice pudding"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/salad/boiledrice = 1
	)
	result = /obj/item/food/salad/ricepudding
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/butterbear //ITS ALIVEEEEEE!
	name = "Living bear/butter hybrid"
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/organ/heart = 1,
		/obj/item/reagent_containers/food/snacks/butter = 10,
		/obj/item/reagent_containers/food/snacks/meat/slab = 5,
		/datum/reagent/blood = 50,
		/datum/reagent/teslium = 1 //To shock the whole thing into life
	)
	result = /mob/living/simple_animal/hostile/bear/butter
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/crab_rangoon
	name = "Crab Rangoon"
	reqs = list(
		/obj/item/food/doughslice = 1,
		/datum/reagent/consumable/cream = 5,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/meat/rawcrab = 1
	)
	result = /obj/item/reagent_containers/food/snacks/crab_rangoon
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/pingles
	name = "Pingles"
	reqs = list(
		/obj/item/c_tube = 1,
		/obj/item/reagent_containers/food/snacks/grown/potato/wedges = 1,
		/obj/item/reagent_containers/food/snacks/onion_slice = 1,
		/datum/reagent/consumable/cream = 10
	)
	result = /obj/item/reagent_containers/food/snacks/pingles
	subcategory = CAT_MISCFOOD
