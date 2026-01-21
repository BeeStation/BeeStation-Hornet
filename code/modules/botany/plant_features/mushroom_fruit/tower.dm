/*
	Tower-cap
*/
//TODO: - Sprites
/datum/plant_feature/fruit/mushroom/tower
	species_name = "turrim fungus"
	name = "tower-cap"
	icon_state = "tower"
	colour_overlay = "tower_colour"
	colour_override = "#57a02c"
	fruit_product = /obj/item/grown/log
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	fast_reagents = list(/datum/reagent/carbon = PLANT_REAGENT_LARGE)
	mutations = list(/datum/plant_feature/fruit/mushroom/tower/steel)

/*
	Steel-cap
*/
//TODO: - Sprites
/datum/plant_feature/fruit/mushroom/tower/steel
	species_name = "ferro fungus"
	name = "steel-cap"
	colour_override = "#ffee00"
	fruit_product = /obj/item/grown/log/steel
	fast_reagents = list(/datum/reagent/iron = PLANT_REAGENT_LARGE)
	mutations = list(/datum/plant_feature/fruit/mushroom/tower)
