/*
	Mycelium, generic body for mushrooms
*/
/datum/plant_feature/body/mushroom
	species_name = "fungus corporis"
	name = "mycelium"
	icon_state = ""
	layer_offset = 0
	overlay_positions = list(list(9, 2), list(20, 2), list(16, 4))
	yields = PLANT_BODY_YIELD_FOREVER
	yield_cooldown_time = PLANT_BODY_YIELD_TIME_FAST
	max_harvest = PLANT_BODY_HARVEST_SMALL
	slot_size = PLANT_BODY_SLOT_SIZE_MICRO
	growth_time = PLANT_BODY_GROWTH_VERY_FAST
	genetic_budget = 1
	//Mushrooms have no needs
	plant_needs = list()
	//We can pair with only mushroom fruit, but any kind of roots
	whitelist_features = list(/datum/plant_feature/fruit/mushroom, /datum/plant_feature/roots)
