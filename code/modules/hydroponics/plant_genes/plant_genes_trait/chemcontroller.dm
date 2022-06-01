
// 2x to max reagents volume.
/datum/plant_gene/trait/maxchem
	name = "Densified Chemicals"
	desc = "This doubles the reagent size of a plant."
	plant_gene_flags = PLANT_GENE_COMMON_REMOVABLE | PLANT_GENE_RANDOM_ALLOWED
	trait_id = "maxchem"
	rate = 2
	research_needed = 1

/datum/plant_gene/trait/maxchem/on_new_seed(obj/item/seeds/S)
	if(!S.volume_mod)
		return
	S.volume_mod = initial(S.volume_mod)*rate
	S.gene_update_from_seed(PLANT_GENEPATH_VOLUME)

/datum/plant_gene/trait/maxchem/on_removal(obj/item/seeds/S)
	if(!S.volume_mod)
		return
	S.volume_mod = initial(S.volume_mod)
	S.gene_update_from_seed(PLANT_GENEPATH_VOLUME)

/datum/plant_gene/trait/no_maxchem
	name = "Already at limitation"
	desc = "This plant can't accept Densified Chemicals trait."
	plant_gene_flags = PLANT_GENE_COMMON_REMOVABLE
	trait_id = "maxchem"
	research_needed = -1
	plant_gene_flags = NONE

// Seprated chemicals
/datum/plant_gene/trait/noreact
	name = "Separated Chemicals"
	desc = "Chemicals don't mix until it's used."
	trait_id = "chemmix"
	plant_gene_flags = NONE
	research_needed = -1

/datum/plant_gene/trait/noreact/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	ENABLE_BITFIELD(G.reagents.flags, NO_REACT)

/datum/plant_gene/trait/noreact/on_squashreact(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	DISABLE_BITFIELD(G.reagents.flags, NO_REACT)
	G.reagents.handle_reactions()

// doubles the bite size
/datum/plant_gene/trait/doublebite
	name = "Embiggened Size"
	desc = "Makes the plant difficult to eat, havles the bite size."
	plant_gene_flags = PLANT_GENE_COMMON_REMOVABLE
	trait_id = "eatmethod"
	rate = 2
	research_needed = 0

/datum/plant_gene/trait/doublebite/on_new_seed(obj/item/seeds/S)
	if(!S.volume_mod)
		return
	if(S.bite_type == PLANT_BITE_TYPE_PATCH)
		return
	S.bitesize_mod = initial(S.bitesize_mod)
	if(S.bite_type == PLANT_BITE_TYPE_DYNAM)
		S.bitesize_mod = round(S.bitesize_mod/rate)
	if(S.bite_type == PLANT_BITE_TYPE_CONST)
		S.bitesize_mod = round(S.bitesize_mod*rate)

	S.gene_update_from_seed(PLANT_GENEPATH_BITESI)

/datum/plant_gene/trait/doublebite/on_removal(obj/item/seeds/S)
	if(!S.volume_mod)
		return
	S.bitesize_mod = initial(S.bitesize_mod)
	S.gene_update_from_seed(PLANT_GENEPATH_BITESI)

// changes bite type to patch
/datum/plant_gene/trait/patch
	name = "Pastable Paste"
	desc = "Makes the plant pastable on your skin - works as if the plant is a patch. But it has longer delay than a patch for applying."
	plusdesc = "Needs to combine with Liquid Contents trait."
	plant_gene_flags = PLANT_GENE_COMMON_REMOVABLE | PLANT_GENE_RANDOM_ALLOWED
	trait_id = "eatmethod"
	research_needed = 1
	// If you want to edit eat_delay, check `grown.dm`

/datum/plant_gene/trait/patch/on_new_seed(obj/item/seeds/S)
	if(!S.volume_mod)
		return
	var/datum/plant_gene/trait/squash/SG = S.get_gene(/datum/plant_gene/trait/squash)
	if(SG)
		S.bite_type = PLANT_BITE_TYPE_PATCH
		S.bitesize_mod = 100
	S.gene_update_from_seed(PLANT_GENEPATH_BITESI)
	S.gene_update_from_seed(PLANT_GENEPATH_BITETY)

/datum/plant_gene/trait/patch/on_removal(obj/item/seeds/S)
	if(!S.volume_mod)
		return
	S.bite_type = initial(S.bite_type)
	S.bitesize_mod = initial(S.bitesize_mod)
	S.gene_update_from_seed(PLANT_GENEPATH_BITESI)
	S.gene_update_from_seed(PLANT_GENEPATH_BITETY)

/// Liquid content-----------------
/datum/plant_gene/trait/squash/on_new_seed(obj/item/seeds/S)
	if(!S.volume_mod)
		return
	var/datum/plant_gene/trait/patch/PG = S.get_gene(/datum/plant_gene/trait/patch)
	if(PG)
		S.bite_type = PLANT_BITE_TYPE_PATCH
		S.bitesize_mod = 100
		S.gene_update_from_seed(PLANT_GENEPATH_BITESI)
		S.gene_update_from_seed(PLANT_GENEPATH_BITETY)

/datum/plant_gene/trait/squash/on_removal(obj/item/seeds/S)
	if(!S.volume_mod)
		return
	var/datum/plant_gene/trait/patch/PG = S.get_gene(/datum/plant_gene/trait/patch)
	if(PG)
		S.bite_type = initial(S.bite_type)
		S.bitesize_mod = initial(S.bitesize_mod)
		S.gene_update_from_seed(PLANT_GENEPATH_BITESI)
		S.gene_update_from_seed(PLANT_GENEPATH_BITETY)
///----------------------------------

/datum/plant_gene/trait/patch/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	if(!G.volume)
		return
	var/datum/plant_gene/trait/squash/SG = G.seed.get_gene(/datum/plant_gene/trait/squash)
	if(SG)
		G.apply_type = PATCH
		G.eatverb = "apply"

