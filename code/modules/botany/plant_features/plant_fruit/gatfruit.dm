/*
	gatfruit
*/
/datum/plant_feature/fruit/gat
	species_name = "sagitta fructus"
	name = "gatfruit"
	icon_state = "gat"
	fruit_product = /obj/item/food/grown/shell/gatfruit
	fast_reagents = list(/datum/reagent/sulfur = PLANT_REAGENT_SMALL, /datum/reagent/carbon = PLANT_REAGENT_SMALL, /datum/reagent/nitrogen = PLANT_REAGENT_SMALL, /datum/reagent/potassium = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_SLOW
	fruit_size = PLANT_FRUIT_SIZE_LARGE
