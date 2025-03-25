//Adds a Coconut tree and fruit to the game. Tree functions similar to apples/bananas and allows for the production of coconut milk.

/obj/item/seeds/coconut
	name = "pack of coconut seeds"
	desc = "These seeds grow into a coconut tree."
	icon_state = "seed-coconut"
	species = "coconut"
	plantname = "Coconut Tree"
	product = /obj/item/grown/coconut
	lifespan = 55
	endurance = 35
	yield = 3
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "coconut-grow"
	icon_dead = "coconut-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1) // Remove nutriment, add coconut milk once I've made the code for it

/obj/item/grown/coconut
	seed = /obj/item/seeds/coconut
	name = "coconut"
	desc = "A coconut. It's a hard nut to crack."
	icon_state = "coconut"
	//make coconut milk from juicing or just make coconut juice from it and have coconut milk seperate??
	//juice_typepath = /datum/reagent/consumable/coconutmilk
	//tastes = list("coconut" = 1)
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 2
	throw_range = 4
