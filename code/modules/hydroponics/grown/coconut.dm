/*Adds a Coconut tree and fruit to the game.
when processed, it lets you choose between coconut flesh or the coconut cup*/
/obj/item/seeds/coconut
	name = "pack of coconut seeds"
	desc = "These seeds grow into a coconut tree."
	icon_state = "seed-coconut"
	species = "coconut"
	plantname = "Coconut Tree"
	product = /obj/item/food/grown/coconut
	lifespan = 55
	endurance = 35
	production = 7
	yield = 3
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "coconut-grow"
	icon_dead = "coconut-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/water = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.2)

/obj/item/food/grown/coconut
	seed = /obj/item/seeds/coconut
	name = "coconut"
	desc = "A coconut. It's a hard nut to crack."
	icon_state = "coconut"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	foodtypes = FRUIT
	throw_speed = 2
	throw_range = 4

/obj/item/food/grown/coconut/make_edible()
	return //no eat

/obj/item/food/grown/coconut/make_dryable()
	return //No drying

/*obj/item/food/grown/coconut/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/coconutflesh, 5, 20)
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/reagent_containers/cup/coconutcup, 1)
*/

/obj/item/food/grown/coconut/attackby(obj/item/W, mob/user, params)
    if(W.is_sharp())
        to_chat(user, span_notice("You use [W] to process the flesh from the coconut"))
        var/obj/item/reagent_containers/cup/coconutcup/cup = new /obj/item/reagent_containers/cup/coconutcup(user.loc)

        if(reagents && reagents.total_volume > 0)
            reagents.trans_to(cup.reagents, reagents.total_volume)
            to_chat(user, span_notice("Reagents transferred"))
        else
            to_chat(user, span_notice("No reagents to transfer"))
        qdel(src)
    else
        return ..()
