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

    // Get the turf where the user is located
    var/turf/location = get_turf(user)

    // Defaults to creating 1 coconut flesh when processed
    var/part_amount = 1
    if(seed && seed.potency)
        part_amount = floor(seed.potency / 20 + 1) // Min 1, Max 6 at 100 potency

    var/datum/reagents/revised_regredients = new /datum/reagents // Reagents for coconut flesh
    reagents.copy_to(revised_regredients, reagents.total_volume)

    if(reagents && reagents.total_volume > 0)
        for(var/datum/reagent/reg in revised_regredients.reagent_list)
            if(istype(reg, /datum/reagent/consumable/coconutmilk)) // Remove coconut milk
                revised_regredients.add_reagent(/datum/reagent/consumable/nutriment/vitamin, reg.volume / 4)
                revised_regredients.add_reagent(/datum/reagent/consumable/nutriment, reg.volume / 2)
                revised_regredients.del_reagent(/datum/reagent/consumable/coconutmilk)

    for(var/i = 1 to part_amount)
        var/obj/item/food/coconutflesh/flesh = new /obj/item/food/coconutflesh(location)
        if(reagents && reagents.total_volume > 0) // If coconut has no chems, flesh gets default ones
            flesh.reagents.clear_reagents()
            if(part_amount == 6) // So 100 potency isn't a punishment
                revised_regredients.copy_to(flesh.reagents, reagents.total_volume / 5)
            else
                revised_regredients.copy_to(flesh.reagents, reagents.total_volume / part_amount)
        flesh.pixel_x = rand(-5, 5) // Randomize the positioning of the flesh
        flesh.pixel_y = rand(-5, 5)

    // Creates the coconut cup alongside the coconut flesh
    var/obj/item/reagent_containers/cup/coconutcup/cup = new /obj/item/reagent_containers/cup/coconutcup(location)

    // Scale the volume of the coconut cup based on the plant's potency
    if(seed && seed.potency)
        cup.volume = max(10, round(seed.potency)) // Scale volume, minimum of 10 - max of 100
        if(seed.get_gene(/datum/plant_gene/trait/maxchem)) // If plant has densified chemicals trait
            cup.volume = max(20, round(seed.potency) * 2) // Scale volume, minimum of 20 - max of 200
        else
            cup.volume = max(10, round(seed.potency)) // Scale volume, minimum of 10 - max of 100
    else
        cup.volume = 50 // Default volume if potency is unavailable

    // Transfers the reagents from the plant to liquid form inside the cup
    if(reagents && reagents.total_volume > 0)
        reagents.trans_to(cup.reagents, reagents.total_volume)

    // Delete the coconut after processing
    qdel(src)
    return ..()
