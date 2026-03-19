/*
	Starthistle
*/
/datum/plant_feature/fruit/starthistle
	species_name = "stella carduus"
	name = "starthistle"
	icon_state = "star"
	seed_icon_state = "seed-starthistle"
	fruit_product = /obj/item/plant_seeds/preset/starthistle
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin,
	/datum/plant_trait/fruit/liquid_contents)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/starthistle/galaxy = 10)

/*
	Galaxy Thistle
*/
/datum/plant_feature/fruit/starthistle/galaxy
	species_name = "galaxia carduus"
	name = "galaxythistle"
	icon_state = "galaxy"
	seed_icon_state = "seed-galaxythistle"
	fruit_product = /obj/item/food/grown/galaxythistle
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	genetic_budget = 4
	fast_reagents = list(/datum/reagent/medicine/silibinin = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/starthistle)
