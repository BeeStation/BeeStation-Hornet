//Helpers for botany logging
/proc/get_plant_stats(obj/item/seeds/plant)
	. = "\n==Plant Stats==\nName: [plant.plantname]\nType: [plant.type]\nFingerprint Last : ([plant.fingerprintslast])\n==GENES=="
	for(var/datum/plant_gene/gene in plant.genes)
		. += "\nGENE <[gene.get_name()]>"
	. += ")}\n"
