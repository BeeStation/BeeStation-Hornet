/*
	Eggplant
*/
/datum/plant_feature/fruit/eggplant
	species_name = "aubergine purpura"
	name = "eggplant"
	icon_state = "eggplant"
	fruit_product = /obj/item/food/grown/eggplant
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/eggplant/egg = 10)

/*
	Egg-Plant
*/
/datum/plant_feature/fruit/eggplant/egg
	species_name = "aubergine ovum"
	name = "egg-plant"
	icon_state = "eggplant-2"
	fruit_product = /obj/item/food/grown/shell/eggy
	mutations = list(/datum/plant_feature/fruit/eggplant)
