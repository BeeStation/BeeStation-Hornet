/*
	Corn
*/
/datum/plant_feature/fruit/corn
	species_name = "frumentum flavum"
	name = "corn"
	icon_state = "corn"
	icon_uneven = TRUE
	fruit_product = /obj/item/food/grown/corn
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/consumable/nutriment/fat/oil = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/corn/snap = 10)

/*
	Snap Corn
*/
/datum/plant_feature/fruit/corn/snap
	species_name = "frumentum disrumpam"
	name = "snap corn"
	icon_state = "snapcorn"
	fruit_product = /obj/item/grown/snapcorn
	mutations = list(/datum/plant_feature/fruit/corn)
