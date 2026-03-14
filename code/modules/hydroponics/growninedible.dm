// **********************
// Other harvested materials from plants (that are not food)
// **********************

/obj/item/grown // Grown weapons
	name = "grown_weapon"
	icon = 'icons/obj/hydroponics/harvest.dmi'
	worn_icon = 'icons/mob/clothing/head/hydroponics.dmi'
	resistance_flags = FLAMMABLE
	var/obj/item/plant_seeds/seed = null
	var/discovery_points = 0 //Amount of discovery points given for scanning
	var/max_volume = 100 // There is the same variable in the food/grown.dm - this variable only exists to suppress a runtime error by /datum/plant_gene/trait/maxchem touching max_volume

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/grown)

/obj/item/grown/Initialize(mapload, obj/item/plant_seeds/_new_seed)
	. = ..()
	create_reagents(50)

	pixel_x = base_pixel_x + rand(-5, 5)
	pixel_y = base_pixel_y + rand(-5, 5)

	if(discovery_points)
		AddComponent(/datum/component/discoverable, discovery_points)

	if(!seed || !mapload)
		return
	var/obj/item/plant_seeds/new_seed = _new_seed || seed
	new_seed = new new_seed(src)
	//Traits - This doesn't cover modifications added by body & root traits, sue me
	var/datum/plant_feature/fruit/fruit_feature = locate(/datum/plant_feature/fruit) in new_seed.plant_features
	for(var/datum/plant_trait/trait as anything in fruit_feature?.plant_traits)
		trait.copy(src)
	//Add genes
	if(!SSbotany.gene_cache["[new_seed.species_id]"])
		var/list/plant_genes = list()
		for(var/datum/plant_feature/gene as anything in new_seed.plant_features)
			if(QDELETED(gene))
				continue
			plant_genes += gene?.copy()
		SSbotany.gene_cache[new_seed.species_id] = plant_genes
	AddElement(/datum/element/plant_genes, SSbotany.gene_cache["[new_seed.species_id]"], new_seed.species_id)
	qdel(new_seed)

/obj/item/grown/microwave_act(obj/machinery/microwave/M)
	return

/obj/item/grown/on_grind()
	. = ..()
	var/power = get_fruit_trait_power(src)
	for(var/i in 1 to grind_results.len)
		grind_results[grind_results[i]] = power*25
