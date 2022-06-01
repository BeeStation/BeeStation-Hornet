/datum/plant_gene/trait/eternalbloom
	name = "Eternal Blooming"
	desc = "Your plant will never be harvestable, but will never die. Always blooming. This is good for gardening purpose."
	plant_gene_flags = PLANT_GENE_COMMON_REMOVABLE
	research_needed = 0 //roundstart research
	on_grow_chance = 100

/datum/plant_gene/trait/eternalbloom/on_grow(obj/machinery/hydroponics/H)
	if(H.plant_health <= 0)
		H.plant_health += 30
	H.weedlevel = 0
	H.pestlevel = 0
	H.dead = 0
	H.dont_warn_me = TRUE // because we don't want to see warning icons
