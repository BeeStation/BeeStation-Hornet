
// 2x to max reagents volume.
/datum/plant_gene/trait/maxchem
	name = "Densified Chemicals"
	desc = "This doubles the reagent size of a plant."
	randomness_flags = BOTANY_RANDOM_COMMON
	rate = 2
	research_needed = 1

/datum/plant_gene/trait/maxchem/on_new_seed(obj/item/seeds/S)
	. = ..()
	if(ispath(S.product, obj/item/reagent_containers/food/snacks/grown))
		S.volume_mod *= rate

/datum/plant_gene/trait/maxchem/on_removal(obj/item/seeds/S)
	. = ..()
	if(ispath(S.product, obj/item/reagent_containers/food/snacks/grown))
		S.volume_mod = initial(S.volume_mod)

/datum/plant_gene/trait/maxchem/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	. = ..()
	if(istype(G, obj/item/reagent_containers/food/snacks/grown))
		G.volume *= rate


// 2x to bite size
/datum/plant_gene/trait/doublebite
	name = "Embiggened Size"
	desc = "Makes the plant difficult to eat."
	plusdesc = "If const type: 2x the bite size. If ratio type: halves the ratio."
	randomness_flags = NONE
	rate = 2
	research_needed = 0

/datum/plant_gene/trait/doublebite/on_new_seed(obj/item/seeds/S)
	..()
	if(!istype(S.prod, obj/item/reagent_containers/food/snacks/grown/G))
		return
	if(S.bite_type & PLANT_BITE_TYPE_PATCH)
		return
	if(S.bite_type & PLANT_BITE_TYPE_CONST)
		S.bitesize_mod *= rate
	if(S.bite_type & PLANT_BITE_TYPE_RATIO)
		S.bitesize_mod /= rate

/datum/plant_gene/trait/doublebite/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	..()
	if(S.bite_type & PLANT_BITE_TYPE_PATCH)
		return
	if(S.bite_type & PLANT_BITE_TYPE_CONST)
		G.bitesize_mod *= rate
	if(S.bite_type & PLANT_BITE_TYPE_RATIO)
		G.bitesize_mod /= rate

/datum/plant_gene/trait/doublebite/on_removal(obj/item/seeds/S)
	..()
	if(S.bite_type)
		S.bitesize_mod = initial(S.bitesize_mod)

// changes bite type to patch
/datum/plant_gene/trait/patch
	name = "Pastable Paste"
	desc = "Makes the plant pastable on your skin - works as if the plant is a patch. But it has longer delay than a patch for applying."
	plusdesc = "It's superior gene than Embiggened Size."
	randomness_flags = BOTANY_RANDOM_COMMON
	research_needed = 0
	rate = 5 // apply speed

/datum/plant_gene/trait/patch/on_new_seed(obj/item/seeds/S)
	..()
	S.bite_type = PLANT_BITE_TYPE_PATCH
	S.bitesize_mod = 100

/datum/plant_gene/trait/patch/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	..()
	G.bite_type = PLANT_BITE_TYPE_PATCH
	G.bitesize_mod = 100
	G.apply_type = PATCH
	G.eatverb = "apply"

/datum/plant_gene/trait/patch/on_removal(obj/item/seeds/S)
	..()
	if(S.bite_type == PLANT_BITE_TYPE_PATCH)
		S.bite_type = initial(S.bite_type)
		S.bitesize_mod = initial(S.bitesize_mod)
