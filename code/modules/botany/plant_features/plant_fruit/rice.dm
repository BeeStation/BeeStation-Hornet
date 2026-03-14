/*
	Rice
*/
/datum/plant_feature/fruit/rice
	species_name = "alba parva"
	name = "rice"
	icon_state = "corn-2"
	fruit_product = /obj/item/food/grown/rice
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/rice = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_VERY_FAST
