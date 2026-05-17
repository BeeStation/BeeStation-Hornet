/*
	Potato
*/
/datum/plant_feature/fruit/potato
	species_name = "annuum patet"
	name = "potato"
	icon_state = "potato"
	seed_icon_state = "seed-potato"
	fruit_product = /obj/item/food/grown/potato
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/potato/sweet)

/*
	Sweet Potato
*/
/datum/plant_feature/fruit/potato/sweet
	species_name = "annuum dulce"
	name = "sweet potato"
	icon_state = "potato-2"
	colour_override = "#c96576"
	seed_icon_state = "seed-sweetpotato"
	fruit_product = /obj/item/food/grown/potato/sweet
	fast_reagents = list(/datum/reagent/consumable/sugar = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/potato)
