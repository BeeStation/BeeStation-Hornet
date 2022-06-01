// Apple
/obj/item/seeds/apple
	name = "pack of apple seeds"
	desc = "These seeds grow into apple trees."
	plantname = "Apple Tree"
	species = "apple"
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_state = "seed-apple"
	icon_grow = "apple-grow"
	icon_dead = "apple-dead"
	product = /obj/item/reagent_containers/food/snacks/grown/apple

	lifespan = 55
	endurance = 35
	yield = 5
	volume_mod = 25
	bite_type = PLANT_BITE_TYPE_CONST
	bitesize_mod = 100
	distill_reagent = /datum/reagent/consumable/ethanol/hcider

	mutatelist = list(/obj/item/seeds/apple/gold)
	genes = list(/datum/plant_gene/trait/perennial)
	reagents_innate = list(
		/datum/reagent/consumable/nutriment/vitamin = list(1, 1, NONE)) // No apple meta
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(5, 15),
		/datum/reagent/consumable/nutriment/vitamin = list(2, 6))

/obj/item/reagent_containers/food/snacks/grown/apple
	seed = /obj/item/seeds/apple
	name = "apple"
	desc = "It's a little piece of Eden."
	icon_state = "apple"
	filling_color = "#FF4500"
	foodtype = FRUIT
	juice_results = list(/datum/reagent/consumable/applejuice = 0)
	tastes = list("apple" = 1)

// Gold Apple
/obj/item/seeds/apple/gold
	name = "pack of golden apple seeds"
	desc = "These seeds grow into golden apple trees. Good thing there are no firebirds in space."
	plantname = "Golden Apple Tree"
	species = "goldapple"
	icon_state = "seed-goldapple"
	product = /obj/item/reagent_containers/food/snacks/grown/apple/gold

	maturation = 10
	production = 10
	volume_mod = 30
	distill_reagent = null
	wine_power = 50

	mutatelist = list(/obj/item/seeds/apple)
	reagents_innate = list(
		/datum/reagent/gold = list(5, 5, NONE))
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(3, 9),
		/datum/reagent/consumable/nutriment/vitamin = list(2, 6),
		/datum/reagent/gold = list(15, 30))
	rarity = 40 // Alchemy!

/obj/item/reagent_containers/food/snacks/grown/apple/gold
	seed = /obj/item/seeds/apple/gold
	name = "golden apple"
	desc = "Emblazoned upon the apple is the word 'Kallisti'."
	icon_state = "goldapple"
	filling_color = "#FFD700"
	wine_flavor = "the precursor of the gods' elixir"
	discovery_points = 300
