/*
	Reishi
*/
/datum/plant_feature/fruit/mushroom/reishi
	species_name = "orientalem fungus"
	name = "reishi"
	icon_state = "chanterelle"
	colour_overlay = "chanterelle_colour"
	colour_override = "#ff7b00"
	seed_icon_state = "mycelium-reishi"
	fruit_product = /obj/item/food/grown/mushroom/reishi
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_FAST
	fast_reagents = list(/datum/reagent/medicine/morphine = PLANT_REAGENT_MEDIUM, /datum/reagent/medicine/charcoal = PLANT_REAGENT_MEDIUM)
