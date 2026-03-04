/*
	Chanterelle
*/
/datum/plant_feature/fruit/mushroom/chanterelle
	species_name = "flavo poculum"
	name = "chanterelle"
	icon_state = "chanterelle"
	fruit_product = /obj/item/food/grown/mushroom/chanterelle
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/mushroom/chanterelle/jupiter)

/*
	Jupiter Cup
*/
/datum/plant_feature/fruit/mushroom/chanterelle/jupiter
	species_name = "purpura poculum"
	name = "jupiter cup"
	icon_state = "chanterelle"
	colour_overlay = "chanterelle_colour"
	colour_override = "#ff0000"
	fruit_product = /obj/item/food/grown/mushroom/jupitercup
	fast_reagents = list(/datum/reagent/consumable/liquidelectricity = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/mushroom/chanterelle)
