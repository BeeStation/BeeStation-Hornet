/*
	Kudzu
*/
/datum/plant_feature/fruit/kudzu
	species_name = "pueraria virallis"
	name = "kudzu pod"
	icon_state = "pod"
	icon_uneven = TRUE
	colour_override = "#7d9e48"
	fruit_product = /obj/item/food/grown/kudzupod
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/medicine/charcoal = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	can_copy = FALSE
	can_remove = FALSE
