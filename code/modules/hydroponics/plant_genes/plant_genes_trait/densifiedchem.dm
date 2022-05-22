/datum/plant_gene/trait/maxchem
	// 2x to max reagents volume.
	name = "Densified Chemicals"
	rate = 2

/datum/plant_gene/trait/maxchem/on_new(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	..()
	G.reagents.maximum_volume *= rate
