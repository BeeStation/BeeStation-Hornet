
/// Booze and bottles crafting
/// This is the home of drink related tablecrafting recipes, I have opted to only let players bottle fancy boozes to reduce the number of entries.

/datum/crafting_recipe/lizardwine
	name = "Lizard Wine"
	result = /obj/item/reagent_containers/food/drinks/bottle/lizardwine
	time = 4 SECONDS
	reqs = list(
		/obj/item/organ/tail/lizard = 1,
		/datum/reagent/consumable/ethanol = 100
	)
	category = CAT_DRINK

/datum/crafting_recipe/moonshinejug
	name = "Moonshine Jug"
	result = /obj/item/reagent_containers/food/drinks/bottle/moonshine
	time = 3 SECONDS
	reqs = list(
		/obj/item/reagent_containers/food/drinks/bottle/blank = 1,
		/datum/reagent/consumable/ethanol/moonshine = 100
	)
	category = CAT_DRINK

/datum/crafting_recipe/hoochbottle
	name = "Hooch Bottle"
	result = /obj/item/reagent_containers/food/drinks/bottle/hooch
	time = 3 SECONDS
	reqs = list(
		/obj/item/reagent_containers/food/drinks/bottle/blank = 1,
		/obj/item/storage/box/papersack = 1,
		/datum/reagent/consumable/ethanol/hooch = 100
	)
	category = CAT_DRINK

/datum/crafting_recipe/blazaambottle
	name = "Blazaam Bottle"
	result = /obj/item/reagent_containers/food/drinks/bottle/blazaam
	time = 2 SECONDS
	reqs = list(
		/obj/item/reagent_containers/food/drinks/bottle/blank = 1,
		/datum/reagent/consumable/ethanol/blazaam = 100
	)
	category = CAT_DRINK

/datum/crafting_recipe/champagnebottle
	name = "Champagne Bottle"
	result = /obj/item/reagent_containers/food/drinks/bottle/champagne
	time = 3 SECONDS
	reqs = list(
		/obj/item/reagent_containers/food/drinks/bottle/blank = 1,
		/datum/reagent/consumable/ethanol/champagne = 100
	)
	category = CAT_DRINK

/datum/crafting_recipe/trappistbottle
	name = "Trappist Bottle"
	result = /obj/item/reagent_containers/food/drinks/bottle/trappist
	time = 1.5 SECONDS
	reqs = list(
		/obj/item/reagent_containers/food/drinks/bottle/blank/small = 1,
		/datum/reagent/consumable/ethanol/trappist = 50
	)
	category = CAT_DRINK

/datum/crafting_recipe/goldschlagerbottle
	name = "Goldschlager Bottle"
	result = /obj/item/reagent_containers/food/drinks/bottle/goldschlager
	time = 3 SECONDS
	reqs = list(
		/obj/item/reagent_containers/food/drinks/bottle/blank = 1,
		/datum/reagent/consumable/ethanol/goldschlager = 100
	)
	category = CAT_DRINK

/datum/crafting_recipe/patronbottle
	name = "Patron Bottle"
	result = /obj/item/reagent_containers/food/drinks/bottle/patron
	time = 3 SECONDS
	reqs = list(
		/obj/item/reagent_containers/food/drinks/bottle/blank = 1,
		/datum/reagent/consumable/ethanol/patron = 100
	)
	category = CAT_DRINK

////////////////////// Non-alcoholic recipes ///////////////////

/datum/crafting_recipe/holybottle
	name = "Holy Water Flask"
	result = /obj/item/reagent_containers/food/drinks/bottle/holywater
	time = 3 SECONDS
	reqs = list(
		/obj/item/reagent_containers/food/drinks/bottle/blank = 1,
		/datum/reagent/water/holywater = 100
	)
	category = CAT_DRINK

/datum/crafting_recipe/unholybottle
	name = "Unholy Water Flask"
	result = /obj/item/reagent_containers/food/drinks/bottle/unholywater
	time = 3 SECONDS
	reqs = list(
		/obj/item/reagent_containers/food/drinks/bottle/blank = 1,
		/datum/reagent/fuel/unholywater = 100
	)
	category = CAT_DRINK

/datum/crafting_recipe/nothingbottle
	name = "Nothing Bottle"
	result = /obj/item/reagent_containers/food/drinks/bottle/bottleofnothing
	time = 3 SECONDS
	reqs = list(
		/obj/item/reagent_containers/food/drinks/bottle/blank = 1,
		/datum/reagent/consumable/nothing = 100
	)
	category = CAT_DRINK

/datum/crafting_recipe/smallcarton
	name = "Small Carton"
	result = /obj/item/reagent_containers/food/drinks/sillycup/smallcarton
	time = 1 SECONDS
	reqs = list(/obj/item/stack/sheet/cardboard = 1)
	category = CAT_DRINK

/datum/crafting_recipe/honeycomb
	name = "Honeycomb"
	result = /obj/item/reagent_containers/food/drinks/honeycomb
	always_available = FALSE
	time = 3 SECONDS
	reqs = list(/datum/reagent/consumable/sugar = 50)
	category = CAT_DRINK

