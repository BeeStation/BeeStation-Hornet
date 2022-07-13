
// Various traits affecting the product.
/datum/plant_gene/trait
	var/rate = 0.05
	var/examine_line = ""
	var/trait_id // must be set and equal for any two traits of the same type
	var/on_grow_chance // used in on_grow proc
	plant_gene_flags = NONE

/datum/plant_gene/proc/Initialize(mapload)
	if(plusdesc)
		desc += "<br />[plusdesc]"
	if(research_needed > 1)
		desc += "<br />Requirement: [research_needed] researches"

/datum/plant_gene/trait/Copy()
	var/datum/plant_gene/trait/G = ..()
	G.rate = rate
	G.examine_line = examine_line
	G.trait_id = trait_id
	G.on_grow_chance = on_grow_chance
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
/*
	 <A type> - They always happen before B type
		[on_squash]
		[on_aftersquash]

	 <B type> - They always happen after A type
		[on_slip]
		[on_attack]
		[on_throw_impact]

	 <C type> - Other types than A, B
		[on_attackby]
		[on_consume]
		[on_grow]
		[on_new_plant]
		[on_new_seed]
		[on_removal]
*/

// A types
/datum/plant_gene/trait/proc/on_squash(obj/item/reagent_containers/food/snacks/grown/G, atom/target, p_method)
	return FALSE // return does nothing

/datum/plant_gene/trait/proc/on_aftersquash(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	return FALSE // return does nothing

// B types
/datum/plant_gene/trait/proc/on_slip(obj/item/reagent_containers/food/snacks/grown/G, mob/living/carbon/target, p_method)
	return FALSE // return TRUE: qdel(plant)

/datum/plant_gene/trait/proc/on_attack(obj/item/reagent_containers/food/snacks/grown/G, obj/item/I, mob/user, p_method)
	return FALSE // return TRUE: qdel(plant)

/datum/plant_gene/trait/proc/on_throw_impact(obj/item/reagent_containers/food/snacks/grown/G, atom/target, p_method)
	return FALSE // return TRUE: qdel(plant)

// C types
/datum/plant_gene/trait/proc/on_attackby(obj/item/reagent_containers/food/snacks/grown/G, obj/item/I, mob/user)
	return FALSE // return TRUE: qdel(plant)

/datum/plant_gene/trait/proc/on_consume(obj/item/reagent_containers/food/snacks/grown/G, mob/living/carbon/target, p_method)
	return FALSE // return TRUE: qdel(plant)

/datum/plant_gene/trait/proc/on_grow(obj/machinery/hydroponics/H)
	return FALSE // return does nothing

// other 3 procs at the parent type.

// This is needed after `on_squash()`
/datum/plant_gene/trait/proc/qdel_after_squash(obj/item/reagent_containers/food/snacks/grown/G)
	if(G.seed.get_gene(/datum/plant_gene/trait/squash))
		var/obj/item/seeds/S = G.seed
		S.genes -= src
		if(plant_gene_flags & PLANT_GENE_QDEL_TARGET)
			qdel(src)
	return FALSE



/datum/plant_gene/trait/desc
	name = "innate trait"
	desc = "you shouldn't see this"
	research_needed = -1
	plant_gene_flags = NONE
	// This is a dummy trait for some special plants (grass, fairygrass, bamboo, holymelon, etc...)
	// This does nothing, but it is helpful to explain how special a plant is.




















