/*
	Wheat
*/
/datum/plant_feature/fruit/wheat
	species_name = "triticum aurum"
	name = "wheat"
	icon_state = "corn-2"
	colour_override = "#d8d86d"
	fruit_product = /obj/item/food/grown/wheat
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_VERY_FAST
	mutations = list(/datum/plant_feature/fruit/wheat/oat)

/*
	Oat
*/
/datum/plant_feature/fruit/wheat/oat
	species_name = "triticum patet"
	name = "oat"
	icon_state = "corn-2"
	colour_override = "#48923e"
	fruit_product = /obj/item/food/grown/oat
	mutations = list(/datum/plant_feature/fruit/wheat/meat = 10)

/*
	Meat
*/
/datum/plant_feature/fruit/wheat/meat
	species_name = "triticum escam"
	name = "meat"
	icon_state = "corn-2"
	colour_override = "#ff0000"
	fruit_product = /obj/item/food/grown/meatwheat
	mutations = list(/datum/plant_feature/fruit/wheat)
