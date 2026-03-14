/*
	Whitebeet
*/
/datum/plant_feature/fruit/whitebeet
	species_name = "beta album"
	name = "whitebeet"
	icon_state = "parsnip"
	fruit_product = /obj/item/food/grown/whitebeet
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/consumable/sugar = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/whitebeet/red)

/*
	Redbeet
*/
/datum/plant_feature/fruit/whitebeet/red
	species_name = "beta erubesco"
	name = "redbeet"
	icon_state = "parsnip"
	colour_override = "#be1c6a"
	fruit_product = /obj/item/food/grown/redbeet
	fast_reagents = list(/datum/reagent/sodium = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/whitebeet)
