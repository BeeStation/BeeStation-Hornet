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

	// Store the original reagents for readability
	var/datum/reagents/original_reagent_holder = reagents

	var/datum/reagents/reagents_template
	if(original_reagent_holder && original_reagent_holder.total_volume > 0)
		reagents_template = new /datum/reagents // Reagents for coconut flesh
		original_reagent_holder.copy_to(reagents_template, original_reagent_holder.total_volume)
		if(original_reagent_holder.has_reagent(/datum/reagent/consumable/coconutmilk)) // Remove coconut milk
			var/datum/reagent/reg = original_reagent_holder.get_reagent(/datum/reagent/consumable/coconutmilk)
			reagents_template.del_reagent(/datum/reagent/consumable/coconutmilk)
			reagents_template.add_reagent(/datum/reagent/consumable/nutriment/vitamin, reg.volume / 4)
			reagents_template.add_reagent(/datum/reagent/consumable/nutriment, reg.volume / 2)

	// Defaults to creating 1 coconut flesh when processed
	var/part_amount = 1
	var/div_mod = 1
	if(seed && seed.potency)
		part_amount = floor(seed.potency / 20 + 1) // Min 1, Max 6 at 100 potency
		div_mod = clamp(part_amount, 1, 5) // So 100 potency isn't a punishment

	for(var/i = 1 to part_amount)
		var/obj/item/food/coconutflesh/flesh = new /obj/item/food/coconutflesh/empty(location)
		if(original_reagent_holder && original_reagent_holder.total_volume > 0)
			reagents_template.copy_to(flesh.reagents, original_reagent_holder.total_volume / div_mod)
		flesh.pixel_x = rand(-5, 5) // Randomize the positioning of the flesh
		flesh.pixel_y = rand(-5, 5)

	// Creates the coconut cup alongside the coconut flesh
	var/obj/item/reagent_containers/cup/coconutcup/cup = new /obj/item/reagent_containers/cup/coconutcup(location)

	// Scale the volume of the coconut cup based on the plant's potency
	if(seed && seed.potency)
		var/modifier = 1
		if(seed.get_gene(/datum/plant_gene/trait/maxchem))
			modifier = 2
		cup.volume = max(10, seed.potency) * modifier // Without trait 10-100, with it 20-200
		cup.reagents.maximum_volume = max(10, seed.potency) * modifier // Because this doesnt auto update for some reson

	// Transfers the reagents from the plant to liquid form inside the cup
	if(original_reagent_holder && original_reagent_holder.total_volume > 0)
		original_reagent_holder.trans_to(cup.reagents, original_reagent_holder.total_volume)

	// Delete the coconut after processing
	. = ..()
	qdel(reagents_template)
	qdel(src)

