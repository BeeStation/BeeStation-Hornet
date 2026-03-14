/datum/export/seed
	cost = 50 // Gets multiplied by potency
	unit_name = "new plant species sample"
	export_types = list(
		/obj/item/plant_seeds = TRUE,
	)
	var/needs_discovery = FALSE // Only for undiscovered species
	var/static/list/discoveredPlants = list()

/datum/export/seed/get_cost(obj/O)
	var/obj/item/plant_seeds/S = O
	if(!needs_discovery && (S.species_id in discoveredPlants))
		return 0
	if(needs_discovery && !(S.species_id in discoveredPlants))
		return 0
	return ..() * S.seeds

/datum/export/seed/sell_object(obj/O, datum/export_report/report, dry_run, allowed_categories)
	. = ..()
	if(. && !dry_run)
		var/obj/item/plant_seeds/S = O
		discoveredPlants[S.species_id] = TRUE
