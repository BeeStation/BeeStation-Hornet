// Cocoa Pod
/obj/item/food/grown/cocoapod
	seed = /obj/item/plant_seeds/preset/cocoa
	name = "cocoa pod"
	desc = "Fattening... Mmmmm... Chocolate."
	icon_state = "cocoapod"
	bite_consumption_mod = 2
	foodtypes = FRUIT
	tastes = list("cocoa" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/creme_de_cacao

// Vanilla Pod
/obj/item/food/grown/vanillapod
	name = "vanilla pod"
	desc = "Fattening... Mmmmm... Vanilla."
	icon_state = "vanillapod"
	bite_consumption_mod = 2
	foodtypes = FRUIT
	tastes = list("vanilla" = 1)
	distill_reagent = /datum/reagent/consumable/vanilla //Takes longer, but you can get even more vanilla from it.
	discovery_points = 300

//Bungo
/obj/item/food/grown/bungofruit
	name = "bungo fruit"
	desc = "A strange fruit, tough leathery skin protects its juicy flesh and large poisonous seed."
	icon_state = "bungo"
	bite_consumption_mod = 2
	trash_type = /obj/item/food/grown/bungopit
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/bungojuice
	tastes = list("bungo" = 2, "tropical fruitiness" = 1)
	distill_reagent = null
	discovery_points = 300

/obj/item/food/grown/bungopit
	name = "bungo pit"
	icon_state = "bungopit"
	bite_consumption_mod = 5
	desc = "A large seed, it is said to be potent enough to be able to stop a mans heart."
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 7
	foodtypes = TOXIC
	tastes = list("acrid bitterness" = 1)
