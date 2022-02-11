/obj/item/reagent_containers/food/snacks/monkeycube/chicken
	name = "chicken cube"
	desc = "A new Nanotrasen classic, the chicken cube. Tastes like everything!"
	bitesize = 20
	list_reagents = list(/datum/reagent/consumable/eggyolk = 30, /datum/reagent/medicine/strange_reagent = 1)
	tastes = list("chicken" = 1, "the country" = 1, "chicken bouillon" = 1)
	spawned_mob = /mob/living/simple_animal/chicken

/obj/item/reagent_containers/food/snacks/monkeycube/bee
	name = "bee cube"
	desc = "We were sure it was a good idea. Just add water."
	bitesize = 20
	list_reagents = list(/datum/reagent/consumable/honey = 10, /datum/reagent/toxin = 5, /datum/reagent/medicine/strange_reagent = 1)
	tastes = list("buzzing" = 1, "honey" = 1, "regret" = 1)
	spawned_mob = /mob/living/simple_animal/hostile/poison/bees
