
/// Misc. foodstuff crafting

/datum/crafting_recipe/food/icecreamsandwich
	name = "Icecream sandwich"
	result = /obj/item/food/icecreamsandwich
	reqs = list(
		/datum/reagent/consumable/cream = 5,
		/datum/reagent/consumable/ice = 5,
		/obj/item/food/icecream = 1
	)
	category = CAT_ICE

/datum/crafting_recipe/food/strawberryicecreamsandwich
	name = "Strawberry ice cream sandwich"
	result = /obj/item/food/strawberryicecreamsandwich
	reqs = list(
		/datum/reagent/consumable/cream = 5,
		/datum/reagent/consumable/ice = 5,
		/obj/item/food/grown/berries = 2,
	)
	category = CAT_ICE

/datum/crafting_recipe/food/spacefreezy
	name ="Space freezy"
	result = /obj/item/food/spacefreezy
	reqs = list(
		/datum/reagent/consumable/bluecherryjelly = 5,
		/datum/reagent/consumable/spacemountainwind = 15,
		/obj/item/food/icecream = 1
	)
	category = CAT_ICE

/datum/crafting_recipe/food/sundae
	name ="Sundae"
	result = /obj/item/food/sundae
	reqs = list(
		/datum/reagent/consumable/cream = 5,
		/obj/item/food/grown/cherries = 1,
		/obj/item/food/grown/banana = 1,
		/obj/item/food/icecream = 1
	)
	category = CAT_ICE

/datum/crafting_recipe/food/honkdae
	name ="Honkdae"
	result = /obj/item/food/honkdae
	reqs = list(
		/datum/reagent/consumable/cream = 5,
		/obj/item/clothing/mask/gas/clown_hat = 1,
		/obj/item/food/grown/cherries = 1,
		/obj/item/food/grown/banana = 2,
		/obj/item/food/icecream = 1
	)
	category = CAT_ICE

//////////////////////////SNOW CONES///////////////////////

/datum/crafting_recipe/food/flavorless_sc
	name = "Flavorless snowcone"
	result = /obj/item/food/snowcones
	reqs = list(
		/obj/item/reagent_containers/cup/glass/sillycup = 1,
		/datum/reagent/consumable/ice = 15
	)
	category = CAT_ICE

/datum/crafting_recipe/food/pineapple_sc
	name = "Pineapple snowcone"
	result = /obj/item/food/snowcones/pineapple
	reqs = list(
		/obj/item/reagent_containers/cup/glass/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/pineapplejuice = 5
	)
	category = CAT_ICE

/datum/crafting_recipe/food/lime_sc
	name = "Lime snowcone"
	result = /obj/item/food/snowcones/lime
	reqs = list(
		/obj/item/reagent_containers/cup/glass/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/limejuice = 5
	)
	category = CAT_ICE

/datum/crafting_recipe/food/lemon_sc
	name = "Lemon snowcone"
	result = /obj/item/food/snowcones/lemon
	reqs = list(
		/obj/item/reagent_containers/cup/glass/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/lemonjuice = 5
	)
	category = CAT_ICE

/datum/crafting_recipe/food/apple_sc
	name = "Apple snowcone"
	result = /obj/item/food/snowcones/apple
	reqs = list(
		/obj/item/reagent_containers/cup/glass/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/applejuice = 5
	)
	category = CAT_ICE

/datum/crafting_recipe/food/grape_sc
	name = "Grape snowcone"
	result = /obj/item/food/snowcones/grape
	reqs = list(
		/obj/item/reagent_containers/cup/glass/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/berryjuice = 5
	)
	category = CAT_ICE

/datum/crafting_recipe/food/orange_sc
	name = "Orange snowcone"
	result = /obj/item/food/snowcones/orange
	reqs = list(
		/obj/item/reagent_containers/cup/glass/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/orangejuice = 5
	)
	category = CAT_ICE

/datum/crafting_recipe/food/blue_sc
	name = "Bluecherry snowcone"
	result = /obj/item/food/snowcones/blue
	reqs = list(
		/obj/item/reagent_containers/cup/glass/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/bluecherryjelly= 5
	)
	category = CAT_ICE

/datum/crafting_recipe/food/red_sc
	name = "Cherry snowcone"
	result = /obj/item/food/snowcones/red
	reqs = list(
		/obj/item/reagent_containers/cup/glass/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/cherryjelly= 5
	)
	category = CAT_ICE

/datum/crafting_recipe/food/berry_sc
	name = "Berry snowcone"
	result = /obj/item/food/snowcones/berry
	reqs = list(
		/obj/item/reagent_containers/cup/glass/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/berryjuice = 5
	)
	category = CAT_ICE

/datum/crafting_recipe/food/fruitsalad_sc
	name = "Fruit Salad snowcone"
	result = /obj/item/food/snowcones/fruitsalad
	reqs = list(
		/obj/item/reagent_containers/cup/glass/sillycup = 1,
		/datum/reagent/water  = 5,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/orangejuice = 5,
		/datum/reagent/consumable/limejuice = 5,
		/datum/reagent/consumable/lemonjuice = 5
	)
	category = CAT_ICE

/datum/crafting_recipe/food/mime_sc
	name = "Mime snowcone"
	result = /obj/item/food/snowcones/mime
	reqs = list(
		/obj/item/reagent_containers/cup/glass/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/nothing = 5
	)
	category = CAT_ICE

/datum/crafting_recipe/food/clown_sc
	name = "Clown snowcone"
	result = /obj/item/food/snowcones/clown
	reqs = list(
		/obj/item/reagent_containers/cup/glass/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/laughter = 5
	)
	category = CAT_ICE

/datum/crafting_recipe/food/soda_sc
	name = "Space Cola snowcone"
	result = /obj/item/food/snowcones/soda
	reqs = list(
		/obj/item/reagent_containers/cup/glass/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/space_cola = 5
	)
	category = CAT_ICE

/datum/crafting_recipe/food/spacemountainwind_sc
	name = "Space Mountain Wind snowcone"
	result = /obj/item/food/snowcones/spacemountainwind
	reqs = list(
		/obj/item/reagent_containers/cup/glass/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/spacemountainwind = 5
	)
	category = CAT_ICE

/datum/crafting_recipe/food/pwrgame_sc
	name = "Pwrgame snowcone"
	result = /obj/item/food/snowcones/pwrgame
	reqs = list(
		/obj/item/reagent_containers/cup/glass/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/pwr_game = 15
	)
	category = CAT_ICE

/datum/crafting_recipe/food/honey_sc
	name = "Honey snowcone"
	result = /obj/item/food/snowcones/honey
	reqs = list(
		/obj/item/reagent_containers/cup/glass/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/honey = 5
	)
	category = CAT_ICE

/datum/crafting_recipe/food/rainbow_sc
	name = "Rainbow snowcone"
	result = /obj/item/food/snowcones/rainbow
	reqs = list(
		/obj/item/reagent_containers/cup/glass/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/colorful_reagent = 1 //Harder to make
	)
	category = CAT_ICE
