
/// Pastry crafting
/// Donuts Crafting
/datum/crafting_recipe/food/donut
	name = "Donut"
	result = /obj/item/food/donut/plain
	time = 1.5 SECONDS
	reqs = list(
		/datum/reagent/consumable/sugar = 1,
		/obj/item/food/pastrybase = 1
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donut/chaos
	name = "Chaos donut"
	result = /obj/item/food/donut/chaos
	reqs = list(
		/datum/reagent/consumable/frostoil = 5,
		/datum/reagent/consumable/capsaicin = 5,
		/obj/item/food/pastrybase = 1
	)

/datum/crafting_recipe/food/donut/meat
	name = "Meat donut"
	result = /obj/item/food/donut/meat
	reqs = list(
		/obj/item/food/meat/rawcutlet = 1,
		/obj/item/food/pastrybase = 1
	)

/datum/crafting_recipe/food/donut/jelly
	name = "Jelly donut"
	result = /obj/item/food/donut/jelly/plain
	reqs = list(
		/datum/reagent/consumable/berryjuice = 5,
		/obj/item/food/pastrybase = 1
	)

/datum/crafting_recipe/food/donut/slimejelly
	name = "Slime jelly donut"
	result = /obj/item/food/donut/jelly/slimejelly/plain
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/food/pastrybase = 1
	)


/datum/crafting_recipe/food/donut/berry
	name = "Berry Donut"
	result = /obj/item/food/donut/berry
	reqs = list(
		/datum/reagent/consumable/berryjuice = 3,
		/obj/item/food/donut/plain = 1
	)

/datum/crafting_recipe/food/donut/trumpet
	name = "Spaceman's Donut"
	result = /obj/item/food/donut/trumpet
	reqs = list(
		/datum/reagent/medicine/polypyr = 3,
		/obj/item/food/donut/plain = 1
	)

/datum/crafting_recipe/food/donut/apple
	name = "Apple Donut"
	result = /obj/item/food/donut/apple
	reqs = list(
		/datum/reagent/consumable/applejuice = 3,
		/obj/item/food/donut/plain = 1
	)

/datum/crafting_recipe/food/donut/caramel
	name = "Caramel Donut"
	result = /obj/item/food/donut/caramel
	reqs = list(
		/datum/reagent/consumable/caramel = 3,
		/obj/item/food/donut/plain = 1
	)

/datum/crafting_recipe/food/donut/choco
	name = "Chocolate Donut"
	result = /obj/item/food/donut/choco
	reqs = list(
		/obj/item/food/chocolatebar = 1,
		/obj/item/food/donut/plain = 1
	)

/datum/crafting_recipe/food/donut/blumpkin
	name = "Blumpkin Donut"
	result = /obj/item/food/donut/blumpkin
	reqs = list(
		/datum/reagent/consumable/blumpkinjuice = 3,
		/obj/item/food/donut/plain = 1
	)

/datum/crafting_recipe/food/donut/bungo
	name = "Bungo Donut"
	result = /obj/item/food/donut/bungo
	reqs = list(
		/datum/reagent/consumable/bungojuice = 3,
		/obj/item/food/donut/plain = 1
	)

/datum/crafting_recipe/food/donut/matcha
	name = "Matcha Donut"
	result = /obj/item/food/donut/matcha
	reqs = list(
		/datum/reagent/toxin/teapowder = 3,
		/obj/item/food/donut/plain = 1
	)

	///Jelly Donuts Crafting

/datum/crafting_recipe/food/donut/jelly/berry
	name = "Berry Jelly Donut"
	result = /obj/item/food/donut/jelly/berry
	reqs = list(
		/datum/reagent/consumable/berryjuice = 3,
		/obj/item/food/donut/jelly/plain = 1
	)

/datum/crafting_recipe/food/donut/jelly/trumpet
	name = "Spaceman's Jelly Donut"
	result = /obj/item/food/donut/jelly/trumpet
	reqs = list(
		/datum/reagent/medicine/polypyr = 3,
		/obj/item/food/donut/jelly/plain = 1
	)

/datum/crafting_recipe/food/donut/jelly/apple
	name = "Apple Jelly Donut"
	result = /obj/item/food/donut/jelly/apple
	reqs = list(
		/datum/reagent/consumable/applejuice = 3,
		/obj/item/food/donut/jelly/plain = 1
	)

/datum/crafting_recipe/food/donut/jelly/caramel
	name = "Caramel Jelly Donut"
	result = /obj/item/food/donut/jelly/caramel
	reqs = list(
		/datum/reagent/consumable/caramel = 3,
		/obj/item/food/donut/jelly/plain = 1
	)

/datum/crafting_recipe/food/donut/jelly/choco
	name = "Chocolate Jelly Donut"
	result = /obj/item/food/donut/jelly/choco
	reqs = list(
		/obj/item/food/chocolatebar = 1,
		/obj/item/food/donut/jelly/plain = 1
	)

/datum/crafting_recipe/food/donut/jelly/blumpkin
	name = "Blumpkin Jelly Donut"
	result = /obj/item/food/donut/jelly/blumpkin
	reqs = list(
		/datum/reagent/consumable/blumpkinjuice = 3,
		/obj/item/food/donut/jelly/plain = 1
	)

/datum/crafting_recipe/food/donut/jelly/bungo
	name = "Bungo Jelly Donut"
	result = /obj/item/food/donut/jelly/bungo
	reqs = list(
		/datum/reagent/consumable/bungojuice = 3,
		/obj/item/food/donut/jelly/plain = 1
	)

/datum/crafting_recipe/food/donut/jelly/matcha
	name = "Matcha Jelly Donut"
	result = /obj/item/food/donut/jelly/matcha
	reqs = list(
		/datum/reagent/toxin/teapowder = 3,
		/obj/item/food/donut/jelly/plain = 1
	)

///Slime Donuts Crafting

/datum/crafting_recipe/food/donut/slimejelly/berry
	name = "Berry Slime Donut"
	result = /obj/item/food/donut/jelly/slimejelly/berry
	reqs = list(
		/datum/reagent/consumable/berryjuice = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)

/datum/crafting_recipe/food/donut/slimejelly/trumpet
	name = "Spaceman's Slime Donut"
	result = /obj/item/food/donut/jelly/slimejelly/trumpet
	reqs = list(
		/datum/reagent/medicine/polypyr = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)

/datum/crafting_recipe/food/donut/slimejelly/apple
	name = "Apple Slime Donut"
	result = /obj/item/food/donut/jelly/slimejelly/apple
	reqs = list(
		/datum/reagent/consumable/applejuice = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)

/datum/crafting_recipe/food/donut/slimejelly/caramel
	name = "Caramel Slime Donut"
	result = /obj/item/food/donut/jelly/slimejelly/caramel
	reqs = list(
		/datum/reagent/consumable/caramel = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)

/datum/crafting_recipe/food/donut/slimejelly/choco
	name = "Chocolate Slime Donut"
	result = /obj/item/food/donut/jelly/slimejelly/choco
	reqs = list(
		/obj/item/food/chocolatebar = 1,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)

/datum/crafting_recipe/food/donut/slimejelly/blumpkin
	name = "Blumpkin Slime Donut"
	result = /obj/item/food/donut/jelly/slimejelly/blumpkin
	reqs = list(
		/datum/reagent/consumable/blumpkinjuice = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)

/datum/crafting_recipe/food/donut/slimejelly/bungo
	name = "Bungo Slime Donut"
	result = /obj/item/food/donut/jelly/slimejelly/bungo
	reqs = list(
		/datum/reagent/consumable/bungojuice = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)

/datum/crafting_recipe/food/donut/slimejelly/matcha
	name = "Matcha Slime Donut"
	result = /obj/item/food/donut/jelly/slimejelly/matcha
	reqs = list(
		/datum/reagent/toxin/teapowder = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)

/datum/crafting_recipe/food/waffles
	name = "Waffles"
	result = /obj/item/food/waffles
	time = 1.5 SECONDS
	reqs = list(
		/obj/item/food/pastrybase = 2
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/soylenviridians
	name = "Soylent viridians"
	result = /obj/item/food/soylenviridians
	reqs = list(
		/obj/item/food/pastrybase = 2,
		/obj/item/food/grown/soybeans = 1
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/soylentgreen
	name = "Soylent green"
	result = /obj/item/food/soylentgreen
	reqs = list(
		/obj/item/food/pastrybase = 2,
		/obj/item/food/meat/slab/human = 2
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/rofflewaffles
	name = "Roffle waffles"
	result = /obj/item/food/rofflewaffles
	reqs = list(
		/datum/reagent/drug/mushroomhallucinogen = 5,
		/obj/item/food/pastrybase = 2
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket
	name = "Donk-pocket"
	result = /obj/item/food/donkpocket
	time = 1.5 SECONDS
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/meatball = 1
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/dankpocket
	name = "Dank-pocket"
	result = /obj/item/food/donkpocket/dankpocket
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/cannabis = 1
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/spicy
	name = "Spicy-pocket"
	result = /obj/item/food/donkpocket/spicy
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/chili = 1
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/teriyaki
	name = "Teriyaki-pocket"
	result = /obj/item/food/donkpocket/teriyaki
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/datum/reagent/consumable/soysauce = 3
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/pizza
	name = "Pizza-pocket"
	result = /obj/item/food/donkpocket/pizza
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/tomato = 1
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/honk
	name = "Honk-Pocket"
	result = /obj/item/food/donkpocket/honk
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/banana = 1,
		/datum/reagent/consumable/sugar = 3
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/berry
	name = "Berry-pocket"
	result = /obj/item/food/donkpocket/berry
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/berries = 1
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/gondola //PERKELE :DDD
	name = "Gondola-pocket"
	result = /obj/item/food/donkpocket/gondola
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/datum/reagent/tranquility = 5
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/muffin
	name = "Muffin"
	result = /obj/item/food/muffin
	time = 1.5 SECONDS
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/pastrybase = 1
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/muffin/berrymuffin
	name = "Berry muffin"
	result = /obj/item/food/muffin/berry
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/berries = 1
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/muffin/booberrymuffin
	name = "Booberry muffin"
	result = /obj/item/food/muffin/booberry
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/berries = 1,
		/obj/item/ectoplasm = 1
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/muffin/moffin
	name = "Moffin"
	result = /obj/item/food/muffin/moffin
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/pastrybase = 1,
		/obj/item/stack/sheet/cotton/cloth = 1,
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/khachapuri
	name = "Khachapuri"
	result = /obj/item/food/khachapuri
	reqs = list(
		/datum/reagent/consumable/eggyolk = 2,
		/datum/reagent/consumable/eggwhite = 4,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/bread/plain = 1
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/sugarcookie
	name = "Sugar cookie"
	result = /obj/item/food/cookie/sugar
	time = 1.5 SECONDS
	reqs = list(
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/pastrybase = 1
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/fortunecookie
	name = "Fortune cookie"
	result = /obj/item/food/fortunecookie
	time = 1.5 SECONDS
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/paper = 1
	)
	parts =	list(/obj/item/paper = 1)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/poppypretzel
	name = "Poppy pretzel"
	result = /obj/item/food/poppypretzel
	time = 1.5 SECONDS
	reqs = list(
		/obj/item/seeds/flower/poppy = 1,
		/obj/item/food/pastrybase = 1
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/plumphelmetbiscuit
	name = "Plumphelmet biscuit"
	result = /obj/item/food/plumphelmetbiscuit
	time = 1.5 SECONDS
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/mushroom/plumphelmet = 1
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/cracker
	name = "Cracker"
	result = /obj/item/food/cracker
	time = 1.5 SECONDS
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/food/pastrybase = 1,
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/chococornet
	name = "Choco cornet"
	result = /obj/item/food/chococornet
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/food/pastrybase = 1,
		/obj/item/food/chocolatebar = 1
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/oatmealcookie
	name = "Oatmeal cookie"
	result = /obj/item/food/cookie/oatmeal
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/oat = 1
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/raisincookie
	name = "Raisin cookie"
	result = /obj/item/food/cookie/raisin
	reqs = list(
		/obj/item/food/no_raisin = 1,
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/oat = 1
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/cherrycupcake
	name = "Cherry cupcake"
	result = /obj/item/food/cherrycupcake
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/cherries = 1
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/bluecherrycupcake
	name = "Blue cherry cupcake"
	result = /obj/item/food/cherrycupcake/blue
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/bluecherries = 1
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/jupitercupcake
	name = "Jupiter-cup-cake"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/mushroom/jupitercup = 1,
		/datum/reagent/consumable/caramel = 3,
	)
	result = /obj/item/food/jupitercupcake
	category = CAT_PASTRY

/datum/crafting_recipe/food/honeybun
	name = "Honey bun"
	result = /obj/item/food/honeybun
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/datum/reagent/consumable/honey = 5
	)
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/ravtart
	name = "Rav'tart"
	result = /obj/item/food/ravtart
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/stack/sheet/bronze = 1,
		/obj/item/food/grown/berries = 2,
		/obj/item/food/grown/citrus/orange = 1
	)
	subcategory = CAT_PASTRY
