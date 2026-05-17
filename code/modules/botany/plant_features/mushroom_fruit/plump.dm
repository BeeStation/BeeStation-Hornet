/*
	Plump
*/
/datum/plant_feature/fruit/mushroom/plump
	species_name = "denso fungus"
	name = "plump helmet"
	icon_state = "plump"
	colour_overlay = "plump_colour"
	colour_override = "#9964b1"
	seed_icon_state = "mycelium-plump"
	fruit_product = /obj/item/food/grown/mushroom/plumphelmet
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/mushroom/plump/walking)

/*
	Walking
*/
/datum/plant_feature/fruit/mushroom/plump/walking
	species_name = "ingredior fungus"
	name = "walking mushroom"
	seed_icon_state = "mycelium-walkingmushroom"
	fruit_product = /obj/item/food/grown/mushroom/plumphelmet
	plant_traits = list(/datum/plant_trait/fruit/killer/friendly/walking)
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/mushroom/plump)


