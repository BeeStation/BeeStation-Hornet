/*Adds a Coconut tree and fruit to the game.
when processed, it lets you choose between coconut flesh or the coconut cup*/
/obj/item/seeds/coconut
	name = "pack of coconut seeds"
	desc = "These seeds grow into a coconut tree."
	icon_state = "seed-coconut"
	species = "coconut"
	plantname = "Coconut Tree"
	product = /obj/item/grown/coconut
	lifespan = 55
	endurance = 35
	production = 7
	yield = 3
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "coconut-grow"
	icon_dead = "coconut-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/consumable/coconutmilk = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.2)

/obj/item/grown/coconut
	seed = /obj/item/seeds/coconut
	name = "coconut"
	desc = "A coconut. It's a hard nut to crack."
	icon_state = "coconut"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 2
	throw_range = 4

// Use a knife/sharp object to process the coconut
/obj/item/grown/coconut/attackby(obj/item/W, mob/user, params)
	if(!W.is_sharp())
		return ..()
	to_chat(user, span_notice("You use [W] to process the flesh from the coconut"))

	// Creates 5 coconut flesh when processed
	for(var/i = 1 to 5)
		var/obj/item/food/coconutflesh/flesh = new /obj/item/food/coconutflesh(src.loc)
		flesh.pixel_x = rand(-5, 5) // Randomises the positioning of the flesh so it isn't all lumped on top of each other
		flesh.pixel_y = rand(-5, 5)

	// Creates the coconut cup alongside the coconut flesh
	var/obj/item/reagent_containers/cup/coconutcup/cup = new /obj/item/reagent_containers/cup/coconutcup(src.loc)
	// Transfers the reagents from the plant to liquid form inside the cup
	if(reagents && reagents.total_volume > 0)
		reagents.trans_to(cup.reagents, reagents.total_volume)
	qdel(src)
	return ..()
