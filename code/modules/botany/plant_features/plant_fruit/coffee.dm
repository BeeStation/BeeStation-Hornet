/*
	Coffee
	Micro fruit type that grows very fast
*/
/datum/plant_feature/fruit/coffee
	species_name = "capulus faba"
	name = "coffee"
	icon_state = "berry"
	colour_override = "#42200b"
	fruit_product = /obj/item/food/grown/coffee
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/toxin/coffeepowder = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_VERY_FAST
	mutations = list(/datum/plant_feature/fruit/coffee/robusta)

/*
	Coffee Robusta
*/
/datum/plant_feature/fruit/coffee/robusta
	species_name = "capulus robusta"
	name = "coffee robusta"
	colour_override = "#9a1717"
	fruit_product = /obj/item/food/grown/coffee/robusta
	fast_reagents = list(/datum/reagent/toxin/coffeepowder = PLANT_REAGENT_SMALL, /datum/reagent/medicine/ephedrine = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/coffee)
