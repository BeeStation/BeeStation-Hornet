// doubles the bite size
/datum/plant_gene/trait/doublebite
	name = "Embiggened Size"
	desc = "Makes the plant difficult to eat, havles the bite size."
	plant_gene_flags = PLANT_GENE_COMMON_REMOVABLE
	trait_id = "eatmethod"
	rate = 2
	research_needed = 0

/* <Behavior table>
	 <A type>
		[on_squash] ...
		[on_aftersquash] ...

	 <B type>
		[on_slip] ...
		[on_attack] ...
		[on_throw_impact] ...

	 <C type>
		[on_attackby] ...
		[on_consume] ...
		[on_grow] ...
		[on_new_plant] ... (don't touch this, because seed stats go to harvested plant)
		[on_new_seed] changes the seed stats.
		[on_removal] revert the seed stat changes.
 */

/datum/plant_gene/trait/doublebite/on_new_seed(obj/item/seeds/S)
	if(!S.volume_mod)
		return
	if(S.bite_type == PLANT_BITE_TYPE_PATCH)
		return
	S.bitesize_mod = initial(S.bitesize_mod)
	if(S.bite_type == PLANT_BITE_TYPE_DYNAMIC)
		S.bitesize_mod = round(S.bitesize_mod/rate)
	if(S.bite_type == PLANT_BITE_TYPE_CONSTANT)
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

/* <Behavior table>
	 <A type>
		[on_squash] ...
		[on_aftersquash] ...

	 <B type>
		[on_slip] ...
		[on_attack] ...
		[on_throw_impact] ...

	 <C type>
		[on_attackby] ...
		[on_consume] ...
		[on_grow] ...
		[on_new_plant] changes the plant variable (which seed can't change)
		[on_new_seed] changes the seed stats.
		[on_removal] revert the seed stat changes.

		it has squash trait at the middle.
 */

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

