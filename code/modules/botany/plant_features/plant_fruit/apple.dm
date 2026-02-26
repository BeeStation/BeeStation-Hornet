/*
	Apple
*/
/datum/plant_feature/fruit/apple
	species_name = "malum parvum"
	name = "apple"
	icon_state = "apple"
	fruit_product = /obj/item/food/grown/apple
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/apple/gold = 20)

/*
	Gold Apple
*/
/datum/plant_feature/fruit/apple/gold
	species_name = "malum aurum"
	name = "gold apple"
	icon_state = "apple_gold"
	fruit_product = /obj/item/food/grown/apple/gold
	fast_reagents = list(/datum/reagent/gold = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/apple)
