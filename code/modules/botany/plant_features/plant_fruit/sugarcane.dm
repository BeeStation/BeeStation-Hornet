/*
	Sugarcane
*/
/datum/plant_feature/fruit/sugarcane
	species_name = "dulcis ferula"
	name = "sugarcane"
	icon_state = "sugar"
	fruit_product = /obj/item/food/grown/sugarcane
	total_volume = PLANT_FRUIT_VOLUME_MEDIUM
	growth_time = PLANT_FRUIT_GROWTH_FAST
	fruit_size = PLANT_FRUIT_SIZE_MEDIUM
	fast_reagents = list(/datum/reagent/consumable/sugar = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/bamboo)
	whitelist_features = list(/datum/plant_feature/body/tuber, /datum/plant_feature/roots)

/*
	Bamboo
	Volumeless fruit type that grows fast
*/
/datum/plant_feature/fruit/bamboo
	species_name = "quis fermentum"
	name = "bamboo"
	icon_state = "bamboo"
	fruit_product = /obj/item/grown/log/bamboo
	total_volume = 0
	growth_time = PLANT_FRUIT_GROWTH_VERY_FAST
	fruit_size = PLANT_FRUIT_SIZE_MEDIUM
	mutations = list(/datum/plant_feature/fruit/sugarcane)
