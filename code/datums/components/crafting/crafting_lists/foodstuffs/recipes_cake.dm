
/// Cakes crafting

/datum/crafting_recipe/food/carrotcake
	name = "Carrot cake"
	result = /obj/item/food/cake/carrot
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/grown/carrot = 2
	)
	category = CAT_CAKE

/datum/crafting_recipe/food/cheesecake
	name = "Cheese cake"
	result = /obj/item/food/cake/cheese
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/cheese/wedge = 2
	)
	category = CAT_CAKE

/datum/crafting_recipe/food/applecake
	name = "Apple cake"
	result = /obj/item/food/cake/apple
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/grown/apple = 2
	)
	category = CAT_CAKE

/datum/crafting_recipe/food/orangecake
	name = "Orange cake"
	result = /obj/item/food/cake/orange
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/grown/citrus/orange = 2
	)
	category = CAT_CAKE

/datum/crafting_recipe/food/limecake
	name = "Lime cake"
	result = /obj/item/food/cake/lime
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/grown/citrus/lime = 2
	)
	category = CAT_CAKE

/datum/crafting_recipe/food/lemoncake
	name = "Lemon cake"
	result = /obj/item/food/cake/lemon
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/grown/citrus/lemon = 2
	)
	category = CAT_CAKE

/datum/crafting_recipe/food/chocolatecake
	name = "Chocolate cake"
	result = /obj/item/food/cake/chocolate
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/chocolatebar = 2
	)
	category = CAT_CAKE

/datum/crafting_recipe/food/birthdaycake
	name = "Birthday cake"
	result = /obj/item/food/cake/birthday
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/candle = 1,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/consumable/caramel = 2
	)
	category = CAT_CAKE

/datum/crafting_recipe/food/energycake
	name = "Energy cake"
	blacklist = list(/obj/item/food/cake/birthday/energy)
	reqs = list(
		/obj/item/food/cake/birthday = 1,
		/obj/item/melee/energy/sword = 1,
	)
	result = /obj/item/food/cake/birthday/energy
	category = CAT_CAKE

/datum/crafting_recipe/food/braincake
	name = "Brain cake"
	result = /obj/item/food/cake/brain
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/food/cake/plain = 1
	)
	category = CAT_CAKE

/datum/crafting_recipe/food/slimecake
	name = "Slime cake"
	result = /obj/item/food/cake/slimecake
	reqs = list(
		/obj/item/slime_extract = 1,
		/obj/item/food/cake/plain = 1
	)
	category = CAT_CAKE

/datum/crafting_recipe/food/pumpkinspicecake
	name = "Pumpkin spice cake"
	result = /obj/item/food/cake/pumpkinspice
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/grown/pumpkin = 2
	)
	category = CAT_CAKE

/datum/crafting_recipe/food/holycake
	name = "Angel food cake"
	result = /obj/item/food/cake/holy_cake
	reqs = list(
		/datum/reagent/water/holywater = 15,
		/obj/item/food/cake/plain = 1
	)
	category = CAT_CAKE

/datum/crafting_recipe/food/poundcake
	name = "Pound cake"
	result = /obj/item/food/cake/pound_cake
	reqs = list(
		/obj/item/food/cake/plain = 4
	)
	category = CAT_CAKE

/datum/crafting_recipe/food/hardwarecake
	name = "Hardware cake"
	result = /obj/item/food/cake/hardware_cake
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/circuitboard = 2,
		/datum/reagent/toxin/acid = 5 //ironic that circuitmaking no longer need acids, but a cake that's a circuit still do
	)
	category = CAT_CAKE

/datum/crafting_recipe/food/berry_chocolate_cake
	name = "strawberry chocolate cake"
	result = /obj/item/food/cake/berry_chocolate_cake
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/chocolatebar = 2,
		/obj/item/food/grown/berries = 5
	)
	category = CAT_CAKE

/datum/crafting_recipe/food/pavlovacream
	name = "Pavlova with cream"
	reqs = list(
		/datum/reagent/consumable/eggwhite = 12,
		/datum/reagent/consumable/sugar = 15,
		/datum/reagent/consumable/whipped_cream = 10,
		/obj/item/food/grown/berries = 5
	)
	result = /obj/item/food/cake/pavlova
	category = CAT_CAKE

/*
/datum/crafting_recipe/food/pavlovakorta
	name = "Pavlova with korta cream"
	reqs = list(
		/datum/reagent/consumable/eggwhite = 12,
		/datum/reagent/consumable/sugar = 15,
		/datum/reagent/consumable/korta_milk = 10,
		/obj/item/food/grown/berries = 5
	)
	result = /obj/item/food/cake/pavlova/nuts
	category = CAT_CAKE
*/

/datum/crafting_recipe/food/berry_vanilla_cake
	name = "blackberry and strawberry vanilla cake"
	result = /obj/item/food/cake/berry_vanilla_cake
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/grown/berries = 5
	)
	category = CAT_CAKE

/datum/crafting_recipe/food/clowncake
	name = "clown cake"
	result = /obj/item/food/cake/clown_cake
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/sundae = 2,
		/obj/item/food/grown/banana = 5
	)
	category = CAT_CAKE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/food/vanillacake
	name = "vanilla cake"
	result = /obj/item/food/cake/vanilla_cake
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/grown/vanillapod = 2
	)
	category = CAT_CAKE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/food/trumpetcake
	name = "Spaceman's Cake"
	result = /obj/item/food/cake/trumpet
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/obj/item/food/grown/flower/trumpet = 2,
		/datum/reagent/consumable/cream = 5,
		/datum/reagent/consumable/berryjuice = 5
	)
	category = CAT_CAKE

/datum/crafting_recipe/food/cak
	name = "Living cat/cake hybrid"
	result = /mob/living/simple_animal/pet/cat/cak
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/organ/heart = 1,
		/obj/item/food/cake/birthday = 1,
		/obj/item/food/meat/slab = 3,
		/datum/reagent/blood = 30,
		/datum/reagent/consumable/sprinkles = 5,
		/datum/reagent/teslium = 1 //To shock the whole thing into life
	)
	category = CAT_CAKE //Cat! Haha, get it? CAT? GET IT? We get it - Love Felines

/datum/crafting_recipe/food/popup_cake
	name = "Towering pile of cakes"
	result = /obj/structure/popout_cake
	reqs = list(
	/obj/item/food/cake/plain = 3,
	/datum/reagent/consumable/sugar = 10,
	/datum/reagent/consumable/cream = 5,
	/obj/item/bikehorn/airhorn = 1
	)
	category = CAT_CAKE
