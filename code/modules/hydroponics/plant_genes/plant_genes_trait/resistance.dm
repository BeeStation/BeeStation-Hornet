/datum/plant_gene/trait/fire_resistance // Lavaland
	name = "Fire Resistance"
	desc = "This makes your plant fire proof."
	plant_gene_flags = PLANT_GENE_COMMON_REMOVABLE | PLANT_GENE_RANDOM_ALLOWED
	research_needed = 3

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
		[on_new_plant] changes the plant stat.
		[on_new_seed] changes the seed stat.
		[on_removal] revert the seed stat.
 */

/datum/plant_gene/trait/fire_resistance/on_new_seed(obj/item/seeds/S)
	if(!(S.resistance_flags & FIRE_PROOF))
		S.resistance_flags |= FIRE_PROOF

/datum/plant_gene/trait/fire_resistance/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	if(!(G.resistance_flags & FIRE_PROOF))
		G.resistance_flags |= FIRE_PROOF

/datum/plant_gene/trait/fire_resistance/on_removal(obj/item/seeds/S)
	if(initial(S.resistance_flags) & FIRE_PROOF)
		return
	S.resistance_flags &= ~FIRE_PROOF

/datum/plant_gene/trait/acid_resistance
	name = "Acid Resistance"
	desc = "This makes your plant acid proof."
	plant_gene_flags = PLANT_GENE_COMMON_REMOVABLE | PLANT_GENE_RANDOM_ALLOWED
	research_needed = 2

/datum/plant_gene/trait/acid_resistance/on_new_seed(obj/item/seeds/S)
	if(!(S.resistance_flags & ACID_PROOF))
		S.resistance_flags |= ACID_PROOF

/datum/plant_gene/trait/acid_resistance/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	if(!(G.resistance_flags & ACID_PROOF))
		G.resistance_flags |= ACID_PROOF

/datum/plant_gene/trait/acid_resistance/on_removal(obj/item/seeds/S)
	if(initial(S.resistance_flags) & ACID_PROOF)
		return
	S.resistance_flags &= ~ACID_PROOF
