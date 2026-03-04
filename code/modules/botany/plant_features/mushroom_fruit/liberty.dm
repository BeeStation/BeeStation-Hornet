/*
	Liberty
*/
//TODO: - Sprites
/datum/plant_feature/fruit/mushroom/liberty
	species_name = "libertatem fungus"
	name = "liberty-cap"
	icon_state = "cap"
	colour_overlay = "cap_colour"
	colour_override = "#ff0"
	fruit_product = /obj/item/food/grown/mushroom/libertycap
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_FAST
	fast_reagents = list(/datum/reagent/drug/mushroomhallucinogen = PLANT_REAGENT_SMALL)
