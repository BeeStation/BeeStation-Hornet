/*
	Carrot
*/
/datum/plant_feature/fruit/carrot
	species_name = "carota solis"
	name = "carrot"
	icon_state = "carrot"
	fruit_product = /obj/item/food/grown/carrot
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/medicine/oculine = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/carrot/parsnip)

/*
	Parsnip
*/
/datum/plant_feature/fruit/carrot/parsnip
	species_name = "carota pastinaca"
	name = "parsnip"
	icon_state = "parsnip"
	fruit_product = /obj/item/food/grown/parsnip
	fast_reagents = list()
	mutations = list(/datum/plant_feature/fruit/carrot)
