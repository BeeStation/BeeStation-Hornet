/*
	Cactus
	Medium fruit type that grows fast
*/
/datum/plant_feature/fruit/cactus
	species_name = "spinis fructificatio"
	name = "cactus"
	icon_state = "cactus"
	icon_uneven = TRUE
	fruit_product = /obj/item/food/grown/ash_flora/cactus_fruit
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin, /datum/plant_trait/fruit/spikey)
	fast_reagents = list(/datum/reagent/consumable/vitfro = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_MEDIUM
	growth_time = PLANT_FRUIT_GROWTH_FAST
	fruit_size = PLANT_FRUIT_SIZE_MEDIUM
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
