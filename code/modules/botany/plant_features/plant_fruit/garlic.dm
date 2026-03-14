/*
	Garlic
*/
/datum/plant_feature/fruit/garlic
	species_name = "allium clamare"
	name = "garlic"
	icon_state = "garlic"
	fruit_product = /obj/item/food/grown/garlic
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/garlic = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
