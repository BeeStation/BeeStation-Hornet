/*
	Pumpkin
	Slow growing large volume fruit
*/
/datum/plant_feature/fruit/pumpkin
	species_name = "cucurbita magna"
	name = "pumpkin"
	icon_state = "pumpkin"
	seed_icon_state = "seed-pumpkin"
	icon_uneven = TRUE
	fruit_product = /obj/item/food/grown/pumpkin
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment/large, /datum/plant_trait/reagent/fruit/vitamin/large)
	total_volume = PLANT_FRUIT_VOLUME_LARGE
	growth_time = PLANT_FRUIT_GROWTH_SLOW
	fruit_size = PLANT_FRUIT_SIZE_LARGE
	mutations = list(/datum/plant_feature/fruit/pumpkin/blumpkin = 3)

/*
	Blumpkin
*/
/datum/plant_feature/fruit/pumpkin/blumpkin
	species_name = "cucurbita venenum"
	name = "blumpkin"
	icon_state = "pumpkin-2"
	colour_override = "#8cf3ff"
	seed_icon_state = "seed-blumpkin"
	genetic_budget = 3
	fruit_product = /obj/item/food/grown/blumpkin
	fast_reagents = list(/datum/reagent/ammonia = PLANT_REAGENT_MEDIUM, /datum/reagent/chlorine = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/pumpkin)
