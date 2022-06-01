/datum/plant_gene/trait/squash
	// Allows the plant to be squashed when thrown or slipped on, leaving a colored mess and trash type item behind.
	// Also splashes everything in target turf with reagents and applies other trait effects (teleporting, etc) to the target by on_squash.
	// For code, see grown.dm
	name = "Liquid Contents"
	desc = "This makes your plants very fragil from throwing."
	plant_gene_flags = PLANT_GENE_COMMON_REMOVABLE | PLANT_GENE_RANDOM_ALLOWED
	examine_line = "<span class='info'>It has a lot of liquid contents inside.</span>"
	research_needed = 2

/datum/plant_gene/trait/squash/on_slip(obj/item/reagent_containers/food/snacks/grown/G, mob/living/carbon/C)
	// Squash the plant on slip.
	G.squash(C)

/datum/plant_gene/trait/squash/on_attack(obj/item/reagent_containers/food/snacks/grown/G, mob/living/carbon/C)
	G.squash(C)
