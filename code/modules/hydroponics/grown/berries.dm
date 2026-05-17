// Berries
/obj/item/food/grown/berries
	seed = /obj/item/plant_seeds/preset/berry
	name = "bunch of berries"
	desc = "Nutritious!"
	icon_state = "berrypile"
	gender = PLURAL
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/berryjuice
	tastes = list("berry" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/gin

// Poison Berries
/obj/item/food/grown/berries/poison
	name = "bunch of poison-berries"
	desc = "Taste so good, you might die!"
	icon_state = "poisonberrypile"
	bite_consumption_mod = 3
	foodtypes = FRUIT | TOXIC
	juice_typepath = /datum/reagent/consumable/poisonberryjuice
	tastes = list("poison-berry" = 1)
	distill_reagent = null
	wine_power = 35
	discovery_points = 300

// Death Berries
/obj/item/food/grown/berries/death
	name = "bunch of death-berries"
	desc = "Taste so good, you will die!"
	icon_state = "deathberrypile"
	bite_consumption_mod = 3
	foodtypes = FRUIT | TOXIC
	juice_typepath = /datum/reagent/consumable/poisonberryjuice
	tastes = list("death-berry" = 1)
	distill_reagent = null
	wine_power = 50
	discovery_points = 300

// Glow Berries
/obj/item/food/grown/berries/glow
	name = "bunch of glow-berries"
	desc = "Nutritious!"
	bite_consumption_mod = 3
	icon_state = "glowberrypile"
	foodtypes = FRUIT
	tastes = list("glow-berry" = 1)
	distill_reagent = null
	wine_power = 60
	discovery_points = 300

// Cherries
/obj/item/food/grown/cherries
	seed = /obj/item/plant_seeds/preset/cherry
	name = "cherries"
	desc = "Great for toppings!"
	icon_state = "cherry"
	gender = PLURAL
	bite_consumption_mod = 2
	foodtypes = FRUIT
	grind_results = list(/datum/reagent/consumable/cherryjelly = 0)
	tastes = list("cherry" = 1)
	wine_power = 30

// Blue Cherries
/obj/item/food/grown/bluecherries
	name = "blue cherries"
	desc = "They're cherries that are blue."
	icon_state = "bluecherry"
	bite_consumption_mod = 2
	foodtypes = FRUIT
	grind_results = list(/datum/reagent/consumable/bluecherryjelly = 0)
	tastes = list("blue cherry" = 1)
	wine_power = 50
	discovery_points = 300

//Cherry Bulbs
/obj/item/food/grown/cherrybulbs
	name = "cherry bulbs"
	desc = "They're like little Space Christmas lights!"
	icon_state = "cherry_bulb"
	bite_consumption_mod = 2
	foodtypes = FRUIT
	grind_results = list(/datum/reagent/consumable/cherryjelly = 0)
	tastes = list("cherry" = 1)
	wine_power = 50
	discovery_points = 300

// Grapes
/obj/item/food/grown/grapes
	seed = /obj/item/plant_seeds/preset/grape
	name = "bunch of grapes"
	desc = "Nutritious!"
	icon_state = "grapes"
	bite_consumption_mod = 2
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/grapejuice
	tastes = list("grape" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/wine

/obj/item/food/grown/grapes/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/no_raisin/healthy)

// Green Grapes
/obj/item/food/grown/grapes/green
	name = "bunch of green grapes"
	icon_state = "greengrapes"
	bite_consumption_mod = 3
	tastes = list("green grape" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/cognac
	discovery_points = 300
