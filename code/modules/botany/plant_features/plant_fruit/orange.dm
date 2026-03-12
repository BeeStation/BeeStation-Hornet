/*
	Orange
*/
/datum/plant_feature/fruit/orange
	species_name = "citrum solis"
	name = "orange"
	icon_state = "orange"
	icon_uneven = TRUE
	fruit_product = /obj/item/food/grown/citrus/orange
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/orange/threedee = 10)

/*
	Extradimensional Orange
*/
/datum/plant_feature/fruit/orange/threedee
	species_name = "citrum veritas"
	name = "extradimensional orange"
	icon_state = "orange_3D"
	genetic_budget = 4
	fruit_product = /obj/item/food/grown/citrus/orange_3d
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin,
	/datum/plant_trait/fruit/biolight/orange)
	total_volume = PLANT_FRUIT_VOLUME_MEDIUM
	mutations = list(/datum/plant_feature/fruit/orange)
