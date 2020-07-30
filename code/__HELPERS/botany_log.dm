//Helpers for botany logging
/proc/get_plant_stats(obj/item/seeds/plant, obj/container)
	. = "\n==Plant Stats==\nName: [plant.plantname]\n[container?"[container.fingerprintlast]\n":""]Type: [plant.type]\n==GENES=="
	for(var/datum/plant_gene/gene in plant.genes)
		. += "\nGENE <[gene.get_name()]>"
	. += ")}\n"
