/datum/plant_gene/trait/noreact
	// Makes plant reagents not react until squashed.
	name = "Separated Chemicals"

/datum/plant_gene/trait/noreact/on_new(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	..()
	ENABLE_BITFIELD(G.reagents.flags, NO_REACT)

/datum/plant_gene/trait/noreact/on_squashreact(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	DISABLE_BITFIELD(G.reagents.flags, NO_REACT)
	G.reagents.handle_reactions()
