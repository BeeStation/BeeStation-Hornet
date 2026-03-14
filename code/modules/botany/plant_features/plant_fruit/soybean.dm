/*
	Soybean
*/
/datum/plant_feature/fruit/soybean
	species_name = "faba anima"
	name = "soybean"
	icon_state = "pod"
	colour_override = "#95d94d"
	fruit_product = /obj/item/food/grown/soybeans
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/consumable/nutriment/fat/oil = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_VERY_FAST
	mutations = list(/datum/plant_feature/fruit/soybean/koi = 10)

/*
	Koibean
*/
/datum/plant_feature/fruit/soybean/koi
	species_name = "faba piscis"
	name = "koibean"
	icon_state = "pod"
	colour_override = "#d4d94d"
	fruit_product = /obj/item/food/grown/koibeans
	fast_reagents = list(/datum/reagent/toxin/carpotoxin = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/soybean)
