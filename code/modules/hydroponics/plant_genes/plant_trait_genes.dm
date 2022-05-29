
// Various traits affecting the product.
/datum/plant_gene/trait
	var/rate = 0.05
	var/examine_line = ""
	var/randomness_flags = NONE  //used to check random resistrction or aviliability
	var/trait_id // must be set and equal for any two traits of the same type
	var/on_grow_chance // used in on_grow proc

/datum/plant_gene/proc/Initialize(mapload)
	if(plusdesc)
		desc += "<br />[plusdesc]"
	if(research_needed > 1)
		desc += "<br />Requirement: [research_needed] researches"

/datum/plant_gene/trait/Copy()
	var/datum/plant_gene/trait/G = ..()
	G.rate = rate
	return G

/datum/plant_gene/trait/can_add(obj/item/seeds/S)
	if(!..())
		return FALSE

	for(var/datum/plant_gene/trait/R in S.genes)
		if(trait_id && R.trait_id == trait_id)
			return FALSE
		if(type == R.type)
			return FALSE
	return TRUE


//plant behaviours
/datum/plant_gene/trait/proc/on_consume(obj/item/reagent_containers/food/snacks/grown/G, mob/living/carbon/target)
	return

/datum/plant_gene/trait/proc/on_slip(obj/item/reagent_containers/food/snacks/grown/G, mob/living/carbon/target)
	return

/datum/plant_gene/trait/proc/on_squash(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	return

/datum/plant_gene/trait/proc/on_squashreact(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	return

/datum/plant_gene/trait/proc/on_attack(obj/item/reagent_containers/food/snacks/grown/G, obj/item/I, mob/user)
	return

/datum/plant_gene/trait/proc/on_attackby(obj/item/reagent_containers/food/snacks/grown/G, obj/item/I, mob/user)
	return

/datum/plant_gene/trait/proc/on_throw_impact(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	return


///This proc triggers when the tray processes and a roll is sucessful, the success chance scales with production.
/datum/plant_gene/trait/proc/on_grow(obj/machinery/hydroponics/H)
	return


/datum/plant_gene/trait/desc
	name = "innate trait"
	desc = "you shouldn't see this"
	research_needed = -1
	// This is a dummy trait for some special plants (grass, fairygrass, bamboo, holymelon, etc...)
	// This does nothing, but it is helpful to explain how special a plant is.




















