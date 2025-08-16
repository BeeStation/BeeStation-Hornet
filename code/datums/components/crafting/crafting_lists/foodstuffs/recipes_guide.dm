// Recipes that provide crafting instructions and don't yield any result

// Crafting recipes

/datum/crafting_recipe/shiv
	reqs = list(
		/obj/item/shard = 1,
		/obj/item/stack/sheet/cotton/cloth = 1,
	)
	result = /obj/item/knife/shiv
	category = CAT_WEAPON_MELEE
	steps = list("Use cloth on a glass shard of any type")

/datum/crafting_recipe/restraints
	reqs = list(/obj/item/stack/cable_coil = 15)
	result = /obj/item/restraints/handcuffs/cable
	category = CAT_TOOLS

/datum/crafting_recipe/runed_metal
	reqs = list(/obj/item/stack/sheet/plasteel = 1)
	result = /obj/item/stack/sheet/runed_metal
	category = CAT_CULT
	non_craftable = TRUE
	steps = list("Use Twisted Construction on plasteel")

/datum/crafting_recipe/constructshell
	reqs = list(/obj/item/stack/sheet/iron = 50)
	result = /obj/structure/constructshell
	category = CAT_CULT
	non_craftable = TRUE
	steps = list("Use Twisted Construction on iron")

// Food reactions

/datum/crafting_recipe/food/reaction
	category = CAT_MISCFOOD
	non_craftable = TRUE

/datum/crafting_recipe/food/reaction/New()
	..()
	if(!reaction)
		return
	var/datum/chemical_reaction/chemical_reaction = new reaction // This could use GLOB.chemical_reactions_list if it was initialized by now
	reqs = chemical_reaction.required_reagents
	chem_catalysts = chemical_reaction.required_catalysts
	if (chemical_reaction.results.len)
		result = chemical_reaction.results[1]
		result_amount = chemical_reaction.results[result]

/datum/crafting_recipe/food/reaction/candle
	reaction = /datum/chemical_reaction/candlefication
	result = /obj/item/candle
	category = CAT_CAKE

/datum/crafting_recipe/food/reaction/tofu
	reaction = /datum/chemical_reaction/food/tofu
	result = /obj/item/food/tofu

/datum/crafting_recipe/food/reaction/chocolatepudding
	reaction = /datum/chemical_reaction/food/chocolatepudding
	category = CAT_PASTRY

/datum/crafting_recipe/food/reaction/vanillapudding
	reaction = /datum/chemical_reaction/food/vanillapudding
	category = CAT_PASTRY

/datum/crafting_recipe/food/reaction/chocolatebar
	name = "Chocolate bar"
	reaction = /datum/chemical_reaction/food/chocolate_bar3
	result = /obj/item/food/chocolatebar
	category = CAT_PASTRY

/datum/crafting_recipe/food/reaction/chocolatebar/chocomilk
	name = "Chocolate bar (choco milk)"
	reaction = /datum/chemical_reaction/food/chocolate_bar2

/datum/crafting_recipe/food/reaction/chocolatebar/vegan
	name = "Chocolate bar (vegan)"
	reaction = /datum/chemical_reaction/food/chocolate_bar

/datum/crafting_recipe/food/reaction/soysauce
	reaction = /datum/chemical_reaction/food/soysauce

/datum/crafting_recipe/food/reaction/corn_syrup
	reaction = /datum/chemical_reaction/food/corn_syrup

/datum/crafting_recipe/food/reaction/caramel
	reaction = /datum/chemical_reaction/food/caramel
	category = CAT_PASTRY

/datum/crafting_recipe/food/reaction/cheesewheel
	reaction = /datum/chemical_reaction/food/cheesewheel
	result = /obj/item/food/cheese/wheel

/datum/crafting_recipe/food/reaction/synthmeat
	reaction = /datum/chemical_reaction/food/synthmeat
	result = /obj/item/food/meat/slab/synthmeat
	category = CAT_MEAT

/datum/crafting_recipe/food/reaction/imitationcarpmeat
	reaction = /datum/chemical_reaction/food/imitationcarpmeat
	result = /obj/item/food/fishmeat/carp/imitation
	category = CAT_SEAFOOD

/datum/crafting_recipe/food/reaction/dough
	reaction = /datum/chemical_reaction/food/dough
	result = /obj/item/food/dough
	category = CAT_BREAD

/datum/crafting_recipe/food/reaction/cakebatter
	name = "Cake batter"
	reaction = /datum/chemical_reaction/food/cakebatter
	result = /obj/item/food/cakebatter
	category = CAT_BREAD

/datum/crafting_recipe/food/reaction/cakebatter/vegan
	name = "Cake batter (vegan)"
	reaction = /datum/chemical_reaction/food/cakebatter/vegan

/datum/crafting_recipe/food/reaction/pancakebatter
	result = /datum/reagent/consumable/pancakebatter
	reaction = /datum/chemical_reaction/food/pancakebatter
	category = CAT_BREAD

/datum/crafting_recipe/food/reaction/uncooked_rice
	result = /obj/item/food/uncooked_rice
	reaction = /datum/chemical_reaction/food/uncooked_rice
	category = CAT_SALAD

/datum/crafting_recipe/food/reaction/bbqsauce
	result = /datum/reagent/consumable/bbqsauce
	reaction = /datum/chemical_reaction/food/bbqsauce

/datum/crafting_recipe/food/reaction/gravy
	result = /datum/reagent/consumable/gravy
	reaction = /datum/chemical_reaction/food/gravy

//datum/crafting_recipe/food/reaction/olive_oil
//	result = /datum/reagent/consumable/nutriment/fat/oil/olive
//	reaction = /datum/chemical_reaction/food/olive_oil

/datum/crafting_recipe/food/reaction/olive_oil/upconvert
	reaction = /datum/chemical_reaction/food/olive_oil_upconvert

/datum/crafting_recipe/food/reaction/moonshine
	reaction = /datum/chemical_reaction/drink/moonshine

// Tools: Rolling pin

/datum/crafting_recipe/food/rollingpin
	tool_behaviors =  list(TOOL_ROLLINGPIN)
	steps = list("Flatten with a rolling pin")
	category = CAT_MISCFOOD
	non_craftable = TRUE

/datum/crafting_recipe/food/rollingpin/flatdough
	reqs = list(/obj/item/food/dough = 1)
	result = /obj/item/food/flatdough
	category = CAT_BREAD

/datum/crafting_recipe/food/rollingpin/piedough
	reqs = list(/obj/item/food/cakebatter = 1)
	result = /obj/item/food/piedough
	category = CAT_BREAD

/datum/crafting_recipe/food/rollingpin/raw_patty
	reqs = list(/obj/item/food/raw_meatball = 1)
	result = /obj/item/food/raw_patty
	category = CAT_MEAT

// Tools: Knife

/datum/crafting_recipe/food/knife
	tool_behaviors =  list(TOOL_KNIFE)
	steps = list("Slice with a knife")
	category = CAT_MISCFOOD
	non_craftable = TRUE

/datum/crafting_recipe/food/knife/breadslice
	reqs = list(/obj/item/food/bread/plain = 1)
	result = /obj/item/food/breadslice/plain
	category = CAT_BREAD

/datum/crafting_recipe/food/knife/cakeslice
	reqs = list(/obj/item/food/cake/plain = 1)
	result = /obj/item/food/cakeslice/plain
	category = CAT_PASTRY

/datum/crafting_recipe/food/knife/pizzaslice
	reqs = list(/obj/item/food/pizza/margherita = 1)
	result = /obj/item/food/pizzaslice/margherita
	category = CAT_PIZZA

/datum/crafting_recipe/food/knife/doughslice
	reqs = list(/obj/item/food/flatdough = 1)
	result = /obj/item/food/doughslice
	category = CAT_BREAD

/datum/crafting_recipe/food/knife/pastrybase
	reqs = list(/obj/item/food/piedough = 1)
	result = /obj/item/food/pastrybase
	category = CAT_BREAD

/datum/crafting_recipe/food/knife/rawcutlet
	reqs = list(/obj/item/food/meat/slab = 1)
	result = /obj/item/food/meat/rawcutlet
	category = CAT_MEAT

/datum/crafting_recipe/food/knife/potatowedge
	reqs = list(/obj/item/food/grown/potato = 1)
	result = /obj/item/food/grown/potato/wedges

/datum/crafting_recipe/food/knife/pineappleslice
	reqs = list(/obj/item/food/grown/pineapple = 1)
	result = /obj/item/food/pineappleslice

/datum/crafting_recipe/food/knife/onionslice
	reqs = list(/obj/item/food/grown/onion = 1)
	result = /obj/item/food/onion_slice

/datum/crafting_recipe/food/knife/cheesewedge
	reqs = list(/obj/item/food/cheese/wheel = 1)
	result = /obj/item/food/cheese/wedge

/datum/crafting_recipe/food/knife/salami
	reqs = list(/obj/item/food/sausage = 1)
	result = /obj/item/food/salami
	category = CAT_MEAT

/datum/crafting_recipe/food/knife/american_sausage
	reqs = list(/obj/item/food/sausage = 1)
	result = /obj/item/food/sausage/american
	category = CAT_MEAT

/datum/crafting_recipe/food/knife/watermelonslice
	reqs = list(/obj/item/food/grown/watermelon = 1)
	result = /obj/item/food/watermelonslice
	category = CAT_SALAD

// Machinery: Grill

/datum/crafting_recipe/food/grill
	machinery = list(/obj/machinery/griddle)
	steps = list("Grill until ready")
	category = CAT_MEAT
	non_craftable = TRUE

/datum/crafting_recipe/food/grill/meatball
	reqs = list(/obj/item/food/raw_meatball = 1)
	result = /obj/item/food/meatball

/datum/crafting_recipe/food/grill/patty
	reqs = list(/obj/item/food/raw_patty = 1)
	result = /obj/item/food/patty

/datum/crafting_recipe/food/grill/cutlet
	reqs = list(/obj/item/food/meat/rawcutlet = 1)
	result = /obj/item/food/meat/cutlet

/datum/crafting_recipe/food/grill/steak
	reqs = list(/obj/item/food/meat/slab = 1)
	result = /obj/item/food/meat/steak

/datum/crafting_recipe/food/grill/steak/chicken
	reqs = list(/obj/item/food/meat/slab/chicken = 1)
	result = /obj/item/food/meat/steak/chicken

/datum/crafting_recipe/food/grill/crab
	reqs = list(/obj/item/food/meat/slab/rawcrab = 1)
	result = /obj/item/food/meat/crab

/datum/crafting_recipe/food/grill/bacon
	reqs = list(/obj/item/food/meat/rawbacon = 1)
	result = /obj/item/food/meat/bacon

/datum/crafting_recipe/food/grill/sausage
	reqs = list(/obj/item/food/raw_sausage = 1)
	result = /obj/item/food/sausage

/datum/crafting_recipe/food/grill/griddle_toast
	reqs = list(/obj/item/food/breadslice/plain = 1)
	result = /obj/item/food/griddle_toast
	category = CAT_BREAD

/datum/crafting_recipe/food/grill/khinkali
	reqs = list(/obj/item/food/rawkhinkali = 1)
	result = /obj/item/food/khinkali
	category = CAT_BREAD

/datum/crafting_recipe/food/grill/grilled_cheese_sandwich
	reqs = list(/obj/item/food/cheese_sandwich = 1)
	result = /obj/item/food/grilled_cheese_sandwich
	category = CAT_SANDWICH

/datum/crafting_recipe/food/grill/grilled_cheese
	reqs = list(/obj/item/food/cheese/wedge = 1)
	result = /obj/item/food/grilled_cheese_sandwich
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/grill/friedegg
	reqs = list(/obj/item/food/egg = 1)
	result = /obj/item/food/friedegg
	category = CAT_EGG
	steps = list(
		"Break the egg onto a griddle",
		"Fry until ready"
	)

/datum/crafting_recipe/food/grill/pancake
	reqs = list(/datum/reagent/consumable/pancakebatter = 5)
	result = /obj/item/food/pancakes
	category = CAT_BREAD
	steps = list(
		"Pour batter onto a griddle",
		"Bake until ready"
	)

/datum/crafting_recipe/food/grill/pancake/blueberry
	reqs = list(
		/datum/reagent/consumable/pancakebatter = 5,
		/obj/item/food/grown/berries = 1
	)
	result = /obj/item/food/pancakes/blueberry
	steps = list(
		"Pour batter onto a griddle",
		"Add berries",
		"Bake until ready"
	)

/datum/crafting_recipe/food/grill/pancake/choco
	reqs = list(
		/datum/reagent/consumable/pancakebatter = 5,
		/obj/item/food/chocolatebar = 1
	)
	result = /obj/item/food/pancakes/chocolatechip
	steps = list(
		"Pour batter onto a griddle",
		"Add chocolate",
		"Bake until ready"
	)

// Machinery: Grinder
/datum/crafting_recipe/food/grinder
	machinery = list(/obj/machinery/reagentgrinder)
	steps = list("Put into grinder and grind")
	category = CAT_MISCFOOD
	non_craftable = TRUE

/datum/crafting_recipe/food/grinder/capsaicin
	reqs = list(/obj/item/food/grown/chili = 1)
	result = /datum/reagent/consumable/capsaicin

/datum/crafting_recipe/food/grinder/frostoil
	reqs = list(/obj/item/food/grown/icepepper = 1)
	result = /datum/reagent/consumable/frostoil

/datum/crafting_recipe/food/grinder/ketchup
	reqs = list(/obj/item/food/grown/tomato = 1)
	result = /datum/reagent/consumable/ketchup

/datum/crafting_recipe/food/grinder/flour
	reqs = list(/obj/item/food/grown/wheat = 1)
	result = /datum/reagent/consumable/flour

/datum/crafting_recipe/food/grinder/flour/oat
	reqs = list(/obj/item/food/grown/oat = 1)
	result = /datum/reagent/consumable/flour

/datum/crafting_recipe/food/grinder/butter
	reqs = list(/datum/reagent/consumable/milk = 15)
	result = /obj/item/food/butter
	steps = list("Put into grinder and mix")

/datum/crafting_recipe/food/grinder/mayonnaise
	reqs = list(/datum/reagent/consumable/eggyolk = 1)
	result = /datum/reagent/consumable/mayonnaise
	steps = list("Put into grinder and mix")

/datum/crafting_recipe/food/grinder/sugar
	reqs = list(/obj/item/food/grown/sugarcane = 1)
	result = /datum/reagent/consumable/sugar

/datum/crafting_recipe/food/grinder/sugar/beet
	reqs = list(/obj/item/food/grown/whitebeet = 1)
	result = /datum/reagent/consumable/sugar

/datum/crafting_recipe/food/grinder/cornstarch
	reqs = list(/obj/item/food/grown/corn = 1)
	result = /datum/reagent/consumable/corn_starch
	steps = list("Put into grinder and juice")

/datum/crafting_recipe/food/grinder/sprinkles
	reqs = list(/obj/item/food/donut/plain = 1)
	result = /datum/reagent/consumable/sprinkles

/datum/crafting_recipe/food/grinder/cherryjelly
	reqs = list(/obj/item/food/grown/cherries = 1)
	result = /datum/reagent/consumable/cherryjelly

/datum/crafting_recipe/food/grinder/bluecherryjelly
	reqs = list(/obj/item/food/grown/bluecherries = 1)
	result = /datum/reagent/consumable/bluecherryjelly

// Machinery: Processor
/datum/crafting_recipe/food/processor
	machinery = list(/obj/machinery/processor)
	steps = list("Put into processor and activate")
	category = CAT_MISCFOOD
	non_craftable = TRUE

/datum/crafting_recipe/food/processor/rawbacon
	reqs = list(/obj/item/food/meat/rawcutlet = 1)
	result = /obj/item/food/meat/rawbacon
	category = CAT_MEAT

/datum/crafting_recipe/food/processor/rawmeatball
	reqs = list(/obj/item/food/meat/slab = 1)
	result = /obj/item/food/raw_meatball
	category = CAT_MEAT

/datum/crafting_recipe/food/processor/tatortot
	reqs = list(/obj/item/food/grown/potato = 1)
	result = /obj/item/food/tatortot

/datum/crafting_recipe/food/processor/fries
	reqs = list(/obj/item/food/grown/potato/wedges = 1)
	result = /obj/item/food/fries

/datum/crafting_recipe/food/processor/carrotfries
	reqs = list(/obj/item/food/grown/carrot = 1)
	result = /obj/item/food/carrotfries

/datum/crafting_recipe/food/processor/roastparsnip
	reqs = list(/obj/item/food/grown/parsnip = 1)
	result = /obj/item/food/roastparsnip

/datum/crafting_recipe/food/processor/soydope
	reqs = list(/obj/item/food/grown/soybeans = 1)
	result = /obj/item/food/soydope

/datum/crafting_recipe/food/processor/spaghetti
	reqs = list(/obj/item/food/doughslice = 1)
	result = /obj/item/food/spaghetti/raw
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/processor/tortilla
	reqs = list(/obj/item/food/grown/corn = 1)
	result = /obj/item/food/tortilla
	category = CAT_BREAD

/datum/crafting_recipe/food/processor/yakiimo
	reqs = list(/obj/item/food/grown/potato/sweet = 1)
	result = /obj/item/food/yakiimo

// Machinery: Microwave
/datum/crafting_recipe/food/microwave
	machinery = list(/obj/machinery/microwave)
	steps = list("Microwave until ready")
	category = CAT_MISCFOOD
	non_craftable = TRUE

/datum/crafting_recipe/food/microwave/boiledegg
	reqs = list(/obj/item/food/egg = 1)
	result = /obj/item/food/boiledegg
	category = CAT_EGG

/datum/crafting_recipe/food/microwave/boiledrice
	reqs = list(/obj/item/food/uncooked_rice = 1)
	result = /obj/item/food/boiledrice
	category = CAT_SALAD

/datum/crafting_recipe/food/microwave/boiledspaghetti
	reqs = list(/obj/item/food/spaghetti/raw = 1)
	result = /obj/item/food/spaghetti/boiledspaghetti
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/microwave/onionrings
	reqs = list(/obj/item/food/onion_slice = 1)
	result = /obj/item/food/onionrings
	category = CAT_SALAD

/datum/crafting_recipe/food/microwave/popcorn
	reqs = list(/obj/item/food/grown/corn = 1)
	result = /obj/item/food/popcorn

/datum/crafting_recipe/food/microwave/cakehat
	reqs = list(/obj/item/food/cake/birthday = 1)
	result = /obj/item/clothing/head/utility/hardhat/cakehat
	category = CAT_CAKE

/datum/crafting_recipe/food/microwave/cakehat/energycake
	reqs = list(/obj/item/food/cake/birthday/energy = 1)
	result = /obj/item/clothing/head/utility/hardhat/cakehat/energycake
	category = CAT_CAKE

// Machinery: Oven
/datum/crafting_recipe/food/oven
	machinery = list(/obj/machinery/oven)
	steps = list("Bake in the oven until ready")
	category = CAT_BREAD
	non_craftable = TRUE

/datum/crafting_recipe/food/oven/bread
	reqs = list(/obj/item/food/dough = 1)
	result = /obj/item/food/bread/plain

/datum/crafting_recipe/food/oven/bun
	reqs = list(/obj/item/food/doughslice = 1)
	result = /obj/item/food/bun

/datum/crafting_recipe/food/oven/pastrybase
	reqs = list(/obj/item/food/rawpastrybase = 1)
	result = /obj/item/food/pastrybase
	category = CAT_PASTRY

/datum/crafting_recipe/food/oven/pizzabread
	reqs = list(/obj/item/food/flatdough = 1)
	result = /obj/item/food/pizzabread
	category = CAT_PIZZA

/datum/crafting_recipe/food/oven/pizza
	reqs = list(/obj/item/food/pizza/margherita/raw = 1)
	result = /obj/item/food/pizza/margherita
	category = CAT_PIZZA

/datum/crafting_recipe/food/oven/pie
	reqs = list(/obj/item/food/piedough = 1)
	result = /obj/item/food/pie/plain
	category = CAT_PASTRY

/datum/crafting_recipe/food/oven/cake
	reqs = list(/obj/item/food/cakebatter = 1)
	result = /obj/item/food/cake/plain
	category = CAT_PASTRY

/datum/crafting_recipe/food/oven/yakiimo
	reqs = list(/obj/item/food/grown/potato/sweet = 1)
	result = /obj/item/food/yakiimo
	category = CAT_SALAD

// Machinery: Drying rack
/datum/crafting_recipe/food/drying
	machinery = list(/obj/machinery/smartfridge/drying/rack)
	steps = list("Put into the rack and dry")
	category = CAT_MISCFOOD
	non_craftable = TRUE

/datum/crafting_recipe/food/drying/sosjerky
	reqs = list(/obj/item/food/meat/slab = 1)
	result = /obj/item/food/sosjerky/healthy
	category = CAT_MEAT

/datum/crafting_recipe/food/drying/no_raisin/healthy
	reqs = list(/obj/item/food/grown/grapes = 1)
	result = /obj/item/food/no_raisin/healthy
