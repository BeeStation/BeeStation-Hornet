/datum/plant_gene/trait/fire_resistance // Lavaland
	name = "Fire Resistance"
	desc = "This makes your plant fire proof."
	randomness_flags = BOTANY_RANDOM_COMMON
	research_needed = 3

/datum/plant_gene/trait/fire_resistance/on_new_seed(obj/item/seeds/S)
	if(!(S.resistance_flags & FIRE_PROOF))
		S.resistance_flags |= FIRE_PROOF

/datum/plant_gene/trait/fire_resistance/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	if(!(G.resistance_flags & FIRE_PROOF))
		G.resistance_flags |= FIRE_PROOF

/datum/plant_gene/trait/fire_resistance/on_removal(obj/item/seeds/S)
	if(S.resistance_flags & FIRE_PROOF)
		S.resistance_flags -= FIRE_PROOF

/datum/plant_gene/trait/acid_resistance
	name = "Acid Resistance"
	desc = "This makes your plant acid proof."
	randomness_flags = BOTANY_RANDOM_COMMON
	research_needed = 2

/datum/plant_gene/trait/acid_resistance/on_new_seed(obj/item/seeds/S)
	if(!(S.resistance_flags & ACID_PROOF))
		S.resistance_flags |= ACID_PROOF

/datum/plant_gene/trait/acid_resistance/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	if(!(G.resistance_flags & ACID_PROOF))
		G.resistance_flags |= ACID_PROOF

/datum/plant_gene/trait/acid_resistance/on_removal(obj/item/seeds/S)
	if(S.resistance_flags & ACID_PROOF)
		S.resistance_flags -= ACID_PROOF
