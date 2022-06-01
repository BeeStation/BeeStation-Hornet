// ----------------------------------------------------
// Basic structure of plant genes
/datum/plant_gene
	var/name
	var/plant_gene_flags = NONE
	var/desc = ""
	var/plusdesc = 0
	var/research_needed = 1
	// -1: not researchable
	// 0: roundstarting
	// more than 1: need to research from various plants

/datum/plant_gene/proc/get_name() // Used for manipulator display
	var/formatted_name
	if(!(plant_gene_flags & PLANT_GENE_REAGENT_ADJUSTABLE) && !(plant_gene_flags & PLANT_GENE_COMMON_REMOVABLE))
		formatted_name = "Stubborn: "
	else if(!plant_gene_flags & PLANT_GENE_REAGENT_ADJUSTABLE)
		formatted_name = "Flexible: "
	else if(!plant_gene_flags & PLANT_GENE_COMMON_REMOVABLE)
		formatted_name = "Essential: "
	formatted_name += name
	return formatted_name

/datum/plant_gene/proc/can_add(obj/item/seeds/S)
	return !istype(S, /obj/item/seeds/sample) // Samples can't accept new genes

/datum/plant_gene/proc/Copy()
	var/datum/plant_gene/G = new type
	G.name = name
	G.plant_gene_flags = plant_gene_flags
	G.desc = desc
	G.plusdesc = plusdesc
	G.research_needed = research_needed
	return G

// changes a plant upon Initialize()
/datum/plant_gene/proc/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	return

// changes a seed stats upon Initialize() or Gene modding
/datum/plant_gene/proc/on_new_seed(obj/item/seeds/S)
	return

// used to revert 'changed seed stats' upon Gene modding
/datum/plant_gene/proc/on_removal(obj/item/seeds/S)
	return

/datum/plant_gene/proc/get_plant_gene_flags()
	return plant_gene_flags

/datum/plant_gene/Destroy()
	if(!plant_gene_flags & PLANT_GENE_QDEL_TARGET)
		CRASH("[src] has been qdel'ed, but it shouldn't. Botany system will have runtime issue from now.")
	return ..()

// ----------------------------------------------------
// --------------- Plant 'core genes' -----------------
// ----------------------------------------------------
/datum/plant_gene/core
	var/value
	plant_gene_flags = PLANT_GENE_QDEL_TARGET
	research_needed = -1

/datum/plant_gene/core/get_name()
	return "[name] [value]"

/datum/plant_gene/core/proc/apply_stat(obj/item/seeds/S)
	return

/datum/plant_gene/core/proc/update_from_seed(obj/item/seeds/S)
	return

/datum/plant_gene/core/proc/update_value(newval)
	value = newval
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

/datum/plant_gene/core/update_from_seed(obj/item/seeds/S)
	value = S.lifespan

//Endurance
/datum/plant_gene/core/endurance
	name = "Endurance"
	value = 15

/datum/plant_gene/core/endurance/apply_stat(obj/item/seeds/S)
	S.endurance = value

/datum/plant_gene/core/endurance/update_from_seed(obj/item/seeds/S)
	value = S.endurance

//Maturation speed
/datum/plant_gene/core/maturation
	name = "Maturation Speed"
	value = 6

/datum/plant_gene/core/maturation/apply_stat(obj/item/seeds/S)
	S.maturation = value

/datum/plant_gene/core/maturation/update_from_seed(obj/item/seeds/S)
	value = S.maturation

//Production speed
/datum/plant_gene/core/production
	name = "Production Speed"
	value = 6

/datum/plant_gene/core/production/apply_stat(obj/item/seeds/S)
	S.production = value

/datum/plant_gene/core/production/update_from_seed(obj/item/seeds/S)
	value = S.production

//Yield
/datum/plant_gene/core/yield
	name = "Yield"
	value = 3

/datum/plant_gene/core/yield/apply_stat(obj/item/seeds/S)
	S.yield = value

/datum/plant_gene/core/yield/update_from_seed(obj/item/seeds/S)
	value = S.yield

//Potency
/datum/plant_gene/core/potency
	name = "Potency"
	value = 10

/datum/plant_gene/core/potency/apply_stat(obj/item/seeds/S)
	S.potency = value

/datum/plant_gene/core/potency/update_from_seed(obj/item/seeds/S)
	value = S.potency
//Weed Rate
/datum/plant_gene/core/weed_rate
	name = "Weed Growth Rate"
	value = 1

/datum/plant_gene/core/weed_rate/apply_stat(obj/item/seeds/S)
	S.weed_rate = value

/datum/plant_gene/core/weed_rate/update_from_seed(obj/item/seeds/S)
	value = S.weed_rate
//Weed chance
/datum/plant_gene/core/weed_chance
	name = "Weed Vulnerability"
	value = 5

/datum/plant_gene/core/weed_chance/apply_stat(obj/item/seeds/S)
	S.weed_chance = value

/datum/plant_gene/core/weed_chance/update_from_seed(obj/item/seeds/S)
	value = S.weed_chance
// --------------------------------------------------------------------------------
// ------------------------PLANT stats, not seed stats-----------------------------
//Plant size
/datum/plant_gene/core/volume_mod
	name = "Plant Size"
	value = 50

/datum/plant_gene/core/volume_mod/apply_stat(obj/item/seeds/S)
	S.volume_mod = value

/datum/plant_gene/core/volume_mod/update_from_seed(obj/item/seeds/S)
	value = S.volume_mod

/datum/plant_gene/core/volume_mod/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	if(istype(G, /obj/item/reagent_containers/food/snacks/grown))
		G.volume = value

//Bite size - how much do a person eat
/datum/plant_gene/core/bitesize_mod
	name = "Bite size"
	value = 10

/datum/plant_gene/core/bitesize_mod/apply_stat(obj/item/seeds/S)
	S.bitesize_mod = value

/datum/plant_gene/core/bitesize_mod/update_from_seed(obj/item/seeds/S)
	value = S.bitesize_mod

/datum/plant_gene/core/bitesize_mod/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	if(istype(G, /obj/item/reagent_containers/food/snacks/grown))
		G.bitesize_mod = value

//Bite type - a method to eat //i.e. ratio(5% from 100u) or constant(5u from 100u)
/datum/plant_gene/core/bite_type
	name = "Bite type"
	value = PLANT_BITE_TYPE_DYNAM

/datum/plant_gene/core/bite_type/apply_stat(obj/item/seeds/S)
	S.bite_type = value

/datum/plant_gene/core/bite_type/update_from_seed(obj/item/seeds/S)
	value = S.bite_type

/datum/plant_gene/core/bite_type/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	if(istype(G, /obj/item/reagent_containers/food/snacks/grown))
		G.bite_type = value

//Wine Power
/datum/plant_gene/core/wine_power
	name = "Booze Power"
	value = 10

/datum/plant_gene/core/wine_power/apply_stat(obj/item/seeds/S)
	S.wine_power = value

/datum/plant_gene/core/wine_power/update_from_seed(obj/item/seeds/S)
	value = S.wine_power

/datum/plant_gene/core/wine_power/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	if(istype(G, /obj/item/reagent_containers/food/snacks/grown))
		G.wine_power = value

//Fermentation reagent
/datum/plant_gene/core/distill_reagent
	name = "Fermentation Result"
	value = "Fruit Wine"

/datum/plant_gene/core/distill_reagent/apply_stat(obj/item/seeds/S)
	S.distill_reagent = value

/datum/plant_gene/core/distill_reagent/update_from_seed(obj/item/seeds/S)
	value = S.distill_reagent

/datum/plant_gene/core/distill_reagent/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	if(istype(G, /obj/item/reagent_containers/food/snacks/grown))
		G.distill_reagent = value


//Credit worthy - cargo value
/datum/plant_gene/core/rarity
	name = "Rarity"
	value = 50

/datum/plant_gene/core/rarity/apply_stat(obj/item/seeds/S)
	S.rarity = value

/datum/plant_gene/core/rarity/update_from_seed(obj/item/seeds/S)
	value = S.rarity

/datum/plant_gene/core/rarity/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	if(istype(G, /obj/item/reagent_containers/food/snacks/grown))
		G.rarity = value
