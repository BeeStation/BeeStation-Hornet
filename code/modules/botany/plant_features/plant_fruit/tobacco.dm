/*
	Tobacco
*/
/datum/plant_feature/fruit/tobacco
	species_name = "folium fumigant"
	name = "tobacco"
	icon_state = "tabacco"
	icon_uneven = TRUE
	fruit_product = /obj/item/food/grown/tobacco
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_VERY_FAST
	fast_reagents = list(/datum/reagent/drug/nicotine = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/tobacco/space)

/*
	Space Tobacco
*/
/datum/plant_feature/fruit/tobacco/space
	species_name = "spatium folium"
	name = "space tobacco"
	icon_state = "tabacco_2"
	icon_uneven = TRUE
	genetic_budget = 4
	fruit_product = /obj/item/food/grown/tobacco/space
	fast_reagents = list(/datum/reagent/drug/nicotine = PLANT_REAGENT_MEDIUM, /datum/reagent/medicine/salbutamol = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/tobacco)
