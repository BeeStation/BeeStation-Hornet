// Apple
/obj/item/food/grown/apple
	seed = /obj/item/plant_seeds/preset/apple
	name = "apple"
	desc = "It's a little piece of Eden."
	icon_state = "apple"
	bite_consumption_mod = 100 // Always eat apples in one bite
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/applejuice
	tastes = list("apple" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/hcider

// Gold Apple
/obj/item/food/grown/apple/gold
	name = "golden apple"
	desc = "Emblazoned upon the apple is the word 'Kallisti'."
	icon_state = "goldapple"
	distill_reagent = null
	wine_power = 50
	discovery_points = 300
