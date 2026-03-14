/*
	Onion
*/
/datum/plant_feature/fruit/onion
	species_name = "cepa tabulatum"
	name = "onion"
	icon_state = "garlic"
	fruit_product = /obj/item/food/grown/onion
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/onion/red)

/*
	Red Onion
*/
/datum/plant_feature/fruit/onion/red
	species_name = "cepa clamare"
	name = "red onion"
	icon_state = "garlic"
	colour_override = "#ff004c"
	fruit_product = /obj/item/food/grown/onion/red
	fast_reagents = list(/datum/reagent/consumable/tearjuice = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/onion)
