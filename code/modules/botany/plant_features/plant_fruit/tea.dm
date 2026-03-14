/*
	Tea
*/
/datum/plant_feature/fruit/tea
	species_name = "aspera folium"
	name = "tea leaf"
	icon_state = "tea"
	fruit_product = /obj/item/food/grown/tea
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_VERY_FAST
	fast_reagents = list(/datum/reagent/toxin/teapowder = PLANT_REAGENT_MEDIUM, /datum/reagent/fluorine = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/tea/other)

/*
	The other Tea
*/
/datum/plant_feature/fruit/tea/other
	species_name = "astra folium"
	name = "astra tea leaf"
	icon_state = "tea_2"
	fruit_product = /obj/item/food/grown/tea/astra
	fast_reagents = list(/datum/reagent/toxin/teapowder = PLANT_REAGENT_MEDIUM, /datum/reagent/fluorine = PLANT_REAGENT_MEDIUM, /datum/reagent/medicine/synaptizine = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/tea)
