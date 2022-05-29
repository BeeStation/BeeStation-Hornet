#define BOTANY_RANDOM_COMMON   (1<<0)
#define BOTANY_RANDOM_UNCOMMON (1<<1)
#define BOTANY_RANDOM_RARE     (1<<2)

/datum/plant_gene
	var/name
	var/mutability_flags = PLANT_GENE_COMMON_REMOVABLE ///These flags tells the genemodder if we want the gene to be extractable, only removable or neither.
	var/desc = ""
	var/plusdesc = 0
	var/research_needed = 1
	// -1: not researchable
	// 0: roundstarting
	// more than 1: need to research from various plants

/datum/plant_gene/proc/get_name() // Used for manipulator display and gene disk name.
	var/formatted_name
	if(!(mutability_flags & PLANT_GENE_COMMON_REMOVABLE))
		formatted_name += "Essential: "
	formatted_name += name
	return formatted_name

/datum/plant_gene/proc/can_add(obj/item/seeds/S)
	return !istype(S, /obj/item/seeds/sample) // Samples can't accept new genes

/datum/plant_gene/proc/Copy()
	var/datum/plant_gene/G = new type
	G.mutability_flags = mutability_flags
	return G

/datum/plant_gene/proc/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	return

/datum/plant_gene/proc/on_new_seed(obj/item/seeds/S) // currently used for fire resist, can prob. be further refactored
	return

/datum/plant_gene/proc/on_removal(obj/item/seeds/S)
	return

// Core plant genes store 5 main variables: lifespan, endurance, production, yield, potency
/datum/plant_gene/core
	var/value

/datum/plant_gene/core/get_name()
	return "[name] [value]"

/datum/plant_gene/core/proc/apply_stat(obj/item/seeds/S)
	return

/datum/plant_gene/core/New(var/i = null)
	..()
	if(!isnull(i))
		value = i

/datum/plant_gene/core/Copy()
	var/datum/plant_gene/core/C = ..()
	C.value = value
	return C

/datum/plant_gene/core/can_add(obj/item/seeds/S)
	if(!..())
		return FALSE
	return S.get_gene(src.type)


// -------------------------------------------------------------------
// ------------------------  seed stats  -----------------------------
//Lifespan
/datum/plant_gene/core/lifespan
	name = "Lifespan"
	value = 25

/datum/plant_gene/core/lifespan/apply_stat(obj/item/seeds/S)
	S.lifespan = value

//Endurance
/datum/plant_gene/core/endurance
	name = "Endurance"
	value = 15

/datum/plant_gene/core/endurance/apply_stat(obj/item/seeds/S)
	S.endurance = value

//Maturation speed
/datum/plant_gene/core/maturation
	name = "Maturation Speed"
	value = 6

/datum/plant_gene/core/maturation/apply_stat(obj/item/seeds/S)
	S.maturation = value

//Production speed
/datum/plant_gene/core/production
	name = "Production Speed"
	value = 6

/datum/plant_gene/core/production/apply_stat(obj/item/seeds/S)
	S.production = value

//Yield
/datum/plant_gene/core/yield
	name = "Yield"
	value = 3

/datum/plant_gene/core/yield/apply_stat(obj/item/seeds/S)
	S.yield = value

//Potency
/datum/plant_gene/core/potency
	name = "Potency"
	value = 10

/datum/plant_gene/core/potency/apply_stat(obj/item/seeds/S)
	S.potency = value

//Weed Rate
/datum/plant_gene/core/weed_rate
	name = "Weed Growth Rate"
	value = 1

/datum/plant_gene/core/weed_rate/apply_stat(obj/item/seeds/S)
	S.weed_rate = value

//Weed chance
/datum/plant_gene/core/weed_chance
	name = "Weed Vulnerability"
	value = 5

/datum/plant_gene/core/weed_chance/apply_stat(obj/item/seeds/S)
	S.weed_chance = value

// --------------------------------------------------------------------------------
// ------------------------PLANT stats, not seed stats-----------------------------
//Bite size - how much do a person eat
/datum/plant_gene/core/bitesize_mod
	name = "Bite size"
	value = 10

/datum/plant_gene/core/bitesize_mod/apply_stat(obj/item/seeds/S)
	S.bitesize_mod = value

/datum/plant_gene/core/bitesize_mod/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	if(istype(G, obj/item/reagent_containers/food/snacks/grown))
		G.bitesize_mod = value

//Bite type - a method to eat //i.e. ratio(5% from 100u) or constant(5u from 100u)
/datum/plant_gene/core/bite_type
	name = "Bite size"
	value = PLANT_BITE_TYPE_CONST

/datum/plant_gene/core/bite_type/apply_stat(obj/item/seeds/S)
	S.bite_type = value

/datum/plant_gene/core/bite_type/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	if(istype(G, obj/item/reagent_containers/food/snacks/grown))
		G.bite_type = value

//Wine Power
/datum/plant_gene/core/wine_power
	name = "Booze Power"
	value = 10

/datum/plant_gene/core/wine_power/apply_stat(obj/item/seeds/S)
	S.wine_power = value

/datum/plant_gene/core/wine_power/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	if(istype(G, obj/item/reagent_containers/food/snacks/grown))
		G.wine_power = value

//Fermentation reagent
/datum/plant_gene/core/distill_reagent
	name = "Fermentation Result"
	value = NULL

/datum/plant_gene/core/distill_reagent/apply_stat(obj/item/seeds/S)
	S.distill_reagent = value

/datum/plant_gene/core/distill_reagent/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	if(istype(G, obj/item/reagent_containers/food/snacks/grown))
		G.distill_reagent = value

//Plant size
/datum/plant_gene/core/volume_mod
	name = "Plant Size"
	value = 50

/datum/plant_gene/core/volume_mod/apply_stat(obj/item/seeds/S)
	S.volume_mod = value

/datum/plant_gene/core/volume_mod/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	if(istype(G, obj/item/reagent_containers/food/snacks/grown))
		G.volume = value

//Credit worthy - cargo value
/datum/plant_gene/core/rarity
	name = "Rarity"
	value = 50

/datum/plant_gene/core/rarity/apply_stat(obj/item/seeds/S)
	S.rarity = value

/datum/plant_gene/core/rarity/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	if(istype(G, obj/item/reagent_containers/food/snacks/grown))
		G.rarity = value
