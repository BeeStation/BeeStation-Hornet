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
	production = 7
	yield = 2
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "coconut-grow"
	icon_dead = "coconut-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)

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
/*
commented out as this was the code for processing the coconut when it was edible upon harvest

/obj/item/food/grown/coconut/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/coconutflesh, 4, 20)

*/


/* code used from towercap.dm so that the coconut is not edible upon harvest
I feel this code could be cleaned up, I just don't have the skill or knowledge */
/obj/item/grown/coconut/attackby(obj/item/W, mob/user, params)
	if(W.is_sharp())
		user.show_message(span_notice("You crack open the [src]!"), MSG_VISUAL)
		var/seed_modifier = 0
		if(seed)
			seed_modifier = round(seed.potency / 25)
		var/total_flesh = 4 + seed_modifier
		for(var/i = 1 to total_flesh)
			new /obj/item/food/coconutflesh(user.loc)
		new /obj/item/reagent_containers/cup/coconutcup(user.loc, 50)
		qdel(src)
