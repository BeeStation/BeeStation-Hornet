// 2x to max reagents volume.
/datum/plant_gene/trait/maxchem
	name = "Densified Chemicals"
	desc = "This doubles the reagent size of a plant."
	plant_gene_flags = PLANT_GENE_COMMON_REMOVABLE | PLANT_GENE_RANDOM_ALLOWED
	trait_id = "maxchem"
	rate = 2
	research_needed = 1

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
		[on_new_seed] changes the seed stat.
		[on_removal] revert the seed stat change.
 */

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
